/*******************************************************************************

    Contains tests for the functionality of the NetworkClient.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.NetworkClient;

version (unittest):

import agora.common.crypto.Key;
import agora.common.Block;
import agora.common.Data;
import agora.common.Hash;
import agora.common.Transaction;
import agora.consensus.Genesis;
import agora.test.Base;

/// test retrying requests after failure
unittest
{
    import std.algorithm;
    import std.range;
    import core.thread;

    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();
    scope(exit) network.shutdown();
    assert(network.getDiscoveredNodes().length == NodeCount);

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    // block periodic getBlocksFrom
    node_1.filter!(node_1.getBlocksFrom);

    // reject inbound requests
    nodes[1 .. $].each!(node => node.filter!(node.putTransaction));

    auto txes = makeChainedTransactions(getGenesisKeyPair(), null, 1);

    // node 1 will keep trying to send transactions up to
    // (max_retries * retry_delay) seconds (see Base.d)
    txes.each!(tx => node_1.putTransaction(tx));

    // clear filter after 100 msecs, the above requests will eventually be gossiped
    Thread.sleep(100.msecs);
    nodes[1 .. $].each!(node => node.clearFilter());

    auto attempts = 20;  // wait up to 20*100 msecs (2 seconds)
    while (attempts--)
    {
        if (nodes.all!(node => node.getBlockHeight() == 1))
            return;

        Thread.sleep(100.msecs);
    }

    assert(0, "Nodes should have same block height");
}
