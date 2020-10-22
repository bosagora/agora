/*******************************************************************************

    Contains networking tests with multiple enrollments with different UTXOs.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.EnrollDifferentUTXOs;

version (unittest):

import agora.common.Amount;
import agora.common.Config;
import agora.common.Hash;
import agora.common.crypto.ECC;
import agora.common.crypto.Key;
import agora.common.crypto.Schnorr;
import agora.consensus.EnrollmentManager;
import agora.consensus.data.Block;
import agora.consensus.data.ConsensusParams;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.test.Base;

import core.stdc.time;
import core.thread;
import geod24.Registry;

private class SameKeyValidator : TestValidatorNode
{
    private shared(Hash*) prev_enroll_key;

    /// Ctor
    public this (Config config, Registry* reg, immutable(Block)[] blocks,
                    ulong txs_to_nominate, shared(time_t)* cur_time,
                    shared(Hash*) prev_enroll_key)
    {
        this.prev_enroll_key = prev_enroll_key;
        super(config, reg, blocks, txs_to_nominate, cur_time);
    }

    /// Create an enrollment with new UTXO which is not yet used
    public override Enrollment createEnrollmentData ()
    {
        Hash[] utxo_hashes;
        auto utxos = this.utxo_set.getUTXOs(
            this.config.validator.key_pair.address);
        foreach (key, utxo; utxos)
        {
            if (utxo.type == TxType.Freeze &&
                utxo.output.value.integral() >= Amount.MinFreezeAmount.integral())
            {
                utxo_hashes ~= key;
            }
        }

        // Find a UTXO which is not used for the enrollments in Genesis block
        Hash unused_utxo;
        Hash[] enroll_keys;
        assert(this.enroll_man.getEnrolledUTXOs(enroll_keys));
        foreach (utxo; utxo_hashes)
        {
            if (!canFind(enroll_keys, utxo))
            {
                unused_utxo = utxo;
                break;
            }
        }
        assert(unused_utxo != Hash.init);

        // Set the previous enrollment key
        *this.prev_enroll_key =
            cast(shared(Hash)) this.enroll_man.getEnrollmentKey();

        return this.enroll_man.createEnrollment(unused_utxo);
    }
}

private class SameKeyNodeAPIManager : TestAPIManager
{
    // Used for sharing the enrollment key of a SameKeyValidator
    shared Hash prev_enroll_key;

    ///
    public this (immutable(Block)[] blocks, TestConf test_conf, time_t initial_time)
    {
        super(blocks, test_conf, initial_time);
    }

    /// See base class
    public override void createNewNode (Config conf, string file, int line)
    {
        if (this.nodes.length == 0)
        {
            auto time = new shared(time_t)(this.initial_time);
            auto api = RemoteAPI!TestAPI.spawn!SameKeyValidator(
                conf, &this.reg, this.blocks, this.test_conf.txs_to_nominate,
                time, &this.prev_enroll_key, conf.node.timeout);
            this.reg.register(conf.node.address, api.tid());
            this.nodes ~= NodePair(conf.node.address, api, time);
        }
        else
            super.createNewNode(conf, file, line);
    }
}

/// Situation: There is six validators enrolled in Genesis block. Right before
///     the cycle ends, the first validator reenrolls with another UTXO and
///     other validators reenrolls again with the same UTXO used in the current
///     enrollments.
/// Expectation: Enrolling with a different UTXO succeeds and blocks are
///     created normally after that.
unittest
{
    TestConf conf = {
        extra_blocks : 16,
    };

    auto network = makeTestNetwork!SameKeyNodeAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;

    // Sanity check
    assert(network.blocks[0].header.enrollments.length >= 1);
    network.expectBlock(Height(16), network.blocks[0].header, 5.seconds);

    // Discarded UTXOs (just to trigger block creation)
    auto spendable = network.blocks[$ - 1].spendable().array;
    auto txs = spendable[0 .. 5]
        .map!(txb => txb.refund(WK.Keys.Genesis.address).sign())
        .array;

    // 8 utxos for freezing, 16 utxos for creating a block later
    txs ~= spendable[5].split(WK.Keys.A.address.repeat(8)).sign();
    txs ~= spendable[6].split(WK.Keys.Z.address.repeat(8)).sign();
    txs ~= spendable[7].split(WK.Keys.Z.address.repeat(8)).sign();

    // Block 17
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(17), network.blocks[0].header, 5.seconds);

    // Freeze builders
    auto freezable = txs[$ - 3]
        .outputs.length.iota
        .takeExactly(8)
        .map!(idx => TxBuilder(txs[$ - 3], cast(uint)idx));

    // Create 8 freeze TXs
    auto freeze_txs = freezable
        .enumerate
        .map!(pair => pair.value.refund(WK.Keys.A.address)
            .sign(TxType.Freeze))
        .array;
    assert(freeze_txs.length == 8);

    // Block 18
    freeze_txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(18), network.blocks[0].header, 5.seconds);

    // Block 19
    auto new_txs = txs[$ - 2]
        .outputs.length.iota.map!(idx => TxBuilder(txs[$ - 2], cast(uint)idx))
        .takeExactly(8)
        .map!(txb => txb.refund(WK.Keys.Z.address).sign()).array;
    new_txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(19), network.blocks[0].header, 5.seconds);

    // Now we re-enroll the first validator with a new UTXO
    Enrollment new_enroll = nodes[0].createEnrollmentData();
    nodes[0].enrollValidator(new_enroll);
    nodes.each!(node =>
        retryFor(node.getEnrollment(new_enroll.utxo_key) == new_enroll, 5.seconds));

    // Now we re-enroll other five validators
    foreach (node; nodes[1 .. $])
    {
        Enrollment enroll = node.createEnrollmentData();
        nodes[0].enrollValidator(enroll);
        nodes.each!(node =>
            retryFor(node.getEnrollment(enroll.utxo_key) == enroll, 5.seconds));
    }

    // Block 20
    new_txs = txs[$ - 1]
        .outputs.length.iota.map!(idx => TxBuilder(txs[$ - 1], cast(uint)idx))
        .takeExactly(8)
        .map!(txb => txb.refund(WK.Keys.Z.address).sign()).array;
    new_txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(20), 5.seconds);
    auto b20 = nodes[0].getBlocksFrom(20, 2)[0];
    assert(b20.header.enrollments.length == 6);

    // Check the two enrollments of the first validator which has WK.Keys.A key.
    Enrollment genesis_enroll;
    Hash prev_enroll_key = cast(Hash)network.prev_enroll_key;
    foreach (enroll; network.blocks[0].header.enrollments)
    {
        if (enroll.utxo_key[] == prev_enroll_key[])
        {
            genesis_enroll = enroll;
            break;
        }
    }
    auto pubkey = Point(nodes[0].getPublicKey());
    assert(genesis_enroll.random_seed[] != new_enroll.random_seed[]);
    assert(verify(pubkey, genesis_enroll.enroll_sig, genesis_enroll));
    assert(verify(pubkey, new_enroll.enroll_sig, new_enroll));

    // Block 21
    new_txs = new_txs
        .map!(tx => TxBuilder(tx))
        .takeExactly(8)
        .map!(txb => txb.refund(WK.Keys.Z.address).sign()).array;
    new_txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(21), 5.seconds);
}

/// Situation: There are six validators enrolled in Genesis block. A few blocks
///     before the cycle, the first validator enrolls with the first validator
///     enrolls with another UTXO.
/// Expectation: Enrolling with a different UTXO succeeds and blocks are
///     created normally after that.
/// Node: It's currently making the problem happen. But it's not rare case,
///     so we remain it as `version (none)`. See the link.
///     https://github.com/bpfkorea/agora/pull/1268#issuecomment-716384194
version (none)
unittest
{
    TestConf conf = {
        extra_blocks : 15
    };

    auto network = makeTestNetwork!SameKeyNodeAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;

    // Sanity check
    assert(network.blocks[0].header.enrollments.length >= 1);
    network.expectBlock(Height(15), network.blocks[0].header, 5.seconds);

    // Discarded UTXOs (just to trigger block creation)
    auto spendable = network.blocks[$ - 1].spendable().array;
    auto txs = spendable[0 .. 4]
        .map!(txb => txb.refund(WK.Keys.Genesis.address).sign())
        .array;

    // 8 utxos for freezing, 16 utxos for creating a block later
    txs ~= spendable[4].split(WK.Keys.A.address.repeat(8)).sign();
    txs ~= spendable[5].split(WK.Keys.Z.address.repeat(8)).sign();
    txs ~= spendable[6].split(WK.Keys.Z.address.repeat(8)).sign();
    txs ~= spendable[7].split(WK.Keys.Z.address.repeat(8)).sign();

    // Block 16
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(16), network.blocks[0].header, 5.seconds);

    // Freeze builders
    auto freezable = txs[$ - 4]
        .outputs.length.iota
        .takeExactly(8)
        .map!(idx => TxBuilder(txs[$ - 4], cast(uint)idx));

    // Create 8 freeze TXs
    auto freeze_txs = freezable
        .enumerate
        .map!(pair => pair.value.refund(WK.Keys.A.address)
            .sign(TxType.Freeze))
        .array;
    assert(freeze_txs.length == 8);

    // Block 17
    freeze_txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(17), network.blocks[0].header, 5.seconds);

    // Block 18
    auto new_txs = txs[$ - 3]
        .outputs.length.iota.map!(idx => TxBuilder(txs[$ - 3], cast(uint)idx))
        .takeExactly(8)
        .map!(txb => txb.refund(WK.Keys.Z.address).sign()).array;
    new_txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(18), network.blocks[0].header, 5.seconds);

    // Now we re-enroll the first validator with a new UTXO
    Enrollment new_enroll = nodes[0].createEnrollmentData();
    nodes[0].enrollValidator(new_enroll);
    nodes.each!(node =>
        retryFor(node.getEnrollment(new_enroll.utxo_key) == new_enroll, 5.seconds));

    // Now we re-enroll other five validators
    foreach (node; nodes[1 .. $])
    {
        Enrollment enroll = node.createEnrollmentData();
        nodes[0].enrollValidator(enroll);
        nodes.each!(node =>
            retryFor(node.getEnrollment(enroll.utxo_key) == enroll, 5.seconds));
    }

    // Block 19
    new_txs = txs[$ - 2]
        .outputs.length.iota.map!(idx => TxBuilder(txs[$ - 2], cast(uint)idx))
        .takeExactly(8)
        .map!(txb => txb.refund(WK.Keys.Z.address).sign()).array;
    new_txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(19), 5.seconds);
    auto b19 = nodes[0].getBlocksFrom(19, 2)[0];
    assert(b19.header.enrollments.length == 1);

    // Check the two enrollments of the first validator which has WK.Keys.A key.
    Enrollment genesis_enroll;
    Hash prev_enroll_key = cast(Hash)network.prev_enroll_key;
    foreach (enroll; network.blocks[0].header.enrollments)
    {
        if (enroll.utxo_key[] == prev_enroll_key[])
        {
            genesis_enroll = enroll;
            break;
        }
    }
    auto pubkey = Point(nodes[0].getPublicKey());
    assert(genesis_enroll.random_seed[] != new_enroll.random_seed[]);
    assert(verify(pubkey, genesis_enroll.enroll_sig, genesis_enroll));
    assert(verify(pubkey, new_enroll.enroll_sig, new_enroll));

    network.waitForPreimages([new_enroll], 0);
    network.waitForPreimages(network.blocks[0].header.enrollments, 19);

    // Block 20
    new_txs = txs[$ - 1]
        .outputs.length.iota.map!(idx => TxBuilder(txs[$ - 1], cast(uint)idx))
        .takeExactly(8)
        .map!(txb => txb.refund(WK.Keys.Z.address).sign()).array;
    new_txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(20), 5.seconds);
    auto b20 = nodes[0].getBlocksFrom(20, 2)[0];
    assert(b20.header.enrollments.length == 5);
}
