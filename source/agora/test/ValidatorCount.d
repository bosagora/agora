/*******************************************************************************

    The creation of a block must stop immediately just before all the
    active validators is expired.
    This is to allow additional enrollment of validators.
    Enrollment's cycle is `ConsensusParams.validator_cycle`,
    If none of the active validators exist at height `validator_cycle`,
    block generation must stop at height `validator_cycle`-1.

    This code tests these.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.ValidatorCount;

version (unittest):

import agora.consensus.data.ConsensusParams;
import agora.consensus.data.Transaction;
import agora.test.Base;

import core.thread;

/// ditto
unittest
{
    auto network = makeTestNetwork(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto gen_key_pair = WK.Keys.Genesis;
    // Get the genesis block, make sure it's the only block externalized
    auto blocks = node_1.getBlocksFrom(0, 2);

    Transaction[] txs;

    // create validator_cycle - 1 blocks
    foreach (block_idx; 1 .. network.validator_cycle)
    {
        // create enough tx's for a single block
        txs = blocks[block_idx - 1].spendable().map!(txb => txb.sign()).array();

        // send it to one node
        txs.each!(tx => node_1.putTransaction(tx));
        network.expectBlock(Height(block_idx), blocks[0].header, 5.seconds);

        // add next block
         blocks ~= node_1.getBlocksFrom(block_idx, 1);
    }

    // Block will not be created because otherwise there would be no active validators
    {
        txs = blocks[network.validator_cycle - 1].spendable().map!(txb => txb.sign()).array();
        txs.each!(tx => node_1.putTransaction(tx));

        // try to add next block
         blocks ~= node_1.getBlocksFrom(network.validator_cycle, 1);
    }

    network.setTimeFor(Height(network.validator_cycle));  // trigger consensus round
    Thread.sleep(2.seconds);  // wait for propagation

    // New block was not created because all validators would expire
    containSameBlocks(nodes, network.validator_cycle - 1).retryFor(5.seconds);
}
