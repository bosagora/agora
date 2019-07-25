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
import agora.common.Block;
import agora.common.Data;
import agora.common.Hash;
import agora.common.Transaction;
import agora.test.Base;

///
unittest
{
    import core.thread;
    import std.algorithm;
    import std.conv;
    import std.format;
    import std.range;

    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();
    assert(network.getDiscoveredNodes().length == NodeCount);

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    nodes.each!(node => assert(node.getBlockHeight() == 0));

    Transaction[] last_txs;
    foreach (block_idx; 0 .. 10)  // create 10 blocks
    {
        // create enough tx's for a single block
        auto txs = getChainedTransactions(getGenesisKeyPair(), Block.TxsInBlock, last_txs);

        // send it to one node
        txs.each!(tx => node_1.putTransaction(tx));

        Thread.sleep(50.msecs);  // await gossip

        // gossip was complete
        nodes.each!(node =>
            txs.each!(tx =>
                assert(node.hasTransactionHash(hashFull(tx)))
        ));

        last_txs = txs;
    }
}
