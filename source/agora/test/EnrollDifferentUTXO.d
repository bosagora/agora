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
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.test.Base;

import core.thread;
import geod24.Registry;

private class SameKeyValidator : TestValidatorNode
{
    mixin ForwardCtor!();

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

        return this.enroll_man.createEnrollment(unused_utxo, this.ledger.getBlockHeight());
    }
}

private class SameKeyNodeAPIManager : TestAPIManager
{
    ///
    mixin ForwardCtor!();

    /// See base class
    public override void createNewNode (Config conf, string file, int line)
    {
        if (this.nodes.length == 0)
            this.addNewNode!SameKeyValidator(conf, file, line);
        else
            super.createNewNode(conf, file, line);
    }
}

/// Situation: There are six validators enrolled in Genesis block. Right before
///     the cycle ends, the first validator re-enrolls with another UTXO and
///     other validators re-enrolls again with the same UTXO used in the current
///     enrollments.
/// Expectation: Enrolling with the different UTXO of first validator fails but
///     trying re-enrolling with the UTXO succeeds after the cycle ends.
unittest
{
    TestConf conf = {
        txs_to_nominate : 0, // zero allows any number of txs for nomination
        recurring_enrollment : false
    };

    auto network = makeTestNetwork!SameKeyNodeAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;

    // generate 16 blocks
    network.generateBlocks(Height(16));
    assert(network.blocks[0].header.enrollments.length >= 1);
    network.expectBlock(Height(16), network.blocks[0].header, 5.seconds);

    // Discarded UTXOs (just to trigger block creation)
    auto spendable = network.blocks[$ - 1].spendable().array;
    auto txs = spendable[0 .. 4]
        .map!(txb => txb.refund(WK.Keys.Genesis.address).sign())
        .array;

    // 8 utxos for freezing, 24 utxos for creating a block later
    txs ~= spendable[4].split(WK.Keys.NODE2.address.repeat(8)).sign();
    txs ~= spendable[5].split(WK.Keys.Z.address.repeat(8)).sign();
    txs ~= spendable[6].split(WK.Keys.Z.address.repeat(8)).sign();
    txs ~= spendable[7].split(WK.Keys.Z.address.repeat(8)).sign();

    // Block 17
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(17), network.blocks[0].header, 10.seconds);

    // Freeze builders
    auto freezable = txs[$ - 4]
        .outputs.length.iota
        .takeExactly(8)
        .map!(idx => TxBuilder(txs[$ - 4], cast(uint)idx));

    // Create 8 freeze TXs
    auto freeze_txs = freezable
        .enumerate
        .map!(pair => pair.value.refund(WK.Keys.NODE2.address)
            .sign(TxType.Freeze))
        .array;
    assert(freeze_txs.length == 8);

    // Block 18
    freeze_txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(18), network.blocks[0].header, 5.seconds);

    // Block 19
    auto new_txs = txs[$ - 3]
        .outputs.length.iota.map!(idx => TxBuilder(txs[$ - 3], cast(uint)idx))
        .takeExactly(8)
        .map!(txb => txb.refund(WK.Keys.Z.address).sign()).array;
    new_txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(19), network.blocks[0].header, 5.seconds);

    // Now we re-enroll the first validator with a new UTXO but it will fail
    // because an enrollment with same public key of the first validator is
    // already present in the validator set.
    Enrollment new_enroll = nodes[0].createEnrollmentData();
    nodes[0].enrollValidator(new_enroll);
    Thread.sleep(3.seconds);  // enrollValidator() can take a while..
    nodes.each!(node =>
        retryFor(node.getEnrollment(new_enroll.utxo_key) == Enrollment.init, 1.seconds));

    // Now we re-enroll other five validators
    foreach (node; nodes[1 .. $])
    {
        Enrollment enroll = node.createEnrollmentData();
        nodes[0].enrollValidator(enroll);
        nodes.each!(node =>
            retryFor(node.getEnrollment(enroll.utxo_key) == enroll, 5.seconds));
    }

    // Block 20
    new_txs = txs[$ - 2]
        .outputs.length.iota.map!(idx => TxBuilder(txs[$ - 2], cast(uint)idx))
        .takeExactly(8)
        .map!(txb => txb.refund(WK.Keys.Z.address).sign()).array;
    new_txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(20), 5.seconds);
    auto b20 = nodes[0].getBlocksFrom(20, 2)[0];
    assert(b20.header.enrollments.length == 5);

    // Now we retry re-enrolling the first validator with the new UTXO
    nodes[0].enrollValidator(new_enroll);
    nodes.each!(node =>
        retryFor(node.getEnrollment(new_enroll.utxo_key) == new_enroll, 5.seconds));

    // Block 21 created with the new enrollment
    new_txs = txs[$ - 1]
        .outputs.length.iota.map!(idx => TxBuilder(txs[$ - 1], cast(uint)idx))
        .takeExactly(8)
        .map!(txb => txb.refund(WK.Keys.Z.address).sign()).array;
    new_txs.each!(tx => nodes[0].putTransaction(tx));
    network.waitForPreimages(b20.header.enrollments, 1, 2.seconds);
    network.expectBlock(Height(21), 5.seconds);
    auto b21 = nodes[0].getBlocksFrom(21, 2)[0];
    assert(b21.header.enrollments.length == 1);
    assert(b21.header.enrollments[0] == new_enroll);
}
