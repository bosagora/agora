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
import agora.consensus.data.Block;
import agora.common.Data;
import agora.common.Hash;
import agora.consensus.data.Transaction;
import agora.consensus.Genesis;
import agora.test.Base;

///
unittest
{
    import std.algorithm;
    import std.conv;
    import std.format;
    import std.range;
    import core.time;

    const NodeCount = 4;
    auto network = makeTestNetwork(NetworkTopology.Simple, NodeCount);
    network.start();
    scope(exit) network.shutdown();
    assert(network.getDiscoveredNodes().length == NodeCount);

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    Transaction[][] block_txes; /// per-block array of transactions (genesis not included)
    Transaction[] last_txs;
    foreach (block_idx; 0 .. 10)  // create 10 blocks
    {
        // create enough tx's for a single block
        auto txs = makeChainedTransactions(getGenesisKeyPair(), last_txs, 1);

        // send it to one node
        txs.each!(tx => node_1.putTransaction(tx));

        nodes.enumerate.each!((idx, node) =>
            retryFor(node.getBlockHeight() == block_idx + 1,
                4.seconds,
                format("Node %s has block height %s. Expected: %s",
                    idx, node.getBlockHeight().to!string, block_idx + 1)));

        block_txes ~= txs.sort.array;
        last_txs = txs;
    }

    // get all the blocks (including genesis block)
    auto blocks = node_1.getBlocksFrom(0, 101);

    assert(blocks[0] == GenesisBlock);

    // exclude genesis block
    assert(blocks[1 .. $].enumerate.each!((idx, block) =>
        assert(block.txs == block_txes[idx])
    ));

    blocks = node_1.getBlocksFrom(0, 1);
    assert(blocks.length == 1 && blocks[0] == GenesisBlock);

    blocks = node_1.getBlocksFrom(10, 1);
    assert(blocks.length == 1 && blocks[0].txs == block_txes[9]);  // -1 as genesis block not included

    // over the limit => return up to the highest block
    assert(node_1.getBlocksFrom(0, 100).length == 11);

    // higher index than available => return nothing
    assert(node_1.getBlocksFrom(100, 10).length == 0);
}

/// test catch-up phase during booting
unittest
{
    import std.algorithm;
    import std.conv;
    import std.format;
    import std.range;
    import core.time;

    const NodeCount = 4;
    auto network = makeTestNetwork(NetworkTopology.Simple, NodeCount);

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    Transaction[] last_txs;
    foreach (block_idx; 0 .. 10)  // create 10 blocks
    {
        // create enough tx's for a single block
        auto txs = makeChainedTransactions(getGenesisKeyPair(), last_txs, 1);

        // send it to one node
        txs.each!(tx => node_1.putTransaction(tx));

        retryFor(node_1.getBlockHeight() == block_idx + 1,
            1.seconds,
            format("Node 1 has block height %s. Expected: %s",
                node_1.getBlockHeight().to!string, block_idx + 1));

        last_txs = txs;
    }

    retryFor(node_1.getBlockHeight() == 10, 1.seconds);

    foreach (empty_node; nodes[1 .. $])
    {
        assert(empty_node.getBlockHeight() == 0);
    }

    // now start the network, let other nodes catch-up the latest blocks
    network.start();
    scope(exit) network.shutdown();
    assert(network.getDiscoveredNodes().length == NodeCount);
    containSameBlocks(nodes, 10).retryFor(8.seconds);
}

/// test catch-up phase after initial booting (periodic catch-up)
unittest
{
    import std.algorithm;
    import std.range;
    import core.time;

    const NodeCount = 4;
    auto network = makeTestNetwork(NetworkTopology.Simple, NodeCount, true,
        100, 20, 100);  // reduce timeout to 100 msecs
    network.start();
    scope(exit) network.shutdown();
    assert(network.getDiscoveredNodes().length == NodeCount);

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    // ignore transaction propagation and periodically retrieve blocks via getBlocksFrom
    nodes[1 .. $].each!(node => node.filter!(node.putTransaction));

    auto txs = makeChainedTransactions(getGenesisKeyPair(), null, 2);
    txs.each!(tx => node_1.putTransaction(tx));
    containSameBlocks(nodes, 2).retryFor(8.seconds);
}

/// Merkle Proof
unittest
{
    import core.time;
    import std.algorithm;

    const NodeCount = 4;
    auto network = makeTestNetwork(NetworkTopology.Simple, NodeCount);
    network.start();
    scope(exit) network.shutdown();
    assert(network.getDiscoveredNodes().length == NodeCount);

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    auto gen_key_pair = getGenesisKeyPair();
    auto txs = makeChainedTransactions(gen_key_pair, null, 1);
    txs.each!(tx => node_1.putTransaction(tx));

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

    const Hash hab = hashMulti(ha, hb);
    const Hash hcd = hashMulti(hc, hd);
    const Hash hef = hashMulti(he, hf);
    const Hash hgh = hashMulti(hg, hh);

    const Hash habcd = hashMulti(hab, hcd);
    const Hash hefgh = hashMulti(hef, hgh);

    const Hash habcdefgh = hashMulti(habcd, hefgh);

    // wait for transaction propagation
    nodes.each!(node => retryFor(node.getBlockHeight() == 1, 4.seconds));

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

/// test behavior of receiving double-spend transactions
unittest
{
    import agora.common.Deserializer;
    import agora.common.Serializer;
    import std.algorithm;
    import core.time;
    import core.thread;
    import agora.consensus.Validation;

    const NodeCount = 2;
    auto network = makeTestNetwork(NetworkTopology.Simple, NodeCount, true,
        100, 20, 100);  // reduce timeout to 100 msecs
    network.start();
    scope(exit) network.shutdown();

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    auto txs = makeChainedTransactions(getGenesisKeyPair(), null, 1);
    txs.each!(tx => node_1.putTransaction(tx));
    containSameBlocks(nodes, 1).retryFor(3.seconds);

    txs = makeChainedTransactions(getGenesisKeyPair(), txs, 1);
    txs.each!(tx => node_1.putTransaction(tx));
    containSameBlocks(nodes, 2).retryFor(3.seconds);

    txs = makeChainedTransactions(getGenesisKeyPair(), txs, 1);

    // create a deep-copy of the first tx
    auto backup_tx = deserializeFull!Transaction(serializeFull(txs[0]));

    // create a double-spend tx
    txs[0].inputs[0] = txs[1].inputs[0];
    txs[0].outputs[0].value = Amount(100);
    auto signature = getGenesisKeyPair().secret.sign(hashFull(txs[0])[]);
    txs[0].inputs[0].signature = signature;

    // make sure the transaction is still authentic (signature is correct),
    // even if it's double spending
    assert(txs[0].isValid((Hash hash, size_t index, out Output output)
        { output = GenesisTransaction.outputs[0]; return true; }));

    txs.each!(tx => node_1.putTransaction(tx));

    Thread.sleep(2.seconds);  // wait for propagation
    containSameBlocks(nodes, 2).retryFor(3.seconds);  // no new block yet (1 rejected tx)

    node_1.putTransaction(backup_tx);
    containSameBlocks(nodes, 3).retryFor(3.seconds);  // new block finally created
}
