/*******************************************************************************

    Tests preimage quorum generation behavior.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
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
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.data.genesis.Test;
import agora.crypto.Key;
import agora.node.FullNode;
import agora.test.Base;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

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
    };
    conf.node.max_listeners = 7;
    auto network = makeTestNetwork!TestAPIManager(conf);
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
            writefln("L%s: Node %s: \n%s", line, idx, quorum.prettify);
        }
    }

    enum quorums_1 = [
        // 0
        QuorumConfig(5, [0, 1, 2, 3, 4, 5]),

        // 1
        QuorumConfig(5, [0, 1, 2, 3, 4, 5]),

        // 2
        QuorumConfig(5, [0, 1, 2, 3, 4, 5]),

        // 3
        QuorumConfig(5, [0, 1, 2, 3, 4, 5]),

        // 4
        QuorumConfig(5, [0, 1, 2, 3, 4, 5]),

        // 5
        QuorumConfig(5, [0, 1, 2, 3, 4, 5]),

        QuorumConfig.init,
        QuorumConfig.init,
    ];

    {
        scope (failure) printQuorums();
        nodes.enumerate.each!((idx, node) =>
            retryFor(node.getQuorumConfig() == quorums_1[idx], 5.seconds,
                format("Node %s has quorum config [%s]. Expected quorums_1: [%s]",
                    idx, node.getQuorumConfig(), quorums_1[idx])));
    }

    const keys = network.nodes.map!(node => node.getPublicKey().key)
        .dropExactly(GenesisValidators).takeExactly(conf.outsider_validators)
        .array;

    // prepare frozen outputs for outsider validators to enroll
    genesisSpendable().dropExactly(1).takeExactly(1)
        .map!(txb => txb.split(keys).sign(OutputType.Freeze))
        .each!(tx => network.clients[0].putTransaction(tx));

    // block 19
    network.generateBlocks(Height(GenesisValidatorCycle - 1));

    // make sure outsiders are up to date
    network.expectHeight(iota(GenesisValidators, validators),
        Height(GenesisValidatorCycle - 1));

    // Now we enroll new validators and re-enroll the original validators
    iota(validators).each!(idx => network.enroll(idx));

     // Generate the last block of cycle with Genesis validators
    network.generateBlocks(iota(GenesisValidators),
        Height(GenesisValidatorCycle));

    // make sure outsiders are up to date
    network.expectHeight(iota(GenesisValidators, validators),
        Height(GenesisValidatorCycle));

    enum quorums_2 = [
        // 0
        QuorumConfig(6, [0, 1, 3, 4, 5, 6, 7]),

        // 1
        QuorumConfig(6, [0, 1, 2, 3, 5, 6, 7]),

        // 2
        QuorumConfig(6, [0, 1, 2, 4, 5, 6, 7]),

        // 3
        QuorumConfig(6, [1, 2, 3, 4, 5, 6, 7]),

        // 4
        QuorumConfig(6, [0, 1, 3, 4, 5, 6, 7]),

        // 5
        QuorumConfig(6, [0, 1, 3, 4, 5, 6, 7]),

        // 6
        QuorumConfig(6, [0, 1, 2, 3, 4, 6, 7]),

        // 7
        QuorumConfig(6, [1, 2, 3, 4, 5, 6, 7]),
    ];

    static assert(quorums_1 != quorums_2);

    {
        scope (failure) printQuorums();
        nodes.enumerate.each!((idx, node) =>
            retryFor(node.getQuorumConfig() == quorums_2[idx], 5.seconds,
                format("Node %s has quorum config %s. Expected quorums_2: %s",
                    idx, node.getQuorumConfig(), quorums_2[idx])));
    }

    // create 19 more blocks with all validators (1 short of end of 2nd cycle)
    network.generateBlocks(iota(validators),
        Height((2 * GenesisValidatorCycle) - 1));

    // Re-enroll
    iota(validators).each!(idx => network.enroll(iota(validators), idx));

    // Generate the last block of cycle with Genesis validators
    network.generateBlocks(iota(validators),
        Height(2 * GenesisValidatorCycle));

    // these changed compared to quorums_2 due to the new enrollments
    // which use a different preimage
    enum quorums_3 = [
        // 0
        QuorumConfig(6, [0, 1, 2, 4, 5, 6, 7]),

        // 1
        QuorumConfig(6, [0, 1, 3, 4, 5, 6, 7]),

        // 2
        QuorumConfig(6, [0, 1, 2, 4, 5, 6, 7]),

        // 3
        QuorumConfig(6, [0, 2, 3, 4, 5, 6, 7]),

        // 4
        QuorumConfig(6, [1, 2, 3, 4, 5, 6, 7]),

        // 5
        QuorumConfig(6, [0, 1, 2, 3, 5, 6, 7]),

        // 6
        QuorumConfig(6, [0, 1, 3, 4, 5, 6, 7]),

        // 7
        QuorumConfig(6, [0, 1, 2, 3, 4, 6, 7]),
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
