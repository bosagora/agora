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
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;

/// The genesis block as defined by CoinNet
public immutable Block GenesisBlock =
{
    header:
    {
        prev_block:  Hash.init,
        height:      Height(0),
        merkle_root: GenesisMerkleRoot,
        enrollments: Enrollments,
    },
    txs: GenesisTransactions,
    merkle_tree: GenesisMerkleTree,
};

///
unittest
{
    import agora.common.Serializer;
    Block block = GenesisBlock.serializeFull.deserializeFull!Block;

    assert(GenesisBlock.header.prev_block == Hash.init);
    assert(GenesisBlock.header.height == 0);
    assert(GenesisBlock.header.merkle_root == GenesisBlock.merkle_tree[2]);
    assert(GenesisBlock.merkle_tree.length == 3);
    assert(GenesisBlock.header.merkle_root == block.buildMerkleTree());
}

// TODO: Replace with the node's enrollments
/// The enrollments that are part of the genesis block
private immutable Enrollment[] Enrollments =
    [
        Enrollment(
            Hash(`0x46883e83778481d640a95fcffd6e1a1b6defeaac5a8001cd3f99e17576b809c` ~
                    `7e9bc7a44c3917806765a5ff997366e217ff54cd4da09c0c51dc339c47052a3ac`),
            Hash(`0xe5a721c94a3fc70abc6ea490164afc684de4395c7337fd2527529a9c62df191` ~
                    `40e076f6107c03ac2680e3c2b29db29233c9add36db25aac2d7aec09baf029a38`),
            1008,
            Signature(`0x034c6cfbdece8eeca9e7ed8e5fce86150f29a0dce90bb5ff33857f5752266af` ~
                        `3dc8b89135fe3f5df9e2815b9bdb763c41b8b2dab5911e313acc82470c2147422`)
        ),
        Enrollment(
            Hash(`0x4dde806d2e09367f9d5bdaaf46deab01a336a64fdb088dbb94edb171560c63c` ~
                    `f6a39377bf0c4d35118775681d989dee46531926299463256da303553f09be6ef`),
            Hash(`0xd409b6b1d4f39baf8e7dd4d7bf01be89eebe6fd2f724ba5aa7ef7529f542381` ~
                    `4142acee417e62e289b87c17bf4cb531f1bfe12cbeae3dd842af279e127bd2843`),
            1008,
            Signature(`0x046affb4dbae903a47e75dac343e66e0fe1ee8c99a0f072e210458632316e6f` ~
                        `e2692d0b8b04133a34716169a4b1d33d77c3e585357d8a2a2c48a772275255c01`)
        ),
        Enrollment(
            Hash(`0x8c1561a4475df42afa0830da1f8a678ad4b1d82b6c610f7b03ce69b7e0fabcf` ~
                    `537d48ecd0aee6f1cab14290a0fc6313c729edf928ff3576f8656f3b7be5670e0`),
            Hash(`0xd83ee1b8609ddbed2dc7c8608704565e6a4122121aaf770d7cf75d74f8ec67d` ~
                    `01730df8b9104c4424b959da15c1076fca90a4eff23153f246c71b13973733942`),
            1008,
            Signature(`0x0b9b073c924ffbb26ca026939bbf19bf65769c1e375b9855ec5aadf1cb1e0d7` ~
                        `77e3d4753b6b4ccdb35c2864be4195e83b7b8433ca1d27a57fb9f48a631001304`)
        ),

        Enrollment(
            Hash(`0x94908ec79866cf54bb8e87b605e31ce0b5d7c3090f3498237d83edaca9c8ba2` ~
                    `d3d180c572af46c1221fb81add163e14adf738df26e3679626e82113b9fe085b0`),
            Hash(`0x34fde2fb7140b7c65da081fafc5e883dabf22ab4a3db655a11ea934d664a7eb` ~
                    `12e10dde55c27d6f127c83a53322d615e97ab3b4d2f64a1b150d586e8cd16acda`),
            1008,
            Signature(`0x03ac63d9fdeb0952db6676556e07ad14efcceb9f03711b73f697e774c552400` ~
                        `8fd787c4518b78ab9ed73a3760741d557ac2aca631fc2796be86fcf391d3a6634`)
        ),

        Enrollment(
            Hash(`0xb20da9cfbda971f3f573f55eabcd677feaf12f7948e8994a97cdf9e570799b7` ~
                    `1631e87bb9ebce0d6a402275adfb6e365fdb72139c18559a10df0e5fe4bae08eb`),
            Hash(`0x52df29767ea498e78e50a6db1ec4095cead3b4d11a368d5c2c5859042764f97` ~
                    `f1955cd3cc73190f97431e2736805a986f61d4be67bb9a82eab54c85bcfbe6cdb`),
            1008,
            Signature(`0x0b05b49b2a4776645f765288380e945b3e81ea883aec2d6c9815db70138f332` ~
                        `2d79a36ace4d3097869dc009b8939fc83bdf940c8822c6931d5c09326aa746b31`)
        ),

        Enrollment(
            Hash(`0xdb3931bd87d2cea097533d82be0a5e36c54fec8e5570790c3369bd8300c65a0` ~
                    `3d76d12a74aa38ec3e6866fd64ae56091ed3cbc3ca278ae0c8265ab699ffe2d85`),
            Hash(`0x23dc305988b8ff32232256192f2350fe8cde4f54c60ca266c444489b9081702` ~
                    `0d3c38148f877b8b16a80e46ce35e1a3e66a5309786282b816627961e1dcb088e`),
            1008,
            Signature(`0x0e251a27c71664bd6105b5f3817c5833971f13a57c02457fcc1c7f7cc937553` ~
                        `55c71e74382a24b7e644d32b0306fe3cf14ecd7de5635c70aa592f4721aa74fe2`)
        ),
    ];

///
private immutable Hash GenesisMerkleRoot =
    Hash(`0xbd90e9b69ef7937b575cd4ec7f368859e70304770db6e085fab80214f79a1316c`
         ~ `4aeb13817fb77c11d8408bc3a12270c503407762d757e633990613151a7d9b4`);

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
    Hash(`0x3ef5f5f24248ad836438251b72e878e52d232bf7da548b3613cf2867556dce3` ~
         `c0dc5639120ad617f74add4e77bc217a50f59071c72020eb4f222c20216bc9972`),
    Hash(`0x6314ce9bc41a7f5b98309c3a3d824647d7613b714c4e3ddbc1c5e9ae46db297` ~
         `15c83127ce259a3851363bff36af2e1e9a51dfa15c36a77c9f8eba6826ff975bc`),
    Hash(`0xbd90e9b69ef7937b575cd4ec7f368859e70304770db6e085fab80214f79a131` ~
         `6c4aeb13817fb77c11d8408bc3a12270c503407762d757e633990613151a7d9b4`),
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
