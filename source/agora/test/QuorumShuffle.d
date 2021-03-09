/*******************************************************************************

    Tests regular quorum shuffling behavior.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.QuorumShuffle;

version (unittest):

import agora.serialization.Serializer;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.test.Base;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

mixin AddLogger!();
/// With a validator cycle of 20 and shuffle cycle of 6 we should expect
/// quorums being shuffled at these block heights:
/// 6, 12, 18, 20 (enrollment change), 26 (next shuffle cycle)
unittest
{
    import agora.common.Types;
    TestConf conf = {
        max_listeners : 7,
        max_quorum_nodes : 4,  // makes it easier to test shuffle cycling
        quorum_shuffle_interval : 6,
        txs_to_nominate : 0
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    const keys = network.nodes.map!(node => node.client.getPublicKey()).array;

    QuorumConfig[] checkQuorum (Height height) {
        if (height > 0) // if not Genesis block
        {
            if (height % GenesisValidatorCycle == 0) {
                log.trace("generateBlocks to height {}", height - 1);
                network.generateBlocks(Height(height - 1));
                log.trace("re-enrolling at height {}", height);
                iota(0, GenesisValidators).each!(idx => network.enroll(idx));
                log.trace("generateBlocks to height {}", height);
                network.generateBlocks(Height(height));
            }
            else
            {
                log.trace("generateBlocks to height {}", height);
                network.generateBlocks(Height(height));
            }
        }
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
