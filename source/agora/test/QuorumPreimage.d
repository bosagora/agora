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
import agora.consensus.data.Params;
import agora.consensus.data.genesis.Test;
import agora.crypto.Key;
import agora.node.FullNode;
import agora.test.Base;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

import core.thread;

/// test preimage changing quorum configs
unittest
{
    TestConf conf = {
        outsider_validators : 2,
    };
    conf.node.network_discovery_interval = 2.seconds;
    conf.node.retry_delay = 250.msecs;
    conf.consensus.quorum_threshold = 60;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    auto validators = GenesisValidators + conf.outsider_validators;

    // generate 18 blocks, 2 short of the enrollments expiring.
    network.generateBlocks(Height(GenesisValidatorCycle - 2));

    // make sure outsiders are up to date
    network.expectHeight(iota(GenesisValidators, validators),
        Height(GenesisValidatorCycle - 2));

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
        QuorumConfig(3, [0, 1, 3, 4, 5]),

        // 1
        QuorumConfig(3, [0, 1, 2, 3, 4]),

        // 2
        QuorumConfig(3, [0, 2, 3, 4, 5]),

        // 3
        QuorumConfig(3, [0, 1, 2, 3, 5]),

        // 4
        QuorumConfig(3, [0, 1, 2, 4, 5]),

        // 5
        QuorumConfig(3, [0, 2, 3, 4, 5]),

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

    // prepare frozen outputs for the outsider validator to enroll
    network.postAndEnsureTxInPool(network.freezeUTXO(only(GenesisValidators, GenesisValidators + 1)));

    // block 19
    network.generateBlocks(Height(GenesisValidatorCycle - 1));

    // make sure outsiders are up to date
    network.expectHeight(iota(GenesisValidators, validators),
        Height(GenesisValidatorCycle - 1));

    // Now we enroll new validators and re-enroll the original validators
    iota(GenesisValidators, validators).each!(idx => network.enroll(idx));

     // Generate the last block of cycle with Genesis validators
    network.generateBlocks(iota(GenesisValidators),
        Height(GenesisValidatorCycle));

    // Make sure we have all enrolled in block 20
    auto block20 = nodes.front.getBlock(Height(GenesisValidatorCycle));
    assert(block20.header.enrollments.length == validators);

    // make sure outsiders are up to date
    network.expectHeight(iota(GenesisValidators, validators),
        Height(GenesisValidatorCycle));

    enum quorums_2 = [
        // 0
        QuorumConfig(4, [0, 1, 3, 4, 6, 7]),

        // 1
        QuorumConfig(4, [0, 1, 3, 4, 5, 6]),

        // 2
        QuorumConfig(4, [0, 1, 3, 4, 5, 6]),

        // 3
        QuorumConfig(4, [0, 1, 3, 4, 5, 6]),

        // 4
        QuorumConfig(4, [0, 1, 3, 4, 5, 6]),

        // 5
        QuorumConfig(4, [0, 1, 3, 4, 5, 6]),

        // 6
        QuorumConfig(4, [0, 1, 2, 3, 4, 5]),

        // 7
        QuorumConfig(4, [0, 1, 3, 4, 5, 7]),
    ];

    static assert(quorums_1 != quorums_2);

    {
        scope (failure) printQuorums();
        nodes.enumerate.each!((idx, node) =>
            retryFor(node.getQuorumConfig() == quorums_2[idx], 5.seconds,
                format("Node %s has quorum config %s. Expected quorums_2: %s",
                    idx, node.getQuorumConfig(), quorums_2[idx])));
    }

    // create 20 more blocks with all validators
    iota(Height(GenesisValidatorCycle + 1), Height(2 * GenesisValidatorCycle + 1))
        .each!((Height h)
        {
            network.sendTransaction(nodes.front);
            network.expectHeightAndPreImg(iota(validators), h, block20.header.enrollments);
        });

    // these changed compared to quorums_2 due to the new enrollments
    // which use a different preimage
    enum quorums_3 = [
        // 0
        QuorumConfig(4, [0, 1, 3, 4, 5, 6]),

        // 1
        QuorumConfig(4, [0, 1, 3, 4, 5, 6]),

        // 2
        QuorumConfig(4, [0, 1, 3, 4, 5, 6]),

        // 3
        QuorumConfig(4, [0, 1, 3, 4, 5, 6]),

        // 4
        QuorumConfig(4, [0, 1, 3, 4, 5, 6]),

        // 5
        QuorumConfig(4, [0, 1, 3, 4, 5, 6]),

        // 6
        QuorumConfig(4, [1, 2, 3, 4, 5, 6]),

        // 7
        QuorumConfig(4, [0, 1, 4, 5, 6, 7]),
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
