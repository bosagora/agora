/*******************************************************************************

    Contains tests for the validators not revealing their pre-images. There
    are four cases that the validators do not reveal as follows.

    (A) Never send any pre-image after its initial enrollment
    (B) Only send one pre-image after enrolling then no more
    (C) Send pre-image for half of its cycle (potentially in one burst)
        then stop sending pre-image
    (D) Send pre-image for half its cycle, stop it for a quarter of the cycle,
        resume until the end

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.MissingPreImageDetection;

import agora.common.crypto.Key;
import agora.common.Config;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Params;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.test.Base;

import core.stdc.time;
import core.thread;
import geod24.Registry;

version (unittest):

/*******************************************************************************

    Check a pre-image of the specified distance is revealed

    Params:
        clients = nodes to check
        enroll_key = the key for enrollment
        distance = the distance of a pre-image to be checked

*******************************************************************************/

private void checkMissingPreImage (Clients)(Clients clients, Hash enroll_key,
    uint distance)
{
    foreach (_; 0 .. 10)
    {
        clients.each!(node => retryFor(
            node.getPreimage(enroll_key).distance < distance,
            1.seconds, format!"distance: %s, expected: %s"(
                node.getPreimage(enroll_key).distance, distance)));
    }
}

/*******************************************************************************

    Make common blocks and enroll all the nodes as validators

    Params:
        network = API manager to use
        new_enroll = the enrollment to be newly enrolled

    Returns:
        Transactions used for making the last block

*******************************************************************************/

private Transaction[] makeCommonBlocks (ParentBadAPIManager network,
    ref Enrollment new_enroll)
{
    auto nodes = network.clients;
    auto bad_validator = nodes[$ - 1];
    auto genesis_header = network.blocks[0].header;
    auto spendable = network.blocks[$ - 1].spendable().array;

    // Discarded UTXOs (just to trigger block creation)
    auto txs = spendable[0 .. 6]
        .map!(txb => txb.refund(WK.Keys.A.address).sign())
        .array;

    // 8 utxo for freezing, 16 utxos for, 16 utxos for creating a block later
    txs ~= spendable[6].split(WK.Keys.Z.address.repeat(8)).sign();
    txs ~= spendable[7].split(WK.Keys.Z.address.repeat(8)).sign();

    // Block 18
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(18), genesis_header);

    // freeze builders
    auto freezable = txs[$ - 2]  // contains 8 payment UTXOs
        .outputs.length.iota
        .takeExactly(8)
        .map!(idx => TxBuilder(txs[$ - 2], cast(uint)idx))
        .array;

    // create 8 freeze TXs
    auto freeze_txs = freezable
        .enumerate
        .map!(pair => pair.value.refund(WK.Keys.A.address)
            .sign(TxType.Freeze))
        .array;

    // Block 19
    freeze_txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(19), genesis_header);

    writeln("WK.Keys.A.address: ", WK.Keys.A.address);
    // Now we enroll a new validator and re-enroll the four current validators.
    int idx = 0;
    foreach (ref node; nodes)
    {
        writeln("node: ", node.getPublicKey());
        Enrollment enroll = node.createEnrollmentData();
        node.enrollValidator(enroll);



        // Check enrollment
        nodes.each!(node =>
            retryFor(node.getEnrollment(enroll.utxo_key) == enroll, 5.seconds));

        if (node == bad_validator)
            new_enroll = enroll;
    }
    writeln("After enrollments");

    // Block 8 with new enrollments
    auto new_txs = txs[$ - 1]
        .outputs.length.iota.map!(idx => TxBuilder(txs[$ - 1], cast(uint)idx))
        .map!(txb => txb.refund(WK.Keys.Z.address).sign())
        .array;
    new_txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(20), genesis_header);

    return new_txs;
}

/// The imtermediate API manager class used as parameter of `makeCommonBlocks`
private class ParentBadAPIManager : TestAPIManager
{
    ///
    public this (immutable(Block)[] blocks, TestConf test_conf, time_t initial_time)
    {
        super(blocks, test_conf, initial_time);
    }
}

/// This test is for the case A.
/// Test for detecting the validator never sending any pre-image after
/// its initial enrollment.
unittest
{
    static class NeverRevelationEM : EnrollmentManager
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

    static class MisbehavingValidator : TestValidatorNode
    {
        ///
        public this (Config config, Registry* reg, immutable(Block)[] blocks,
                        ulong txs_to_nominate, shared(time_t)* cur_time)
        {
            super(config, reg, blocks, txs_to_nominate, cur_time);
        }

        protected override EnrollmentManager getEnrollmentManager (
            string data_dir, in ValidatorConfig validator_config,
            immutable(ConsensusParams) params)
        {
            return new NeverRevelationEM(":memory:", validator_config.key_pair,
                params);
        }
    }

    static class BadAPIManager : ParentBadAPIManager
    {
        ///
        public this (immutable(Block)[] blocks, TestConf test_conf, time_t initial_time)
        {
            super(blocks, test_conf, initial_time);
        }

        ///
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 6)
            {
                auto time = new shared(time_t)(this.initial_time);
                auto api = RemoteAPI!TestAPI.spawn!MisbehavingValidator(
                    conf, &this.reg, this.blocks, this.test_conf.txs_to_nominate,
                    time, conf.node.timeout);
                this.reg.register(conf.node.address, api.tid());
                this.nodes ~= NodePair(conf.node.address, api, time);
            }
            else
                super.createNewNode(conf, file, line);
        }
    }

    TestConf conf = {
        extra_blocks : 17,
        outsider_validators : 1,
    };
    auto network = makeTestNetwork!BadAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;

    Enrollment bad_enroll;
    auto new_txs = makeCommonBlocks(network, bad_enroll);

    auto b20 = nodes[0].getBlocksFrom(20, 2)[0];
    assert(b20.header.enrollments.length == 7);

    // Block 21 to 39 which is the height before the bad balidator's cycle ends
    foreach (height; 21 .. 40)
    {
        new_txs = new_txs.map!
            (tx => TxBuilder(tx, 0).refund(WK.Keys.Z.address).sign()).array();
        new_txs.each!(tx => nodes[0].putTransaction(tx));
        network.expectBlock(Height(height));
    }

    // Check the bad validator never reveal its pre-image
    checkMissingPreImage(nodes, bad_enroll.utxo_key, 1);
}

/// This test is for the case B.
/// Test for detecting the validator only sending one pre-image after enrolling
/// then no more.
unittest
{
    static class OnceRevelationEM : EnrollmentManager
    {
        ///
        public this (string db_path, KeyPair key_pair,
            immutable(ConsensusParams) params)
        {
            super(db_path, key_pair, params);
        }

        /// This does not reveal pre-images intentionally in at a specified time
        public override bool getNextPreimage (out PreImageInfo preimage,
            Height height) @safe
        {
            if (this.hasPreimage(this.enroll_key, 1))
                return false;
            else
                return super.getNextPreimage(preimage, height);
        }
    }

    static class MisbehavingValidator : TestValidatorNode
    {
        ///
        public this (Config config, Registry* reg, immutable(Block)[] blocks,
                        ulong txs_to_nominate, shared(time_t)* cur_time)
        {
            super(config, reg, blocks, txs_to_nominate, cur_time);
        }

        protected override EnrollmentManager getEnrollmentManager (
            string data_dir, in ValidatorConfig validator_config,
            immutable(ConsensusParams) params)
        {
            return new OnceRevelationEM(":memory:", validator_config.key_pair,
                params);
        }
    }

    static class BadAPIManager : ParentBadAPIManager
    {
        ///
        public this (immutable(Block)[] blocks, TestConf test_conf, time_t initial_time)
        {
            super(blocks, test_conf, initial_time);
        }

        ///
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 6)
            {
                auto time = new shared(time_t)(this.initial_time);
                auto api = RemoteAPI!TestAPI.spawn!MisbehavingValidator(
                    conf, &this.reg, this.blocks, this.test_conf.txs_to_nominate,
                    time, conf.node.timeout);
                this.reg.register(conf.node.address, api.tid());
                this.nodes ~= NodePair(conf.node.address, api, time);
            }
            else
                super.createNewNode(conf, file, line);
        }
    }

    TestConf conf = {
        extra_blocks : 17,
        outsider_validators : 1,
    };
    auto network = makeTestNetwork!BadAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;

    Enrollment bad_enroll;
    auto new_txs = makeCommonBlocks(network, bad_enroll);

    auto b20 = nodes[0].getBlocksFrom(20, 2)[0];
    assert(b20.header.enrollments.length == 7);

    // Check the bad validator reveals pre-images at first
    network.waitForPreimages(b20.header.enrollments,
        EnrollmentManager.PreimageRevealPeriod);

    // Block 21 to 39 which is the height before the bad balidator's cycle ends
    foreach (height; 21 .. 40)
    {
        new_txs = new_txs.map!
            (tx => TxBuilder(tx, 0).refund(WK.Keys.Z.address).sign()).array();
        new_txs.each!(tx => nodes[0].putTransaction(tx));
        network.expectBlock(Height(height));
    }

    // Check the bad validator only reveals the next pre-image
    checkMissingPreImage(nodes, bad_enroll.utxo_key,
        EnrollmentManager.PreimageRevealPeriod + 1);
}

/// This test is for the case C.
/// Test for detecting the validator sending pre-image for half of its cycle
/// (potentially in one burst) then stop sending pre-image.
unittest
{
    static class HalfRevelationEM : EnrollmentManager
    {
        ///
        public this (string db_path, KeyPair key_pair,
            immutable(ConsensusParams) params)
        {
            super(db_path, key_pair, params);
        }

        /// This does not reveal pre-images intentionally in at a specified time
        public override bool getNextPreimage (out PreImageInfo preimage,
            Height height) @safe
        {
            auto required_dist = cast(ushort)(this.params.ValidatorCycle / 2 - 1);
            if (this.hasPreimage(this.enroll_key, required_dist))
                return false;
            else
                return super.getNextPreimage(preimage, height);
        }
    }

    static class MisbehavingValidator : TestValidatorNode
    {
        ///
        public this (Config config, Registry* reg, immutable(Block)[] blocks,
                        ulong txs_to_nominate, shared(time_t)* cur_time)
        {
            super(config, reg, blocks, txs_to_nominate, cur_time);
        }

        ///
        protected override EnrollmentManager getEnrollmentManager (
            string data_dir, in ValidatorConfig validator_config,
            immutable(ConsensusParams) params)
        {
            return new HalfRevelationEM(":memory:", validator_config.key_pair,
                params);
        }
    }

    static class BadAPIManager : ParentBadAPIManager
    {
        ///
        public this (immutable(Block)[] blocks, TestConf test_conf, time_t initial_time)
        {
            super(blocks, test_conf, initial_time);
        }

        /// see base class
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 6)
            {
                auto time = new shared(time_t)(this.initial_time);
                auto api = RemoteAPI!TestAPI.spawn!MisbehavingValidator(
                    conf, &this.reg, this.blocks, this.test_conf.txs_to_nominate,
                    time, conf.node.timeout);
                this.reg.register(conf.node.address, api.tid());
                this.nodes ~= NodePair(conf.node.address, api, time);
            }
            else
                super.createNewNode(conf, file, line);
        }
    }

    TestConf conf = {
        extra_blocks : 17,
        outsider_validators : 1,
    };
    auto network = makeTestNetwork!BadAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;

    Enrollment bad_enroll;
    auto new_txs = makeCommonBlocks(network, bad_enroll);

    auto b20 = nodes[0].getBlocksFrom(20, 2)[0];
    assert(b20.header.enrollments.length == 7);

    foreach (height; 21 .. 31)
    {
        new_txs = new_txs.map!
            (tx => TxBuilder(tx, 0).refund(WK.Keys.Z.address).sign()).array();
        new_txs.each!(tx => nodes[0].putTransaction(tx));
        network.expectBlock(Height(height));
    }

    // Check the bad validator reveals pre-images during half of a cycle
    network.waitForPreimages(b20.header.enrollments,
        cast(ushort)(bad_enroll.cycle_length / 2 - 1));

    foreach (height; 31 .. 40)
    {
        new_txs = new_txs.map!
            (tx => TxBuilder(tx, 0).refund(WK.Keys.Z.address).sign()).array();
        new_txs.each!(tx => nodes[0].putTransaction(tx));
        network.expectBlock(Height(height));
    }

    // Check the bad validator never reveal after half of a cycle
    checkMissingPreImage(nodes, bad_enroll.utxo_key,
        bad_enroll.cycle_length - 1);
}

/// This test is for the case D.
/// Test for detecting the validator sending pre-image for half its cycle,
/// stop it for a quarter of the cycle, resume until the end.
unittest
{
    static class HalfAndLastQuarterRevelationEM : EnrollmentManager
    {
        ///
        public this (string db_path, KeyPair key_pair,
            immutable(ConsensusParams) params)
        {
            super(db_path, key_pair, params);
        }

        ///
        public override bool getNextPreimage (out PreImageInfo preimage,
            Height height) @safe
        {
            auto enrolled = this.getEnrolledHeight(this.enroll_key);
            auto reuired = height - enrolled - 1;
            auto half = cast(ushort)(this.params.ValidatorCycle / 2 - 1);
            auto last_quarter = half + this.params.ValidatorCycle / 4;

            if (!this.hasPreimage(this.enroll_key, half) ||
                reuired >= last_quarter)
                return super.getNextPreimage(preimage, height);
            else
                return false;
        }
    }

    static class MisbehavingValidator : TestValidatorNode
    {
        ///
        public this (Config config, Registry* reg, immutable(Block)[] blocks,
                        ulong txs_to_nominate, shared(time_t)* cur_time)
        {
            super(config, reg, blocks, txs_to_nominate, cur_time);
        }

        ///
        protected override EnrollmentManager getEnrollmentManager (
            string data_dir, in ValidatorConfig validator_config,
            immutable(ConsensusParams) params)
        {
            return new HalfAndLastQuarterRevelationEM(":memory:",
                validator_config.key_pair, params);
        }
    }

    static class BadAPIManager : ParentBadAPIManager
    {
        ///
        public this (immutable(Block)[] blocks, TestConf test_conf, time_t initial_time)
        {
            super(blocks, test_conf, initial_time);
        }

        ///
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 6)
            {
                auto time = new shared(time_t)(this.initial_time);
                auto api = RemoteAPI!TestAPI.spawn!MisbehavingValidator(
                    conf, &this.reg, this.blocks, this.test_conf.txs_to_nominate,
                    time, conf.node.timeout);
                this.reg.register(conf.node.address, api.tid());
                this.nodes ~= NodePair(conf.node.address, api, time);
            }
            else
                super.createNewNode(conf, file, line);
        }
    }

    TestConf conf = {
        extra_blocks : 17,
        outsider_validators : 1,
    };
    auto network = makeTestNetwork!BadAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;

    Enrollment bad_enroll;
    auto new_txs = makeCommonBlocks(network, bad_enroll);
    auto b20 = nodes[0].getBlocksFrom(20, 2)[0];
    assert(b20.header.enrollments.length == 7);

    foreach (height; 21 .. 31)
    {
        new_txs = new_txs.map!
            (tx => TxBuilder(tx, 0).refund(WK.Keys.Z.address).sign()).array();
        new_txs.each!(tx => nodes[0].putTransaction(tx));
        network.expectBlock(Height(height));
    }

    // Check the bad validator reveals pre-images during half of a cycle
    network.waitForPreimages(b20.header.enrollments,
        cast(ushort)(bad_enroll.cycle_length / 2 - 1));

    // Check the bad validator does not reveal from half of a cycle
    // during a quarter of a cycle
    foreach (height; 31 .. 36)
    {
        new_txs = new_txs.map!
            (tx => TxBuilder(tx, 0).refund(WK.Keys.Z.address).sign()).array();
        new_txs.each!(tx => nodes[0].putTransaction(tx));
        network.expectBlock(Height(height));
        checkMissingPreImage(nodes, bad_enroll.utxo_key,
            EnrollmentManager.PreimageRevealPeriod * 2);
    }

    // Check the bad validator reveals during the last quarter of a cycle
    foreach (height; 36 .. 40)
    {
        new_txs = new_txs.map!
            (tx => TxBuilder(tx, 0).refund(WK.Keys.Z.address).sign()).array();
        new_txs.each!(tx => nodes[0].putTransaction(tx));
        network.expectBlock(Height(height));
        network.waitForPreimages(b20.header.enrollments,
            cast(ushort)(height - bad_enroll.cycle_length - 1));
    }
}
