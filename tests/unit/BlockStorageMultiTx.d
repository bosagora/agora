/*******************************************************************************

    Create blocks with multiple transactions and test that they are
    read properly.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module unit.BlockStorageMultiTx;

import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Data;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.consensus.Genesis;
import agora.node.BlockStorage;

import std.algorithm.comparison;
import std.file;
import std.path;

/// The maximum number of block in one file
private immutable ulong MFILE_MAX_BLOCK = 100;

/// blocks to test
const size_t BlockCount = 300;

///
private void main ()
{
    string path = buildPath(getcwd, ".cache");
    if (path.exists)
        rmdirRecurse(path);

    mkdir(path);

    BlockStorage.removeIndexFile(path);
    BlockStorage storage = new BlockStorage(path);
    const(Block)[] blocks;

    blocks ~= GenesisBlock;
    storage.saveBlock(blocks[$ - 1]);

    // We can use a random keypair because blocks are not validated
    auto gen_key_pair = KeyPair.random();

    Transaction[] last_txs;
    foreach (block_idx; 0 .. BlockCount)
    {
        // create enough tx's for a single block
        auto txs = makeChainedTransactions(gen_key_pair, last_txs, 1);

        auto block = makeNewBlock(blocks[$ - 1], txs);
        storage.saveBlock(block);
        blocks ~= block;
        last_txs = txs;
    }

    //// load
    Block[] loaded_blocks;
    loaded_blocks.length = BlockCount + 1;
    foreach (idx; 0 .. BlockCount + 1)
        storage.readBlock(loaded_blocks[idx], idx);
    size_t idx;

    assert(loaded_blocks == blocks);
}

/// Copied over from agora.common.Transaction
private Transaction[] makeChainedTransactions (KeyPair key_pair,
    Transaction[] prev_txs, size_t block_count)
{
    import agora.consensus.data.Block;
    import std.conv;

    assert(prev_txs.length == 0 || prev_txs.length == Block.TxsInBlock);
    const TxCount = block_count * Block.TxsInBlock;

    // in unittests we use the following blockchain layout:
    //
    // genesis => 8 outputs
    // txs[0] => spend gen_tx.outputs[0]
    // txs[1] => spend gen_tx.outputs[1]...
    // ..
    // tx[9] => spend tx[0].outputs[0]
    // tx[10] => spend tx[1].outputs[0]
    // ..
    // tx[17] => spend tx[9].outputs[0]
    // tx[18] => spend tx[10].outputs[0]
    // ..
    // therefore the genesis block and the 1st block are unique here,
    // as the 1st block spends all the genesis outputs via separate
    // transactions, and subsequent blocks have transactions which
    // spend the only outputs in the transaction from the previous block

    Transaction[] transactions;

    // always use the same amount, for simplicity
    const Amount AmountPerTx = 40_000_000 / Block.TxsInBlock;

    foreach (idx; 0 .. TxCount)
    {
        Input input;
        if (prev_txs.length == 0)  // refering to genesis tx's outputs
            input = Input(hashFull(GenesisTransaction), idx.to!uint);
        else  // refering to tx's in the previous block
            input = Input(hashFull(prev_txs[idx % Block.TxsInBlock]), 0);

        Transaction tx =
        {
            [input],
            [Output(AmountPerTx, key_pair.address, TXO_PAYMENT]  // send to the same address
        };

        auto signature = key_pair.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        transactions ~= tx;

        // new transactions will refer to the just created transactions
        // which will be part of the previous block after the block is created
        if (Block.TxsInBlock == 1 ||  // special case
            (idx > 0 && ((idx + 1) % Block.TxsInBlock == 0)))
        {
            // refer to tx'es which will be in the previous block
            prev_txs = transactions[$ - Block.TxsInBlock .. $];
        }
    }
    return transactions;
}
