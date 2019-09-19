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
import agora.consensus.data.Block;
import agora.common.Data;
import agora.common.Hash;
import agora.common.crypto.Key;
import agora.consensus.data.Transaction;

/// The genesis block
public immutable Block GenesisBlock =
{
    header:
    {
        prev_block:  Hash.init,
        height:      0,
        merkle_root: GenesisMerkleRoot,
    },
    txs: [ GenesisTransaction ],
    merkle_tree: [ GenesisMerkleRoot ],
};

///
unittest
{
    assert(GenesisBlock.header.prev_block == Hash.init);
    assert(GenesisBlock.header.height == 0);
    assert(GenesisBlock.header.merkle_root == GenesisBlock.merkle_tree[0]);
    assert(GenesisBlock.merkle_tree.length == 1);
    assert(GenesisBlock.header.merkle_root == hashFull(GenesisTransaction));
}

///
private immutable Hash GenesisMerkleRoot =
    Hash(`0xdb6e67f59fe0b30676037e4970705df8287f0de38298dcc09e50a8e85413959ca`
         ~ `4c52a9fa1edbe6a47cbb6b5e9b2a19b4d0877cc1f5955a7166fe6884eecd2c3`);

/// The single transaction that are part of the genesis block
public immutable Transaction GenesisTransaction =
{
    TxType.Payment,
    inputs: [ Input.init ],
    outputs: [
        Output(Amount(62_500_000L * 10_000_000L), GenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), GenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), GenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), GenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), GenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), GenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), GenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), GenesisOutputAddress),
    ],
};

// TODO: Replace with the foundation's pubkey
/// GCOQEOHAUFYUAC6G22FJ3GZRNLGVCCLESEJ2AXBIJ5BJNUVTAERPLRIJ
private immutable PublicKey GenesisOutputAddress = GenesisAddressUbyte;

///
private immutable ubyte[] GenesisAddressUbyte =
    [
        0x9D, 0x02, 0x38, 0xE0, 0xA1, 0x71, 0x40, 0x0B,
        0xC6, 0xD6, 0x8A, 0x9D, 0x9B, 0x31, 0x6A, 0xCD,
        0x51, 0x09, 0x64, 0x91, 0x13, 0xA0, 0x5C, 0x28,
        0x4F, 0x42, 0x96, 0xD2, 0xB3, 0x01, 0x22, 0xF5,
    ];

unittest
{
    assert(GenesisOutputAddress.toString()
           == `GCOQEOHAUFYUAC6G22FJ3GZRNLGVCCLESEJ2AXBIJ5BJNUVTAERPLRIJ`);
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
        assert(getGenesisKeyPair().address == GenesisOutputAddress);
    }
}
