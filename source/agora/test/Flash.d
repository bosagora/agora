/*******************************************************************************

    Contains Flash layer tests.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Flash;

version (unittest):

import agora.api.FullNode : FullNodeAPI = API;
import agora.common.Amount;
import agora.common.ManagedDatabase;
import agora.common.Task;
import agora.consensus.data.genesis.Test;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXO;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr;
import agora.flash.api.FlashAPI;
import agora.flash.api.FlashControlAPI;
import agora.flash.api.FlashListenerAPI;
import agora.flash.Channel;
import agora.flash.Config;
import agora.flash.ErrorCode;
import agora.flash.Invoice;
import agora.flash.Node;
import agora.flash.OnionPacket;
import agora.flash.Route;
import agora.flash.Scripts;
import agora.flash.Types;
import agora.script.Engine;
import agora.script.Lock;
import agora.script.Script;
import agora.serialization.Serializer;
import agora.test.Base;
import agora.utils.Log;

import geod24.LocalRest : Listener;
import geod24.Registry;

import std.algorithm;
import std.conv;
import std.exception;

import core.stdc.time;
import core.time;
import core.thread;

mixin AddLogger!();

/// Listener (wallet / front-end)
public interface TestFlashListenerAPI : FlashListenerAPI
{
    /// wait until we get a signal that the payment for this invoice
    /// has succeeded / failed, and return true / false for success
    ErrorCode waitUntilNotified (Invoice);

    /// wait until we get a notification about the given channel state,
    /// and return any associated error codes
    ErrorCode waitUntilChannelState (Hash, ChannelState, PublicKey node = PublicKey.init);
}

/// In addition to the Flash APIs, we provide methods for conditional waits
/// and extracting update / closing / settle pairs, and forceful channel close.
public interface TestFlashAPI : FlashControlAPI
{
    /// Wait for the specified update index. Index 0 is the funding state.
    /// Note that a payment also triggers an update later when the secret
    /// is revealed, so the indexes passed are usually even numbers (2, 4, 6..)
    public void waitForUpdateIndex (in PublicKey pk, in Hash chan_id,
        in uint index);

    /// Wait until the specified channel ID has been gossiped to this node
    public void waitForChannelDiscovery (in Hash chan_id);

    /// Wait until the specified channel ID has been opened. The node must be
    /// part of this channel.
    public void waitForChannelOpen (in PublicKey pk, in Hash chan_id);

    /// Wait until the specified channel update has been gossiped to this node
    public ChannelUpdate waitForChannelUpdate (in Hash chan_id,
        in PaymentDirection dir, in uint update_idx);

    /// Force publishing an update tx with the given index to the blockchain.
    /// Used for testing and ensuring the counter-party detects the update tx
    /// and publishes the latest state to the blockchain.
    public Transaction getPublishUpdateIndex (in PublicKey pk, in Hash chan_id,
        in uint index);

    /// Get the expected closing tx that should have been published to the chain
    public Transaction getClosingTx (in PublicKey pk, in Hash chan_id);

    /// Get the expected settlement tx when a trigger was published to the chain
    public Transaction getLastSettleTx (in PublicKey pk, in Hash chan_id);

    /// Print out the contents of the log
    public abstract void printLog ();

    /// Shut down any timers (forwards to ThinFlashNode.shutdown)
    public void shutdownNode ();

    /// disable/enable tx publish
    public void setPublishEnable (in bool enabled);
}

/// Controls behavior of database storage for the Flash layer
enum DatabaseStorage : string
{
    /// db erased between restarts
    Local = ":memory:",

    /// db preserved between restarts
    Static = ":static:",
}

/// A thin localrest flash node which itself is not a FullNode / Validator
public class TestFlashNode : ThinFlashNode, TestFlashAPI
{
    ///
    protected Registry!TestAPI* agora_registry;

    ///
    protected Registry!TestFlashAPI* flash_registry;

    ///
    protected Registry!TestFlashListenerAPI* listener_registry;

    ///
    protected bool allow_publish;

    ///
    public this (FlashConfig conf, Registry!TestAPI* agora_registry,
        string agora_address, DatabaseStorage storage,
        Registry!TestFlashAPI* flash_registry,
        Registry!TestFlashListenerAPI* listener_registry)
    {
        this.agora_registry = agora_registry;
        this.flash_registry = flash_registry;
        this.listener_registry = listener_registry;
        const genesis_hash = hashFull(GenesisBlock);
        const TestStackMaxTotalSize = 16_384;
        const TestStackMaxItemSize = 512;
        this.allow_publish = true;
        auto engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
        super(conf, storage, genesis_hash, engine, new LocalRestTaskManager(),
            agora_address);
    }

    /***************************************************************************

        Get either a managed database local to the class, or a static one
        which will survive restarts.

        Params:
            db_path = path to the database

        Returns:
            a ManagedDatabase instance for the given path

    ***************************************************************************/

    protected override ManagedDatabase getManagedDatabase (string db_path)
    {
        if (db_path == DatabaseStorage.Static)
        {
            static ManagedDatabase static_db;
            if (static_db is null)
                static_db = new ManagedDatabase(":memory:");
            return static_db;
        }

        return new ManagedDatabase(db_path);
    }

    ///
    public override void shutdownNode ()
    {
        log.info("Shutting down node!");
        super.shutdown();  // kill timers
    }

    ///
    protected override FullNodeAPI getAgoraClient (Address address,
        Duration timeout)
    {
        auto tid = this.agora_registry.locate(address);
        assert(tid != typeof(tid).init, "Agora node not initialized");
        return new RemoteAPI!TestAPI(tid, timeout);
    }

    ///
    protected override TestFlashAPI getFlashClient (in PublicKey peer_pk,
        Duration timeout) @trusted
    {
        if (auto peer = peer_pk in this.known_peers)
        {
            auto control_api = cast(TestFlashAPI)*peer;
            assert(control_api !is null);  // something's wrong
            return control_api;
        }

        // give some time to the other node to wake up and register
        Listener!TestFlashAPI tid;
        foreach (i; 0 .. 5)
        {
            tid = this.flash_registry.locate(peer_pk.to!string);
            if (tid != typeof(tid).init)
                break;

            this.taskman.wait(500.msecs);
        }

        assert(tid != typeof(tid).init, "Flash node not initialized");

        auto peer = new RemoteAPI!TestFlashAPI(tid, timeout);
        this.known_peers[peer_pk] = peer;
        if (this.known_channels.length > 0)
            peer.gossipChannelsOpen(this.channel_updates.byValue
                .map!(updates => updates.byValue).joiner
                .map!(update => ChannelOpen(this.known_channels[update.chan_id].height,
                                            this.known_channels[update.chan_id].conf, update)).array);

        return peer;
    }

    protected override TestFlashListenerAPI getFlashListenerClient (
        string address, Duration timeout) @trusted
    {
        auto tid = this.listener_registry.locate(address);
        assert(tid != typeof(tid).init);
        return new RemoteAPI!TestFlashListenerAPI(tid, timeout);
    }

    ///
    public override Transaction getPublishUpdateIndex (in PublicKey pk,
        in Hash chan_id, in uint index)
    {
        auto channel = chan_id in this.channels[pk];
        assert(channel !is null);
        return channel.getPublishUpdateIndex(index);
    }

    ///
    public override void waitForUpdateIndex (in PublicKey pk, in Hash chan_id,
        in uint index)
    {
        auto channel = chan_id in this.channels[pk];
        assert(channel !is null);
        return channel.waitForUpdateIndex(index);
    }

    ///
    public override void waitForChannelDiscovery (in Hash chan_id)
    {
        // Wait for discovery and first set of updates
        while (chan_id !in this.known_channels ||
                chan_id !in this.channel_updates ||
                this.channel_updates[chan_id].length < 2)
            this.taskman.wait(100.msecs);
    }

    ///
    public override void waitForChannelOpen (in PublicKey pk, in Hash chan_id)
    {
        super.waitChannelOpen(pk, chan_id);
    }

    ///
    public override ChannelUpdate waitForChannelUpdate (in Hash chan_id,
        in PaymentDirection dir, in uint update_idx)
    {
        while (1)
        {
            if (auto updates = chan_id in this.channel_updates)
                if (auto update = dir in *updates)
                    if (update.update_idx == update_idx)
                        return *update;

            this.taskman.wait(100.msecs);
        }
    }

    ///
    public override Transaction getClosingTx (in PublicKey pk, in Hash chan_id)
    {
        auto channel = chan_id in this.channels[pk];
        assert(channel !is null);
        return channel.getClosingTx();
    }

    ///
    public override Transaction getLastSettleTx (in PublicKey pk, in Hash chan_id)
    {
        auto channel = chan_id in this.channels[pk];
        assert(channel !is null);
        return channel.getLastSettleTx();
    }

    /// Prints out the log contents for this node
    public void printLog ()
    {
        auto output = stdout.lockingTextWriter();
        output.formattedWrite("Log for Flash node %s:\n", cast(void*)this);
        output.put("======================================================================\n");
        CircularAppender!()().print(output);
        output.put("======================================================================\n\n");
        stdout.flush();
    }

    /// disable/enable tx publish
    public override void setPublishEnable (in bool enabled)
    {
        this.allow_publish = enabled;
    }

    ///
    protected override void postTransaction (Transaction tx)
    {
        if (this.allow_publish)
            super.postTransaction(tx);
        else
            log.info("Skipping publishing {}", tx);
    }
}

/// Is in charge of spawning the flash nodes
public class FlashNodeFactory (FlashListenerType = FlashListener)
{
    /// Registry of nodes
    private Registry!TestAPI* agora_registry;

    /// we keep a separate LocalRest registry of the flash "nodes"
    private Registry!TestFlashAPI flash_registry;

    /// and a registry of listener nodes (usually just one)
    private Registry!TestFlashListenerAPI listener_registry;

    /// list of flash addresses
    private PublicKey[] addresses;

    /// list of listener addresses
    private string[] listener_addresses;

    /// list of flash nodes
    private RemoteAPI!TestFlashAPI[] nodes;

    /// list of FlashListenerAPI nodes
    private RemoteAPI!TestFlashListenerAPI[] listener_nodes;

    /// Flash listener address
    private static const ListenerAddress = "flash-listener";

    /// Flash listener (Wallet)
    public TestFlashListenerAPI listener;

    /// Ctor
    public this (Registry!TestAPI* agora_registry)
    {
        this.agora_registry = agora_registry;
        this.flash_registry.initialize();
        this.listener_registry.initialize();

        this.listener = this.createFlashListener!FlashListenerType(
            ListenerAddress);
    }

    /// Create a new flash node user
    public RemoteAPI!TestFlashAPI create (FlashNodeImpl = TestFlashNode)
        (const KeyPair kp, string agora_address,
         DatabaseStorage storage = DatabaseStorage.Local)
    {
        FlashConfig conf = { enabled : true,
            min_funding : Amount(1000),
            max_funding : Amount(100_000_000),
            min_settle_time : 0,
            max_settle_time : 100,
            max_retry_time : 4.seconds,
            max_retry_delay : 100.msecs,
            listener_address : ListenerAddress, };
        return this.create!FlashNodeImpl(kp, conf, agora_address, storage);
    }

    /// ditto
    public RemoteAPI!TestFlashAPI create (FlashNodeImpl = TestFlashNode)
        (const KeyPair kp, FlashConfig conf, string agora_address,
         DatabaseStorage storage = DatabaseStorage.Local)
    {
        RemoteAPI!TestFlashAPI api = RemoteAPI!TestFlashAPI.spawn!FlashNodeImpl(
            conf, this.agora_registry, agora_address, storage,
            &this.flash_registry, &this.listener_registry,
            10.seconds);  // timeout from main thread

        this.addresses ~= kp.address;
        this.nodes ~= api;
        this.flash_registry.register(kp.address.to!string, api.listener());
        api.start();
        api.registerKey(kp.secret);

        return api;
    }

    /// Create a new FlashListenerAPI node
    public RemoteAPI!TestFlashListenerAPI createFlashListener (
        Listener : TestFlashListenerAPI)(string address)
    {
        const string agora_address = format("Validator #%s (%s)", 0, genesis_validator_keys[0].address);
        RemoteAPI!TestFlashListenerAPI api
            = RemoteAPI!TestFlashListenerAPI.spawn!Listener(this.agora_registry, agora_address, 5.seconds);
        this.listener_registry.register(address, api.listener());
        this.listener_addresses ~= address;
        this.listener_nodes ~= api;
        return api;
    }

    /***************************************************************************

        Print out the logs for each node

    ***************************************************************************/

    public void printLogs (string file = __FILE__, int line = __LINE__)
    {
        synchronized  // make sure logging output is not interleaved
        {
            writeln("---------------------------- START OF LOGS ----------------------------");
            writefln("%s(%s): Flash node logs:\n", file, line);
            foreach (node; this.nodes)
            {
                try
                {
                    node.printLog();
                }
                catch (Exception ex)
                {
                    writefln("Could not print logs for node: %s", ex.message);
                }
            }
        }

        auto output = stdout.lockingTextWriter();
        output.put("Flash log for tests\n");
        output.put("======================================================================\n");
        CircularAppender!()().print(output);
        output.put("======================================================================\n\n");
        stdout.flush();
    }

    /// Shut down all the nodes
    public void shutdown ()
    {
        foreach (address; this.addresses)
            enforce(this.flash_registry.unregister(address.to!string));

        foreach (address; this.listener_addresses)
            enforce(this.listener_registry.unregister(address));

        foreach (node; this.nodes)
            node.shutdownNode();

        foreach (node; this.nodes)
            node.ctrl.shutdown();

        foreach (node; this.listener_nodes)
        {
            node.ctrl.shutdown();
        }
    }

    /// Shut down & restart all nodes
    public void restart ()
    {
        foreach (node; this.nodes)
        {
            node.ctrl.restart((Object node) { (cast(TestFlashNode)node).shutdownNode(); });
            node.ctrl.withTimeout(0.msecs, (scope FlashControlAPI api) { api.start(); });
        }
    }
}

/// Listens for Flash events (if registered with a Flash node)
private class FlashListener : TestFlashListenerAPI
{
    static struct State
    {
        ChannelState state;
        ErrorCode error;
    }

    State[PublicKey][Hash] channel_state;
    ErrorCode[Invoice] invoices;
    LocalRestTaskManager taskman;
    FullNodeAPI agora_node;

    public this (Registry!TestAPI* agora_registry, string agora_address)
    {
        this.taskman = new LocalRestTaskManager();

        auto tid = agora_registry.locate(agora_address);
        assert(tid != typeof(tid).init, "Agora node not initialized");
        this.agora_node = new RemoteAPI!TestAPI(tid, 5.seconds);
    }

    public void onPaymentSuccess (PublicKey pk, Invoice invoice)
    {
        this.invoices[invoice] = ErrorCode.None;
    }

    public void onPaymentFailure (PublicKey pk, Invoice invoice, ErrorCode error)
    {
        this.invoices[invoice] = error;
    }

    public ErrorCode waitUntilNotified (Invoice invoice)
    {
        while (1)
        {
            if (auto inv = invoice in this.invoices)
            {
                scope (exit) this.invoices.remove(invoice);
                return *inv;
            }

            this.taskman.wait(200.msecs);
        }
    }

    public ErrorCode waitUntilChannelState (Hash chan_id, ChannelState state,
        PublicKey node = PublicKey.init)
    {
        scope (exit) this.channel_state.remove(chan_id);
        while (1)
        {
            if (auto chan_states = chan_id in this.channel_state)
            {
                if (auto chan_state = node in *chan_states)
                    if ((*chan_state).state >= state)
                        return (*chan_state).error;
                if (node == PublicKey.init)
                {
                    auto states = chan_states.byValue
                        .filter!(chan_state => chan_state.state >= state);
                    if (!states.empty())
                        return states.front.error;
                }
            }

            this.taskman.wait(200.msecs);
        }
    }

    public void onChannelNotify (PublicKey pk, Hash chan_id, ChannelState state,
        ErrorCode error, Height height = Height(0))
    {
        if (chan_id !in this.channel_state)
            this.channel_state[chan_id] = typeof(this.channel_state[chan_id]).init;
        this.channel_state[chan_id][pk] = State(state, error);
    }

    public string onRequestedChannelOpen (PublicKey pk, ChannelConfig conf)
    {
        return null;  // accept by default
    }

    public FeeUTXOs getFeeUTXOs (PublicKey pk, Amount amount)
    {
        auto last_height = agora_node.getBlockHeight();

        FeeUTXOs utxos;
        do
        {
            const last_block = agora_node.getBlock(last_height);
            foreach (tx; last_block.txs)
            foreach (idx, output; tx.outputs)
                if (output.address() == pk)
                {
                    utxos.utxos ~= UTXO.getHash(tx.hashFull(), idx);
                    utxos.total_value += output.value;
                }

            last_height--;
        } while (last_height > 0 && utxos.total_value < amount);

        return utxos;
    }

    public Amount getEstimatedTxFee ()
    {
        return Amount(1);
    }
}

private TestConf flashTestConf ()
{
    TestConf conf;
    conf.consensus.quorum_threshold = 100;
    // TODO: remove this line when fees are handled
    conf.consensus.min_fee = Amount(0);
    conf.node.min_fee_pct = 0;
    return conf;
}

/// Test unilateral non-collaborative close (funding + update* + settle)
//version (none)
unittest
{
    auto conf = flashTestConf();
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope (exit) network.shutdown();
    //scope (failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];
    scope (failure) node_1.printLog();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    foreach (idx, tx; txs)
    {
        node_1.postTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory!()(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0, genesis_validator_keys[0].address);
    auto alice = factory.create(WK.Keys.A, address);
    auto charlie = factory.create(WK.Keys.C, address);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 3;
    //const Settle_10_Blocks = 10;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(WK.Keys.A.address,
        utxo, utxo_hash, Amount(10_000), Settle_1_Blocks, WK.Keys.C.address);
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    const chan_id = chan_id_res.value;
    factory.listener.waitUntilChannelState(chan_id, ChannelState.WaitingForFunding);

    // await funding transaction
    network.expectTxExternalization(chan_id);

    // wait for the parties & listener to detect the funding tx
    alice.waitForChannelOpen(WK.Keys.A.address, chan_id);
    charlie.waitForChannelOpen(WK.Keys.C.address, chan_id);
    factory.listener.waitUntilChannelState(chan_id, ChannelState.Open);

    auto update_tx = alice.getPublishUpdateIndex(WK.Keys.A.address, chan_id, 0);

    /* do some off-chain transactions */
    auto inv_1 = charlie.createNewInvoice(WK.Keys.C.address, Amount(5_000), time_t.max, "payment 1");
    alice.payInvoice(WK.Keys.A.address, inv_1.value);

    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 2);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 2);

    auto inv_2 = charlie.createNewInvoice(WK.Keys.C.address, Amount(1_000), time_t.max, "payment 2");
    alice.payInvoice(WK.Keys.A.address, inv_2.value);

    // need to wait for invoices to be complete before we have the new balance
    // to send in the other direction
    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 4);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 4);

    // note the reverse payment from charlie to alice. Can use this for refunds too.
    auto inv_3 = alice.createNewInvoice(WK.Keys.A.address, Amount(2_000), time_t.max, "payment 3");
    charlie.payInvoice(WK.Keys.C.address, inv_3.value);

    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 6);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 6);

    // alice is acting bad
    log.info("Alice unilaterally closing the channel..");
    network.expectTxExternalization(update_tx);
    factory.listener.waitUntilChannelState(chan_id,
        ChannelState.StartedUnilateralClose);

    // at this point charlie will automatically publish the latest update tx
    network.expectHeightAndPreImg(Height(11), network.blocks[0].header);

    // and then a settlement will be published (but only after time lock expires)
    iota(Settle_1_Blocks * 2).each!(idx => network.addBlock(true));
    factory.listener.waitUntilChannelState(chan_id, ChannelState.Closed);
}

/// Test the settlement timeout branch for the
/// unilateral non-collaborative close (funding + update* + settle)
//version (none)
unittest
{
    auto conf = flashTestConf();
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope (exit) network.shutdown();
    //scope (failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];
    scope (failure) node_1.printLog();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    foreach (idx, tx; txs[0 .. 4])
    {
        node_1.postTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory!()(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0, genesis_validator_keys[0].address);
    auto alice = factory.create(WK.Keys.A, address);
    auto charlie = factory.create(WK.Keys.C, address);

    // 4 blocks settle time after trigger tx is published
    const Settle_4_Blocks = 4;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(WK.Keys.A.address,
        utxo, utxo_hash, Amount(10_000), Settle_4_Blocks, WK.Keys.C.address);
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    const chan_id = chan_id_res.value;
    factory.listener.waitUntilChannelState(chan_id, ChannelState.WaitingForFunding);

    // await funding transaction
    network.expectTxExternalization(chan_id);

    // wait for the parties & listener to detect the funding tx
    alice.waitForChannelOpen(WK.Keys.A.address, chan_id);
    charlie.waitForChannelOpen(WK.Keys.C.address, chan_id);
    factory.listener.waitUntilChannelState(chan_id, ChannelState.Open);

    auto update_tx = alice.getPublishUpdateIndex(WK.Keys.A.address, chan_id, 0);

    /* do some off-chain transactions */
    auto inv_1 = charlie.createNewInvoice(WK.Keys.C.address, Amount(5_000), time_t.max,
        "payment 1");
    alice.payInvoice(WK.Keys.A.address, inv_1.value);

    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 2);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 2);

    auto inv_2 = charlie.createNewInvoice(WK.Keys.C.address, Amount(1_000), time_t.max,
        "payment 2");
    alice.payInvoice(WK.Keys.A.address, inv_2.value);

    // need to wait for invoices to be complete before we have the new balance
    // to send in the other direction
    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 4);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 4);

    // note the reverse payment from charlie to alice. Can use this for refunds too.
    auto inv_3 = alice.createNewInvoice(WK.Keys.A.address, Amount(2_000), time_t.max,
        "payment 3");
    charlie.payInvoice(WK.Keys.C.address, inv_3.value);

    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 6);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 6);

    // alice is acting bad
    log.info("Alice unilaterally closing the channel..");
    network.expectTxExternalization(update_tx);
    factory.listener.waitUntilChannelState(chan_id,
        ChannelState.StartedUnilateralClose);

    // at this point charlie will automatically publish the latest update tx
    network.expectHeightAndPreImg(Height(7), network.blocks[0].header);

    // at `Settle_4_Blocks` blocks need to be externalized before a settlement
    // can be attached to the update transaction
    node_1.postTransaction(txs[4]);
    network.expectHeightAndPreImg(Height(8), network.blocks[0].header);
    node_1.postTransaction(txs[5]);
    network.expectHeightAndPreImg(Height(9), network.blocks[0].header);
    node_1.postTransaction(txs[6]);
    network.expectHeightAndPreImg(Height(10), network.blocks[0].header);
    node_1.postTransaction(txs[7]);
    network.expectHeightAndPreImg(Height(11), network.blocks[0].header);

    // and then a settlement will be automatically published
    iota(Settle_4_Blocks * 2).each!(idx => network.addBlock(true));
    factory.listener.waitUntilChannelState(chan_id, ChannelState.Closed);
}

/// Test attempted collaborative close with a non-collaborative counter-party,
/// forcing the first counter-party to initiate a non-collaborative close.
//version (none)
unittest
{
    static class RejectingCloseNode : TestFlashNode
    {
        mixin ForwardCtor!();

        ///
        protected override Result!Point closeChannel (PublicKey sender_pk,
            PublicKey pk, Hash chan_id, uint seq_id, Point peer_nonce,
            Amount fee)
        {
            return Result!Point(ErrorCode.Unknown);
        }
    }

    auto conf = flashTestConf();
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope (exit) network.shutdown();
    //scope (failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];
    scope (failure) node_1.printLog();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    foreach (idx, tx; txs)
    {
        node_1.postTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory!()(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0, genesis_validator_keys[0].address);
    auto alice = factory.create(WK.Keys.A, address);
    auto charlie = factory.create!RejectingCloseNode(WK.Keys.C, address);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;
    //const Settle_10_Blocks = 10;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(WK.Keys.A.address,
        utxo, utxo_hash, Amount(10_000), Settle_1_Blocks, WK.Keys.C.address);
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    const chan_id = chan_id_res.value;
    factory.listener.waitUntilChannelState(chan_id, ChannelState.WaitingForFunding);

    // await funding transaction
    network.expectTxExternalization(chan_id);

    // wait for the parties & listener to detect the funding tx
    alice.waitForChannelOpen(WK.Keys.A.address, chan_id);
    charlie.waitForChannelOpen(WK.Keys.C.address, chan_id);
    factory.listener.waitUntilChannelState(chan_id, ChannelState.Open);

    /* do some off-chain transactions */
    auto inv_1 = charlie.createNewInvoice(WK.Keys.C.address, Amount(5_000), time_t.max, "payment 1");
    alice.payInvoice(WK.Keys.A.address, inv_1.value);

    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 2);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 2);

    auto inv_2 = charlie.createNewInvoice(WK.Keys.C.address, Amount(1_000), time_t.max, "payment 2");
    alice.payInvoice(WK.Keys.A.address, inv_2.value);

    // need to wait for invoices to be complete before we have the new balance
    // to send in the other direction
    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 4);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 4);

    // note the reverse payment from charlie to alice. Can use this for refunds too.
    auto inv_3 = alice.createNewInvoice(WK.Keys.A.address, Amount(2_000), time_t.max, "payment 3");
    charlie.payInvoice(WK.Keys.C.address, inv_3.value);

    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 6);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 6);

    log.info("Alice collaboratively closing the channel..");
    auto error = alice.beginCollaborativeClose(WK.Keys.A.address, chan_id).error;
    assert(error == ErrorCode.None, error.to!string);
    // note: not checking for StartedUnilateralClose due to timing
    factory.listener.waitUntilChannelState(chan_id,
        ChannelState.RejectedCollaborativeClose);

    log.info("Alice unilaterally closing the channel..");
    error = alice.beginUnilateralClose(WK.Keys.A.address, chan_id).error;
    assert(error == ErrorCode.None, error.to!string);
    factory.listener.waitUntilChannelState(chan_id,
        ChannelState.StartedUnilateralClose);

    // trigger tx & latest update tx & latest settle tx
    iota(4).each!(idx => network.addBlock(true));
    factory.listener.waitUntilChannelState(chan_id, ChannelState.Closed);
}

/// Test indirect channel payments
//version (none)
unittest
{
    auto conf = flashTestConf();
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope (exit) network.shutdown();
    //scope (failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];
    scope (failure) node_1.printLog();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    foreach (idx, tx; txs)
    {
        node_1.postTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory!()(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0, genesis_validator_keys[0].address);
    auto alice = factory.create(WK.Keys.A, address);
    auto charlie = factory.create(WK.Keys.C, address);
    auto diego = factory.create(WK.Keys.D, address);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;
    //const Settle_10_Blocks = 10;

    /+ OPEN ALICE => CHARLIE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const alice_utxo = UTXO(0, txs[0].outputs[0]);
    const alice_utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const alice_charlie_chan_id_res = alice.openNewChannel(WK.Keys.A.address,
        alice_utxo, alice_utxo_hash, Amount(10_000), Settle_1_Blocks, WK.Keys.C.address);
    assert(alice_charlie_chan_id_res.error == ErrorCode.None,
        alice_charlie_chan_id_res.message);
    const alice_charlie_chan_id = alice_charlie_chan_id_res.value;
    log.info("Alice charlie channel ID: {}", alice_charlie_chan_id);
    factory.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.WaitingForFunding);

    // await alice & charlie channel funding transaction
    network.expectTxExternalization(alice_charlie_chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(WK.Keys.A.address, alice_charlie_chan_id);
    charlie.waitForChannelOpen(WK.Keys.C.address, alice_charlie_chan_id);
    factory.listener.waitUntilChannelState(alice_charlie_chan_id, ChannelState.Open);

    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN CHARLIE => DIEGO CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const charlie_utxo = UTXO(0, txs[1].outputs[0]);
    const charlie_utxo_hash = UTXO.getHash(hashFull(txs[1]), 0);
    const charlie_diego_chan_id_res = charlie.openNewChannel(WK.Keys.C.address,
        charlie_utxo, charlie_utxo_hash, Amount(3_000), Settle_1_Blocks, WK.Keys.D.address);
    assert(charlie_diego_chan_id_res.error == ErrorCode.None,
        charlie_diego_chan_id_res.message);
    const charlie_diego_chan_id = charlie_diego_chan_id_res.value;
    log.info("Charlie Diego channel ID: {}", charlie_diego_chan_id);
    factory.listener.waitUntilChannelState(charlie_diego_chan_id,
        ChannelState.WaitingForFunding);

    // await charlie & charlie channel funding transaction
    network.expectTxExternalization(charlie_diego_chan_id);

    // wait for the parties to detect the funding tx
    charlie.waitForChannelOpen(WK.Keys.C.address, charlie_diego_chan_id);
    diego.waitForChannelOpen(WK.Keys.D.address, charlie_diego_chan_id);
    factory.listener.waitUntilChannelState(charlie_diego_chan_id, ChannelState.Open);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    // also wait for all parties to discover other channels on the network
    alice.waitForChannelDiscovery(charlie_diego_chan_id);
    diego.waitForChannelDiscovery(alice_charlie_chan_id);

    // begin off-chain transactions
    auto inv_1 = diego.createNewInvoice(WK.Keys.D.address, Amount(2_000),
        time_t.max, "payment 1");

    // here we assume charlie sent the invoice to alice through some means,
    // e.g. QR code. Alice scans it and proposes the payment.
    // it has a direct channel to charlie so it uses it.
    alice.payInvoice(WK.Keys.A.address, inv_1.value);
    auto inv_res = factory.listener.waitUntilNotified(inv_1.value);
    assert(inv_res == ErrorCode.None, format("Couldn't pay invoice: %s", inv_res));

    // wait for payment + folding update indices
    alice.waitForUpdateIndex(WK.Keys.A.address, alice_charlie_chan_id, 2);
    charlie.waitForUpdateIndex(WK.Keys.C.address, alice_charlie_chan_id, 2);
    charlie.waitForUpdateIndex(WK.Keys.C.address, charlie_diego_chan_id, 2);
    diego.waitForUpdateIndex(WK.Keys.D.address, charlie_diego_chan_id, 2);

    //
    log.info("Beginning charlie => diego collaborative close..");
    assert(charlie.beginCollaborativeClose(WK.Keys.C.address, charlie_diego_chan_id).error
        == ErrorCode.None);
    factory.listener.waitUntilChannelState(charlie_diego_chan_id,
        ChannelState.StartedCollaborativeClose);
    auto close_tx = charlie.getClosingTx(WK.Keys.C.address,
        charlie_diego_chan_id);
    network.expectTxExternalization(close_tx);
    log.info("charlie closing tx: {}", close_tx);
    factory.listener.waitUntilChannelState(charlie_diego_chan_id,
        ChannelState.Closed);

    // can't close twice
    assert(charlie.beginCollaborativeClose(WK.Keys.C.address, charlie_diego_chan_id).error
        == ErrorCode.ChannelNotOpen);

    log.info("Beginning alice => charlie collaborative close..");
    assert(alice.beginCollaborativeClose(WK.Keys.A.address,
        alice_charlie_chan_id).error == ErrorCode.None);
    factory.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.StartedCollaborativeClose);
    close_tx = alice.getClosingTx(WK.Keys.A.address,
        alice_charlie_chan_id);
    network.expectTxExternalization(close_tx);
    log.info("alice closing tx: {}", close_tx);
    factory.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.Closed);
}

/// Test path probing
unittest
{
    auto conf = flashTestConf();
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope (exit) network.shutdown();
    //scope (failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];
    scope (failure) node_1.printLog();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    foreach (idx, tx; txs)
    {
        node_1.postTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory!()(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0, genesis_validator_keys[0].address);

    FlashConfig alice_conf = { enabled : true,
        min_funding : Amount(1000),
        max_funding : Amount(100_000_000),
        min_settle_time : 0,
        max_settle_time : 100,
        listener_address : factory.ListenerAddress,
        max_retry_time : 4.seconds,
        max_retry_delay : 100.msecs,
    };

    auto alice = factory.create(WK.Keys.A, alice_conf, address);
    auto charlie = factory.create(WK.Keys.C, address);
    auto diego = factory.create(WK.Keys.D, address);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;
    //const Settle_10_Blocks = 10;

    /+ OPEN ALICE => CHARLIE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const alice_utxo = UTXO(0, txs[0].outputs[0]);
    const alice_utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const alice_charlie_chan_id_res = alice.openNewChannel(WK.Keys.A.address,
        alice_utxo, alice_utxo_hash, Amount(10_000), Settle_1_Blocks, WK.Keys.C.address);
    assert(alice_charlie_chan_id_res.error == ErrorCode.None,
        alice_charlie_chan_id_res.message);
    const alice_charlie_chan_id = alice_charlie_chan_id_res.value;
    log.info("Alice charlie channel ID: {}", alice_charlie_chan_id);
    factory.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.WaitingForFunding);

    // await alice & charlie channel funding transaction
    network.expectTxExternalization(alice_charlie_chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(WK.Keys.A.address, alice_charlie_chan_id);
    charlie.waitForChannelOpen(WK.Keys.C.address, alice_charlie_chan_id);
    factory.listener.waitUntilChannelState(alice_charlie_chan_id, ChannelState.Open);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN CHARLIE => DIEGO CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const charlie_utxo = UTXO(0, txs[1].outputs[0]);
    const charlie_utxo_hash = UTXO.getHash(hashFull(txs[1]), 0);
    const charlie_diego_chan_id_res = charlie.openNewChannel(WK.Keys.C.address,
        charlie_utxo, charlie_utxo_hash, Amount(10_000), Settle_1_Blocks, WK.Keys.D.address);
    assert(charlie_diego_chan_id_res.error == ErrorCode.None,
        charlie_diego_chan_id_res.message);
    const charlie_diego_chan_id = charlie_diego_chan_id_res.value;
    log.info("Charlie Diego channel ID: {}", charlie_diego_chan_id);
    factory.listener.waitUntilChannelState(charlie_diego_chan_id,
        ChannelState.WaitingForFunding);

    // await charlie & charlie channel funding transaction
    network.expectTxExternalization(charlie_diego_chan_id);

    // wait for the parties to detect the funding tx
    charlie.waitForChannelOpen(WK.Keys.C.address, charlie_diego_chan_id);
    diego.waitForChannelOpen(WK.Keys.D.address, charlie_diego_chan_id);
    factory.listener.waitUntilChannelState(charlie_diego_chan_id, ChannelState.Open);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN DIEGO => ALICE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const diego_utxo = UTXO(0, txs[2].outputs[0]);
    const diego_utxo_hash = UTXO.getHash(hashFull(txs[2]), 0);
    const diego_alice_chan_id_res = diego.openNewChannel(WK.Keys.D.address,
        diego_utxo, diego_utxo_hash, Amount(10_000), Settle_1_Blocks, WK.Keys.A.address);
    assert(diego_alice_chan_id_res.error == ErrorCode.None,
        diego_alice_chan_id_res.message);
    const diego_alice_chan_id = diego_alice_chan_id_res.value;
    log.info("Diego Alice channel ID: {}", diego_alice_chan_id);
    factory.listener.waitUntilChannelState(diego_alice_chan_id,
        ChannelState.WaitingForFunding);

    // await charlie & charlie channel funding transaction
    network.expectTxExternalization(diego_alice_chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(WK.Keys.A.address, diego_alice_chan_id);
    diego.waitForChannelOpen(WK.Keys.D.address, diego_alice_chan_id);
    factory.listener.waitUntilChannelState(diego_alice_chan_id, ChannelState.Open);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    // also wait for all parties to discover other channels on the network
    alice.waitForChannelDiscovery(charlie_diego_chan_id);
    charlie.waitForChannelDiscovery(diego_alice_chan_id);
    diego.waitForChannelDiscovery(alice_charlie_chan_id);

    // begin off-chain transactions
    auto inv_1 = diego.createNewInvoice(WK.Keys.D.address, Amount(2_000),
        time_t.max, "payment 1");

    // here we assume charlie sent the invoice to alice through some means,

    // Alice has a direct channel to diego, but it does not have enough funds
    // to complete the payment in that direction. Alice will first naively try
    // that route and fail. In the second try, alice will route the payment through charlie.
    alice.payInvoice(WK.Keys.A.address, inv_1.value);
    auto res1 = factory.listener.waitUntilNotified(inv_1.value);
    assert(res1 != ErrorCode.None);  // should fail at first
    alice.payInvoice(WK.Keys.A.address, inv_1.value);
    auto res2 = factory.listener.waitUntilNotified(inv_1.value);
    assert(res2 == ErrorCode.None);  // should succeed the second time

    charlie.waitForUpdateIndex(WK.Keys.C.address, charlie_diego_chan_id, 2);
    diego.waitForUpdateIndex(WK.Keys.D.address, charlie_diego_chan_id, 2);

    alice.changeFees(WK.Keys.A.address, diego_alice_chan_id, Amount(1337),
        Amount(1));
    auto update = alice.waitForChannelUpdate(diego_alice_chan_id,
        PaymentDirection.TowardsOwner, 1);
    assert(update.fixed_fee == Amount(1337));
    assert(update.proportional_fee == Amount(1));
    update = charlie.waitForChannelUpdate(diego_alice_chan_id,
        PaymentDirection.TowardsOwner, 1);
    assert(update.fixed_fee == Amount(1337));
    assert(update.proportional_fee == Amount(1));
    update = diego.waitForChannelUpdate(diego_alice_chan_id,
        PaymentDirection.TowardsOwner, 1);
    assert(update.fixed_fee == Amount(1337));
    assert(update.proportional_fee == Amount(1));
}

/// Test path probing
unittest
{
    auto conf = flashTestConf();
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope (exit) network.shutdown();
    //scope (failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];
    scope (failure) node_1.printLog();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[3]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index / 2].address).sign())
        .array();

    foreach (idx, tx; txs)
    {
        node_1.postTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory!()(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0, genesis_validator_keys[0].address);
    auto alice = factory.create(WK.Keys.A, address);
    auto charlie = factory.create(WK.Keys.C, address);
    auto diego = factory.create(WK.Keys.D, address);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;
    //const Settle_10_Blocks = 10;

    /+ OPEN ALICE => CHARLIE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const alice_utxo = UTXO(0, txs[0].outputs[0]);
    const alice_utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const alice_charlie_chan_id_res = alice.openNewChannel(WK.Keys.A.address,
        alice_utxo, alice_utxo_hash, Amount(10_000), Settle_1_Blocks, WK.Keys.C.address);
    assert(alice_charlie_chan_id_res.error == ErrorCode.None,
        alice_charlie_chan_id_res.message);
    const alice_charlie_chan_id = alice_charlie_chan_id_res.value;
    log.info("Alice charlie channel ID: {}", alice_charlie_chan_id);
    factory.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.WaitingForFunding);

    // await alice & charlie channel funding transaction
    network.expectTxExternalization(alice_charlie_chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(WK.Keys.A.address, alice_charlie_chan_id);
    charlie.waitForChannelOpen(WK.Keys.C.address, alice_charlie_chan_id);
    factory.listener.waitUntilChannelState(alice_charlie_chan_id, ChannelState.Open);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN CHARLIE => DIEGO CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const charlie_utxo = UTXO(0, txs[2].outputs[0]);
    const charlie_utxo_hash = UTXO.getHash(hashFull(txs[2]), 0);
    const charlie_diego_chan_id_res = charlie.openNewChannel(WK.Keys.C.address,
        charlie_utxo, charlie_utxo_hash, Amount(10_000), Settle_1_Blocks, WK.Keys.D.address);
    assert(charlie_diego_chan_id_res.error == ErrorCode.None,
        charlie_diego_chan_id_res.message);
    const charlie_diego_chan_id = charlie_diego_chan_id_res.value;
    log.info("Charlie Diego channel ID: {}", charlie_diego_chan_id);
    factory.listener.waitUntilChannelState(charlie_diego_chan_id,
        ChannelState.WaitingForFunding);

    // await charlie & charlie channel funding transaction
    network.expectTxExternalization(charlie_diego_chan_id);

    // wait for the parties to detect the funding tx
    charlie.waitForChannelOpen(WK.Keys.C.address, charlie_diego_chan_id);
    diego.waitForChannelOpen(WK.Keys.D.address, charlie_diego_chan_id);
    factory.listener.waitUntilChannelState(charlie_diego_chan_id, ChannelState.Open);
    alice.waitForChannelDiscovery(charlie_diego_chan_id);  // also alice (so it can detect fees)

    charlie.changeFees(WK.Keys.C.address, charlie_diego_chan_id, Amount(100), Amount(1));
    alice.waitForChannelUpdate(charlie_diego_chan_id, PaymentDirection.TowardsPeer, 1);
    diego.waitForChannelUpdate(charlie_diego_chan_id, PaymentDirection.TowardsPeer, 1);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN SECOND CHARLIE => DIEGO CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const charlie_utxo_2 = UTXO(0, txs[3].outputs[0]);
    const charlie_utxo_hash_2 = UTXO.getHash(hashFull(txs[3]), 0);
    const charlie_diego_chan_id_2_res = charlie.openNewChannel(WK.Keys.C.address,
        charlie_utxo_2, charlie_utxo_hash_2, Amount(10_000), Settle_1_Blocks, WK.Keys.D.address);
    assert(charlie_diego_chan_id_2_res.error == ErrorCode.None,
        charlie_diego_chan_id_2_res.message);
    const charlie_diego_chan_id_2 = charlie_diego_chan_id_2_res.value;
    log.info("Charlie Diego channel ID: {}", charlie_diego_chan_id_2);
    factory.listener.waitUntilChannelState(charlie_diego_chan_id_2,
        ChannelState.SettingUp, WK.Keys.C.address);

    auto chans = charlie.getManagedChannels(null);
    assert(chans.length == 3, chans.to!string);

    chans = charlie.getManagedChannels([WK.Keys.C.address]);
    assert(chans.length == 3, chans.to!string);

    chans = charlie.getManagedChannels([WK.Keys.A.address]);
    assert(chans.length == 0, chans.to!string);

    auto infos = charlie.getChannelInfo([charlie_diego_chan_id_2]);
    assert(infos.length == 1);
    auto info = infos[0];
    assert(info.chan_id == charlie_diego_chan_id_2);
    assert(info.owner_key == WK.Keys.C.address);
    assert(info.peer_key == WK.Keys.D.address);
    assert(info.state == ChannelState.Negotiating
        || info.state == ChannelState.SettingUp
        || info.state == ChannelState.WaitingForFunding, info.state.to!string);
    assert(info.owner_balance == Amount(0), info.owner_balance.to!string);
    assert(info.peer_balance == Amount(0), info.peer_balance.to!string);

    // await charlie & charlie channel funding transaction
    network.expectTxExternalization(charlie_diego_chan_id_2);

    // wait for the parties to detect the funding tx
    charlie.waitForChannelOpen(WK.Keys.C.address, charlie_diego_chan_id_2);
    diego.waitForChannelOpen(WK.Keys.D.address, charlie_diego_chan_id_2);
    factory.listener.waitUntilChannelState(charlie_diego_chan_id_2, ChannelState.Open);

    // check if info is different now
    infos = charlie.getChannelInfo([charlie_diego_chan_id_2]);
    assert(infos.length == 1);
    info = infos[0];
    assert(info.state == ChannelState.Open);
    assert(info.owner_balance == Amount(10_000), info.owner_balance.to!string);
    assert(info.peer_balance == Amount(0), info.peer_balance.to!string);

    charlie.changeFees(WK.Keys.C.address, charlie_diego_chan_id_2, Amount(10), Amount(1));
    alice.waitForChannelUpdate(charlie_diego_chan_id_2, PaymentDirection.TowardsPeer, 1);
    diego.waitForChannelUpdate(charlie_diego_chan_id_2, PaymentDirection.TowardsPeer, 1);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    // also wait for all parties to discover other channels on the network
    alice.waitForChannelDiscovery(charlie_diego_chan_id);
    alice.waitForChannelDiscovery(charlie_diego_chan_id_2);
    diego.waitForChannelDiscovery(alice_charlie_chan_id);

    // begin off-chain transactions
    auto inv_1 = diego.createNewInvoice(WK.Keys.D.address, Amount(2_000),
        time_t.max, "payment 1");

    // Alice is expected to route the payment through the channel
    // with lower fee between Charlie and Diego
    alice.payInvoice(WK.Keys.A.address, inv_1.value);

    // wait for payment + folding update indices
    alice.waitForUpdateIndex(WK.Keys.A.address, alice_charlie_chan_id, 2);
    charlie.waitForUpdateIndex(WK.Keys.C.address, alice_charlie_chan_id, 2);
    charlie.waitForUpdateIndex(WK.Keys.C.address, charlie_diego_chan_id_2, 2);
    diego.waitForUpdateIndex(WK.Keys.D.address, charlie_diego_chan_id_2, 2);

    assert(charlie.beginCollaborativeClose(WK.Keys.C.address, charlie_diego_chan_id_2).error
        == ErrorCode.None);
    factory.listener.waitUntilChannelState(charlie_diego_chan_id_2,
        ChannelState.StartedCollaborativeClose);
    auto close_tx = charlie.getClosingTx(WK.Keys.C.address, charlie_diego_chan_id_2);
    assert(close_tx.outputs.length == 2);
    assert(close_tx.outputs.count!(o => o.value == Amount(8000)) == 1); // No fees
    assert(close_tx.outputs.count!(o => o.value == Amount(2000 - close_tx.sizeInBytes)) == 1);
    network.expectTxExternalization(close_tx);
    factory.listener.waitUntilChannelState(charlie_diego_chan_id_2,
        ChannelState.Closed);

    assert(alice.beginCollaborativeClose(WK.Keys.A.address, alice_charlie_chan_id).error
        == ErrorCode.None);
    factory.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.StartedCollaborativeClose);
    close_tx = alice.getClosingTx(WK.Keys.A.address, alice_charlie_chan_id);
    assert(close_tx.outputs.length == 2);
    assert(close_tx.outputs.count!(o => o.value == Amount(7990)) == 1); // Fees
    assert(close_tx.outputs.count!(o => o.value == Amount(2010 - close_tx.sizeInBytes)) == 1);
    network.expectTxExternalization(close_tx);
    factory.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.Closed);

    assert(charlie.beginCollaborativeClose(WK.Keys.C.address, charlie_diego_chan_id).error
        == ErrorCode.None);
    factory.listener.waitUntilChannelState(charlie_diego_chan_id,
        ChannelState.StartedCollaborativeClose);
    close_tx = charlie.getClosingTx(WK.Keys.C.address, charlie_diego_chan_id);
    assert(close_tx.outputs.length == 1); // No updates
    network.expectTxExternalization(close_tx);
    factory.listener.waitUntilChannelState(charlie_diego_chan_id,
        ChannelState.Closed);
    auto block14 = node_1.getBlocksFrom(14, 1)[0];
}

unittest
{
    static class BleedingEdgeFlashNode : TestFlashNode
    {
        mixin ForwardCtor!();

        ///
        protected override void paymentRouter (in PublicKey pk, in Hash chan_id,
            in Hash payment_hash, in Amount amount,
            in Height lock_height, in OnionPacket packet)
        {
            OnionPacket hijacked = packet;
            hijacked.version_byte += 1;
            super.paymentRouter(pk, chan_id, payment_hash, amount,
                lock_height, hijacked);
        }
    }

    auto conf = flashTestConf();
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope (exit) network.shutdown();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    foreach (idx, tx; txs)
    {
        node_1.postTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory!()(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0, genesis_validator_keys[0].address);
    auto alice = factory.create!BleedingEdgeFlashNode(WK.Keys.A, address);
    auto charlie = factory.create(WK.Keys.C, address);

    /+ OPEN ALICE => CHARLIE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const alice_utxo = UTXO(0, txs[0].outputs[0]);
    const alice_utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const alice_charlie_chan_id_res = alice.openNewChannel(WK.Keys.A.address,
        alice_utxo, alice_utxo_hash, Amount(10_000), 0, WK.Keys.C.address);
    assert(alice_charlie_chan_id_res.error == ErrorCode.None,
        alice_charlie_chan_id_res.message);
    const alice_charlie_chan_id = alice_charlie_chan_id_res.value;
    log.info("Alice charlie channel ID: {}", alice_charlie_chan_id);
    factory.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.WaitingForFunding);

    // await alice & charlie channel funding transaction
    network.expectTxExternalization(alice_charlie_chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(WK.Keys.A.address, alice_charlie_chan_id);
    charlie.waitForChannelOpen(WK.Keys.C.address, alice_charlie_chan_id);
    factory.listener.waitUntilChannelState(alice_charlie_chan_id, ChannelState.Open);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    // begin off-chain transactions
    auto inv_1 = charlie.createNewInvoice(WK.Keys.C.address, Amount(2_000), time_t.max, "payment 1");

    // Charlie will receive packets with a different version than it implements
    alice.payInvoice(WK.Keys.A.address, inv_1.value);
    Thread.sleep(1.seconds);

    assert(charlie.beginCollaborativeClose(WK.Keys.C.address, alice_charlie_chan_id).error
        == ErrorCode.None);
    factory.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.StartedCollaborativeClose);
    auto close_tx = charlie.getClosingTx(WK.Keys.C.address, alice_charlie_chan_id);
    assert(close_tx.outputs.length == 1); // No updates
    network.expectTxExternalization(close_tx);
    factory.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.Closed);
}

/// Test node serialization & loading
//version (none)
unittest
{
    auto conf = flashTestConf();
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope (exit) network.shutdown();
    //scope (failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];
    scope (failure) node_1.printLog();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    foreach (idx, tx; txs)
    {
        node_1.postTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory!()(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0, genesis_validator_keys[0].address);
    auto alice = factory.create(WK.Keys.A, address, DatabaseStorage.Static);
    auto charlie = factory.create(WK.Keys.C, address, DatabaseStorage.Static);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(WK.Keys.A.address,
        utxo, utxo_hash, Amount(10_000), Settle_1_Blocks, WK.Keys.C.address);
    assert(chan_id_res.error == ErrorCode.None,
        chan_id_res.message);
    const chan_id = chan_id_res.value;
    factory.listener.waitUntilChannelState(chan_id, ChannelState.WaitingForFunding);

    // await funding transaction
    network.expectTxExternalization(chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(WK.Keys.A.address, chan_id);
    charlie.waitForChannelOpen(WK.Keys.C.address, chan_id);
    factory.listener.waitUntilChannelState(chan_id, ChannelState.Open);

    auto update_tx = alice.getPublishUpdateIndex(WK.Keys.A.address, chan_id, 0);

    /* do some off-chain transactions */
    auto inv_1 = charlie.createNewInvoice(WK.Keys.C.address, Amount(5_000), time_t.max, "payment 1");
    alice.payInvoice(WK.Keys.A.address, inv_1.value);

    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 2);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 2);

    auto inv_2 = charlie.createNewInvoice(WK.Keys.C.address, Amount(1_000), time_t.max, "payment 2");
    alice.payInvoice(WK.Keys.A.address, inv_2.value);

    // need to wait for invoices to be complete before we have the new balance
    // to send in the other direction
    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 4);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 4);

    // restart the two nodes
    factory.restart();

    // note the reverse payment from charlie to alice. Can use this for refunds too.
    auto inv_3 = alice.createNewInvoice(WK.Keys.A.address, Amount(2_000), time_t.max, "payment 3");
    charlie.payInvoice(WK.Keys.C.address, inv_3.value);

    // next update index should be 6
    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 6);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 6);
}

/// test various error cases
unittest
{
    auto conf = flashTestConf();
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope (exit) network.shutdown();
    //scope (failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];
    scope (failure) node_1.printLog();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    foreach (idx, tx; txs)
    {
        node_1.postTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory!()(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0, genesis_validator_keys[0].address);

    FlashConfig charlie_conf = { enabled : true,
        min_funding : Amount(1000),
        max_funding : Amount(100_000_000),
        min_settle_time : 10,
        max_settle_time : 100,
        max_retry_delay : 100.msecs,
    };
    auto alice = factory.create(WK.Keys.A, address);
    auto charlie = factory.create(WK.Keys.C, charlie_conf, address);

    const Settle_10_Blocks = 10;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);

    // error on mismatching genesis hash
    ChannelConfig bad_conf = { funder_pk : WK.Keys.A.address };
    auto open_res = charlie.openChannel(WK.Keys.C.address, bad_conf, PublicNonce.init);
    assert(open_res.error == ErrorCode.InvalidGenesisHash, open_res.to!string);

    // error on non-managed key
    open_res = charlie.openChannel(WK.Keys.A.address, bad_conf, PublicNonce.init);
    assert(open_res.error == ErrorCode.KeyNotRecognized, open_res.to!string);

    // error on capacity too low
    auto res = alice.openNewChannel(WK.Keys.A.address,
        utxo, utxo_hash, Amount(1), Settle_10_Blocks, WK.Keys.C.address);
    assert(res.error == ErrorCode.None);

    auto error = factory.listener.waitUntilChannelState(res.value,
        ChannelState.Rejected);
    assert(error == ErrorCode.RejectedFundingAmount, res.to!string);

    // channel does not exist as it was rejected
    assert(alice.beginCollaborativeClose(WK.Keys.A.address, res.value).error
        == ErrorCode.InvalidChannelID);

    // error on capacity too high
    res = alice.openNewChannel(WK.Keys.A.address,
        utxo, utxo_hash, Amount(1_000_000_000), Settle_10_Blocks, WK.Keys.C.address);
    assert(res.error == ErrorCode.None);

    error = factory.listener.waitUntilChannelState(res.value,
        ChannelState.Rejected);
    assert(error == ErrorCode.RejectedFundingAmount, res.to!string);

    // error on settle time too low
    res = alice.openNewChannel(WK.Keys.A.address,
        utxo, utxo_hash, Amount(10_000), 5, WK.Keys.C.address);
    assert(res.error == ErrorCode.None);

    error = factory.listener.waitUntilChannelState(res.value,
        ChannelState.Rejected);
    assert(error == ErrorCode.RejectedSettleTime, res.to!string);

    // error on not enough funds on funding UTXO
    res = alice.openNewChannel(WK.Keys.A.address,
        utxo, utxo_hash, Amount.MaxUnitSupply, Settle_10_Blocks, WK.Keys.C.address);
    assert(res.error == ErrorCode.RejectedFundingUTXO);

    // error on not enough funds on funding UTXO for TX fees
    res = alice.openNewChannel(WK.Keys.A.address,
        utxo, utxo_hash, utxo.output.value, Settle_10_Blocks, WK.Keys.C.address);
    assert(res.error == ErrorCode.RejectedFundingUTXO);

    // error on not own funding UTXO
    res = charlie.openNewChannel(WK.Keys.C.address,
        utxo, utxo_hash, Amount(10_000), 1000, WK.Keys.A.address);
    assert(res.error == ErrorCode.RejectedFundingUTXO);

    res = alice.openNewChannel(WK.Keys.A.address,
        utxo, utxo_hash, Amount(10_000), 1000, WK.Keys.C.address);
    assert(res.error == ErrorCode.None);

    error = factory.listener.waitUntilChannelState(res.value,
        ChannelState.Rejected, WK.Keys.A.address);
    assert(error == ErrorCode.RejectedSettleTime, res.to!string);

    const chan_id_res = alice.openNewChannel(WK.Keys.A.address,
        utxo, utxo_hash, Amount(10_000), Settle_10_Blocks, WK.Keys.C.address);
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    factory.listener.waitUntilChannelState(res.value, ChannelState.WaitingForFunding);
    const chan_id = chan_id_res.value;

    // await funding transaction
    network.expectTxExternalization(chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(WK.Keys.A.address, chan_id);
    charlie.waitForChannelOpen(WK.Keys.C.address, chan_id);
    factory.listener.waitUntilChannelState(chan_id, ChannelState.Open);

    // test what happens trying to open a new channel with the same funding tx
    res = alice.openNewChannel(WK.Keys.A.address, utxo, utxo_hash, Amount(10_000),
        Settle_10_Blocks, WK.Keys.C.address);
    assert(res.error == ErrorCode.DuplicateChannelID, res.to!string);

    // test some update signer error cases
    auto sig_res = alice.requestSettleSig(WK.Keys.C.address, WK.Keys.A.address, Hash.init, 0);
    assert(sig_res.error == ErrorCode.InvalidChannelID, sig_res.to!string);

    auto up_sig_res = alice.requestUpdateSig(WK.Keys.C.address, WK.Keys.A.address, Hash.init, 0);
    assert(up_sig_res.error == ErrorCode.InvalidChannelID, up_sig_res.to!string);

    /*** test invalid payment proposals ***/

    // mismatching version byte
    OnionPacket onion = { version_byte : ubyte.max };
    auto pay_res = alice.proposePayment(WK.Keys.C.address, WK.Keys.A.address, Hash.init, 0, Hash.init, Amount.init,
        Height.init, onion, PublicNonce.init, Height.init);
    assert(pay_res.error == ErrorCode.VersionMismatch, pay_res.to!string);

    // invalid channel ID
    onion.version_byte = 0;
    pay_res = alice.proposePayment(WK.Keys.C.address, WK.Keys.A.address, Hash.init, 0, Hash.init, Amount.init,
        Height.init, onion, PublicNonce.init, Height.init);
    assert(pay_res.error == ErrorCode.InvalidChannelID, pay_res.to!string);

    // ephemeral pk is invalid
    pay_res = alice.proposePayment(WK.Keys.C.address, WK.Keys.A.address, chan_id, 0, Hash.init, Amount.init,
        Height.init, onion, PublicNonce.init, Height.init);
    assert(pay_res.error == ErrorCode.InvalidOnionPacket, pay_res.to!string);

    // onion packet cannot be decrypted
    onion.ephemeral_pk = Scalar.random().toPoint();
    pay_res = alice.proposePayment(WK.Keys.C.address, WK.Keys.A.address, chan_id, 0, Hash.init, Amount.init,
        Height.init, onion, PublicNonce.init, Height.init);
    assert(pay_res.error == ErrorCode.InvalidOnionPacket, pay_res.to!string);

    // invalid next channel ID
    Hop[] path = [
        Hop(Point(WK.Keys.A.address[]), chan_id, Amount(10)),
        Hop(Scalar.random().toPoint(), hashFull(2), Amount(10))];
    Amount total_amount;
    Height use_lock_height;
    Point[] shared_secrets;
    onion = createOnionPacket(hashFull(42), Amount(100), path,
        total_amount, use_lock_height, shared_secrets);
    pay_res = alice.proposePayment(WK.Keys.C.address, WK.Keys.A.address, chan_id, 0, hashFull(42), total_amount,
        use_lock_height, onion, PublicNonce.init, Height.init);
    assert(pay_res.error == ErrorCode.InvalidChannelID, pay_res.to!string);

    /*** test invalid update proposals ***/

    // invalid channel ID
    auto upd_res = alice.proposeUpdate(WK.Keys.C.address, WK.Keys.A.address, Hash.init, 0, null, null,
        PublicNonce.init, Height.init);
    assert(upd_res.error == ErrorCode.InvalidChannelID, upd_res.to!string);

    // invalid height
    upd_res = alice.proposeUpdate(WK.Keys.C.address, WK.Keys.A.address, chan_id, 0, null, null,
        PublicNonce.init, Height(100));
    assert(upd_res.error == ErrorCode.MismatchingBlockHeight, upd_res.to!string);
}

/// test listener API and payment success / failures
unittest
{
    static class RejectingFlashNode : TestFlashNode
    {
        mixin ForwardCtor!();

        ///
        public override Result!PublicNonce proposePayment (PublicKey sender_pk,
            PublicKey recv_pk, /* in */ Hash chan_id,
            /* in */ uint seq_id, /* in */ Hash payment_hash,
            /* in */ Amount amount, /* in */ Height lock_height,
            /* in */ OnionPacket packet, /* in */ PublicNonce peer_nonce,
            /* in */ Height height) @trusted
        {
            if (seq_id >= 2)
                return Result!PublicNonce(ErrorCode.Unknown, "I'm a bad node");
            else
                return super.proposePayment(sender_pk, recv_pk, chan_id, seq_id,
                    payment_hash, amount, lock_height, packet, peer_nonce,
                    height);
        }
    }

    auto conf = flashTestConf();
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope (exit) network.shutdown();
    //scope (failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    foreach (idx, tx; txs)
    {
        node_1.postTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory!()(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0, genesis_validator_keys[0].address);

    FlashConfig alice_conf = { enabled : true,
        min_funding : Amount(1000),
        max_funding : Amount(100_000_000),
        min_settle_time : 0,
        max_settle_time : 100,
        listener_address : factory.ListenerAddress,
        max_retry_time : 4.seconds,
        max_retry_delay : 10.msecs,
    };

    auto alice = factory.create(WK.Keys.A, alice_conf, address);
    auto charlie = factory.create!RejectingFlashNode(WK.Keys.C, address);
    auto diego = factory.create(WK.Keys.D, address);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(WK.Keys.A.address,
        utxo, utxo_hash, Amount(10_000), Settle_1_Blocks, WK.Keys.C.address);
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    const chan_id = chan_id_res.value;
    factory.listener.waitUntilChannelState(chan_id, ChannelState.WaitingForFunding);

    // await funding transaction
    network.expectTxExternalization(chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(WK.Keys.A.address, chan_id);
    charlie.waitForChannelOpen(WK.Keys.C.address, chan_id);
    factory.listener.waitUntilChannelState(chan_id, ChannelState.Open);

    auto update_tx = alice.getPublishUpdateIndex(WK.Keys.A.address, chan_id, 0);

    /* do some off-chain transactions */
    auto inv_1 = charlie.createNewInvoice(WK.Keys.C.address, Amount(5_000), time_t.max,
        "payment 1");
    alice.payInvoice(WK.Keys.A.address, inv_1.value);

    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 2);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 2);

    auto res = factory.listener.waitUntilNotified(inv_1.value);
    assert(res == ErrorCode.None);  // should succeed

    auto inv_2 = charlie.createNewInvoice(WK.Keys.C.address, Amount(1_000), time_t.max,
        "payment 2");
    alice.payInvoice(WK.Keys.A.address, inv_2.value);

    res = factory.listener.waitUntilNotified(inv_2.value);
    assert(res != ErrorCode.None);  // should have failed

    auto inv_3 = diego.createNewInvoice(WK.Keys.D.address, Amount(1_000),
        time_t.max, "diego");
    alice.payInvoice(WK.Keys.A.address, inv_3.value);

    res = factory.listener.waitUntilNotified(inv_3.value);
    assert(res == ErrorCode.PathNotFound);
}

/// test listener API rejecting channels
unittest
{
    /// Rejects opening new channels
    static class RejectingFlashListener : FlashListener
    {
        mixin ForwardCtor!();

        public override string onRequestedChannelOpen (PublicKey pk,
            ChannelConfig conf)
        {
            return "I don't like this channel";
        }
    }

    auto conf = flashTestConf();
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope (exit) network.shutdown();
    //scope (failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    foreach (idx, tx; txs)
    {
        node_1.postTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory!RejectingFlashListener(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0, genesis_validator_keys[0].address);

    FlashConfig alice_conf = { enabled : true,
        min_funding : Amount(1000),
        max_funding : Amount(100_000_000),
        min_settle_time : 0,
        max_settle_time : 100,
        listener_address : factory.ListenerAddress,
        max_retry_time : 4.seconds,
        max_retry_delay : 10.msecs,
    };

    auto alice = factory.create(WK.Keys.A, alice_conf, address);
    auto charlie = factory.create(WK.Keys.C, address);
    auto diego = factory.create(WK.Keys.D, address);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(WK.Keys.A.address,
        utxo, utxo_hash, Amount(10_000), Settle_1_Blocks, WK.Keys.C.address);
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    const chan_id = chan_id_res.value;

    auto error = factory.listener.waitUntilChannelState(chan_id,
        ChannelState.Rejected);
    assert(error == ErrorCode.UserRejectedChannel);
}

/// Test unilateral non-collaborative close (funding + update* + settle)
//version (none)
unittest
{
    auto conf = flashTestConf();
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope (exit) network.shutdown();
    //scope (failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];
    scope (failure) node_1.printLog();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    foreach (idx, tx; txs)
    {
        node_1.postTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory!()(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0, genesis_validator_keys[0].address);
    auto alice = factory.create(WK.Keys.A, address);
    auto charlie = factory.create(WK.Keys.C, address);

    // 3 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 3;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(WK.Keys.A.address,
        utxo, utxo_hash, Amount(10_000), Settle_1_Blocks, WK.Keys.C.address);
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    const chan_id = chan_id_res.value;
    factory.listener.waitUntilChannelState(chan_id, ChannelState.WaitingForFunding);

    // await funding transaction
    network.expectTxExternalization(chan_id);

    // wait for the parties & listener to detect the funding tx
    alice.waitForChannelOpen(WK.Keys.A.address, chan_id);
    charlie.waitForChannelOpen(WK.Keys.C.address, chan_id);
    factory.listener.waitUntilChannelState(chan_id, ChannelState.Open);

    /* do some off-chain transactions */
    auto inv_1 = charlie.createNewInvoice(WK.Keys.C.address, Amount(5_000), time_t.max, "payment 1");
    alice.payInvoice(WK.Keys.A.address, inv_1.value);

    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 2);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 2);

    auto inv_2 = charlie.createNewInvoice(WK.Keys.C.address, Amount(1_000), time_t.max, "payment 2");
    alice.payInvoice(WK.Keys.A.address, inv_2.value);

    // need to wait for invoices to be complete before we have the new balance
    // to send in the other direction
    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 4);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 4);

    // note the reverse payment from charlie to alice. Can use this for refunds too.
    auto inv_3 = alice.createNewInvoice(WK.Keys.A.address, Amount(2_000), time_t.max, "payment 3");
    charlie.payInvoice(WK.Keys.C.address, inv_3.value);

    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 6);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 6);

    // disallow nodes to publish TXs so that we can publish older updates
    alice.setPublishEnable(false);
    charlie.setPublishEnable(false);

    auto update_tx = alice.getPublishUpdateIndex(WK.Keys.A.address, chan_id, 0);
    node_1.postTransaction(update_tx);
    network.expectTxExternalization(update_tx);
    factory.listener.waitUntilChannelState(chan_id,
        ChannelState.StartedUnilateralClose);


    // publish an older update
    update_tx = alice.getPublishUpdateIndex(WK.Keys.A.address, chan_id, 2);
    node_1.postTransaction(update_tx);
    network.expectTxExternalization(update_tx);

    // an even older update can not be externalized anymore
    update_tx = alice.getPublishUpdateIndex(WK.Keys.A.address, chan_id, 1);
    node_1.postTransaction(update_tx);
    assertThrown!Exception(network.expectTxExternalization(update_tx));

    // allow normal node operation again
    alice.setPublishEnable(true);
    charlie.setPublishEnable(true);

    update_tx = alice.getPublishUpdateIndex(WK.Keys.A.address, chan_id, 4);
    network.expectTxExternalization(update_tx);

    iota(Settle_1_Blocks * 2).each!(idx => network.addBlock(true));
    factory.listener.waitUntilChannelState(chan_id,
        ChannelState.Closed);
}
