/*******************************************************************************

    Contains tests for the node discovery behavior

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.NetworkDiscovery;

version (unittest):

import agora.test.Base;

///
unittest
{
    import std.algorithm;
    import std.format;

    TestConf conf = { nodes : 4 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    foreach (key, node; network.nodes)
    {
        auto addresses = node.client.getNetworkInfo().addresses.keys;
        assert(addresses.sort.uniq.count == conf.nodes - 1,
               format("Node %s has %d peers: %s", key, addresses.length, addresses));
    }
}
