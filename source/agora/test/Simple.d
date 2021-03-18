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
import agora.test.Base;

/// Simple test
unittest
{
    TestConf conf = {
        txs_to_nominate : 1,
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // First create a block with single transaction
    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => node_1.putTransaction(tx));
    network.expectHeight(Height(1));
    network.assertSameBlocks(iota(network.nodes.length), Height(1));

    // Now create blocks until after the end of the first validator cycle
    auto target_height = Height(GenesisValidatorCycle + 2);
    network.generateBlocks(target_height);
    network.assertSameBlocks(target_height);
}
