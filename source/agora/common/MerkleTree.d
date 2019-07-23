/*******************************************************************************

    Contains MerkleTree that makes binary tree of transactions.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.MerkleTree;

import agora.common.Data;
import agora.common.Hash;
import agora.common.Transaction;

import std.algorithm;


/***************************************************************************

    Build merkle tree

    Params:
        txs = Array of `Transaction`
        merkle_tree = Hash of merkle tree

    Returns:
        Return merkle root

***************************************************************************/

public Hash buildMerkleTree(ref Transaction[] txs, ref Hash[] merkle_tree)
{
    merkle_tree.length = txs.length;

    foreach (size_t idx, ref hash; merkle_tree)
        hash = hashFull(txs[idx]);

    size_t j = 0;
    for (size_t length = txs.length; length > 1; length = (length + 1) / 2)
    {
        for (size_t i = 0; i < length; i += 2)
        {
            size_t i2 = min(i + 1, length - 1);
            merkle_tree ~= mergeHash(merkle_tree[j + i], merkle_tree[j + i2]);
        }
        j += length;
    }
    return ((merkle_tree.length == 0) ? Hash.init : merkle_tree[$ - 1]);
}

    /*******************************************************************************

        Get merkle branch

        Params:
            merkle_tree = Array of Hash, this is Merkle Tree
            size_txs = Number of transactions
            index = Sequence of transactions

        Returns:
            Return merkle branch

    *******************************************************************************/

    public Hash[] getMerkleBranch(ref Hash[] merkle_tree, size_t size_txs, size_t index)
    {
        Hash[] merkle_branch;
        size_t j = 0;
        for (size_t length = size_txs; length > 1; length = (length + 1) / 2)
        {
            size_t i = min(index ^ 1, length - 1);
            merkle_branch ~= merkle_tree[j + i];
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

    public Hash checkMerkleBranch(Hash hash, const ref Hash[] merkle_branch, size_t index)
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

/// Merge two hash
public Hash mergeHash (Hash h1, Hash h2)
        nothrow @nogc @trusted
{
    static struct MergeHash
    {
        Hash left;
        Hash right;

        public void computeHash (scope HashDg dg) const nothrow @safe @nogc
        {
            hashPart(this.left, dg);
            hashPart(this.right, dg);
        }
    }

    return hashFull(MergeHash(h1, h2));
}

/// Test of Merkle Path and Merkle Proof
unittest
{
    import agora.common.crypto.Key;

    Transaction[] txs;
    Hash[] merkle_tree;
    Hash[] merkle_branch;
    Hash merkle_root;

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

    merkle_root = buildMerkleTree(txs, merkle_tree);

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

    assert(merkle_root == h01234567, "Error in MerkleTree.");

    // Merkle Proof
    merkle_branch = getMerkleBranch(merkle_tree, txs.length, 2);
    assert(merkle_branch.length == 3);
    assert(merkle_branch[0] == h3, "Error in the merkle path.");
    assert(merkle_branch[1] == h01, "Error in the merkle path.");
    assert(merkle_branch[2] == h4567, "Error in the merkle path.");

    assert(merkle_root == checkMerkleBranch(h2, merkle_branch, 2), "Error in the merkle proof.");

    merkle_branch = getMerkleBranch(merkle_tree, txs.length, 4);
    assert(merkle_branch.length == 3);
    assert(merkle_branch[0] == h5, "Error in the merkle path.");
    assert(merkle_branch[1] == h67, "Error in the merkle path.");
    assert(merkle_branch[2] == h0123, "Error in the merkle path.");

    assert(merkle_root == checkMerkleBranch(h4, merkle_branch, 4), "Error in the merkle proof.");
}
