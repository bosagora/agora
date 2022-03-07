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

import agora.consensus.protocol.Data;
import agora.consensus.EnrollmentManager;
import agora.consensus.PreImage;
import agora.consensus.protocol.Nominator;
import agora.crypto.Hash;
import agora.consensus.Ledger;

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
            return new BadEnrollmentManager(this.stateDB, this.cacheDB,
                this.config.validator, this.params);
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

    network.generateBlocks(Height(GenesisValidatorCycle - 1), true);

    // Try creating one last block, should fail
    assertThrown!AssertError(
        network.generateBlocks(Height(GenesisValidatorCycle), true));
}

// Not all validators can enroll at the same height again. They should enroll
// in 2 subsequent blocks. Nodes that can't enroll in the first block should
// create another enrollment request for the next block
unittest
{
    import std.algorithm.mutation : reverse;
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
    conf.node.network_discovery_interval = 1.seconds;

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


    // TODO: remove pause
    import core.thread;
    Thread.sleep(5.seconds);

    network.generateBlocks(Height(GenesisValidatorCycle + 2), true);
    blocks = node_0.getBlocksFrom(10, GenesisValidatorCycle + 3);
    assert(blocks[$ - 1].header.height == Height(GenesisValidatorCycle + 2));
    auto last_enrolls = blocks.retro.take(3).map!(block => block.header.enrollments.length);
    assert(last_enrolls.sum() == 6);
    assert(!last_enrolls.any!(count => count > 3));
}

// Some nodes are interrupted during their validator cycles, they should
// still manage to enroll when they are back online
unittest
{
    TestConf conf;
    conf.consensus.quorum_threshold = 60; // quorum size will be 5 so we need to allow 3 / 5
    conf.node.max_retries = 2; // less retries as two are sleeping later
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_0 = nodes[0];

    assert(node_0.getQuorumConfig().threshold == 3);

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = node_0.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    auto node_4 = nodes[4];
    auto node_5 = nodes[5];

    // Approach end of the cycle
    network.generateBlocks(Height(GenesisValidatorCycle - 3), true);

    // Make 2 nodes sleep for longer than test can possibly run
    node_4.ctrl.sleep(1.hours, true);
    node_5.ctrl.sleep(1.hours, true);

    network.generateBlocks(iota(4),
        Height(GenesisValidatorCycle - 1), true);

    // Wake up node #4 right before cycle ends
    node_4.ctrl.sleep(0.seconds);
    // Let it catch up
    network.expectHeightAndPreImg(only(4), // node #4
        Height(GenesisValidatorCycle - 1), network.blocks[0].header);

    network.generateBlocks(iota(5), // nodes #0 .. #4
        Height(GenesisValidatorCycle), true);

    blocks = node_0.getBlocksFrom(10, GenesisValidatorCycle + 3);
    auto enrolls1 = blocks[$ - 1].header.enrollments.length;

    // Last node should not be enrolled yet
    assert(enrolls1 == GenesisValidators - 1);

    // Wake up node #5 to an expired cycle, it should immediately enroll
    node_5.ctrl.sleep(0.seconds);
    // Let node $5 catch up
    network.expectHeightAndPreImg(only(5), Height(GenesisValidatorCycle));

    network.generateBlocks(iota(GenesisValidators),
        Height(GenesisValidatorCycle + 1), true);

    blocks = node_0.getBlocksFrom(10, GenesisValidatorCycle + 3);
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
            if (msg == NodeLedger.InvalidConsensusDataReason.NotEnoughValidators)
                this.checkAndEnroll(this.ledger.height());
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
    network.generateBlocks(Height(GenesisValidatorCycle + 1), true);
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
    network.generateBlocks(Height(GenesisValidatorCycle - 1), true);

    // set the recurring enrollment option to true and check in enrollment pools
    network.validators.each!((node)
    {
        Enrollment enroll = node.setRecurringEnrollment(true);
        assert(enroll !is Enrollment.init);
        network.validators.each!(n =>
            retryFor(n.getEnrollment(enroll.utxo_key) == enroll, 5.seconds));
    });
    network.generateBlocks(Height(GenesisValidatorCycle), true);
    const b20 = network.clients[0].getBlocksFrom(GenesisValidatorCycle, 1)[0];
    assert(b20.header.enrollments.length == 6);
}
