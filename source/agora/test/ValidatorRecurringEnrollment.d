/*******************************************************************************

    Ensures validators re-enroll at the end of their validator cycle
    when configured to do so

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.ValidatorRecurringEnrollment;

import agora.test.Base;
import agora.consensus.data.Transaction;

unittest
{
    TestConf conf = {
        quorum_threshold : 100
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = node_1.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    Transaction[] txs;

    void createAndExpectNewBlock (Height new_block_height)
    {
        // create enough tx's for a single block
        txs = blocks[new_block_height - 1].spendable().map!(txb => txb.sign()).array();

        // send it to one node
        txs.each!(tx => node_1.putTransaction(tx));

        network.expectBlock(new_block_height, blocks[0].header);

        // add next block
        blocks ~= node_1.getBlocksFrom(new_block_height, 1);
    }

    // create GenesisValidatorCycle - 1 blocks
    foreach (block_idx; 1 .. GenesisValidatorCycle)
    {
        createAndExpectNewBlock(Height(block_idx));
    }

    // Create one last block
    // if Validators don't re-enroll, this would fail
    createAndExpectNewBlock(Height(GenesisValidatorCycle));
    // Check if all validators in genesis are enrolled again
    assert(blocks[blocks.length - 1].header.enrollments.length == blocks[0].header.enrollments.length);
}
