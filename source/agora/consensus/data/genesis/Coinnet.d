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
import agora.common.BitField;
import agora.common.Types;
import agora.crypto.Schnorr: Signature;
import agora.crypto.ECC;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.utils.Test;

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
        time_offset: 0, // In subsequent blocks this will be the offset in seconds from Genesis time
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
        // boa1xzdmznw099p8e2h54pe8ed7599c99qez0f2m756ecmtamqtlq0vm73jg5mj
        Enrollment(
            Hash(`0x03b2c926071d92528f7401afb2144c1f9bfc4dbd60d116076f7dbbb4779556b628689e0c6bb8f12212a27b6ca93f8dfe8c6e951ef367302ee22dd0cb1e8b83ce`),
            Hash(`0x2e6c60eb300e240a25dcc0cef5a7d0488294b103c569754061547cfbf1455bfde84a3b445eb76c6dfe49282a404d34f02cf89b6a5076930ecea93fbfde54df96`),
            1008,
            Signature.fromString(`0xf45c14a6f9220b53128f1f08aa666ddefd125ccf2512015937a2b97248f25ce90ee306cc3ee1a422155b8ae29c92113ba66a533530558be867f86a82d5f71e7a`)),
        // boa1xzd6zuhueq5nyd0m4c4qm66az5dyq8r29hrynd3phezh50gf5c7u54eqtdh
        Enrollment(
            Hash(`0x6e05cf3391eceafec28bb35beaf30d17bc2e5df1a13c9326c9ea565a304e8cf5439e6f972b3e7ac82a3ac19e17586898d9c9d84327d437af6e838636f2ee4e78`),
            Hash(`0x07decf74191a485b86533f7bcaf34456288c27a9ea589d32b1407c5bcfc0fdeb312ec86f021597611aad7f988b99279d10cfb7d536b516b2f7f8d5bac7b36971`),
            1008,
            Signature.fromString(`0x6633727a9a0b55b2dafbdd951682b089b2b45b9644d09522370c6f1c4e2c9b2f03e1d337008a2870cb8a1bf63542539f3610af2aef502f4596b15ad20624ff47`)),
        // boa1xzd7zmk7rnun06psp9d0r0p0lj2m6zfz63w55pguzlem7nkv274e6hn2hg3
        Enrollment(
            Hash(`0x9544c71cece09f1a585f730c0df3d0ee8ad5cbbfa0bdc9d9d294f92e2972b746f97c3b97611f693491b7dc1ddccee0081b4663876cd02e494edc5409f40818ac`),
            Hash(`0x7709cc2b7b1b6228fa0554417bfc33341f9e6a160b20da255b24b8d2bc199a277eecb2e717652acce1dd9c45a2f32789f5a9d548c5209e4e7eb84df191c77647`),
            1008,
            Signature.fromString(`0xbcab099143e5161f6a7861601a7dd3f834d6a6ff9dab1e48ac05d02c8c993c0e0e4db77439a1a08dc1c56abce1b71e4c9e6a0a20091c5168d5ebd2bfa293189c`)),
        // boa1xzduznmm7kp7gg20azr8k9c9pzdwapx6culll96s8dqah5kj5cjsj0le8rk
        Enrollment(
            Hash(`0x980a42069faaa81a090c5e0ba8d9264f126c569542ac83da159a06078e432f23a2a9bcd366f8b850fbb464cc1e2b636b0fae4ec71484ef1102c543e24c88fc77`),
            Hash(`0x4aae1b6921cd6ba2ea3389008ce329436f7ed455fbd731b7084183d8dcb584334ddbc2edc9e2f781bf3a5613a24cf816493e7610812587b2040909ed41ef1af1`),
            1008,
            Signature.fromString(`0x907ef65138cae7cad57d9c6804700188f66f69cfb7c4b283e4cf380a8067a23f0443dd1c84906959c97797944c7802cc3670e14d32266c617698fd71200dcce9`)),
        // boa1xzdlzl5znnssm3dlslqgrayrl4frdmh0s7dyqwgvkdqaqkf5994aw53cn58
        Enrollment(
            Hash(`0xe7596f3e910432fdeb5c9168cde5f1ba3a0ff5ca8cd8a5e89eab39775d89b2ab106887615aecdb9f6ccc9691ef7bc893f08d28e053ba8de26cbf61d88a26112e`),
            Hash(`0x437706c76be50fda4dc65e3d914f0fb6f550a685e4701b124f15338f969ef1909f6ad9475e89417324a612f248a893c9cb309bf33c7d9629fae69ec09624e51a`),
            1008,
            Signature.fromString(`0xcc1d153578be5cd72e52d51a5b71f4802d574da2be4f015764aae44f39180f9a0372280688caa4a929e4c71174a7153162d834289ba52db88e830ebf1f15eabf`)),
        // boa1xzdaz4hx35kmp7zfd854yf98hx6ksdv3ps363dunvfl6l39m4v63qmyccsm
        Enrollment(
            Hash(`0xee93cf1aeed5015e453897263560fed541492963b82d73261750a92fcb120823b9af7f95ea5f85b19a03c48e7cb23035f36637487f457060fabee1720d030771`),
            Hash(`0x07d842b1d0ae9ccc697418c1aab67c2de12466bcf38c580365470360a3cfd770c6929c509b5ed6d5b8431246cc47775e122a7252723c8d726a2e0dff01e174fa`),
            1008,
            Signature.fromString(`0x39fc8b1202724ee3d09e2815199ae6a1424f8d84a0987760e87eca04951de58b061c9b60d3353c95eb134e9099167a7979b460d09f5e2a9091c69f5a8b6f4700`)),
    ];

///
private immutable Hash GenesisMerkleRoot = GenesisMerkleTree[$ - 1];

///
private immutable Transaction[] GenesisTransactions =
    [
        Transaction(
            TxType.Payment,
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
        Transaction(
            TxType.Freeze,
            [
                Output(Amount(2_000_000L * 10_000_000L), NODE2_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE3_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE4_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE5_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE6_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE7_ADDRESS),
            ])
    ];

private immutable Hash[] GenesisMerkleTree = [
    Hash(`0x184f8aad95102ccafe881916261f22f892ffa9f9e2524068cd417df58a7fcb6487ef3039efb323286a99e9b0f86a5ebee074cf1f6cbc2a172ef9f5cef1a78ebf`),
    Hash(`0xf9c6b41297791941f76b2415afbfbf863f139947ccbd36dd13ec71af206202852086342df1dc0f56003cb04c506854b0029849c67a0587936a459a99e0af5078`),
    Hash(`0xd3976f40312a29cce0d5dfeee3bc2e67c4caca8a7117eb5b0b02466770734c620f0358fd94c2eb6c920815bcf57f24f648adb0b6efc776860cc4af73b3fcefdc`),
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
