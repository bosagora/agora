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
import agora.common.Hash;
import agora.consensus.data.Transaction;
import agora.test.Base;

import std.exception;
import std.range;

///
unittest
{
    TestConf conf = { validators : 5, txs_to_nominate : 2,
        block_interval_sec : 1, max_quorum_nodes : 5, quorum_threshold : 100
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // sanity check for the generated quorum config
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getQuorumConfig().threshold == 5 &&
            node.getQuorumConfig().nodes.length == 5, 5.seconds,
            format("Node %s has the wrong quorum config. Expecte 3/5. Got: %s",
                idx, node.getQuorumConfig())));

    // set the time to `height` * `block_interval_sec` for 4/5 nodes
    // clock times for nodes:    [ 1,  1,  1,  1,  0] median => 1
    // calculated clock offset:  [+0, +0, +0, +0, +1]
    network.setTimeFor(network.nodes.take(4), Height(1));
    retryFor(nodes[0].getLocalTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[1].getLocalTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[2].getLocalTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[3].getLocalTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[4].getLocalTime() == 0 + network.genesis_start_time, 5.seconds);

    network.synchronizeClocks();  // net-sync all clocks
    retryFor(nodes[0].getNetworkTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[1].getNetworkTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[2].getNetworkTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[3].getNetworkTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[4].getNetworkTime() == 1 + network.genesis_start_time, 5.seconds,
        format("Expected %s. Got %s", 1 + network.genesis_start_time,
            nodes[4].getNetworkTime()));

    // prepare 8 txs: can generate 4 blocks with 2 txs each
    auto spendable = network.blocks[0].txs
        .filter!(tx => tx.type == TxType.Payment)
        .map!(tx => iota(tx.outputs.length)
            .map!(idx => TxBuilder(tx, cast(uint)idx)))
        .joiner().take(8).array;

    auto txs = spendable
        .map!(txb => txb.refund(WK.Keys.Genesis.address).sign())
        .array;

    txs.take(2).each!(tx => nodes[0].putTransaction(tx));
    // wait for propagation
    nodes.each!(node =>
       txs.take(2).each!(tx =>
           node.hasTransactionHash(hashFull(tx)).retryFor(4.seconds)
    ));
    txs.popFrontN(2);

    // 5/5 nodes accepted
    ensureConsistency(nodes, 1, 5.seconds);

    // clock times for nodes:    [ 1,  1,  1,  1,  2] median => 1
    // calculated clock offset:  [+0, +0, +0, +0, -1]
    network.setTimeFor(network.nodes[0].only, Height(1));
    network.setTimeFor(network.nodes[1].only, Height(1));
    network.setTimeFor(network.nodes[2].only, Height(1));
    network.setTimeFor(network.nodes[3].only, Height(1));
    network.setTimeFor(network.nodes[4].only, Height(2));
    retryFor(nodes[0].getLocalTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[1].getLocalTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[2].getLocalTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[3].getLocalTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[4].getLocalTime() == 2 + network.genesis_start_time, 5.seconds);

    network.synchronizeClocks();  // net-sync all clocks
    retryFor(nodes[0].getNetworkTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[1].getNetworkTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[2].getNetworkTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[3].getNetworkTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[4].getNetworkTime() == 1 + network.genesis_start_time, 5.seconds);

    txs.take(2).each!(tx => nodes[0].putTransaction(tx));
    // wait for propagation
    nodes.each!(node =>
       txs.take(2).each!(tx =>
           node.hasTransactionHash(hashFull(tx)).retryFor(4.seconds)
    ));
    txs.popFrontN(2);

    // calculated net clock is still at height 1 => no blocks created
    assertThrown(ensureConsistency!Exception(nodes, 2, 5.seconds));

    // clock times for nodes:    [ 1,  1,  1,  2,  2] median => 1
    // calculated clock offset:  [+0, +0, +0, -1, -1]
    network.setTimeFor(network.nodes[0].only, Height(1));
    network.setTimeFor(network.nodes[1].only, Height(1));
    network.setTimeFor(network.nodes[2].only, Height(1));
    network.setTimeFor(network.nodes[3].only, Height(2));
    network.setTimeFor(network.nodes[4].only, Height(2));
    retryFor(nodes[0].getLocalTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[1].getLocalTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[2].getLocalTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[3].getLocalTime() == 2 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[4].getLocalTime() == 2 + network.genesis_start_time, 5.seconds);

    network.synchronizeClocks();  // net-sync all clocks
    retryFor(nodes[0].getNetworkTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[1].getNetworkTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[2].getNetworkTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[3].getNetworkTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[4].getNetworkTime() == 1 + network.genesis_start_time, 5.seconds);

    // calculated net clock is still at height 1 => no blocks created
    assertThrown(ensureConsistency!Exception(nodes, 2, 5.seconds));

    // clock times for nodes:    [ 1,  1,  2,  2,  2] median => 2
    // calculated clock offset:  [+1, +1,  0,  0,  0]
    network.setTimeFor(network.nodes[0].only, Height(1));
    network.setTimeFor(network.nodes[1].only, Height(1));
    network.setTimeFor(network.nodes[2].only, Height(2));
    network.setTimeFor(network.nodes[3].only, Height(2));
    network.setTimeFor(network.nodes[4].only, Height(2));
    retryFor(nodes[0].getLocalTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[1].getLocalTime() == 1 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[2].getLocalTime() == 2 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[3].getLocalTime() == 2 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[4].getLocalTime() == 2 + network.genesis_start_time, 5.seconds);

    network.synchronizeClocks();  // net-sync all clocks
    retryFor(nodes[0].getNetworkTime() == 2 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[1].getNetworkTime() == 2 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[2].getNetworkTime() == 2 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[3].getNetworkTime() == 2 + network.genesis_start_time, 5.seconds);
    retryFor(nodes[4].getNetworkTime() == 2 + network.genesis_start_time, 5.seconds);

    // calculated net clock is at height 2 => create a new block
    ensureConsistency(nodes, 2, 5.seconds);
}
