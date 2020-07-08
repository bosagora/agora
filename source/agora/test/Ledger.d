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
import agora.common.Hash;
import agora.common.Serializer;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXOSetValue;
import agora.consensus.Genesis;
import agora.consensus.validation;
import agora.test.Base;

import core.thread;


///
unittest
{
    auto network = makeTestNetwork(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    Transaction[][] block_txes; /// per-block array of transactions (genesis not included)
    Transaction[] last_txs;
    foreach (block_idx; 0 .. 10)  // create 10 blocks
    {
        // create enough tx's for a single block
        auto txs = makeChainedTransactions(WK.Keys.Genesis, last_txs, 1);

        // send it to one node
        txs.each!(tx => node_1.putTransaction(tx));

        nodes.enumerate.each!((idx, node) =>
            retryFor(node.getBlockHeight() == block_idx + 1,
                4.seconds,
                format("Node %s has block height %s. Expected: %s",
                    idx, node.getBlockHeight(), block_idx + 1)));

        block_txes ~= txs.sort.array;
        last_txs = txs;
    }

    // get all the blocks (including genesis block)
    auto blocks = node_1.getBlocksFrom(0, 101);

    assert(blocks[0] == network.blocks[0]);

    // exclude genesis block
    assert(blocks[1 .. $].enumerate.each!((idx, block) =>
        assert(block.txs == block_txes[idx])
    ));

    blocks = node_1.getBlocksFrom(0, 1);
    assert(blocks.length == 1 && blocks[0] == network.blocks[0]);

    blocks = node_1.getBlocksFrom(10, 1);
    assert(blocks.length == 1 && blocks[0].txs == block_txes[9]);  // -1 as genesis block not included

    // over the limit => return up to the highest block
    assert(node_1.getBlocksFrom(0, 100).length == 11);

    // higher index than available => return nothing
    assert(node_1.getBlocksFrom(100, 10).length == 0);
}

/// test catch-up phase after initial booting (periodic catch-up)
unittest
{
    TestConf conf = { topology : NetworkTopology.OneValidator };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // node_1 is the validator
    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // ignore transaction propagation and periodically retrieve blocks via getBlocksFrom
    nodes[1 .. $].each!(node => node.filter!(node.putTransaction));

    auto txs = makeChainedTransactions(WK.Keys.Genesis, null, 1);
    txs.each!(tx => node_1.putTransaction(tx));
    containSameBlocks(nodes, 1).retryFor(8.seconds);

    txs = makeChainedTransactions(WK.Keys.Genesis, txs, 1);
    txs.each!(tx => node_1.putTransaction(tx));
    containSameBlocks(nodes, 2).retryFor(8.seconds);
}

/// Merkle Proof
unittest
{
    auto network = makeTestNetwork(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto gen_key_pair = WK.Keys.Genesis;
    auto txs = makeChainedTransactions(gen_key_pair, null, 1);
    txs.each!(tx => node_1.putTransaction(tx));

    Hash[] hashes;
    hashes.reserve(txs.length);
    foreach (ref e; txs)
        hashes ~= hashFull(e);

    // transactions are ordered lexicographically by hash in the Merkle tree
    hashes.sort!("a < b");

    const Hash hab = hashMulti(hashes[0], hashes[1]);
    const Hash hcd = hashMulti(hashes[2], hashes[3]);
    const Hash hef = hashMulti(hashes[4], hashes[5]);
    const Hash hgh = hashMulti(hashes[6], hashes[7]);

    const Hash habcd = hashMulti(hab, hcd);
    const Hash hefgh = hashMulti(hef, hgh);

    const Hash expected_root = hashMulti(habcd, hefgh);

    // wait for transaction propagation
    nodes.each!(node => retryFor(node.getBlockHeight() == 1, 4.seconds));

    Hash[] merkle_path;
    foreach (node; nodes)
    {
        merkle_path = node.getMerklePath(1, hashes[2]);
        assert(merkle_path.length == 3);
        assert(merkle_path[0] == hashes[3]);
        assert(merkle_path[1] == hab);
        assert(merkle_path[2] == hefgh);
        assert(expected_root == Block.checkMerklePath(hashes[2], merkle_path, 2));
        assert(expected_root != Block.checkMerklePath(hashes[3], merkle_path, 2));

        merkle_path = node.getMerklePath(1, hashes[4]);
        assert(merkle_path.length == 3);
        assert(merkle_path[0] == hashes[5]);
        assert(merkle_path[1] == hgh);
        assert(merkle_path[2] == habcd);
        assert(expected_root == Block.checkMerklePath(hashes[4], merkle_path, 4));
        assert(expected_root != Block.checkMerklePath(hashes[5], merkle_path, 4));

        merkle_path = node.getMerklePath(1, Hash.init);
        assert(merkle_path.length == 0);
    }
}

/// test behavior of receiving double-spend transactions
unittest
{
    TestConf conf = { nodes : 2 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto txs = makeChainedTransactions(WK.Keys.Genesis, null, 1);
    txs.each!(tx => node_1.putTransaction(tx));
    containSameBlocks(nodes, 1).retryFor(3.seconds);

    txs = makeChainedTransactions(WK.Keys.Genesis, txs, 1);
    txs.each!(tx => node_1.putTransaction(tx));
    containSameBlocks(nodes, 2).retryFor(3.seconds);

    txs = makeChainedTransactions(WK.Keys.Genesis, txs, 1);

    // create a deep-copy of the first tx
    auto backup_tx = deserializeFull!Transaction(serializeFull(txs[0]));

    // create a double-spend tx
    txs[0].inputs[0] = txs[1].inputs[0];
    txs[0].outputs[0].value = Amount(100);
    auto signature = WK.Keys.Genesis.secret.sign(hashFull(txs[0])[]);
    txs[0].inputs[0].signature = signature;

    // make sure the transaction is still authentic (signature is correct),
    // even if it's double spending
    assert(txs[0].isValid((Hash hash, size_t index, out UTXOSetValue value)
        {
            value =
            UTXOSetValue(
                0,
                TxType.Payment,
                GenesisTransaction.outputs[0]
            );
            return true;
        }, Height(0)));

    txs.each!(tx => node_1.putTransaction(tx));

    Thread.sleep(2.seconds);  // wait for propagation
    containSameBlocks(nodes, 2).retryFor(3.seconds);  // no new block yet (1 rejected tx)

    node_1.putTransaction(backup_tx);
    containSameBlocks(nodes, 3).retryFor(3.seconds);  // new block finally created
}
