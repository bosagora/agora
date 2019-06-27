/*******************************************************************************

    Contains tests for the node network (P2P) behavior

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Network;

version (unittest):

import agora.test.Base;

///
unittest
{
    import std.algorithm;
    import std.format;

    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();
    assert(network.getDiscoveredNodes().length == NodeCount);
    // Check that each node knows of the others
    assert(network.apis.byKey().count == NodeCount);
    foreach (key, node; network.apis)
    {
        auto addresses = node.getNetworkInfo().addresses.keys;
        assert(addresses.sort.uniq.count == NodeCount - 1,
               format("Node %s has %d peers: %s", key, addresses.length, addresses));
    }
}
