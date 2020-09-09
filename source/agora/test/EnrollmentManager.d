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
import agora.consensus.data.ConsensusParams;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.validation.PreImage;
import agora.test.Base;

import core.thread;
import core.time;

/// test for enrollment process & revealing a pre-image periodically
unittest
{
    // generate 9 blocks, 1 short of the enrollments expiring.
    immutable validator_cycle = 10;
    TestConf conf = {
        validator_cycle : validator_cycle,
        extra_blocks : validator_cycle - 1,
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    network.expectBlock(Height(validator_cycle - 1), 2.seconds);

    // wait for preimages to be revealed before making block 10
    nodes.each!(node =>
        network.blocks[0].header.enrollments.each!(enroll =>
            retryFor(node.getPreimage(enroll.utxo_key).distance >= 9,
                5.seconds)));

    // create enrollment data
    // send a request to enroll as a Validator
    Enrollment enroll_0 = nodes[0].createEnrollmentData();
    Enrollment enroll_1 = nodes[1].createEnrollmentData();
    Enrollment enroll_2 = nodes[2].createEnrollmentData();
    Enrollment enroll_3 = nodes[3].createEnrollmentData();
    nodes[0].enrollValidator(enroll_1);
    nodes[1].enrollValidator(enroll_2);
    nodes[2].enrollValidator(enroll_3);
    nodes[3].enrollValidator(enroll_0);

    // wait until new enrollments are propagated to the pools
    nodes.each!(node =>
        retryFor(node.getEnrollment(enroll_0.utxo_key) == enroll_0 &&
                 node.getEnrollment(enroll_1.utxo_key) == enroll_1 &&
                 node.getEnrollment(enroll_2.utxo_key) == enroll_2 &&
                 node.getEnrollment(enroll_3.utxo_key) == enroll_3,
            5.seconds));

    // re-enroll every validator
    auto txs = network.blocks[$ - 1].spendable().map!(txb => txb.sign()).array();
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(validator_cycle), 2.seconds);

    // wait until preimages are revealed before creating a new block
    nodes.each!(node =>
        retryFor(node.getPreimage(enroll_0.utxo_key).distance >= 1 &&
                 node.getPreimage(enroll_1.utxo_key).distance >= 1 &&
                 node.getPreimage(enroll_2.utxo_key).distance >= 1 &&
                 node.getPreimage(enroll_3.utxo_key).distance >= 1,
            5.seconds));

    // verify that consensus can still be reached
    txs = txs.map!(tx => TxBuilder(tx).sign()).array();
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(validator_cycle + 1), 2.seconds);
}

// Test for re-enroll before the validator cycle ends
unittest
{
    immutable validator_cycle = 20;
    immutable current_height = validator_cycle - 5;
    TestConf conf = {
        validator_cycle : validator_cycle,
        extra_blocks : current_height,
    };
    auto network = makeTestNetwork(conf);
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.start();
    network.waitForDiscovery();

    // Check if the genesis block has enrollments
    auto nodes = network.clients;
    const b0 = nodes[0].getBlocksFrom(0, 2)[0];
    assert(b0.header.enrollments.length >= 1);

    // Request enrollment at the height of 15
    Enrollment enroll = nodes[0].createEnrollmentData();
    nodes[0].enrollValidator(enroll);

    // Make 5 blocks in order to finish the validator cycle
    const(Transaction)[] prev_txs = network.blocks[$ - 1].txs;
    foreach (height; current_height .. validator_cycle)
    {
        auto txs = prev_txs.map!(tx => TxBuilder(tx).sign()).array();
        txs.each!(tx => nodes[0].putTransaction(tx));
        network.expectBlock(Height(height + 1), 2.seconds);
        prev_txs = txs;
    }

    // Check if the enrollment has been added to the last block
    const b20 = nodes[0].getBlocksFrom(validator_cycle, 2)[0];
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
    // Boilerplate
    const validator_cycle = 20;
    TestConf conf = {
        validator_cycle : validator_cycle,
    };
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
        network.expectBlock(Height(count + 1), 3.seconds);
    }

    // Now create an Enrollment for nodes[0], create block #20, and restart nodes[0]
    auto enroll = nodes[0].createEnrollmentData();
    nodes[0].enrollValidator(enroll);
    txs = txs
        .map!(ptx => TxBuilder(ptx).refund(WK.Keys[20].address).sign())
        .array();
    txs.each!(tx => nodes[1].putTransaction(tx));
    network.expectBlock(nodes.take(1), Height(validator_cycle), 3.seconds);
    retryFor(nodes[0].getBlocksFrom(20, 1)[0].header.enrollments.length == 1,
        2.seconds);

    network.restart(nodes[0]);
    network.waitForDiscovery();
    network.expectBlock(nodes.take(1), Height(20), 10.seconds);

    // Now make a new block and make sure only nodes[0] signs it
    txs = txs
        .map!(ptx => TxBuilder(ptx).refund(WK.Keys[21].address).sign())
        .array();
    txs.each!(tx => nodes[1].putTransaction(tx));
    network.expectBlock(nodes.take(1), Height(21), 3.seconds);

    PreImageInfo org_preimage = PreImageInfo(enroll.utxo_key, enroll.random_seed, 0);

    // Wait for the revelation of new pre-image to complete
    PreImageInfo preimage_2;
    retryFor(org_preimage != (preimage_2 = nodes[0].getPreimage(enroll.utxo_key)),
        10.seconds);

    // Check if a new pre-image has been revealed from the restarted node
    assert(preimage_2.isValid(org_preimage, validator_cycle));
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
            ulong txs_to_nominate)
        {
            super(config, reg, blocks, txs_to_nominate);
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
        public this (immutable(Block)[] blocks, TestConf test_conf)
        {
            super(blocks, test_conf);
        }

        /// see base class
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 0)
            {
                assert(conf.node.is_validator);
                auto node = RemoteAPI!TestAPI.spawn!TestNode(
                    conf, &this.reg, this.blocks, this.test_conf.txs_to_nominate,
                    conf.node.timeout);
                this.reg.register(conf.node.address, node.ctrl.tid());
                this.nodes ~= NodePair(conf.node.address, node);
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
    import agora.consensus.data.ConsensusData;
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
        public this (NetworkManager network, KeyPair key_pair, Ledger ledger,
            TaskManager taskman, ulong txs_to_nominate, shared(size_t)* countPtr)
        {
            this.runCount = countPtr;
            super(network, key_pair, ledger, taskman, txs_to_nominate);
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
                     ulong txs_to_nominate, shared(size_t)* countPtr)
        {
            this.runCount = countPtr;
            super(config, reg, blocks, txs_to_nominate);
        }

        ///
        protected override TestNominator getNominator (
            NetworkManager network, KeyPair key_pair, Ledger ledger,
            TaskManager taskman)
        {
            return new BadNominator(
                network, key_pair, ledger, taskman, this.txs_to_nominate,
                this.runCount);
        }
    }

    static class BadAPIManager : TestAPIManager
    {
        // Make sure the code in BadNominator gets executed
        shared size_t runCount;

        ///
        public this (immutable(Block)[] blocks, TestConf test_conf)
        {
            super(blocks, test_conf);
        }

        /// see base class
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 0)
            {
                auto api = RemoteAPI!TestAPI.spawn!MisbehavingValidator(
                    conf, &this.reg, this.blocks, this.test_conf.txs_to_nominate,
                    &this.runCount, conf.node.timeout);
                this.reg.register(conf.node.address, api.tid());
                this.nodes ~= NodePair(conf.node.address, api);
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
    const b0 = validator.getBlocksFrom(0, 2)[0];
    assert(b0.header.enrollments.length >= 1);

    // Make a block using Genesis
    Transaction[] txs = genesisSpendable().take(8).enumerate()
        .map!(en => en.value.refund(WK.Keys.A.address).sign())
        .array();
    txs.each!(tx => validator.putTransaction(tx));

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
    ensureConsistency(network.clients, 1);
}

/// Situation: After the network starts, the Genesis block already has
///     enrollments and the validators must reveal their pre-images
/// Expectation: The validators reveal their pre-images timely and the
///     pre-images are shared in the network
unittest
{
    TestConf conf = {
        validator_cycle : 20,
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // Check if the genesis block has enrollments
    auto nodes = network.clients;
    const b0 = nodes[0].getBlocksFrom(0, 2)[0];
    assert(b0.header.enrollments.length >= 1);
    const e0 = b0.header.enrollments[0];

    // Wait for the revelation of new pre-image to complete
    const org_preimage = PreImageInfo(e0.utxo_key, e0.random_seed, 0);
    PreImageInfo preimage_2;
    retryFor(org_preimage != (preimage_2 = nodes[0].getPreimage(e0.utxo_key)),
        15.seconds);
    assert(preimage_2 != PreImageInfo.init);
}
