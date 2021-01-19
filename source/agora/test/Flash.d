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
import agora.common.Task;
import agora.consensus.data.genesis.Test;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXO;
import agora.flash.API;
import agora.flash.Channel;
import agora.flash.Config;
import agora.flash.ErrorCode;
import agora.flash.Node;
import agora.flash.Scripts;
import agora.flash.Types;
import agora.test.Base;

import geod24.Registry;

import std.conv;
import std.exception;

import core.thread;

/// In addition to the Flash API, we provide controller methods to initiate
/// the channel creation procedures and control each flash node's behavior.
public interface ControlAPI : FlashAPI
{
    /// start timers which monitor the blockchain for new relevant tx's
    public void ctrlStart();

    ///
    public void ctrlPublishUpdate (in Hash chan_id, in uint index);

    ///
    public void ctrlCollaborativeClose (in Hash chan_id);

    /// Open a channel with another flash node.
    public Hash ctrlOpenChannel (in Hash funding_hash, in Amount funding_amount,
        in uint settle_time, in Point peer_pk);

    ///
    public void ctrlWaitFunding (in Hash chan_id);

    ///
    public void ctrlUpdateBalance (in Hash chan_id, in Amount funder,
        in Amount peer);
}

public class ControlFlashNode : FlashNode, ControlAPI
{
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
    protected override FlashAPI getFlashClient (in Point peer_pk,
        Duration timeout)
    {
        auto tid = this.flash_registry.locate(peer_pk.to!string);
        assert(tid != typeof(tid).init, "Flash node not initialized");
        return new RemoteAPI!FlashAPI(tid, timeout);
    }

    ///
    public override void ctrlStart ()
    {
        super.startMonitoring();
    }

    ///
    public override void ctrlWaitFunding (in Hash chan_id)
    {
        auto channel = chan_id in this.channels;
        assert(channel !is null);

        while (!channel.isOpen())
            this.taskman.wait(500.msecs);
    }

    ///
    public override Hash ctrlOpenChannel (in Hash funding_utxo,
        in Amount funding_amount, in uint settle_time, in Point peer_pk)
    {
        writefln("%s: ctrlOpenChannel(%s, %s, %s)", this.kp.V.prettify,
            funding_amount, settle_time, peer_pk.prettify);

        // todo: move to initialization stage!
        auto peer = this.getFlashClient(peer_pk, Duration.init);
        const pair_pk = this.kp.V + peer_pk;

        // create funding, don't sign it yet as we'll share it first
        auto funding_tx = createFundingTx(funding_utxo, funding_amount,
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
            funding_amount  : funding_amount,
            settle_time     : settle_time,
        };

        PrivateNonce priv_nonce = genPrivateNonce();
        PublicNonce pub_nonce = priv_nonce.getPublicNonce();

        auto result = peer.openChannel(chan_conf, pub_nonce);
        assert(result.error == ErrorCode.None, result.to!string);

        auto channel = new Channel(chan_conf, this.kp, priv_nonce, result.value,
            peer, this.engine, this.taskman, &this.agora_node.putTransaction);
        this.channels[chan_id] = channel;

        return chan_id;
    }

    ///
    public override void ctrlPublishUpdate (in Hash chan_id, in uint index)
    {
        auto channel = chan_id in this.channels;
        assert(channel !is null);
        channel.ctrlPublishUpdate(index);
    }

    ///
    public override void ctrlCollaborativeClose (in Hash chan_id)
    {
        auto channel = chan_id in this.channels;
        assert(channel !is null);
        channel.beginCollaborativeClose();
    }

    ///
    public override void ctrlUpdateBalance (in Hash chan_id,
        in Amount funder_amount, in Amount peer_amount)
    {
        writefln("%s: ctrlUpdateBalance(%s, %s, %s)", this.kp.V.prettify,
            chan_id.prettify, funder_amount, peer_amount);

        auto channel = chan_id in this.channels;
        assert(channel !is null);

        // todo: we need to track this somewhere else
        static uint new_seq_id = 0;
        ++new_seq_id;

        PrivateNonce priv_nonce = genPrivateNonce();
        PublicNonce pub_nonce = priv_nonce.getPublicNonce();

        const Balance balance = Balance(
            [Output(funder_amount, PublicKey(channel.conf.funder_pk[])),
             Output(peer_amount, PublicKey(channel.conf.peer_pk[]))]);

        const BalanceRequest balance_req =
        {
            balance    : balance,
            peer_nonce : pub_nonce,
        };

        Result!PublicNonce result;
        while (1)
        {
            result = channel.peer.requestBalanceUpdate(chan_id, new_seq_id,
                balance_req);
            if (result.error == ErrorCode.SigningInProcess)
            {
                writefln("Signing not yet complete: %s. Waiting..",
                    result.message);
                this.taskman.wait(100.msecs);
                continue;
            }

            break;
        }

        assert(result.error == ErrorCode.None, result.to!string);
        channel.updateBalance(new_seq_id, priv_nonce, result.value, balance);
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
    private RemoteAPI!ControlAPI[] nodes;

    /// Ctor
    public this (Registry* agora_registry)
    {
        this.agora_registry = agora_registry;
        this.flash_registry.initialize();
    }

    /// Create a new flash node user
    public RemoteAPI!ControlAPI create (const Pair pair, string agora_address)
    {
        RemoteAPI!ControlAPI api = RemoteAPI!ControlAPI.spawn!ControlFlashNode(pair,
            this.agora_registry, agora_address, &this.flash_registry);
        api.ctrlStart();

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

/// Test collaborative close (funding + closing tx)
unittest
{
    TestConf conf = { txs_to_nominate : 1 };
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
    const chan_id = alice.ctrlOpenChannel(
        utxo, Amount(10_000), Settle_1_Blocks, bob_pair.V);

    // await funding transaction
    network.expectBlock(Height(9), network.blocks[0].header);
    const block_9 = node_1.getBlocksFrom(9, 1)[$ - 1];
    assert(block_9.txs.any!(tx => tx.hashFull() == chan_id));

    // wait for the parties to detect the funding tx
    alice.ctrlWaitFunding(chan_id);
    bob.ctrlWaitFunding(chan_id);

    /* do some off-chain transactions */

    // todo: this would error because it's overspending, re-add the test later
    // alice.ctrlUpdateBalance(chan_id, Amount(10_000), Amount(5_000));

    alice.ctrlUpdateBalance(chan_id, Amount(5_000),  Amount(5_000));
    alice.ctrlUpdateBalance(chan_id, Amount(4_000),  Amount(6_000));
    alice.ctrlUpdateBalance(chan_id, Amount(6_000),  Amount(4_000));

    //
    writefln("Beginning collaborative close..");
    alice.ctrlCollaborativeClose(chan_id);
    network.expectBlock(Height(10), network.blocks[0].header);
}

/// Test unilateral non-collaborative close (funding + update* + settle)
unittest
{
    TestConf conf = { txs_to_nominate : 1 };
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
    const chan_id = alice.ctrlOpenChannel(
        utxo, Amount(10_000), Settle_1_Blocks, bob_pair.V);

    // await funding transaction
    network.expectBlock(Height(9), network.blocks[0].header);
    const block_9 = node_1.getBlocksFrom(9, 1)[$ - 1];
    assert(block_9.txs.any!(tx => tx.hashFull() == chan_id));

    // wait for the parties to detect the funding tx
    alice.ctrlWaitFunding(chan_id);
    bob.ctrlWaitFunding(chan_id);

    /* do some off-chain transactions */

    // todo: this would error because it's overspending, re-add the test later
    // alice.ctrlUpdateBalance(chan_id, Amount(10_000), Amount(5_000));

    alice.ctrlUpdateBalance(chan_id, Amount(5_000),  Amount(5_000));
    alice.ctrlUpdateBalance(chan_id, Amount(4_000),  Amount(6_000));
    alice.ctrlUpdateBalance(chan_id, Amount(6_000),  Amount(4_000));

    // alice is bad
    writefln("Alice unilaterally closing the channel..");
    alice.ctrlPublishUpdate(chan_id, 0);
    network.expectBlock(Height(10), network.blocks[0].header);

    // at this point bob will automatically publish the latest update tx
    network.expectBlock(Height(11), network.blocks[0].header);

    // and then a settlement will be published (but only after time lock expires)
    network.expectBlock(Height(12), network.blocks[0].header);
}
