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
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;

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
    nothrow @trusted @nogc
{
    assert(block !is null);

    // note: see #747
    //if (auto reason = isInvalidReason(block, 0, Hash.init, null))
    //    throw new Exception(reason);

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
private immutable Block UnitTestGenesisBlock =
{
    header:
    {
        prev_block:  Hash.init,
        height:      0,
        merkle_root: UnitTestGenesisMerkleRoot,
    },
    txs: [ UnitTestGenesisTransaction ],
    merkle_tree: [ UnitTestGenesisMerkleRoot ],
};

///
unittest
{
    assert(UnitTestGenesisBlock.header.prev_block == Hash.init);
    assert(UnitTestGenesisBlock.header.height == 0);
    assert(UnitTestGenesisBlock.header.merkle_root == UnitTestGenesisBlock.merkle_tree[0]);
    assert(UnitTestGenesisBlock.merkle_tree.length == 1);
    assert(UnitTestGenesisBlock.header.merkle_root == hashFull(UnitTestGenesisTransaction));
}

private immutable Hash UnitTestGenesisMerkleRoot =
    Hash(`0xdb6e67f59fe0b30676037e4970705df8287f0de38298dcc09e50a8e85413959ca`
         ~ `4c52a9fa1edbe6a47cbb6b5e9b2a19b4d0877cc1f5955a7166fe6884eecd2c3`);

/// The single transaction that are part of the genesis block
private immutable Transaction UnitTestGenesisTransaction =
{
    TxType.Payment,
    inputs: [ Input.init ],
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
};

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
    testSymmetry(UnitTestGenesisTransaction);
    testSymmetry(UnitTestGenesisBlock);
}

version (unittest)
{
    /***************************************************************************

        Get the key-pair which can spend the UTXO in the genesis transaction.

        In unittests, we need the genesis key pair to be known for us to be
        able to test anything. Hence the genesis block has a different value.

        Seed:    SCT4KKJNYLTQO4TVDPVJQZEONTVVW66YLRWAINWI3FZDY7U4JS4JJEI4
        Address: GCOQEOHAUFYUAC6G22FJ3GZRNLGVCCLESEJ2AXBIJ5BJNUVTAERPLRIJ

        Returns:
            the key pair which can spend the UTXO in the genesis transaction

    ***************************************************************************/

    public KeyPair getGenesisKeyPair ()
    {
        return KeyPair.fromSeed(
            Seed.fromString(
                "SCT4KKJNYLTQO4TVDPVJQZEONTVVW66YLRWAINWI3FZDY7U4JS4JJEI4"));
    }

    // Check that the public key matches, temporarily
    unittest
    {
        assert(getGenesisKeyPair().address == UnitTestGenesisOutputAddress);
    }
}

/// The genesis block as defined by CoinNet
private immutable Block CoinNetGenesisBlock =
{
    header:
    {
        prev_block:  Hash.init,
        height:      0,
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
    Hash(`0xdb6e67f59fe0b30676037e4970705df8287f0de38298dcc09e50a8e85413959ca`
         ~ `4c52a9fa1edbe6a47cbb6b5e9b2a19b4d0877cc1f5955a7166fe6884eecd2c3`);

/// The single transaction that are part of the genesis block
private immutable Transaction CoinNetGenesisTransaction =
{
    TxType.Payment,
    inputs: [ Input.init ],
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
