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
import agora.common.BitField;
import agora.common.Types;
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.crypto.Hash;

/// The genesis block as defined by CoinNet
public immutable Block GenesisBlock =
{
    header:
    {
        prev_block:  Hash.init,
        height:      Height(0),
        merkle_root: GenesisMerkleRoot,
        enrollments: Enrollments,
        validators:  BitField!ubyte(6),
        signature:   Signature.init,
    },
    txs: GenesisTransactions,
    merkle_tree: GenesisMerkleTree,
};

///
unittest
{
    import agora.common.Serializer;
    import std.conv;
    import std.algorithm.sorting : isSorted;

    Block block = GenesisBlock.serializeFull.deserializeFull!Block;

    assert(GenesisBlock.header.prev_block == Hash.init);
    assert(GenesisBlock.header.height == 0);
    assert(GenesisBlock.txs.isSorted(), "Block transaction must be sorted!");
    assert(GenesisBlock.merkle_tree.length == 3);
    Hash[] merkle_tree;
    GenesisBlock.buildMerkleTree(GenesisBlock.txs, merkle_tree);
    assert(merkle_tree == GenesisMerkleTree, merkle_tree.to!string);
}

// TODO: Replace with the node's enrollments
/// The enrollments that are part of the genesis block
private immutable Enrollment[] Enrollments =
    [
        // GDNODE6ZXW2NNOOQIGN24MBEZRO5226LSMHGQA3MUAMYQSTJVR7XT6GH
        Enrollment(
            Hash(`0x1a1ae2be7afbe367e8e588474d93806b66b773c741b184dc5b4c59640e998644d2ebb0b866ac25dc053b06fd815a86d11c718f77c9e4d0fce1bdbb58486ee751`),
            Hash(`0x3712f9aa91099107b563ee54315f9d8e90159b3e75395b4545fd594b9b7e23b4c1dec672f4d2341bb9e961de35b5ce1ed3d2e063b7c1f59ee1679621b087a428`),
            1008,
            Signature(`0x086cead239cfb40245f54b3f8ae0da25e62f71697461c40e19c9869bb4531c507e3d4753b6b4ccdb35c2864be4195e83b7b8433ca1d27a57fb9f48a631001304`)),
        // GDNODE3EWQKF33TPK35DAQ3KXAYSOT4E4ACDOVJMDZQDVKP66IMJEACM
        Enrollment(
            Hash(`0x25f5484830881b7e7d1247f8d607ead059344ade42abb56c68e63a4870303e165cbfd08078cca8e6be193848bc520c9538df4fadb8f551ea8db58792a17b8cf1`),
            Hash(`0xa9123912972492f84182402a104f1f248e1aa1853ad365a2a65f4831d7567a8552c950c8d31bdf60d77a7dbfa70c88317cd0b797cd3e64fea3e4c3311e59a658`),
            1008,
            Signature(`0x00fb4ab0b651440553808844ed34697c574b4f438b2bf889348fbf46ca81c2275c71e74382a24b7e644d32b0306fe3cf14ecd7de5635c70aa592f4721aa74fe2`)),
        // GDNODE2IMTDH7SZHXWDS24EZCMYCEJMRZWB3S4HLRIUP6UNGKVVFLVHQ
        Enrollment(
            Hash(`0x4fab6478e5283258dd749edcb303e48f4192f199d742e14b348711f4bbb116b197e63429c6fa608621681e625baf1b045a07ecf12f2e0b04c38bee449f5eacff`),
            Hash(`0xb4b9252dc29b16f9624d3d94fa5c3dc8c7b82e086327a89dfc08a32642ed62bbd7ec6edf040ab13b8719dab7ec7f67d9d4927cc2a9970107bfe397acfaceebb8`),
            1008,
            Signature(`0x090613c2c1cd807fb881f01a92a335011678852dfa0545cb75a9dbee5df60869d79a36ace4d3097869dc009b8939fc83bdf940c8822c6931d5c09326aa746b31`)),
        // GDNODE4KTE7VQUHVBLXIGD7VEFY57X4XV547P72D37SDG7UEO7MWOSNY
        Enrollment(
            Hash(`0xbf150033f0c3123f0b851c3a97b6cf5335b2bc2f4e9f0c2f3d44b863b10c261614d79f72c2ec0b1180c9135893c3575d4a1e1951a0ba24a1a25bfe8737db0aef`),
            Hash(`0x4e3900af87f47b5a2b73e0bf10d598a69e7f2d43211141fbb993e26d17cf1fd9e376db5d34039e03420da00bc5b8513af23943f533ac8dae2205d5cbfd1d727d`),
            1008,
            Signature(`0x0798646eaf63b50f64a7b4bbc2ba5a444c19c533f8e2475ef50f7af8aed62f59dc8b89135fe3f5df9e2815b9bdb763c41b8b2dab5911e313acc82470c2147422`)),
        // GDNODE7J5EUK7T6HLEO2FDUBWZEXVXHJO7C4AF5VZAKZENGQ4WR3IX2U
        Enrollment(
            Hash(`0xc0abcbff07879bfdb1495b8fdb9a9e5d2b07a689c7b9b3c583459082259be35687c125a1ddd6bd28b4fe8533ff794d3dba466b5f91117bbf557c3f1b6ff50e5f`),
            Hash(`0xa2c12a9fd9f4e2c5bb75dfdc90603d80c75a73d6d91624afa2ca47f4d8e710c79aa00a3da5a6b7391100b10ac256a7714c93fe8dcc933a98db3d0827510dcc13`),
            1008,
            Signature(`0x01f859869ed713cc6f6db24f175e0c67a6c983f12635e96def9e5ed1263447ec2692d0b8b04133a34716169a4b1d33d77c3e585357d8a2a2c48a772275255c01`)),
        // GDNODE5T7TWJ2S4UQSTM7KDHU2HQHCJUXFYLPZDDYGXIBUAH3U3PJQC2
        Enrollment(
            Hash(`0xd827d6a201a4e7630dee1f19ed3670b6012610457c8c729a2077b4fcafcfcc7a48a640aac29ae79e25f80ca1cbf535b779eebb7609304041ec1f13ec21dcbc8d`),
            Hash(`0x5ae7cd3f8b52ff6442cfa166d4c61bf6531b397d884859dc973a1b68e989f147bf19ac7ee2b86c559589a96b136322f65768cf1d880ee8beeb8076f12bdd2ee3`),
            1008,
            Signature(`0x09aba5ab7f4dd7193001e7a45b86fd0ed7f4f3c53799a3c9d7054c6b75c76c9ffd787c4518b78ab9ed73a3760741d557ac2aca631fc2796be86fcf391d3a6634`)),
    ];

///
private immutable Hash GenesisMerkleRoot = GenesisMerkleTree[$ - 1];

///
private immutable Transaction[] GenesisTransactions =
    [
        {
            TxType.Payment,
            outputs: [
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
            ],
        },
        {
            TxType.Freeze,
            outputs: [
                Output(Amount(2_000_000L * 10_000_000L), NODE2_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE3_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE4_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE5_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE6_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE7_ADDRESS),
            ],
        },
    ];

private immutable Hash[] GenesisMerkleTree = [
    Hash(`0x0bacd1635faa87fd28df08f38b06be82c57493d00d8992e0d273b49c70770259d4e8b583737c0d9564d6748b25818d475f11e85dfe1262b8600fcc5230914c14`),
    Hash(`0x5208f03b3b95e90b3bff5e0daa1d657738839624d6605845d6e2ef3cf73d0d0ef5aff7d58bde1e00e1ccd5a502b26f569021324a4b902b7e66594e94f05e074c`),
    Hash(`0x0e2763d2657ceb688448e24f83e9f912f118a9af82103fc097edf4a2b99fd4cdfb151f2ee29f87cc1255412b73d32801b9740cfe5fc2243fff37e2ff8fec695c`),
];

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

/// GCOMMONBGUXXP4RFCYGEF74JDJVPUW2GUENGTKKJECDNO6AGO32CUWGU
public immutable PublicKey CommonsBudgetAddress = CommonsBudgetUbyte;

///
private immutable ubyte[] CommonsBudgetUbyte =
    [
        0x9c, 0xc6, 0x39, 0xa1, 0x35, 0x2f, 0x77, 0xf2,
        0x25, 0x16, 0x0c, 0x42, 0xff, 0x89, 0x1a, 0x6a,
        0xfa, 0x5b, 0x46, 0xa1, 0x1a, 0x69, 0xa9, 0x49,
        0x20, 0x86, 0xd7, 0x78, 0x06, 0x76, 0xf4, 0x2a,
    ];

unittest
{
    assert(CommonsBudgetAddress.toString()
           == `GCOMMONBGUXXP4RFCYGEF74JDJVPUW2GUENGTKKJECDNO6AGO32CUWGU`);
}

unittest
{
    import agora.common.Serializer;
    testSymmetry(GenesisTransactions);
    testSymmetry(GenesisBlock);
}

// TODO: Replace with the node's pubkey
/// NODE2: GDNODE2IMTDH7SZHXWDS24EZCMYCEJMRZWB3S4HLRIUP6UNGKVVFLVHQ
public immutable PublicKey NODE2_ADDRESS = PublicKey(
    [
        218, 225, 147, 72, 100, 198, 127, 203, 39, 189, 135, 45, 112, 153, 19, 48,
        34, 37, 145, 205, 131, 185, 112, 235, 138, 40, 255, 81, 166, 85, 106, 85,
    ]);

/// NODE3: GDNODE3EWQKF33TPK35DAQ3KXAYSOT4E4ACDOVJMDZQDVKP66IMJEACM
public immutable PublicKey NODE3_ADDRESS = PublicKey(
    [
        218, 225, 147, 100, 180, 20, 93, 238, 111, 86, 250, 48, 67, 106, 184, 49,
        39, 79, 132, 224, 4, 55, 85, 44, 30, 96, 58, 169, 254, 242, 24, 146
    ]);

/// NODE4: GDNODE4KTE7VQUHVBLXIGD7VEFY57X4XV547P72D37SDG7UEO7MWOSNY
public immutable PublicKey NODE4_ADDRESS = PublicKey(
    [
        218, 225, 147, 138, 153, 63, 88, 80, 245, 10, 238, 131, 15, 245, 33, 113,
        223, 223, 151, 175, 121, 247, 255, 67, 223, 228, 51, 126, 132, 119, 217, 103
    ]);

/// NODE5: GDNODE5T7TWJ2S4UQSTM7KDHU2HQHCJUXFYLPZDDYGXIBUAH3U3PJQC2
public immutable PublicKey NODE5_ADDRESS = PublicKey(
    [
        218, 225, 147, 179, 252, 236, 157, 75, 148, 132, 166, 207, 168, 103, 166,
        143, 3, 137, 52, 185, 112, 183, 228, 99, 193, 174, 128, 208, 7, 221, 54, 244
    ]);

/// NODE6: GDNODE6ZXW2NNOOQIGN24MBEZRO5226LSMHGQA3MUAMYQSTJVR7XT6GH
public immutable PublicKey NODE6_ADDRESS = PublicKey(
    [
        218, 225, 147, 217, 189, 180, 214, 185, 208, 65, 155, 174, 48, 36, 204,
        93, 221, 107, 203, 147, 14, 104, 3, 108, 160, 25, 136, 74, 105, 172, 127, 121
    ]);

/// NODE7: GDNODE7J5EUK7T6HLEO2FDUBWZEXVXHJO7C4AF5VZAKZENGQ4WR3IX2U
public immutable PublicKey NODE7_ADDRESS = PublicKey(
    [
        218, 225, 147, 233, 233, 40, 175, 207, 199, 89, 29, 162, 142, 129, 182, 73,
        122, 220, 233, 119, 197, 192, 23, 181, 200, 21, 146, 52, 208, 229, 163, 180
    ]);
