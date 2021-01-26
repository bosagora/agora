/*******************************************************************************

    Contains tests for the validators not revealing their pre-images.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.MissingPreImageDetection;

version (unittest):

import agora.common.crypto.Key;
import agora.common.Config;
import agora.common.Hash;
import agora.common.Serializer;
import agora.common.Task;
import agora.consensus.data.Block;
import agora.consensus.data.Params;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.protocol.Data;
import agora.network.Clock;
import agora.network.NetworkManager;
import agora.node.Ledger;
import agora.utils.Test;
import agora.test.Base;

import scpd.types.Utils;
import scpd.types.Stellar_SCP;

import core.stdc.stdint;
import core.stdc.time;
import core.thread;

import geod24.Registry;

/*******************************************************************************

    Verifies that the nodes have not generated a block at the given height.

    Params:
        clients = the nodes to be checked
        height = the unexpected block height

*******************************************************************************/

private void unexpectBlock (Clients)(Clients clients, Height height)
{
    foreach (_; 0 .. 10)
    {
        clients.each!(node => retryFor(
            node.getBlockHeight() < height, 1.seconds));
        Thread.sleep(1.seconds);
    }
}

private class MissingPreImageEM : EnrollmentManager
{
    ///
    public this (string db_path, KeyPair key_pair,
        immutable(ConsensusParams) params)
    {
        super(db_path, key_pair, params);
    }

    /// This does not reveal pre-images intentionally
    public override bool getNextPreimage (out PreImageInfo preimage,
        Height height) @safe
    {
        return false;
    }
}

private class NoPreImageVN : TestValidatorNode
{
    ///
    public this (Config config, Registry* reg, immutable(Block)[] blocks,
        in TestConf test_conf, shared(time_t)* cur_time)
    {
        super(config, reg, blocks, test_conf, cur_time);
    }

    protected override EnrollmentManager getEnrollmentManager ()
    {
        return new MissingPreImageEM(
            ":memory:", this.config.validator.key_pair, params);
    }
}

private class BadNominator : TestNominator
{
    /// Ctor
    public this (immutable(ConsensusParams) params, Clock clock,
        NetworkManager network, KeyPair key_pair, Ledger ledger,
        EnrollmentManager enroll_man, TaskManager taskman,
        string data_dir, ulong txs_to_nominate, ulong test_start_time)
    {
        super(params, clock, network, key_pair, ledger, enroll_man, taskman,
            data_dir, txs_to_nominate, test_start_time);
    }

extern (C++):

    public override ValidationLevel validateValue (uint64_t slot_idx,
        ref const(Value) value, bool nomination) nothrow
    {
        scope(failure) assert(0);
        ValidationLevel ret;
        () @trusted {
            auto data = deserializeFull!ConsensusData(value[]);
            data.missing_validators.length = 0;
            data.missing_validators ~= 2;
            auto next_value = data.serializeFull().toVec();
            ret = super.validateValue(slot_idx, next_value, nomination);
        }();

        return ret;
    }
}

private class BadNominatingVN : TestValidatorNode
{
    ///
    public this (Config config, Registry* reg, immutable(Block)[] blocks,
        in TestConf test_conf, shared(time_t)* cur_time)
    {
        super(config, reg, blocks, test_conf, cur_time);
    }

    ///
    protected override TestNominator getNominator (Clock clock,
        NetworkManager network, Ledger ledger, EnrollmentManager enroll_man,
        TaskManager taskman)
    {
        return new BadNominator(
            this.params, clock, network, this.config.validator.key_pair, ledger,
            enroll_man, taskman, this.config.node.data_dir,
            this.txs_to_nominate, this.test_start_time);
    }
}

/// Situation: There is a validator does not reveal a pre-image for
///     the height after next.
/// Expectation: The expected block has been generated.
unittest
{
    static class BadAPIManager : TestAPIManager
    {
        ///
        public this (immutable(Block)[] blocks, TestConf test_conf,
            time_t initial_time)
        {
            super(blocks, test_conf, initial_time);
        }

        ///
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 5)
            {
                auto time = new shared(time_t)(this.initial_time);
                auto api = RemoteAPI!TestAPI.spawn!NoPreImageVN(
                    conf, &this.reg, this.blocks, this.test_conf,
                    time, conf.node.timeout);
                this.reg.register(conf.node.address, api.tid());
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

    // discarded UTXOs (just to trigger block creation)
    auto txs = spendable[0 .. 8].map!(txb => txb.sign()).array;

    Thread.sleep(5.seconds);

    // block 1
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(1));
}

/// Situation: There is a validator does not reveal a pre-image for next
//      height and the information is contained in a `ConsensusData`. But
//      a bad nominator manipulates information about the missing preimage
//      validators.
/// Expectation: The expected block has been generated.
unittest
{
    static class BadNominatingAPIManager : TestAPIManager
    {
        ///
        public this (immutable(Block)[] blocks, TestConf test_conf,
            time_t initial_time)
        {
            super(blocks, test_conf, initial_time);
        }

        ///
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 0)
            {
                auto time = new shared(time_t)(this.initial_time);
                auto api = RemoteAPI!TestAPI.spawn!NoPreImageVN(
                    conf, &this.reg, this.blocks, this.test_conf,
                    time, conf.node.timeout);
                this.reg.register(conf.node.address, api.tid());
                this.nodes ~= NodePair(conf.node.address, api, time);
            }
            else if (this.nodes.length == 5)
            {
                auto time = new shared(time_t)(this.initial_time);
                auto api = RemoteAPI!TestAPI.spawn!BadNominatingVN(
                    conf, &this.reg, this.blocks, this.test_conf,
                    time, conf.node.timeout);
                this.reg.register(conf.node.address, api.tid());
                this.nodes ~= NodePair(conf.node.address, api, time);
            }
            else
                super.createNewNode(conf, file, line);
        }
    }

    TestConf conf = {
        recurring_enrollment : false,
    };
    auto network = makeTestNetwork!BadNominatingAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto spendable = network.blocks[$ - 1].spendable().array;

    // discarded UTXOs (just to trigger block creation)
    auto txs = spendable[0 .. 8].map!(txb => txb.sign()).array;

    Thread.sleep(5.seconds);

    // try to make block 1
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(1));
}
