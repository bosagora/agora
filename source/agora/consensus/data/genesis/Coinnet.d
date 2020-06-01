/*******************************************************************************

    Defines the genesis block used by the live network (CoinNet)

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.genesis.Coinnet;

import agora.common.Amount;
import agora.common.Hash;
import agora.common.Types;
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;

/// The genesis block as defined by CoinNet
public immutable Block GenesisBlock =
{
    header:
    {
        prev_block:  Hash.init,
        height:      Height(0),
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
    Hash(`0x5d7f6a7a30f7ff591c8649f61eb8a35d034824ed5cd252c2c6f10cdbd223671`
         ~ `3dc369ef2a44b62ba113814a9d819a276ff61582874c9aee9c98efa2aa1f10d73`);

/// The single transaction that are part of the genesis block
private immutable Transaction GenesisTransaction =
{
    TxType.Payment,
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

unittest
{
    import agora.common.Serializer;
    testSymmetry(GenesisTransaction);
    testSymmetry(GenesisBlock);
}
