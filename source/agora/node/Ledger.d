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
import agora.common.Serializer;
import agora.common.Transaction;

import vibe.core.log;

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
        if (this.storage.length == Block.TxsInBlock)
            this.makeBlock();

        return true;
    }

    /***************************************************************************

        Create a new block out of transactions in the storage.

    ***************************************************************************/

    private void makeBlock () @trusted
    {
        assert(this.storage.length == Block.TxsInBlock);

        auto block = makeNewBlock(*this.last_block, this.storage);
        this.storage.length = 0;
        assumeSafeAppend(this.storage);
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

        Add a block to the ledger.

        If the block fails verification, it is not added to the ledger.

        Params:
            block = the block to add

    ***************************************************************************/

    public void addNewBlock (Block block) @trusted nothrow
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

    private bool isValidBlock (Block block)
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

    private Output* findOutput (Hash tx_hash, size_t index) @safe
    {
        foreach (ref block; this.ledger)
        {
            foreach (ref tx; block.txs)
            {
                if (hashFull(tx) == tx_hash)
                {
                    if (index < tx.outputs.length)
                        return &tx.outputs[index];
                }
            }
        }

        return null;
    }
}

/// getBlocksFrom tests
unittest
{
    import agora.common.crypto.Key;
    import std.digest;
    import std.range;

    scope ledger = new Ledger;
    assert(ledger.getLastBlock() == getGenesisBlock());
    assert(ledger.ledger.length == 1);

    auto gen_key_pair = getGenesisKeyPair();
    Transaction[] last_txs;

    // generate enough transactions to form a block
    void genBlockTransactions (size_t count)
    {
        auto txes = getChainedTransactions(gen_key_pair, count * Block.TxsInBlock, last_txs);
        txes.each!((tx)
            {
                assert(ledger.acceptTransaction(tx));
            });

        last_txs = txes;
    }

    genBlockTransactions(2);
    Block[] blocks = ledger.getBlocksFrom(0, 10);
    assert(blocks[0] == getGenesisBlock());
    assert(blocks[0].header.height == 0);
    assert(blocks.length == 3);  // two blocks + genesis block

    /// now generate 98 more blocks to make it 100 + genesis block (101 total)
    genBlockTransactions(98);

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

    // getLastBlock Testing serialization
    // Compare the serialization hexstring with the origin Ledger data.
    const ubyte[] data = serializeFull(ledger.getLastBlock());
    const string serializeData =
      "4B17D2A06D8244BF9DD5EBA79780FFF2A1B98C8CE0619A67BA9BE1A6D8FA8C74A77DA9C59F799CBE"
    ~ "258DAE88B5B73E068C54E93D210DA037D4B4BFFB63475278640000000000000036538996D12799E8"
    ~ "ED8740B9BF13D90C6E89961F00FB6E08954E12395B8D65C863809CD86EEFD46D7453490A22995359"
    ~ "A9ECE2A279A089E78E36AA24C5A3C3C3DCB04DD1044AE87CB47A947C43B9FFAB223947D8FE213DD3"
    ~ "80F12AA5672F1E07FBA3BB6B2EE26CEA55C419E6B6EFCEF12FF2EBBBD11C652049D9929672E3B565"
    ~ "00000000E7A729309D5CF3C1E1B1660CB14103E511C08B1439D76ACF195B8A29D27BACF2AEA3D01E"
    ~ "58803ED8CEE2D7EC6C74BC613B861740349484BBEFCB2D9740E3F704404B4C00000000009D0238E0"
    ~ "A171400BC6D68A9D9B316ACD5109649113A05C284F4296D2B30122F5243099D75C1CB61278A91338"
    ~ "0FC93CA23399135EE0BABE9B26FDC7FE6FE2C4D865DACC637CBE7376C57EA5F07CF926CB1977F73A"
    ~ "3CFA395A919714E64CB736BF000000000ACC97A46DA6DC67D3BCFCD471F8C7A716CEE84DD14AD9E8"
    ~ "66814E575CFAA9749688746611F152D78EE4FC9D1533C96207A131535A4D1043773405A6623D2703"
    ~ "404B4C00000000009D0238E0A171400BC6D68A9D9B316ACD5109649113A05C284F4296D2B30122F5"
    ~ "C980D73C0093BB2EC70975AA6CF6FB16B26B6AE3A662900FE1B8D3C870D28ED781EAC11881E18990"
    ~ "7BD9F44E5877624C7DB6ED0F37B8997061AA7D7532F38ECF000000003881E83ACCEF5EA3F1DC05AD"
    ~ "D289AE366F4D79BC50E7ED26E6208A5DDCFE1ECE34B17CF41A87B87B8A5DC65FE08C9A592AE43EA8"
    ~ "67D2851519BEF59E0494370E404B4C00000000009D0238E0A171400BC6D68A9D9B316ACD51096491"
    ~ "13A05C284F4296D2B30122F5C458EA9EE028D55B6E4DCB690AB1690AA8C4EE34D45ED9ED6B4C5260"
    ~ "AAF1B38AF9C0D176FA42B502F69FDD3B41155BB16A4AD23D104AC08C73482AFFA0AE002100000000"
    ~ "034C65371F53170947C9B0113272EF77DED61BDCBA9DA54386D30552D537DDDADBA7285D23132CD5"
    ~ "736513708C2D2C4331E8D9236744E70FCBAB5D58E9DF6F0E404B4C00000000009D0238E0A171400B"
    ~ "C6D68A9D9B316ACD5109649113A05C284F4296D2B30122F57CBD1776FC2D2A0F85CFC41138600712"
    ~ "32E1BB7D6DC79BBD0C84BE1597001ECE7D0436E86128F71A5F0A7954899D6F30285C110910CDD9B3"
    ~ "83F9E78DDBADFC3500000000C48335B0F74EC7D342BFB932C05CCECF0201AD66ACE88AEE9C3C11A6"
    ~ "3F6ABCF77BDFDE421AD0BECB91C1900337BFD32A26DD7F03FB3D5EE166EFD7986DB1400C404B4C00"
    ~ "000000009D0238E0A171400BC6D68A9D9B316ACD5109649113A05C284F4296D2B30122F505E9883F"
    ~ "411E618870438E779B439B13AB928F76B389CF58285F4F8BAD35AE2BEB1DDED87212EDA15C65B283"
    ~ "4022E553060430917E9C10C2368F2571478A29890000000082AEAB6723A0521AE8B5A2F08912096D"
    ~ "12ABBD87FE17A377DCDBBEF2F701BE95ABDBB12BCF839016C611599169F17A4FCB0351234D0EBDEB"
    ~ "0BD59829FC46CB0C404B4C00000000009D0238E0A171400BC6D68A9D9B316ACD5109649113A05C28"
    ~ "4F4296D2B30122F5ABEE9F177B2943DD4867E1CCA3130232F150B601A1F9C7A383F2FF362FED18C7"
    ~ "643C41B2D67358550C6F353DD78400F04ABB1B808824E57E0983D03044BD3FDD0000000012BDF056"
    ~ "A12C061CFF12017D128A4AC6186D867641FDD6396CF5B38E199EF712DDC0CC70CF37B0FAB871D96C"
    ~ "B56EB0F87E856E21EAE4CDB7D9153F3CD8CCEA09404B4C00000000009D0238E0A171400BC6D68A9D"
    ~ "9B316ACD5109649113A05C284F4296D2B30122F574EA636427DC86D14CB4DC9F7DBA500EA98A4CC4"
    ~ "E45A4DE9403F468E500449E0D32B6851E7E59A52D66E1EF5844F848EDBDED46C5C964DB3A14A3B00"
    ~ "AF40CC2600000000276D8D09B2AA057559046DE6DDB625EF8690B74FEF2933AF41A1B8AD09B7737D"
    ~ "62E4BAF3A0F248101CD78C6B7E202E55759DAE844C61660972B1A326D4BC690F404B4C0000000000"
    ~ "9D0238E0A171400BC6D68A9D9B316ACD5109649113A05C284F4296D2B30122F5";

    assert(data.toHexString() == serializeData, data.toHexString());
}
