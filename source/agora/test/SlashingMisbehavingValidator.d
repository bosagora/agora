/*******************************************************************************

    Contains tests for re-routing part of the frozen UTXO of a slashed
    validater to `CommonsBudget` address.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.SlashingMisbehavingValidator;

version (unittest):

import agora.common.crypto.Key;
import agora.common.Config;
import agora.consensus.data.Block;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.state.UTXODB;
import agora.network.NetworkManager;
import agora.utils.Test;
import agora.test.Base;

import core.stdc.stdint;
import core.thread;

import geod24.Registry;

// This derived `EnrollmentManager` does not reveal any preimages
// after enrollment.
private class MissingPreImageEM : EnrollmentManager
{
    private shared bool* reveal_preimage;

    mixin ForwardCtor!();

    ///
    public this (Parameters!(EnrollmentManager.__ctor) args,
        shared(bool)* reveal_preimage)
    {
        this.reveal_preimage = reveal_preimage;
        super(args);
    }

    /// This does not reveal pre-images intentionally
    public override bool getNextPreimage (out PreImageInfo preimage,
        Height height) @safe
    {
        assert(this.reveal_preimage != null);
        if (*this.reveal_preimage == false)
            return false;
        else
            return super.getNextPreimage(preimage, height);
    }
}

// This derived TestValidatorNode does not reveal any preimages using the
// `MissingPreImageEM` class
private class NoPreImageVN : TestValidatorNode
{
    public static shared UTXOSet utxo_set;
    private shared bool* reveal_preimage;

    mixin ForwardCtor!();

    ///
    public this (Parameters!(TestValidatorNode.__ctor) args,
        shared(bool)* reveal_preimage)
    {
        this.reveal_preimage = reveal_preimage;
        super(args);
    }

    protected override EnrollmentManager getEnrollmentManager ()
    {
        return new MissingPreImageEM(
            ":memory:", this.config.validator.key_pair, params,
            this.reveal_preimage);
    }

    protected override UTXOSet getUtxoSet()
    {
        this.utxo_set = cast(shared UTXOSet)super.getUtxoSet();
        return cast(UTXOSet)this.utxo_set;
    }
}

/// Situation: A misbehaving validator does not reveal its preimages right after
///     it's enrolled.
/// Expectation: The information about the validator is stored in a block.
///     The validator is un-enrolled and a part of its fund is refunded to the
///     validators with the 10K of the fund going to the `CommonsBudget` address.
unittest
{
    import agora.script.Lock;
    static class BadAPIManager : TestAPIManager
    {
        public static shared bool reveal_preimage = false;

        mixin ForwardCtor!();

        ///
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 5)
            {
                auto time = new shared(TimePoint)(this.initial_time);
                auto api = RemoteAPI!TestAPI.spawn!NoPreImageVN(
                    conf, &this.reg, &this.nreg, this.blocks, this.test_conf,
                    time, &reveal_preimage, conf.node.timeout);
                this.reg.register(conf.node.address, api.ctrl.listener());
                this.nodes ~= NodePair(conf.node.address, api, time);
            }
            else
                super.createNewNode(conf, file, line);
        }
    }

    TestConf conf = {
        recurring_enrollment : false,
    };
    auto network = makeTestNetwork!BadAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto spendable = network.blocks[$ - 1].spendable().array;
    auto utxo_set = cast(UTXOSet) NoPreImageVN.utxo_set;
    auto bad_address = nodes[5].getPublicKey();

    // discarded UTXOs (just to trigger block creation)
    auto txs = spendable[0 .. 8].map!(txb => txb.sign()).array;

    // wait for the preimage to be missed
    Thread.sleep(5.seconds);

    // block 1
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(1));

    auto frozen_hash = utxo_set.getUTXOs(bad_address).keys[0];
    auto frozen_utxo = utxo_set.getUTXOs(bad_address).values[0];
    UTXO utxo;
    utxo_set.peekUTXO(frozen_hash, utxo);
    assert(utxo.type == TxType.Freeze);

    // block 2
    txs = txs.map!(tx => TxBuilder(tx).sign()).array();
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(2));
    auto block2 = nodes[0].getBlocksFrom(2, 1)[0];
    assert(block2.header.missing_validators.length == 1);
    assert(nodes[0].getValidatorCount() == 5,
        format!"Invalid validator count, current: %s"(nodes[0].getValidatorCount()));

    // check if the frozen UTXO is refunded to the owner and
    // the penalty is re-routed to the `CommonsBudget`
    utxo_set.peekUTXO(frozen_hash, utxo);
    assert(utxo == UTXO.init);
    auto slashed_utxo = utxo_set.getUTXOs(bad_address).values[0];
    auto common_utxo = utxo_set.getUTXOs(WK.Keys.CommonsBudget.address).values[0];
    auto slashed_amout = slashed_utxo.output.value;
    slashed_amout.add(common_utxo.output.value);
    assert(frozen_utxo.output.value == slashed_amout);

    // check the leftover UTXO is melting and the penalty UTXO is unfrozen
    assert(slashed_utxo.unlock_height == 2018);
    assert(common_utxo.unlock_height == 3);
}

/// Situation: All the validators do not reveal their pre-images for
///     some time in the middle of creating the block of height 2 and
///     then start revealing their pre-images.
/// Expectation: The block of height 2 is created in the end after
///     some failures.
unittest
{
    static class LazyAPIManager : TestAPIManager
    {
        public static shared bool reveal_preimage = false;

        ///
        public this (immutable(Block)[] blocks, TestConf test_conf,
            TimePoint initial_time)
        {
            super(blocks, test_conf, initial_time);
        }

        ///
        public override void createNewNode (Config conf, string file, int line)
        {
            if (conf.validator.enabled == true)
            {
                auto time = new shared(TimePoint)(this.initial_time);
                auto api = RemoteAPI!TestAPI.spawn!NoPreImageVN(
                    conf, &this.reg, &this.nreg, this.blocks, this.test_conf,
                    time, &reveal_preimage, conf.node.timeout);
                this.reg.register(conf.node.address, api.ctrl.listener());
                this.nodes ~= NodePair(conf.node.address, api, time);
            }
            else
                super.createNewNode(conf, file, line);
        }
    }

    TestConf conf = {
        recurring_enrollment : false,
    };
    auto network = makeTestNetwork!LazyAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;
    auto txs = network.blocks[$ - 1].spendable().map!(txb => txb.sign()).array;

    // block 1
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(1));

    // block 2 must not be created because all the validators do not
    // reveal any pre-images after their enrollments.
    txs = txs.map!(tx => TxBuilder(tx).sign()).array();
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(1));

    // all the validators start revealing pre-images
    LazyAPIManager.reveal_preimage = true;

    // block 2 created with no slashed validator
    network.expectBlock(Height(2));
    auto block2 = nodes[0].getBlocksFrom(2, 1)[0];
    assert(block2.header.missing_validators.length == 0);
}
