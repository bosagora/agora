/*******************************************************************************

    Defines the genesis block used by the live network (CoinNet)

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.genesis.Coinnet;

import agora.common.Amount;
import agora.common.BitMask;
import agora.common.Types;
import agora.crypto.Schnorr: Signature;
import agora.crypto.ECC;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.utils.Test;

/// The genesis block as defined by CoinNet (Chain ID: 1)
public immutable Block GenesisBlock =
{
    header:
    {
        prev_block:  Hash.init,
        height:      Height(0),
        merkle_root: GenesisMerkleRoot,
        enrollments: Enrollments,
        validators:  BitMask(0),    // Validators do not sign GenesisBlock
        signature:   Signature.init,
    },
    txs: GenesisTransactions,
    merkle_tree: GenesisMerkleTree,
};

///
unittest
{
    import agora.serialization.Serializer;

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
        // boa1xzd6zuhueq5nyd0m4c4qm66az5dyq8r29hrynd3phezh50gf5c7u54eqtdh
        Enrollment(
            Hash(`0x2523d6f448f611ae307c933548696343755014bdb843923d7c6542fa1999b1e136b1fd0dad19d949ead2b0d9864a27dc82b4c34ceed942ce289c3781ca1f4091`),
            Hash(`0xafcdb1c2dbbc89d9ad6aaf23b78af550109361782193737985caacdcb85b3c12924d73f8460a6397dde9033daf69f7db2310f50914b00a0c10b6119ed7bbfd55`),
            Signature.fromString(`0x7dab008be6ee0513cb327c1e551eebec9037c3c817877aa3e52bca12fafeda3c0e42cf9c6141f59306fd81c7c572b44f06a8844d868b8cb5f965cf157dd4d2b6`)),
        // boa1xzd7zmk7rnun06psp9d0r0p0lj2m6zfz63w55pguzlem7nkv274e6hn2hg3
        Enrollment(
            Hash(`0x60e4167b461a3cf8c9be32633e3a2455e1513279b8e3119d5f66acf10b8bc66583aa1dda8045880e47c0c526cda073f65f7d34c5f6f5dea76d06581869f2bd56`),
            Hash(`0x049c0b4fc68a3f152c1955339807acdc39b812a82775b20a9da93bb6e0b11b5fe4334c90335283558ffcf6ee8976b40834c0d73f6557a0f90f8c1d7a8e8cd578`),
            Signature.fromString(`0x9aa018e52819dfad24876578c922d5a388fe899a2d61cee98f54ae71bc7015740bd9d2de44b930ae9a5ddf5516095dcb3fc38309c098facf2f4998dd926325d2`)),
        // boa1xzduznmm7kp7gg20azr8k9c9pzdwapx6culll96s8dqah5kj5cjsj0le8rk
        Enrollment(
            Hash(`0x65bb39b1a60c75081eb1e7f1eb67ff1588b54c356d85d25b6afd932b9f6a3f84fd334a121adb578622ad387b127adbf88631e45f906a4ac276f65936c61d8134`),
            Hash(`0x5a84df6de5db32494206b88b0442c3bd7843a367ea556a6fde8dc74e701df155934c40e6f957814eb273fab2087095f150870e734f6384bd1db4ca879b41800a`),
            Signature.fromString(`0xb89f61b4b8d0995cc22b9937ff7ba4f55980d65a20bc83815fe0025e7e44948006237a6a85a6564b7de5b403c254a05abfeeef6d29001b57b51024f45f0f1e96`)),
        // boa1xzdaz4hx35kmp7zfd854yf98hx6ksdv3ps363dunvfl6l39m4v63qmyccsm
        Enrollment(
            Hash(`0x9218eebc90b48262f87445c38060438cc4885c3e93bc6f54e378efec2a3888622b0498c01c42ba6229cf5b8d3b044f869948214e3053b90ddfb2251e472ea634`),
            Hash(`0x96bf6d264cada2b6e1580cd11d9d141be991714c884b93d9bfdedc7f9053a034fba7f8e4acea86a009aaa21a5d49da3d07495952deedaa70cc11885a3ff56b4e`),
            Signature.fromString(`0x2c3a40f3588c33088baa414dea56d5915e26d1e42b47c6407201b4e67be8b6e0068d9c864adf609828431a5dbe189ceb08e5cf03c7df660594667a83ec17079d`)),
        // boa1xzdmznw099p8e2h54pe8ed7599c99qez0f2m756ecmtamqtlq0vm73jg5mj
        Enrollment(
            Hash(`0xb93e43e2b5c5a92c6f85b8dd562969882438a57de02486692169660e35c2bd4d5117ec2c663ab624b5c849e503ff0e7c452ce459bad683766bc4a6d4c245411f`),
            Hash(`0x262fdfdc6b195b6d297a5795d16f5621a0365aa4f39e2bbb8b5eed00567891bda48939c1600eadeb3fae33c8085bcaa4ffd8c6252323facb4bdd022057dec30f`),
            Signature.fromString(`0x9774b1d8a1f0e88b1f0f51cf247e3ffcf93cf3233e557312c8ab5ec61562f2dc05fbfdaeafb5514eb4d973ede3be7421da9fcc2d1fb0eeaecdd6face45dedba2`)),
        // boa1xzdlzl5znnssm3dlslqgrayrl4frdmh0s7dyqwgvkdqaqkf5994aw53cn58
        Enrollment(
            Hash(`0xec6d25eedfb0979d7a98992543122f6f7e18a584197bf0900d05d4b1aa81c3b179c93a5d1264d6cef16ecbeccbffaa40850db4ac3fbee987465bd1695e60c6be`),
            Hash(`0x17c7bef25aef31905717ad2d0b8004eb2cf93d561dd88f2db16f685d723825e8b3b2038b4e4df2160b889fdb7a4557161dbee111865efcd73d856a56e62eb1d7`),
            Signature.fromString(`0x946fe18cf5feafee6cc2f5f33084d8a9f67e28ab3894553cc0fcf7f815644c940f040e34d600a60ca0990d7a8771f86a19f0ce2fc3ab17be22c0c2447f14088e`)),
    ];

///
private immutable Hash GenesisMerkleRoot = GenesisMerkleTree[$ - 1];

///
private immutable Transaction[] GenesisTransactions =
    [
        Transaction(
            [
                Output(Amount(2_000_000L * 10_000_000L), NODE2_ADDRESS, OutputType.Freeze),
                Output(Amount(2_000_000L * 10_000_000L), NODE3_ADDRESS, OutputType.Freeze),
                Output(Amount(2_000_000L * 10_000_000L), NODE4_ADDRESS, OutputType.Freeze),
                Output(Amount(2_000_000L * 10_000_000L), NODE5_ADDRESS, OutputType.Freeze),
                Output(Amount(2_000_000L * 10_000_000L), NODE6_ADDRESS, OutputType.Freeze),
                Output(Amount(2_000_000L * 10_000_000L), NODE7_ADDRESS, OutputType.Freeze),
            ]),
        Transaction(
            [
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
            ]),
    ];

private immutable Hash[] GenesisMerkleTree = [
    Hash(`0x5b257765c764a9b3091f9b9ea482f759f69befb3386bf90c800f74e4deb89d1de5a2944f49291d2393a760220b0f1eeac35197dc294d901bd06700b39c059cd6`),
    Hash(`0xa4a350420df24381544a9fb1324be73aaa11a07d75341d7a6ab463dbb43a5b137334a0bbd60f7c0df0a1fecca400fedebe5ee669d4af240f152797afde725a8a`),
    Hash(`0xda4440ef3906bbc9865a91ecf61684a542f78713bfb5af7a4f48ea6537176b7a47c7524e65015b73e0d139f6f91050f763eccc07992e0bf9f02b5cf8cc681384`),
];

// TODO: Replace with the foundation's pubkey
/// GDGENYO6TWO6EZG2OXEBVDCNKLHCV2UFLLZY6TJMWTGR23UMJHVHLHKJ
private immutable PublicKey GenesisOutputAddress = GenesisAddressUbyte;

///
private immutable ubyte[] GenesisAddressUbyte = [
    204, 70, 225, 222, 157, 157, 226, 100,
    218, 117, 200, 26, 140, 77, 82, 206,
    42, 234, 133, 90, 243, 143, 77, 44,
    180, 205, 29, 110, 140, 73, 234, 117
    ];

unittest
{
    assert(GenesisOutputAddress.toString()
           == `boa1xrxydcw7nkw7yex6whyp4rzd2t8z4659ttec7nfvknx36m5vf8482hvnkxh`);
}


/// GCOMBBXA6ON7PT7APS4IWS4N53FCBQTLWBPIU4JR2DSOBCA72WEB4XU4
public immutable PublicKey CommonsBudgetAddress = CommonsBudgetUbyte;

///
private immutable ubyte[] CommonsBudgetUbyte = [
    156, 192, 134, 224, 243, 155, 247, 207,
    224, 124, 184, 139, 75, 141, 238, 202,
    32, 194, 107, 176, 94, 138, 113, 49,
    208, 228, 224, 136, 31, 213, 136, 30];

unittest
{
    assert(CommonsBudgetAddress.toString()
           == `boa1xzwvpphq7wdl0nlq0jugkjudam9zpsntkp0g5uf36rjwpzql6kypuddc9vr`);
}

unittest
{
    import agora.serialization.Serializer;
    testSymmetry(GenesisTransactions);
    testSymmetry(GenesisBlock);
}

// TODO: Replace with the node's pubkey
/// NODE2: GCN2C4X4ZAUTENP3VYVA3225CUNEAHDKFXDETNRBXZCXUPIJUY64UANT
public immutable PublicKey NODE2_ADDRESS =
    GCN2C4X4ZAUTENP3VYVA3225CUNEAHDKFXDETNRBXZCXUPIJUY64UANT.address;

/// NODE3: GCN3CTOPFFBHZKXUVBZHZN6UFFYFFAZCPJK36U2ZY3L53AL7APM36GYO
public immutable PublicKey NODE3_ADDRESS =
    GCN3CTOPFFBHZKXUVBZHZN6UFFYFFAZCPJK36U2ZY3L53AL7APM36GYO.address;

/// NODE4: GCN4CT336WB6IIKP5CDHWFYFBCNO5BG2Y4777F2QHNA5XUWSUYSQS7IP
public immutable PublicKey NODE4_ADDRESS =
    GCN4CT336WB6IIKP5CDHWFYFBCNO5BG2Y4777F2QHNA5XUWSUYSQS7IP.address;

/// NODE5: GCN5CVXGRUW3B6CJNHUVEJFHXG2WQNMRBQR2RN4TMJ727RF3VM2RA6LF
public immutable PublicKey NODE5_ADDRESS =
    GCN5CVXGRUW3B6CJNHUVEJFHXG2WQNMRBQR2RN4TMJ727RF3VM2RA6LF.address;

/// NODE6: GCN6C3W6DT4TP2BQBFNPDPBP7SK32CJC2ROUUBI4C7Z36TWMK6VZ3CT4
public immutable PublicKey NODE6_ADDRESS =
    GCN6C3W6DT4TP2BQBFNPDPBP7SK32CJC2ROUUBI4C7Z36TWMK6VZ3CT4.address;

/// NODE7: GCN7C7UCTTQQ3RN7Q7AID5ED7VJDN3XPQ6NEAOIMWNA5AWJUFFV5PRBN
public immutable PublicKey NODE7_ADDRESS =
    GCN7C7UCTTQQ3RN7Q7AID5ED7VJDN3XPQ6NEAOIMWNA5AWJUFFV5PRBN.address;

public immutable KeyPair[] genesis_validator_keys = [
    GCN2C4X4ZAUTENP3VYVA3225CUNEAHDKFXDETNRBXZCXUPIJUY64UANT,
    GCN3CTOPFFBHZKXUVBZHZN6UFFYFFAZCPJK36U2ZY3L53AL7APM36GYO,
    GCN4CT336WB6IIKP5CDHWFYFBCNO5BG2Y4777F2QHNA5XUWSUYSQS7IP,
    GCN5CVXGRUW3B6CJNHUVEJFHXG2WQNMRBQR2RN4TMJ727RF3VM2RA6LF,
    GCN6C3W6DT4TP2BQBFNPDPBP7SK32CJC2ROUUBI4C7Z36TWMK6VZ3CT4,
    GCN7C7UCTTQQ3RN7Q7AID5ED7VJDN3XPQ6NEAOIMWNA5AWJUFFV5PRBN
    ];

/// GCOMBBXA6ON7PT7APS4IWS4N53FCBQTLWBPIU4JR2DSOBCA72WEB4XU4:
private immutable GCOMBBXA6ON7PT7APS4IWS4N53FCBQTLWBPIU4JR2DSOBCA72WEB4XU4 =
KeyPair(PublicKey(Point([156, 192, 134, 224, 243, 155, 247, 207, 224, 124, 184, 139, 75, 141, 238, 202, 32, 194, 107,
176, 94, 138, 113, 49, 208, 228, 224, 136, 31, 213, 136, 30])),
SecretKey(Scalar([125, 41, 233, 11, 233, 133, 207, 35, 253, 6, 44, 244, 136, 201, 182, 68, 93, 37, 201, 206, 51, 71,
203, 166, 225, 229, 49, 209, 242, 161, 120, 4])));

/// GDGENYO6TWO6EZG2OXEBVDCNKLHCV2UFLLZY6TJMWTGR23UMJHVHLHKJ:
private immutable GDGENYO6TWO6EZG2OXEBVDCNKLHCV2UFLLZY6TJMWTGR23UMJHVHLHKJ =
KeyPair(PublicKey(Point([204, 70, 225, 222, 157, 157, 226, 100, 218, 117, 200, 26, 140, 77, 82, 206, 42, 234, 133, 90, 243, 143, 77, 44, 180, 205, 29, 110, 140, 73, 234, 117])), SecretKey(Scalar([115, 95, 118, 15, 205, 199, 178, 40, 246, 217, 128, 245, 129, 168, 223, 89, 93, 102, 200, 110, 191, 25, 248, 37, 136, 99, 204, 190, 173, 144, 19, 8])));

/// GCN2C4X4ZAUTENP3VYVA3225CUNEAHDKFXDETNRBXZCXUPIJUY64UANT:
private immutable GCN2C4X4ZAUTENP3VYVA3225CUNEAHDKFXDETNRBXZCXUPIJUY64UANT =
KeyPair(PublicKey(Point([155, 161, 114, 252, 200, 41, 50, 53, 251, 174, 42, 13, 235, 93, 21, 26, 64, 28, 106, 45, 198, 73, 182, 33, 190, 69, 122, 61, 9, 166, 61, 202])), SecretKey(Scalar([164, 206, 34, 110, 32, 193, 201, 0, 110, 132, 233, 30, 33, 37, 73, 99, 25, 205, 114, 100, 147, 33, 17, 118, 197, 178, 165, 234, 3, 222, 99, 15])));

/// GCN3CTOPFFBHZKXUVBZHZN6UFFYFFAZCPJK36U2ZY3L53AL7APM36GYO:
private immutable GCN3CTOPFFBHZKXUVBZHZN6UFFYFFAZCPJK36U2ZY3L53AL7APM36GYO =
KeyPair(PublicKey(Point([155, 177, 77, 207, 41, 66, 124, 170, 244, 168, 114, 124, 183, 212, 41, 112, 82, 131, 34, 122, 85, 191, 83, 89, 198, 215, 221, 129, 127, 3, 217, 191])), SecretKey(Scalar([169, 30, 41, 87, 161, 183, 48, 38, 254, 47, 170, 184, 38, 248, 244, 109, 116, 171, 53, 203, 46, 6, 214, 23, 182, 79, 80, 244, 198, 181, 133, 5])));

/// GCN4CT336WB6IIKP5CDHWFYFBCNO5BG2Y4777F2QHNA5XUWSUYSQS7IP:
private immutable GCN4CT336WB6IIKP5CDHWFYFBCNO5BG2Y4777F2QHNA5XUWSUYSQS7IP =
KeyPair(PublicKey(Point([155, 193, 79, 123, 245, 131, 228, 33, 79, 232, 134, 123, 23, 5, 8, 154, 238, 132, 218, 199, 63, 255, 151, 80, 59, 65, 219, 210, 210, 166, 37, 9])), SecretKey(Scalar([33, 32, 17, 253, 27, 191, 90, 211, 79, 31, 81, 156, 192, 164, 41, 228, 239, 254, 236, 222, 189, 120, 127, 8, 247, 2, 143, 10, 25, 156, 109, 8])));

/// GCN5CVXGRUW3B6CJNHUVEJFHXG2WQNMRBQR2RN4TMJ727RF3VM2RA6LF:
private immutable GCN5CVXGRUW3B6CJNHUVEJFHXG2WQNMRBQR2RN4TMJ727RF3VM2RA6LF =
KeyPair(PublicKey(Point([155, 209, 86, 230, 141, 45, 176, 248, 73, 105, 233, 82, 36, 167, 185, 181, 104, 53, 145, 12, 35, 168, 183, 147, 98, 127, 175, 196, 187, 171, 53, 16])), SecretKey(Scalar([10, 80, 62, 156, 147, 169, 145, 78, 190, 212, 103, 114, 243, 38, 80, 28, 14, 156, 42, 28, 69, 168, 242, 26, 138, 233, 201, 168, 166, 10, 193, 7])));

/// GCN6C3W6DT4TP2BQBFNPDPBP7SK32CJC2ROUUBI4C7Z36TWMK6VZ3CT4:
private immutable GCN6C3W6DT4TP2BQBFNPDPBP7SK32CJC2ROUUBI4C7Z36TWMK6VZ3CT4 =
KeyPair(PublicKey(Point([155, 225, 110, 222, 28, 249, 55, 232, 48, 9, 90, 241, 188, 47, 252, 149, 189, 9, 34, 212, 93, 74, 5, 28, 23, 243, 191, 78, 204, 87, 171, 157])), SecretKey(Scalar([244, 65, 235, 237, 149, 154, 211, 131, 202, 243, 249, 219, 234, 86, 109, 116, 197, 230, 106, 9, 242, 5, 66, 135, 12, 55, 14, 213, 211, 221, 215, 13])));

/// GCN7C7UCTTQQ3RN7Q7AID5ED7VJDN3XPQ6NEAOIMWNA5AWJUFFV5PRBN:
private immutable GCN7C7UCTTQQ3RN7Q7AID5ED7VJDN3XPQ6NEAOIMWNA5AWJUFFV5PRBN =
KeyPair(PublicKey(Point([155, 241, 126, 130, 156, 225, 13, 197, 191, 135, 192, 129, 244, 131, 253, 82, 54, 238, 239, 135, 154, 64, 57, 12, 179, 65, 208, 89, 52, 41, 107, 215])), SecretKey(Scalar([194, 151, 6, 120, 48, 80, 141, 208, 62, 69, 74, 41, 149, 21, 158, 137, 94, 152, 249, 49, 207, 36, 233, 95, 142, 62, 235, 174, 31, 96, 227, 2])));
