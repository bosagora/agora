/*******************************************************************************

    Ensures validators re-enroll at the end of their validator cycle
    when configured to do so

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.ValidatorRecurringEnrollment;

import agora.test.Base;

import agora.consensus.data.Params;
import agora.consensus.protocol.Data;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.data.Block;
import agora.consensus.state.UTXODB;
import agora.consensus.EnrollmentManager;
import agora.consensus.Fee;
import agora.common.Hash;
import agora.common.Task;
import agora.common.Config;
import agora.common.Metadata;
import agora.common.crypto.Key;
import agora.network.NetworkManager;
import agora.network.Clock;
import agora.node.Ledger;
import geod24.Registry;
import core.stdc.time;

unittest
{
    TestConf conf = {
        quorum_threshold : 100
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = node_1.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    Transaction[] txs;

    void createAndExpectNewBlock (Height new_block_height)
    {
        // create enough tx's for a single block
        txs = blocks[new_block_height - 1].spendable().map!(txb => txb.sign()).array();

        // send it to one node
        txs.each!(tx => node_1.putTransaction(tx));

        network.expectBlock(new_block_height, blocks[0].header);

        // add next block
        blocks ~= node_1.getBlocksFrom(new_block_height, 1);
    }

    // create GenesisValidatorCycle - 1 blocks
    foreach (block_idx; 1 .. GenesisValidatorCycle)
    {
        createAndExpectNewBlock(Height(block_idx));
    }

    // Create one last block
    // if Validators don't re-enroll, this would fail
    createAndExpectNewBlock(Height(GenesisValidatorCycle));
    // Check if all validators in genesis are enrolled again
    assert(blocks[blocks.length - 1].header.enrollments.length == blocks[0].header.enrollments.length);
}

// Recurring enrollment with wrong `random_seed`
// When nodes reach the end of their validation cycle, they will try to
// re-enroll with the same commitment in the GenesisBlock (ie. Height(0))
// They should not be able to enroll and no new block should be created.
unittest
{
    import std.exception;
    import core.exception : AssertError;

    // Will always try to enroll with PreImage at Height(0)
    static class BadEnrollmentManager : EnrollmentManager
    {
        mixin ForwardCtor!();

        public override Enrollment createEnrollment ( in Hash utxo,
            Height height ) @safe nothrow
        {
            return super.createEnrollment(utxo, Height(0));
        }
    }

    static class BadValidator : TestValidatorNode
    {
        mixin ForwardCtor!();

        protected override EnrollmentManager getEnrollmentManager ()
        {
            return new BadEnrollmentManager(
                ":memory:", this.config.validator.key_pair, params);
        }
    }

    static class BadAPIManager : TestAPIManager
    {
        mixin ForwardCtor!();

        public override void createNewNode (Config conf, string file = __FILE__,
            int line = __LINE__)
        {
            if (conf.validator.enabled)
                this.addNewNode!BadValidator(conf, file, line);
            else
                this.addNewNode!TestFullNode(conf, file, line);
        }
    }

    TestConf conf = {
        quorum_threshold : 100
    };
    auto network = makeTestNetwork!BadAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = node_1.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    Transaction[] txs;

    void createAndExpectNewBlock (Height new_block_height)
    {
        // create enough tx's for a single block
        txs = blocks[new_block_height - 1].spendable().map!(txb => txb.sign())
            .array();

        // send it to one node
        txs.each!(tx => node_1.putTransaction(tx));

        network.expectBlock(new_block_height, blocks[0].header);

        // add next block
        blocks ~= node_1.getBlocksFrom(new_block_height, 1);
    }

    // create GenesisValidatorCycle - 1 blocks
    foreach (block_idx; 1 .. GenesisValidatorCycle)
    {
        createAndExpectNewBlock(Height(block_idx));
    }

    // Try creating one last block, should fail
    assertThrown!AssertError(createAndExpectNewBlock(
        Height(GenesisValidatorCycle)));
}

// Not all validators can enroll at the same height again. They should enroll
// in 2 subsequent blocks. Nodes that can't enroll in the first block should
// create another enrollment request for the next block
unittest
{
    static class SocialDistancingNominator : TestNominator
    {
        mixin ForwardCtor!();

        protected override bool prepareNominatingSet (out ConsensusData data) @safe
        {
            auto ret = super.prepareNominatingSet(data);
            if (data.enrolls.length > 3)
                data.enrolls.length = 3;
            return ret;
        }
    }

    static class SocialDistancingValidator : TestValidatorNode
    {
        mixin ForwardCtor!();

        ///
        protected override TestNominator getNominator (
            Parameters!(TestValidatorNode.getNominator) args)
        {
            return new SocialDistancingNominator(
                this.params, this.config.validator.key_pair, args,
                this.config.node.data_dir,
                this.txs_to_nominate, this.test_start_time);
        }

    }

    static class SocialDistancingAPIManager : TestAPIManager
    {
        mixin ForwardCtor!();

        public override void createNewNode (Config conf, string file = __FILE__,
            int line = __LINE__)
        {
            if (conf.validator.enabled)
                this.addNewNode!SocialDistancingValidator(conf, file, line);
            else
                this.addNewNode!TestFullNode(conf, file, line);
        }
    }

    TestConf conf = {
        quorum_threshold : 100
    };

    auto network = makeTestNetwork!SocialDistancingAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = node_1.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    network.generateBlocks(Height(GenesisValidatorCycle + 1));
    blocks = node_1.getBlocksFrom(10, GenesisValidatorCycle + 2);
    assert(blocks[$ - 1].header.height == Height(GenesisValidatorCycle + 1));
    assert(blocks[$ - 1].header.enrollments.length == 3);
    assert(blocks[$ - 2].header.enrollments.length == 3);
}

// Some nodes are interrupted during their validator cycles, they should
// still manage to enroll when they are back online
unittest
{
    TestConf conf = {
        quorum_threshold : 66
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = node_1.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    auto sleep_node_1 = nodes[$ - 1];
    auto sleep_node_2 = nodes[$ - 2];

    // Approach end of the cycle
    network.generateBlocks(Height(GenesisValidatorCycle - 2));

    // Make 2 nodes sleep
    sleep_node_1.ctrl.sleep(60.seconds, true);
    sleep_node_2.ctrl.sleep(60.seconds, true);

    network.generateBlocks(iota(GenesisValidators - 2),
        Height(GenesisValidatorCycle - 1));

    // Wake one up right before cycle ends
    sleep_node_2.ctrl.sleep(0.seconds);
    // Let it catch up
    network.expectBlock(iota(GenesisValidators - 1),
        Height(GenesisValidatorCycle - 1));

    network.generateBlocks(iota(GenesisValidators - 1),
        Height(GenesisValidatorCycle));

    blocks = node_1.getBlocksFrom(10, GenesisValidatorCycle + 3);
    auto enrolls1 = blocks[$ - 1].header.enrollments.length;

    // This nodes will wake up to an expired cycle, it should immediately enroll
    sleep_node_1.ctrl.sleep(0.seconds);
    // Let it catch up
    network.expectBlock(Height(GenesisValidatorCycle));

    network.generateBlocks(iota(GenesisValidators),
        Height(GenesisValidatorCycle + 1));

    blocks = node_1.getBlocksFrom(10, GenesisValidatorCycle + 3);
    auto enrolls2 = blocks[$ - 1].header.enrollments.length;

    // By now, all genesis validators should be enrolled again
    assert(enrolls1 + enrolls2 == GenesisValidators);
}

// No validator will willingly re-enroll until the network is stuck
unittest
{
    static class BatValidator : TestValidatorNode
    {
        mixin ForwardCtor!();

        protected override void invalidNominationHandler (const ref ConsensusData data,
            const ref string msg) @safe
        {
            // Unlike the regular validator, dont check the config. BatValidator
            // always answers a cry for help.
            if (msg == Ledger.InvalidConsensusDataReason.NotEnoughValidators)
                this.checkAndEnroll(this.ledger.getBlockHeight());
        }
    }

    static class GothamAPIManager : TestAPIManager
    {
        mixin ForwardCtor!();

        public override void createNewNode (Config conf, string file = __FILE__,
            int line = __LINE__)
        {
            if (conf.validator.enabled)
                this.addNewNode!BatValidator(conf, file, line);
            else
                this.addNewNode!TestFullNode(conf, file, line);
        }
    }

    TestConf conf = {
        quorum_threshold : 100,
        recurring_enrollment : false,
    };

    auto network = makeTestNetwork!GothamAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // Even if configured to not re-enroll, BatValidator should enroll if there
    // are not enough validators
    network.generateBlocks(Height(GenesisValidatorCycle + 1));
}
