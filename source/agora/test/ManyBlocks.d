/*******************************************************************************

    Testing generastion of many blocks with re-enrolling every cycle

    This is useful as a starting point for testing many blocks can be created.

    Run via:
    $ dtest=agora.test.ManyBlocks dub test

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
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
    TestConf conf = { quorum_threshold : 100, payout_period : 200 };
    auto network = makeTestNetwork!TestAPIManager(conf);
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
