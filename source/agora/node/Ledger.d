/*******************************************************************************

    Contains supporting code for tracking the current ledger.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.Ledger;

import agora.common.Block;
import agora.common.Data;
import agora.common.Hash;
import agora.common.Transaction;

/// Ditto
public class Ledger
{
    /// data storage for all the blocks
    private Block[Hash] ledger;

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

        Creates a new block containing the transaction,
        and adds the block to the ledger.

        Params:
            tx = the received transaction

    ***************************************************************************/

    public void receiveTransaction (Transaction tx) @trusted
    {
        auto block = makeNewBlock(*this.last_block, tx);
        this.addNewBlock(block);
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

        Add a block to the ledger

        Params:
            block = the block to add

    ***************************************************************************/

    private void addNewBlock (Block block) @safe nothrow
    {
        auto block_hash = block.header.hashFull();
        this.ledger[block_hash] = block;
        this.last_block = block_hash in this.ledger;
    }
}

///
unittest
{
    import agora.common.crypto.Key;

    scope ledger = new Ledger;
    assert(ledger.getLastBlock() == getGenesisBlock());

    auto rand_pair = KeyPair.random();
    auto input = Input(hashFull(42));
    input.signature = rand_pair.secret.sign(input.hashFull[]);
    Transaction tx = { inputs : [input], outputs: [ Output(100, rand_pair.address) ]};

    ledger.receiveTransaction(tx);
    assert(ledger.getLastBlock().tx == tx);
    assert(ledger.getLastBlock().header.tx_hash == tx.hashFull());
}
