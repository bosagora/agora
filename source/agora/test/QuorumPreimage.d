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
        recurring_enrollment : false,
        outsider_validators : 2,
        max_listeners : 7,
        txs_to_nominate : 0 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    auto validators = GenesisValidators + conf.outsider_validators;

    // generate 18 blocks, 2 short of the enrollments expiring.
    network.generateBlocks(Height(GenesisValidatorCycle - 2));

    void printQuorums (uint line = __LINE__)
    {
        foreach (idx, node; nodes.enumerate)
        {
            import std.string;
            const quorum = node.getQuorumConfig();
            writefln("L%s: Node %s: Threshold: %s Nodes: %s", line, idx,
                quorum.threshold, quorum.nodes.map!(e =>
                    e.to!string.chompPrefix("GD")
                    .chompPrefix("NODE")[0 .. 1]));
        }
    }

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
        scope (failure) printQuorums();
        nodes.enumerate.each!((idx, node) =>
            retryFor(node.getQuorumConfig() == quorums_1[idx], 5.seconds,
                format("Node %s has quorum config %s. Expected quorums_1: %s",
                    idx, node.getQuorumConfig(), quorums_1[idx])));
    }

    const keys = network.nodes.map!(node => node.client.getPublicKey())
        .dropExactly(GenesisValidators).takeExactly(conf.outsider_validators)
        .array;

    // prepare frozen outputs for outsider validators to enroll
    genesisSpendable().dropExactly(1).takeExactly(1)
        .map!(txb => txb.split(keys).sign(TxType.Freeze))
        .each!(tx => network.clients[0].putTransaction(tx));

    // block 19
    network.generateBlocks(Height(GenesisValidatorCycle - 1));

    // make sure outsiders are up to date
    network.expectBlock(iota(GenesisValidators, validators),
        Height(GenesisValidatorCycle - 1));

    // Now we enroll new validators and re-enroll the original validators
    iota(validators).each!(idx => network.enroll(idx));

     // Generate the last block of cycle with Genesis validators
    network.generateBlocks(iota(GenesisValidators),
        Height(GenesisValidatorCycle));

    // make sure outsiders are up to date
    network.expectBlock(iota(GenesisValidators, validators),
        Height(GenesisValidatorCycle));

    enum quorums_2 = [
        // 0
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE6.address,
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
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
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

    {
        scope (failure) printQuorums();
        nodes.enumerate.each!((idx, node) =>
            retryFor(node.getQuorumConfig() == quorums_2[idx], 5.seconds,
                format("Node %s has quorum config %s. Expected quorums_2: %s",
                    idx, node.getQuorumConfig(), quorums_2[idx])));
    }

    // create 19 blocks with all validators (1 short of end of 2nd cycle)
    network.generateBlocks(iota(validators),
        Height((2 * GenesisValidatorCycle) - 1));

    // Re-enroll
    iota(validators).each!(idx => network.enroll(idx));

    // Generate the last block of cycle with Genesis validators
    network.generateBlocks(iota(validators),
        Height(2 * GenesisValidatorCycle));

    // these changed compared to quorums_2 due to the new enrollments
    // which use a different preimage
    enum quorums_3 = [
        // 0
        QuorumConfig(6, [
            WK.Keys.NODE2.address,
            WK.Keys.NODE6.address,
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
            WK.Keys.NODE6.address,
            WK.Keys.B.address,
            WK.Keys.NODE3.address,
            WK.Keys.A.address,
            WK.Keys.NODE7.address]),

        // 6
        QuorumConfig(6, [
            WK.Keys.NODE4.address,
            WK.Keys.NODE6.address,
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
        scope (failure) printQuorums();
        nodes.enumerate.each!((idx, node) =>
            retryFor(node.getQuorumConfig() == quorums_3[idx], 5.seconds,
                format("Node %s has quorum config %s. Expected quorums_3: %s",
                    idx, node.getQuorumConfig(), quorums_3[idx])));
    }
}
