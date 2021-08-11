/*******************************************************************************

    Ensures validators re-enroll at the end of their validator cycle
    when configured to do so

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.ValidatorRecurringEnrollment;

version (unittest):

import agora.test.Base;

import agora.common.Config;
import agora.consensus.protocol.Data;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.data.Block;
import agora.consensus.EnrollmentManager;
import agora.consensus.PreImage;
import agora.consensus.protocol.Nominator;
import agora.crypto.Hash;
import agora.consensus.Ledger;

unittest
{
    TestConf conf;
    conf.consensus.quorum_threshold = 100;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_0 = nodes[0];

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = node_0.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    Transaction[] txs;

    void createAndExpectNewBlock (Height new_height)
    {
        // create enough tx's for a single block
        txs = blocks[new_height - 1].spendable().map!(txb => txb.sign()).array();

        // send it to one node
        txs.each!(tx => node_0.putTransaction(tx));

        network.expectHeightAndPreImg(new_height, blocks[0].header);

        // add next block
        blocks ~= node_0.getBlocksFrom(new_height, 1);
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

// Recurring enrollment with wrong `commitment`
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

        public override Enrollment createEnrollment (
            in Hash utxo, in Height height) @safe nothrow
        {
            return super.createEnrollment(utxo, Height(0));
        }
    }

    static class BadValidator : TestValidatorNode
    {
        mixin ForwardCtor!();

        protected override EnrollmentManager makeEnrollmentManager ()
        {
            Hash cycle_seed;
            Height cycle_seed_height;
            getCycleSeed(this.config.validator.key_pair, params.ValidatorCycle,
                cycle_seed, cycle_seed_height);
            assert(cycle_seed != Hash.init);
            assert(cycle_seed_height != Height(0));
            auto cycle = PreImageCycle(cycle_seed, cycle_seed_height,
                this.params.ValidatorCycle);
            return new BadEnrollmentManager(this.stateDB, this.cacheDB,
                this.config.validator.key_pair, this.params, cycle);
        }
    }

    TestConf conf;
    conf.consensus.quorum_threshold = 100;
    auto network = makeTestNetwork!(TestNetwork!BadValidator)(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_0 = nodes[0];

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = node_0.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    Transaction[] txs;

    void createAndExpectNewBlock (Height new_height)
    {
        // create enough tx's for a single block
        txs = blocks[new_height - 1].spendable().map!(txb => txb.sign())
            .array();

        // send it to one node
        txs.each!(tx => node_0.putTransaction(tx));

        network.expectHeightAndPreImg(new_height, blocks[0].header);

        // add next block
        blocks ~= node_0.getBlocksFrom(new_height, 1);
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
    static class SocialDistancingNominator : Nominator
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
        protected override SocialDistancingNominator makeNominator (
            Parameters!(TestValidatorNode.makeNominator) args)
        {
            return new SocialDistancingNominator(
                this.params, this.config.validator.key_pair, args,
                this.cacheDB, this.config.validator.nomination_interval,
                &this.acceptBlock);
        }

    }

    TestConf conf;
    conf.consensus.quorum_threshold = 100;

    auto network = makeTestNetwork!(TestNetwork!SocialDistancingValidator)(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_0 = nodes[0];

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = node_0.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    network.generateBlocks(Height(GenesisValidatorCycle + 1));
    blocks = node_0.getBlocksFrom(10, GenesisValidatorCycle + 2);
    assert(blocks[$ - 1].header.height == Height(GenesisValidatorCycle + 1));
    assert(blocks[$ - 1].header.enrollments.length == 3);
    assert(blocks[$ - 2].header.enrollments.length == 3);
}

// Some nodes are interrupted during their validator cycles, they should
// still manage to enroll when they are back online
unittest
{
    TestConf conf;
    conf.consensus.quorum_threshold = 66;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_0 = nodes[0];

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = node_0.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    auto node_4 = nodes[4];
    auto node_5 = nodes[5];

    // Approach end of the cycle
    network.generateBlocks(Height(GenesisValidatorCycle - 2));

    // Make 2 nodes sleep
    node_4.ctrl.sleep(60.seconds, true);
    node_5.ctrl.sleep(60.seconds, true);

    network.generateBlocks(iota(4),
        Height(GenesisValidatorCycle - 1));

    // Wake up node #4 right before cycle ends
    node_4.ctrl.sleep(0.seconds);
    // Let it catch up
    network.expectHeightAndPreImg(only(4), // node #4
        Height(GenesisValidatorCycle - 1), network.blocks[0].header);

    network.generateBlocks(iota(5), // nodes #0 .. #4
        Height(GenesisValidatorCycle));

    blocks = node_0.getBlocksFrom(10, GenesisValidatorCycle + 3);
    auto enrolls1 = blocks[$ - 1].header.enrollments.length;

    // Wake up node #5 to an expired cycle, it should immediately enroll
    node_5.ctrl.sleep(0.seconds);
    // Let node $5 catch up
    network.expectHeight(only(5), Height(GenesisValidatorCycle));

    network.generateBlocks(iota(GenesisValidators),
        Height(GenesisValidatorCycle + 1));

    blocks = node_0.getBlocksFrom(10, GenesisValidatorCycle + 3);
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

        protected override void invalidNominationHandler (in ConsensusData data,
            in string msg) @safe
        {
            // Unlike the regular validator, dont check the config. BatValidator
            // always answers a cry for help.
            if (msg == Ledger.InvalidConsensusDataReason.NotEnoughValidators)
                this.checkAndEnroll(this.ledger.getBlockHeight());
        }
    }

    TestConf conf = {
        recurring_enrollment : false,
    };
    conf.consensus.quorum_threshold = 100;

    auto network = makeTestNetwork!(TestNetwork!BatValidator)(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // Even if configured to not re-enroll, BatValidator should enroll if there
    // are not enough validators
    network.generateBlocks(Height(GenesisValidatorCycle + 1));
}

// Make a validator recur enrollment in the middle of generating blocks
unittest
{
    TestConf conf = {
        recurring_enrollment : false,
    };
    auto network = makeTestNetwork!TestAPIManager(conf);
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.start();
    network.waitForDiscovery();

    // generate 19 blocks
    network.generateBlocks(Height(GenesisValidatorCycle - 1));

    // set the recurring enrollment option to true and check in enrollment pools
    network.clients.each!((node)
    {
        Enrollment enroll = node.setRecurringEnrollment(true);
        network.clients.each!(n =>
            retryFor(n.getEnrollment(enroll.utxo_key) == enroll, 5.seconds));
    });
    network.generateBlocks(Height(GenesisValidatorCycle));
    const b20 = network.clients[0].getBlocksFrom(GenesisValidatorCycle, 1)[0];
    assert(b20.header.enrollments.length == 6);
}
