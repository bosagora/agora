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
            Hash(`0xd83ee1b8609ddbed2dc7c8608704565e6a4122121aaf770d7cf75d74f8ec67d01730df8b9104c4424b959da15c1076fca90a4eff23153f246c71b13973733942`),
            1008,
            Signature(`0x0a209b5ab8c085bbf6a3c96c64ec7b8f06b59377231c28720f8b8fc10a98a61b7e3d4753b6b4ccdb35c2864be4195e83b7b8433ca1d27a57fb9f48a631001304`)),
        // GDNODE3EWQKF33TPK35DAQ3KXAYSOT4E4ACDOVJMDZQDVKP66IMJEACM
        Enrollment(
            Hash(`0x25f5484830881b7e7d1247f8d607ead059344ade42abb56c68e63a4870303e165cbfd08078cca8e6be193848bc520c9538df4fadb8f551ea8db58792a17b8cf1`),
            Hash(`0x23dc305988b8ff32232256192f2350fe8cde4f54c60ca266c444489b90817020d3c38148f877b8b16a80e46ce35e1a3e66a5309786282b816627961e1dcb088e`),
            1008,
            Signature(`0x08a5710c50eda8d4e2a66f5ed57899b2a12b94d74e4bcc5c3203e1459e32c68b5c71e74382a24b7e644d32b0306fe3cf14ecd7de5635c70aa592f4721aa74fe2`)),
        // GDNODE2IMTDH7SZHXWDS24EZCMYCEJMRZWB3S4HLRIUP6UNGKVVFLVHQ
        Enrollment(
            Hash(`0x4fab6478e5283258dd749edcb303e48f4192f199d742e14b348711f4bbb116b197e63429c6fa608621681e625baf1b045a07ecf12f2e0b04c38bee449f5eacff`),
            Hash(`0x52df29767ea498e78e50a6db1ec4095cead3b4d11a368d5c2c5859042764f97f1955cd3cc73190f97431e2736805a986f61d4be67bb9a82eab54c85bcfbe6cdb`),
            1008,
            Signature(`0x08eee45242ff1bc2dcb6d931483a3801e34bdf411b1cd063448394feb204ee1ad79a36ace4d3097869dc009b8939fc83bdf940c8822c6931d5c09326aa746b31`)),
        // GDNODE4KTE7VQUHVBLXIGD7VEFY57X4XV547P72D37SDG7UEO7MWOSNY
        Enrollment(
            Hash(`0xbf150033f0c3123f0b851c3a97b6cf5335b2bc2f4e9f0c2f3d44b863b10c261614d79f72c2ec0b1180c9135893c3575d4a1e1951a0ba24a1a25bfe8737db0aef`),
            Hash(`0xe5a721c94a3fc70abc6ea490164afc684de4395c7337fd2527529a9c62df19140e076f6107c03ac2680e3c2b29db29233c9add36db25aac2d7aec09baf029a38`),
            1008,
            Signature(`0x0c5ab0544ad30e09da6638b71861d93fe216118ecc51ac5114783e8f1e9b2478dc8b89135fe3f5df9e2815b9bdb763c41b8b2dab5911e313acc82470c2147422`)),
        // GDNODE7J5EUK7T6HLEO2FDUBWZEXVXHJO7C4AF5VZAKZENGQ4WR3IX2U
        Enrollment(
            Hash(`0xc0abcbff07879bfdb1495b8fdb9a9e5d2b07a689c7b9b3c583459082259be35687c125a1ddd6bd28b4fe8533ff794d3dba466b5f91117bbf557c3f1b6ff50e5f`),
            Hash(`0xd409b6b1d4f39baf8e7dd4d7bf01be89eebe6fd2f724ba5aa7ef7529f5423814142acee417e62e289b87c17bf4cb531f1bfe12cbeae3dd842af279e127bd2843`),
            1008,
            Signature(`0x051a1ff5eb286544718f8f46db081cdee166a420e4c73f874691fb25847b670a2692d0b8b04133a34716169a4b1d33d77c3e585357d8a2a2c48a772275255c01`)),
        // GDNODE5T7TWJ2S4UQSTM7KDHU2HQHCJUXFYLPZDDYGXIBUAH3U3PJQC2
        Enrollment(
            Hash(`0xd827d6a201a4e7630dee1f19ed3670b6012610457c8c729a2077b4fcafcfcc7a48a640aac29ae79e25f80ca1cbf535b779eebb7609304041ec1f13ec21dcbc8d`),
            Hash(`0x34fde2fb7140b7c65da081fafc5e883dabf22ab4a3db655a11ea934d664a7eb12e10dde55c27d6f127c83a53322d615e97ab3b4d2f64a1b150d586e8cd16acda`),
            1008,
            Signature(`0x0524440316ba294a156850bfea66f6390155a70fba18b851cc03309bd184c4c4fd787c4518b78ab9ed73a3760741d557ac2aca631fc2796be86fcf391d3a6634`)),
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
