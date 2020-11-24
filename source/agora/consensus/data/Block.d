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

import std.algorithm.comparison;
import std.algorithm.iteration;
import std.algorithm.searching;
import std.algorithm.sorting;
import std.range;

import core.bitop;

/*******************************************************************************

    The block header which contains a link to the previous block header,
    unless it's the genesis header.

*******************************************************************************/

public struct BlockHeader
{
    /// Hash of the previous block in the chain of blocks
    public Hash prev_block;

    /// Block height (genesis is #0)
    public Height height;

    /// The hash of the merkle root of the transactions
    public Hash merkle_root;

    /// Bitfield containing the validators' key indices which signed the block
    public BitField!ubyte validators;

    /// Schnorr multisig of all validators which signed this block
    public Signature signature;

    /// Enrolled validators
    public Enrollment[] enrollments;

    /// Hash of random seed of the preimages for this this height
    public Hash random_seed;

    /// List of indices to the validator UTXO set which have not revealed the preimage
    public uint[] missing_validators;

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
        hashPart(this.height.value, dg);
        dg(this.merkle_root[]);
        foreach (enrollment; this.enrollments)
            hashPart(enrollment, dg);
        dg(this.random_seed[]);
        foreach (validator; this.missing_validators)
            hashPart(validator, dg);
    }

    /***************************************************************************

        Block Header Serialization

        Params:
            dg = serialize function accumulator

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) const @safe
    {
        dg(this.prev_block[]);
        serializePart(this.height.value, dg);
        dg(this.merkle_root[]);
        serializePart(this.validators, dg);
        serializePart(this.signature, dg);
        serializePart(this.enrollments.length, dg);
        foreach (enrollment; this.enrollments)
            serializePart(enrollment, dg);
        dg(this.random_seed[]);
        serializePart(this.missing_validators.length, dg);
        foreach (validator; this.missing_validators)
            serializePart(validator, dg);
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
        auto exp_hash = Hash("0xc49255b83a9e125377df3de687abd883dd57df98aa7" ~
            "5bd5f26a7e7de89d78e2922fa426524aef0b7651467051736fb4c98e1d4737" ~
            "b2c91cfa0b866a3fae8bec8");
        assert(hash == exp_hash);
    }();
}

/*******************************************************************************

    The block which contains the block header and its body (the transactions).

*******************************************************************************/

public struct Block
{
    // some unittests still assume a block contains 8 txs. Once they're fixed
    // this constant should be removed.
    version (unittest)
    {
        /// number of transactions that constitutes a block
        public enum TxsInTestBlock = 8;
    }

    ///
    public BlockHeader header;

    ///
    public Transaction[] txs;

    ///
    public Hash[] merkle_tree;


    /***************************************************************************

        Returns:
            a copy of this block with a different signature and validators bitmask

        Params:
            signature = new signature
            validators = mask to indicate who has signed

    ***************************************************************************/

    public Block updateSignature (const Signature signature,
        BitField!ubyte validators) const @safe
    {
        return Block(
            BlockHeader(
                this.header.prev_block,
                this.header.height,
                this.header.merkle_root,
                validators,
                signature,
                this.header.enrollments.dup),
            // TODO: Optimize this by using dup for txs also
            this.txs.map!(tx =>
                tx.serializeFull.deserializeFull!Transaction).array,
            this.merkle_tree.dup);
    }

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

        Returns:
            a number that is power 2 aligned. If the number is already a power
            of two it returns that number. Otherwise returns the next bigger
            number which is itself a power of 2.

    ***************************************************************************/

    private static size_t getPow2Aligned (size_t value) @safe @nogc nothrow pure
    in
    {
        assert(value > 0);
    }
    do
    {
        return bsr(value) == bsf(value) ? value : (1 << (bsr(value) + 1));
    }

    ///
    unittest
    {
        assert(getPow2Aligned(1) == 1);
        assert(getPow2Aligned(2) == 2);
        assert(getPow2Aligned(3) == 4);
        assert(getPow2Aligned(4) == 4);
        assert(getPow2Aligned(5) == 8);
        assert(getPow2Aligned(7) == 8);
        assert(getPow2Aligned(8) == 8);
        assert(getPow2Aligned(9) == 16);
        assert(getPow2Aligned(15) == 16);
        assert(getPow2Aligned(16) == 16);
        assert(getPow2Aligned(17) == 32);
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
        immutable pow2_size = getPow2Aligned(txs.length);
        const MerkleLength = (pow2_size * 2) - 1;

        // 'new' instead of .length: workaround for issue #127 with ldc2 on osx
        merkle_tree = new Hash[](MerkleLength);

        return Block.buildMerkleTreeImpl(pow2_size, txs, merkle_tree);
    }

    /// Ditto
    private static Hash buildMerkleTreeImpl (in size_t pow2_size,
        const(Transaction)[] txs, ref Hash[] merkle_tree)
        nothrow @safe @nogc
    in
    {
        assert(txs !is null, "When calling buildMerkleTreeImpl, `txs` must not be null.");
    }
    do
    {
        assert(merkle_tree.length == (pow2_size * 2) - 1);

        const log2 = bsf(pow2_size);
        foreach (size_t idx, ref hash; merkle_tree[0 .. txs.length])
            hash = hashFull(txs[idx]);

        // transactions are ordered lexicographically by hash in the Merkle tree
        merkle_tree[0 .. txs.length].sort!("a < b");

        // repeat last hash if txs length was not a strict power of 2
        foreach (idx; txs.length .. pow2_size)
            merkle_tree[idx] = merkle_tree[txs.length - 1];

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

    public Hash[] getMerklePath (size_t index) const @safe nothrow
    {
        assert(this.merkle_tree.length != 0, "Block hasn't been fully initialized");

        immutable pow2_size = getPow2Aligned(this.txs.length);
        Hash[] merkle_path;
        size_t j = 0;
        for (size_t length = pow2_size; length > 1; length = (length + 1) / 2)
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

    public size_t findHashIndex (Hash hash) const @safe nothrow
    {
        immutable pow2_size = getPow2Aligned(this.txs.length);
        assert(this.merkle_tree.length == (pow2_size * 2) - 1,
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

    Block block =
    {
        header:
        {
            prev_block:  Hash.init,
            height:      Height(0),
            merkle_root: merkle,
            validators:  validators,
            signature:   Signature.fromString(
                            "0x0f55e869b35fdd36a1f5147771c0c2f5ad35ec7b3e4e"
                            ~ "4f77bd37f1e0aef06d1a4b62ed5c610735b73e3175"
                            ~ "47ab3dc3402b05fd57419a2a5def798a03df2ef56a"),
            enrollments: enrollments,
        },
        txs: [ tx ],
        merkle_tree: [ merkle ],
    };
    testSymmetry!Block();
    testSymmetry(block);
    assert(block.header.validators[0]);
    assert(!block.header.validators[1]);
}

/*******************************************************************************

    Create a new block, referencing the provided previous block.

    Params:
        prev_block = the previous block
        txs = the transactions that will be contained in the new block
        enrollments = the enrollments that will be contained in the new block

*******************************************************************************/

public Block makeNewBlock (Transactions)(const ref Block prev_block,
    Transactions txs, Enrollment[] enrollments = null) @safe nothrow
{
    static assert (isInputRange!Transactions);

    Block block;

    block.header.prev_block = prev_block.header.hashFull();
    block.header.height.value = prev_block.header.height.value + 1;
    txs.each!(tx => block.txs ~= tx);
    block.txs.sort;

    block.header.merkle_root = block.buildMerkleTree();
    block.header.enrollments = enrollments;
    block.header.enrollments.sort!((a, b) => a.utxo_key < b.utxo_key);
    assert(block.header.enrollments.isStrictlyMonotonic!
        ("a.utxo_key < b.utxo_key"));  // there cannot be duplicates either
    return block;
}

/// only used in unittests with defualt block signing with the genesis validators
version (unittest)
{
    import agora.utils.Test : WK;

    public KeyPair[] genesis_validator_keys = [
        WK.Keys.NODE2,
        WK.Keys.NODE3,
        WK.Keys.NODE4,
        WK.Keys.NODE5,
        WK.Keys.NODE6,
        WK.Keys.NODE7 ];

    ulong defaultCycleZero (PublicKey key)
    {
        return 0;
    }

    public Block makeNewTestBlock (Transactions)(const ref Block prev_block,
        Transactions txs, Enrollment[] enrollments = null,
        KeyPair[] keys = genesis_validator_keys,
        ulong delegate (PublicKey) cycleForValidator = (PublicKey k) => defaultCycleZero(k)) @safe nothrow
    {
        auto block = makeNewBlock(prev_block, txs, enrollments);
        return multiSigTestBlock(block, cycleForValidator, keys);
    }
}

///
@safe nothrow unittest
{
    import agora.consensus.data.genesis.Test;

    auto new_block = makeNewTestBlock(GenesisBlock, [Transaction.init]);
    auto rng_block = makeNewTestBlock(GenesisBlock, [Transaction.init].take(1));
    assert(new_block.header.prev_block == hashFull(GenesisBlock.header));
    assert(new_block == rng_block);

    Enrollment enr_1 =
    {
        utxo_key : Hash.fromString(
            "0x412ce227771d98240ffb0015ae49349670eded40267865c18f655db662d4e698f" ~
            "7caa4fcffdc5c068a07532637cf5042ae39b7af418847385480e620e1395986")
    };

    Enrollment enr_2 =
    {
        utxo_key : Hash.fromString(
            "0x412ce227771d98240ffb0015ae49349670eded40267865c18f655db662d4e698f" ~
            "7caa4fcffdc5c068a07532637cf5042ae39b7af418847385480e620e1395987")
    };

    auto block = makeNewBlock(GenesisBlock, [Transaction.init], [enr_1, enr_2]);
    assert(block.header.enrollments == [enr_1, enr_2]);  // ascending
    block = makeNewBlock(GenesisBlock, [Transaction.init], [enr_2, enr_1]);
    assert(block.header.enrollments == [enr_1, enr_2]);  // ditto
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
    block.header.height = Height(0);
    block.txs ~= txs;
    block.header.merkle_root = block.buildMerkleTree();

    Hash[] hashes;
    hashes.reserve(txs.length);
    foreach (ref e; txs)
        hashes ~= hashFull(e);

    // transactions are ordered lexicographically by hash in the Merkle tree
    hashes.sort!("a < b");
    foreach (idx, hash; hashes)
        assert(block.findHashIndex(hash) == idx);

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

// test when the number of txs is not a strict power of 2
unittest
{
    auto kp = KeyPair.random();
    Transaction[] txs;
    Hash[] hashes;

    foreach (amount; 0 .. 9)
    {
        txs ~= Transaction(TxType.Payment,
            [Input(Hash.init, 0)],
            [Output(Amount(amount + 1), kp.address)]);
        hashes ~= hashFull(txs[$ - 1]);
    }

    Block block;
    block.txs = txs;
    block.header.merkle_root = block.buildMerkleTree();

    // transactions are ordered lexicographically by hash in the Merkle tree
    hashes.sort!("a < b");
    foreach (idx, hash; hashes)
        assert(block.findHashIndex(hash) == idx);

    const Hash ha = hashes[0];
    const Hash hb = hashes[1];
    const Hash hc = hashes[2];
    const Hash hd = hashes[3];
    const Hash he = hashes[4];
    const Hash hf = hashes[5];
    const Hash hg = hashes[6];
    const Hash hh = hashes[7];
    const Hash hi = hashes[8];
    const Hash hj = hashes[8];
    const Hash hk = hashes[8];
    const Hash hl = hashes[8];
    const Hash hm = hashes[8];
    const Hash hn = hashes[8];
    const Hash ho = hashes[8];
    const Hash hp = hashes[8];

    const Hash hab = hashMulti(ha, hb);
    const Hash hcd = hashMulti(hc, hd);
    const Hash hef = hashMulti(he, hf);
    const Hash hgh = hashMulti(hg, hh);
    const Hash hij = hashMulti(hi, hj);
    const Hash hkl = hashMulti(hk, hl);
    const Hash hmn = hashMulti(hm, hn);
    const Hash hop = hashMulti(ho, hp);

    const Hash habcd = hashMulti(hab, hcd);
    const Hash hefgh = hashMulti(hef, hgh);
    const Hash hijkl = hashMulti(hij, hkl);
    const Hash hmnop = hashMulti(hmn, hop);

    const Hash habcdefgh = hashMulti(habcd, hefgh);
    const Hash hijklmnop = hashMulti(hijkl, hmnop);

    const Hash habcdefghijklmnop = hashMulti(habcdefgh, hijklmnop);

    assert(block.header.merkle_root == habcdefghijklmnop);

    auto merkle_path = block.getMerklePath(2);
    assert(merkle_path.length == 4);
    assert(merkle_path[0] == hd);
    assert(merkle_path[1] == hab);
    assert(merkle_path[2] == hefgh);
    assert(merkle_path[3] == hijklmnop);
    assert(block.header.merkle_root == Block.checkMerklePath(hc, merkle_path, 2));

    merkle_path = block.getMerklePath(4);
    assert(merkle_path.length == 4);
    assert(merkle_path[0] == hf);
    assert(merkle_path[1] == hgh);
    assert(merkle_path[2] == habcd);
    assert(merkle_path[3] == hijklmnop);
    assert(block.header.merkle_root == Block.checkMerklePath(he, merkle_path, 4));

    merkle_path = block.getMerklePath(8);
    assert(merkle_path.length == 4);
    assert(merkle_path[0] == hj);
    assert(merkle_path[1] == hkl);
    assert(merkle_path[2] == hmnop);
    assert(merkle_path[3] == habcdefgh);
    assert(block.header.merkle_root == Block.checkMerklePath(hi, merkle_path, 8));
}

version (unittest)
{
    import agora.utils.Log;
    mixin AddLogger!();

    public Block multiSigTestBlock (ref Block block,
        ulong delegate (PublicKey) cycleForValidator,
        KeyPair[] keys) @trusted nothrow
    {
        import agora.common.crypto.Schnorr;
        import agora.common.crypto.ECC;
        import std.format;

        auto validators = BitField!ubyte(keys.length);
        Signature[] sigs;

        // challenge = Hash(block) to Scalar
        const Scalar challenge = hashFull(block);

        void validatorSign (ulong i, KeyPair key)
        {
            Scalar v = secretKeyToCurveScalar(key.secret);
            // rc = r used in signing the commitment
            const Scalar rc = Scalar(hashMulti(v, "consensus.signature.noise",
                cycleForValidator(key.address)));
            const Scalar r = rc + challenge; // make it unique each challenge
            const Pair R = Pair.fromScalar(r);
            const K = Point(key.address[]);
            auto sig = multiSigSign(R, v, challenge);
            log.trace("multiSigTestBlock: cycle {} index {} Commited R for validator {} is \n{} \nsig is {}",
                cycleForValidator(key.address), i, key.address, rc.toPoint(), sig);
            sigs ~= sig;
            validators[i] = true;
        }
        try
        {
            keys.enumerate.each!((idx, key) => validatorSign(idx, key));
        } catch (Exception e)
        {
            assert(0, format!"Unit test signing error: %s"(e));
        }
        // Create new block with updates
        block.header.validators = validators;
        block.header.signature = multiSigCombine(sigs);
        return block;
    }
}
