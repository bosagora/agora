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

import agora.common.Data;
import agora.common.Hash;
import agora.common.Transaction;


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
    public Transaction tx;
}
