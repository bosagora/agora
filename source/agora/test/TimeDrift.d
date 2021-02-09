/*******************************************************************************

    Tests consensus-reaching behavior when the nodes' clocks start to drift.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.TimeDrift;

version (unittest):

import agora.api.Validator;
import agora.consensus.data.Transaction;
import agora.crypto.Hash;
import agora.test.Base;
import agora.consensus.data.genesis.Test : GenesisBlock;

import std.exception;
import std.range;

///
unittest
{
    TestConf conf = { txs_to_nominate : 2,
        block_interval_sec : 1, max_quorum_nodes : 5, quorum_threshold : 100
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    // Make sure nodes have revealed their preimage for height 1
    network.waitForPreimages(GenesisBlock.header.enrollments, 1);

    // sanity check for the generated quorum config
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getQuorumConfig().threshold == conf.max_quorum_nodes &&
                node.getQuorumConfig().nodes.length == conf.max_quorum_nodes,
            5.seconds,
            format("Node #%s has invalid quorum config for test: %s",
                idx, node.getQuorumConfig())));

    // Check the node local time
    void checkNodeLocalTime (ulong idx, ulong expected_height)
    {
        retryFor(nodes[idx].getLocalTime() == expected_height +
            network.test_start_time, 5.seconds,
            format!"Expected node #%s would have time of height %s not %s"
                (idx, expected_height,
                    nodes[idx].getLocalTime() - network.test_start_time));
    }

    // Check the node network time
    void checkNodeNetworkTime (ulong idx, ulong expected_height)
    {
        retryFor(nodes[idx].getNetworkTime() == expected_height +
            network.test_start_time, 5.seconds,
            format!"Expected node #%s would have time of height %s not %s"
                (idx, expected_height, nodes[idx].getNetworkTime() -
                    network.test_start_time));
    }

    // clock times for nodes:    [ 1,  1,  1,  1,  1, 0] median => 1
    // calculated clock offset:  [+0, +0, +0, +0, +0, +1]

    // set the time to `height` * `block_interval_sec` for 5/6 nodes
    assert(conf.block_interval_sec == 1);
    network.setTimeFor(network.nodes.take(5), Height(1));
    [ 1,  1,  1,  1,  1, 0].enumerate.each!((idx, height) =>
        checkNodeLocalTime(idx, height));

    network.synchronizeClocks();  // net-sync all clocks
    [ 1,  1,  1,  1,  1, 1].enumerate.each!((idx, height) =>
        checkNodeNetworkTime(idx, height));

    // Take 8 spendable tx enough to create 4 blocks
    auto txs = genesisSpendable.takeExactly(8)
        .map!(txb => txb.refund(WK.Keys.Genesis.address).sign())
        .array;

    txs.take(2).each!(tx => nodes[0].putTransaction(tx));
    // wait for propagation
    nodes.each!(node =>
       txs.take(2).each!(tx =>
           node.hasTransactionHash(hashFull(tx)).retryFor(4.seconds)
    ));
    txs.popFrontN(2);

    // 6/6 nodes accepted
    network.assertSameBlocks(Height(1));

    // clock times for nodes:    [ 1,  1,  1,  1,  1, 2] median => 1
    // calculated clock offset:  [+0, +0, +0, +0, +0, -1]
    [ 1,  1,  1,  1,  1, 2].enumerate.each!((idx, time) =>
        network.setTimeFor(network.nodes[idx].only, Height(time)));

    [ 1,  1,  1,  1,  1, 2].enumerate.each!((idx, height) =>
        checkNodeLocalTime(idx, height));

    network.synchronizeClocks();  // net-sync all clocks

    [ 1,  1,  1,  1,  1, 1].enumerate.each!((idx, height) =>
        checkNodeNetworkTime(idx, height));

    // Make sure nodes have revealed their preimage for height 2
    network.waitForPreimages(GenesisBlock.header.enrollments, 2);

    txs.take(2).each!(tx => nodes[0].putTransaction(tx));
    // wait for propagation
    nodes.each!(node =>
       txs.take(2).each!(tx =>
           node.hasTransactionHash(hashFull(tx)).retryFor(4.seconds)
    ));
    txs.popFrontN(2);

    // calculated net clock is still at height 1 => no blocks created
    network.assertSameBlocks(Height(1));

    // clock times for nodes:    [ 1,  1,  1,  1,  2, 2] median => 1
    // calculated clock offset:  [+0, +0, +0, +0, -1, -1]
    [ 1,  1,  1,  1,  2, 2].enumerate.each!((idx, time) =>
        network.setTimeFor(network.nodes[idx].only, Height(time)));

    [ 1,  1,  1,  1,  2, 2].enumerate.each!((idx, height) =>
        checkNodeLocalTime(idx, height));

    network.synchronizeClocks();  // net-sync all clocks

    [ 1,  1,  1,  1,  1, 1].enumerate.each!((idx, height) =>
        checkNodeNetworkTime(idx, height));

    // calculated net clock is still at height 1 => no blocks created
    network.assertSameBlocks(Height(1));

    // clock times for nodes:    [ 1,  1,  2,  2,  2, 2] median => 2
    // calculated clock offset:  [+1, +1,  0,  0,  0, 0]

    [ 1,  1,  2,  2,  2, 2].enumerate.each!((idx, time) =>
        network.setTimeFor(network.nodes[idx].only, Height(time)));

    [ 1,  1,  2,  2,  2, 2].enumerate.each!((idx, height) =>
        checkNodeLocalTime(idx, height));

    network.synchronizeClocks();  // net-sync all clocks

    [ 2,  2,  2,  2,  2, 2].enumerate.each!((idx, height) =>
        checkNodeNetworkTime(idx, height));

    // calculated net clock is at height 2 => create a new block
    network.assertSameBlocks(iota(GenesisValidators), Height(2));
}
