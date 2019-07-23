/*******************************************************************************

    Defines the data structure of a block

    The design is influenced by Bitcoin, but will be ammended later.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Block;

import agora.common.crypto.Key;
import agora.common.Data;
import agora.common.Hash;
import agora.common.Transaction;
import agora.node.BlockSerialize;

import std.algorithm.comparison;

/*******************************************************************************

    The block header which contains a link to the previous block header,
    unless it's the genesis header.

*******************************************************************************/

public struct BlockHeader
{
    /// Hash of the previous block in the chain of blocks
    public Hash prev_block;

    /// Block height (genesis is #0)
    public ulong height;

    /// The hash of the only transaction in the block
    /// (later to be replaced with a merkle root)
    public Hash tx_hash;


    /***************************************************************************

        Implements hashing support

        Params:
            dg = Hashing function accumulator

    ***************************************************************************/

    public void computeHash (scope HashDg dg) const nothrow @safe @nogc
    {
        dg(this.prev_block[]);
        hashPart(this.height, dg);
        dg(this.tx_hash[]);
    }

    /***************************************************************************

        Block Header Serialization

        Params:
             dg = serialize function accumulator

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) pure const nothrow @safe
    {
        dg(this.prev_block[]);
        serializePart(this.height, dg);
        dg(this.tx_hash[]);
    }
}

/// hashing test
unittest
{
    import agora.common.crypto.Key;
    auto address = `GDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQFW`;
    PublicKey pubkey = PublicKey.fromString(address);

    // above parts not @safe/@nogc yet
    () @safe @nogc nothrow
    {
        Output[1] outputs = [ Output(100, pubkey) ];
        Transaction tx = { outputs: outputs[] };
        BlockHeader header = { tx_hash : tx.hashFull() };

        auto hash = hashFull(header);
        auto exp_hash = Hash("0xc45f765d063deece0348f9e7d47287fec5324395b1c" ~
            "065cde457dbb3c809cbb680450e86ac86bac50ce0d5cd8b1f9b04b29c1b2e5" ~
            "4cee5d6d5aaac38bb4dca3c");
        assert(hash == exp_hash);
    }();
}

/*******************************************************************************

    The block which contains the block header and its body (the transactions).

    In the current preliminary design a block contains a single transaction.

*******************************************************************************/

public struct Block
{
    ///
    public BlockHeader header;

    ///
    public Transaction[] txs;

    ///
    public Hash[] merkle_tree;


    /***************************************************************************

        Block serialization

        Params:
            dg = serialize function accumulator

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) pure const nothrow @safe
    {
        serializePart(this.header, dg);
        foreach (ref tx; this.txs)
            serializePart(tx, dg);
    }

    /***************************************************************************

        Build merkle tree

        Returns:
            Return merkle root

    ***************************************************************************/

    public Hash buildMerkleTree() @safe
    {
        this.merkle_tree.length = this.txs.length;
        foreach (size_t idx, ref hash; this.merkle_tree)
            hash = hashFull(this.txs[idx]);

        size_t j = 0;
        for (size_t length = this.txs.length; length > 1; length = (length + 1) / 2)
        {
            for (size_t i = 0; i < length; i += 2)
            {
                size_t i2 = min(i + 1, length - 1);
                this.merkle_tree ~= mergeHash(this.merkle_tree[j + i], this.merkle_tree[j + i2]);
            }
            j += length;
        }
        return ((this.merkle_tree.length == 0) ? Hash.init : this.merkle_tree[$ - 1]);
    }

    /*******************************************************************************

        Get merkle branch

        Params:
            index = Sequence of transactions

        Returns:
            Return merkle branch

    *******************************************************************************/

    public Hash[] getMerkleBranch(size_t index) @safe
    {
        if (this.merkle_tree.length == 0)
            this.buildMerkleTree();

        Hash[] merkle_branch;
        size_t j = 0;
        for (size_t length = this.txs.length; length > 1; length = (length + 1) / 2)
        {
            size_t i = min(index ^ 1, length - 1);
            merkle_branch ~= this.merkle_tree[j + i];
            index >>= 1;
            j += length;
        }
        return merkle_branch;
    }

    /*******************************************************************************

        Calculate the merkle root using the merkle branch.

        Params:
            hash = `Hash` of `Transaction`
            merkle_branch = `Hash` of merkle branch
            index = Index of the hash in the array of transactions. It starts at zero.

        Returns:
            Return `Hash` of merkle root.

    *******************************************************************************/

    public static Hash checkMerkleBranch(Hash hash, const ref Hash[] merkle_branch, size_t index) @safe
    {
        foreach(const ref otherside; merkle_branch)
        {
            if (index & 1)
                hash = mergeHash(otherside, hash);
            else
                hash = mergeHash(hash, otherside);
            index >>= 1;
        }
        return hash;
    }
}

/*******************************************************************************

    Get the key-pair which can spend the UTXO in the genesis transaction.
    Used for unittests, will be removed later.

    Returns:
        the key pair which can spend the UTXO in the genesis transaction

*******************************************************************************/

public KeyPair getGenesisKeyPair ()
{
    return KeyPair.fromSeed(
        Seed.fromString(
            "SCT4KKJNYLTQO4TVDPVJQZEONTVVW66YLRWAINWI3FZDY7U4JS4JJEI4"));
}

/*******************************************************************************

    Creates the genesis block.
    The output address is currently hardcoded to a randomly generated value,
    it will be replaced later with the proper address.

    Returns:
        the genesis block

*******************************************************************************/

public Block getGenesisBlock ()
{
    import agora.common.crypto.Key;

    auto gen_tx = newCoinbaseTX(getGenesisKeyPair().address, 40_000_000);
    auto header = BlockHeader(
        Hash.init, 0,
        mergeHash(hashFull(gen_tx),hashFull(gen_tx)));

    return Block(header, [gen_tx]);
}

///
unittest
{
    // ensure the genesis block is always the same
    assert(getGenesisBlock() == getGenesisBlock());
}

/*******************************************************************************

    Create a new block, referencing the provided previous block.
    In the current preliminary design a block contains a single transaction.

    Params:
        prev_block = the previous block
        txs = the transactions that will be contained in the new block

*******************************************************************************/

public Block makeNewBlock (Block prev_block, Transaction[] txs) @safe
{
    Block block;

    block.header.prev_block = prev_block.header.hashFull();
    block.header.height = prev_block.header.height + 1;
    block.txs ~= txs;

    block.header.tx_hash = block.buildMerkleTree();

    return block;
}

///
unittest
{
    Block gen_block = getGenesisBlock();

    // above parts not @safe/@nogc yet
    () @safe
    {
        auto new_block = makeNewBlock(gen_block, [Transaction.init]);
        assert(new_block.header.prev_block == hashFull(gen_block.header));
    }();
}


/// Test of Merkle Path and Merkle Proof
unittest
{
    Transaction[] txs;
    Hash[] merkle_branch;

    KeyPair[] key_pairs = [
        KeyPair.random(),
        KeyPair.random(),
        KeyPair.random(),
        KeyPair.random(),
        KeyPair.random(),
        KeyPair.random(),
        KeyPair.random(),
        KeyPair.random(),
        KeyPair.random()
    ];

    // Create transactions.
    Transaction tx;
    Hash last_hash = Hash.init;
    for (int idx = 0; idx < 8; idx++)
    {
        tx = Transaction([Input(last_hash, 0)],[Output(100_000, key_pairs[idx+1].address)]);
        last_hash = hashFull(tx);
        tx.inputs[0].signature = key_pairs[idx].secret.sign(last_hash[]);
        txs ~= tx;
    }

    Block block;

    block.header.prev_block = Hash.init;
    block.header.height = 0;
    block.txs ~= txs;
    block.header.tx_hash = block.buildMerkleTree();

    const Hash h0 = hashFull(txs[0]);
    const Hash h1 = hashFull(txs[1]);
    const Hash h2 = hashFull(txs[2]);
    const Hash h3 = hashFull(txs[3]);
    const Hash h4 = hashFull(txs[4]);
    const Hash h5 = hashFull(txs[5]);
    const Hash h6 = hashFull(txs[6]);
    const Hash h7 = hashFull(txs[7]);

    const Hash h01 = mergeHash(h0, h1);
    const Hash h23 = mergeHash(h2, h3);
    const Hash h45 = mergeHash(h4, h5);
    const Hash h67 = mergeHash(h6, h7);

    const Hash h0123 = mergeHash(h01, h23);
    const Hash h4567 = mergeHash(h45, h67);

    const Hash h01234567 = mergeHash(h0123, h4567);

    assert(block.header.tx_hash == h01234567, "Error in MerkleTree.");

    // Merkle Proof
    merkle_branch = block.getMerkleBranch(2);
    assert(merkle_branch.length == 3);
    assert(merkle_branch[0] == h3, "Error in the merkle path.");
    assert(merkle_branch[1] == h01, "Error in the merkle path.");
    assert(merkle_branch[2] == h4567, "Error in the merkle path.");
    assert(block.header.tx_hash == Block.checkMerkleBranch(h2, merkle_branch, 2), "Error in the merkle proof.");

    merkle_branch = block.getMerkleBranch(4);
    assert(merkle_branch.length == 3);
    assert(merkle_branch[0] == h5, "Error in the merkle path.");
    assert(merkle_branch[1] == h67, "Error in the merkle path.");
    assert(merkle_branch[2] == h0123, "Error in the merkle path.");
    assert(block.header.tx_hash == Block.checkMerkleBranch(h4, merkle_branch, 4), "Error in the merkle proof.");
}
