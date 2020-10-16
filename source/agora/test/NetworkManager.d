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
import agora.common.Hash;
import agora.common.Metadata;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.ConsensusParams;
import agora.consensus.data.Transaction;
import agora.test.Base;

import geod24.Registry;

import std.array;

import core.stdc.time;

/// test behavior when getBlockHeight() call fails
unittest
{
    auto conf = TestConf.init;
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // last two nodes will fail, others should work
    nodes[conf.validators - 2].filter!(API.getBlockHeight);
    nodes[conf.validators - 1].filter!(API.getBlockHeight);

    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => node_1.putTransaction(tx));

    nodes[conf.validators - 2].clearFilter();
    nodes[conf.validators - 1].clearFilter();
    const b0 = nodes[0].getBlocksFrom(0, 2)[0];
    network.expectBlock(Height(1), b0.header, 2.seconds);
}

/// test behavior when a node sends bad block data
unittest
{
    /// node which returns bad blocks
    static class BadNode : TestFullNode
    {
        ///
        public this (Config config, Registry* reg, immutable(Block)[] blocks,
            shared(time_t)* cur_time)
        {
            super(config, reg, blocks, cur_time);
        }

        /// return phony blocks
        public override const(Block)[] getBlocksFrom (ulong block_height,
            uint max_blocks)
        {
            Block[] blocks;
            Transaction[] last_tx;

            auto prev_key = () @trusted { return KeyPair.random(); }();

            Block last_block;
            // make 3 blocks which have an invalid previous hash

            auto txs = genesisSpendable().map!(txb => txb.sign()).array();
            auto block = makeNewBlock(last_block, txs);
            blocks ~= block;
            last_tx = txs;
            last_block = block;

            foreach (idx; 1 .. 3)
            {
                txs = last_tx.map!(tx => TxBuilder(tx).sign()).array();
                last_tx = txs;
                block = makeNewBlock(last_block, txs);

                blocks ~= block;
                last_block = block;
            }

            auto signTx (Transaction tx) @trusted { return prev_key.secret.sign(hashFull(tx)[]); }

            foreach (block1; blocks)
            {
                foreach (idx1, txs1; block1.txs)
                {
                    foreach (idx2, txs2; block1.txs[idx1].outputs)
                        block1.txs[idx1].outputs[idx2].address = prev_key.address;
                    foreach (idx3, txs3; block1.txs[idx1].inputs)
                        block1.txs[idx1].inputs[idx3].signature = signTx(block1.txs[idx1]);
                }
                block1.header.merkle_root = block1.buildMerkleTree();
            }

            return blocks;
        }

        /// return block length as returned by function above
        public override ulong getBlockHeight () { return 3; }
    }

    static class BadAPIManager : TestAPIManager
    {
        ///
        public this (immutable(Block)[] blocks, TestConf test_conf, time_t initial_time)
        {
            super(blocks, test_conf, initial_time);
        }

        /// see base class
        public override void createNewNode (Config conf, string file, int line)
        {
            RemoteAPI!TestAPI api;
            auto time = new shared(time_t)(this.initial_time);

            // the test has 8 nodes:
            // 6 validators => used for creating blocks
            // 1 byzantine FullNode => lies about the blockchain
            //   (returns syntactically invalid data)
            // 1 good FullNode => it accepts only the valid blockchain
            if (conf.validator.enabled)
            {
                api = RemoteAPI!TestAPI.spawn!TestValidatorNode(
                    conf, &this.reg, this.blocks, this.test_conf.txs_to_nominate,
                    time, conf.node.timeout);
            }
            else
            {
                if (this.nodes.length == 6)  // 7th good FN, 8th bad FN
                    api = RemoteAPI!TestAPI.spawn!TestFullNode(conf,
                        &this.reg, this.blocks, time, conf.node.timeout);
                else
                    api = RemoteAPI!TestAPI.spawn!BadNode(conf,
                        &this.reg, this.blocks, time, conf.node.timeout);
            }

            this.reg.register(conf.node.address, api.tid());
            this.nodes ~= NodePair(conf.node.address, api, time);
        }
    }

    TestConf conf = { full_nodes : 2 };
    auto network = makeTestNetwork!BadAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_validators = nodes[0 .. conf.validators];  // validators, create blocks
    auto node_test = nodes[conf.validators];  // full node, does not create blocks
    auto node_bad = nodes[conf.validators + 1];  // full node, returns bad blocks in getBlocksFrom()

    // wait for preimages to be revealed before making blocks
    network.waitForPreimages(network.blocks[0].header.enrollments, 6,
        5.seconds);

    // enable filtering first
    nodes[1 .. conf.validators - 1].each!(node => node.filter!(API.getBlocksFrom));
    node_bad.filter!(API.getBlocksFrom);
    node_test.filter!(API.putTransaction);

    Transaction[] last_txs;

    // create next block after Genesis
    last_txs = genesisSpendable().map!(txb => txb.sign()).array();
    last_txs.each!(tx => node_validators[0].putTransaction(tx));
    network.expectBlock([node_validators[0]], Height(1), 4.seconds);

    // create 1 additional block and enough `tx`es
    auto txs = last_txs.map!(tx => TxBuilder(tx).sign()).array();
    // send it to one node
    txs.each!(tx => node_validators[0].putTransaction(tx));
    network.expectBlock([node_validators[0]], Height(2), 4.seconds);
    last_txs = txs;

    // the validator node has 2 blocks, but bad node pretends to have 3
    assert(node_validators[0].getBlockHeight() == 2, node_validators[0].getBlockHeight().to!string);
    assert(node_bad.getBlockHeight() == 3);
    assert(node_test.getBlockHeight() == 0);  // only genesis

    node_bad.clearFilter();
    node_validators.each!(node => node.clearFilter());

    // node test will accept its blocks from node_validator,
    // as the blocks in node_bad do not pass validation
    retryFor(node_test.getBlockHeight() == 2, 4.seconds);
    assert(containSameBlocks([node_test, node_validators[0]], 2));
}
