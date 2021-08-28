/*******************************************************************************

    Test for the NameRegistry functionality

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.
    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.NameRegistry;

version (unittest):

import agora.api.Validator;
import agora.consensus.data.Transaction;
import agora.test.Base;

/// Simple test
unittest
{
    TestConf conf = { configure_network : false };  // use name registry instead
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery(10.seconds);

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => node_1.postTransaction(tx));
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);
}
