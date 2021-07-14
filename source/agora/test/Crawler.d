/*******************************************************************************

    Tests for the network crawlers, that are trying to determine node properties
    like geographical location or node OS.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Crawler;

version (unittest):

import agora.consensus.data.genesis.Test;
import agora.test.Base;
import agora.utils.Utility : retryFor;

import std.array : array;
import std.conv : to;

import core.time;
import core.thread.osthread : Thread;

///
void test_crawling (NetworkTopology topology)
{
    TestConf test_conf =
    {
        topology : topology,
        // Making sure running nodes doesn't alter the original topology
        // by switching off network discovery
        do_network_discovery : false,
        use_non_assert_get_client : true,
        collect_network_statistics : true,
        num_of_crawlers : 1,
        crawling_interval : 50.msecs,
        full_nodes : 2,
    };

    auto network = makeTestNetwork!TestAPIManager(test_conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();

    immutable expected_discovered_node_cnt = test_conf.full_nodes + genesis_validator_keys.length;
    // Check if the crawling was succesfull, and all nodes in the network
    // crawled all the other nodes (including themselves) successfully
    auto check_for_success = ()
    {
        foreach (i, client; network.clients.array())
            if (network.clients[i].getNetworkInfo().length != expected_discovered_node_cnt)
                return false;
        return true;
    };

    check_for_success().retryFor(10.seconds);
}

unittest
{
    test_crawling(NetworkTopology.MinimallyConnected);
}

unittest
{
    test_crawling(NetworkTopology.FullyConnected);
}
