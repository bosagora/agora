/*******************************************************************************

    Contains tests for Gossip Protocol.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.GossipProtocol;

version (unittest):

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
    import std.conv;
    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();
    assert(network.getDiscoveredNodes().length == NodeCount);
    auto node_1 = network.apis.values[0];

    KeyPair[] key_pairs = [
        KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random,
        KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random,
        KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random,
        ];

    KeyPair gen_key_pair = getGenesisKeyPair();
    const gen_block = getGenesisBlock();

    // last transaction in the ledger
    Hash gen_tx_hash = hashFull(gen_block.txs[$-1]);
    Hash last_tx_hash;
    Transaction[] txs;

    // check block height
    foreach (key, ref node; network.apis)
    {
        auto block_height = node.getBlockHeight();
        assert(block_height == 0, block_height.to!string);
    }

    // It is validated. (the sum of `Output` < the sum of `Input`)
    // The Genesis block has 40,000,000

    // Creates the first transaction.
    foreach (idx; 0 .. 8)
    {
        Transaction tx1 = Transaction(
            [
                Input(gen_tx_hash, 0)
            ],
            [
                Output(1_000_000, key_pairs[idx].address)
            ]
        );
        last_tx_hash = hashFull(tx1);

        // Sign a transaction and assign it to the input
        tx1.inputs[0].signature = gen_key_pair.secret.sign(last_tx_hash[]);
        node_1.putTransaction(tx1);

        txs ~= tx1;
    }

    // Check hasTransactionHash
    foreach (key, ref node; network.apis)
    {
        //  every nodes received tx
        assert(node.hasTransactionHash(last_tx_hash));

        auto block_height = node.getBlockHeight();
        assert(block_height == 1, block_height.to!string);
    }

    // It is validated. (the sum of `Output` == the sum of `Input`)

    // Creates the second transaction.
    foreach (idx; 0 .. 8)
    {
        Transaction tx2 = Transaction(
            [
                Input(hashFull(txs[idx]), 0)
            ],
            [
                Output(1_000_000, key_pairs[idx+8].address)
            ]
        );
        last_tx_hash = hashFull(tx2);

        // Sign a transaction and assign it to the input
        tx2.inputs[0].signature = key_pairs[idx].secret.sign(last_tx_hash[]);
        node_1.putTransaction(tx2);
        txs ~= tx2;
    }

    // Check hasTransactionHash
    foreach (key, ref node; network.apis)
    {
        //  every nodes received tx
        assert(node.hasTransactionHash(last_tx_hash));

        auto block_height = node.getBlockHeight();
        assert(block_height == 2, block_height.to!string);
    }


    // It isn't validated. (the sum of `Output` > the sum of `Input`)

    // Creates the third transaction.
    foreach (idx; 0 .. 8)
    {
        Transaction tx3 = Transaction(
            [
                Input(hashFull(txs[idx+8]), 0)
            ],
            [
                Output(2_000_000, key_pairs[idx].address)
            ]
        );
        last_tx_hash = hashFull(tx3);

        // Sign a transaction and assign it to the input
        tx3.inputs[0].signature = key_pairs[idx+8].secret.sign(last_tx_hash[]);
        node_1.putTransaction(tx3);
        txs ~= tx3;
    }

    // Check hasTransactionHash
    foreach (key, ref node; network.apis)
    {
        assert(!node.hasTransactionHash(last_tx_hash));

        auto block_height = node.getBlockHeight();
        assert(block_height == 2, block_height.to!string);
    }

    // Creates the fourth transaction.
    foreach (idx; 0 .. 8)
    {
        Transaction tx4 = Transaction(
            [
                Input(hashFull(txs[idx+8]), 0)
            ],
            [
                Output(1_000_000, key_pairs[idx].address)
            ]
        );
        last_tx_hash = hashFull(tx4);

        // Sign a transaction and assign it to the input,  the exact `KeyPair` is `key_pairs[idx+8]

        tx4.inputs[0].signature = gen_key_pair.secret.sign(last_tx_hash[]);
        node_1.putTransaction(tx4);
        txs ~= tx4;
    }

    // Check hasTransactionHash
    foreach (key, ref node; network.apis)
    {
        assert(!node.hasTransactionHash(last_tx_hash));

        auto block_height = node.getBlockHeight();
        assert(block_height == 2, block_height.to!string);
    }
}
