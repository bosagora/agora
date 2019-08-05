/*******************************************************************************

    Contains tests for the tests & error-handling of the NetworkManager

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.NetworkManager;

version (unittest):

import agora.common.API;
import agora.common.Transaction;
import agora.consensus.Genesis;
import agora.test.Base;

/// test behavior when getBlockHeight() call fails
unittest
{
    import std.algorithm;
    import std.range;
    import core.thread;

    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();
    assert(network.getDiscoveredNodes().length == NodeCount);

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    // first two nodes will fail, second two should work
    nodes[0].filter!(API.getBlockHeight);
    nodes[1].filter!(API.getBlockHeight);

    auto txes = makeChainedTransactions(getGenesisKeyPair(), null, 1);
    txes.each!(tx => node_1.putTransaction(tx));

    Thread.sleep(2000.msecs);

    nodes[0].clearFilter();
    nodes[1].clearFilter();

    auto attempts = 20;  // wait up to 20*100 msecs (2 seconds)
    while (attempts--)
    {
        if (nodes.all!(node => node.getBlockHeight() == 1))
            return;

        Thread.sleep(100.msecs);
    }

    assert(0, "Nodes should have same block height");
}
