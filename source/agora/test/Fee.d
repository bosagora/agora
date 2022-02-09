/*******************************************************************************

    Contains tests for the fee distribution

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Fee;

import agora.test.Base;

import std.typecons: tuple;

// Normal operation, every `payout_period`th block should
// include coinbase outputs to validators
unittest
{
    TestConf conf;
    conf.consensus.quorum_threshold = 100;
    conf.consensus.payout_period = 5;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = node_1.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    void createAndExpectNewBlock (Height new_height)
    {
        // create tx for a single block
        auto utxo_pairs = node_1.getSpendables(100.coins);

        // create and send tx to all nodes
        network.postAndEnsureTxInPool(
            TxBuilder(WK.Keys.AAA.address)
            .attach(utxo_pairs.map!(p => tuple(p.utxo.output, p.hash)))
            .deduct(1.coins).sign());

        network.expectHeightAndPreImg(new_height, blocks[0].header);

        // add next block
        blocks ~= node_1.getBlocksFrom(new_height, 1);

        auto cb_txs = blocks[$-1].txs.filter!(tx => tx.isCoinbase).array;
        // Regular block
        if (blocks[$-1].header.height < 2 * conf.consensus.payout_period
            || blocks[$-1].header.height % conf.consensus.payout_period)
            assert(cb_txs.length == 0);
        else // Payout block
        {
            assert(cb_txs.length == 1);
            auto cb_outs = cb_txs[0].outputs;
            assert(cb_outs.length == 1 + blocks[0].header.enrollments.length);
        }
    }

    // create GenesisValidatorCycle - 1 blocks
    foreach (block_idx; 1 .. GenesisValidatorCycle)
    {
        createAndExpectNewBlock(Height(block_idx));
    }
}

// One of the nodes have different config, will try to pay different amounts
// at different heights. With 100 quorum threshold, no blocks should be created
// Disabling this test as it is testing something that is not implemented and
// is failing now some test configuration has been updated and the block is
// created faster so within the 1 second sleep.
version (none)
unittest
{
    import core.thread;

    TestConf conf;
    conf.consensus.quorum_threshold = 100;
    conf.consensus.payout_period = 5;

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
    auto valid_nodes = nodes.drop(1);

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = valid_nodes.front.getBlocksFrom(0, 2);
    assert(valid_nodes.count == nodes.count - 1);
    assert(blocks.length == 1);

    Transaction[] txs;

    // create enough tx's for a single block
    txs = blocks[0].spendable().takeExactly(1).map!(txb => txb
        .deduct(Amount.UnitPerCoin).sign()).array();

    // send them to all valid nodes
    txs.each!(tx => valid_nodes.each!(node => node.postTransaction(tx)));

    network.setTimeFor(Height(1));
    Thread.sleep(1.seconds);

    // Assert no block was created
    network.assertSameBlocks(Height(0));
}

// One of the nodes have different config, will try to pay different amounts
// at different heights. With 80 quorum threshold, consensus should be reached
unittest
{
    import core.thread;

    TestConf conf;
    conf.consensus.payout_period = 5;

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
    auto valid_nodes = nodes.drop(1);

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = valid_nodes.front.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    void createAndExpectNewBlock (Height new_height)
    {
        // create tx for a single block
        auto utxo_pairs = valid_nodes.front.getSpendables(100.coins);

        // create and send tx to all nodes
        network.postAndEnsureTxInPool(
            TxBuilder(WK.Keys.AAA.address)
            .attach(utxo_pairs.map!(p => tuple(p.utxo.output, p.hash)))
            .deduct(1.coins).sign());

        network.expectHeightAndPreImg(iota(1, GenesisValidators),
            new_height, blocks[0].header);

        // add next block
        blocks ~= valid_nodes.front.getBlocksFrom(new_height, 1);

        auto cb_txs = blocks[$-1].txs.filter!(tx => tx.isCoinbase).array;
        // Regular block
        if (blocks[$-1].header.height < 2 * conf.consensus.payout_period
            || blocks[$-1].header.height % conf.consensus.payout_period)
            assert(cb_txs.length == 0);
        else // Payout block
        {
            assert(cb_txs.length == 1);
            auto cb_outs = cb_txs[0].outputs;
            assert(cb_outs.length == 1 + blocks[0].header.enrollments.length);
        }
    }

    // create GenesisValidatorCycle - 1 blocks
    foreach (block_idx; 1 .. 2 * conf.consensus.payout_period + 1)
    {
        createAndExpectNewBlock(Height(block_idx));
    }

    // Node with the different config should not accept payout block
    auto bad_node = nodes[0];
    assert(bad_node.getBlockHeight() == Height(2 * conf.consensus.payout_period - 1));
}
