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
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.Genesis;
import agora.test.Base;

import core.thread;
import core.time;

/// test for enrollment process & revealing a pre-image periodically
unittest
{
    // generate 1007 blocks, 1 short of the enrollments expiring.
    TestConf conf = { extra_blocks : 1007 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == 1007, 2.seconds,
            format("Node %s has block height %s. Expected: %s",
                idx, node.getBlockHeight(), 1007)));

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

    auto txs = makeChainedTransactions(getGenesisKeyPair(),
        network.blocks[$ - 1].txs, 1);
    txs.each!(tx => nodes[0].putTransaction(tx));

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == 1008, 2.seconds,
            format("Node %s has block height %s. Expected: %s",
                idx, node.getBlockHeight(), 1008)));

    // verify that consensus can still be reached
    txs = makeChainedTransactions(getGenesisKeyPair(), txs, 1);
    txs.each!(tx => nodes[0].putTransaction(tx));

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == 1009, 2.seconds,
            format("Node %s has block height %s. Expected: %s",
                idx, node.getBlockHeight(), 1009)));

    // check if nodes have a pre-image newly sent
    // during creating transactions for the new block
    nodes.each!(node =>
        retryFor(node.getPreimage(enroll_0.utxo_key) != PreImageInfo.init &&
                 node.getPreimage(enroll_1.utxo_key) != PreImageInfo.init &&
                 node.getPreimage(enroll_2.utxo_key) != PreImageInfo.init &&
                 node.getPreimage(enroll_3.utxo_key) != PreImageInfo.init,
            5.seconds));
}
