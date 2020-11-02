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
import agora.consensus.data.Params;
import agora.common.crypto.Key;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.data.genesis.Test;
import agora.node.FullNode;
import agora.utils.Log;
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
    TestConf conf = {
        outsider_validators : 2,
        max_listeners : 7,
        extra_blocks : 18 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    Height expected_block = Height(conf.extra_blocks);

    // Expect block 18
    network.expectBlock(expected_block++, GenesisBlock.header);

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

    {
        scope (failure)
            foreach (idx, node; nodes.enumerate)
                writefln("Node %s: %s\n", idx, node.getQuorumConfig);

        nodes.enumerate.each!((idx, node) =>
            retryFor(node.getQuorumConfig() == quorums_1[idx], 5.seconds,
                format("Node %s has quorum config %s. Expected quorums_1: %s",
                    idx, node.getQuorumConfig(), quorums_1[idx])));
    }

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
        .map!(pair => pair.value.refund(nodes[GenesisValidators + pair.index].getPublicKey())
            .sign(TxType.Freeze))
        .array;

    txs.each!(tx => nodes[0].putTransaction(tx));

    // at block height 19 the freeze txs are available
    network.expectBlock(expected_block++, GenesisBlock.header);

    // now we re-enroll existing validators (extension),
    // and enroll 2 new validators.
    Enrollment[] enrolls;
    foreach (node; nodes)
    {
        Enrollment enroll = node.createEnrollmentData();
        enrolls ~= enroll;
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

    // at block height 20 the validator set has changed
    network.expectBlock(expected_block++, GenesisBlock.header);

    // check if the needed pre-images are revealed timely
    enrolls.each!(enroll =>
        nodes.each!(node =>
            retryFor(node.getPreimage(enroll.utxo_key).distance >= 6, 5.seconds)));

    enum quorums_2 = [
        // 0
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address]),

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
            WK.Keys.NODE7.address]),

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

    {
        scope (failure)
            foreach (idx, node; nodes.enumerate)
                writefln("Node %s: %s\n", idx, node.getQuorumConfig);

        nodes.enumerate.each!((idx, node) =>
            retryFor(node.getQuorumConfig() == quorums_2[idx], 5.seconds,
                format("Node %s has quorum config %s. Expected quorums_2: %s",
                    idx, node.getQuorumConfig(), quorums_2[idx])));
    }

    // create 19 blocks (1 short of all enrollments expiring)
    const b20 = nodes[0].getBlocksFrom(20, 2)[0];
    foreach (idx; 0 .. 19)
    {
        makeBlock();

        // at block height 20 the validator set has changed
        network.expectBlock(expected_block++, b20.header);
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

    // at block height 40 the validator set has changed
    network.expectBlock(expected_block++, b20.header);

    // these changed compared to quorums_2 due to the new enrollments
    // which use a different preimage
    enum quorums_3 = [
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
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address]),

        // 2
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address,]),

        // 3
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
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
            WK.Keys.NODE7.address]),

        // 5
        QuorumConfig(6, [
            WK.Keys.NODE4.address,
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
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),

        // 7
        QuorumConfig(6, [
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address,
            WK.Keys.NODE5.address]),
    ];

    static assert(quorums_2 != quorums_3);

    {
        scope (failure)
            foreach (idx, node; nodes.enumerate)
                writefln("Node %s: %s\n", idx, node.getQuorumConfig);

        nodes.enumerate.each!((idx, node) =>
            retryFor(node.getQuorumConfig() == quorums_3[idx], 5.seconds,
                format("Node %s has quorum config %s. Expected quorums_3: %s",
                    idx, node.getQuorumConfig(), quorums_3[idx])));
    }
}
