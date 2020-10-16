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

import agora.common.Serializer;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.test.Base;
import agora.utils.Log;

mixin AddLogger!();

/// With a validator cycle of 20 and shuffle cycle of 6 we should expect
/// quorums being shuffled at these block heights:
/// 0, 6, 12, 18, 20 (enrollment change), 26 (next shuffle cycle)
unittest
{
    import agora.common.Types;
    TestConf conf = {
        max_quorum_nodes : 4,  // makes it easier to test shuffle cycling
        quorum_shuffle_interval : 6
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.completeTestSetup();

    auto clients = network.clients;

    const keys = clients.map!(client => client.getPublicKey()).array;
    log.trace(keys.fold!((a, b) => format!"%s\n%s"(a, b))(""));

    void checkDistance (ulong target_height, Height enroll_height)
    {
        auto distance = target_height - enroll_height;
        clients.enumerate.each!((idx, client) =>
            network.blocks[enroll_height].header.enrollments.each!(e =>
                retryFor(client.getPreimage(e.utxo_key).distance >= distance,
                    5.seconds,
                    format!"For client #%s expected at least preimage distance %s not %s"
                        (idx, distance, client.getPreimage(e.utxo_key).distance))));
    }

    QuorumConfig[] checkQuorum(Height height) {
        if (height > 0) // if not Genesis block
        {
            log.trace(format!"generateBlocks to height %s"(height));
            auto enrollment_Height = Height(network.validator_cycle * (height.value / network.validator_cycle));
            if (height % network.validator_cycle == 0) { // As cycle is 20 we need to re-enroll every 20 blocks
                network.generateBlocks(Height(height - 1));
                iota(0, genesis_validators).each!(idx => network.enroll(idx));
                network.generateBlocks(height);
            } else
            {
                checkDistance(height, enrollment_Height);
                if (height < network.validator_cycle)
                {
                    network.generateBlocks(height);
                }
                else
                {
                    network.generateBlocks(height, enrollment_Height); // enrolls are every 20
                }
            }
        }
        QuorumConfig[] quorums = clients[0].getExpectedQuorums(keys, Height(height));
        log.trace(quorums.fold!((a, b) => format!"%s\n%s"(a, b))(""));
        clients.enumerate.each!((idx, client) =>
            retryFor(client.getQuorumConfig() == quorums[idx], 5.seconds,
                format!"Node %s has quorum config %s. Expected: %s"
                    (idx, client.getQuorumConfig(), quorums[idx])));
        return quorums;
    }

    // We check at each expected shuffle
    auto quorums = [0, 6, 12, 18, 20, 26].map!(height => checkQuorum(Height(height))).array;
    assert(quorums.uniq().count() == quorums.count(),
        format!"The quorums should be unique not %s"
        (quorums.fold!((a, b) => format!"%s\n%s"(a, b))("")));
}
