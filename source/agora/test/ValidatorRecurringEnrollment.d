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
    auto node_1 = nodes[0];

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = node_1.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    Transaction[] txs;

    void createAndExpectNewBlock (Height new_height)
    {
        // create enough tx's for a single block
        txs = blocks[new_height - 1].spendable().map!(txb => txb.sign()).array();

        // send it to one node
        txs.each!(tx => node_1.putTransaction(tx));

        network.expectHeightAndPreImg(new_height, blocks[0].header);

        // add next block
        blocks ~= node_1.getBlocksFrom(new_height, 1);
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
    auto node_1 = nodes[0];

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = node_1.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    Transaction[] txs;

    void createAndExpectNewBlock (Height new_height)
    {
        // create enough tx's for a single block
        txs = blocks[new_height - 1].spendable().map!(txb => txb.sign())
            .array();

        // send it to one node
        txs.each!(tx => node_1.putTransaction(tx));

        network.expectHeightAndPreImg(new_height, blocks[0].header);

        // add next block
        blocks ~= node_1.getBlocksFrom(new_height, 1);
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

/// node which will skip checkAndEnroll below given height
private class DelayedEnrollNode (Height enroll_at) : TestValidatorNode
{
    mixin ForwardCtor!();

    protected override Enrollment checkAndEnroll (Height height) @safe
    {
        if (height >= enroll_at)
            return super.checkAndEnroll(height);
        else
            return Enrollment.init;
    }
}

/// create a node that will skip enroll below given height
private class NodeManager : TestAPIManager
{
    ///
    public this (immutable(Block)[] blocks, TestConf test_conf, TimePoint genesis_start_time)
    {
        super(blocks, test_conf, genesis_start_time);
    }

    public override void createNewNode (Config conf,
        string file = __FILE__, int line = __LINE__)
    {
        auto node_idx = this.nodes.length;
        if (node_idx >= 4) // last two nodes
        {
            assert(conf.validator.enabled);
            if (node_idx == 4)
                this.addNewNode!(DelayedEnrollNode!(Height(19)))(conf, file, line);
            else
                this.addNewNode!(DelayedEnrollNode!(Height(20)))(conf, file, line);
        }
        else
        {
            super.createNewNode(conf, file, line);
        }
    }
}

// Some nodes are interrupted during their validator cycles, they should
// still manage to enroll when they are back online
unittest
{

    TestConf conf;
    conf.consensus.quorum_threshold = 66;
    auto network = makeTestNetwork!NodeManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = node_1.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    auto sleep_node_1 = nodes[$ - 1]; // node #5
    auto sleep_node_2 = nodes[$ - 2]; // node #4

    // Approach end of the cycle
    network.generateBlocks(Height(GenesisValidatorCycle - 3));

    // Make 2 nodes sleep (they will not enroll as they are also DelayedEnrollNodes)
    sleep_node_1.ctrl.sleep(60.seconds, true);
    sleep_node_2.ctrl.sleep(60.seconds, true);

    network.generateBlocks(iota(GenesisValidators - 2),
        Height(GenesisValidatorCycle - 1));

    // Wake up node #4 right before cycle ends
    sleep_node_2.ctrl.sleep(0.seconds);
    // Let it catch up
    network.expectHeightAndPreImg(only(GenesisValidators - 2), // node #4
        Height(GenesisValidatorCycle - 1), network.blocks[0].header);

    network.generateBlocks(iota(GenesisValidators - 1), // nodes #0 -> #4
        Height(GenesisValidatorCycle));

    blocks = node_1.getBlocksFrom(GenesisValidatorCycle, 1);
    auto enrolls1 = blocks[$ - 1].header.enrollments.length;

    assert(enrolls1 == GenesisValidators - 1);

    // Wake up node #5 to an expired cycle, it should immediately enroll
    sleep_node_1.ctrl.sleep(0.seconds);
    // Let the last node catch up
    network.expectHeightAndPreImg(only(GenesisValidators - 1), Height(GenesisValidatorCycle));

    network.generateBlocks(iota(GenesisValidators),
        Height(GenesisValidatorCycle + 1));

    blocks = node_1.getBlocksFrom(GenesisValidatorCycle + 1, 1);
    auto enrolls2 = blocks[$ - 1].header.enrollments.length;

    // Now the last node woken up is also enrolled
    assert(enrolls2 == 1);
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
