/*******************************************************************************

    Contains primitives related to the genesis block

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.Genesis;

import agora.common.Amount;
import agora.common.Hash;
import agora.common.Types;
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.consensus.validation.Block;

/// Contains a pointer to the genesis block.
version (unittest)
    private immutable(Block)* gen_block = &UnitTestGenesisBlock;
else
    private immutable(Block)* gen_block = &CoinNetGenesisBlock;

/*******************************************************************************

    Returns:
        a reference to the genesis block.

*******************************************************************************/

pragma(inline, true)
public ref immutable(Block) GenesisBlock () nothrow @safe @nogc
{
    return *gen_block;
}

/*******************************************************************************

    Set a custom Genesis block. Any subsequent call to `GenesisBlock`
    will refer to the Block as configured here.

    Params:
        block = the new Genesis block to use

*******************************************************************************/

pragma(inline, true)
public void setGenesisBlock (immutable Block* block)
    @safe
{
    assert(block !is null);

    if (auto reason = isGenesisBlockInvalidReason(*gen_block))
        throw new Exception(reason);

    gen_block = block;
}

/*******************************************************************************

    Returns:
        a reference to the genesis transaction

*******************************************************************************/

pragma(inline, true)
public ref immutable(Transaction) GenesisTransaction () nothrow @safe @nogc
{
    return gen_block.txs[0];
}

/// Genesis block as used by most unittests
private immutable Block UnitTestGenesisBlock = {
    header: {
        prev_block:  Hash.init,
        height:      Height(0),
        merkle_root: UnitTestGenesisMerkleTree[$ - 1],
    },
    merkle_tree: UnitTestGenesisMerkleTree,
    txs: [
        {
            TxType.Payment,
            outputs: [
                Output(Amount(62_500_000L * 10_000_000L), UnitTestGenesisOutputAddress),
                Output(Amount(62_500_000L * 10_000_000L), UnitTestGenesisOutputAddress),
                Output(Amount(62_500_000L * 10_000_000L), UnitTestGenesisOutputAddress),
                Output(Amount(62_500_000L * 10_000_000L), UnitTestGenesisOutputAddress),
                Output(Amount(62_500_000L * 10_000_000L), UnitTestGenesisOutputAddress),
                Output(Amount(62_500_000L * 10_000_000L), UnitTestGenesisOutputAddress),
                Output(Amount(62_500_000L * 10_000_000L), UnitTestGenesisOutputAddress),
                Output(Amount(62_500_000L * 10_000_000L), UnitTestGenesisOutputAddress),
            ],
        },
    ],
};

///
unittest
{
    import std.algorithm;

    version (none)
    {
        import std.stdio;
        import std.range;

        const txs = UnitTestGenesisBlock.txs;

        if (!txs.isStrictlyMonotonic())
        {
            writeln("WARN: Genesis block transactions are unsorted!");
            txs.enumerate.each!((idx, tx) => writefln("[%d]: %s", idx, tx));
        }

        Hash[] merkle_tree;
        writeln("Merkle root: ", Block.buildMerkleTree(txs, merkle_tree));
        writeln("\tMerkle tree: ", merkle_tree);
    }

    Amount amount;
    assert(UnitTestGenesisBlock.txs.all!(tx => tx.getSumOutput(amount)));
    assert(amount == Amount.MaxUnitSupply, amount.toString());
    assert(UnitTestGenesisBlock.merkle_tree.length == UnitTestGenesisMerkleTree.length);
    assert(UnitTestGenesisBlock.header.merkle_root == UnitTestGenesisBlock.merkle_tree[$-1]);
}

private immutable Hash[] UnitTestGenesisMerkleTree = [
    Hash(`0x5d7f6a7a30f7ff591c8649f61eb8a35d034824ed5cd252c2c6f10cdbd223671` ~
         `3dc369ef2a44b62ba113814a9d819a276ff61582874c9aee9c98efa2aa1f10d73`),
];

/// GCOQEOHAUFYUAC6G22FJ3GZRNLGVCCLESEJ2AXBIJ5BJNUVTAERPLRIJ
private immutable PublicKey UnitTestGenesisOutputAddress = UnitTestGenesisAddressUbyte;

///
private immutable ubyte[] UnitTestGenesisAddressUbyte =
    [
        0x9D, 0x02, 0x38, 0xE0, 0xA1, 0x71, 0x40, 0x0B,
        0xC6, 0xD6, 0x8A, 0x9D, 0x9B, 0x31, 0x6A, 0xCD,
        0x51, 0x09, 0x64, 0x91, 0x13, 0xA0, 0x5C, 0x28,
        0x4F, 0x42, 0x96, 0xD2, 0xB3, 0x01, 0x22, 0xF5,
    ];

unittest
{
    assert(UnitTestGenesisOutputAddress.toString()
           == `GCOQEOHAUFYUAC6G22FJ3GZRNLGVCCLESEJ2AXBIJ5BJNUVTAERPLRIJ`);
}

unittest
{
    import agora.common.Serializer;
    testSymmetry(UnitTestGenesisBlock.txs[0]);
    testSymmetry(UnitTestGenesisBlock);
}

/// The genesis block as defined by CoinNet
private immutable Block CoinNetGenesisBlock =
{
    header:
    {
        prev_block:  Hash.init,
        height:      Height(0),
        merkle_root: CoinNetGenesisMerkleRoot,
    },
    txs: [ CoinNetGenesisTransaction ],
    merkle_tree: [ CoinNetGenesisMerkleRoot ],
};

///
unittest
{
    assert(CoinNetGenesisBlock.header.prev_block == Hash.init);
    assert(CoinNetGenesisBlock.header.height == 0);
    assert(CoinNetGenesisBlock.header.merkle_root == CoinNetGenesisBlock.merkle_tree[0]);
    assert(CoinNetGenesisBlock.merkle_tree.length == 1);
    assert(CoinNetGenesisBlock.header.merkle_root == hashFull(CoinNetGenesisTransaction));
}

///
private immutable Hash CoinNetGenesisMerkleRoot =
    Hash(`0x5d7f6a7a30f7ff591c8649f61eb8a35d034824ed5cd252c2c6f10cdbd223671` ~
         `3dc369ef2a44b62ba113814a9d819a276ff61582874c9aee9c98efa2aa1f10d73`);


/// The single transaction that are part of the genesis block
private immutable Transaction CoinNetGenesisTransaction =
{
    TxType.Payment,
    inputs: [],
    outputs: [
        Output(Amount(62_500_000L * 10_000_000L), CoinNetGenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), CoinNetGenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), CoinNetGenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), CoinNetGenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), CoinNetGenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), CoinNetGenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), CoinNetGenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), CoinNetGenesisOutputAddress),
    ],
};

// TODO: Replace with the foundation's pubkey
/// GCOQEOHAUFYUAC6G22FJ3GZRNLGVCCLESEJ2AXBIJ5BJNUVTAERPLRIJ
private immutable PublicKey CoinNetGenesisOutputAddress = CoinNetGenesisAddressUbyte;

///
private immutable ubyte[] CoinNetGenesisAddressUbyte =
    [
        0x9D, 0x02, 0x38, 0xE0, 0xA1, 0x71, 0x40, 0x0B,
        0xC6, 0xD6, 0x8A, 0x9D, 0x9B, 0x31, 0x6A, 0xCD,
        0x51, 0x09, 0x64, 0x91, 0x13, 0xA0, 0x5C, 0x28,
        0x4F, 0x42, 0x96, 0xD2, 0xB3, 0x01, 0x22, 0xF5,
    ];

unittest
{
    assert(CoinNetGenesisOutputAddress.toString()
           == `GCOQEOHAUFYUAC6G22FJ3GZRNLGVCCLESEJ2AXBIJ5BJNUVTAERPLRIJ`);
}

unittest
{
    import agora.common.Serializer;
    testSymmetry(CoinNetGenesisTransaction);
    testSymmetry(CoinNetGenesisBlock);
}
