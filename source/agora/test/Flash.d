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
import agora.api.Registry;
import agora.common.ManagedDatabase;
import agora.common.Task;
import agora.consensus.data.genesis.Test;
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
import agora.script.Signature;
import agora.serialization.Serializer;
import agora.test.Base;
import agora.utils.Log;

import geod24.LocalRest : Listener;
import geod24.Registry;

import std.exception;

import core.stdc.time;
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

    /// Print out the contents of the log
    public void printLog ();
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
    public void waitForChannelOpen (in Hash chan_id);

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
    public void printLog ();

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
public class TestFlashNode : FlashNode, TestFlashAPI
{
    ///
    protected AnyRegistry* registry;

    ///
    protected FullNodeAPI agora_node;

    ///
    protected bool allow_publish;

    ///
    public this (FlashConfig conf, AnyRegistry* registry,
        string agora_address, DatabaseStorage storage, Duration timeout)
    {
        this.registry = registry;
        const genesis_hash = hashFull(GenesisBlock);
        auto engine = new Engine();
        this.allow_publish = true;

        this.agora_node = this.getAgoraClient(agora_address, timeout);
        super(conf, storage, genesis_hash, engine, new LocalRestTaskManager(),
            &this.postTransaction, &agora_node.getBlock, &this.getNameRegistryClient);
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
    protected FullNodeAPI getAgoraClient (string address,
        Duration timeout)
    {
        auto tid = this.registry.locate!TestAPI(address);
        assert(tid != typeof(tid).init, "Agora node not initialized");
        return new RemoteAPI!TestAPI(tid, timeout);
    }

    ///
    protected override FlashAPI createFlashClient (in Address address, in Duration timeout) @trusted
    {
        // give some time to the other node to wake up and register
        Listener!TestFlashAPI tid;
        foreach (i; 0 .. 5)
        {
            tid = this.registry.locate!TestFlashAPI(address.host);
            if (tid != typeof(tid).init)
                break;

            this.taskman.wait(500.msecs);
        }

        assert(tid != typeof(tid).init, "Flash node not initialized");

        return new RemoteAPI!TestFlashAPI(tid, timeout);
    }

    ///
    protected override TestFlashListenerAPI getFlashListenerClient (
        Address address, Duration timeout) @trusted
    {
        auto tid = this.registry.locate!TestFlashListenerAPI(address.host);
        assert(tid != typeof(tid).init);
        return new RemoteAPI!TestFlashListenerAPI(tid, timeout);
    }

    ///
    public NameRegistryAPI getNameRegistryClient (string address, Duration timeout)
    {
        assert(address != string.init, "Empty address");
        const url = Address(address);
        auto tid = this.registry.locate!NameRegistryAPI(url.host);
        assert(tid != typeof(tid).init, "Trying to access name registry at address '" ~ address ~
               "' without first creating it");
        return new RemoteAPI!NameRegistryAPI(tid, timeout);
    }

    ///
    public override Transaction getPublishUpdateIndex (in PublicKey pk,
        in Hash chan_id, in uint index)
    {
        auto channel = chan_id in this.channels;
        assert(channel !is null);
        return channel.getPublishUpdateIndex(index);
    }

    ///
    public override void waitForUpdateIndex (in PublicKey pk, in Hash chan_id,
        in uint index)
    {
        auto channel = chan_id in this.channels;
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
    public override void waitForChannelOpen (in Hash chan_id)
    {
        super.waitChannelOpen(chan_id);
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
        auto channel = chan_id in this.channels;
        assert(channel !is null);
        return channel.getClosingTx();
    }

    ///
    public override Transaction getLastSettleTx (in PublicKey pk, in Hash chan_id)
    {
        auto channel = chan_id in this.channels;
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
    private TransactionResult postTransaction (in Transaction tx)
    {
        if (this.allow_publish)
        {
            return this.agora_node.postTransaction(tx);
        }
        else
        {
            log.info("Skipping publishing {}", tx);
            return TransactionResult(TransactionResult.Status.Accepted);
        }
    }
}

/// Is in charge of spawning the flash nodes
public class FlashNodeFactory : TestAPIManager
{
    /// list of flash addresses
    private PublicKey[] addresses;

    /// list of listener addresses
    private string[] listener_addresses;

    /// list of flash nodes
    private RemoteAPI!TestFlashAPI[] flash_nodes;

    /// list of FlashListenerAPI nodes
    private RemoteAPI!TestFlashListenerAPI[] listener_nodes;

    /// Flash listener address
    private static const ListenerAddress = "http://flash-listener";

    /// Flash listener (Wallet)
    public TestFlashListenerAPI listener;

    /// Ctor
    public this (immutable(Block)[] blocks, TestConf test_conf,
        TimePoint test_start_time)
    {
        super(blocks, test_conf, test_start_time);
    }

    ///
    public void start (Listener : TestFlashListenerAPI = FlashListener) ()
    {
        this.listener = this.createFlashListener!Listener(ListenerAddress);
        super.start();
        this.flash_nodes.each!(fn => fn.start());
    }

    /// Returns: A default config for `kp` suitable for `createFlashNode`
    public FlashConfig makeFlashNodeConfig (in KeyPair kp) const scope @safe
    {
        FlashConfig conf = {
            enabled : true,
            min_funding : Amount(1000),
            max_funding : Amount(100_000_000),
            min_settle_time : 0,
            max_settle_time : 100,
            max_retry_time : 4.seconds,
            max_retry_delay : 100.msecs,
            listener_address : ListenerAddress,
            registry_address : "dns://10.8.8.8",
            addresses_to_register : [ Address("http://"~to!string(kp.address)) ],
            key_pair : kp,
        };
        return conf;
    }

    /// Create a new flash node user
    public RemoteAPI!TestFlashAPI createFlashNode (FlashNodeImpl = TestFlashNode)
        (in KeyPair kp, DatabaseStorage storage = DatabaseStorage.Local,
        string file = __FILE__, int line = __LINE__)
    {
        auto conf = this.makeFlashNodeConfig(kp);
        return this.createFlashNode!FlashNodeImpl(conf, storage, file, line);
    }

    /// ditto
    public RemoteAPI!TestFlashAPI createFlashNode (FlashNodeImpl = TestFlashNode)
        (FlashConfig conf, DatabaseStorage storage = DatabaseStorage.Local,
        string file = __FILE__, int line = __LINE__)
    {
        import agora.api.Handlers;

        RemoteAPI!TestFlashAPI api = RemoteAPI!TestFlashAPI.spawn!FlashNodeImpl(
            conf, &this.registry, this.nodes[0].address, storage,
            10.seconds, 10.seconds, file, line);  // timeout from main thread

        this.addresses ~= conf.key_pair.address;
        this.flash_nodes ~= api;
        this.registry.register(conf.key_pair.address.to!string, api.listener());
        api.registerKey(conf.key_pair);

        return api;
    }

    /// Create a new FlashListenerAPI node
    public RemoteAPI!TestFlashListenerAPI createFlashListener (
        Listener : TestFlashListenerAPI)(string address)
    {
        auto api = RemoteAPI!TestFlashListenerAPI.spawn!Listener(
            &this.registry, this.nodes[0].address, 5.seconds);
        this.registry.register(Address(address).host, api.listener());
        this.listener_addresses ~= address;
        this.listener_nodes ~= api;
        return api;
    }

    /***************************************************************************

        Print out the logs for each node

    ***************************************************************************/

    public override void printLogs (string file = __FILE__, int line = __LINE__)
    {
        super.printLogs();
        synchronized  // make sure logging output is not interleaved
        {
            writeln("---------------------------- START OF FLASH LOGS ----------------------------");
            writefln("%s(%s): Flash node logs:\n", file, line);
            foreach (idx, node; this.flash_nodes)
            {
                try
                {
                    node.printLog();
                }
                catch (Exception ex)
                {
                    writefln("Could not print logs for node %s: %s", this.addresses[idx], ex.message);
                }
            }
        }

        this.listener.printLog();

        auto output = stdout.lockingTextWriter();
        output.put("Flash log for tests\n");
        output.put("======================================================================\n");
        CircularAppender!()().print(output);
        output.put("======================================================================\n\n");
        stdout.flush();
    }

    /// Shut down all the nodes
    public override void shutdown (bool printLogs = false)
    {
        super.shutdown();

        foreach (node; this.flash_nodes)
            node.shutdownNode();

        foreach (node; this.flash_nodes)
            node.ctrl.shutdown();

        foreach (node; this.listener_nodes)
        {
            node.ctrl.shutdown();
        }
    }

    /// Shut down & restart all nodes
    public void restart ()
    {
        foreach (node; this.flash_nodes)
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

    public this (AnyRegistry* registry, string agora_address)
    {
        this.taskman = new LocalRestTaskManager();

        auto tid = registry.locate!TestAPI(agora_address);
        assert(tid != typeof(tid).init, "Agora node not initialized");
        this.agora_node = new RemoteAPI!TestAPI(tid, 5.seconds);
    }

    public void onPaymentSuccess (PublicKey, Invoice invoice)
    {
        log.info("Payment succeded {}", invoice);
        this.invoices[invoice] = ErrorCode.None;
    }

    public void onPaymentFailure (PublicKey, Invoice invoice, ErrorCode error)
    {
        log.info("Payment failed {} reason {}", invoice, error);
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
        ErrorCode error, Height = Height(0))
    {
        log.info("Channel event {}, id {}", state, chan_id.flashPrettify);
        if (chan_id !in this.channel_state)
            this.channel_state[chan_id] = typeof(this.channel_state[chan_id]).init;
        this.channel_state[chan_id][pk] = State(state, error);
    }

    public Result!ChannelUpdate onRequestedChannelOpen (PublicKey pk, ChannelConfig conf)
    {
        auto is_owner = pk == conf.funder_pk;
        auto update = ChannelUpdate(conf.chan_id,
            is_owner ? PaymentDirection.TowardsPeer : PaymentDirection.TowardsOwner,
            Amount(1), Amount(1), 1);
        update.sig = WK.Keys[pk].sign(update);
        return Result!ChannelUpdate(update);  // accept by default
    }

    public FeeUTXOs getFeeUTXOs (PublicKey pk, Amount amount)
    {
        auto last_height = agora_node.getBlockHeight();
        auto per_byte = this.getEstimatedTxFee();

        FeeUTXOs utxos;
        do
        {
            const last_block = agora_node.getBlock(last_height);
            foreach (tx; last_block.txs)
            foreach (idx, output; tx.outputs)
                if (output.address() == pk)
                {
                    auto utxo = UTXO.getHash(tx.hashFull(), idx);
                    utxos.utxos ~= utxo;
                    utxos.total_value += output.value;
                    auto fee = per_byte;
                    fee.mul(Input(utxo, genKeyUnlock(SigPair.init)).sizeInBytes());
                    amount.add(fee);
                }

            last_height--;
        } while (last_height > 0 && utxos.total_value < amount);
        utxos.total_fee = amount;

        return utxos;
    }

    public Amount getEstimatedTxFee ()
    {
        return flashTestConf().consensus.min_fee;
    }

    public void printLog ()
    {
        auto output = stdout.lockingTextWriter();
        output.formattedWrite("Log for Flash Listener\n");
        output.put("======================================================================\n");
        CircularAppender!()().print(output);
        output.put("======================================================================\n\n");
        stdout.flush();
    }
}

private TestConf flashTestConf () @safe
{
    import agora.node.Config;

    TestConf conf;
    conf.consensus.quorum_threshold = 100;
    conf.event_handlers = [
        EventHandlerConfig(HandlerType.BlockExternalized, ["http://"~WK.Keys.A.address.to!string()]),
        EventHandlerConfig(HandlerType.BlockExternalized, ["http://"~WK.Keys.C.address.to!string()]),
        EventHandlerConfig(HandlerType.BlockExternalized, ["http://"~WK.Keys.D.address.to!string()]),
        EventHandlerConfig(HandlerType.BlockExternalized, ["http://"~WK.Keys.E.address.to!string()])
    ];
    return conf;
}

/// Test unilateral non-collaborative close (funding + update* + settle)
//version (none)
unittest
{
    auto conf = flashTestConf();
    auto network = makeTestNetwork!FlashNodeFactory(conf);
    scope (exit) network.shutdown();
    scope (failure) network.printLogs();

    auto alice = network.createFlashNode(WK.Keys.A);
    auto charlie = network.createFlashNode(WK.Keys.C);

    network.start();
    network.waitForDiscovery();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    txs.each!(tx => network.postAndEnsureTxInPool(tx));
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 3;
    //const Settle_10_Blocks = 10;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(utxo, utxo_hash, Amount(10_000),
        Settle_1_Blocks, WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address))); // TODO common registry localrest
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    const chan_id = chan_id_res.value;
    network.listener.waitUntilChannelState(chan_id, ChannelState.WaitingForFunding);

    // await funding transaction
    network.expectTxExternalization(chan_id);

    // wait for the parties & listener to detect the funding tx
    alice.waitForChannelOpen(chan_id);
    charlie.waitForChannelOpen(chan_id);
    network.listener.waitUntilChannelState(chan_id, ChannelState.Open);

    auto update_tx = alice.getPublishUpdateIndex(WK.Keys.A.address, chan_id, 0);

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
    network.listener.waitUntilChannelState(chan_id,
        ChannelState.StartedUnilateralClose);

    // at this point charlie will automatically publish the latest update tx
    // and then a settlement will be published (but only after time lock expires)
    iota(Settle_1_Blocks * 2).each!(idx => network.addBlock(true));
    network.listener.waitUntilChannelState(chan_id, ChannelState.Closed);
}

/// Test the settlement timeout branch for the
/// unilateral non-collaborative close (funding + update* + settle)
//version (none)
unittest
{
    auto conf = flashTestConf();
    auto network = makeTestNetwork!FlashNodeFactory(conf);
    scope (exit) network.shutdown();
    scope (failure) network.printLogs();

    auto alice = network.createFlashNode(WK.Keys.A);
    auto charlie = network.createFlashNode(WK.Keys.C);

    network.start();
    network.waitForDiscovery();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    txs.each!(tx => network.postAndEnsureTxInPool(tx));
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    // 4 blocks settle time after trigger tx is published
    const Settle_4_Blocks = 4;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(utxo, utxo_hash, Amount(10_000),
        Settle_4_Blocks, WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    const chan_id = chan_id_res.value;
    network.listener.waitUntilChannelState(chan_id, ChannelState.WaitingForFunding);

    // await funding transaction
    network.expectTxExternalization(chan_id);

    // wait for the parties & listener to detect the funding tx
    alice.waitForChannelOpen(chan_id);
    charlie.waitForChannelOpen(chan_id);
    network.listener.waitUntilChannelState(chan_id, ChannelState.Open);

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
    network.listener.waitUntilChannelState(chan_id,
        ChannelState.StartedUnilateralClose);

    // at this point charlie will automatically publish the latest update tx
    // at `Settle_4_Blocks` blocks need to be externalized before a settlement
    // can be attached to the update transaction
    // and then a settlement will be automatically published
    iota(Settle_4_Blocks * 2 + 5).each!(idx => network.addBlock(true));
    network.listener.waitUntilChannelState(chan_id, ChannelState.Closed);
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
    auto network = makeTestNetwork!FlashNodeFactory(conf);
    scope (exit) network.shutdown();
    scope (failure) network.printLogs();

    auto alice = network.createFlashNode(WK.Keys.A);
    auto charlie = network.createFlashNode!RejectingCloseNode(WK.Keys.C);

    network.start();
    network.waitForDiscovery();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    txs.each!(tx => network.postAndEnsureTxInPool(tx));
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;
    //const Settle_10_Blocks = 10;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(utxo, utxo_hash, Amount(10_000),
        Settle_1_Blocks, WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    const chan_id = chan_id_res.value;
    network.listener.waitUntilChannelState(chan_id, ChannelState.WaitingForFunding);

    // await funding transaction
    network.expectTxExternalization(chan_id);

    // wait for the parties & listener to detect the funding tx
    alice.waitForChannelOpen(chan_id);
    charlie.waitForChannelOpen(chan_id);
    network.listener.waitUntilChannelState(chan_id, ChannelState.Open);

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
    network.listener.waitUntilChannelState(chan_id,
        ChannelState.RejectedCollaborativeClose);

    log.info("Alice unilaterally closing the channel..");
    error = alice.beginUnilateralClose(WK.Keys.A.address, chan_id).error;
    assert(error == ErrorCode.None, error.to!string);
    network.listener.waitUntilChannelState(chan_id,
        ChannelState.StartedUnilateralClose);

    // trigger tx & latest update tx & latest settle tx
    iota(4).each!(idx => network.addBlock(true));
    network.listener.waitUntilChannelState(chan_id, ChannelState.Closed);
}

/// Test indirect channel payments
//version (none)
unittest
{
    auto conf = flashTestConf();
    auto network = makeTestNetwork!FlashNodeFactory(conf);
    scope (exit) network.shutdown();
    scope (failure) network.printLogs();

    auto alice = network.createFlashNode(WK.Keys.A);
    auto charlie = network.createFlashNode(WK.Keys.C);
    auto diego = network.createFlashNode(WK.Keys.D);

    network.start();
    network.waitForDiscovery();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    txs.each!(tx => network.postAndEnsureTxInPool(tx));
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;
    //const Settle_10_Blocks = 10;

    /+ OPEN ALICE => CHARLIE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const alice_utxo = UTXO(0, txs[0].outputs[0]);
    const alice_utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const alice_charlie_chan_id_res = alice.openNewChannel(alice_utxo, alice_utxo_hash,
        1.coins, Settle_1_Blocks, WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(alice_charlie_chan_id_res.error == ErrorCode.None,
        alice_charlie_chan_id_res.message);
    const alice_charlie_chan_id = alice_charlie_chan_id_res.value;
    log.info("Alice charlie channel ID: {}", alice_charlie_chan_id);
    network.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.WaitingForFunding);

    // await alice & charlie channel funding transaction
    network.expectTxExternalization(alice_charlie_chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(alice_charlie_chan_id);
    charlie.waitForChannelOpen(alice_charlie_chan_id);
    network.listener.waitUntilChannelState(alice_charlie_chan_id, ChannelState.Open);

    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN CHARLIE => DIEGO CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const charlie_utxo = UTXO(0, txs[1].outputs[0]);
    const charlie_utxo_hash = UTXO.getHash(hashFull(txs[1]), 0);
    const charlie_diego_chan_id_res = charlie.openNewChannel(charlie_utxo, charlie_utxo_hash,
        Amount(300_000), Settle_1_Blocks, WK.Keys.D.address, false, Address("http://"~to!string(WK.Keys.D.address)));
    assert(charlie_diego_chan_id_res.error == ErrorCode.None,
        charlie_diego_chan_id_res.message);
    const charlie_diego_chan_id = charlie_diego_chan_id_res.value;
    log.info("Charlie Diego channel ID: {}", charlie_diego_chan_id);
    network.listener.waitUntilChannelState(charlie_diego_chan_id,
        ChannelState.WaitingForFunding);

    // await charlie & charlie channel funding transaction
    network.expectTxExternalization(charlie_diego_chan_id);

    // wait for the parties to detect the funding tx
    charlie.waitForChannelOpen(charlie_diego_chan_id);
    diego.waitForChannelOpen(charlie_diego_chan_id);
    network.listener.waitUntilChannelState(charlie_diego_chan_id, ChannelState.Open);
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
    auto inv_res = network.listener.waitUntilNotified(inv_1.value);
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
    network.listener.waitUntilChannelState(charlie_diego_chan_id,
        ChannelState.StartedCollaborativeClose);
    auto close_tx = charlie.getClosingTx(WK.Keys.C.address,
        charlie_diego_chan_id);
    network.expectTxExternalization(close_tx);
    log.info("charlie closing tx: {}", close_tx);
    network.listener.waitUntilChannelState(charlie_diego_chan_id,
        ChannelState.Closed);

    // can't close twice
    assert(charlie.beginCollaborativeClose(WK.Keys.C.address, charlie_diego_chan_id).error
        == ErrorCode.ChannelNotOpen);

    log.info("Beginning alice => charlie collaborative close..");
    assert(alice.beginCollaborativeClose(WK.Keys.A.address,
        alice_charlie_chan_id).error == ErrorCode.None);
    network.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.StartedCollaborativeClose);
    close_tx = alice.getClosingTx(WK.Keys.A.address,
        alice_charlie_chan_id);
    network.expectTxExternalization(close_tx);
    log.info("alice closing tx: {}", close_tx);
    network.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.Closed);
}

/// Test path probing
unittest
{
    auto conf = flashTestConf();
    auto network = makeTestNetwork!FlashNodeFactory(conf);
    scope (exit) network.shutdown();
    scope (failure) network.printLogs();

    auto alice = network.createFlashNode(WK.Keys.A);
    auto charlie = network.createFlashNode(WK.Keys.C);
    auto diego = network.createFlashNode(WK.Keys.D);

    network.start();
    network.waitForDiscovery();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    txs.each!(tx => network.postAndEnsureTxInPool(tx));
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;
    //const Settle_10_Blocks = 10;

    /+ OPEN ALICE => CHARLIE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const alice_utxo = UTXO(0, txs[0].outputs[0]);
    const alice_utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const alice_charlie_chan_id_res = alice.openNewChannel(alice_utxo, alice_utxo_hash,
        Amount(10_000), Settle_1_Blocks, WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(alice_charlie_chan_id_res.error == ErrorCode.None,
        alice_charlie_chan_id_res.message);
    const alice_charlie_chan_id = alice_charlie_chan_id_res.value;
    log.info("Alice charlie channel ID: {}", alice_charlie_chan_id);
    network.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.WaitingForFunding);

    // await alice & charlie channel funding transaction
    network.expectTxExternalization(alice_charlie_chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(alice_charlie_chan_id);
    charlie.waitForChannelOpen(alice_charlie_chan_id);
    network.listener.waitUntilChannelState(alice_charlie_chan_id, ChannelState.Open);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN CHARLIE => DIEGO CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const charlie_utxo = UTXO(0, txs[1].outputs[0]);
    const charlie_utxo_hash = UTXO.getHash(hashFull(txs[1]), 0);
    const charlie_diego_chan_id_res = charlie.openNewChannel(charlie_utxo, charlie_utxo_hash,
        Amount(10_000), Settle_1_Blocks, WK.Keys.D.address, false, Address("http://"~to!string(WK.Keys.D.address)));
    assert(charlie_diego_chan_id_res.error == ErrorCode.None,
        charlie_diego_chan_id_res.message);
    const charlie_diego_chan_id = charlie_diego_chan_id_res.value;
    log.info("Charlie Diego channel ID: {}", charlie_diego_chan_id);
    network.listener.waitUntilChannelState(charlie_diego_chan_id,
        ChannelState.WaitingForFunding);

    // await charlie & charlie channel funding transaction
    network.expectTxExternalization(charlie_diego_chan_id);

    // wait for the parties to detect the funding tx
    charlie.waitForChannelOpen(charlie_diego_chan_id);
    diego.waitForChannelOpen(charlie_diego_chan_id);
    network.listener.waitUntilChannelState(charlie_diego_chan_id, ChannelState.Open);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN DIEGO => ALICE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const diego_utxo = UTXO(0, txs[2].outputs[0]);
    const diego_utxo_hash = UTXO.getHash(hashFull(txs[2]), 0);
    const diego_alice_chan_id_res = diego.openNewChannel(diego_utxo, diego_utxo_hash,
        Amount(10_000), Settle_1_Blocks, WK.Keys.A.address, false, Address("http://"~to!string(WK.Keys.A.address)));
    assert(diego_alice_chan_id_res.error == ErrorCode.None,
        diego_alice_chan_id_res.message);
    const diego_alice_chan_id = diego_alice_chan_id_res.value;
    log.info("Diego Alice channel ID: {}", diego_alice_chan_id);
    network.listener.waitUntilChannelState(diego_alice_chan_id,
        ChannelState.WaitingForFunding);

    // await charlie & charlie channel funding transaction
    network.expectTxExternalization(diego_alice_chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(diego_alice_chan_id);
    diego.waitForChannelOpen(diego_alice_chan_id);
    network.listener.waitUntilChannelState(diego_alice_chan_id, ChannelState.Open);
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
    auto res1 = network.listener.waitUntilNotified(inv_1.value);
    assert(res1 != ErrorCode.None);  // should fail at first
    alice.payInvoice(WK.Keys.A.address, inv_1.value);
    auto res2 = network.listener.waitUntilNotified(inv_1.value);
    assert(res2 == ErrorCode.None);  // should succeed the second time

    charlie.waitForUpdateIndex(WK.Keys.C.address, charlie_diego_chan_id, 2);
    diego.waitForUpdateIndex(WK.Keys.D.address, charlie_diego_chan_id, 2);

    auto update = ChannelUpdate(diego_alice_chan_id,
        PaymentDirection.TowardsOwner,
        Amount(1337), Amount(1), 1, 1);
    update.sig = WK.Keys.A.sign(update);
    alice.gossipChannelUpdates([update]);
    update = alice.waitForChannelUpdate(diego_alice_chan_id,
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
    auto network = makeTestNetwork!FlashNodeFactory(conf);
    scope (exit) network.shutdown();
    scope (failure) network.printLogs();

    auto alice = network.createFlashNode(WK.Keys.A);
    auto charlie = network.createFlashNode(WK.Keys.C);
    auto diego = network.createFlashNode(WK.Keys.D);

    network.start();
    network.waitForDiscovery();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[3]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index / 2].address).sign())
        .array();

    txs.each!(tx => network.postAndEnsureTxInPool(tx));
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;
    //const Settle_10_Blocks = 10;

    /+ OPEN ALICE => CHARLIE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const alice_utxo = UTXO(0, txs[0].outputs[0]);
    const alice_utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const alice_charlie_chan_id_res = alice.openNewChannel(alice_utxo, alice_utxo_hash,
        1.coins, Settle_1_Blocks, WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(alice_charlie_chan_id_res.error == ErrorCode.None,
        alice_charlie_chan_id_res.message);
    const alice_charlie_chan_id = alice_charlie_chan_id_res.value;
    log.info("Alice charlie channel ID: {}", alice_charlie_chan_id);
    network.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.WaitingForFunding);

    // await alice & charlie channel funding transaction
    network.expectTxExternalization(alice_charlie_chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(alice_charlie_chan_id);
    charlie.waitForChannelOpen(alice_charlie_chan_id);
    network.listener.waitUntilChannelState(alice_charlie_chan_id, ChannelState.Open);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN CHARLIE => DIEGO CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const charlie_utxo = UTXO(0, txs[2].outputs[0]);
    const charlie_utxo_hash = UTXO.getHash(hashFull(txs[2]), 0);
    const charlie_diego_chan_id_res = charlie.openNewChannel(charlie_utxo, charlie_utxo_hash,
        1.coins, Settle_1_Blocks, WK.Keys.D.address, false, Address("http://"~to!string(WK.Keys.D.address)));
    assert(charlie_diego_chan_id_res.error == ErrorCode.None,
        charlie_diego_chan_id_res.message);
    const charlie_diego_chan_id = charlie_diego_chan_id_res.value;
    log.info("Charlie Diego channel ID: {}", charlie_diego_chan_id);
    network.listener.waitUntilChannelState(charlie_diego_chan_id,
        ChannelState.WaitingForFunding);

    // await charlie & charlie channel funding transaction
    network.expectTxExternalization(charlie_diego_chan_id);

    // wait for the parties to detect the funding tx
    charlie.waitForChannelOpen(charlie_diego_chan_id);
    diego.waitForChannelOpen(charlie_diego_chan_id);
    network.listener.waitUntilChannelState(charlie_diego_chan_id, ChannelState.Open);
    alice.waitForChannelDiscovery(charlie_diego_chan_id);  // also alice (so it can detect fees)

    auto update = ChannelUpdate(charlie_diego_chan_id,
        PaymentDirection.TowardsPeer,
        Amount(100), Amount(1), 1, 1);
    update.sig = WK.Keys.C.sign(update);
    charlie.gossipChannelUpdates([update]);
    alice.waitForChannelUpdate(charlie_diego_chan_id, PaymentDirection.TowardsPeer, 1);
    diego.waitForChannelUpdate(charlie_diego_chan_id, PaymentDirection.TowardsPeer, 1);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN SECOND CHARLIE => DIEGO CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const charlie_utxo_2 = UTXO(0, txs[3].outputs[0]);
    const charlie_utxo_hash_2 = UTXO.getHash(hashFull(txs[3]), 0);
    const charlie_diego_chan_id_2_res = charlie.openNewChannel(charlie_utxo_2, charlie_utxo_hash_2,
        1.coins, Settle_1_Blocks, WK.Keys.D.address, false, Address("http://"~to!string(WK.Keys.D.address)));
    assert(charlie_diego_chan_id_2_res.error == ErrorCode.None,
        charlie_diego_chan_id_2_res.message);
    const charlie_diego_chan_id_2 = charlie_diego_chan_id_2_res.value;
    log.info("Charlie Diego channel ID: {}", charlie_diego_chan_id_2);
    network.listener.waitUntilChannelState(charlie_diego_chan_id_2,
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
    charlie.waitForChannelOpen(charlie_diego_chan_id_2);
    diego.waitForChannelOpen(charlie_diego_chan_id_2);
    network.listener.waitUntilChannelState(charlie_diego_chan_id_2, ChannelState.Open);

    // check if info is different now
    infos = charlie.getChannelInfo([charlie_diego_chan_id_2]);
    assert(infos.length == 1);
    info = infos[0];
    assert(info.state == ChannelState.Open);
    assert(info.owner_balance == 1.coins, info.owner_balance.to!string);
    assert(info.peer_balance == Amount(0), info.peer_balance.to!string);

    update = ChannelUpdate(charlie_diego_chan_id_2,
        PaymentDirection.TowardsPeer,
        Amount(10), Amount(1), 1, 1);
    update.sig = WK.Keys.C.sign(update);
    charlie.gossipChannelUpdates([update]);
    alice.waitForChannelUpdate(charlie_diego_chan_id_2, PaymentDirection.TowardsPeer, 1);
    diego.waitForChannelUpdate(charlie_diego_chan_id_2, PaymentDirection.TowardsPeer, 1);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    // also wait for all parties to discover other channels on the network
    alice.waitForChannelDiscovery(charlie_diego_chan_id);
    alice.waitForChannelDiscovery(charlie_diego_chan_id_2);
    diego.waitForChannelDiscovery(alice_charlie_chan_id);

    // begin off-chain transactions
    auto inv_1 = diego.createNewInvoice(WK.Keys.D.address, Amount(200_000),
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
    network.listener.waitUntilChannelState(charlie_diego_chan_id_2,
        ChannelState.StartedCollaborativeClose);
    auto close_tx = charlie.getClosingTx(WK.Keys.C.address, charlie_diego_chan_id_2);
    auto close_tx_fees = conf.consensus.min_fee * close_tx.sizeInBytes;
    assert(close_tx.outputs.length == 2);
    assert(close_tx.outputs.count!(o => o.value == Amount(9800000)) == 1, to!string(close_tx.outputs)); // No fees
    assert(close_tx.outputs.count!(o => o.value == Amount(200000) - close_tx_fees) == 1, to!string(close_tx.outputs));
    network.expectTxExternalization(close_tx);
    network.listener.waitUntilChannelState(charlie_diego_chan_id_2,
        ChannelState.Closed);

    assert(alice.beginCollaborativeClose(WK.Keys.A.address, alice_charlie_chan_id).error
        == ErrorCode.None);
    network.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.StartedCollaborativeClose);
    close_tx = alice.getClosingTx(WK.Keys.A.address, alice_charlie_chan_id);
    close_tx_fees = conf.consensus.min_fee * close_tx.sizeInBytes;
    assert(close_tx.outputs.length == 2);
    assert(close_tx.outputs.count!(o => o.value == Amount(9799990)) == 1, to!string(close_tx.outputs)); // Fees
    assert(close_tx.outputs.count!(o => o.value == Amount(200010) - close_tx_fees) == 1, to!string(close_tx.outputs));
    network.expectTxExternalization(close_tx);
    network.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.Closed);

    assert(charlie.beginCollaborativeClose(WK.Keys.C.address, charlie_diego_chan_id).error
        == ErrorCode.None);
    network.listener.waitUntilChannelState(charlie_diego_chan_id,
        ChannelState.StartedCollaborativeClose);
    close_tx = charlie.getClosingTx(WK.Keys.C.address, charlie_diego_chan_id);
    assert(close_tx.outputs.length == 1); // No updates
    network.expectTxExternalization(close_tx);
    network.listener.waitUntilChannelState(charlie_diego_chan_id,
        ChannelState.Closed);
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
    auto network = makeTestNetwork!FlashNodeFactory(conf);
    scope (exit) network.shutdown();
    scope (failure) network.printLogs();

    auto alice = network.createFlashNode!BleedingEdgeFlashNode(WK.Keys.A);
    auto charlie = network.createFlashNode(WK.Keys.C);

    network.start();
    network.waitForDiscovery();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    txs.each!(tx => network.postAndEnsureTxInPool(tx));
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    /+ OPEN ALICE => CHARLIE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const alice_utxo = UTXO(0, txs[0].outputs[0]);
    const alice_utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const alice_charlie_chan_id_res = alice.openNewChannel(alice_utxo, alice_utxo_hash,
        1.coins, 0, WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(alice_charlie_chan_id_res.error == ErrorCode.None,
        alice_charlie_chan_id_res.message);
    const alice_charlie_chan_id = alice_charlie_chan_id_res.value;
    log.info("Alice charlie channel ID: {}", alice_charlie_chan_id);
    network.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.WaitingForFunding);

    // await alice & charlie channel funding transaction
    network.expectTxExternalization(alice_charlie_chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(alice_charlie_chan_id);
    charlie.waitForChannelOpen(alice_charlie_chan_id);
    network.listener.waitUntilChannelState(alice_charlie_chan_id, ChannelState.Open);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    // begin off-chain transactions
    auto inv_1 = charlie.createNewInvoice(WK.Keys.C.address, Amount(2_000), time_t.max, "payment 1");

    // Charlie will receive packets with a different version than it implements
    alice.payInvoice(WK.Keys.A.address, inv_1.value);
    Thread.sleep(1.seconds);

    assert(charlie.beginCollaborativeClose(WK.Keys.C.address, alice_charlie_chan_id).error
        == ErrorCode.None);
    network.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.StartedCollaborativeClose);
    auto close_tx = charlie.getClosingTx(WK.Keys.C.address, alice_charlie_chan_id);
    assert(close_tx.outputs.length == 1); // No updates
    network.expectTxExternalization(close_tx);
    network.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.Closed);
}

/// Test node serialization & loading
//version (none)
unittest
{
    auto conf = flashTestConf();
    auto network = makeTestNetwork!FlashNodeFactory(conf);
    scope (exit) network.shutdown();
    scope (failure) network.printLogs();

    auto alice = network.createFlashNode(WK.Keys.A, DatabaseStorage.Static);
    auto charlie = network.createFlashNode(WK.Keys.C, DatabaseStorage.Static);

    network.start();
    network.waitForDiscovery();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    txs.each!(tx => network.postAndEnsureTxInPool(tx));
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(utxo, utxo_hash, Amount(10_000),
        Settle_1_Blocks, WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(chan_id_res.error == ErrorCode.None,
        chan_id_res.message);
    const chan_id = chan_id_res.value;
    network.listener.waitUntilChannelState(chan_id, ChannelState.WaitingForFunding);

    // await funding transaction
    network.expectTxExternalization(chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(chan_id);
    charlie.waitForChannelOpen(chan_id);
    network.listener.waitUntilChannelState(chan_id, ChannelState.Open);

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
    network.restart();

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
    auto network = makeTestNetwork!FlashNodeFactory(conf);
    scope (exit) network.shutdown();
    scope (failure) network.printLogs();

    auto charlie_conf = network.makeFlashNodeConfig(WK.Keys.C);
    charlie_conf.min_settle_time = 10;

    auto alice = network.createFlashNode(WK.Keys.A);
    auto charlie = network.createFlashNode(charlie_conf);

    network.start();
    network.waitForDiscovery();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    txs.each!(tx => network.postAndEnsureTxInPool(tx));
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);


    const Settle_10_Blocks = 10;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);

    // error on mismatching genesis hash
    ChannelConfig bad_conf = { funder_pk : WK.Keys.A.address, peer_pk : WK.Keys.C.address};
    auto open_res = charlie.openChannel(bad_conf, PublicNonce.init, Address("http://"~bad_conf.funder_pk.to!string()));
    assert(open_res.error == ErrorCode.InvalidGenesisHash, open_res.to!string);

    bad_conf.peer_pk = PublicKey.init;
    // error on non-managed key
    open_res = charlie.openChannel(bad_conf, PublicNonce.init, Address("http://"~bad_conf.funder_pk.to!string()));
    assert(open_res.error == ErrorCode.KeyNotRecognized, open_res.to!string);

    // error on capacity too low
    auto res = alice.openNewChannel(utxo, utxo_hash, Amount(1), Settle_10_Blocks,
        WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(res.error == ErrorCode.None);

    auto error = network.listener.waitUntilChannelState(res.value,
        ChannelState.Rejected);
    assert(error == ErrorCode.RejectedFundingAmount, res.to!string);

    // channel does not exist as it was rejected
    assert(alice.beginCollaborativeClose(WK.Keys.A.address, res.value).error
        == ErrorCode.InvalidChannelID);

    // error on capacity too high
    res = alice.openNewChannel(utxo, utxo_hash, Amount(1_000_000_000),
        Settle_10_Blocks, WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(res.error == ErrorCode.None);

    error = network.listener.waitUntilChannelState(res.value,
        ChannelState.Rejected);
    assert(error == ErrorCode.RejectedFundingAmount, res.to!string);

    // error on settle time too low
    res = alice.openNewChannel(utxo, utxo_hash, Amount(10_000), 5, WK.Keys.C.address,
        false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(res.error == ErrorCode.None);

    error = network.listener.waitUntilChannelState(res.value,
        ChannelState.Rejected);
    assert(error == ErrorCode.RejectedSettleTime, res.to!string);

    // error on not enough funds on funding UTXO
    res = alice.openNewChannel(utxo, utxo_hash, Amount.MaxUnitSupply, Settle_10_Blocks, WK.Keys.C.address,
        false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(res.error == ErrorCode.RejectedFundingUTXO);

    // error on not enough funds on funding UTXO for TX fees
    res = alice.openNewChannel(utxo, utxo_hash, utxo.output.value, Settle_10_Blocks, WK.Keys.C.address,
        false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(res.error == ErrorCode.RejectedFundingUTXO);

    // error on not own funding UTXO
    res = charlie.openNewChannel(utxo, utxo_hash, Amount(10_000), 1000, WK.Keys.A.address,
        false, Address("http://"~to!string(WK.Keys.A.address)));
    assert(res.error == ErrorCode.KeyNotRecognized);

    res = alice.openNewChannel(utxo, utxo_hash, Amount(10_000), 1000, WK.Keys.C.address,
        false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(res.error == ErrorCode.None);

    error = network.listener.waitUntilChannelState(res.value,
        ChannelState.Rejected, WK.Keys.A.address);
    assert(error == ErrorCode.RejectedSettleTime, res.to!string);

    const chan_id_res = alice.openNewChannel(utxo, utxo_hash, Amount(10_000), Settle_10_Blocks,
        WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    network.listener.waitUntilChannelState(res.value, ChannelState.WaitingForFunding);
    const chan_id = chan_id_res.value;

    // await funding transaction
    network.expectTxExternalization(chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(chan_id);
    charlie.waitForChannelOpen(chan_id);
    network.listener.waitUntilChannelState(chan_id, ChannelState.Open);

    // test what happens trying to open a new channel with the same funding tx
    res = alice.openNewChannel(utxo, utxo_hash, Amount(10_000),
        Settle_10_Blocks, WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address)));
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
    onion = createOnionPacket(Amount(100), path,
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
    auto network = makeTestNetwork!FlashNodeFactory(conf);
    scope (exit) network.shutdown();
    scope (failure) network.printLogs();

    auto alice = network.createFlashNode(WK.Keys.A);
    auto charlie = network.createFlashNode!RejectingFlashNode(WK.Keys.C);
    auto diego = network.createFlashNode(WK.Keys.D);

    network.start();
    network.waitForDiscovery();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    txs.each!(tx => network.postAndEnsureTxInPool(tx));
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(utxo, utxo_hash, Amount(10_000), Settle_1_Blocks,
        WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    const chan_id = chan_id_res.value;
    network.listener.waitUntilChannelState(chan_id, ChannelState.WaitingForFunding);

    // await funding transaction
    network.expectTxExternalization(chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(chan_id);
    charlie.waitForChannelOpen(chan_id);
    network.listener.waitUntilChannelState(chan_id, ChannelState.Open);

    auto update_tx = alice.getPublishUpdateIndex(WK.Keys.A.address, chan_id, 0);

    /* do some off-chain transactions */
    auto inv_1 = charlie.createNewInvoice(WK.Keys.C.address, Amount(5_000), time_t.max,
        "payment 1");
    alice.payInvoice(WK.Keys.A.address, inv_1.value);

    alice.waitForUpdateIndex(WK.Keys.A.address, chan_id, 2);
    charlie.waitForUpdateIndex(WK.Keys.C.address, chan_id, 2);

    auto res = network.listener.waitUntilNotified(inv_1.value);
    assert(res == ErrorCode.None);  // should succeed

    auto inv_2 = charlie.createNewInvoice(WK.Keys.C.address, Amount(1_000), time_t.max,
        "payment 2");
    alice.payInvoice(WK.Keys.A.address, inv_2.value);

    res = network.listener.waitUntilNotified(inv_2.value);
    assert(res != ErrorCode.None);  // should have failed

    auto inv_3 = diego.createNewInvoice(WK.Keys.D.address, Amount(1_000),
        time_t.max, "diego");
    alice.payInvoice(WK.Keys.A.address, inv_3.value);

    res = network.listener.waitUntilNotified(inv_3.value);
    assert(res == ErrorCode.PathNotFound);
}

/// test listener API rejecting channels
unittest
{
    /// Rejects opening new channels
    static class RejectingFlashListener : FlashListener
    {
        mixin ForwardCtor!();

        public override Result!ChannelUpdate onRequestedChannelOpen (PublicKey pk,
            ChannelConfig conf)
        {
            if (conf.funder_pk == pk)
                return super.onRequestedChannelOpen(pk, conf);
            return Result!ChannelUpdate(ErrorCode.InvalidGenesisHash, "I don't like this channel");
        }
    }

    auto conf = flashTestConf();
    auto network = makeTestNetwork!FlashNodeFactory(conf);
    scope (exit) network.shutdown();
    scope (failure) network.printLogs();

    auto alice = network.createFlashNode(WK.Keys.A);
    auto charlie = network.createFlashNode(WK.Keys.C);
    auto diego = network.createFlashNode(WK.Keys.D);

    network.start!RejectingFlashListener();
    network.waitForDiscovery();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    txs.each!(tx => network.postAndEnsureTxInPool(tx));
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(utxo, utxo_hash, Amount(10_000),
        Settle_1_Blocks, WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    const chan_id = chan_id_res.value;

    auto error = network.listener.waitUntilChannelState(chan_id,
        ChannelState.Rejected);
    assert(error == ErrorCode.UserRejectedChannel);
}

/// Test unilateral non-collaborative close (funding + update* + settle)
//version (none)
unittest
{
    auto conf = flashTestConf();
    auto network = makeTestNetwork!FlashNodeFactory(conf);
    scope (exit) network.shutdown();
    scope (failure) network.printLogs();

    auto alice = network.createFlashNode(WK.Keys.A);
    auto charlie = network.createFlashNode(WK.Keys.C);

    network.start();
    network.waitForDiscovery();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    txs.each!(tx => network.postAndEnsureTxInPool(tx));
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    // 3 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 3;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(utxo, utxo_hash, Amount(10_000),
        Settle_1_Blocks, WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    const chan_id = chan_id_res.value;
    network.listener.waitUntilChannelState(chan_id, ChannelState.WaitingForFunding);

    // await funding transaction
    network.expectTxExternalization(chan_id);

    // wait for the parties & listener to detect the funding tx
    alice.waitForChannelOpen(chan_id);
    charlie.waitForChannelOpen(chan_id);
    network.listener.waitUntilChannelState(chan_id, ChannelState.Open);

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
    network.postAndEnsureTxInPool(update_tx);
    network.expectTxExternalization(update_tx);
    network.listener.waitUntilChannelState(chan_id,
        ChannelState.StartedUnilateralClose);


    // publish an older update
    update_tx = alice.getPublishUpdateIndex(WK.Keys.A.address, chan_id, 2);
    network.postAndEnsureTxInPool(update_tx);
    network.expectTxExternalization(update_tx);

    // an even older update can not be externalized anymore
    update_tx = alice.getPublishUpdateIndex(WK.Keys.A.address, chan_id, 1);
    network.clients[0].postTransaction(update_tx);
    assert(!network.clients[0].hasTransactionHash(update_tx.hashFull()));

    // allow normal node operation again
    alice.setPublishEnable(true);
    charlie.setPublishEnable(true);

    update_tx = alice.getPublishUpdateIndex(WK.Keys.A.address, chan_id, 4);
    network.expectTxExternalization(update_tx);

    iota(Settle_1_Blocks * 2).each!(idx => network.addBlock(true));
    network.listener.waitUntilChannelState(chan_id,
        ChannelState.Closed);
}

/// Test private channels
unittest
{
    auto conf = flashTestConf();
    auto network = makeTestNetwork!FlashNodeFactory(conf);
    scope (exit) network.shutdown();
    scope (failure) network.printLogs();

    auto alice = network.createFlashNode(WK.Keys.A);
    auto charlie = network.createFlashNode(WK.Keys.C);
    auto diego = network.createFlashNode(WK.Keys.D);
    auto eomer = network.createFlashNode(WK.Keys.E);

    network.start();
    network.waitForDiscovery();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    txs.each!(tx => network.postAndEnsureTxInPool(tx));
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;
    //const Settle_10_Blocks = 10;

    /+ OPEN ALICE => CHARLIE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const alice_utxo = UTXO(0, txs[0].outputs[0]);
    const alice_utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const alice_charlie_chan_id_res = alice.openNewChannel(alice_utxo, alice_utxo_hash,
        Amount(10_000), Settle_1_Blocks, WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(alice_charlie_chan_id_res.error == ErrorCode.None,
        alice_charlie_chan_id_res.message);
    const alice_charlie_chan_id = alice_charlie_chan_id_res.value;
    log.info("Alice charlie channel ID: {}", alice_charlie_chan_id);
    network.listener.waitUntilChannelState(alice_charlie_chan_id,
        ChannelState.WaitingForFunding);

    // await alice & charlie channel funding transaction
    network.expectTxExternalization(alice_charlie_chan_id);

    // wait for the parties to detect the funding tx
    alice.waitForChannelOpen(alice_charlie_chan_id);
    charlie.waitForChannelOpen(alice_charlie_chan_id);
    network.listener.waitUntilChannelState(alice_charlie_chan_id, ChannelState.Open);

    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN CHARLIE => DIEGO CHANNEL (PRIVATE) +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const charlie_utxo = UTXO(0, txs[1].outputs[0]);
    const charlie_utxo_hash = UTXO.getHash(hashFull(txs[1]), 0);
    const charlie_diego_chan_id_res = charlie.openNewChannel(charlie_utxo, charlie_utxo_hash,
        Amount(3_000), Settle_1_Blocks, WK.Keys.D.address, true, Address("http://"~to!string(WK.Keys.D.address)));
    assert(charlie_diego_chan_id_res.error == ErrorCode.None,
        charlie_diego_chan_id_res.message);
    const charlie_diego_chan_id = charlie_diego_chan_id_res.value;
    log.info("Charlie Diego channel ID: {}", charlie_diego_chan_id);
    network.listener.waitUntilChannelState(charlie_diego_chan_id,
        ChannelState.WaitingForFunding);

    // await charlie & charlie channel funding transaction
    network.expectTxExternalization(charlie_diego_chan_id);

    // wait for the parties to detect the funding tx
    charlie.waitForChannelOpen(charlie_diego_chan_id);
    diego.waitForChannelOpen(charlie_diego_chan_id);
    network.listener.waitUntilChannelState(charlie_diego_chan_id, ChannelState.Open);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN DIEGO => EOMER CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const diego_utxo = UTXO(0, txs[2].outputs[0]);
    const diego_utxo_hash = UTXO.getHash(hashFull(txs[2]), 0);
    const eomer_diego_chan_id_res = diego.openNewChannel(diego_utxo, diego_utxo_hash,
        Amount(3_000), Settle_1_Blocks, WK.Keys.E.address, false, Address("http://"~to!string(WK.Keys.E.address)));
    assert(eomer_diego_chan_id_res.error == ErrorCode.None,
        eomer_diego_chan_id_res.message);
    const eomer_diego_chan_id = eomer_diego_chan_id_res.value;
    log.info("Eomer Diego channel ID: {}", eomer_diego_chan_id);
    network.listener.waitUntilChannelState(eomer_diego_chan_id,
        ChannelState.WaitingForFunding);

    // await charlie & charlie channel funding transaction
    network.expectTxExternalization(eomer_diego_chan_id);

    // wait for the parties to detect the funding tx
    eomer.waitForChannelOpen(eomer_diego_chan_id);
    diego.waitForChannelOpen(eomer_diego_chan_id);
    network.listener.waitUntilChannelState(eomer_diego_chan_id, ChannelState.Open);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    // also wait for all parties to discover other channels on the network
    alice.waitForChannelDiscovery(charlie_diego_chan_id);
    eomer.waitForChannelDiscovery(charlie_diego_chan_id);
    alice.waitForChannelDiscovery(eomer_diego_chan_id);
    charlie.waitForChannelDiscovery(eomer_diego_chan_id);
    diego.waitForChannelDiscovery(alice_charlie_chan_id);
    eomer.waitForChannelDiscovery(alice_charlie_chan_id);

    // begin off-chain transactions
    auto inv_1 = diego.createNewInvoice(WK.Keys.D.address, Amount(2_000),
        time_t.max, "payment 1");

    // This would have to use Charlie => Diego channel as a hop, but channel is private
    alice.payInvoice(WK.Keys.A.address, inv_1.value);
    auto inv_res = network.listener.waitUntilNotified(inv_1.value);
    assert(inv_res == ErrorCode.PathNotFound, format("Payment %s didn't fail", inv_res));

    auto inv_2 = charlie.createNewInvoice(WK.Keys.C.address, Amount(1_000),
        time_t.max, "payment 1");
    auto inv_3 = eomer.createNewInvoice(WK.Keys.E.address, Amount(2_000),
        time_t.max, "payment 1");

    // charlie and eomer should be able to pay each other.
    charlie.payInvoice(WK.Keys.C.address, inv_3.value);
    inv_res = network.listener.waitUntilNotified(inv_3.value);
    assert(inv_res == ErrorCode.None, format("Couldn't pay invoice: %s", inv_res));

    eomer.payInvoice(WK.Keys.E.address, inv_2.value);
    inv_res = network.listener.waitUntilNotified(inv_2.value);
    assert(inv_res == ErrorCode.None, format("Couldn't pay invoice: %s", inv_res));
}

// Reject collaborative close, if a too generous fee was set for close TX
// that it can not be paid using the channel funds
unittest
{
    static class GenerousFlashListener : FlashListener
    {
        mixin ForwardCtor!();

        public override Amount getEstimatedTxFee ()
        {
            return 10.coins;
        }
    }

    auto conf = flashTestConf();
    auto network = makeTestNetwork!FlashNodeFactory(conf);
    scope (exit) network.shutdown();
    scope (failure) network.printLogs();

    auto alice = network.createFlashNode(WK.Keys.A);
    auto charlie = network.createFlashNode(WK.Keys.C);

    network.start!GenerousFlashListener();
    network.waitForDiscovery();

    // split the genesis funds into WK.Keys[0] .. WK.Keys[7]
    auto txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();

    txs.each!(tx => network.postAndEnsureTxInPool(tx));
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;
    //const Settle_10_Blocks = 10;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO(0, txs[0].outputs[0]);
    const utxo_hash = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(utxo, utxo_hash, Amount(10_000),
        Settle_1_Blocks, WK.Keys.C.address, false, Address("http://"~to!string(WK.Keys.C.address)));
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    const chan_id = chan_id_res.value;
    network.listener.waitUntilChannelState(chan_id, ChannelState.WaitingForFunding);

    // await funding transaction
    network.expectTxExternalization(chan_id);

    // wait for the parties & listener to detect the funding tx
    alice.waitForChannelOpen(chan_id);
    charlie.waitForChannelOpen(chan_id);
    network.listener.waitUntilChannelState(chan_id, ChannelState.Open);

    log.info("Alice collaboratively closing the channel..");
    auto error = alice.beginCollaborativeClose(WK.Keys.A.address, chan_id).error;
    assert(error == ErrorCode.None, error.to!string);
    network.listener.waitUntilChannelState(chan_id,
        ChannelState.RejectedCollaborativeClose);

    log.info("Alice unilaterally closing the channel..");
    error = alice.beginUnilateralClose(WK.Keys.A.address, chan_id).error;
    assert(error == ErrorCode.None, error.to!string);
    network.listener.waitUntilChannelState(chan_id,
        ChannelState.StartedUnilateralClose);

    // trigger tx & latest update tx & latest settle tx
    iota(4).each!(idx => network.addBlock(true));
    network.listener.waitUntilChannelState(chan_id, ChannelState.Closed);
}
