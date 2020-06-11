/*******************************************************************************

    Contains the simplest possible block creating test

    This is useful as a starting point for creating more complext test-cases,
    or just to test new behavior with the simplest creation of blocks.

    Run via:
    $ dtest=agora.test.Simple dub test

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Simple;

version (unittest):

import agora.api.Validator;
import agora.consensus.data.Transaction;
import agora.consensus.Genesis;
import agora.test.Base;

/// Simple test
unittest
{
    auto network = makeTestNetwork(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto txes = makeChainedTransactions([WK.Keys.Genesis.address],
        genesisSpendable(), 1);
    txes.each!(tx => node_1.putTransaction(tx));

    nodes.all!(node => node.getBlockHeight() == 1)
        .retryFor(2.seconds);
}
