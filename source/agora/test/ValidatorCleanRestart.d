/*******************************************************************************

    Contains tests for general situations where validators participate in
    nominating a block and reaching consensus.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.ValidatorCleanRestart;

version (unittest):

import agora.api.FullNode;
import agora.common.crypto.Key;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.test.Base;

/// Situation: One set of Validators(set A) which enrolled in the Genesis
///     block are all expired at the latest block height. And the other
///     set of Validators(set B) are already enrolled and all validators.
///     But all the set B has been shutdown and lost their data, which
///     means that they have to have a catch-up process. After the catch-up
///     process of set B have finished, a new block is being nominated,
///     and a consensus round for the new block is being made.
/// Expectation: The new block is approved and inserted into the ledger.
unittest
{
    TestConf conf = {
        timeout : 10.seconds,
        validators : 4,
        outsider_validators : 4,
        extra_blocks : 7,
        validator_cycle : 10 };

    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto set_a = network.clients[0 .. 4];
    auto set_b = network.clients[4 .. $];
    network.expectBlock(Height(7), 5.seconds);

    auto spendable = network.blocks[$ - 1].spendable().array;

    // Discarded UTXOs (just to trigger block creation)
    auto txs = spendable[0 .. 5]
        .map!(txb => txb.refund(WK.Keys.Genesis.address).sign())
        .array;

    // 8 utxos for freezing, 16 utxos for creating a block later
    txs ~= spendable[5].split(WK.Keys.byRange.take(8).map!(k => k.address)).sign();
    txs ~= spendable[6].split(WK.Keys.Z.address.repeat(8)).sign();
    txs ~= spendable[7].split(WK.Keys.Z.address.repeat(8)).sign();

    // Block 8
    txs.each!(tx => set_a[0].putTransaction(tx));
    network.expectBlock(Height(8), 5.seconds);

    // Freeze builders
    auto freezable = txs[$ - 3]
        .outputs.length.iota
        .takeExactly(8)
        .map!(idx => TxBuilder(txs[$ - 3], cast(uint)idx))
        .array;

    // Create 8 freeze TXs
    auto freeze_txs = freezable
        .enumerate
        .map!(pair => pair.value.refund(WK.Keys[pair.index].address)
            .sign(TxType.Freeze))
        .array;
    assert(freeze_txs.length == 8);

    // Block 9
    freeze_txs.each!(tx => set_a[0].putTransaction(tx));
    network.expectBlock(Height(9), 5.seconds);

    // Now we enroll four new validators. After this, the already enrolled
    // validators will be expired.
    foreach (ref node; set_b)
    {
        Enrollment enroll = node.createEnrollmentData();
        node.enrollValidator(enroll);

        // Check enrollment
        set_b.each!(node =>
            retryFor(node.getEnrollment(enroll.utxo_key) == enroll, 5.seconds));
    }

    // Block 10
    auto new_txs = txs[$ - 2]
        .outputs.length.iota.map!(idx => TxBuilder(txs[$ - 2], cast(uint)idx))
        .takeExactly(8)
        .map!(txb => txb.refund(WK.Keys.Genesis.address).sign()).array;
    new_txs.each!(tx => set_a[0].putTransaction(tx));
    network.expectBlock(Height(10), 5.seconds);

    // Sanity check
    auto b10 = set_a[0].getBlocksFrom(0, 2)[0];
    assert(b10.header.enrollments.length == 4);

    // Now restarting the validators in the set B, all the data of those
    // validators has been wiped out.
    set_b.each!(node => network.restart(node));
    network.expectBlock(Height(10), 5.seconds);

    // Sanity check
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getValidatorCount == 4, 3.seconds,
            format("Node %s has validator count %s. Expected: %s",
                idx, node.getValidatorCount(), 4)));

    // Check the connection states are complete for the set B
    set_b.each!(node =>
        retryFor(node.getNodeInfo().state == NetworkState.Complete, 5.seconds));

    // Check if the validators in the set B have all the addresses for
    // current validators and previous validators except themselves.
    set_b.each!(node =>
        retryFor(node.getNodeInfo().addresses.length ==
                    conf.validators + conf.outsider_validators - 1 , 5.seconds));

    // Make all the validators of the set A disable to respond
    set_a.each!(node => node.ctrl.sleep(6.seconds, true));

    // Block 11 with the new validators in the set B
    new_txs = txs[$ - 1]
        .outputs.length.iota.map!(idx => TxBuilder(txs[$ - 1], cast(uint)idx))
        .takeExactly(8)
        .map!(txb => txb.refund(WK.Keys.Genesis.address).sign()).array;
    new_txs.each!(tx => set_b[0].putTransaction(tx));
    network.expectBlock(set_b, Height(11), 5.seconds);
}
