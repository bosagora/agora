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

import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Block;
import agora.common.Data;
import agora.common.Hash;
import agora.common.Transaction;
import agora.consensus.Genesis;
import agora.test.Base;

///
unittest
{
    import std.algorithm;
    import std.conv;
    import std.format;
    import std.range;
    import core.thread;

    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();
    scope(exit) network.shutdown();
    assert(network.getDiscoveredNodes().length == NodeCount);

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    Transaction[][] block_txes; /// per-block array of transactions (genesis not included)
    Transaction[] last_txs;
    foreach (block_idx; 0 .. 100)  // create 100 blocks
    {
        // create enough tx's for a single block
        auto txs = makeChainedTransactions(getGenesisKeyPair(), last_txs, 1);

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
    import std.algorithm;
    import std.conv;
    import std.format;
    import std.range;
    import core.thread;

    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    Transaction[] last_txs;
    foreach (block_idx; 0 .. 100)  // create 100 blocks
    {
        // create enough tx's for a single block
        auto txs = makeChainedTransactions(getGenesisKeyPair(), last_txs, 1);

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
    scope(exit) network.shutdown();
    assert(network.getDiscoveredNodes().length == NodeCount);
    containSameBlocks(nodes, 100).retryFor(8.seconds);
}

/// test catch-up phase after initial booting (periodic catch-up)
unittest
{
    import std.algorithm;
    import std.range;
    import core.thread;

    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();
    scope(exit) network.shutdown();

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    // ignore transaction propagation and periodically retrieve blocks via getBlocksFrom
    nodes[1 .. $].each!(node => node.filter!(node.putTransaction));

    auto txs = makeChainedTransactions(getGenesisKeyPair(), null, 4);
    txs.each!(tx => node_1.putTransaction(tx));
    containSameBlocks(nodes, 4).retryFor(8.seconds);
}

/// Merkle Proof
unittest
{
    import std.algorithm.sorting;

    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();
    scope(exit) network.shutdown();

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];
    auto gen_key_pair = getGenesisKeyPair();
    auto gen_block = getGenesisBlock();

    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random];

    Hash gen_tx_hash = hashFull(gen_block.txs[$-1]);
    Transaction[] txs;

    foreach (idx; 0 .. 8)
    {
        Transaction tx = Transaction(
            [
                Input(gen_tx_hash, 0)
            ],
            [
                Output(Amount(1_000_000), key_pairs[idx].address)
            ]
        );
        tx.inputs[0].signature = gen_key_pair.secret.sign(hashFull(tx)[]);
        node_1.putTransaction(tx);
        txs ~= tx;
    }

    Hash[] hashes;
    hashes.reserve(txs.length);
    foreach (ref e; txs)
        hashes ~= hashFull(e);

    // transactions are ordered lexicographically by hash in the Merkle tree
    hashes.sort!("a < b");

    const Hash ha = hashes[0];
    const Hash hb = hashes[1];
    const Hash hc = hashes[2];
    const Hash hd = hashes[3];
    const Hash he = hashes[4];
    const Hash hf = hashes[5];
    const Hash hg = hashes[6];
    const Hash hh = hashes[7];

    const Hash hab = mergeHash(ha, hb);
    const Hash hcd = mergeHash(hc, hd);
    const Hash hef = mergeHash(he, hf);
    const Hash hgh = mergeHash(hg, hh);

    const Hash habcd = mergeHash(hab, hcd);
    const Hash hefgh = mergeHash(hef, hgh);

    const Hash habcdefgh = mergeHash(habcd, hefgh);

    Hash[] merkle_path;
    foreach (key, ref node; nodes)
    {
        merkle_path = node.getMerklePath(1, hc);
        assert(merkle_path.length == 3);
        assert(merkle_path[0] == hd, "Error in the merkle path.");
        assert(merkle_path[1] == hab, "Error in the merkle path.");
        assert(merkle_path[2] == hefgh, "Error in the merkle path.");
        assert(habcdefgh == Block.checkMerklePath(hc, merkle_path, 2), "Error in the merkle proof.");
        assert(habcdefgh != Block.checkMerklePath(hd, merkle_path, 2), "Error in the merkle proof.");

        merkle_path = node.getMerklePath(1, he);
        assert(merkle_path.length == 3);
        assert(merkle_path[0] == hf, "Error in the merkle path.");
        assert(merkle_path[1] == hgh, "Error in the merkle path.");
        assert(merkle_path[2] == habcd, "Error in the merkle path.");
        assert(habcdefgh == Block.checkMerklePath(he, merkle_path, 4), "Error in the merkle proof.");
        assert(habcdefgh != Block.checkMerklePath(hf, merkle_path, 4), "Error in the merkle proof.");

        merkle_path = node.getMerklePath(1, Hash.init);
        assert(merkle_path.length == 0);
    }
}
