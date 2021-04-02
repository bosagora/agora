/*******************************************************************************

    Contains tests for the node discovery behavior

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
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
    TestConf conf =
    {
        retry_delay : 100.msecs,
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    foreach (key, node; network.nodes)
    {
        auto addresses = node.client.getNodeInfo().addresses.keys;
        assert(addresses.sort.uniq.count == GenesisValidators,
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
        assert(addresses.sort.uniq.count == 10,
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
        assert(addresses.sort.uniq.count == 6,
               format("Node %s has %d peers: %s", key, addresses.length, addresses));
    }
}
