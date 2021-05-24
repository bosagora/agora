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
        // boa1xzduznmm7kp7gg20azr8k9c9pzdwapx6culll96s8dqah5kj5cjsj0le8rk
        Enrollment(
            Hash(`0x022a3dddeb952e0131ad9eee0a2fa63d6c26ada285c165dfe58f83c54d182e5cb1fadea98f7fc8129b3cefe130a5b874d1dcf499bbaa5d995e9af627dbf1543e`),
            Hash(`0x4aae1b6921cd6ba2ea3389008ce329436f7ed455fbd731b7084183d8dcb584334ddbc2edc9e2f781bf3a5613a24cf816493e7610812587b2040909ed41ef1af1`),
            1008,
            Signature.fromString(`0x907ef65138cae7cad57d9c6804700188f66f69cfb7c4b283e4cf380a8067a23f01d75d9814e206c9775bea5667491217d085ca770ae624db55b310b15146ddc5`)),
        // boa1xzdaz4hx35kmp7zfd854yf98hx6ksdv3ps363dunvfl6l39m4v63qmyccsm
        Enrollment(
            Hash(`0x0fa6e90d3465fa7fbf5f5fffd5f112da738cb9cef1145288033773bda1f10bb45a0b2288460df4b296cadab522c52e903c78f4f238563f03e413c9fb68b720ae`),
            Hash(`0x07d842b1d0ae9ccc697418c1aab67c2de12466bcf38c580365470360a3cfd770c6929c509b5ed6d5b8431246cc47775e122a7252723c8d726a2e0dff01e174fa`),
            1008,
            Signature.fromString(`0x39fc8b1202724ee3d09e2815199ae6a1424f8d84a0987760e87eca04951de58b00463e86299f2e30e3107725170c7f25e64093133e68c07c508ac3794bd174a5`)),
        // boa1xzdmznw099p8e2h54pe8ed7599c99qez0f2m756ecmtamqtlq0vm73jg5mj
        Enrollment(
            Hash(`0x677d5cdaf19b22fb007f64a09e7429a42d887972c8358f72ef3a4345fe13696d70ae64de01c45ffeb20064848e5dbc14c547ba8061efca31dbf6f2f84f0bc140`),
            Hash(`0x2e6c60eb300e240a25dcc0cef5a7d0488294b103c569754061547cfbf1455bfde84a3b445eb76c6dfe49282a404d34f02cf89b6a5076930ecea93fbfde54df96`),
            1008,
            Signature.fromString(`0xf45c14a6f9220b53128f1f08aa666ddefd125ccf2512015937a2b97248f25ce90a05037c6debf71f75c6cb06c784e914fcdae790444f8654762f098bf069d681`)),
        // boa1xzdlzl5znnssm3dlslqgrayrl4frdmh0s7dyqwgvkdqaqkf5994aw53cn58
        Enrollment(
            Hash(`0xb8e563dda632881e63877560c450d998b2fdaed18efb194f0d80254585a9df016786e45b2b3e11bcb666b11675781ee09bdccf42f108d54c4aa79d1d3705400b`),
            Hash(`0x437706c76be50fda4dc65e3d914f0fb6f550a685e4701b124f15338f969ef1909f6ad9475e89417324a612f248a893c9cb309bf33c7d9629fae69ec09624e51a`),
            1008,
            Signature.fromString(`0xcc1d153578be5cd72e52d51a5b71f4802d574da2be4f015764aae44f39180f9a0ef5b9ee6e7e7e6129db566b481a794eb5c09ae217ffad062758eb559d84b38b`)),
        // boa1xzd6zuhueq5nyd0m4c4qm66az5dyq8r29hrynd3phezh50gf5c7u54eqtdh
        Enrollment(
            Hash(`0xe7cd127358a21abbda2a5a2c10ebfe55489c632ffa128aba1f422592b0d7ddca301ba9a244ccd9acec703ea2e0f9c8a8329aa1be462831e617159cc5b6cc371a`),
            Hash(`0x07decf74191a485b86533f7bcaf34456288c27a9ea589d32b1407c5bcfc0fdeb312ec86f021597611aad7f988b99279d10cfb7d536b516b2f7f8d5bac7b36971`),
            1008,
            Signature.fromString(`0x6633727a9a0b55b2dafbdd951682b089b2b45b9644d09522370c6f1c4e2c9b2f0937a6c0ba89d7965ec5121a577ab3e4953b0dace3b262a7c258b24b05346476`)),
        // boa1xzd7zmk7rnun06psp9d0r0p0lj2m6zfz63w55pguzlem7nkv274e6hn2hg3
        Enrollment(
            Hash(`0xeafcb33013b6d7fc82c51afc7b3557e9c1676619e3c31efa4ef47ee7819cf8e23a61a889d7f8faeef17d935a533eb779d9bf4647355cd5708dd0c162aa9185e5`),
            Hash(`0x7709cc2b7b1b6228fa0554417bfc33341f9e6a160b20da255b24b8d2bc199a277eecb2e717652acce1dd9c45a2f32789f5a9d548c5209e4e7eb84df191c77647`),
            1008,
            Signature.fromString(`0xbcab099143e5161f6a7861601a7dd3f834d6a6ff9dab1e48ac05d02c8c993c0e0b619d3cec3033be1318f98196277e48eabe3c0355374fc7d450fcca82c33d2c`)),
    ];

///
private immutable Hash GenesisMerkleRoot = GenesisMerkleTree[$ - 1];

///
private immutable Transaction[] GenesisTransactions =
    [
        Transaction(
            TxType.Freeze,
            [
                Output(Amount(2_000_000L * 10_000_000L), NODE2_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE3_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE4_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE5_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE6_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE7_ADDRESS),
            ]),
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
    ];

private immutable Hash[] GenesisMerkleTree = [
    Hash(`0x5b196ce5763be335c4e674b8ea104b74a63831d80326fdb1e048e19c7819dd170e8e3bd8aa683fcaeeb907d65be580fbcd2e1188682d1d9f61c51736ee735da6`),
    Hash(`0x8f926510c41d7f624c63a2eafbbdd498e7058634170aa380c61376a99776fbcaa2a5934d8172ec50851a8ffce44800f431f301c26fa48494e9a35b74eb285c01`),
    Hash(`0x53e35525191c7b3a70800167275e7222113844d95ebbb7aa02ff6af85b934d71e7d8144edf2970dede86d0efac9927652f753dc23731388ecf14a7d4b1ea9383`),
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
