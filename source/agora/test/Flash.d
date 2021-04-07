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
import agora.common.Config;
import agora.common.ManagedDatabase;
import agora.common.Types;
import agora.common.Task;
import agora.consensus.data.genesis.Test;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXO;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr;
import agora.flash.API;
import agora.flash.ControlAPI;
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

import std.conv;
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
}

/// In addition to the Flash APIs, we provide methods for conditional waits
/// and extracting update / closing / settle pairs, and forceful channel close.
public interface TestFlashAPI : ControlFlashAPI
{
    /// Wait for the specified update index. Index 0 is the funding state.
    /// Note that a payment also triggers an update later when the secret
    /// is revealed, so the indexes passed are usually even numbers (2, 4, 6..)
    public void waitForUpdateIndex (in Hash chan_id, in uint index);

    /// Wait until the specified channel ID has been gossiped to this node
    public void waitForChannelDiscovery (in Hash chan_id);

    /// Force publishing an update tx with the given index to the blockchain.
    /// Used for testing and ensuring the counter-party detects the update tx
    /// and publishes the latest state to the blockchain.
    public Transaction getPublishUpdateIndex (in Hash chan_id, in uint index);

    /// Get the expected closing tx that should have been published to the chain
    public Transaction getClosingTx (in Hash chan_id);

    /// Get the expected settlement tx when a trigger was published to the chain
    public Transaction getLastSettleTx (in Hash chan_id);

    /// Get the channel update
    public ChannelUpdate getChannelUpdate (Hash chan_id, PaymentDirection dir);

    /// Print out the contents of the log
    public abstract void printLog ();

    /// Shut down any timers (forwards to ThinFlashNode.shutdown)
    public void shutdownNode ();
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
    protected override TestFlashAPI getFlashClient (in Point peer_pk,
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
        peer.gossipChannelsOpen(this.known_channels.values);

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
    public override Transaction getPublishUpdateIndex (in Hash chan_id,
        in uint index)
    {
        auto channel = chan_id in this.channels;
        assert(channel !is null);
        return channel.getPublishUpdateIndex(index);
    }

    ///
    public override void waitForUpdateIndex (in Hash chan_id, in uint index)
    {
        auto channel = chan_id in this.channels;
        assert(channel !is null);
        return channel.waitForUpdateIndex(index);
    }

    ///
    public override void waitForChannelDiscovery (in Hash chan_id)
    {
        while (chan_id !in this.known_channels)
            this.taskman.wait(100.msecs);
    }

    ///
    public override Transaction getClosingTx (in Hash chan_id)
    {
        auto channel = chan_id in this.channels;
        assert(channel !is null);
        return channel.getClosingTx();
    }

    ///
    public override Transaction getLastSettleTx (in Hash chan_id)
    {
        auto channel = chan_id in this.channels;
        assert(channel !is null);
        return channel.getLastSettleTx();
    }

    ///
    public override void changeFees (Hash chan_id, Amount fixed_fee, Amount proportional_fee)
    {
        const dir = this.conf.key_pair.address == this.known_channels[chan_id].funder_pk ?
            PaymentDirection.TowardsPeer : PaymentDirection.TowardsOwner;
        auto update = this.channel_updates[chan_id][dir];
        update.fixed_fee = fixed_fee;
        update.proportional_fee = proportional_fee;
        update.sig = this.conf.key_pair.sign(update);
        this.gossipChannelUpdates([update]);
    }

    ///
    public ChannelUpdate getChannelUpdate (Hash chan_id, PaymentDirection dir)
    {
        return this.channel_updates[chan_id][dir];
    }

    /// Prints out the log contents for this node
    public void printLog ()
    {
        auto output = stdout.lockingTextWriter();
        output.formattedWrite("Log for Flash node %s:\n", this.conf.key_pair.address.flashPrettify);
        output.put("======================================================================\n");
        CircularAppender!()().print(output);
        output.put("======================================================================\n\n");
        stdout.flush();
    }
}

/// Is in charge of spawning the flash nodes
public class FlashNodeFactory
{
    /// Registry of nodes
    private Registry!TestAPI* agora_registry;

    /// we keep a separate LocalRest registry of the flash "nodes"
    private Registry!TestFlashAPI flash_registry;

    /// and a registry of listener nodes (usually just one)
    private Registry!TestFlashListenerAPI listener_registry;

    /// list of flash addresses
    private Point[] addresses;

    /// list of listener addresses
    private string[] listener_addresses;

    /// list of flash nodes
    private RemoteAPI!TestFlashAPI[] nodes;

    /// list of FlashListenerAPI nodes
    private RemoteAPI!TestFlashListenerAPI[] listener_nodes;

    /// Ctor
    public this (Registry!TestAPI* agora_registry)
    {
        this.agora_registry = agora_registry;
        this.flash_registry.initialize();
        this.listener_registry.initialize();
    }

    /// Create a new flash node user
    public RemoteAPI!TestFlashAPI create (FlashNodeImpl = TestFlashNode)
        (const Pair pair, string agora_address,
         DatabaseStorage storage = DatabaseStorage.Local)
    {
        FlashConfig conf = { enabled : true,
            min_funding : Amount(1000),
            max_funding : Amount(100_000_000),
            min_settle_time : 0,
            max_settle_time : 100,
            key_pair : KeyPair(PublicKey(pair.V), SecretKey(pair.v)),
            max_retry_time : 4.seconds };
        return this.create!FlashNodeImpl(pair, conf, agora_address, storage);
    }

    /// ditto
    public RemoteAPI!TestFlashAPI create (FlashNodeImpl = TestFlashNode)
        (const Pair pair, FlashConfig conf, string agora_address,
         DatabaseStorage storage = DatabaseStorage.Local)
    {
        RemoteAPI!TestFlashAPI api = RemoteAPI!TestFlashAPI.spawn!FlashNodeImpl(
            conf, this.agora_registry, agora_address, storage,
            &this.flash_registry, &this.listener_registry,
            5.seconds);  // timeout from main thread

        this.addresses ~= pair.V;
        this.nodes ~= api;
        this.flash_registry.register(pair.V.to!string, api.listener());
        api.start();

        return api;
    }

    /// Create a new FlashListenerAPI node
    public RemoteAPI!TestFlashListenerAPI createFlashListener (
        Listener : TestFlashListenerAPI)(string address)
    {
        RemoteAPI!TestFlashListenerAPI api
            = RemoteAPI!TestFlashListenerAPI.spawn!Listener(5.seconds);
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
        if (no_logs)
            return;

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
        {
            node.shutdownNode();
            node.ctrl.shutdown();
        }

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
            node.ctrl.withTimeout(0.msecs, (scope ControlFlashAPI api) { api.start(); });
        }
    }
}

/// Listens for Flash events (if registered with a Flash node)
private class FlashListener : TestFlashListenerAPI
{
    ErrorCode[Invoice] invoices;
    LocalRestTaskManager taskman;

    public this ()
    {
        this.taskman = new LocalRestTaskManager();
    }

    public void onPaymentSuccess (Invoice invoice)
    {
        this.invoices[invoice] = ErrorCode.None;
    }

    public void onPaymentFailure (Invoice invoice, ErrorCode error)
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
}

/// Test unilateral non-collaborative close (funding + update* + settle)
//version (none)
unittest
{
    TestConf conf = { txs_to_nominate : 1, payout_period : 100 };
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
        node_1.putTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    const alice_pair = Pair(WK.Keys[0].secret, WK.Keys[0].secret.toPoint);
    const bob_pair = Pair(WK.Keys[1].secret, WK.Keys[1].secret.toPoint);

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0,
        WK.Keys.NODE2.address);
    auto alice = factory.create(alice_pair, address);
    auto bob = factory.create(bob_pair, address);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;
    //const Settle_10_Blocks = 10;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(
        utxo, Amount(10_000), Settle_1_Blocks, bob_pair.V);
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    const chan_id = chan_id_res.value;

    // await funding transaction
    network.expectHeightAndPreImg(Height(9), network.blocks[0].header);
    const block_9 = node_1.getBlocksFrom(9, 1)[$ - 1];
    assert(block_9.txs.any!(tx => tx.hashFull() == chan_id));

    // wait for the parties to detect the funding tx
    alice.waitChannelOpen(chan_id);
    bob.waitChannelOpen(chan_id);

    auto update_tx = alice.getPublishUpdateIndex(chan_id, 0);

    /* do some off-chain transactions */
    auto inv_1 = bob.createNewInvoice(Amount(5_000), time_t.max, "payment 1");
    alice.payInvoice(inv_1);

    alice.waitForUpdateIndex(chan_id, 2);
    bob.waitForUpdateIndex(chan_id, 2);

    auto inv_2 = bob.createNewInvoice(Amount(1_000), time_t.max, "payment 2");
    alice.payInvoice(inv_2);

    // need to wait for invoices to be complete before we have the new balance
    // to send in the other direction
    alice.waitForUpdateIndex(chan_id, 4);
    bob.waitForUpdateIndex(chan_id, 4);

    // note the reverse payment from bob to alice. Can use this for refunds too.
    auto inv_3 = alice.createNewInvoice(Amount(2_000), time_t.max, "payment 3");
    bob.payInvoice(inv_3);

    alice.waitForUpdateIndex(chan_id, 6);
    bob.waitForUpdateIndex(chan_id, 6);

    // alice is acting bad
    log.info("Alice unilaterally closing the channel..");
    network.expectHeightAndPreImg(Height(10), network.blocks[0].header);
    auto tx_10 = node_1.getBlocksFrom(10, 1)[0].txs[0];
    assert(tx_10 == update_tx);

    // at this point bob will automatically publish the latest update tx
    network.expectHeightAndPreImg(Height(11), network.blocks[0].header);

    // and then a settlement will be published (but only after time lock expires)
    auto settle_tx = bob.getLastSettleTx(chan_id);
    network.expectHeightAndPreImg(Height(12), network.blocks[0].header);
    auto tx_12 = node_1.getBlocksFrom(12, 1)[0].txs[0];
    //assert(tx_12 == settle_tx);
}

/// Test indirect channel payments
//version (none)
unittest
{
    TestConf conf = { txs_to_nominate : 1, payout_period : 100 };
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
        node_1.putTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    const alice_pair = Pair(WK.Keys[0].secret, WK.Keys[0].secret.toPoint);
    const bob_pair = Pair(WK.Keys[1].secret, WK.Keys[1].secret.toPoint);
    const charlie_pair = Pair(WK.Keys[2].secret, WK.Keys[2].secret.toPoint);

    const alice_pk = alice_pair.V;
    const bob_pk = bob_pair.V;
    const charlie_pk = charlie_pair.V;

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0,
        WK.Keys.NODE2.address);
    auto alice = factory.create(alice_pair, address);
    auto bob = factory.create(bob_pair, address);
    auto charlie = factory.create(charlie_pair, address);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;
    //const Settle_10_Blocks = 10;

    /+ OPEN ALICE => BOB CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const alice_utxo = UTXO.getHash(hashFull(txs[0]), 0);
    const alice_bob_chan_id_res = alice.openNewChannel(
        alice_utxo, Amount(10_000), Settle_1_Blocks, bob_pk);
    assert(alice_bob_chan_id_res.error == ErrorCode.None,
        alice_bob_chan_id_res.message);
    const alice_bob_chan_id = alice_bob_chan_id_res.value;
    log.info("Alice bob channel ID: {}", alice_bob_chan_id);

    // await alice & bob channel funding transaction
    network.expectHeightAndPreImg(Height(9), network.blocks[0].header);
    const block_9 = node_1.getBlocksFrom(9, 1)[$ - 1];
    assert(block_9.txs.any!(tx => tx.hashFull() == alice_bob_chan_id));

    // wait for the parties to detect the funding tx
    alice.waitChannelOpen(alice_bob_chan_id);
    bob.waitChannelOpen(alice_bob_chan_id);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN BOB => CHARLIE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const bob_utxo = UTXO.getHash(hashFull(txs[1]), 0);
    const bob_charlie_chan_id_res = bob.openNewChannel(
        bob_utxo, Amount(3_000), Settle_1_Blocks, charlie_pk);
    assert(bob_charlie_chan_id_res.error == ErrorCode.None,
        bob_charlie_chan_id_res.message);
    const bob_charlie_chan_id = bob_charlie_chan_id_res.value;
    log.info("Bob Charlie channel ID: {}", bob_charlie_chan_id);

    // await bob & bob channel funding transaction
    network.expectHeightAndPreImg(Height(10), network.blocks[0].header);
    const block_10 = node_1.getBlocksFrom(10, 1)[$ - 1];
    assert(block_10.txs.any!(tx => tx.hashFull() == bob_charlie_chan_id));

    // wait for the parties to detect the funding tx
    bob.waitChannelOpen(bob_charlie_chan_id);
    charlie.waitChannelOpen(bob_charlie_chan_id);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    // also wait for all parties to discover other channels on the network
    alice.waitForChannelDiscovery(bob_charlie_chan_id);
    charlie.waitForChannelDiscovery(alice_bob_chan_id);

    // begin off-chain transactions
    auto inv_1 = charlie.createNewInvoice(Amount(2_000), time_t.max, "payment 1");

    // here we assume bob sent the invoice to alice through some means,
    // e.g. QR code. Alice scans it and proposes the payment.
    // it has a direct channel to bob so it uses it.
    alice.payInvoice(inv_1);

    // wait for payment + folding update indices
    alice.waitForUpdateIndex(alice_bob_chan_id, 2);
    bob.waitForUpdateIndex(alice_bob_chan_id, 2);
    bob.waitForUpdateIndex(bob_charlie_chan_id, 2);
    charlie.waitForUpdateIndex(bob_charlie_chan_id, 2);

    //
    log.info("Beginning bob => charlie collaborative close..");
    bob.beginCollaborativeClose(bob_charlie_chan_id);
    network.expectHeightAndPreImg(Height(11), network.blocks[0].header);
    auto block11 = node_1.getBlocksFrom(11, 1)[0];
    log.info("bob closing tx: {}", bob.getClosingTx(bob_charlie_chan_id));
    assert(block11.txs[0] == bob.getClosingTx(bob_charlie_chan_id));

    log.info("Beginning alice => bob collaborative close..");
    alice.beginCollaborativeClose(alice_bob_chan_id);
    network.expectHeightAndPreImg(Height(12), network.blocks[0].header);
    auto block12 = node_1.getBlocksFrom(12, 1)[0];
    log.info("alice closing tx: {}", alice.getClosingTx(alice_bob_chan_id));
    assert(block12.txs[0] == alice.getClosingTx(alice_bob_chan_id));
}

/// Test path probing
unittest
{
    TestConf conf = { txs_to_nominate : 1, payout_period : 100 };
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
        node_1.putTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    const alice_pair = Pair(WK.Keys[0].secret, WK.Keys[0].secret.toPoint);
    const bob_pair = Pair(WK.Keys[1].secret, WK.Keys[1].secret.toPoint);
    const charlie_pair = Pair(WK.Keys[2].secret, WK.Keys[2].secret.toPoint);

    const alice_pk = alice_pair.V;
    const bob_pk = bob_pair.V;
    const charlie_pk = charlie_pair.V;

    const ListenerAddress = "flash-listener";
    auto listener = factory.createFlashListener!FlashListener(ListenerAddress);

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0,
        WK.Keys.NODE2.address);

    FlashConfig alice_conf = { enabled : true,
        min_funding : Amount(1000),
        max_funding : Amount(100_000_000),
        min_settle_time : 0,
        max_settle_time : 100,
        key_pair : KeyPair(PublicKey(alice_pair.V), SecretKey(alice_pair.v)),
        listener_address : ListenerAddress,
        max_retry_time : 4.seconds,
    };

    auto alice = factory.create(alice_pair, alice_conf, address);
    auto bob = factory.create(bob_pair, address);
    auto charlie = factory.create(charlie_pair, address);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;
    //const Settle_10_Blocks = 10;

    /+ OPEN ALICE => BOB CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const alice_utxo = UTXO.getHash(hashFull(txs[0]), 0);
    const alice_bob_chan_id_res = alice.openNewChannel(
        alice_utxo, Amount(10_000), Settle_1_Blocks, bob_pk);
    assert(alice_bob_chan_id_res.error == ErrorCode.None,
        alice_bob_chan_id_res.message);
    const alice_bob_chan_id = alice_bob_chan_id_res.value;
    log.info("Alice bob channel ID: {}", alice_bob_chan_id);

    // await alice & bob channel funding transaction
    network.expectHeightAndPreImg(Height(9), network.blocks[0].header);
    const block_9 = node_1.getBlocksFrom(9, 1)[$ - 1];
    assert(block_9.txs.any!(tx => tx.hashFull() == alice_bob_chan_id));

    // wait for the parties to detect the funding tx
    alice.waitChannelOpen(alice_bob_chan_id);
    bob.waitChannelOpen(alice_bob_chan_id);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN BOB => CHARLIE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const bob_utxo = UTXO.getHash(hashFull(txs[1]), 0);
    const bob_charlie_chan_id_res = bob.openNewChannel(
        bob_utxo, Amount(10_000), Settle_1_Blocks, charlie_pk);
    assert(bob_charlie_chan_id_res.error == ErrorCode.None,
        bob_charlie_chan_id_res.message);
    const bob_charlie_chan_id = bob_charlie_chan_id_res.value;
    log.info("Bob Charlie channel ID: {}", bob_charlie_chan_id);

    // await bob & bob channel funding transaction
    network.expectHeightAndPreImg(Height(10), network.blocks[0].header);
    const block_10 = node_1.getBlocksFrom(10, 1)[$ - 1];
    assert(block_10.txs.any!(tx => tx.hashFull() == bob_charlie_chan_id));

    // wait for the parties to detect the funding tx
    bob.waitChannelOpen(bob_charlie_chan_id);
    charlie.waitChannelOpen(bob_charlie_chan_id);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN CHARLIE => ALICE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const charlie_utxo = UTXO.getHash(hashFull(txs[2]), 0);
    const charlie_alice_chan_id_res = charlie.openNewChannel(
        charlie_utxo, Amount(10_000), Settle_1_Blocks, alice_pk);
    assert(charlie_alice_chan_id_res.error == ErrorCode.None,
        charlie_alice_chan_id_res.message);
    const charlie_alice_chan_id = charlie_alice_chan_id_res.value;
    log.info("Charlie Alice channel ID: {}", charlie_alice_chan_id);

    // await bob & bob channel funding transaction
    network.expectHeightAndPreImg(Height(11), network.blocks[0].header);
    const block_11 = node_1.getBlocksFrom(11, 1)[$ - 1];
    assert(block_11.txs.any!(tx => tx.hashFull() == charlie_alice_chan_id));

    // wait for the parties to detect the funding tx
    alice.waitChannelOpen(charlie_alice_chan_id);
    charlie.waitChannelOpen(charlie_alice_chan_id);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    // also wait for all parties to discover other channels on the network
    alice.waitForChannelDiscovery(bob_charlie_chan_id);
    bob.waitForChannelDiscovery(charlie_alice_chan_id);
    charlie.waitForChannelDiscovery(alice_bob_chan_id);

    // begin off-chain transactions
    auto inv_1 = charlie.createNewInvoice(Amount(2_000), time_t.max, "payment 1");

    // here we assume bob sent the invoice to alice through some means,

    // Alice has a direct channel to charlie, but it does not have enough funds
    // to complete the payment in that direction. Alice will first naively try
    // that route and fail. In the second try, alice will route the payment through bob.
    alice.payInvoice(inv_1);
    auto res1 = listener.waitUntilNotified(inv_1);
    assert(res1 != ErrorCode.None);  // should fail at first
    alice.payInvoice(inv_1);
    auto res2 = listener.waitUntilNotified(inv_1);
    assert(res2 == ErrorCode.None);  // should succeed the second time

    bob.waitForUpdateIndex(bob_charlie_chan_id, 2);
    charlie.waitForUpdateIndex(bob_charlie_chan_id, 2);

    alice.changeFees(charlie_alice_chan_id, Amount(1337), Amount(1));
    auto update = alice.getChannelUpdate(charlie_alice_chan_id, PaymentDirection.TowardsOwner);
    assert(update.fixed_fee == Amount(1337));
    assert(update.proportional_fee == Amount(1));
    update = bob.getChannelUpdate(charlie_alice_chan_id, PaymentDirection.TowardsOwner);
    assert(update.fixed_fee == Amount(1337));
    assert(update.proportional_fee == Amount(1));
    update = charlie.getChannelUpdate(charlie_alice_chan_id, PaymentDirection.TowardsOwner);
    assert(update.fixed_fee == Amount(1337));
    assert(update.proportional_fee == Amount(1));
}

/// Test path probing
unittest
{
    TestConf conf = { txs_to_nominate : 1, payout_period : 100 };
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
        node_1.putTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    const alice_pair = Pair(WK.Keys[0].secret, WK.Keys[0].secret.toPoint);
    const bob_pair = Pair(WK.Keys[1].secret, WK.Keys[1].secret.toPoint);
    const charlie_pair = Pair(WK.Keys[2].secret, WK.Keys[2].secret.toPoint);

    const alice_pk = alice_pair.V;
    const bob_pk = bob_pair.V;
    const charlie_pk = charlie_pair.V;

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0,
        WK.Keys.NODE2.address);
    auto alice = factory.create(alice_pair, address);
    auto bob = factory.create(bob_pair, address);
    auto charlie = factory.create(charlie_pair, address);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;
    //const Settle_10_Blocks = 10;

    /+ OPEN ALICE => BOB CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const alice_utxo = UTXO.getHash(hashFull(txs[0]), 0);
    const alice_bob_chan_id_res = alice.openNewChannel(
        alice_utxo, Amount(10_000), Settle_1_Blocks, bob_pk);
    assert(alice_bob_chan_id_res.error == ErrorCode.None,
        alice_bob_chan_id_res.message);
    const alice_bob_chan_id = alice_bob_chan_id_res.value;
    log.info("Alice bob channel ID: {}", alice_bob_chan_id);

    // await alice & bob channel funding transaction
    network.expectHeightAndPreImg(Height(9), network.blocks[0].header);
    const block_9 = node_1.getBlocksFrom(9, 1)[$ - 1];
    assert(block_9.txs.any!(tx => tx.hashFull() == alice_bob_chan_id));

    // wait for the parties to detect the funding tx
    alice.waitChannelOpen(alice_bob_chan_id);
    bob.waitChannelOpen(alice_bob_chan_id);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN BOB => CHARLIE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const bob_utxo = UTXO.getHash(hashFull(txs[2]), 0);
    const bob_charlie_chan_id_res = bob.openNewChannel(
        bob_utxo, Amount(10_000), Settle_1_Blocks, charlie_pk);
    assert(bob_charlie_chan_id_res.error == ErrorCode.None,
        bob_charlie_chan_id_res.message);
    const bob_charlie_chan_id = bob_charlie_chan_id_res.value;
    log.info("Bob Charlie channel ID: {}", bob_charlie_chan_id);

    // await bob & bob channel funding transaction
    network.expectHeightAndPreImg(Height(10), network.blocks[0].header);
    const block_10 = node_1.getBlocksFrom(10, 1)[$ - 1];
    assert(block_10.txs.any!(tx => tx.hashFull() == bob_charlie_chan_id));

    // wait for the parties to detect the funding tx
    bob.waitChannelOpen(bob_charlie_chan_id);
    charlie.waitChannelOpen(bob_charlie_chan_id);

    bob.changeFees(bob_charlie_chan_id, Amount(100), Amount(1));
    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ OPEN SECOND BOB => CHARLIE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const bob_utxo_2 = UTXO.getHash(hashFull(txs[3]), 0);
    const bob_charlie_chan_id_2_res = bob.openNewChannel(
        bob_utxo_2, Amount(10_000), Settle_1_Blocks, charlie_pk);
    assert(bob_charlie_chan_id_2_res.error == ErrorCode.None,
        bob_charlie_chan_id_2_res.message);
    const bob_charlie_chan_id_2 = bob_charlie_chan_id_2_res.value;
    log.info("Bob Charlie channel ID: {}", bob_charlie_chan_id_2);

    // await bob & bob channel funding transaction
    network.expectHeightAndPreImg(Height(11), network.blocks[0].header);
    const block_11 = node_1.getBlocksFrom(11, 1)[$ - 1];
    assert(block_11.txs.any!(tx => tx.hashFull() == bob_charlie_chan_id_2));

    // wait for the parties to detect the funding tx
    bob.waitChannelOpen(bob_charlie_chan_id_2);
    charlie.waitChannelOpen(bob_charlie_chan_id_2);

    bob.changeFees(bob_charlie_chan_id_2, Amount(10), Amount(1));
    /+++++++++++++++++++++++++++++++++++++++++++++/

    // also wait for all parties to discover other channels on the network
    alice.waitForChannelDiscovery(bob_charlie_chan_id);
    alice.waitForChannelDiscovery(bob_charlie_chan_id_2);
    charlie.waitForChannelDiscovery(alice_bob_chan_id);

    // begin off-chain transactions
    auto inv_1 = charlie.createNewInvoice(Amount(2_000), time_t.max, "payment 1");

    // Alice is expected to route the payment through the channel
    // with lower fee between Bob and Charlie
    alice.payInvoice(inv_1);

    // wait for payment + folding update indices
    alice.waitForUpdateIndex(alice_bob_chan_id, 2);
    bob.waitForUpdateIndex(alice_bob_chan_id, 2);
    bob.waitForUpdateIndex(bob_charlie_chan_id_2, 2);
    charlie.waitForUpdateIndex(bob_charlie_chan_id_2, 2);

    bob.beginCollaborativeClose(bob_charlie_chan_id_2);
    network.expectHeightAndPreImg(Height(12), network.blocks[0].header);
    auto block12 = node_1.getBlocksFrom(12, 1)[0];
    assert(block12.txs[0] == bob.getClosingTx(bob_charlie_chan_id_2));
    assert(block12.txs[0].outputs.length == 2);
    assert(block12.txs[0].outputs[0].value == Amount(8000)); // No fees
    assert(block12.txs[0].outputs[1].value == Amount(2000));

    alice.beginCollaborativeClose(alice_bob_chan_id);
    network.expectHeightAndPreImg(Height(13), network.blocks[0].header);
    auto block13 = node_1.getBlocksFrom(13, 1)[0];
    assert(block13.txs[0] == alice.getClosingTx(alice_bob_chan_id));
    assert(block13.txs[0].outputs.length == 2);
    assert(block13.txs[0].outputs[0].value == Amount(7990)); // Fees
    assert(block13.txs[0].outputs[1].value == Amount(2010));

    bob.beginCollaborativeClose(bob_charlie_chan_id);
    network.expectHeightAndPreImg(Height(14), network.blocks[0].header);
    auto block14 = node_1.getBlocksFrom(14, 1)[0];
    assert(block14.txs[0] == bob.getClosingTx(bob_charlie_chan_id));
    assert(block14.txs[0].outputs.length == 1); // No updates
}

unittest
{
    static class BleedingEdgeFlashNode : TestFlashNode
    {
        mixin ForwardCtor!();

        ///
        protected override void paymentRouter (in Hash chan_id,
            in Hash payment_hash, in Amount amount,
            in Height lock_height, in OnionPacket packet)
        {
            OnionPacket hijacked = packet;
            hijacked.version_byte += 1;
            super.paymentRouter(chan_id, payment_hash, amount,
                lock_height, hijacked);
        }
    }

    TestConf conf = { txs_to_nominate : 1, payout_period : 100 };
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
        node_1.putTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    const alice_pair = Pair(WK.Keys[0].secret, WK.Keys[0].secret.toPoint);
    const bob_pair = Pair(WK.Keys[1].secret, WK.Keys[1].secret.toPoint);

    const bob_pk = bob_pair.V;

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0,
        WK.Keys.NODE2.address);
    auto alice = factory.create!BleedingEdgeFlashNode(alice_pair, address);
    auto bob = factory.create(bob_pair, address);

    /+ OPEN ALICE => BOB CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const alice_utxo = UTXO.getHash(hashFull(txs[0]), 0);
    const alice_bob_chan_id_res = alice.openNewChannel(
        alice_utxo, Amount(10_000), 0, bob_pk);
    assert(alice_bob_chan_id_res.error == ErrorCode.None,
        alice_bob_chan_id_res.message);
    const alice_bob_chan_id = alice_bob_chan_id_res.value;
    log.info("Alice bob channel ID: {}", alice_bob_chan_id);

    // await alice & bob channel funding transaction
    network.expectHeightAndPreImg(Height(9), network.blocks[0].header);
    const block_9 = node_1.getBlocksFrom(9, 1)[$ - 1];
    assert(block_9.txs.any!(tx => tx.hashFull() == alice_bob_chan_id));

    // wait for the parties to detect the funding tx
    alice.waitChannelOpen(alice_bob_chan_id);
    bob.waitChannelOpen(alice_bob_chan_id);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    // begin off-chain transactions
    auto inv_1 = bob.createNewInvoice(Amount(2_000), time_t.max, "payment 1");

    // Bob will receive packets with a different version than it implements
    alice.payInvoice(inv_1);
    Thread.sleep(1.seconds);

    bob.beginCollaborativeClose(alice_bob_chan_id);
    network.expectHeightAndPreImg(Height(10), network.blocks[0].header);
    auto block10 = node_1.getBlocksFrom(10, 1)[0];
    assert(block10.txs[0] == bob.getClosingTx(alice_bob_chan_id));
    assert(block10.txs[0].outputs.length == 1); // No updates
}
/// Test node serialization & loading
//version (none)
unittest
{
    TestConf conf = { txs_to_nominate : 1, payout_period : 100 };
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
        node_1.putTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    const alice_pair = Pair(WK.Keys[0].secret, WK.Keys[0].secret.toPoint);
    const bob_pair = Pair(WK.Keys[1].secret, WK.Keys[1].secret.toPoint);

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0,
        WK.Keys.NODE2.address);
    auto alice = factory.create(alice_pair, address, DatabaseStorage.Static);
    auto bob = factory.create(bob_pair, address, DatabaseStorage.Static);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(
        utxo, Amount(10_000), Settle_1_Blocks, bob_pair.V);
    assert(chan_id_res.error == ErrorCode.None,
        chan_id_res.message);
    const chan_id = chan_id_res.value;

    // await funding transaction
    network.expectHeightAndPreImg(Height(9), network.blocks[0].header);
    const block_9 = node_1.getBlocksFrom(9, 1)[$ - 1];
    assert(block_9.txs.any!(tx => tx.hashFull() == chan_id));

    // wait for the parties to detect the funding tx
    alice.waitChannelOpen(chan_id);
    bob.waitChannelOpen(chan_id);

    auto update_tx = alice.getPublishUpdateIndex(chan_id, 0);

    /* do some off-chain transactions */
    auto inv_1 = bob.createNewInvoice(Amount(5_000), time_t.max, "payment 1");
    alice.payInvoice(inv_1);

    alice.waitForUpdateIndex(chan_id, 2);
    bob.waitForUpdateIndex(chan_id, 2);

    auto inv_2 = bob.createNewInvoice(Amount(1_000), time_t.max, "payment 2");
    alice.payInvoice(inv_2);

    // need to wait for invoices to be complete before we have the new balance
    // to send in the other direction
    alice.waitForUpdateIndex(chan_id, 4);
    bob.waitForUpdateIndex(chan_id, 4);

    // restart the two nodes
    factory.restart();

    // note the reverse payment from bob to alice. Can use this for refunds too.
    auto inv_3 = alice.createNewInvoice(Amount(2_000), time_t.max, "payment 3");
    bob.payInvoice(inv_3);

    // next update index should be 6
    alice.waitForUpdateIndex(chan_id, 6);
    bob.waitForUpdateIndex(chan_id, 6);
}

/// test various error cases
unittest
{
    TestConf conf = { txs_to_nominate : 1, payout_period : 100 };
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
        node_1.putTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory(network.getRegistry());
    scope (exit) factory.shutdown();
    scope (failure) factory.printLogs();

    const alice_pair = Pair(WK.Keys[0].secret, WK.Keys[0].secret.toPoint);
    const bob_pair = Pair(WK.Keys[1].secret, WK.Keys[1].secret.toPoint);

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0,
        WK.Keys.NODE2.address);

    FlashConfig bob_conf = { enabled : true,
        min_funding : Amount(1000),
        max_funding : Amount(100_000_000),
        min_settle_time : 10,
        max_settle_time : 100,
        key_pair : KeyPair(PublicKey(bob_pair.V), SecretKey(bob_pair.v)),
    };
    auto alice = factory.create(alice_pair, address);
    auto bob = factory.create(bob_pair, bob_conf, address);

    const Settle_10_Blocks = 10;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO.getHash(hashFull(txs[0]), 0);

    // error on mismatching genesis hash
    ChannelConfig bad_conf = { funder_pk : alice_pair.V };
    auto open_res = bob.openChannel(bad_conf, PublicNonce.init);
    assert(open_res.error == ErrorCode.InvalidGenesisHash, open_res.to!string);

    // error on capacity too low
    auto res = alice.openNewChannel(
        utxo, Amount(1), Settle_10_Blocks, bob_pair.V);
    assert(res.error == ErrorCode.RejectedFundingAmount, res.to!string);

    // error on capacity too high
    res = alice.openNewChannel(
        utxo, Amount(1_000_000_000), Settle_10_Blocks, bob_pair.V);
    assert(res.error == ErrorCode.RejectedFundingAmount, res.to!string);

    // error on settle time too low
    res = alice.openNewChannel(
        utxo, Amount(10_000), 5, bob_pair.V);
    assert(res.error == ErrorCode.RejectedSettleTime, res.to!string);

    // error on settle time too high
    res = alice.openNewChannel(
        utxo, Amount(10_000), 1000, bob_pair.V);
    assert(res.error == ErrorCode.RejectedSettleTime, res.to!string);

    const chan_id_res = alice.openNewChannel(
        utxo, Amount(10_000), Settle_10_Blocks, bob_pair.V);
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    const chan_id = chan_id_res.value;

    // await funding transaction
    network.expectHeightAndPreImg(Height(9), network.blocks[0].header);
    const block_9 = node_1.getBlocksFrom(9, 1)[$ - 1];
    assert(block_9.txs.any!(tx => tx.hashFull() == chan_id));

    // wait for the parties to detect the funding tx
    alice.waitChannelOpen(chan_id);
    bob.waitChannelOpen(chan_id);

    // test what happens trying to open a new channel with the same funding tx
    res = alice.openNewChannel(utxo, Amount(10_000), Settle_10_Blocks,
        bob_pair.V);
    assert(res.error == ErrorCode.DuplicateChannelID, res.to!string);

    // test some update signer error cases
    auto sig_res = alice.requestSettleSig(Hash.init, 0);
    assert(sig_res.error == ErrorCode.InvalidChannelID, sig_res.to!string);

    sig_res = alice.requestUpdateSig(Hash.init, 0);
    assert(sig_res.error == ErrorCode.InvalidChannelID, sig_res.to!string);

    /*** test invalid payment proposals ***/

    // mismatching version byte
    OnionPacket onion = { version_byte : ubyte.max };
    auto pay_res = alice.proposePayment(Hash.init, 0, Hash.init, Amount.init,
        Height.init, onion, PublicNonce.init, Height.init);
    assert(pay_res.error == ErrorCode.VersionMismatch, pay_res.to!string);

    // invalid channel ID
    onion.version_byte = 0;
    pay_res = alice.proposePayment(Hash.init, 0, Hash.init, Amount.init,
        Height.init, onion, PublicNonce.init, Height.init);
    assert(pay_res.error == ErrorCode.InvalidChannelID, pay_res.to!string);

    // ephemeral pk is invalid
    pay_res = alice.proposePayment(chan_id, 0, Hash.init, Amount.init,
        Height.init, onion, PublicNonce.init, Height.init);
    assert(pay_res.error == ErrorCode.InvalidOnionPacket, pay_res.to!string);

    // onion packet cannot be decrypted
    onion.ephemeral_pk = Scalar.random().toPoint();
    pay_res = alice.proposePayment(chan_id, 0, Hash.init, Amount.init,
        Height.init, onion, PublicNonce.init, Height.init);
    assert(pay_res.error == ErrorCode.InvalidOnionPacket, pay_res.to!string);

    // invalid next channel ID
    Hop[] path = [
        Hop(Point(alice_pair.V[]), chan_id, Amount(10)),
        Hop(Scalar.random().toPoint(), hashFull(2), Amount(10))];
    Amount total_amount;
    Height use_lock_height;
    Point[] shared_secrets;
    onion = createOnionPacket(hashFull(42), Height(1000), Amount(100), path,
        total_amount, use_lock_height, shared_secrets);
    pay_res = alice.proposePayment(chan_id, 0, hashFull(42), total_amount,
        use_lock_height, onion, PublicNonce.init, Height.init);
    assert(pay_res.error == ErrorCode.InvalidChannelID, pay_res.to!string);

    /*** test invalid update proposals ***/

    // invalid channel ID
    auto upd_res = alice.proposeUpdate(Hash.init, 0, null, null,
        PublicNonce.init, Height.init);
    assert(upd_res.error == ErrorCode.InvalidChannelID, upd_res.to!string);

    // invalid height
    upd_res = alice.proposeUpdate(chan_id, 0, null, null,
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
        public override Result!PublicNonce proposePayment (/* in */ Hash chan_id,
            /* in */ uint seq_id, /* in */ Hash payment_hash,
            /* in */ Amount amount, /* in */ Height lock_height,
            /* in */ OnionPacket packet, /* in */ PublicNonce peer_nonce,
            /* in */ Height height) @trusted
        {
            if (seq_id >= 2)
                return Result!PublicNonce(ErrorCode.Unknown, "I'm a bad node");
            else
                return super.proposePayment(chan_id, seq_id, payment_hash,
                    amount, lock_height, packet, peer_nonce, height);
        }
    }

    TestConf conf = { txs_to_nominate : 1, payout_period : 100 };
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
        node_1.putTransaction(tx);
        network.expectHeightAndPreImg(Height(idx + 1), network.blocks[0].header);
    }

    auto factory = new FlashNodeFactory(network.getRegistry());
    scope (exit) factory.shutdown();
    //scope (failure) factory.printLogs();

    const alice_pair = Pair(WK.Keys[0].secret, WK.Keys[0].secret.toPoint);
    const bob_pair = Pair(WK.Keys[1].secret, WK.Keys[1].secret.toPoint);
    const charlie_pair = Pair(WK.Keys[2].secret, WK.Keys[2].secret.toPoint);

    const ListenerAddress = "flash-listener";
    auto listener = factory.createFlashListener!FlashListener(ListenerAddress);

    // workaround to get a handle to the node from another registry's thread
    const string address = format("Validator #%s (%s)", 0,
        WK.Keys.NODE2.address);

    FlashConfig alice_conf = { enabled : true,
        min_funding : Amount(1000),
        max_funding : Amount(100_000_000),
        min_settle_time : 0,
        max_settle_time : 100,
        key_pair : KeyPair(PublicKey(alice_pair.V), SecretKey(alice_pair.v)),
        listener_address : ListenerAddress,
        max_retry_time : 4.seconds,
    };

    auto alice = factory.create(alice_pair, alice_conf, address);
    auto bob = factory.create!RejectingFlashNode(bob_pair, address);
    auto charlie = factory.create(charlie_pair, address);

    // 0 blocks settle time after trigger tx is published (unsafe)
    const Settle_1_Blocks = 0;

    // the utxo the funding tx will spend (only relevant to the funder)
    const utxo = UTXO.getHash(hashFull(txs[0]), 0);
    const chan_id_res = alice.openNewChannel(
        utxo, Amount(10_000), Settle_1_Blocks, bob_pair.V);
    assert(chan_id_res.error == ErrorCode.None, chan_id_res.message);
    const chan_id = chan_id_res.value;

    // await funding transaction
    network.expectHeightAndPreImg(Height(9), network.blocks[0].header);
    const block_9 = node_1.getBlocksFrom(9, 1)[$ - 1];
    assert(block_9.txs.any!(tx => tx.hashFull() == chan_id));

    // wait for the parties to detect the funding tx
    alice.waitChannelOpen(chan_id);
    bob.waitChannelOpen(chan_id);

    auto update_tx = alice.getPublishUpdateIndex(chan_id, 0);

    /* do some off-chain transactions */
    auto inv_1 = bob.createNewInvoice(Amount(5_000), time_t.max, "payment 1");
    alice.payInvoice(inv_1);

    alice.waitForUpdateIndex(chan_id, 2);
    bob.waitForUpdateIndex(chan_id, 2);

    auto res = listener.waitUntilNotified(inv_1);
    assert(res == ErrorCode.None);  // should succeed

    auto inv_2 = bob.createNewInvoice(Amount(1_000), time_t.max, "payment 2");
    alice.payInvoice(inv_2);

    res = listener.waitUntilNotified(inv_2);
    assert(res != ErrorCode.None);  // should have failed

    auto inv_3 = charlie.createNewInvoice(Amount(1_000), time_t.max, "charlie");
    alice.payInvoice(inv_3);

    res = listener.waitUntilNotified(inv_3);
    assert(res == ErrorCode.PathNotFound);
}
