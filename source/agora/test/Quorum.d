/*******************************************************************************

    Verify that expired enrollments and newly added enrollments change
    the quorum set configuration of a node.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Quorum;

version (unittest):

import agora.api.Validator;
import agora.common.Config;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.Genesis;
import agora.test.Base;

import std.algorithm;
import std.format;
import std.range;

import core.thread;
import core.time;

///
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
        retryFor(node.getBlockHeight() == 1007, 5.seconds,
            format("Node %s has block height %s. Expected: %s",
                idx, node.getBlockHeight(), 1007)));

    // create enrollment data
    // send a request to enroll as a Validator
    Enrollment enroll_0 = nodes[0].createEnrollmentData();
    Enrollment enroll_1 = nodes[1].createEnrollmentData();
    nodes[2].enrollValidator(enroll_0);
    nodes[3].enrollValidator(enroll_1);

    // check enrollments
    nodes.each!(node =>
        retryFor(node.getEnrollment(enroll_0.utxo_key) == enroll_0 &&
                 node.getEnrollment(enroll_1.utxo_key) == enroll_1,
            5.seconds));

    auto txs = makeChainedTransactions(getGenesisKeyPair(),
        network.blocks[$ - 1].txs, 1);
    txs.each!(tx => nodes[0].putTransaction(tx));

    // at block height 1008 the validator set changes from 4 => 2
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == 1008, 5.seconds,
            format("Node %s has block height %s. Expected: %s",
                idx, node.getBlockHeight(), 1008)));

    // these are un-enrolled now
    nodes[2 .. $].each!(node => node.sleep(3.seconds, true));

    // verify that consensus can still be reached by the leftover validators
    txs = makeChainedTransactions(getGenesisKeyPair(), txs, 1);
    txs.each!(tx => nodes[0].putTransaction(tx));

    nodes[0 .. 2].enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == 1009, 6.seconds,
            format("Node %s has block height %s. Expected: %s",
                idx, node.getBlockHeight(), 1009)));

    // wait for nodes[2 .. 3] to wake up
    Thread.sleep(6.seconds);

    // now try to re-enroll the rest of the validators
    Enrollment[] enrolls;
    foreach (node; nodes[2 .. $])
    {
        enrolls ~= node.createEnrollmentData();
        nodes[0].enrollValidator(enrolls[$ - 1]);
    }

    // check enrollments
    nodes.each!(node =>
        enrolls.each!(enroll =>
            retryFor(node.getEnrollment(enroll.utxo_key) == enroll, 5.seconds)));

    // this still uses 2 nodes for reaching consensus
    txs = makeChainedTransactions(getGenesisKeyPair(), txs, 1);
    txs.each!(tx => nodes[0].putTransaction(tx));

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == 1010, 5.seconds,
            format("Node %s has block height %s. Expected: %s",
                idx, node.getBlockHeight(), 1010)));

    // this should use 4 nodes
    txs = makeChainedTransactions(getGenesisKeyPair(), txs, 1);
    txs.each!(tx => nodes[0].putTransaction(tx));

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == 1011, 5.seconds,
            format("Node %s has block height %s. Expected: %s",
                idx, node.getBlockHeight(), 1011)));

    // this should halt progress because threshold is set to max
    // commenting this out will make the assert below fire.
    nodes[$ - 1].sleep(6.seconds, true);

    txs = makeChainedTransactions(getGenesisKeyPair(), txs, 1);
    txs.each!(tx => nodes[0].putTransaction(tx));

    try
    {
        // progress was not made, still stuck at 1011 blocks
        nodes.enumerate.each!((idx, node) =>
            retryFor!Exception(node.getBlockHeight() == 1012, 5.seconds,
                format("Node %s has block height %s. Expected: %s",
                    idx, node.getBlockHeight(), 1012)));
        assert(0);  // should not be reached
    }
    catch (Exception ex)
    {
        assert(ex.msg.canFind("has block height 1011. Expected: 1012"));
    }
}
