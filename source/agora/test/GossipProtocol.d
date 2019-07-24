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
import agora.test.Base;

///
unittest
{
    import std.conv;
    import std.range;
    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();
    assert(network.getDiscoveredNodes().length == NodeCount);
    auto node_1 = network.apis.values[0];

    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random];

    const gen_key_pair = getGenesisKeyPair();
    const gen_block = getGenesisBlock();
    Hash genesis_tx_hash = hashFull(gen_block.txs.back);

    // check block height
    foreach (key, ref node; network.apis)
    {
        auto block_height = node.getBlockHeight();
        assert(block_height == 0, block_height.to!string);
    }

    // It is validated. (the sum of `Output` == the sum of `Input`)
    // The Genesis block has 40,000,000

    // Creates the first transaction.
    Transaction tx1 = Transaction(
        [
            Input(genesis_tx_hash, 0)
        ],
        [
            Output(40_000_000, key_pairs[0].address)
        ]
    );
    Hash tx1Hash = hashFull(tx1);

    // Sign a transaction and assign it to the input
    tx1.inputs[0].signature = gen_key_pair.secret.sign(tx1Hash[]);
    node_1.putTransaction(tx1);

    // Check hasTransactionHash
    foreach (key, ref node; network.apis)
    {
        //  every nodes received tx
        assert(node.hasTransactionHash(tx1Hash));

        auto block_height = node.getBlockHeight();
        assert(block_height == 1, block_height.to!string);
    }

    // It is validated. (the sum of `Output` < the sum of `Input`)

    // Creates the second transaction.
    Transaction tx2 = Transaction(
        [
            Input(tx1Hash, 0)
        ],
        [
            Output(20_000_000, key_pairs[1].address)
        ]
    );
    Hash tx2Hash = hashFull(tx2);

    // Sign a transaction and assign it to the input
    tx2.inputs[0].signature = key_pairs[0].secret.sign(tx2Hash[]);
    node_1.putTransaction(tx2);

    // Check hasTransactionHash
    foreach (key, ref node; network.apis)
    {
        //  every nodes received tx
        assert(node.hasTransactionHash(tx2Hash));

        auto block_height = node.getBlockHeight();
        assert(block_height == 2, block_height.to!string);
    }

    // It isn't validated. (the sum of `Output` > the sum of `Input`)

    // Creates the third transaction.
    Transaction tx3 = Transaction(
        [
            Input(tx2Hash, 0)
        ],
        [
            Output(50_000_000, key_pairs[2].address)
        ]
    );
    Hash tx3Hash = hashFull(tx3);

    // Sign a transaction and assign it to the input
    tx3.inputs[0].signature = key_pairs[1].secret.sign(tx3Hash[]);
    node_1.putTransaction(tx3);

    // Check hasTransactionHash
    foreach (key, ref node; network.apis)
    {
        assert(!node.hasTransactionHash(tx3Hash));

        auto block_height = node.getBlockHeight();
        assert(block_height == 2, block_height.to!string);
    }

    // Creates the fourth transaction.
    Transaction tx4 = Transaction(
        [
            Input(tx2Hash, 0)
        ],
        [
            Output(20_000_000, key_pairs[2].address)
        ]
    );
    Hash tx4Hash = hashFull(tx4);

    // Sign a transaction and assign it to the input
    tx4.inputs[0].signature = key_pairs[2].secret.sign(tx4Hash[]);
    node_1.putTransaction(tx4);

    // Check hasTransactionHash
    foreach (key, ref node; network.apis)
    {
        assert(!node.hasTransactionHash(tx4Hash));

        auto block_height = node.getBlockHeight();
        assert(block_height == 2, block_height.to!string);
    }
}
