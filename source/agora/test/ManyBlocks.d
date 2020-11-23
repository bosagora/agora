/*******************************************************************************

    Testing generastion of many blocks with re-enrolling every cycle

    This is useful as a starting point for testing many blocks can be created.

    Run via:
    $ dtest=agora.test.ManyBlocks dub test

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.ManyBlocks;

version (unittest):

import agora.test.Base;

/// Simple test
unittest
{
    TestConf conf = {
        txs_to_nominate : 1,
        quorum_threshold : 100
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto target_height = Height(101);
    network.generateBlocks(target_height);
    network.assertSameBlocks(target_height);
}
