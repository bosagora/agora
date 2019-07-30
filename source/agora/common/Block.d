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
import agora.common.Deserializer;
import agora.common.Hash;
import agora.common.Serializer;
import agora.common.Transaction;
import agora.consensus.Genesis;

import std.algorithm.comparison;
import std.algorithm.iteration;
import std.algorithm.sorting;
import std.range;

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

    /// The hash of the merkle root of the transactions
    public Hash merkle_root;


    /***************************************************************************

        Implements hashing support

        Params:
            dg = Hashing function accumulator

    ***************************************************************************/

    public void computeHash (scope HashDg dg) const nothrow @safe @nogc
    {
        dg(this.prev_block[]);
        hashPart(this.height, dg);
        dg(this.merkle_root[]);
    }

    /***************************************************************************

        Block Header Serialization

        Params:
            dg = serialize function accumulator

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) const nothrow @safe
    {
        dg(this.prev_block[]);
        serializePart(this.height, dg);
        dg(this.merkle_root[]);
    }

    /***************************************************************************

        Block Header Deserialization

        Params:
            dg = deserialize function accumulator

    ***************************************************************************/

    public void deserialize (scope DeserializeDg dg) nothrow @safe
    {
        this.prev_block = Hash(dg(Hash.sizeof));
        deserializePart(this.height, dg);
        this.merkle_root = Hash(dg(Hash.sizeof));
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
        Output[1] outputs = [ Output(Amount(100), pubkey) ];
        Transaction tx = { outputs: outputs[] };
        BlockHeader header = { merkle_root : tx.hashFull() };

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
    /// number of transactions that constitutes a block
    public enum TxsInBlock = 8;

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

    public void serialize (scope SerializeDg dg) const nothrow @safe
    {
        serializePart(this.header, dg);

        serializePart(this.txs.length, dg);
        foreach (ref tx; this.txs)
            serializePart(tx, dg);

        serializePart(this.merkle_tree.length, dg);
        foreach (ref merkle; this.merkle_tree)
            dg(merkle[]);
    }

    /***************************************************************************

        Block Deserialization

        Params:
            dg = deserialize function accumulator

    ***************************************************************************/

    public void deserialize (scope DeserializeDg dg) nothrow @safe
    {
        deserializePart(this.header, dg);

        size_t size;
        deserializePart(size, dg);
        this.txs.length = size;
        foreach (ref tx; this.txs)
            deserializePart(tx, dg);

        deserializePart(size, dg);
        this.merkle_tree.length = size;
        foreach (ref h; this.merkle_tree)
            deserializePart(h, dg);
    }

    /***************************************************************************

        Build merkle tree

        Returns:
            Return merkle root

    ***************************************************************************/

    public Hash buildMerkleTree () nothrow @safe
    {
        this.merkle_tree.length = (this.txs.length * 2) - 1;
        return this.buildMerkleTreeImpl();
    }

    /// Ditto
    public Hash buildMerkleTreeImpl () nothrow @safe @nogc
    {
        import core.bitop;
        const log2 = bsf(this.txs.length);
        assert((1 << log2) == this.txs.length,
               "Transactions for a block should be a strict power of 2");
        assert(this.merkle_tree.length == (this.txs.length * 2) - 1);

        foreach (size_t idx, ref hash; this.merkle_tree[0 .. this.txs.length])
            hash = hashFull(this.txs[idx]);

        // transactions are ordered lexicographically by hash in the Merkle tree
        this.merkle_tree[0 .. this.txs.length].sort!("a < b");

        immutable len = this.merkle_tree.length;
        for (size_t order = 0; order < log2; order++)
        {
            immutable start = len - (len >> (order));
            immutable end   = len - (len >> (order + 1));
            this.merkle_tree[start .. end].chunks(2)
                .map!(tup => mergeHash(tup[0], tup[1]))
                .enumerate(size_t(end))
                .each!((idx, val) => this.merkle_tree[idx] = val);
        }

        return this.merkle_tree[$ - 1];
    }

    /***************************************************************************

        Get merkle path

        Params:
            index = Sequence of transactions

        Returns:
            Return merkle path

    ***************************************************************************/

    public Hash[] getMerklePath (size_t index) const @safe
    {
        assert(this.merkle_tree.length != 0, "Block hasn't been fully initialized");

        Hash[] merkle_path;
        size_t j = 0;
        for (size_t length = this.txs.length; length > 1; length = (length + 1) / 2)
        {
            size_t i = min(index ^ 1, length - 1);
            merkle_path ~= this.merkle_tree[j + i];
            index >>= 1;
            j += length;
        }
        return merkle_path;
    }

    /***************************************************************************

        Calculate the merkle root using the merkle path.

        Params:
            hash = `Hash` of `Transaction`
            merkle_path  = `Hash` of merkle path
            index = Index of the hash in the array of transactions.

        Returns:
            Return `Hash` of merkle root.

    ***************************************************************************/

    public static Hash checkMerklePath (Hash hash, Hash[] merkle_path, size_t index) @safe
    {
        foreach (const ref otherside; merkle_path)
        {
            if (index & 1)
                hash = mergeHash(otherside, hash);
            else
                hash = mergeHash(hash, otherside);

            index >>= 1;
        }

        return hash;
    }

    /***************************************************************************

        Find the sequence of transactions for the hash.

        Params:
            hash = `Hash` of `Transaction`

        Returns:
            Return sequence if found hash, otherwise Retrun the number of
            transactions.

    ***************************************************************************/

    public size_t findHashIndex (Hash hash) const @safe
    {
        assert(this.merkle_tree.length != 0, "Block hasn't been fully initialized");

        foreach (idx; 0 .. min(this.txs.length, this.merkle_tree.length))
            if (hash == this.merkle_tree[idx])
                return idx;
        return this.txs.length;
    }
}

/*******************************************************************************

    Create a new block, referencing the provided previous block.
    In the current preliminary design a block contains a single transaction.

    Params:
        prev_block = the previous block
        txs = the transactions that will be contained in the new block

*******************************************************************************/

public Block makeNewBlock (const ref Block prev_block, Transaction[] txs) @safe
{
    Block block;

    block.header.prev_block = prev_block.header.hashFull();
    block.header.height = prev_block.header.height + 1;
    block.txs ~= txs;

    block.header.merkle_root = block.buildMerkleTree();

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
    Hash[] merkle_path;

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
        tx = Transaction([Input(last_hash, 0)],[Output(Amount(100_000), key_pairs[idx+1].address)]);
        last_hash = hashFull(tx);
        tx.inputs[0].signature = key_pairs[idx].secret.sign(last_hash[]);
        txs ~= tx;
    }

    Block block;

    block.header.prev_block = Hash.init;
    block.header.height = 0;
    block.txs ~= txs;
    block.header.merkle_root = block.buildMerkleTree();

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

    assert(block.header.merkle_root == habcdefgh);

    // Merkle Proof
    merkle_path = block.getMerklePath(2);
    assert(merkle_path.length == 3);
    assert(merkle_path[0] == hd);
    assert(merkle_path[1] == hab);
    assert(merkle_path[2] == hefgh);
    assert(block.header.merkle_root == Block.checkMerklePath(hc, merkle_path, 2));

    merkle_path = block.getMerklePath(4);
    assert(merkle_path.length == 3);
    assert(merkle_path[0] == hf);
    assert(merkle_path[1] == hgh);
    assert(merkle_path[2] == habcd);
    assert(block.header.merkle_root == Block.checkMerklePath(he, merkle_path, 4));
}
