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
    TestConf conf = { nodes : 6, max_listeners : 7,
        topology : NetworkTopology.TwoOutsiderValidators,
        extra_blocks : 8,
        validator_cycle : 10 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    //scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == 8, 5.seconds,
            format("Node %s has block height %s. Expected: %s",
                idx, node.getBlockHeight(), 8)));

    enum quorums_1 = [
        // 0
        QuorumConfig(5, [
            WK.Keys.D.address,
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),

        // 1
        QuorumConfig(5, [
            WK.Keys.D.address,
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),

        // 2
        QuorumConfig(5, [
            WK.Keys.D.address,
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),

        // 3
        QuorumConfig(5, [
            WK.Keys.D.address,
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),

        // 4
        QuorumConfig(5, [
            WK.Keys.D.address,
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),

        // 5
        QuorumConfig(5, [
            WK.Keys.D.address,
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),

        QuorumConfig.init,
        QuorumConfig.init,
    ];

    version (none)
    foreach (idx, node; nodes.enumerate)
        writefln("Node %s: %s\n", idx, node.getQuorumConfig);

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getQuorumConfig() == quorums_1[idx], 5.seconds,
            format("Node %s has quorum config %s. Expected: %s",
                idx, node.getQuorumConfig(), quorums_1[idx])));

    auto spendable = network.blocks[$ - 1].txs
        .filter!(tx => tx.type == TxType.Payment)
        .map!(tx => iota(tx.outputs.length)
            .map!(idx => TxBuilder(tx, cast(uint)idx)))
        .joiner().array;

    // create block with 5 payment..
    auto txs = spendable[0 .. 5]
        .map!(txb => txb.refund(WK.Keys.Genesis.address).sign())
        .array;

    // ..6th payment (split into 3+ outputs so we can have at least 8 UTXOs..)
    txs ~= spendable[5].split(WK.Keys.Genesis.address.repeat(3)).sign();

    // ..and 2 freeze txs for the two outsider validator nodes
    txs ~= spendable[6 .. 8]
        .enumerate
        .map!(pair => pair.value.refund(nodes[6 + pair.index].getPublicKey())
            .sign(TxType.Freeze))
        .array;

    txs.each!(tx => nodes[0].putTransaction(tx));

    // at block height 9 the freeze txs are available
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == 9, 5.seconds,
            format("Node %s has block height %s. Expected: %s",
                idx, node.getBlockHeight(), 9)));

    // now we re-enroll existing validators (extension),
    // and enroll 2 new validators.
    foreach (node; nodes)
    {
        Enrollment enroll = node.createEnrollmentData();
        node.enrollValidator(enroll);

        // check enrollment
        nodes.each!(n =>
            retryFor(n.getEnrollment(enroll.utxo_key) == enroll, 5.seconds));
    }

    void makeBlock ()
    {
        txs = txs.filter!(tx => tx.type == TxType.Payment)
            .map!(tx => iota(tx.outputs.length)
                .map!(idx => TxBuilder(tx, cast(uint)idx)))
            .joiner().takeExactly(8)  // there might be 9 UTXOs..
            .map!(txb => txb.refund(WK.Keys.Genesis.address).sign()).array;
        txs.each!(tx => nodes[0].putTransaction(tx));
    }

    makeBlock();

    // at block height 10 the validator set has changed
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == 10, 3.seconds,
            format("Node %s has block height %s. Expected: %s",
                idx, node.getBlockHeight(), 10)));

    enum quorums_2 = [
        // 0
        QuorumConfig(6, [
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.H.address,
            WK.Keys.G.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),

        // 1
        QuorumConfig(6, [
            WK.Keys.D.address,
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.H.address,
            WK.Keys.G.address,
            WK.Keys.E.address]),

        // 2
        QuorumConfig(6, [
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.H.address,
            WK.Keys.G.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),

        // 3
        QuorumConfig(6, [
            WK.Keys.D.address,
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.H.address,
            WK.Keys.G.address,
            WK.Keys.C.address]),

        // 4
        QuorumConfig(6, [
            WK.Keys.D.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.H.address,
            WK.Keys.G.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),

        // 5
        QuorumConfig(6, [
            WK.Keys.D.address,
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.H.address,
            WK.Keys.G.address,
            WK.Keys.C.address]),

        // 6
        QuorumConfig(6, [
            WK.Keys.D.address,
            WK.Keys.F.address,
            WK.Keys.A.address,
            WK.Keys.H.address,
            WK.Keys.G.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),

        // 7
        QuorumConfig(6, [
            WK.Keys.D.address,
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.H.address,
            WK.Keys.G.address,
            WK.Keys.E.address]),
    ];

    static assert(quorums_1 != quorums_2);

    version (none)
    foreach (idx, node; nodes.enumerate)
        writefln("Node %s: %s\n", idx, node.getQuorumConfig);

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getQuorumConfig() == quorums_2[idx], 5.seconds,
            format("Node %s has quorum config %s. Expected: %s",
                idx, node.getQuorumConfig(), quorums_2[idx])));

    // create 9 blocks (1 short of all enrollments expiring)
    foreach (idx; 0 .. 9)
    {
        makeBlock();

        // at block height 10 the validator set has changed
        nodes.enumerate.each!((node_idx, node) =>
            retryFor(node.getBlockHeight() == 10 + idx + 1, 3.seconds,
                format("Node %s has block height %s. Expected: %s",
                    node_idx, node.getBlockHeight(), 10 + idx + 1)));
    }

    // re-enroll all validators before they expire
    foreach (node; nodes)
    {
        Enrollment enroll = node.createEnrollmentData();
        node.enrollValidator(enroll);

        // check enrollment
        nodes.each!(n =>
            retryFor(n.getEnrollment(enroll.utxo_key) == enroll, 5.seconds));
    }

    makeBlock();

    // at block height 20 the validator set has changed
    nodes.enumerate.each!((node_idx, node) =>
        retryFor(node.getBlockHeight() == 20, 3.seconds,
            format("Node %s has block height %s. Expected: %s",
                node_idx, node.getBlockHeight(), 20)));

    // these changed compared to quorums_2 due to the new enrollments
    // which use a different preimage
    enum quorums_3 = [
        // 0
        QuorumConfig(6, [
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.H.address,
            WK.Keys.G.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),

        // 1
        QuorumConfig(6, [
            WK.Keys.D.address,
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.H.address,
            WK.Keys.G.address,
            WK.Keys.C.address]),

        // 2
        QuorumConfig(6, [
            WK.Keys.D.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.H.address,
            WK.Keys.G.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),

        // 3
        QuorumConfig(6, [
            WK.Keys.D.address,
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.H.address,
            WK.Keys.G.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),

        // 4
        QuorumConfig(6, [
            WK.Keys.D.address,
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.H.address,
            WK.Keys.G.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),

        // 5
        QuorumConfig(6, [
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.H.address,
            WK.Keys.G.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),

        // 6
        QuorumConfig(6, [
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.H.address,
            WK.Keys.G.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),

        // 7
        QuorumConfig(6, [
            WK.Keys.F.address,
            WK.Keys.B.address,
            WK.Keys.A.address,
            WK.Keys.H.address,
            WK.Keys.G.address,
            WK.Keys.C.address,
            WK.Keys.E.address]),
    ];

    static assert(quorums_2 != quorums_3);

    version (none)
    foreach (idx, node; nodes.enumerate)
        writefln("Node %s: %s\n", idx, node.getQuorumConfig);

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getQuorumConfig() == quorums_3[idx], 5.seconds,
            format("Node %s has quorum config %s. Expected: %s",
                idx, node.getQuorumConfig(), quorums_3[idx])));
}
