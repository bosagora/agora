/*******************************************************************************

    Contains tests for the creation of an enrollment data, enrolling as a
    validator and propagating the information through the network

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.EnrollmentManager;

version (unittest):

import agora.common.Amount;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Params;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.validation.PreImage;
import agora.network.Clock;
import agora.test.Base;

import core.stdc.time;
import core.thread;
import core.time;

/// test for enrollment process & revealing a pre-image periodically
unittest
{
    TestConf conf = {
        recurring_enrollment : false,
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    // generate 19 blocks, 1 short of the enrollments expiring.
    network.generateBlocks(Height(GenesisValidatorCycle - 1));

    // wait for preimages to be revealed before making block 20
    network.waitForPreimages(network.blocks[0].header.enrollments,
        GenesisValidatorCycle - 1);

    // Re-enroll the Genesis validators
    iota(GenesisValidators).each!(idx => network.enroll(idx));

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
    auto network = makeTestNetwork(conf);
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.start();
    network.waitForDiscovery();

    // generate 15 blocks, 5 short of the enrollments expiring.
    network.generateBlocks(Height(GenesisValidatorCycle - 5));

    auto first_node = network.clients[0];

    // Request enrollment at the height of 15
    Enrollment enroll = first_node.createEnrollmentData();
    first_node.enrollValidator(enroll);

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
    TestConf conf = { recurring_enrollment : false };
    auto network = makeTestNetwork(conf);
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.start();
    network.waitForDiscovery();
    auto nodes = network.clients;

    // Sanity check: Check if genesis block has enrollments
    const b0 = nodes[0].getBlocksFrom(0, 2)[0];
    assert(b0.header.enrollments.length >= 1);

    // Make 19 blocks
    Transaction[] txs;
    foreach (count; 0 .. 19)
    {
        // Use Genesis
        if (!txs.length)
            txs = genesisSpendable().take(8).enumerate()
                .map!(en => en.value.refund(WK.Keys.A.address).sign())
                .array();
        else
            txs = txs
                .map!(ptx => TxBuilder(ptx).refund(WK.Keys[count].address).sign())
                .array();
        txs.each!(tx => nodes[1].putTransaction(tx));
        network.expectBlock(Height(count + 1), b0.header);
    }

    // Now create an Enrollment for nodes[0], create block #20, and restart nodes[0]
    auto enroll = nodes[0].createEnrollmentData();
    nodes[0].enrollValidator(enroll);
    txs = txs
        .map!(ptx => TxBuilder(ptx).refund(WK.Keys[20].address).sign())
        .array();
    txs.each!(tx => nodes[1].putTransaction(tx));
    network.expectBlock(iota(1), Height(GenesisValidatorCycle),
        b0.header);
    retryFor(nodes[0].getBlocksFrom(20, 1)[0].header.enrollments.length == 1,
        2.seconds);

    network.restart(nodes[0]);
    network.waitForDiscovery();
    network.expectBlock(iota(1), Height(20));

    // Now make a new block and make sure only nodes[0] signs it
    txs = txs
        .map!(ptx => TxBuilder(ptx).refund(WK.Keys[21].address).sign())
        .array();
    txs.each!(tx => nodes[1].putTransaction(tx));
    const b20 = nodes[0].getBlocksFrom(20, 2)[0];
    network.expectBlock(iota(1), Height(21), b20.header);

    PreImageInfo org_preimage = PreImageInfo(enroll.utxo_key, enroll.random_seed, 0);

    // Wait for the revelation of new pre-image to complete
    PreImageInfo preimage_2;
    retryFor(org_preimage != (preimage_2 = nodes[0].getPreimage(enroll.utxo_key)),
        10.seconds);

    // Check if a new pre-image has been revealed from the restarted node
    assert(preimage_2.isValid(org_preimage, GenesisValidatorCycle));
}

// Situation: A pre-image already known by all nodes is sent on the network
// Expectation: The new pre-image is rejected because it's already known
unittest
{
    import agora.common.Config;
    import geod24.Registry;

    /// A node that will assert if it gets more than 400 calls to
    /// `receivePreimage`.
    static final class TestNode : TestValidatorNode
    {
        private size_t count;

        ///
        public this (Config config, Registry* reg, immutable(Block)[] blocks,
            ulong txs_to_nominate, shared(time_t)* cur_time)
        {
            super(config, reg, blocks, txs_to_nominate, cur_time);
        }

        public override void receivePreimage (PreImageInfo preimage)
        {
            this.count++;
            assert(this.count < 100);
            super.receivePreimage(preimage);
        }
    }

    static final class BadAPIManager : TestAPIManager
    {
        ///
        public this (immutable(Block)[] blocks, TestConf test_conf, time_t initial_time)
        {
            super(blocks, test_conf, initial_time);
        }

        /// see base class
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 0)
            {
                auto time = new shared(time_t)(this.initial_time);
                assert(conf.validator.enabled);
                auto node = RemoteAPI!TestAPI.spawn!TestNode(
                    conf, &this.reg, this.blocks, this.test_conf.txs_to_nominate,
                    time, conf.node.timeout);
                this.reg.register(conf.node.address, node.ctrl.tid());
                this.nodes ~= NodePair(conf.node.address, node, time);
            }
            else
                super.createNewNode(conf, file, line);
        }
    }

    auto network = makeTestNetwork!BadAPIManager(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    const blocks = network.clients.front().getBlocksFrom(0, 1);
    assert(blocks.length == 1);
    assert(blocks[0].header.enrollments.length >= 1);
    const enroll = blocks[0].header.enrollments[0];

    const known_preimage = network.clients.front().getPreimage(enroll.utxo_key);
    assert(known_preimage.distance == 0);
    assert(known_preimage.hash == enroll.random_seed);
    // Send the same pre-image as received
    network.clients().front().receivePreimage(
        PreImageInfo(enroll.utxo_key, enroll.random_seed, 0));

    // Just to be sure, in case this unittest runs last
    Thread.sleep(50.msecs);

    assert(network.clients().each!(
        client => client.getPreimage(enroll.utxo_key).distance == 0));
}

/// Situation: One misbehaving node sends an Enrollment for an
///            already-enrolled validator.
/// Expectation: The nomination is rejected.
unittest
{
    import agora.common.Config;
    import agora.common.Task;
    import agora.common.crypto.Key;
    import agora.consensus.protocol.Nominator;
    import agora.consensus.protocol.Data;
    import agora.consensus.data.genesis.Test;
    import agora.node.Ledger;
    import agora.node.Validator;
    import agora.network.NetworkManager;

    import geod24.Registry;
    import core.atomic;

    static class BadNominator : TestNominator
    {
        private shared(size_t)* runCount;

        /// Ctor
        public this (immutable(ConsensusParams) params, Clock clock,
            NetworkManager network, KeyPair key_pair, Ledger ledger,
            TaskManager taskman, string data_dir, ulong txs_to_nominate,
            shared(time_t)* curr_time, shared(size_t)* countPtr)
        {
            this.runCount = countPtr;
            super(params, clock, network, key_pair, ledger, taskman,
                data_dir, txs_to_nominate);
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
        public this (Config config, Registry* reg, immutable(Block)[] blocks,
                     ulong txs_to_nominate, shared(time_t)* cur_time,
                     shared(size_t)* countPtr)
        {
            this.runCount = countPtr;
            super(config, reg, blocks, txs_to_nominate, cur_time);
        }

        ///
        protected override TestNominator getNominator (
            immutable(ConsensusParams) params, Clock clock,
            NetworkManager network, KeyPair key_pair, Ledger ledger,
            TaskManager taskman, string data_dir)
        {
            return new BadNominator(
                params, clock, network, key_pair, ledger, taskman,
                data_dir, this.txs_to_nominate, this.cur_time, this.runCount);
        }
    }

    static class BadAPIManager : TestAPIManager
    {
        // Make sure the code in BadNominator gets executed
        shared size_t runCount;

        ///
        public this (immutable(Block)[] blocks, TestConf test_conf, time_t initial_time)
        {
            super(blocks, test_conf, initial_time);
        }

        /// see base class
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 0)
            {
                auto time = new shared(time_t)(this.initial_time);
                auto api = RemoteAPI!TestAPI.spawn!MisbehavingValidator(
                    conf, &this.reg, this.blocks, this.test_conf.txs_to_nominate,
                    time, &this.runCount, conf.node.timeout);
                this.reg.register(conf.node.address, api.tid());
                this.nodes ~= NodePair(conf.node.address, api, time);
            }
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
        .each!(tx => validator.putTransaction(tx));
    network.waitForPreimages(b0.header.enrollments, 1);
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
    auto network = makeTestNetwork(conf);
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
    const org_preimage = PreImageInfo(e0.utxo_key, e0.random_seed, 0);
    PreImageInfo preimage_2;
    retryFor(org_preimage != (preimage_2 = nodes[0].getPreimage(e0.utxo_key)),
        15.seconds);
    assert(preimage_2 != PreImageInfo.init);
}
