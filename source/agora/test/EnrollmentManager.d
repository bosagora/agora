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
import agora.consensus.Genesis;
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

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == validator_cycle - 1, 2.seconds,
            format("Node %s has block height %s. Expected: %s",
                idx, node.getBlockHeight(), validator_cycle - 1)));

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

    // re-enroll every validator
    nodes.each!(node =>
        retryFor(node.getEnrollment(enroll_0.utxo_key) == enroll_0 &&
                 node.getEnrollment(enroll_1.utxo_key) == enroll_1 &&
                 node.getEnrollment(enroll_2.utxo_key) == enroll_2 &&
                 node.getEnrollment(enroll_3.utxo_key) == enroll_3,
            5.seconds));

    auto txs = makeChainedTransactions(WK.Keys.Genesis,
        network.blocks[$ - 1].txs, 1);
    txs.each!(tx => nodes[0].putTransaction(tx));

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == validator_cycle, 2.seconds,
            format("Node %s has block height %s. Expected: %s",
                idx, node.getBlockHeight(), validator_cycle)));

    // verify that consensus can still be reached
    txs = makeChainedTransactions(WK.Keys.Genesis, txs, 1);
    txs.each!(tx => nodes[0].putTransaction(tx));

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == validator_cycle + 1, 2.seconds,
            format("Node %s has block height %s. Expected: %s",
                idx, node.getBlockHeight(), validator_cycle + 1)));

    // check if nodes have a pre-image newly sent
    // during creating transactions for the new block
    nodes.each!(node =>
        retryFor(node.getPreimage(enroll_0.utxo_key) != PreImageInfo.init &&
                 node.getPreimage(enroll_1.utxo_key) != PreImageInfo.init &&
                 node.getPreimage(enroll_2.utxo_key) != PreImageInfo.init &&
                 node.getPreimage(enroll_3.utxo_key) != PreImageInfo.init,
            5.seconds));
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
        auto txs = makeChainedTransactions(WK.Keys.Genesis, prev_txs, 1);
        txs.each!(tx => nodes[0].putTransaction(tx));
        nodes.enumerate.each!((idx, node) =>
            retryFor(node.getBlockHeight() == height + 1,
                2.seconds,
                format("Node %s has block height %s. Expected: %s",
                    idx, node.getBlockHeight(), height + 1)));
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
            txs = genesisSpendable().take(Block.TxsInBlock).enumerate()
                .map!(en => en.value.refund(WK.Keys.A.address).sign())
                .array();
        else
            txs = txs
                .map!(ptx => TxBuilder(ptx).refund(WK.Keys[count].address).sign())
                .array();
        txs.each!(tx => nodes[1].putTransaction(tx));

        // Ensure everyone is at the same level
        ensureConsistency(nodes, count + 1);
    }

    // Now create an Enrollment for nodes[0], create block #20, and restart nodes[0]
    auto enroll = nodes[0].createEnrollmentData();
    nodes[0].enrollValidator(enroll);
    txs = txs
        .map!(ptx => TxBuilder(ptx).refund(WK.Keys[20].address).sign())
        .array();
    txs.each!(tx => nodes[1].putTransaction(tx));
    ensureConsistency(nodes.take(1), 20);
    retryFor(nodes[0].getBlocksFrom(20, 1)[0].header.enrollments.length == 1,
        2.seconds);

    network.restart(nodes[0]);
    network.waitForDiscovery();
    ensureConsistency([nodes[0]], 20, 10.seconds);

    // Now make a new block and make sure only nodes[0] signs it
    txs = txs
        .map!(ptx => TxBuilder(ptx).refund(WK.Keys[21].address).sign())
        .array();
    txs.each!(tx => nodes[1].putTransaction(tx));
    ensureConsistency(nodes.take(1), 21);

    PreImageInfo org_preimage = PreImageInfo(enroll.utxo_key, enroll.random_seed, 0);
    PreImageInfo preimage_1;
    retryFor(org_preimage == (preimage_1 = nodes[0].getPreimage(enroll.utxo_key)),
        5.seconds);

    // Wait for the revelation of new pre-image to complete
    PreImageInfo preimage_2;
    retryFor(org_preimage != (preimage_2 = nodes[0].getPreimage(enroll.utxo_key)),
        10.seconds);

    // Check if a new pre-image has been revealed from the restarted node
    assert(preimage_2.isValid(org_preimage, validator_cycle));
}
