/*******************************************************************************

    Tests regular quorum shuffling behavior.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.QuorumShuffle;

version (unittest):

import agora.crypto.Key;
import agora.test.Base;
import agora.utils.Log;

mixin AddLogger!();

/// With a validator cycle of 20 and shuffle cycle of 6 we should expect
/// quorums being shuffled at these block heights:
/// 6, 12, 18, 20 (enrollment change), 26 (next shuffle cycle)
unittest
{
    TestConf conf;
    // makes it easier to test shuffle cycling
    conf.consensus.quorum_shuffle_interval = 6;
    conf.node.max_listeners = 7;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    const keys = network.nodes.map!(node => node.getPublicKey().key).array;

    QuorumConfig[] checkQuorum (Height height) {
        log.trace("generateBlocks to height {}", height);
        network.generateBlocks(Height(height));
        log.trace("checkQuorum for height {}", height);
        QuorumConfig[] quorums = nodes[0].getExpectedQuorums(keys, height);
        log.trace(quorums.fold!((a, b) => format!"%s\n%s"(a, b))(""));
        nodes.enumerate.each!((idx, client) =>
            retryFor(client.getQuorumConfig() == quorums[idx], 5.seconds,
                format!"Node %s has quorum config %s. Expected: %s"
                    (idx, client.getQuorumConfig(), quorums[idx])));
        return quorums;
    }

    // We check at each expected shuffle
    auto quorums = [0, 6, 12, 18, 20, 26].map!(height =>
        checkQuorum(Height(height))).array;
    assert(quorums.sort.uniq().count() == quorums.count(),
        format!"The quorums should be unique not %s"
            (quorums.fold!((a, b) => format!"%s\n%s"(a, b))("")));
}
