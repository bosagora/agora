/*******************************************************************************

    Test node restarting behavior

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Restart;

version (unittest):

import agora.api.Validator;
import agora.consensus.data.Transaction;
import agora.test.Base;

/// A test that stops and restarts a node
unittest
{
    TestConf conf = { validators : 6 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(1));

    // Now shut down & restart one node
    auto restartMe = nodes[$-1];
    network.restart(restartMe);
    network.waitForDiscovery();
    network.expectBlock(Height(1));
}
