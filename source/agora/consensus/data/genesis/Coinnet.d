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
            Hash(`0x23f35dcecc3c7ab1c91bfbd24c9568a63fdfe273bfc263ebaf81349c063c43a32b978fb5d058281f39c6c0a9b918a4a6b7c0f16b2e37f738ba0c2999a692afbf`),
            Hash(`0xe5a721c94a3fc70abc6ea490164afc684de4395c7337fd2527529a9c62df19140e076f6107c03ac2680e3c2b29db29233c9add36db25aac2d7aec09baf029a38`),
            1008,
            Signature(`0x0d30ae9a86e6ef2dc671738739b6e7921d198586c2f9a7782251bf7826ffbab3dc8b89135fe3f5df9e2815b9bdb763c41b8b2dab5911e313acc82470c2147422`)
        ),
        Enrollment(
            Hash(`0x376109201ce9be10edfe3d5f44255a2d0909587ef310efe9d52bfa95089b70766d979b8b31fbf6cc24dcf0150fc8cc05de1c7861bc63015c3bd65cef155b2000`),
            Hash(`0x34fde2fb7140b7c65da081fafc5e883dabf22ab4a3db655a11ea934d664a7eb12e10dde55c27d6f127c83a53322d615e97ab3b4d2f64a1b150d586e8cd16acda`),
            1008,
            Signature(`0x02f59d65289a03a0f868d80455d67f564a24c077cdade49ed21850112cfb12bbfd787c4518b78ab9ed73a3760741d557ac2aca631fc2796be86fcf391d3a6634`)
        ),
        Enrollment(
            Hash(`0x3a917147a39298356b4bc700c44957d8d766b33ccf68bd53b8ec22437d82ac33db409cf0b27c34baf6c9bd2a37d8d2e163eb61a071757819150298c78b51a330`),
            Hash(`0x52df29767ea498e78e50a6db1ec4095cead3b4d11a368d5c2c5859042764f97f1955cd3cc73190f97431e2736805a986f61d4be67bb9a82eab54c85bcfbe6cdb`),
            1008,
            Signature(`0x0604250ac1cd93038a278d381c5ca252f74e235de36b04ee16c1435ff14d50c3d79a36ace4d3097869dc009b8939fc83bdf940c8822c6931d5c09326aa746b31`)
        ),
        Enrollment(
            Hash(`0x80378d786d26ef24bb9f7fe3d8d0c642014652c13c77ee11c7b808c6e0df213b1b2da78bf07072b2dcdda9d1e02d95cdaa00e7f7b790014ccf0ea48e685aa3a1`),
            Hash(`0xd409b6b1d4f39baf8e7dd4d7bf01be89eebe6fd2f724ba5aa7ef7529f5423814142acee417e62e289b87c17bf4cb531f1bfe12cbeae3dd842af279e127bd2843`),
            1008,
            Signature(`0x0a424904c92627958098dcb92c3a6916af0ebd99beff6cae035cdbf50ba58cbf2692d0b8b04133a34716169a4b1d33d77c3e585357d8a2a2c48a772275255c01`)
        ),
        Enrollment(
            Hash(`0xb954b65741a81c8869903a44b6858c570daa2f1b550e13458f4df24c271668ddf11a52eec663b72dfbb354192d570eb9734277df6feddf53554ed1e7df81724b`),
            Hash(`0xd83ee1b8609ddbed2dc7c8608704565e6a4122121aaf770d7cf75d74f8ec67d01730df8b9104c4424b959da15c1076fca90a4eff23153f246c71b13973733942`),
            1008,
            Signature(`0x0a3dad83de321b1066055528cc4119c2cf2e867cd5b82d19c135f74169429de37e3d4753b6b4ccdb35c2864be4195e83b7b8433ca1d27a57fb9f48a631001304`)
        ),
        Enrollment(
            Hash(`0xcb11dbc5864a63bc7cb6ea1ebc8485f80bae3e5cc95b8c1b6e6d3bdba73637a8f86089a92289e357c45e02ad73abecdd94e9986e8070b3bba5befed449855d50`),
            Hash(`0x23dc305988b8ff32232256192f2350fe8cde4f54c60ca266c444489b90817020d3c38148f877b8b16a80e46ce35e1a3e66a5309786282b816627961e1dcb088e`),
            1008,
            Signature(`0x0d7f4f062813286ad5787273ffe1c2b8b0ca1cadee7524f976755580734ef7c85c71e74382a24b7e644d32b0306fe3cf14ecd7de5635c70aa592f4721aa74fe2`)
        ),
    ];

///
private immutable Hash GenesisMerkleRoot =
    Hash(`0x103b220bb0818c5eb0e86a31244e6097f4e88931f3fce77e389c17722e76b81ca5725d8d0f4165c67d8dd04d7c477038129170044c41ed33b4c7d9e08f542d68`);

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
    Hash(`0x76a254d8c6df7e82e915b5b8a17e2bfa53477ae86b9334956080d377fa0c1ab781700d0d7a8938994c2718e228dd28e3597984aaf043733132bd89a2ad4f6a31`),
    Hash(`0x8072b135e72dd84d59793d97839680f96300ec783bdc9786ee418a50eb40914f88a5de87e12df58d227bd454b08710a9b2fa9a84ee1f3bbc82bd00ac1f360c48`),
    Hash(`0x103b220bb0818c5eb0e86a31244e6097f4e88931f3fce77e389c17722e76b81ca5725d8d0f4165c67d8dd04d7c477038129170044c41ed33b4c7d9e08f542d68`),
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
