/*******************************************************************************

    Contains tests for the Block creation and adding blocks to the ledger,
    as well as the catch-up

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Ledger;

version (unittest):

import agora.common.crypto.Key;
import agora.common.Block;
import agora.common.Data;
import agora.common.Hash;
import agora.common.Transaction;
import agora.test.Base;

/// Returns: the entire ledger from the provided node
private Block[] getAllBlocks (TestAPI node)
{
    import std.range;
    Block[] blocks;

    // note: may return less than asked for, hence the loop
    size_t starting_block = 0;
    while (1)
    {
        auto new_blocks = node.getBlocksFrom(starting_block, uint.max);
        if (new_blocks.length == 0)  // no blocks left
            break;

        // ensure sequential consistency
        foreach (block; new_blocks)
            assert(block.header.height == starting_block++);

        blocks ~= new_blocks;
    }

    return blocks;
}

/// Returns: true if all the nodes contain the same blocks
private bool containSameBlocks (API)(API[] nodes, size_t height)
{
    auto first_blocks = nodes[0].getAllBlocks();

    foreach (node; nodes)
    {
        if (node.getBlockHeight() != height)
            return false;

        if (node.getAllBlocks() != first_blocks)
            return false;
    }

    return true;
}

///
unittest
{
    import core.thread;
    import std.algorithm;
    import std.conv;
    import std.format;
    import std.range;

    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();
    assert(network.getDiscoveredNodes().length == NodeCount);

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    Transaction[][] block_txes; /// per-block array of transactions (genesis not included)
    Transaction[] last_txs;
    foreach (block_idx; 0 .. 100)  // create 100 blocks
    {
        // create enough tx's for a single block
        auto txs = getChainedTransactions(getGenesisKeyPair(), Block.TxsInBlock, last_txs);

        // send it to one node
        txs.each!(tx => node_1.putTransaction(tx));

        Thread.sleep(50.msecs);  // await gossip and block creation

        nodes.enumerate.each!((idx, node) =>
            assert(node.getBlockHeight() == block_idx + 1,
                format("Node %s has block height %s. Expected: %s",
                    idx, node.getBlockHeight().to!string, block_idx + 1)));

        block_txes ~= txs;
        last_txs = txs;
    }

    // get all the blocks (including genesis block)
    auto blocks = node_1.getBlocksFrom(0, 101);

    assert(blocks[0] == getGenesisBlock());

    // exclude genesis block
    assert(blocks[1 .. $].enumerate.each!((idx, block) =>
        assert(block.txs == block_txes[idx])
    ));

    blocks = node_1.getBlocksFrom(0, 1);
    assert(blocks.length == 1 && blocks[0] == getGenesisBlock());

    blocks = node_1.getBlocksFrom(100, 1);
    assert(blocks.length == 1 && blocks[0].txs == block_txes[99]);  // -1 as genesis block not included

    // over the limit => return up to the highest block
    assert(node_1.getBlocksFrom(0, 1000).length == 101);

    // higher index than available => return nothing
    assert(node_1.getBlocksFrom(1000, 10).length == 0);
}

/// test catch-up phase during booting
unittest
{
    import core.thread;
    import std.algorithm;
    import std.conv;
    import std.format;
    import std.range;

    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    Transaction[] last_txs;
    foreach (block_idx; 0 .. 100)  // create 100 blocks
    {
        // create enough tx's for a single block
        auto txs = getChainedTransactions(getGenesisKeyPair(), Block.TxsInBlock, last_txs);

        // send it to one node
        txs.each!(tx => node_1.putTransaction(tx));

        assert(node_1.getBlockHeight() == block_idx + 1,
            format("Node 1 has block height %s. Expected: %s",
                node_1.getBlockHeight().to!string, block_idx + 1));

        last_txs = txs;
    }

    Thread.sleep(50.msecs);  // await block creation

    assert(node_1.getBlockHeight() == 100);

    foreach (empty_node; nodes[1 .. $])
    {
        assert(empty_node.getBlockHeight() == 0);
    }

    // now start the network, let other nodes catch-up the latest blocks
    network.start();
    assert(network.getDiscoveredNodes().length == NodeCount);

    auto attempts = 80;  // wait up to 80*100 msecs (8 seconds)
    while (attempts--)
    {
        if (containSameBlocks(nodes, 100))
            return;

        // let them do catch-up after boot
        Thread.sleep(100.msecs);
    }
}

/// test catch-up phase after initial booting (periodic catch-up)
unittest
{
    import core.thread;
    import std.algorithm;
    import std.range;

    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    // ignore transaction propagation and periodically retrieve blocks via getBlocksFrom
    nodes[1 .. $].each!(node => node.filter!(node.putTransaction));

    auto txs = getChainedTransactions(getGenesisKeyPair(), 100 * Block.TxsInBlock, null);
    txs.each!(tx => node_1.putTransaction(tx));

    auto attempts = 80;  // wait up to 80*100 msecs (8 seconds)
    while (attempts--)
    {
        if (containSameBlocks(nodes, 100))
            return;

        // let them do catch-up after boot
        Thread.sleep(100.msecs);
    }
}
