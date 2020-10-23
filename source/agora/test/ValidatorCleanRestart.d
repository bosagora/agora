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
        validators : 6,
        outsider_validators : 2,
        extra_blocks : 7,
        validator_cycle : 10 };

    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto set_a = network.clients[0 .. conf.validators];
    auto set_b = network.clients[conf.validators .. $];
    network.expectBlock(Height(7), network.blocks[0].header);

    auto spendable = network.blocks[$ - 1].spendable().array;

    // Discarded UTXOs (just to trigger block creation)
    auto txs = spendable[0 .. 5]
        .map!(txb => txb.refund(WK.Keys.Genesis.address).sign())
        .array;

    // 8 utxos for freezing, 16 utxos for creating a block later
    txs ~= spendable[5].split(WK.Keys.byRange.take(conf.validators + conf.outsider_validators).map!(k => k.address)).sign();
    txs ~= spendable[6].split(WK.Keys.Z.address.repeat(8)).sign();
    txs ~= spendable[7].split(WK.Keys.Z.address.repeat(8)).sign();

    // Block 8
    txs.each!(tx => set_a[0].putTransaction(tx));
    network.expectBlock(Height(8), network.blocks[0].header);

    // Freeze builders
    auto freezable = txs[$ - 3]
        .outputs.length.iota
        .takeExactly(conf.validators + conf.outsider_validators)
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
    network.expectBlock(Height(9), network.blocks[0].header);

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
    network.expectBlock(Height(10), network.blocks[0].header);

    // Sanity check
    auto b10 = set_a[0].getBlocksFrom(10, 2)[0];
    assert(b10.header.enrollments.length == conf.outsider_validators);

    // Now restarting the validators in the set B, all the data of those
    // validators has been wiped out.
    set_b.each!(node => network.restart(node));
    network.expectBlock(Height(10));

    // Sanity check
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getValidatorCount == conf.outsider_validators, 3.seconds,
            format("Node %s has validator count %s. Expected: %s",
                idx, node.getValidatorCount(), conf.outsider_validators)));

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
    network.expectBlock(set_b, Height(11), b10.header);
}

/// Situation: A validator is stopped and wiped clean after the block height
///     is 1, and then, two blocks are inserted into the ledger. After the
///     validator restarts, another new block is in the middle of a consensus.
/// Expectation: The new block is inserted into the ledger because the validator
///     has started to validate immediately.
unittest
{
    TestConf conf = { validators : 6, full_nodes : 1 , quorum_threshold : 75 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // node_1 and node_2 are the validators
    auto nodes = network.clients;
    auto node_1 = nodes[0];
    auto node_2 = nodes[1];
    auto on_nodes = nodes[1 .. $-1];    // full node

    // Create a block from the Genesis block
    auto txs = genesisSpendable().map!(txb => txb.sign()).array();
    txs.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(1));

    // node_1 restarts and becomes unresponsive
    network.restart(node_1);
    node_1.ctrl.sleep(5.seconds);

    // Make 2 blocks
    txs = txs.map!(tx => TxBuilder(tx).sign()).array();
    txs.each!(tx => node_2.putTransaction(tx));
    network.expectBlock(on_nodes, Height(2));

    txs = txs.map!(tx => TxBuilder(tx).sign()).array();
    txs.each!(tx => node_2.putTransaction(tx));
    network.expectBlock(on_nodes, Height(3));

    // Wait for node_1 to wake up
    node_1.ctrl.withTimeout(10.seconds,
        (scope TestAPI api) {
            api.getPublicKey();
        }
    );

    network.expectBlock(Height(3));

    // The node_2 restart and is disabled to respond, which means that
    // the node_2 will be slashed soon.
    network.restart(node_2);
    node_2.ctrl.sleep(5.seconds);

    // A new block is in the middle of a consensus.
    txs = txs.map!(tx => TxBuilder(tx).sign()).array();
    txs.each!(tx => node_1.putTransaction(tx));

    // The new block has been inserted to the ledger with the approval
    // of the node_1, although node_2 was shutdown.
    network.expectBlock(Height(4));
}
