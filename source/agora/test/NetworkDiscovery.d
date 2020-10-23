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
    TestConf conf = TestConf.init;
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    foreach (key, node; network.nodes)
    {
        auto addresses = node.client.getNodeInfo().addresses.keys;
        assert(addresses.sort.uniq.count == conf.validators - 1,
               format("Node %s has %d peers: %s", key, addresses.length, addresses));
    }
}

/// test network discovery through the getNodeInfo() API
unittest
{
    TestConf conf =
    {
        topology : NetworkTopology.MinimallyConnected,
        full_nodes : 4,
        min_listeners : 9,
    };
    auto network = makeTestNetwork(conf);

    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    foreach (key, node; network.nodes)
    {
        auto addresses = node.client.getNodeInfo().addresses.keys;
        assert(addresses.sort.uniq.count == 9,
               format("Node %s has %d peers: %s", key, addresses.length, addresses));
    }
}

/// test finding all quorum nodes before network discovery is complete
unittest
{
    TestConf conf =
    {
        topology : NetworkTopology.MinimallyConnected,
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
        assert(addresses.sort.uniq.count == 5,
               format("Node %s has %d peers: %s", key, addresses.length, addresses));
    }
}
