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
import agora.consensus.Genesis;
import agora.test.Base;

/// A test that stops and restarts a node
unittest
{
    auto network = makeTestNetwork(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto txes = makeChainedTransactions(WK.Keys.Genesis, null, 1);
    txes.each!(tx => node_1.putTransaction(tx));

    nodes.all!(node => node.getBlockHeight() == 1)
        .retryFor(2.seconds);

    // Now shut down & restart one node
    auto restartMe = nodes[$-1];
    network.restart(restartMe);
    network.waitForDiscovery();
    nodes.all!(node => node.getBlockHeight() == 1)
        .retryFor(5.seconds);
}
