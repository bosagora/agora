/*******************************************************************************

    Tests for reaching consensus in multiple rounds instead of 1 round.
    In this test, we make nodes reject nominations for several rounds
    deliberately until one is accepted at a round R, where R could be arbitrarily
    high.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.MultiRoundConsensus;

version (unittest):

import agora.api.Validator;
import agora.common.Config;
import agora.common.Task;
import agora.consensus.data.Block;
import agora.consensus.data.Params;
import agora.consensus.EnrollmentManager;
import agora.consensus.protocol.Nominator;
import agora.common.crypto.Key;
import agora.common.Hash;
import agora.consensus.data.Transaction;
import agora.consensus.data.genesis.Test;
import agora.network.Clock;
import agora.network.NetworkManager;
import agora.node.Ledger;
import agora.test.Base;

import core.stdc.inttypes;
import core.stdc.time;
import core.thread;

import geod24.Registry;

import scpd.types.Stellar_types;
import scpd.types.Stellar_SCP;

/// ditto
unittest
{
    extern (C++) static class CustomNominator : TestNominator
    {
        // To see how many voting rounds are needed to reach consensus
        public __gshared int round_number;

    extern (D):

        mixin ForwardCtor!();

    extern (C++):

        ///
        public override uint64_t computeHashNode (uint64_t slot_idx,
            ref const(Value) prev, bool is_priority, int32_t round_num,
            ref const(NodeID) node_id) nothrow
        {
            this.round_number = round_num;
            return super.computeHashNode(slot_idx, prev, is_priority,
                round_num, node_id);
        }
    }

    static class CustomValidator : TestValidatorNode
    {
        mixin ForwardCtor!();

        ///
        protected override CustomNominator getNominator (
            Parameters!(TestValidatorNode.getNominator) args)
        {
            return new CustomNominator(
                this.params, this.config.validator.key_pair, args,
                this.config.node.data_dir,
                this.txs_to_nominate, this.test_start_time);
        }
    }

    static class CustomAPIManager : TestAPIManager
    {
        mixin ForwardCtor!();

        /// set base class
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 0)
            {
                auto time = new shared(time_t)(this.initial_time);
                auto api = RemoteAPI!TestAPI.spawn!CustomValidator(
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
        timeout : 5.seconds,
        quorum_threshold : 51
    };

    auto network = makeTestNetwork!CustomAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;
    auto validator = network.clients[0];

    // Make four of six validators stop responding for a while
    nodes.drop(1).take(4).each!(node => node.ctrl.sleep(conf.timeout, true));

    // Block 1 with multiple consensus rounds
    auto txs = genesisSpendable().map!(txb => txb.sign()).array();
    txs.each!(tx => validator.putTransaction(tx));

    network.expectBlock(Height(1), conf.timeout + 5.seconds);
    assert(CustomNominator.round_number >= 2,
        format("The validator's round number is %s. Expected: above %s",
            CustomNominator.round_number, 2));
}
