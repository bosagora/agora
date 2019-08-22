/*******************************************************************************

    Contains supporting code for tracking the current ledger.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.Ledger;

import agora.common.Amount;
import agora.common.BlockStorage;
import agora.consensus.data.Block;
import agora.common.Data;
import agora.common.Hash;
import agora.common.TransactionPool;
import agora.consensus.data.Transaction;
import agora.consensus.Genesis;
import agora.consensus.Validation;
import agora.node.API;

import vibe.core.log;

import std.algorithm;

/// Ditto
public class Ledger
{
    /// data storage for all the blocks
    private IBlockStorage storage;

    /// Pool of transactions to pick from when generating blocks
    private TransactionPool pool;

    /// Ctor
    public this (TransactionPool pool, IBlockStorage storage)
    {
        this.pool = pool;
        this.storage = storage;
    }

    /***************************************************************************

        Add a block to the ledger.

        If the block fails verification, it is not added to the ledger.

        Params:
            block = the block to add

        Returns:
            true if the block was accepted

    ***************************************************************************/

    public bool acceptBlock (const ref Block block) nothrow @safe
    {
        Block last_block;
        if (!this.storage.readLastBlock(last_block))
            assert(0);
        if (!block.isValid(last_block.header.height,
            last_block.header.hashFull, &this.findUTXO))
        {
            logDebug("Rejected block. %s", block);
            return false;
        }
        if (!this.storage.saveBlock(block))
            return false;
        return true;
    }

    /***************************************************************************

        Called when a new transaction is received.

        If the transaction is accepted it will be added to
        a new block, and the block will be added to the ledger.

        If the transaction is invalid, it's rejected and false is returned.

        Params:
            tx = the received transaction

        Returns:
            true if the transaction is valid and was added to a block

    ***************************************************************************/

    public bool acceptTransaction (Transaction tx) @safe
    {
        if (!tx.isValid(&this.findUTXO))
            return false;

        this.pool.add(tx);
        if (this.pool.length >= Block.TxsInBlock)
            this.makeBlock();

        return true;
    }

    /***************************************************************************

        Create a new block out of transactions in the storage.

    ***************************************************************************/

    private void makeBlock () @safe
    {
        auto txs = this.pool.take(Block.TxsInBlock);
        assert(txs.length == Block.TxsInBlock);
        Block last_block;
        if (!this.storage.readLastBlock(last_block))
            assert(0);
        auto block = makeNewBlock(last_block, txs);
        if (!this.acceptBlock(block))
            assert(0);
    }

    /***************************************************************************

        Returns:
            latest block height

    ***************************************************************************/

    public ulong getBlockHeight () @safe nothrow
    {
        Block last_block;
        if (!this.storage.readLastBlock(last_block))
            assert(0);
        return last_block.header.height;
    }

    /***************************************************************************

        Get the array of blocks starting from the provided block height.
        The block at block_height is included in the array.

        Params:
            block_height = the starting block height to begin retrieval from
            max_blocks   = the maximum blocks to return at once

        Returns:
            the array of blocks starting from block_height,
            up to `max_blocks`

    ***************************************************************************/

    public const(Block)[] getBlocksFrom (ulong block_height, size_t max_blocks)
        @safe nothrow
    {
        assert(max_blocks > 0);

        const MaxHeight
            = min(block_height + max_blocks, this.getBlockHeight() + 1);
        const(Block)[] res;
        foreach (height; block_height .. MaxHeight)
        {
            Block block;
            if (!this.storage.readBlock(block, height))
                assert(0);

            res ~= block;
        }

        return res;
    }

    /***************************************************************************

        Find a transaction in the ledger

        Params:
            tx_hash = the hash of transation

        Return:
            Return transaction if found. Return null otherwise.

    ***************************************************************************/

    private const(Output)* findUTXO (Hash tx_hash, size_t index)
        @safe nothrow
    {
        foreach (height; 0 .. this.getBlockHeight() + 1)
        {
            Block block;
            if (!this.storage.readBlock(block, height))
                assert(0);

            foreach (ref tx; block.txs)
            {
                if (hashFull(tx) == tx_hash)
                {
                    if (index < tx.outputs.length)
                        return &tx.outputs[index];
                    return null;
                }
            }
        }

        return null;
    }


    /***************************************************************************

        Get the array of hashs the merkle path.

        Params:
            block_height = block height with transaction hash
            hash         = transaction hash

        Returns:
            the array of hashs the merkle path

    ***************************************************************************/

    public Hash[] getMerklePath (ulong block_height, Hash hash) @safe
    {
        if (this.getBlockHeight() < block_height)
            return null;

        Block block;
        if (!this.storage.readBlock(block, block_height))
            assert(0);
        size_t index = block.findHashIndex(hash);
        if (index >= block.txs.length)
            return null;
        return block.getMerklePath(index);
    }
}

///
unittest
{
    import agora.common.BlockStorage;
    import agora.common.crypto.Key;
    import agora.common.Data;
    import agora.common.Hash;

    auto storage = new MemBlockStorage();
    auto pool = new TransactionPool(":memory:");
    scope(exit) pool.shutdown();
    scope ledger = new Ledger(pool, storage);
    assert(ledger.getBlockHeight() == 0);

    const(Block)[] blocks = ledger.getBlocksFrom(0, 10);
    assert(blocks[$ - 1] == GenesisBlock);

    auto gen_key_pair = getGenesisKeyPair();
    Transaction[] last_txs;

    // generate enough transactions to form a block
    void genBlockTransactions (size_t count)
    {
        auto txes = makeChainedTransactions(gen_key_pair, last_txs, count);
        txes.each!((tx)
            {
                assert(ledger.acceptTransaction(tx));
            });

        // keep track of last tx's to chain them to
        last_txs = txes[$ - Block.TxsInBlock .. $];
    }

    genBlockTransactions(2);
    blocks = ledger.getBlocksFrom(0, 10);
    assert(blocks[0] == GenesisBlock);
    assert(blocks[0].header.height == 0);
    assert(blocks.length == 3);  // two blocks + genesis block

    /// now generate 98 more blocks to make it 100 + genesis block (101 total)
    genBlockTransactions(98);
    assert(ledger.getBlockHeight() == 100);

    blocks = ledger.getBlocksFrom(0, 10);
    assert(blocks[0] == GenesisBlock);
    assert(blocks[0].header.height == 0);
    assert(blocks.length == 10);

    /// lower limit
    blocks = ledger.getBlocksFrom(0, 5);
    assert(blocks[0] == GenesisBlock);
    assert(blocks[0].header.height == 0);
    assert(blocks.length == 5);

    /// different indices
    blocks = ledger.getBlocksFrom(1, 10);
    assert(blocks[0].header.height == 1);
    assert(blocks.length == 10);

    blocks = ledger.getBlocksFrom(50, 10);
    assert(blocks[0].header.height == 50);
    assert(blocks.length == 10);

    blocks = ledger.getBlocksFrom(95, 10);  // only 6 left from here (block 100 included)
    assert(blocks[0].header.height == 95);
    assert(blocks.length == 6);

    blocks = ledger.getBlocksFrom(99, 10);  // only 2 left from here (ditto)
    assert(blocks[0].header.height == 99);
    assert(blocks.length == 2);

    blocks = ledger.getBlocksFrom(100, 10);  // only 1 block available
    assert(blocks[0].header.height == 100);
    assert(blocks.length == 1);

    // over the limit => return up to the highest block
    assert(ledger.getBlocksFrom(0, 1000).length == 101);

    // higher index than available => return nothing
    assert(ledger.getBlocksFrom(1000, 10).length == 0);
}

/// basic block verification
unittest
{
    import agora.common.crypto.Key;
    import agora.common.Data;
    import agora.common.Hash;

    auto storage = new MemBlockStorage();
    auto pool = new TransactionPool(":memory:");
    scope(exit) pool.shutdown();
    scope ledger = new Ledger(pool, storage);

    Block invalid_block;  // default-initialized should be invalid
    assert(!ledger.acceptBlock(invalid_block));

    auto gen_key_pair = getGenesisKeyPair();
    auto txs = makeChainedTransactions(gen_key_pair, null, 1);

    auto valid_block = makeNewBlock(GenesisBlock, txs);
    assert(ledger.acceptBlock(valid_block));
}

/// Merkle Proof
unittest
{
    import agora.common.BlockStorage;
    import agora.common.crypto.Key;

    auto storage = new MemBlockStorage();
    auto pool = new TransactionPool(":memory:");
    scope(exit) pool.shutdown();
    scope ledger = new Ledger(pool, storage);

    auto gen_key_pair = getGenesisKeyPair();
    auto txs = makeChainedTransactions(gen_key_pair, null, 1);
    txs.each!(tx => assert(ledger.acceptTransaction(tx)));

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

    Hash[] merkle_path;
    merkle_path = ledger.getMerklePath(1, hc);
    assert(merkle_path.length == 3);
    assert(merkle_path[0] == hd);
    assert(merkle_path[1] == hab);
    assert(merkle_path[2] == hefgh);
    assert(habcdefgh == Block.checkMerklePath(hc, merkle_path, 2));
    assert(habcdefgh != Block.checkMerklePath(hd, merkle_path, 2));

    merkle_path = ledger.getMerklePath(1, he);
    assert(merkle_path.length == 3);
    assert(merkle_path[0] == hf);
    assert(merkle_path[1] == hgh);
    assert(merkle_path[2] == habcd);
    assert(habcdefgh == Block.checkMerklePath(he, merkle_path, 4));
    assert(habcdefgh != Block.checkMerklePath(hf, merkle_path, 4));

    merkle_path = ledger.getMerklePath(1, Hash.init);
    assert(merkle_path.length == 0);
}
