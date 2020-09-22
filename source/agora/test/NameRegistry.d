/*******************************************************************************

    Test for the NameRegistry functionality

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
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
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery(10.seconds);

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(1), 2.seconds);
}
