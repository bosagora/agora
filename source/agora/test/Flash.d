/*******************************************************************************

    Contains Flash layer tests.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Flash;

version (unittest):

import agora.api.FullNode : FullNodeAPI = API;
import agora.common.Amount;
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

import geod24.Registry;

import std.conv;
import std.exception;

import core.stdc.time;
import core.thread;

mixin AddLogger!();

/// In addition to the Flash APIs, we provide methods for conditional waits
/// and extracting update / closing / settle pairs, and forceful channel close.
public interface TestFlashAPI : ControlFlashAPI
{
    /// Wait for the specified update index. Index 0 is the funding state.
    /// Note that a payment also triggers an update later when the secret
    /// is revealed, so the indexes passed are usually even numbers (2, 4, 6..)
    public void waitForUpdateIndex (in Hash chan_id, in uint index);

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

/// A thin localrest flash node which itself is not a FullNode / Validator
public class TestFlashNode : ThinFlashNode, TestFlashAPI
{
    ///
    protected Registry!TestAPI* agora_registry;

    ///
    protected Registry!TestFlashAPI* flash_registry;

    ///
    public this (const KeyPair kp, Registry!TestAPI* agora_registry,
        string agora_address, Registry!TestFlashAPI* flash_registry)
    {
        this.agora_registry = agora_registry;
        this.flash_registry = flash_registry;
        const genesis_hash = hashFull(GenesisBlock);
        const TestStackMaxTotalSize = 16_384;
        const TestStackMaxItemSize = 512;
        auto engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
        super(kp, genesis_hash, engine, new LocalRestTaskManager(), agora_address);
    }

    ///
    public override void shutdownNode ()
    {
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

        auto tid = this.flash_registry.locate(peer_pk.to!string);
        assert(tid != typeof(tid).init, "Flash node not initialized");

        auto peer = new RemoteAPI!TestFlashAPI(tid, timeout);
        this.known_peers[peer_pk] = peer;
        peer.gossipChannelsOpen(this.known_channels.values);

        return peer;
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
        const dir = this.kp.address == this.known_channels[chan_id].funder_pk ?
            PaymentDirection.TowardsPeer : PaymentDirection.TowardsOwner;
        auto update = this.channel_updates[chan_id][dir];
        update.fixed_fee = fixed_fee;
        update.proportional_fee = proportional_fee;
        update.sig = this.kp.sign(update);
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
        output.formattedWrite("Log for Flash node %s:\n", this.kp.address.flashPrettify);
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

    /// list of flash addresses
    private Point[] addresses;

    /// list of flash nodes
    private RemoteAPI!TestFlashAPI[] nodes;

    /// Ctor
    public this (Registry!TestAPI* agora_registry)
    {
        this.agora_registry = agora_registry;
        this.flash_registry.initialize();
    }

    /// Create a new flash node user
    public RemoteAPI!TestFlashAPI create (const Pair pair, string agora_address)
    {
        RemoteAPI!TestFlashAPI api = RemoteAPI!TestFlashAPI.spawn!TestFlashNode(
            KeyPair(PublicKey(pair.V), SecretKey(pair.v)),
            this.agora_registry, agora_address, &this.flash_registry);
        api.start();

        this.addresses ~= pair.V;
        this.nodes ~= api;
        this.flash_registry.register(pair.V.to!string, api.listener());

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

        foreach (node; this.nodes)
        {
            node.shutdownNode();
            node.ctrl.shutdown();
        }
    }
}

/// Test unilateral non-collaborative close (funding + update* + settle)
//version (none)
unittest
{
    TestConf conf = { txs_to_nominate : 1, payout_period : 100 };
    auto network = makeTestNetwork(conf);
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
        network.expectBlock(Height(idx + 1), network.blocks[0].header);
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
    const chan_id = alice.openNewChannel(
        utxo, Amount(10_000), Settle_1_Blocks, bob_pair.V);

    // await funding transaction
    network.expectBlock(Height(9), network.blocks[0].header);
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
    network.expectBlock(Height(10), network.blocks[0].header);
    auto tx_10 = node_1.getBlocksFrom(10, 1)[0].txs[0];
    assert(tx_10 == update_tx);

    // at this point bob will automatically publish the latest update tx
    network.expectBlock(Height(11), network.blocks[0].header);

    // and then a settlement will be published (but only after time lock expires)
    auto settle_tx = bob.getLastSettleTx(chan_id);
    network.expectBlock(Height(12), network.blocks[0].header);
    auto tx_12 = node_1.getBlocksFrom(12, 1)[0].txs[0];
    //assert(tx_12 == settle_tx);
}

/// Test indirect channel payments
//version (none)
unittest
{
    TestConf conf = { txs_to_nominate : 1, payout_period : 100 };
    auto network = makeTestNetwork(conf);
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
        network.expectBlock(Height(idx + 1), network.blocks[0].header);
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
    const alice_bob_chan_id = alice.openNewChannel(
        alice_utxo, Amount(10_000), Settle_1_Blocks, bob_pk);
    log.info("Alice bob channel ID: {}", alice_bob_chan_id);

    // await alice & bob channel funding transaction
    network.expectBlock(Height(9), network.blocks[0].header);
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
    const bob_charlie_chan_id = bob.openNewChannel(
        bob_utxo, Amount(3_000), Settle_1_Blocks, charlie_pk);
    log.info("Bob Charlie channel ID: {}", bob_charlie_chan_id);

    // await bob & bob channel funding transaction
    network.expectBlock(Height(10), network.blocks[0].header);
    const block_10 = node_1.getBlocksFrom(10, 1)[$ - 1];
    assert(block_10.txs.any!(tx => tx.hashFull() == bob_charlie_chan_id));

    // wait for the parties to detect the funding tx
    bob.waitChannelOpen(bob_charlie_chan_id);
    charlie.waitChannelOpen(bob_charlie_chan_id);
    /+++++++++++++++++++++++++++++++++++++++++++++/

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
    network.expectBlock(Height(11), network.blocks[0].header);
    auto block11 = node_1.getBlocksFrom(11, 1)[0];
    log.info("bob closing tx: {}", bob.getClosingTx(bob_charlie_chan_id));
    assert(block11.txs[0] == bob.getClosingTx(bob_charlie_chan_id));

    log.info("Beginning alice => bob collaborative close..");
    alice.beginCollaborativeClose(alice_bob_chan_id);
    network.expectBlock(Height(12), network.blocks[0].header);
    auto block12 = node_1.getBlocksFrom(12, 1)[0];
    log.info("alice closing tx: {}", alice.getClosingTx(alice_bob_chan_id));
    assert(block12.txs[0] == alice.getClosingTx(alice_bob_chan_id));
}

/// Test path probing
unittest
{
    TestConf conf = { txs_to_nominate : 1, payout_period : 100 };
    auto network = makeTestNetwork(conf);
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
        network.expectBlock(Height(idx + 1), network.blocks[0].header);
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
    const alice_bob_chan_id = alice.openNewChannel(
        alice_utxo, Amount(10_000), Settle_1_Blocks, bob_pk);
    log.info("Alice bob channel ID: {}", alice_bob_chan_id);

    // await alice & bob channel funding transaction
    network.expectBlock(Height(9), network.blocks[0].header);
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
    const bob_charlie_chan_id = bob.openNewChannel(
        bob_utxo, Amount(10_000), Settle_1_Blocks, charlie_pk);
    log.info("Bob Charlie channel ID: {}", bob_charlie_chan_id);

    // await bob & bob channel funding transaction
    network.expectBlock(Height(10), network.blocks[0].header);
    const block_10 = node_1.getBlocksFrom(10, 1)[$ - 1];
    assert(block_10.txs.any!(tx => tx.hashFull() == bob_charlie_chan_id));

    // wait for the parties to detect the funding tx
    bob.waitChannelOpen(bob_charlie_chan_id);
    charlie.waitChannelOpen(bob_charlie_chan_id);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    /+ CHARLIE BOB => ALICE CHANNEL +/
    /+++++++++++++++++++++++++++++++++++++++++++++/
    // the utxo the funding tx will spend (only relevant to the funder)
    const charlie_utxo = UTXO.getHash(hashFull(txs[2]), 0);
    const charlie_alice_chan_id = charlie.openNewChannel(
        charlie_utxo, Amount(10_000), Settle_1_Blocks, alice_pk);
    log.info("Charlie Alice channel ID: {}", charlie_alice_chan_id);

    // await bob & bob channel funding transaction
    network.expectBlock(Height(11), network.blocks[0].header);
    const block_11 = node_1.getBlocksFrom(11, 1)[$ - 1];
    assert(block_11.txs.any!(tx => tx.hashFull() == charlie_alice_chan_id));

    // wait for the parties to detect the funding tx
    alice.waitChannelOpen(charlie_alice_chan_id);
    charlie.waitChannelOpen(charlie_alice_chan_id);
    /+++++++++++++++++++++++++++++++++++++++++++++/


    // begin off-chain transactions
    auto inv_1 = charlie.createNewInvoice(Amount(2_000), time_t.max, "payment 1");

    // here we assume bob sent the invoice to alice through some means,

    // Alice has a direct channel to charlie, but it does not have enough funds
    // to complete the payment in that direction. Alice will first naively try
    // that route and fail. In the second try, alice will route the payment through bob.
    alice.payInvoice(inv_1);

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
