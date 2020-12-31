/*******************************************************************************

    Contains tests for the fee distribution

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Fee;

import agora.test.Base;
import agora.consensus.data.Transaction;
import agora.common.Amount;

// Normal operation, every `payout_period`th block should
// include coinbase outputs to validators
unittest
{
    import core.thread;

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
        txs = blocks[new_block_height - 1].spendable().map!(txb => txb
            .sign()).array();

        // send it to one node
        txs.each!(tx => node_1.putTransaction(tx));

        network.expectBlock(new_block_height, blocks[0].header);

        // add next block
        blocks ~= node_1.getBlocksFrom(new_block_height, 1);
/*
        auto cb_txs = blocks[$-1].txs.filter!(tx => tx.type == TxType.Coinbase)
            .array;
        assert(cb_txs.length == 1);
        auto cb_outs = cb_txs[0].outputs;

        // Regular block
        if (blocks[$-1].header.height % conf.payout_period)
            assert(cb_outs.length == 1);
        else // Payout block
            assert(cb_outs.length == 1 + blocks[0].header.enrollments.length);*/
    }

    // create GenesisValidatorCycle - 1 blocks
    foreach (block_idx; 1 .. GenesisValidatorCycle * 2)
    {
        createAndExpectNewBlock(Height(block_idx));
    }
}

