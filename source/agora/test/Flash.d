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
import agora.common.crypto.ECC;
import agora.common.crypto.Key;
import agora.common.crypto.Schnorr;
import agora.common.Hash;
import agora.common.Serializer;
import agora.common.Task;
import agora.consensus.data.genesis.Test;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXO;
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
import agora.script.Lock;
import agora.script.Script;
import agora.test.Base;

import geod24.Registry;

import std.conv;
import std.exception;

import core.stdc.time;
import core.thread;

/// In addition to the Flash API, we provide controller methods to initiate
/// the channel creation procedures and control each flash node's behavior.
public interface TestFlashAPI : ControlFlashAPI
{
    /// Force publishing an update tx with the given index to the blockchain.
    /// Used for testing and ensuring the counter-party detects the update tx
    /// and publishes the latest state to the blockchain.
    public Transaction getPublishUpdateIndex (in Hash chan_id, in uint index);

    /// Get the expected closing tx that should have been published to the chain
    public Transaction getClosingTx (in Hash chan_id);

    /// Get the expected settlement tx when a trigger was published to the chain
    public Transaction getLastSettleTx (in Hash chan_id);
}

///
public class ControlFlashNode : FlashNode, TestFlashAPI
{
    // TODO: move to base class?
    /// secret hash => incoming HTLC.
    /// These can be spent by us if we receive the secret,
    /// or they can be spent by the sender after a time-lock expires.
    //private Script[Hash] incoming_htlcs;

    // TODO: move to base class?
    /// secret hash => outgoing HTLC
    /// These can be spent by us after a time-lock expires,
    /// or we remove it if we get the secret fo the associated incoming HTLC.
    //private Script[Hash] outgoing_htlcs;

    // TODO: move to base class?
    /// hash of secret => Invoice
    private Invoice[Hash] invoices;

    ///
    protected Registry* agora_registry;

    ///
    protected Registry* flash_registry;

    ///
    public this (const Pair kp, Registry* agora_registry,
        string agora_address, Registry* flash_registry)
    {
        this.agora_registry = agora_registry;
        this.flash_registry = flash_registry;
        const genesis_hash = hashFull(GenesisBlock);
        super(kp, genesis_hash, new LocalRestTaskManager(), agora_address);
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
    protected override ControlFlashAPI getFlashClient (in Point peer_pk,
        Duration timeout)
    {
        if (auto peer = peer_pk in this.known_peers)
        {
            auto control_api = cast(ControlFlashAPI)*peer;
            assert(control_api !is null);  // something's wrong
            return control_api;
        }

        auto tid = this.flash_registry.locate(peer_pk.to!string);
        assert(tid != typeof(tid).init, "Flash node not initialized");

        auto peer = new RemoteAPI!ControlFlashAPI(tid, timeout);
        this.known_peers[peer_pk] = peer;
        peer.gossipChannelsOpen(this.known_channels.values);

        return peer;
    }

    ///
    public override void start ()
    {
        super.startMonitoring();
    }

    ///
    public override Invoice createNewInvoice (in Amount amount,
        in time_t expiry, in string description = null)
    {
        writefln("%s: createNewInvoice(%s, %s, %s)", this.kp.V.prettify,
            amount, expiry, description);

        auto pair = createInvoice(this.kp.V, amount, expiry, description);
        this.invoices[pair.invoice.payment_hash] = pair.invoice;
        this.secrets[pair.invoice.payment_hash] = pair.secret;

        return pair.invoice;
    }

    ///
    public override void waitChannelOpen (in Hash chan_id)
    {
        auto channel = chan_id in this.channels;
        assert(channel !is null);

        const state = channel.getState();
        if (state >= ChannelState.PendingClose)
        {
            writefln("%s: Error: waitChannelOpen(%s) called on channel state %s",
                this.kp.V.prettify, chan_id.prettify, state);
            return;
        }

        while (!channel.isOpen())
            this.taskman.wait(500.msecs);
    }

    ///
    public override Hash openNewChannel (in Hash funding_utxo,
        in Amount capacity, in uint settle_time, in Point peer_pk)
    {
        writefln("%s: openNewChannel(%s, %s, %s)", this.kp.V.prettify,
            capacity, settle_time, peer_pk.prettify);

        // todo: move to initialization stage!
        auto peer = this.getFlashClient(peer_pk, Duration.init);
        const pair_pk = this.kp.V + peer_pk;

        // create funding, don't sign it yet as we'll share it first
        auto funding_tx = createFundingTx(funding_utxo, capacity,
            pair_pk);

        const funding_tx_hash = hashFull(funding_tx);
        const Hash chan_id = funding_tx_hash;
        const num_peers = 2;

        const ChannelConfig chan_conf =
        {
            gen_hash        : hashFull(GenesisBlock),
            funder_pk       : this.kp.V,
            peer_pk         : peer_pk,
            pair_pk         : this.kp.V + peer_pk,
            num_peers       : num_peers,
            update_pair_pk  : getUpdatePk(pair_pk, funding_tx_hash, num_peers),
            funding_tx      : funding_tx,
            funding_tx_hash : funding_tx_hash,
            funding_utxo    : UTXO.getHash(funding_tx.hashFull(), 0),
            capacity        : capacity,
            settle_time     : settle_time,
        };

        PrivateNonce priv_nonce = genPrivateNonce();
        PublicNonce pub_nonce = priv_nonce.getPublicNonce();

        auto result = peer.openChannel(chan_conf, pub_nonce);
        assert(result.error == ErrorCode.None, result.to!string);

        auto channel = new Channel(chan_conf, this.kp, priv_nonce, result.value,
            peer, this.engine, this.taskman, &this.agora_node.putTransaction,
            &this.paymentRouter, &this.onChannelOpen, &this.onPaymentComplete,
            &this.onUpdateComplete);
        this.channels[chan_id] = channel;

        return chan_id;
    }

    ///
    public override void beginCollaborativeClose (in Hash chan_id)
    {
        auto channel = chan_id in this.channels;
        assert(channel !is null);
        channel.beginCollaborativeClose();
    }

    // total_amount will take into account the fees
    public OnionPacket createOnionPacket (in Hash payment_hash,
        in Height lock_height, in Amount amount, in Hop[] path,
        out Amount total_amount)
    {
        assert(path.length >= 1);

        // todo: setting fees should be part of the routing algorithm
        total_amount = amount;
        foreach (hop; path)
        {
            if (!total_amount.add(hop.fee))
                assert(0);
        }

        Amount forward_amount = total_amount;
        Height outgoing_lock_height = lock_height;
        OnionPacket packet;
        Hash next_chan_id;

        // onion packets have to be created from the inside-out
        auto range = path.retro;
        foreach (hop; range)
        {
            Payload payload =
            {
                next_chan_id : next_chan_id,
                forward_amount : forward_amount,
                outgoing_lock_height : outgoing_lock_height,
                next_packet : packet,
            };

            Pair ephemeral_kp = Pair.random();
            auto encrypted_payload = encryptPayload(payload, ephemeral_kp,
                hop.pub_key);

            OnionPacket new_packet =
            {
                version_byte : 0,
                ephemeral_pk : ephemeral_kp.V,
                encrypted_payload : encrypted_payload,
                hmac : Hash.init,
            };

            packet = new_packet;

            if (!forward_amount.sub(hop.fee))
                assert(0);

            // todo: use htlc_delta config here from the channel config
            assert(outgoing_lock_height != 0);
            outgoing_lock_height = Height(outgoing_lock_height - 1);

            next_chan_id = hop.chan_id;
        }

        return packet;
    }

    ///
    private bool isValidInvoice (in Invoice invoice)
    {
        // paying to ourself doesn't make sense
        if (invoice.destination == this.kp.V)
            return false;

        return true;
    }

    /// Finds a payment path for the invoice and attempts to pay it
    public override void payInvoice (in Invoice invoice)
    {
        if (!this.isValidInvoice(invoice))
            assert(0);  // todo: should just reject it when we write test for it

        // todo: should not be hardcoded.
        // todo: isn't the payee supposed to set this?
        Height lock_height = Height(this.last_block_height + 100);

        // find a route
        // todo: not implemented properly yet as capacity, individual balances, and
        // fees are not taken into account yet. Only up to two channels assumed here.
        auto path = this.network.getPaymentPath(this.kp.V, invoice.destination,
            invoice.amount);
        Amount total_amount;
        auto packet = this.createOnionPacket(invoice.payment_hash, lock_height,
            invoice.amount, path, total_amount);

        writefln("%s Paying invoice and routing packet", this.kp.V.prettify);
        this.paymentRouter(path.front.chan_id, invoice.payment_hash,
            total_amount, lock_height, packet);
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
}

/// Is in charge of spawning the flash nodes
public class FlashNodeFactory
{
    /// Registry of nodes
    private Registry* agora_registry;

    /// we keep a separate LocalRest registry of the flash "nodes"
    private Registry flash_registry;

    /// list of flash addresses
    private Point[] addresses;

    /// list of flash nodes
    private RemoteAPI!TestFlashAPI[] nodes;

    /// Ctor
    public this (Registry* agora_registry)
    {
        this.agora_registry = agora_registry;
        this.flash_registry.initialize();
    }

    /// Create a new flash node user
    public RemoteAPI!TestFlashAPI create (const Pair pair, string agora_address)
    {
        RemoteAPI!TestFlashAPI api = RemoteAPI!TestFlashAPI.spawn!ControlFlashNode(pair,
            this.agora_registry, agora_address, &this.flash_registry);
        api.start();

        this.addresses ~= pair.V;
        this.nodes ~= api;
        this.flash_registry.register(pair.V.to!string, api.tid());

        return api;
    }

    /// Shut down all the nodes
    public void shutdown ()
    {
        foreach (address; this.addresses)
            enforce(this.flash_registry.unregister(address.to!string));

        foreach (node; this.nodes)
            node.ctrl.shutdown();
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

    const alice_pair = Pair.fromScalar(secretKeyToCurveScalar(WK.Keys[0].secret));
    const bob_pair = Pair.fromScalar(secretKeyToCurveScalar(WK.Keys[1].secret));

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

    /* do some off-chain transactions */
    auto inv_1 = bob.createNewInvoice(Amount(5_000), time_t.max, "payment 1");
    alice.payInvoice(inv_1);

    auto inv_2 = bob.createNewInvoice(Amount(1_000), time_t.max, "payment 2");
    alice.payInvoice(inv_2);

    // note the reverse payment from bob to alice. Can use this for refunds too.
    auto inv_3 = alice.createNewInvoice(Amount(2_000), time_t.max, "payment 3");
    bob.payInvoice(inv_3);

    // wait until the invoices are paid
    writefln("Sleeping for 5 seconds..");
    Thread.sleep(5.seconds);

    // alice is acting bad
    writefln("Alice unilaterally closing the channel..");
    auto update_tx = alice.getPublishUpdateIndex(chan_id, 0);
    network.expectBlock(Height(10), network.blocks[0].header);
    auto tx_10 = node_1.getBlocksFrom(10, 1)[0].txs[0];
    assert(tx_10 == update_tx);

    // at this point bob will automatically publish the latest update tx
    network.expectBlock(Height(11), network.blocks[0].header);

    // and then a settlement will be published (but only after time lock expires)
    auto settle_tx = bob.getLastSettleTx(chan_id);
    network.expectBlock(Height(12), network.blocks[0].header);
    auto tx_12 = node_1.getBlocksFrom(12, 1)[0].txs[0];
    assert(tx_12 == settle_tx);
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

    const alice_pair = Pair.fromScalar(secretKeyToCurveScalar(WK.Keys[0].secret));
    const bob_pair = Pair.fromScalar(secretKeyToCurveScalar(WK.Keys[1].secret));
    const charlie_pair = Pair.fromScalar(secretKeyToCurveScalar(WK.Keys[2].secret));

    const alice_pk = alice_pair.V;
    const bob_pk = bob_pair.V;
    const charlie_pk = charlie_pair.V;

    writefln("alice: %s", alice_pk.prettify);
    writefln("bob: %s", bob_pk.prettify);
    writefln("charlie: %s", charlie_pk.prettify);

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
    writefln("Alice bob channel ID: %s", alice_bob_chan_id);

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
    writefln("Bob Charlie channel ID: %s", bob_charlie_chan_id);

    // await bob & bob channel funding transaction
    network.expectBlock(Height(10), network.blocks[0].header);
    const block_10 = node_1.getBlocksFrom(10, 1)[$ - 1];
    assert(block_10.txs.any!(tx => tx.hashFull() == bob_charlie_chan_id));

    // wait for the parties to detect the funding tx
    bob.waitChannelOpen(bob_charlie_chan_id);
    charlie.waitChannelOpen(bob_charlie_chan_id);
    /+++++++++++++++++++++++++++++++++++++++++++++/

    // begin off-chain transactions
    auto inv_1 = charlie.createNewInvoice(Amount(5_000), time_t.max, "payment 1");

    // here we assume bob sent the invoice to alice through some means,
    // e.g. QR code. Alice scans it and proposes the payment.
    // it has a direct channel to bob so it uses it.
    alice.payInvoice(inv_1);

    // wait until the invoice is done (should payInvoice() be blocking?)
    writefln("Sleeping for 7 seconds..");
    Thread.sleep(7.seconds);

    //
    writefln("Beginning bob => charlie collaborative close..");
    bob.beginCollaborativeClose(bob_charlie_chan_id);
    network.expectBlock(Height(11), network.blocks[0].header);
    auto block11 = node_1.getBlocksFrom(11, 1)[0];
    writefln("bob closing tx: %s", bob.getClosingTx(bob_charlie_chan_id));
    assert(block11.txs[0] == bob.getClosingTx(bob_charlie_chan_id));

    writefln("Beginning alice => bob collaborative close..");
    alice.beginCollaborativeClose(alice_bob_chan_id);
    network.expectBlock(Height(12), network.blocks[0].header);
    auto block12 = node_1.getBlocksFrom(12, 1)[0];
    writefln("alice closing tx: %s", alice.getClosingTx(alice_bob_chan_id));
    assert(block12.txs[0] == alice.getClosingTx(alice_bob_chan_id));
}
