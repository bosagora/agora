/*******************************************************************************

    Contains the simplest possible block creating test

    This is useful as a starting point for creating more complext test-cases,
    or just to test new behavior with the simplest creation of blocks.

    Run via:
    $ dtest=agora.test.Simple dub test

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Simple;

version (unittest):

import agora.test.Base;

/// Simple test with 4 nodes
unittest
{
    TestConf conf;
    conf.node.test_validators = 4;
    simpleTest(conf);
}

public void simpleTest (TestConf conf)
{
    conf.consensus.payout_period = 8;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // Create blocks for 2 validator cycles and a couple more
    auto target_height = Height(2 * GenesisValidatorCycle + 2);
    Height last_height = Height(0);
    // Use stride of payout period as otherwise sometimes signatures will never catch up
    iota(Height(conf.consensus.payout_period), target_height + 1)
        .stride(Height(conf.consensus.payout_period))
        .each!((Height h)
    {
        network.generateBlocks(h);
        network.assertSameBlocks(h, last_height + 1);
        // Make sure the blocks are not empty
        uint blocks = (h - last_height - 1).to!uint;
        node_1.getBlocksFrom(last_height + 1, blocks)
            .each!(block => assert(block.txs.count > 0,
                format!"No txs in block %s"(block.header.height)));
        last_height = h;
    });
}
