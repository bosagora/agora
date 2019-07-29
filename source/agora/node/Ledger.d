/*******************************************************************************

    Contains supporting code for tracking the current ledger.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.Ledger;

import agora.common.API;
import agora.common.Block;
import agora.common.Data;
import agora.common.Hash;
import agora.common.Transaction;
import agora.consensus.Genesis;

import vibe.core.log;

import std.algorithm;

/// Ditto
public class Ledger
{
    /// data storage for all the blocks,
    /// currently a single contiguous region to
    /// improve locality of reference
    private const(Block)[] ledger;

    /// pointer to the latest block
    private const(Block)* last_block;

    /// Temporary storage where transactions are stored until blocks are created.
    private Transaction[] storage;

    /// Ctor
    public this ()
    {
        auto block = getGenesisBlock();
        this.addNewBlock(block);
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

    public bool acceptTransaction (Transaction tx) @trusted
    {
        if (!tx.verify(&this.findOutput))
            return false;

        this.storage ~= tx;
        if (this.storage.length >= Block.TxsInBlock)
            this.makeBlock();

        return true;
    }

    /***************************************************************************

        Create a new block out of transactions in the storage.

    ***************************************************************************/

    private void makeBlock () @trusted
    {
        auto block = makeNewBlock(*this.last_block, this.storage);
        this.storage.length = 0;
        assumeSafeAppend(this.storage);
        this.addNewBlock(block);
    }

    /***************************************************************************

        Returns:
            the highest block

    ***************************************************************************/

    public const(Block)* getLastBlock () @safe nothrow @nogc
    {
        return this.last_block;
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
        @safe nothrow @nogc
    {
        assert(max_blocks > 0);

        if (block_height > this.ledger.length)
            return null;

        return this.ledger[block_height .. min(block_height + max_blocks, $)];
    }

    /***************************************************************************

        Add a block to the ledger.

        If the block fails verification, it is not added to the ledger.

        Params:
            block = the block to add

    ***************************************************************************/

    public void addNewBlock (const Block block) @trusted nothrow
    {
        // force nothrow, an exception will never be thrown here
        scope (failure) assert(0);

        if (!this.isValidBlock(block))
        {
            logDebug("Rejected block. %s", block);
            return;
        }

        this.ledger ~= block;
        this.last_block = &this.ledger[$ - 1];
    }

    /***************************************************************************

        Check the validity of a block.
        Currently only the height of the block is
        checked against the last block in the ledger.

        Params:
            block = the block to check

        Returns:
            true if the block is considered valid

    ***************************************************************************/

    private bool isValidBlock (const ref Block block) pure nothrow @safe @nogc
    {
        const expected_height = this.last_block !is null
            ? (this.last_block.header.height + 1)
            : 0;

        return block.header.height == expected_height;
    }

    /***************************************************************************

        Find a transaction in the ledger

        Params:
            tx_hash = the hash of transation

        Return:
            Return transaction if found. Return null otherwise.

    ***************************************************************************/

    private const(Output)* findOutput (Hash tx_hash, size_t index) @safe
    {
        foreach (ref block; this.ledger)
        {
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
        if (block_height >= this.ledger.length)
            return null;

        const(Block)* block = &this.ledger[block_height];

        size_t index = block.findHashIndex(hash);
        if (index < block.txs.length)
            return block.getMerklePath(index);
        else
            return null;
    }
}

///
unittest
{
    import agora.common.crypto.Key;

    scope ledger = new Ledger;
    assert(*ledger.getLastBlock() == getGenesisBlock());

    // same key-pair as in getGenesisBlock()
    const genesis_key_pair = KeyPair.fromSeed(
        Seed.fromString("SCT4KKJNYLTQO4TVDPVJQZEONTVVW66YLRWAINWI3FZDY7U4JS4JJEI4"));

    // last transaction in the ledger
    Hash last_tx_hash = hashFull(getGenesisBlock().txs[$-1]);
    Transaction tx =
    {
        [Input(last_tx_hash, 0)],
        [Output(40_000_000, genesis_key_pair.address)]  // send to the same address
    };

    auto signature = genesis_key_pair.secret.sign(hashFull(tx)[]);
    tx.inputs[0].signature = signature;

    assert(ledger.acceptTransaction(tx));
    ledger.makeBlock();
    assert(ledger.getLastBlock().txs[$-1] == tx);
}

/// getBlocksFrom tests
unittest
{
    import agora.common.crypto.Key;

    scope ledger = new Ledger;
    assert(*ledger.getLastBlock() == getGenesisBlock());
    assert(ledger.ledger.length == 1);

    auto gen_key_pair = getGenesisKeyPair();
    Transaction last_tx = getGenesisBlock().txs[$-1];

    // each tx currently creates one block
    void genTransactions (size_t count)
    {
        auto txes = getChainedTransactions(last_tx, count, gen_key_pair, 1);
        txes.each!((tx)
            {
                assert(ledger.acceptTransaction(tx));
                ledger.makeBlock();
                assert(ledger.getLastBlock().txs[$-1] == tx);

            });

        last_tx = txes[$ - 1];
    }

    genTransactions(2);
    const(Block)[] blocks = ledger.getBlocksFrom(0, 10);
    assert(blocks[0] == getGenesisBlock());
    assert(blocks[0].header.height == 0);
    assert(blocks.length == 3);  // two blocks + genesis block

    /// now generate 98 more txes (and blocks) to make it 100 + genesis block (101 total)
    genTransactions(98);

    assert(ledger.getLastBlock().header.height == 100);

    blocks = ledger.getBlocksFrom(0, 10);
    assert(blocks[0] == getGenesisBlock());
    assert(blocks[0].header.height == 0);
    assert(blocks.length == 10);

    /// lower limit
    blocks = ledger.getBlocksFrom(0, 5);
    assert(blocks[0] == getGenesisBlock());
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

/// Merkle Proof
unittest
{
    import agora.common.crypto.Key;

    KeyPair[] key_pairs = [
        KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random,
        KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random
    ];

    scope ledger = new Ledger;
    assert(*ledger.getLastBlock() == getGenesisBlock());
    assert(ledger.ledger.length == 1);

    auto gen_key_pair = getGenesisKeyPair();
    Transaction last_tx = getGenesisBlock().txs[$-1];
    Hash gen_tx_hash = hashFull(last_tx);

    Transaction[] txs;

    foreach (idx; 0 .. 8)
    {
        Transaction tx = Transaction(
            [
                Input(gen_tx_hash, 0)
            ],
            [
                Output(1_000_000, key_pairs[idx].address)
            ]
        );
        tx.inputs[0].signature = gen_key_pair.secret.sign(hashFull(tx)[]);
        assert(ledger.acceptTransaction(tx));
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
