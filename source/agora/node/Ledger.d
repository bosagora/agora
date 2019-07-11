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

import std.algorithm;

/// Ditto
public class Ledger
{
    /// data storage for all the blocks,
    /// currently a single contiguous region to
    /// improve locality of reference
    private Block[] ledger;

    /// pointer to the latest block
    private Block* last_block;


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
        // find the previously referenced output
        auto findOutput = (Hash hash, size_t index)
        {
            if (auto txn = this.findTransaction(hash))
                if (index < txn.outputs.length)
                    return &txn.outputs[index];

                return null;
        };

        if (!tx.verifyData(findOutput) || !tx.verifySignature(findOutput))
            return false;

        auto block = makeNewBlock(*this.last_block, tx);
        this.addNewBlock(block);
        return true;
    }

    /***************************************************************************

        Returns:
            the highest block

    ***************************************************************************/

    public Block getLastBlock () @safe nothrow @nogc
    {
        return *this.last_block;
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

    public Block[] getBlocksFrom (ulong block_height, size_t max_blocks) @safe nothrow @nogc
    {
        assert(max_blocks > 0);

        if (block_height > this.ledger.length)
            return null;

        return this.ledger[block_height .. min(block_height + max_blocks, $)];
    }

    /***************************************************************************

        Add a block to the ledger

        Params:
            block = the block to add

    ***************************************************************************/

    private void addNewBlock (Block block) @trusted nothrow
    {
        // force nothrow, an exception will never be thrown here
        scope (failure) assert(0);
        this.ledger ~= block;
        this.last_block = &this.ledger[$ - 1];
    }


    /***************************************************************************

        Find a transaction in the ledger

        Params:
            tx_hash = the hash of transation

        Return:
            Return transaction if found. Return null otherwise.

    ***************************************************************************/

    private inout(Transaction)* findTransaction (Hash tx_hash) inout @safe
    {
        foreach (ref block; this.ledger)
        {
            if (block.header.tx_hash == tx_hash)
            {
                return &block.tx;
            }
        }

        return null;
    }
}

///
unittest
{
    import agora.common.crypto.Key;

    scope ledger = new Ledger;
    assert(ledger.getLastBlock() == getGenesisBlock());

    // same key-pair as in getGenesisBlock()
    const genesis_key_pair = KeyPair.fromSeed(
        Seed.fromString("SCT4KKJNYLTQO4TVDPVJQZEONTVVW66YLRWAINWI3FZDY7U4JS4JJEI4"));

    // last transaction in the ledger
    Hash last_tx_hash = hashFull(getGenesisBlock().tx);
    Transaction tx =
    {
        [Input(last_tx_hash, 0)],
        [Output(40_000_000, genesis_key_pair.address)]  // send to the same address
    };

    auto signature = genesis_key_pair.secret.sign(hashFull(tx)[]);
    tx.inputs[0].signature = signature;

    assert(ledger.acceptTransaction(tx));
    assert(ledger.getLastBlock().tx == tx);
    assert(ledger.getLastBlock().header.tx_hash == tx.hashFull());
}

/// getBlocksFrom tests
unittest
{
    import agora.common.crypto.Key;

    scope ledger = new Ledger;
    assert(ledger.getLastBlock() == getGenesisBlock());
    assert(ledger.ledger.length == 1);

    // same key-pair as in getGenesisBlock()
    const genesis_key_pair = KeyPair.fromSeed(
        Seed.fromString("SCT4KKJNYLTQO4TVDPVJQZEONTVVW66YLRWAINWI3FZDY7U4JS4JJEI4"));

    // last transaction in the ledger
    Hash last_tx_hash = hashFull(getGenesisBlock().tx);

    void generateBlocks (size_t count)
    {
        foreach (_; 0 .. count)
        {
            Transaction tx =
            {
                [Input(last_tx_hash, 0)],
                [Output(40_000_000, genesis_key_pair.address)]  // send to the same address
            };

            auto signature = genesis_key_pair.secret.sign(hashFull(tx)[]);
            tx.inputs[0].signature = signature;

            assert(ledger.acceptTransaction(tx));
            assert(ledger.getLastBlock().tx == tx);
            assert(ledger.getLastBlock().header.tx_hash == tx.hashFull());
            last_tx_hash = hashFull(tx);  // reference it again
        }
    }

    generateBlocks(2);
    Block[] blocks = ledger.getBlocksFrom(0, 10);
    assert(blocks[0] == getGenesisBlock());
    assert(blocks[0].header.height == 0);
    assert(blocks.length == 3);  // two blocks + genesis block

    /// now generate 98 more blocks to make it 100 + genesis block (101 total)
    generateBlocks(98);

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
