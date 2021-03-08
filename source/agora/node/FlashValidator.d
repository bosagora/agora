/*******************************************************************************

    Implementation of the FlashValidator API.

    Copyright:
        Copyright (c) 2019 - 2021 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.FlashValidator;

import agora.api.Validator;
import agora.common.Amount;
import agora.common.Config;
import agora.common.crypto.Key;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Params;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.ValidatorBlockSig;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.protocol.Nominator;
import agora.consensus.Quorum;
import agora.consensus.state.UTXODB;
import agora.consensus.protocol.Data;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Schnorr;
import agora.flash.API;
import agora.flash.Config;
import agora.flash.Invoice;
import agora.flash.Node;
import agora.flash.OnionPacket;
import agora.flash.Types;
import agora.network.Clock;
import agora.network.Manager;
import agora.node.admin.AdminInterface;
import agora.node.BlockStorage;
import agora.node.FullNode;
import agora.node.Ledger;
import agora.node.Validator;
import agora.registry.API;
import agora.utils.Log;
import agora.utils.PrettyPrinter;
import agora.utils.Test;

import scpd.types.Stellar_SCP;

import std.algorithm : each, map;
import std.exception;
import std.range;
import std.stdio;

import core.stdc.stdlib : abort;
import core.stdc.time;
import core.time;

mixin AddLogger!();

///
public class FlashValidator : Validator, FlashValidatorAPI
{
    /// Flash node
    protected AgoraFlashNode flash;

    /***************************************************************************

        Constructor

        Params:
            config = Config instance

    ***************************************************************************/

    public this (const Config config)
    {
        super(config);
        assert(this.config.flash.enabled);
        assert(this.config.validator.enabled);

        immutable kp = Pair(this.config.validator.key_pair.secret,
            this.config.validator.key_pair.secret.toPoint);
        this.flash = new AgoraFlashNode(kp, hashFull(this.params.Genesis),
            this.taskman, this, &this.getFlashClient);
    }

    private ExtendedFlashAPI getFlashClient (in Point peer_pk, Duration timeout)
    {
        // todo: need to retry later
        // todo: need a key => IP mapping (maybe through the NameRegistryAPI?)
        auto pk = PublicKey(peer_pk[]);
        writefln("getFlashClient searching peer: %s", pk);
        auto ip = this.network.getAddress(pk);
        enforce(ip !is null, "Could not find mapping of key => IP");

        import vibe.http.client;

        import vibe.web.rest;
        auto settings = new RestInterfaceSettings;
        // todo: this is obviously wrong, need proper connection handling later
        settings.baseURL = URL(ip);
        settings.httpClientSettings = new HTTPClientSettings;
        settings.httpClientSettings.connectTimeout = timeout;
        settings.httpClientSettings.readTimeout = timeout;

        return new RestInterfaceClient!ExtendedFlashAPI(settings);
    }

    public override void start ()
    {
        super.start();

        if (this.config.flash.testing)
            this.taskman.setTimer(0.seconds, &this.startFlashTest);
    }

    public override void receiveInvoice (Invoice invoice)
    {
        if (this.config.validator.key_pair == WK.Keys.NODE2)
            this.aliceReceivesInvoice(invoice);
    }

    private void startFlashTest ()
    {
        enforce(this.ledger.getBlockHeight() == 0,
            "Test mode requires start with empty blockchain. Delete your cache!");

        if (this.config.validator.key_pair == WK.Keys.NODE2)
            this.runAliceTasks();
        else if (this.config.validator.key_pair == WK.Keys.NODE3)
            this.runBobTasks();
        else if (this.config.validator.key_pair == WK.Keys.NODE4)
            this.runCharlieTasks();
    }

    // in charge of creating initial funding tx's (for everyone),
    // and opening a channel with Bob.
    private void runAliceTasks ()
    {
        writeln("Running Alice tasks");

        auto keys = [WK.Keys.NODE2, WK.Keys.NODE3, WK.Keys.NODE4, WK.Keys.NODE5,
            WK.Keys.NODE6, WK.Keys.NODE7, WK.Keys.NODE7, WK.Keys.NODE7];

        auto txs = genesisSpendable().take(8).enumerate()
            .map!(en => en.value.refund(keys[en.index].address).sign())
            .array();

        while (this.network.getNetworkInfo().state != NetworkState.Complete)
            this.taskman.wait(20.msecs);

        writeln("Alice: Network state complete!");

        // wait for the preimages
        writeln("Alice: Waiting for preimages..");
        this.taskman.wait(3.seconds);

        // gossip them
        foreach (idx, tx; txs)
        {
            writefln("Alice: Gossiped: %s", idx);
            this.putTransaction(tx);
            while (this.ledger.getBlockHeight() != idx + 1)
                this.taskman.wait(20.msecs);
        }

        writefln("Reached block %s", this.ledger.getBlockHeight());

        const alice_pair = Pair(WK.Keys.NODE2.secret,
            WK.Keys.NODE2.secret.toPoint);
        const bob_pair = Pair(WK.Keys.NODE3.secret,
            WK.Keys.NODE3.secret.toPoint);
        const charlie_pair = Pair(WK.Keys.NODE4.secret,
            WK.Keys.NODE4.secret.toPoint);

        const alice_pk = alice_pair.V;
        const bob_pk = bob_pair.V;
        const charlie_pk = charlie_pair.V;

        const Settle_1_Blocks = 0;

        const alice_utxo = UTXO.getHash(hashFull(txs[0]), 0);
        const alice_bob_chan_id = this.flash.openNewChannel(
            alice_utxo, Amount(10_000), Settle_1_Blocks, bob_pk);
        writefln("Alice bob channel: %s", alice_bob_chan_id);
        writefln("Alice bob channel ID: %s", alice_bob_chan_id);

        // await funding tx
        while (this.ledger.getBlockHeight() != 9)
            this.taskman.wait(20.msecs);

        // this should be instant as the ledger should have informed the
        // flash node that a block was externalized
        this.flash.waitChannelOpen(alice_bob_chan_id);

        // await invoice..
        writeln("Alice: Channel with Bob open!..");
    }

    private void aliceReceivesInvoice (Invoice invoice) @trusted
    {
        writefln("Alice: Received invoice: %s", invoice);

        writeln("Alice: Paying invoice..");
        this.flash.payInvoice(invoice);

        // todo: add fiber-blocking capability and await a signed update index
        // with the new HTLC.
        this.taskman.wait(4.seconds);
    }

    // intermediate channel
    private void runBobTasks ()
    {
        writeln("Running Bob tasks");

        while (this.network.getNetworkInfo().state != NetworkState.Complete)
            this.taskman.wait(20.msecs);

        writeln("Bob: Network state complete!");

        // wait for the preimages
        writeln("Bob: Waiting for preimages..");
        this.taskman.wait(3.seconds);

        // wait for channel funding block
        while (this.ledger.getBlockHeight() != 9)
            this.taskman.wait(20.msecs);

        // hardcoded for now..
        const alice_bob_chan_id = Hash.fromString("0x2b69840d0041fd482b466a5c6b23d35db9931506ec24477a842018ae42e76e9a1f153b3df24840a526d94713a93119a93c06942e7b941e55083627b8ab3a56f7");

        writeln("Bob: Waiting for channel open..");
        this.flash.waitChannelOpen(alice_bob_chan_id);

        writeln("Bob: Channel with Alice is open!..");

        // used to get some funding tx's (first already used)
        auto keys = [WK.Keys.NODE2, WK.Keys.NODE3, WK.Keys.NODE4, WK.Keys.NODE5,
            WK.Keys.NODE6, WK.Keys.NODE7, WK.Keys.NODE7, WK.Keys.NODE7];

        auto txs = genesisSpendable().take(8).enumerate()
            .map!(en => en.value.refund(keys[en.index].address).sign())
            .array();

        const alice_pair = Pair(WK.Keys.NODE2.secret,
            WK.Keys.NODE2.secret.toPoint);
        const bob_pair = Pair(WK.Keys.NODE3.secret,
            WK.Keys.NODE3.secret.toPoint);
        const charlie_pair = Pair(WK.Keys.NODE4.secret,
            WK.Keys.NODE4.secret.toPoint);

        const alice_pk = alice_pair.V;
        const bob_pk = bob_pair.V;
        const charlie_pk = charlie_pair.V;

        const Settle_1_Blocks = 0;
        const bob_utxo = UTXO.getHash(hashFull(txs[1]), 0);
        const bob_charlie_chan_id = this.flash.openNewChannel(
            bob_utxo, Amount(3_000), Settle_1_Blocks, charlie_pk);
        writefln("Bob Charlie channel ID: %s", bob_charlie_chan_id);

        // await funding tx
        while (this.ledger.getBlockHeight() != 10)
            this.taskman.wait(20.msecs);

        // wait for the parties to detect the funding tx
        this.flash.waitChannelOpen(bob_charlie_chan_id);

        writeln("Bob: Channel with Charlie open!..");
        writeln("Charlie chan id: %s", bob_charlie_chan_id);
    }

    // destination channel
    private void runCharlieTasks ()
    {
        writeln("Running Charlie tasks");

        const alice_pair = Pair(WK.Keys.NODE2.secret,
            WK.Keys.NODE2.secret.toPoint);
        const bob_pair = Pair(WK.Keys.NODE3.secret,
            WK.Keys.NODE3.secret.toPoint);
        const charlie_pair = Pair(WK.Keys.NODE4.secret,
            WK.Keys.NODE4.secret.toPoint);

        const alice_pk = alice_pair.V;
        const bob_pk = bob_pair.V;
        const charlie_pk = charlie_pair.V;

        // await funding tx
        while (this.ledger.getBlockHeight() != 10)
            this.taskman.wait(20.msecs);

        // wait for the preimages
        writeln("Charlie: Waiting for preimages..");
        this.taskman.wait(3.seconds);

        // hardcoded for now..
        const bob_charlie_chan_id = Hash.fromString("0x5f6f51639e089f3be4e97339f265167deb87c8331a135adb9d75f7b844cb49de768e9916edd60d2e86fce120cd9d524d43790e059d1d71fe51456a5ae2b4b9dc");

        writeln("Charlie: Waiting for channel open..");
        this.flash.waitChannelOpen(bob_charlie_chan_id);

        writeln("Charlie: Channel with Bob is open!..");

        // begin off-chain transactions
        auto inv_1 = this.flash.createNewInvoice(Amount(2_000), time_t.max,
            "payment 1");
        writefln("Charlie's invoice is: %s", inv_1);

        Duration duration;
        auto alice = this.getFlashClient(alice_pk, duration);

        writefln("Charlie: Sending invoice to %s (%s):", alice_pk, alice);
        alice.receiveInvoice(inv_1);

        // then use the extended flash API to send the invoice
    }

    /***************************************************************************

        Called when a block was externalized.

        Calls pushBlock(), but additionally the Validator overrides this
        and implements quorum shuffling.

        Params:
            block = the new block
            validators_changed = whether the validator set has changed

    ***************************************************************************/

    protected override void onAcceptedBlock (in Block block,
        bool validators_changed) @safe
    {
        super.onAcceptedBlock(block, validators_changed);
        this.flash.onExternalizedBlock(block);
    }


    ///
    public override Result!PublicNonce openChannel (
        /* in */ ChannelConfig chan_conf,
        /* in */ PublicNonce peer_nonce) @trusted
    {
        return this.flash.openChannel(chan_conf, peer_nonce);
    }

    ///
    public override Result!Point closeChannel (/* in */ Hash chan_id,
        /* in */ uint seq_id, /* in */ Point peer_nonce, /* in */ Amount fee)
        @trusted
    {
        return this.flash.closeChannel(chan_id, seq_id, peer_nonce, fee);
    }

    ///
    public override void gossipChannelsOpen (ChannelConfig[] chan_configs)
        @trusted
    {
        this.flash.gossipChannelsOpen(chan_configs);
    }

    ///
    public override void gossipChannelUpdates (ChannelUpdate[] chan_updates)
        @trusted
    {
        this.flash.gossipChannelUpdates(chan_updates);
    }

    ///
    public override Result!ChannelState getChannelState (/* in */ Hash chan_id)
        @trusted
    {
        return this.flash.getChannelState(chan_id);
    }

    ///
    public override Result!PublicNonce proposePayment (/* in */ Hash chan_id,
        /* in */ uint seq_id, /* in */ Hash payment_hash,
        /* in */ Amount amount, /* in */ Height lock_height,
        /* in */ OnionPacket packet, /* in */ PublicNonce peer_nonce,
        /* in */ Height height) @trusted
    {
        return this.flash.proposePayment(chan_id, seq_id, payment_hash,
            amount, lock_height, packet, peer_nonce, height);
    }

    ///
    public override Result!PublicNonce proposeUpdate (/* in */ Hash chan_id,
        /* in */ uint seq_id, /* in */ Hash[] secrets,
        /* in */ Hash[] rev_htlcs, /* in */ PublicNonce peer_nonce,
        /* in */ Height block_height) @trusted
    {
        return this.flash.proposeUpdate(chan_id, seq_id, secrets, rev_htlcs,
            peer_nonce, block_height);
    }

    ///
    public override Result!Signature requestSettleSig (/* in */ Hash chan_id,
        /* in */ uint seq_id) @trusted
    {
        return this.flash.requestSettleSig(chan_id, seq_id);
    }

    ///
    public override Result!Signature requestUpdateSig (/* in */ Hash chan_id,
        /* in */ uint seq_id) @trusted
    {
        return this.flash.requestUpdateSig(chan_id, seq_id);
    }

    ///
    public override void confirmChannelUpdate (/* in */ Hash chan_id,
        /* in */ uint seq_id) @trusted
    {
        this.flash.confirmChannelUpdate(chan_id, seq_id);
    }

    ///
    public override Result!Signature requestCloseSig (/* in */ Hash chan_id,
        /* in */ uint seq_id) @trusted
    {
        return this.flash.requestCloseSig(chan_id, seq_id);
    }

    ///
    public override void reportPaymentError (/* in */ Hash chan_id,
        /* in */ OnionError err) @trusted
    {
        this.flash.reportPaymentError(chan_id, err);
    }
}
