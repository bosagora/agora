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

/// With a validator cycle of 10 and shuffle cycle of 3 we should expect
/// quorums being shuffled at these block heights:
/// 3, 6, 9, 10 (enrollment change), 13 (next shuffle cycle)
unittest
{
    import agora.common.Types;
    TestConf conf = {
        validators : 6,
        max_listeners : 7,
        extra_blocks : 2,  // 1 short of shuffle cycle
        validator_cycle : 10,
        max_quorum_nodes : 4,  // makes it easier to test shuffle cycling
        quorum_shuffle_interval : 3
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == 2, 5.seconds,
            format("Node %s has block height %s. Expected: %s",
                idx, node.getBlockHeight(), 2)));

    const keys = WK.Keys.byRange.map!(kp => kp.address).take(6).array;

    // 0 because the shuffle occured at genesis, not at block height 2
    const quorums_1 = nodes[0].getExpectedQuorums(keys, Height(0));
    // writeln(quorums_1);  // uncomment to check
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getQuorumConfig() == quorums_1[idx], 5.seconds,
            format("Node %s has quorum config %s. Expected: %s",
                idx, node.getQuorumConfig(), quorums_1[idx])));

    // check that the preimages were revealed before we trigger block creation
    // note: this is a workaround. A block should not be accepted if there
    // are no preimages for this height - however currently block signatures
    // are not implemented yet (#365)
    const enrollments = network.blocks[0].header.enrollments;
    void checkDistance (uint distance)
    {
        nodes.each!(node =>
            enrollments.each!(enr =>
                retryFor(node.getPreimage(enr.utxo_key).distance >= distance,
                    5.seconds)));
    }

    checkDistance(3);

    const(Block)[] blocks = [network.blocks[$ - 1]];
    void makeBlock (ulong height)
    {
        blocks[$ - 1].spendable.each!(txb =>
            nodes[0].putTransaction(txb.sign()));
        nodes.enumerate.each!((idx, node) =>
            retryFor(node.getBlockHeight() == height, 5.seconds,
                format("Node %s has block height %s. Expected: %s",
                    idx, node.getBlockHeight(), height)));
        retryFor((blocks = nodes[0].getBlocksFrom(height, 1)).length == 1, 5.seconds,
                format("Node 0 getBlocksFrom(%s, 1) failed", height));
    }

    // at block height 3 a shuffle should occur
    makeBlock(3);
    const quorums_2 = nodes[0].getExpectedQuorums(keys, Height(3));
    // writeln(quorums_2);  // uncomment to check
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getQuorumConfig() == quorums_2[idx], 5.seconds,
            format("Node %s has quorum config %s. Expected: %s",
                idx, node.getQuorumConfig(), quorums_2[idx])));

    checkDistance(6);  // make sure we can create the next 3 blocks

    makeBlock(4);
    makeBlock(5);
    makeBlock(6);

    const quorums_3 = nodes[0].getExpectedQuorums(keys, Height(6));
    // writeln(quorums_3);  // uncomment to check
    // at block height 6 a shuffle occured
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getQuorumConfig() == quorums_3[idx], 5.seconds,
            format("Node %s has quorum config %s. Expected: %s",
                idx, node.getQuorumConfig(), quorums_3[idx])));

    checkDistance(9);  // make sure we can create the next 3 blocks
    makeBlock(7);
    makeBlock(8);

    // at block height 10 the enrollments expire so we must re-enroll first.
    // note that this will not have any effect on the quorum shuffle at height 9,
    // it will still happen with the preimages at distance 9 and not these new
    // enrollments.
    foreach (node; nodes)
    {
        Enrollment enroll = node.createEnrollmentData();
        node.enrollValidator(enroll);

        // check enrollment
        nodes.each!(n =>
            retryFor(n.getEnrollment(enroll.utxo_key) == enroll, 5.seconds));
    }

    makeBlock(9);

    const quorums_4 = nodes[0].getExpectedQuorums(keys, Height(9));
    // writeln(quorums_4);  // uncomment to check
    // at block height 9 a shuffle occured
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getQuorumConfig() == quorums_4[idx], 5.seconds,
            format("Node %s has quorum config %s. Expected: %s",
                idx, node.getQuorumConfig(), quorums_4[idx])));

    checkDistance(1);  // re-enrolled, starts from 1 again
    makeBlock(10);

    const quorums_5 = nodes[0].getExpectedQuorums(keys, Height(10));
    // writeln(quorums_5);  // uncomment to check
    // at block height 10 the quorums shuffled because the validator set changed.
    // note: even though the same set of validators re-enrolled, the commitment
    // will be different and therefore the quorums must be shuffled.
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getQuorumConfig() == quorums_5[idx], 5.seconds,
            format("Node %s has quorum config %s. Expected: %s",
                idx, node.getQuorumConfig(), quorums_5[idx])));

    checkDistance(3);
    makeBlock(11);
    makeBlock(12);

    // before the re-enrollment the shuffle was to occur on block heights:
    // 3, 6, 9, 12
    // however the re-enrollment at 9 means the cycle reset and starts from 10,
    // so height 12 will have the same quorum set and height 13 will reshuffle.
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getQuorumConfig() == quorums_5[idx], 5.seconds,
            format("Node %s has quorum config %s. Expected: %s",
                idx, node.getQuorumConfig(), quorums_5[idx])));

    // now create the block which will shuffle
    checkDistance(4);
    makeBlock(13);

    const quorums_6 = nodes[0].getExpectedQuorums(keys, Height(13));
    // writeln(quorums_6);  // uncomment to check
    // shuffle occured on height 13
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getQuorumConfig() == quorums_6[idx], 5.seconds,
            format("Node %s has quorum config %s. Expected: %s",
                idx, node.getQuorumConfig(), quorums_6[idx])));

    // all unique quorums
    assert(quorums_2 != quorums_1);
    assert(quorums_3 != quorums_2);
    assert(quorums_4 != quorums_3);
    assert(quorums_5 != quorums_4);
    assert(quorums_6 != quorums_5);
    assert(quorums_1 != quorums_6);
}
