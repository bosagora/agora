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
    // 60% => 3/5
    TestConf conf = { validators : 5, txs_to_nominate : 2,
        block_interval_sec : 2, max_quorum_nodes : 5, quorum_threshold : 60 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // sanity check for the generated quorum config
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getQuorumConfig().threshold == 3 &&
            node.getQuorumConfig().nodes.length == 5, 5.seconds,
            format("Node %s has the wrong quorum config. Expecte 3/5. Got: %s",
                idx, node.getQuorumConfig())));

    auto txs = network.blocks[$ - 1].spendable.take(8).map!(txb => txb.sign());

    // 8 transactions is enough for 4 blocks with 2 txs each
    txs.each!(tx => nodes[0].putTransaction(tx));

    // wait for propagation
    nodes.each!(node =>
       txs.each!(tx =>
           node.hasTransactionHash(hashFull(tx)).retryFor(2.seconds)
    ));

    // 1 node's clock is drifting
    // 4/5 nodes accepted => consensus reached (threshold is 3)
    network.setTimeFor(network.nodes.take(4), Height(1));
    ensureConsistency(nodes, 1);

    // 2 nodes' clocks are drifting
    // 3/5 nodes accepted => consensus reached (threshold is 3)
    network.setTimeFor(network.nodes.take(3), Height(2));
    ensureConsistency(nodes, 2);

    // 3 nodes' clocks are drifting
    // 2/5 nodes accepted => consensus not reached (threshold is 3)
    network.setTimeFor(network.nodes.take(2), Height(3));
    assertThrown!Exception(ensureConsistency!Exception(nodes, 3));

    // cancel the clock drift for 1 node, allow 3/5 consensus
    network.setTimeFor(network.nodes[2].only, Height(3));
    ensureConsistency!Exception(nodes, 3);  // consenus reached again
}
