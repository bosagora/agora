/*******************************************************************************

    Contains tests for the creation of an enrollment data, enrolling as a
    validator and propagating the information through the network

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.EnrollmentManager;

version (unittest):

import agora.common.Set;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.validation.PreImage;
import agora.test.Base;

import core.thread;

/// test for enrollment process & revealing a pre-image periodically
unittest
{
    TestConf conf = {
        recurring_enrollment : true,
    };
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    // generate 19 blocks, 1 short of the enrollments expiring.
    network.generateBlocks(Height(GenesisValidatorCycle - 1));

    // wait for preimages to be revealed before making block 20
    network.waitForPreimages(network.blocks[0].header.enrollments,
        Height(GenesisValidatorCycle));

    network.generateBlocks(iota(GenesisValidators),
        Height(GenesisValidatorCycle));

    // Make 3 more blocks in new cycle
    network.generateBlocks(iota(GenesisValidators),
        Height(GenesisValidatorCycle + 3));
}

// Test for re-enroll before the validator cycle ends
unittest
{
    import agora.consensus.data.genesis.Test;
    TestConf conf = {
        recurring_enrollment : false,
    };
    auto network = makeTestNetwork!TestAPIManager(conf);
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.start();
    network.waitForDiscovery();

    // generate 18 blocks, 2 short of the enrollments expiring.
    network.generateBlocks(Height(GenesisValidatorCycle - 2));

    auto first_node = network.clients[0];

    // Request enrollment at the height of 18
    auto enroll = first_node.setRecurringEnrollment(true);

    // Make 5 blocks in order to finish the validator cycle
    network.generateBlocks(Height(GenesisValidatorCycle));

    // Check if the enrollment has been added to the last block
    const b20 = first_node.getBlocksFrom(GenesisValidatorCycle, 1)[0];
    assert(b20.header.enrollments.length == 1);
    assert(b20.header.enrollments[0] == enroll);
}

/// Situation: A node in the network crashes after a new enrollment for the
///     node has been inserted into a new block with consensus. And the node
///     starts again
/// Expectation: The node restores its own enrollment from the chain and
///     reveals its pre-images periodically.
unittest
{
    auto network = makeTestNetwork!TestAPIManager(TestConf());
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.start();
    network.waitForDiscovery();
    auto nodes = network.clients;

    // Sanity check: Check if genesis block has enrollments
    const b0 = nodes[0].getBlocksFrom(0, 2)[0];
    assert(b0.header.enrollments.length >= 1);
    Hash node0_utxo = b0.header.enrollments[0].utxo_key;

    network.generateBlocks(Height(20));

    network.restart(nodes[0]);
    network.waitForDiscovery();
    const b20 = nodes[1].getBlocksFrom(20, 1)[0];
    assert(b20.header.enrollments[0].utxo_key >= node0_utxo);
    // Wait for node_0 to catch up
    network.expectHeightAndPreImg(Height(20), b0.header);

    PreImageInfo b20_preimage = PreImageInfo(node0_utxo, b20.header.enrollments[0].commitment, Height(20));

    retryFor(nodes[0].getPreimages(Set!Hash.from(node0_utxo.only))
        .any!(preimage => preimage.height > 20), 5.seconds);
    PreImageInfo preimage_26 = nodes[0].getPreimages(Set!Hash.from(node0_utxo.only))[0];

    // Check if the new pre-image is valid from the restarted node
    assert(preimage_26.isInvalidReason(b20_preimage) is null);
}

/// Situation: One misbehaving node sends an Enrollment for an
///            already-enrolled validator.
/// Expectation: The nomination is rejected.
unittest
{
    import agora.common.Task;
    import agora.consensus.protocol.Nominator;
    import agora.consensus.protocol.Data;
    import agora.consensus.data.genesis.Test;
    import agora.consensus.Ledger;
    import agora.node.Validator;

    import core.atomic;

    static class BadNominator : Nominator
    {
        private shared(size_t)* runCount;

        /// Ctor
        public this (Parameters!(Nominator.__ctor) args, shared(size_t)* countPtr)
        {
            super(args);
            this.runCount = countPtr;
        }

        ///
        protected override bool prepareNominatingSet (out ConsensusData data) @safe
        {
            if (super.prepareNominatingSet(data))
            {
                // This behavior is the only difference with a normal Validator:
                // It adds an enrollment that is already for a node in the ValidatorSet
                atomicOp!("+=")(*this.runCount, 1);
                data.enrolls ~= GenesisBlock.header.enrollments[0];
                return true;
            }

            return false;
        }
    }

    static class MisbehavingValidator : TestValidatorNode
    {
        private shared(size_t)* runCount;

        /// Ctor
        public this (Parameters!(TestValidatorNode.__ctor) args,
            shared(size_t)* countPtr)
        {
            this.runCount = countPtr;
            super(args);
        }

        ///
        protected override BadNominator makeNominator (
            Parameters!(TestValidatorNode.makeNominator) args)
        {
            return new BadNominator(
                this.params, this.config.validator.key_pair, args,
                this.cacheDB, this.config.validator.nomination_interval,
                &this.acceptBlock, this.runCount);
        }
    }

    static class BadAPIManager : TestAPIManager
    {
        // Make sure the code in BadNominator gets executed
        shared size_t runCount;

        mixin ForwardCtor!();

        /// see base class
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 0)
                this.addNewNode!MisbehavingValidator(conf, &this.runCount, file, line);
            else
                super.createNewNode(conf, file, line);
        }
    }

    auto network = makeTestNetwork!BadAPIManager(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto bad_validator = network.clients[0];
    auto validator = network.clients[1];

    // Sanity check: Check if genesis block has enrollments
    const b0 = validator.getBlocksFrom(0, 1)[0];
    assert(b0.header.enrollments.length >= 1);

    // Make a block using Genesis
    genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys.A.address).sign())
        .each!(tx => validator.postTransaction(tx));
    network.waitForPreimages(b0.header.enrollments, Height(1));
    network.setTimeFor(Height(1));  // trigger consensus

    // Make sure that the code in validator gets executed
    size_t loopCount;
    while (atomicLoad(network.runCount) < 1)
    {
        // That's at least 5 seconds
        assert(loopCount < 500);
        loopCount++;
        Thread.sleep(10.msecs);
    }

    // Ensure everyone is at the same level although there is a bad Validator
    network.assertSameBlocks(iota(GenesisValidators).drop(1), Height(1));
}

/// Situation: After the network starts, the Genesis block already has
///     enrollments and the validators must reveal their pre-images
/// Expectation: The validators reveal their pre-images timely and the
///     pre-images are shared in the network
unittest
{
    TestConf conf = TestConf.init;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // Check if the genesis block has enrollments
    auto nodes = network.clients;
    const b0 = nodes[0].getBlocksFrom(0, 1)[0];
    assert(b0.header.enrollments.length >= 1);
    const e0 = b0.header.enrollments[0];

    // Wait for the revelation of new pre-image to complete
    const org_preimage = PreImageInfo(e0.utxo_key, e0.commitment, Height(0));

    retryFor(nodes[0].getPreimages(Set!Hash.from(e0.utxo_key.only))
        .any!(preimage => org_preimage != preimage),
        15.seconds);
    assert(nodes[0].getPreimages(Set!Hash.from(e0.utxo_key.only))[0] != PreImageInfo.init);
}
