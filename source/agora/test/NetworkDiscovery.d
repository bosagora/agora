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
        auto addresses = node.client.getNodeInfo().addresses.keys;
        assert(addresses.sort.uniq.count == conf.nodes - 1,
               format("Node %s has %d peers: %s", key, addresses.length, addresses));
    }
}

/// test network discovery through the getNodeInfo() API
unittest
{
    import std.algorithm;
    import std.format;

    TestConf conf =
    {
        topology : NetworkTopology.FindNetwork,
        nodes : 4,
        min_listeners : 3,
    };
    auto network = makeTestNetwork(conf);

    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    foreach (key, node; network.nodes)
    {
        auto addresses = node.client.getNodeInfo().addresses.keys;
        assert(addresses.sort.uniq.count == 3,
               format("Node %s has %d peers: %s", key, addresses.length, addresses));
    }
}

/// test finding all quorum nodes before network discovery is complete
unittest
{
    import std.algorithm;
    import std.format;

    TestConf conf =
    {
        topology : NetworkTopology.FindQuorums,
        nodes : 4,
        min_listeners : 1
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    foreach (key, node; network.nodes)
    {
        auto addresses = node.client.getNodeInfo().addresses.keys;
        assert(addresses.sort.uniq.count == 3,
               format("Node %s has %d peers: %s", key, addresses.length, addresses));
    }
}
