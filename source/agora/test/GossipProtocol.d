/*******************************************************************************

    Contains tests for Gossip Protocol.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.GossipProtocol;

version (unittest):

import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.common.Data;
import agora.common.Hash;
import agora.consensus.data.Transaction;
import agora.consensus.Genesis;
import agora.test.Base;

///
unittest
{
    import std.algorithm;
    import std.conv;
    import std.format;
    import std.range;
    import core.time;

    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();
    scope(exit) network.shutdown();
    assert(network.getDiscoveredNodes().length == NodeCount);

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    nodes.each!(node => assert(node.getBlockHeight() == 0));

    Transaction[] last_txs;
    foreach (block_idx; 0 .. 10)  // create 10 blocks
    {
        // create enough tx's for a single block
        auto txs = makeChainedTransactions(getGenesisKeyPair(), last_txs, 1);

        // send it to one node
        txs.each!(tx => node_1.putTransaction(tx));

        // gossip was complete
        nodes.each!(node =>
            txs.each!(tx =>
                node.hasTransactionHash(hashFull(tx)).retryFor(1.seconds)
        ));

        last_txs = txs;
    }
}
