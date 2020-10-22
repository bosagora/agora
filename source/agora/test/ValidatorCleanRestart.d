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
        outsider_validators : 4 };

    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.completeTestSetup();

    auto nodes = network.clients;
    auto set_a = nodes.take(genesis_validators);
    auto set_b = nodes.drop(genesis_validators).take(conf.outsider_validators);

    // Get to height 18
    network.generateBlocks(Height(18));

    // Block 19 we add the freeze utxos for set_b validators
    genesisSpendable().drop(1).takeExactly(1)
        .map!(txb => txb
            .split(WK.Keys.byRange.take(conf.outsider_validators).map!(k => k.address)).sign(TxType.Freeze))
        .each!(tx => set_a[0].putTransaction(tx));
    network.generateBlocks(Height(19));

    // wait for other nodes to get to same block height
    set_b.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == 19, 2.seconds,
            format!"[%s:%s] Expected block height %s but Outsider node %s has height %s."
                (__FILE__, __LINE__, 19, idx, node.getBlockHeight())));

    // Now we enroll four new validators. After this, the already enrolled
    // validators will be expired.
    iota(genesis_validators, genesis_validators + conf.outsider_validators)
        .each!(idx => network.enroll(idx));

    // Block 20
    network.generateBlocks(Height(20));

    // Sanity check
    auto b20 = set_a[0].getBlocksFrom(20, 2)[0];
    assert(b20.header.enrollments.length == 4);

    // Now restarting the validators in the set B, all the data of those
    // validators has been wiped out.
    set_b.each!(node => network.restart(node));
    network.expectBlock(Height(20));

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

    // Block 21 with the new validators in the set B
    network.generateBlocks(set_b, Height(21), Height(20));
}

/// Situation: A validator is stopped and wiped clean after the block height
///     is 1, and then, two blocks are inserted into the ledger. After the
///     validator restarts, another new block is in the middle of a consensus.
/// Expectation: The new block is inserted into the ledger because the validator
///     has started to validate immediately.
unittest
{
    TestConf conf = { full_nodes : 1 , quorum_threshold : 75 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // There are 6 validators and 1 full node
    auto nodes = network.clients;

    // Create a block from the Genesis block
    auto txs = genesisSpendable().map!(txb => txb.sign()).array();
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(1));

    // node #5 restarts and becomes unresponsive
    network.restart(nodes[5]);
    nodes[5].ctrl.sleep(5.seconds);

    // Make 2 blocks
    txs = txs.map!(tx => TxBuilder(tx).sign()).array();
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(nodes.take(5), Height(2));

    txs = txs.map!(tx => TxBuilder(tx).sign()).array();
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(nodes.take(5), Height(3));

    // Wait for node_1 to wake up
    nodes[1].ctrl.withTimeout(10.seconds,
        (scope TestAPI api) {
            api.getPublicKey();
        }
    );

    network.expectBlock(Height(3));

    // The node #2 restart and is disabled to respond, which means that
    // the node_2 will be slashed soon.
    network.restart(nodes[2]);
    nodes[2].ctrl.sleep(5.seconds);

    // A new block is in the middle of a consensus.
    txs = txs.map!(tx => TxBuilder(tx).sign()).array();
    txs.each!(tx => nodes[1].putTransaction(tx));

    // The new block has been inserted to the ledger with the approval
    // of the node_1, although node_2 was shutdown.
    network.expectBlock(Height(4));
}
