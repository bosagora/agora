/*******************************************************************************

    Defines the data structure of a block

    The design is influenced by Bitcoin, but will be ammended later.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.Block;

import agora.common.Amount;
import agora.common.BitField;
import agora.common.crypto.Key;
import agora.common.Types;
import agora.common.Hash;
import agora.common.Serializer;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.Genesis;

import std.algorithm.comparison;
import std.algorithm.iteration;
import std.algorithm.searching;
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

    /// Bitfield containing the validators' key indices which signed the block
    public BitField!uint validators;

    /// Schnorr multisig of all validators which signed this block
    public Signature signature;

    /// Enrolled validators
    public Enrollment[] enrollments;

    /***************************************************************************

        Implements hashing support

        Note that validators bitfield & the signature are not hashed
        since they must sign the block header hash.

        Params:
            dg = Hashing function accumulator

    ***************************************************************************/

    public void computeHash (scope HashDg dg) const nothrow @safe @nogc
    {
        dg(this.prev_block[]);
        hashPart(this.height, dg);
        dg(this.merkle_root[]);
        foreach (enrollment; this.enrollments)
            hashPart(enrollment, dg);
    }

    /***************************************************************************

        Block Header Serialization

        Params:
            dg = serialize function accumulator

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) const @safe
    {
        dg(this.prev_block[]);
        serializePart(this.height, dg);
        dg(this.merkle_root[]);
        serializePart(this.validators, dg);
        serializePart(this.signature, dg);
        serializePart(this.enrollments.length, dg);
        foreach (enrollment; this.enrollments)
            serializePart(enrollment, dg);
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
        auto exp_hash = Hash("0xc04f3226bdc07c6d3141e3ac14888cd3b4199d84877" ~
            "e591927063af65e5f56b14f9236e764bacb980aed5acefb98981b221e5c99e" ~
            "aaaf1100c87c250cec2f32c");
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

    public void serialize (scope SerializeDg dg) const @safe
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

        Build a merkle tree and its root, and store the tree to this Block

        Returns:
            the merkle root

    ***************************************************************************/

    public Hash buildMerkleTree () nothrow @safe
    {
        return Block.buildMerkleTree(this.txs, this.merkle_tree);
    }

    /***************************************************************************

        Build a merkle tree and return its root

        Params:
            txs = the transactions to use
            merkle_tree = will contain the merkle tree on function return

        Returns:
            the merkle root

    ***************************************************************************/

    public static Hash buildMerkleTree (const(Transaction)[] txs,
        ref Hash[] merkle_tree) nothrow @safe
    in
    {
        assert(txs !is null, "When calling buildMerkleTree, `txs` must not be null.");
    }
    do
    {
        () @trusted { merkle_tree.assumeSafeAppend(); }();

        // workaround for issue #127 with ldc2 on osx
        const MerkleLength = (txs.length * 2) - 1;
        merkle_tree = new Hash[](MerkleLength);

        return Block.buildMerkleTreeImpl(txs, merkle_tree);
    }

    /// Ditto
    private static Hash buildMerkleTreeImpl (const(Transaction)[] txs,
        ref Hash[] merkle_tree) nothrow @safe @nogc
    in
    {
        assert(txs !is null, "When calling buildMerkleTreeImpl, `txs` must not be null.");
    }
    do
    {
        import core.bitop;
        const log2 = bsf(txs.length);
        assert((1 << log2) == txs.length,
               "Transactions for a block should be a strict power of 2");
        assert(merkle_tree.length == (txs.length * 2) - 1);

        foreach (size_t idx, ref hash; merkle_tree[0 .. txs.length])
            hash = hashFull(txs[idx]);

        // transactions are ordered lexicographically by hash in the Merkle tree
        merkle_tree[0 .. txs.length].sort!("a < b");

        immutable len = merkle_tree.length;
        for (size_t order = 0; order < log2; order++)
        {
            immutable start = len - (len >> (order));
            immutable end   = len - (len >> (order + 1));
            merkle_tree[start .. end].chunks(2)
                .map!(tup => hashMulti(tup[0], tup[1]))
                .enumerate(size_t(end))
                .each!((idx, val) => merkle_tree[idx] = val);
        }

        return merkle_tree[$ - 1];
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
                hash = hashMulti(otherside, hash);
            else
                hash = hashMulti(hash, otherside);

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
        assert(this.merkle_tree.length == (this.txs.length * 2) - 1,
            "Block hasn't been fully initialized");

        auto index = this.merkle_tree[0 .. this.txs.length]
            .enumerate.assumeSorted.find!(res => res[1] == hash);

        return index.empty ? this.txs.length : index.front[0];
    }
}

///
unittest
{
    import agora.common.crypto.Schnorr;
    immutable Hash merkle =
        Hash(`0xdb6e67f59fe0b30676037e4970705df8287f0de38298dcc09e50a8e85413` ~
        `959ca4c52a9fa1edbe6a47cbb6b5e9b2a19b4d0877cc1f5955a7166fe6884eecd2c3`);

    immutable address = `GDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQFW`;
    PublicKey pubkey = PublicKey.fromString(address);

    Transaction tx =
    {
        TxType.Payment,
        inputs: [ Input.init ],
        outputs: [
            Output(Amount(62_500_000L * 10_000_000L), pubkey),
            Output(Amount(62_500_000L * 10_000_000L), pubkey),
            Output(Amount(62_500_000L * 10_000_000L), pubkey),
            Output(Amount(62_500_000L * 10_000_000L), pubkey),
            Output(Amount(62_500_000L * 10_000_000L), pubkey),
            Output(Amount(62_500_000L * 10_000_000L), pubkey),
            Output(Amount(62_500_000L * 10_000_000L), pubkey),
            Output(Amount(62_500_000L * 10_000_000L), pubkey),
        ],
    };

    auto validators = typeof(BlockHeader.validators)(6);
    validators[0] = true;
    validators[2] = true;
    validators[4] = true;

    Enrollment[] enrollments;
    enrollments ~= Enrollment.init;
    enrollments ~= Enrollment.init;

    const ubyte[Signature.sizeof] sig_data = 42;
    Block block =
    {
        header:
        {
            prev_block:  Hash.init,
            height:      0,
            merkle_root: merkle,
            validators:  validators,
            signature:   Signature(sig_data),
            enrollments: enrollments,
        },
        txs: [ tx ],
        merkle_tree: [ merkle ],
    };

    testSymmetry!Block();
    testSymmetry(block);
}

/*******************************************************************************

    Create a new block, referencing the provided previous block.

    Params:
        prev_block = the previous block
        txs = the transactions that will be contained in the new block
        enrollments = the enrollments that will be contained in the new block

*******************************************************************************/

public Block makeNewBlock (Transactions)(const ref Block prev_block,
    Transactions txs, Enrollment[] enrollments) @safe nothrow
    if (isInputRange!Transactions)
{
    Block block;

    block.header.prev_block = prev_block.header.hashFull();
    block.header.height = prev_block.header.height + 1;
    txs.each!(tx => block.txs ~= tx);
    block.txs.sort;

    block.header.merkle_root = block.buildMerkleTree();
    block.header.enrollments = enrollments;
    assert(block.header.enrollments.isStrictlyMonotonic!
        ("a.utxo_key < b.utxo_key"));
    return block;
}

/// only used in unittests
version (unittest)
{
    public Block makeNewBlock (Transactions)(const ref Block prev_block,
        Transactions txs) @safe nothrow
        if (isInputRange!Transactions)
    {
        return makeNewBlock(prev_block, txs, null);
    }
}

///
@safe nothrow unittest
{
    auto new_block = makeNewBlock(GenesisBlock, [Transaction.init]);
    auto rng_block = makeNewBlock(GenesisBlock, [Transaction.init].take(1));
    assert(new_block.header.prev_block == hashFull(GenesisBlock.header));
    assert(new_block == rng_block);
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
        tx = Transaction(TxType.Payment, [Input(last_hash, 0)],[Output(Amount(100_000), key_pairs[idx+1].address)]);
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

    const Hash hab = hashMulti(ha, hb);
    const Hash hcd = hashMulti(hc, hd);
    const Hash hef = hashMulti(he, hf);
    const Hash hgh = hashMulti(hg, hh);

    const Hash habcd = hashMulti(hab, hcd);
    const Hash hefgh = hashMulti(hef, hgh);

    const Hash habcdefgh = hashMulti(habcd, hefgh);

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
