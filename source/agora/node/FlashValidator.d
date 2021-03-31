/*******************************************************************************

    Implementation of the FlashValidator API.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.FlashValidator;

import agora.api.Validator;
import agora.common.Amount;
import agora.common.Config;
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
import agora.consensus.protocol.Data;
import agora.consensus.state.UTXOSet;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr;
import agora.flash.API;
import agora.flash.Config;
import agora.flash.ErrorCode;
import agora.flash.Invoice;
import agora.flash.Node;
import agora.flash.OnionPacket;
import agora.flash.Types;
import agora.network.Clock;
import agora.network.Manager;
import agora.node.admin.AdminInterface;
import agora.node.BlockStorage;
import agora.node.FlashFullNode;
import agora.node.FullNode;
import agora.node.Ledger;
import agora.node.Validator;
import agora.registry.API;
import agora.utils.Log;
import agora.utils.PrettyPrinter;
import agora.utils.Test;

import scpd.types.Stellar_SCP;

import vibe.data.json;
import vibe.web.rest;

import std.algorithm : each, map;
import std.exception;
import std.path : buildPath;
import std.range;

import core.stdc.stdlib : abort;
import core.stdc.time;
import core.time;

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
        const flash_path = buildPath(this.config.node.data_dir, "flash.dat");
        this.flash = new AgoraFlashNode(this.config.flash,
            flash_path, hashFull(this.params.Genesis), this.engine,
            this.taskman, this, &this.getFlashClient,
            &this.getFlashListenerClient);
    }

    public override void start ()
    {
        super.start();

        if (this.config.flash.testing)
            this.taskman.setTimer(0.seconds, &this.startFlashTest);
    }

    public override void shutdown ()
    {
        this.flash.shutdown();
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
        log.info("Running Alice tasks");

        auto keys = [WK.Keys.NODE2, WK.Keys.NODE3, WK.Keys.NODE4, WK.Keys.NODE5,
            WK.Keys.NODE6, WK.Keys.NODE7, WK.Keys.NODE7, WK.Keys.NODE7];

        auto txs = genesisSpendable().take(8).enumerate()
            .map!(en => en.value.refund(keys[en.index].address).sign())
            .array();

        while (this.network.getNetworkInfo().state != NetworkState.Complete)
            this.taskman.wait(20.msecs);

        log.info("Alice: Network state complete!");

        // wait for the preimages
        log.info("Alice: Waiting for preimages..");
        this.taskman.wait(3.seconds);

        // gossip them
        foreach (idx, tx; txs)
        {
            log.info("Alice: Gossiped: {}", idx);
            this.putTransaction(tx);
            while (this.ledger.getBlockHeight() != idx + 1)
                this.taskman.wait(20.msecs);
        }

        log.info("Reached block {}", this.ledger.getBlockHeight());

        const bob   = WK.Keys.NODE3;
        const Settle_1_Blocks = 0;

        const alice_utxo = UTXO.getHash(hashFull(txs[0]), 0);
        const res = this.flash.openNewChannel(
            alice_utxo, Amount(10_000), Settle_1_Blocks, bob.address);
        if (res.error != ErrorCode.None)
        {
            log.error("Cannot open channel with bob: {}", res);
            assert(0);
        }
        const alice_bob_chan_id = res.value;
        log.info("Alice bob channel: {}", alice_bob_chan_id);
        log.info("Alice bob channel ID: {}", alice_bob_chan_id);

        // await funding tx
        while (this.ledger.getBlockHeight() != 9)
            this.taskman.wait(20.msecs);

        // this should be instant as the ledger should have informed the
        // flash node that a block was externalized
        this.flash.waitChannelOpen(alice_bob_chan_id);

        // await invoice..
        log.info("Alice: Channel with Bob open!..");
    }

    private void aliceReceivesInvoice (Invoice invoice) @trusted
    {
        log.info("Alice: Received invoice: {}", invoice);

        log.info("Alice: Paying invoice..");
        this.flash.payInvoice(invoice);

        // todo: add fiber-blocking capability and await a signed update index
        // with the new HTLC.
        this.taskman.wait(4.seconds);
    }

    // intermediate channel
    private void runBobTasks ()
    {
        log.info("Running Bob tasks");

        while (this.network.getNetworkInfo().state != NetworkState.Complete)
            this.taskman.wait(20.msecs);

        log.info("Bob: Network state complete!");

        // wait for the preimages
        log.info("Bob: Waiting for preimages..");
        this.taskman.wait(3.seconds);

        // wait for channel funding block
        while (this.ledger.getBlockHeight() != 9)
            this.taskman.wait(20.msecs);

        // hardcoded for now..
        const alice_bob_chan_id = Hash.fromString("0x2b69840d0041fd482b466a5c6b23d35db9931506ec24477a842018ae42e76e9a1f153b3df24840a526d94713a93119a93c06942e7b941e55083627b8ab3a56f7");

        log.info("Bob: Waiting for channel open..");
        this.flash.waitChannelOpen(alice_bob_chan_id);

        log.info("Bob: Channel with Alice is open!..");

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
        const res = this.flash.openNewChannel(
            bob_utxo, Amount(3_000), Settle_1_Blocks, charlie_pk);
        if (res.error != ErrorCode.None)
        {
            log.error("Cannot open channel with charlie: {}", res);
            assert(0);
        }
        const bob_charlie_chan_id = res.value;
        log.info("Bob Charlie channel ID: {}", bob_charlie_chan_id);

        // await funding tx
        while (this.ledger.getBlockHeight() != 10)
            this.taskman.wait(20.msecs);

        // wait for the parties to detect the funding tx
        this.flash.waitChannelOpen(bob_charlie_chan_id);

        log.info("Bob: Channel with Charlie open!..");
        log.info("Charlie chan id: {}", bob_charlie_chan_id);
    }

    // destination channel
    private void runCharlieTasks ()
    {
        log.info("Running Charlie tasks");

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
        log.info("Charlie: Waiting for preimages..");
        this.taskman.wait(3.seconds);

        // hardcoded for now..
        const bob_charlie_chan_id = Hash.fromString("0x5f6f51639e089f3be4e97339f265167deb87c8331a135adb9d75f7b844cb49de768e9916edd60d2e86fce120cd9d524d43790e059d1d71fe51456a5ae2b4b9dc");

        log.info("Charlie: Waiting for channel open..");
        this.flash.waitChannelOpen(bob_charlie_chan_id);

        log.info("Charlie: Channel with Bob is open!..");

        // begin off-chain transactions
        auto inv_1 = this.flash.createNewInvoice(Amount(2_000), time_t.max,
            "payment 1");
        log.info("Charlie's invoice is: {}", inv_1);

        auto alice = this.getFlashClient(alice_pk, this.config.flash.timeout);

        log.info("Charlie: Sending invoice to {} ({}):", alice_pk, alice);
        alice.receiveInvoice(inv_1);

        // then use the extended flash API to send the invoice
    }

    mixin FlashNodeCommon!();
}
