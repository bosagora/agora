/*******************************************************************************

    Test the public API with invalid parameters

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.API;

version (unittest):

import agora.crypto.Hash;
import agora.test.Base;

/// https://github.com/bosagora/agora/issues/2593
unittest
{
    auto network = makeTestNetwork!TestAPIManager(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // Generate an empty block
    network.generateBlocks(Height(1), true);
    assert(node_1.getBlock(1).txs.length == 0);
    assert(node_1.getMerklePath(1, "Hello World".hashFull()).length == 0);
}
