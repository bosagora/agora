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
import agora.common.Types;
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
    auto network = makeTestNetwork(NetworkTopology.Simple, NodeCount);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    assert(network.getDiscoveredNodes().length == NodeCount);

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    nodes.each!(node => assert(node.getBlockHeight() == 0));

    Transaction[] last_txs;
    // create enough tx's for a single block
    auto txs = makeChainedTransactions(getGenesisKeyPair(), last_txs, 1);

    auto send_txs = txs[0..$-1];
    // send it to tx to node
    send_txs.each!(tx => node_1.putTransaction(tx));
    // gossip was complete
    nodes.each!(node =>
       send_txs.each!(tx =>
           node.hasTransactionHash(hashFull(tx)).retryFor(2.seconds)
    ));
    // When a block is created, the transaction is deleted from the transaction pool.
    node_1.putTransaction(txs[$-1]);
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == 1,
        2.seconds,
        format("Node %s has block height %s. Expected: %s",
        idx,
        node.getBlockHeight().to!string,
        1)));

    nodes.each!(node =>
        txs.each!(tx =>
            (!node.hasTransactionHash(hashFull(tx))).retryFor(2.seconds)));
}
