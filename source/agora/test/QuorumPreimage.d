/*******************************************************************************

    Tests preimage quorum generation behavior.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.QuorumPreimage;

version (unittest):

import agora.api.Validator;
import agora.common.Amount;
import agora.common.Config;
import agora.consensus.data.ConsensusParams;
import agora.common.crypto.Key;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.data.genesis.Test;
import agora.node.FullNode;
import agora.test.Base;

import std.algorithm;
import std.format;
import std.range;

import core.thread;
import core.time;

/// test preimage changing quorum configs
unittest
{
    import agora.common.Types;
    TestConf conf = { validators : 8 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    enum quorums_1 = [
        // 0
        QuorumConfig(5, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.NODE3.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),

        // 1
        QuorumConfig(5, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.NODE3.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),

        // 2
        QuorumConfig(5, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.NODE3.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),

        // 3
        QuorumConfig(5, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.NODE3.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),

        // 4
        QuorumConfig(5, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.NODE3.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),

        // 5
        QuorumConfig(5, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.NODE3.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),

        QuorumConfig.init,
        QuorumConfig.init,
    ];

    version (none)  // un-comment to log quorum configs
    foreach (idx, node; nodes.enumerate)
        writefln("Node %s: %s\n", idx, node.getQuorumConfig);

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getQuorumConfig() == quorums_1[idx], 5.seconds,
            format("Node %s has quorum config %s. Expected: %s",
                idx, node.getQuorumConfig(), quorums_1[idx])));

    auto block_height = network.enrollNonGenesisValidators();
    assert(block_height == 21);

    enum quorums_2 = [
        // 0
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),

        // 1
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),

        // 2
        QuorumConfig(6, [
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),

        // 3
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),

        // 4
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE5.address]),

        // 5
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),

        // 6
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),

        // 7
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),
    ];

    static assert(quorums_1 != quorums_2);

    version (none)  // un-comment to log quorum configs
    foreach (idx, node; nodes.enumerate)
        writefln("Node %s: %s\n", idx, node.getQuorumConfig);

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getQuorumConfig() == quorums_2[idx], 5.seconds,
            format("Node %s has quorum config %s. Expected: %s",
                idx, node.getQuorumConfig(), quorums_2[idx])));

    network.generateBlocks(Height(39), Height(20));

    foreach (node; nodes)
    {
        Enrollment enroll = node.createEnrollmentData();
        nodes[0].enrollValidator(enroll);
        retryFor(nodes[0].getEnrollment(enroll.utxo_key) == enroll, 5.seconds);
    }

    network.generateBlocks(Height(40), Height(20));

    // these changed compared to quorums_2 due to the new enrollments
    // which use a different preimage
    enum quorums_3 = [
        // 0
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE5.address]),

        // 1
        QuorumConfig(6, [
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),

        // 2
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),

        // 3
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE5.address]),

        // 4
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address]),

        // 5
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),

        // 6
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE5.address]),

        // 7
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address]),
    ];

    static assert(quorums_2 != quorums_3);

    version (none)  // un-comment to log quorum configs
    foreach (idx, node; nodes.enumerate)
        writefln("Node %s: %s\n", idx, node.getQuorumConfig);

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getQuorumConfig() == quorums_3[idx], 5.seconds,
            format("Node %s has quorum config %s. Expected: %s",
                idx, node.getQuorumConfig(), quorums_3[idx])));
}
