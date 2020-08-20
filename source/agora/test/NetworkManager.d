/*******************************************************************************

    Contains tests for the tests & error-handling of the NetworkManager

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.NetworkManager;

version (unittest):

import agora.api.Validator;
import agora.common.BanManager;
import agora.common.Config;
import agora.common.crypto.Key;
import agora.common.Metadata;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.ConsensusParams;
import agora.consensus.data.Transaction;
import agora.test.Base;

import geod24.Registry;
import std.array;

/// test behavior when getBlockHeight() call fails
unittest
{
    auto network = makeTestNetwork(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // first two nodes will fail, second two should work
    nodes[0].filter!(API.getBlockHeight);
    nodes[1].filter!(API.getBlockHeight);

    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => node_1.putTransaction(tx));

    nodes[0].clearFilter();
    nodes[1].clearFilter();
    network.expectBlock(Height(1), 2.seconds);
}

/// test behavior when a node sends bad block data
unittest
{
    /// node which returns bad blocks
    static class BadNode : TestFullNode
    {
        ///
        public this (Config config, Registry* reg, immutable(Block)[] blocks)
        {
            super(config, reg, blocks);
        }

        /// return phony blocks
        public override const(Block)[] getBlocksFrom (ulong block_height,
            uint max_blocks)
        {
            Block[] blocks;
            Transaction[] last_tx;

            auto prev_key = () @trusted { return KeyPair.random(); }();

            Block last_block;
            // make 20 blocks which have an invalid previous hash
            foreach (idx; 0 .. 20)
            {
                auto txs = makeChainedTransactions(prev_key, last_tx, 1);
                last_tx = txs;
                auto block = makeNewBlock(last_block, txs);

                blocks ~= block;
                last_block = block;
            }

            return blocks;
        }

        /// return block length as returned by function above
        public override ulong getBlockHeight () { return 20; }
    }

    static class BadAPIManager : TestAPIManager
    {
        ///
        public this (immutable(Block)[] blocks, TestConf test_conf)
        {
            super(blocks, test_conf);
        }

        /// see base class
        public override void createNewNode (Config conf, string file, int line)
        {
            RemoteAPI!TestAPI api;

            // the test has 3 nodes:
            // 1 validator => used for creating blocks
            // 1 byzantine FullNode => lies about the blockchain
            //   (returns syntactically invalid data)
            // 1 good FullNode => it accepts only the valid blockchain
            if (conf.node.is_validator)
            {
                api = RemoteAPI!TestAPI.spawn!TestValidatorNode(
                    conf, &this.reg, this.blocks, this.test_conf.txs_to_nominate,
                    conf.node.timeout);
            }
            else
            {
                if (this.nodes.length == 2)
                    api = RemoteAPI!TestAPI.spawn!BadNode(conf,
                        &this.reg, this.blocks, conf.node.timeout);
                else
                    api = RemoteAPI!TestAPI.spawn!TestFullNode(conf,
                        &this.reg, this.blocks, conf.node.timeout);
            }

            this.reg.register(conf.node.address, api.tid());
            this.nodes ~= NodePair(conf.node.address, api);
        }
    }

    TestConf conf = { validators : 1, full_nodes : 2 };
    auto network = makeTestNetwork!BadAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_validator = nodes[0];  // validator, creates blocks
    auto node_test = nodes[1];  // full node, does not create blocks
    auto node_bad = nodes[2];  // full node, returns bad blocks in getBlocksFrom()

    // enable filtering first
    node_validator.filter!(API.getBlocksFrom);
    node_bad.filter!(API.getBlocksFrom);
    node_test.filter!(API.putTransaction);

    Transaction[][] block_txes; /// per-block array of transactions (genesis not included)
    Transaction[] last_txs;

    // create genesis block
    last_txs = genesisSpendable().map!(txb => txb.sign()).array();
    last_txs.each!(tx => node_validator.putTransaction(tx));
    network.expectBlock([node_validator], Height(1), 4.seconds);
    block_txes ~= last_txs.sort.array;

    foreach (block_idx; 1 .. 10)  // create 9 additional blocks
    {
        // create enough tx's for a single block
        auto txs = last_txs.map!(tx => TxBuilder(tx).sign()).array();
        // send it to one node
        txs.each!(tx => node_validator.putTransaction(tx));
        network.expectBlock([node_validator], Height(block_idx + 1), 4.seconds);
        block_txes ~= txs.sort.array;
        last_txs = txs;
    }

    // the validator node has 10 blocks, but bad node pretends to have 20
    assert(node_validator.getBlockHeight() == 10, node_validator.getBlockHeight().to!string);
    assert(node_bad.getBlockHeight() == 20);
    assert(node_test.getBlockHeight() == 0);  // only genesis

    node_bad.clearFilter();
    node_validator.clearFilter();

    // node test will accept its blocks from node_validator,
    // as the blocks in node_bad do not pass validation
    retryFor(node_test.getBlockHeight() == 10, 4.seconds);
    assert(containSameBlocks([node_test, node_validator], 10));
}
