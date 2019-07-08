/*******************************************************************************

    Contains tests for the Block creation and adding blocks to the ledger

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Ledger;

version (unittest):

import agora.common.Block;
import agora.common.Data;
import agora.common.Hash;
import agora.common.Transaction;
import agora.test.Base;

///
unittest
{
    import std.algorithm;
    import std.conv;
    import std.format;
    import std.digest.sha;

    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();
    assert(network.getDiscoveredNodes().length == NodeCount);

    auto node_1 = network.apis.values[0];
    Transaction[] txes;

    foreach (idx; 0 .. 100)
    {
        Transaction tx =
        {
            [Input(hashFull("Message No. %s".format(idx + 1)))],
            [Output(100)]
        };

        node_1.putTransaction(tx);
        txes ~= tx;
    }

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
