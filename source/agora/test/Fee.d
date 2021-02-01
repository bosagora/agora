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
            .deduct(Amount.UnitPerCoin).sign()).array();

        // send it to one node
        txs.each!(tx => node_1.putTransaction(tx));

        network.expectBlock(new_block_height, blocks[0].header);

        // add next block
        blocks ~= node_1.getBlocksFrom(new_block_height, 1);

        auto cb_txs = blocks[$-1].txs.filter!(tx => tx.type == TxType.Coinbase)
            .array;
        assert(cb_txs.length == 1);
        auto cb_outs = cb_txs[0].outputs;

        // Regular block
        if (blocks[$-1].header.height % conf.payout_period)
            assert(cb_outs.length == 1);
        else // Payout block
            assert(cb_outs.length == 1 + blocks[0].header.enrollments.length);
    }

    // create GenesisValidatorCycle - 1 blocks
    foreach (block_idx; 1 .. GenesisValidatorCycle)
    {
        createAndExpectNewBlock(Height(block_idx));
    }
}

// One of the nodes have different config, will try to pay different amounts
// at different heights. With 100 quorum threshold, no blocks should be created
unittest
{
    import agora.consensus.data.Block;
    import agora.common.Config;
    import core.thread;

    TestConf conf = {
        quorum_threshold : 100
    };

    static class LocalAPIManager : TestAPIManager
    {
        public this (immutable(Block)[] blocks, TestConf test_conf,
            TimePoint initial_time)
        {
            super(blocks, test_conf, initial_time);
        }

        public override void createNewNode (Config conf, string file = __FILE__,
            int line = __LINE__)
        {
            if (this.nodes.length == 0)
            {
                assert(conf.validator.enabled);
                conf.consensus.validator_tx_fee_cut = 50;
                conf.consensus.payout_period = 7;
            }
            super.createNewNode(conf, file, line);
        }
    }

    auto network = makeTestNetwork!LocalAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto valid_node = nodes[$-1];

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = valid_node.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    Transaction[] txs;

    // create enough tx's for a single block
    txs = blocks[0].spendable().map!(txb => txb
        .deduct(Amount.UnitPerCoin).sign()).array();

    // send it to one node
    txs.each!(tx => valid_node.putTransaction(tx));

    network.setTimeFor(Height(1));
    Thread.sleep(1.seconds);

    // Assert no block was created
    network.assertSameBlocks(Height(0));
}

// One of the nodes have different config, will try to pay different amounts
// at different heights. With 80 quorum threshold, consensus should be reached
unittest
{
    import agora.consensus.data.Block;
    import agora.common.Config;
    import core.thread;

    TestConf conf = {
        quorum_threshold : 80
    };

    static class LocalAPIManager : TestAPIManager
    {
        public this (immutable(Block)[] blocks, TestConf test_conf,
            TimePoint initial_time)
        {
            super(blocks, test_conf, initial_time);
        }

        public override void createNewNode (Config conf, string file = __FILE__,
            int line = __LINE__)
        {
            if (this.nodes.length == 0)
            {
                assert(conf.validator.enabled);
                conf.consensus.validator_tx_fee_cut = 50;
                conf.consensus.payout_period = 7;
            }
            super.createNewNode(conf, file, line);
        }
    }

    auto network = makeTestNetwork!LocalAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto valid_node = nodes[$-1];

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = valid_node.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    Transaction[] txs;

    void createAndExpectNewBlock (Height new_block_height)
    {
        // create enough tx's for a single block
        txs = blocks[new_block_height - 1].spendable().map!(txb => txb
            .deduct(Amount.UnitPerCoin).sign()).array();

        // send it to one node
        txs.each!(tx => valid_node.putTransaction(tx));

        network.expectBlock(iota(1, GenesisValidators),
            new_block_height, blocks[0].header);

        // add next block
        blocks ~= valid_node.getBlocksFrom(new_block_height, 1);

        auto cb_txs = blocks[$-1].txs.filter!(tx => tx.type == TxType.Coinbase)
            .array;
        assert(cb_txs.length == 1);
        auto cb_outs = cb_txs[0].outputs;

        // Regular block
        if (blocks[$-1].header.height % conf.payout_period)
            assert(cb_outs.length == 1);
        else // Payout block
            assert(cb_outs.length == 1 + blocks[0].header.enrollments.length);
    }

    // create GenesisValidatorCycle - 1 blocks
    foreach (block_idx; 1 .. conf.payout_period + 1)
    {
        createAndExpectNewBlock(Height(block_idx));
    }

    // Node with the different config should not accept any blocks
    auto bad_node = nodes[0];
    assert(bad_node.getBlockHeight() == Height(0));
}
