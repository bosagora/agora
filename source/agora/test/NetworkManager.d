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

import agora.consensus.data.Transaction;
import agora.consensus.Genesis;
import agora.node.API;
import agora.test.Base;

/// test behavior when getBlockHeight() call fails
unittest
{
    import std.algorithm;
    import std.range;
    import core.thread;

    const NodeCount = 4;
    auto network = makeTestNetwork(NetworkTopology.Simple, NodeCount);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    assert(network.getDiscoveredNodes().length == NodeCount);

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    // first two nodes will fail, second two should work
    nodes[0].filter!(API.getBlockHeight);
    nodes[1].filter!(API.getBlockHeight);

    auto txes = makeChainedTransactions(getGenesisKeyPair(), null, 1);
    txes.each!(tx => node_1.putTransaction(tx));

    nodes[0].clearFilter();
    nodes[1].clearFilter();

    nodes.all!(node => node.getBlockHeight() == 1)
        .retryFor(2.seconds, "Nodes should have same block height");
}

/// test behavior when a node sends bad block data
unittest
{
    import agora.common.BanManager;
    import agora.consensus.data.Block;
    import agora.common.Config;
    import agora.common.Metadata;
    import agora.common.crypto.Key;
    import core.time;
    import geod24.LocalRest;
    import std.algorithm;

    /// node which returns bad blocks
    static class BadNode : TestNode
    {
        ///
        public this (Config config)
        {
            super(config);
        }

        /// return phony blocks
        public override const(Block)[] getBlocksFrom (ulong block_height,
            uint max_blocks)
        {
            Block[] blocks;
            Transaction[] last_tx;

            auto gen_key = () @trusted { return getGenesisKeyPair(); }();

            Block last_block;
            // make 20 blocks which have an invalid previous hash
            foreach (idx; 0 .. 20)
            {
                auto txs = () @trusted { return makeChainedTransactions(gen_key, last_tx, 1); }();
                last_tx = txs;
                auto block = makeNewBlock(last_block, txs);

                // currently the only block validation the Ledger does is the height
                block.header.height = idx + 10;
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
        // base class uses a hashmap, can't depend on the order of nodes
        public RemoteAPI!TestAPI[] nodes;

        /// Initialize a new node
        public override void createNewNode (PublicKey address, Config conf)
        {
            RemoteAPI!TestAPI api;
            if (this.nodes.length == 0)
            {
                api = RemoteAPI!TestAPI.spawn!(BadNode)(conf);
            }
            else
            {
                api = RemoteAPI!TestAPI.spawn!(TestNode)(conf);
            }

            TestNetworkManager.tbn[address.toString()] = api.tid();
            this.apis[address] = api;
            this.nodes ~= api;
        }
    }

    const NodeCount = 3;
    auto network = makeTestNetwork!BadAPIManager(NetworkTopology.Simple,
        NodeCount);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    assert(network.getDiscoveredNodes().length == NodeCount);

    auto nodes = network.nodes;
    auto node_bad = nodes[0];
    auto node_good = nodes[1];
    auto node_test = nodes[2];

    // enable filtering first
    node_good.filter!(API.getBlocksFrom);
    node_bad.filter!(API.getBlocksFrom);
    node_test.filter!(API.putTransaction);

    // make 10 good blocks
    auto txes = makeChainedTransactions(getGenesisKeyPair(), null, 10);
    txes.each!(tx => node_good.putTransaction(tx));

    // at this point both the good node and bad node have same amount of blocks,
    // but bad node pretends to have + 10
    assert(node_good.getBlockHeight() == 10);
    assert(node_bad.getBlockHeight() == 20);
    assert(node_test.getBlockHeight() == 0);  // only genesis

    node_bad.clearFilter();
    node_good.clearFilter();

    // node_receiver will receive its blocks from node_good
    [node_test, node_good].all!(node => node.getBlockHeight() == 10)
        .retryFor(4.seconds, "Nodes should have same block height");

    assertSameBlocks([node_test, node_good], 10);
}
