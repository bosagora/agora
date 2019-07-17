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
    import std.algorithm;
    import std.conv;
    import std.format;

    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();
    assert(network.getDiscoveredNodes().length == NodeCount);

    auto node_1 = network.apis.values[0];
    KeyPair[] key_pairs;

    auto gen_key_pair = getGenesisKeyPair();
    auto gen_block = getGenesisBlock();

    auto txes = getChainedTransactions(gen_block.tx, 100, gen_key_pair);
    txes.each!(tx => node_1.putTransaction(tx));

    // ensure block height is the same everywhere
    foreach (key, ref node; network.apis)
    {
        auto block_height = node.getBlockHeight();
        assert(block_height == 100, block_height.to!string);
    }

    // get all the blocks (including genesis block)
    auto blocks = node_1.getBlocksFrom(0, 101);

    assert(blocks[0] == getGenesisBlock());

    // exclude genesis block
    assert(blocks[1 .. $].map!(block => block.tx).equal(txes[]));

    blocks = node_1.getBlocksFrom(0, 1);
    assert(blocks.length == 1 && blocks[0] == getGenesisBlock());

    blocks = node_1.getBlocksFrom(100, 1);
    assert(blocks.length == 1 && blocks[0].tx == txes[$ - 1]);

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

    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];
    auto gen_key_pair = getGenesisKeyPair();
    auto gen_block = getGenesisBlock();

    auto txes = getChainedTransactions(gen_block.tx, 100, gen_key_pair);
    txes.each!(tx => node_1.putTransaction(tx));

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

    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];
    auto gen_key_pair = getGenesisKeyPair();
    auto gen_block = getGenesisBlock();

    // ignore transaction propagation and periodically retrieve blocks via getBlocksFrom
    foreach (node; nodes[1 .. $])
        node.sleep(1.seconds);

    auto txes = getChainedTransactions(gen_block.tx, 100, gen_key_pair);
    txes.each!(tx => node_1.putTransaction(tx));

    auto attempts = 80;  // wait up to 80*100 msecs (8 seconds)
    while (attempts--)
    {
        if (containSameBlocks(nodes, 100))
            return;

        // let them do catch-up after boot
        Thread.sleep(100.msecs);
    }
}
