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
        quorum_shuffle_interval : 6
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    Height block_height = Height(0);

    const keys = WK.Keys.byRange.map!(kp => kp.address).take(6).array;

    // check that the preimages were revealed before we trigger block creation
    // note: this is a workaround. A block should not be accepted if there
    // are no preimages for this height - however currently block signatures
    // are not implemented yet (#365)
    void checkDistance (Height height)
    {
        auto enrolled_height = Height(GenesisValidatorCycle * ((height.value - 1) / GenesisValidatorCycle));
        auto required_distance = (height - enrolled_height - 1) % GenesisValidatorCycle;
        log.trace("check distance is {} for generating block at height {} with enrollments at height {}", required_distance, height, enrolled_height);
        auto enrollments = nodes[0].getBlocksFrom(enrolled_height, 1)[0].header.enrollments;
        nodes.enumerate.each!((idx, node) =>
            enrollments.each!(enr =>
                retryFor(node.getPreimage(enr.utxo_key).distance >= required_distance, 5.seconds,
                    format!"node #%s has preimage distance %s not %s as expected"
                        (idx, node.getPreimage(enr.utxo_key).distance, required_distance))));
    }

    void makeBlock ()
    {
        nodes[0].getBlocksFrom(block_height++, 1)[0].spendable.takeExactly(8).each!(txb =>
            nodes[0].putTransaction(txb.sign()));
        log.trace("make block {}", block_height);
        checkDistance(block_height);
        log.trace("expect block {}", block_height);
        network.expectBlock(block_height);
        log.trace("Block {}:\n{}\n", block_height, prettify(nodes[0].getBlocksFrom(block_height, 1)[0]));
    }

    // at block height 20 the enrollments expire so we must re-enroll first.
    // note that this will not have any effect on the quorum shuffle at height 18,
    // it will still happen with the preimages at distance 19 and not these new
    // enrollments.
    void reEnrollNodes ()
    {
        foreach (node; nodes)
        {
            Enrollment enroll = node.createEnrollmentData();
            node.enrollValidator(enroll);

            // check enrollment
            nodes.each!(n =>
                retryFor(n.getEnrollment(enroll.utxo_key) == enroll, 5.seconds));
        }
    }

    QuorumConfig[] checkQuorum (Height height) {
        if (height > 0) // if not Genesis block
        {
            log.trace(format!"generateBlocks to height %s"(height));
            if (height % GenesisValidatorCycle == 0) { // As cycle is 20 we need to re-enroll every 20 blocks
                iota(height - block_height - 1).each!(_ => makeBlock());
                reEnrollNodes();
                makeBlock();
            }
            else
            {
                iota(height - block_height).each!(_ => makeBlock());
            }
        }
        log.trace(format!"checkQuorum for height %s"(height));
        QuorumConfig[] quorums = nodes[0].getExpectedQuorums(keys, height);
        log.trace(quorums.fold!((a, b) => format!"%s\n%s"(a, b))(""));
        nodes.enumerate.each!((idx, client) =>
            retryFor(client.getQuorumConfig() == quorums[idx], 5.seconds,
                format!"Node %s has quorum config %s. Expected: %s"
                    (idx, client.getQuorumConfig(), quorums[idx])));
        return quorums;
    }

    // We check at each expected shuffle
    auto quorums = [0, 6, 12, 18, 20, 26].map!(height => checkQuorum(Height(height))).array;
    assert(quorums.sort.uniq().count() == quorums.count(),
        format!"The quorums should be unique not %s"
            (quorums.fold!((a, b) => format!"%s\n%s"(a, b))("")));
}
