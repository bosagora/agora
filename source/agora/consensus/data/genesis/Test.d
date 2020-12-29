/*******************************************************************************

    Defines a genesis block suitable for testing purpose

    This genesis block is used in multiple places:
    - Most unittests;
    - Most network unittests (TODO);
    - The system unit tests;
    - The system integration tests;

    The keys in this module are well-known, and hence not suitable for anything
    that isn't a test.

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.genesis.Test;

import agora.common.Amount;
import agora.common.BitField;
import agora.common.Hash;
import agora.common.Types;
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.utils.Test;

/*******************************************************************************

    The genesis block as used by most tests

    Note that this is more of a 'test' block than a 'unittest' block,
    and it's currently used in a few integration test, hence why it is not
    `version (unittest)`.
    It can also be used for system integration testing.

    It contains a total of 500M initial coins, of which 12M have been frozen
    among 6 nodes, and the rest is evenly split between 8 outputs (61M each).

*******************************************************************************/

public immutable Block GenesisBlock = {
    header: {
        prev_block:  Hash.init,
        height:      Height(0),
        merkle_root: GenesisMerkleTree[$ - 1],
        timestamp:   1596153600, // 2020.07.31 12:00:00AM
        validators:  BitField!ubyte(6),
        signature:   Signature.init,

        enrollments: [
            // Node 4
            Enrollment(
                Hash(`0x46883e83778481d640a95fcffd6e1a1b6defeaac5a8001cd3f99e17576b809c` ~
                     `7e9bc7a44c3917806765a5ff997366e217ff54cd4da09c0c51dc339c47052a3ac`),
                Hash(`0x0a8201f9f5096e1ce8e8de4147694940a57a188b78293a55144fc8777a774f2` ~
                     `349b3a910fb1fb208514fb16deaf49eb05882cdb6796a81f913c6daac3eb74328`),
                20,
                Signature(`0x0cab27862571d2d2e33d6480e1eab4c82195a508b72672d609610d01f23b0be` ~
                          `edc8b89135fe3f5df9e2815b9bdb763c41b8b2dab5911e313acc82470c2147422`)
            ),

            // Node 7
            Enrollment(
                Hash(`0x4dde806d2e09367f9d5bdaaf46deab01a336a64fdb088dbb94edb171560c63cf` ~
                     `6a39377bf0c4d35118775681d989dee46531926299463256da303553f09be6ef`),
                Hash(`0xd0348a88f9b7456228e4df5689a57438766f4774d760776ec450605c82348c4` ~
                     `61db84587c2c9b01c67c8ed17f297ee4008424ad3e0e5039179719d7e9df297c1`),
                20,
                Signature(`0x0ed498b867c33d316b468d817ba8238aec68541abd912cecc499f8e780a8cda` ~
                          `f2692d0b8b04133a34716169a4b1d33d77c3e585357d8a2a2c48a772275255c01`)
            ),

            // Node 6
            Enrollment(
                Hash(`0x8c1561a4475df42afa0830da1f8a678ad4b1d82b6c610f7b03ce69b7e0fabcf` ~
                     `537d48ecd0aee6f1cab14290a0fc6313c729edf928ff3576f8656f3b7be5670e0`),
                Hash(`0xaf43c67d9dd0f53de3eaede63cdcda8643422d62205df0b5af65706ec28b372` ~
                     `adb785ce681d559d7a7137a4494ccbab4658ce11ec75a8ec84be5b73590bffceb`),
                20,
                Signature(`0x09474f489579c930dbac46f638f3202ac24407f1fa419c1d95be38ab474da29` ~
                          `d7e3d4753b6b4ccdb35c2864be4195e83b7b8433ca1d27a57fb9f48a631001304`)
            ),

            // Node 5
            Enrollment(
                Hash(`0x94908ec79866cf54bb8e87b605e31ce0b5d7c3090f3498237d83edaca9c8ba2` ~
                     `d3d180c572af46c1221fb81add163e14adf738df26e3679626e82113b9fe085b0`),
                Hash(`0xa24b7e6843220d3454523ceb7f9b43f037e56a01d2bee82958b080dc6350eba` ~
                     `c2da12b561cbd96c6fb3f5ae5a3c8df0ac2c559ae1c45b11d42fdf866558112bc`),
                20,
                Signature(`0x0e4566eca30feb9ad47a65e7ff7e7ce1a7555ccedcf61e1143c2e5fddbec686` ~
                          `6fd787c4518b78ab9ed73a3760741d557ac2aca631fc2796be86fcf391d3a6634`)
            ),

            // Node 2
            Enrollment(
                Hash(`0xb20da9cfbda971f3f573f55eabcd677feaf12f7948e8994a97cdf9e570799b7` ~
                     `1631e87bb9ebce0d6a402275adfb6e365fdb72139c18559a10df0e5fe4bae08eb`),
                Hash(`0xa0502960ddbe816729f60aeaa480c7924fb020d864deec6a9db778b8e56dd2f` ~
                     `f8e987be748ff6ca0a43597ecb575da5d532696e376dc70bb4567b5b1fa512cb4`),
                20,
                Signature(`0x052ee1d975c49f19fd26b077740dcac399f174f40b5df1aba5f09ebea11faac` ~
                          `fd79a36ace4d3097869dc009b8939fc83bdf940c8822c6931d5c09326aa746b31`)
            ),

            // Node 3
            Enrollment(
                Hash(`0xdb3931bd87d2cea097533d82be0a5e36c54fec8e5570790c3369bd8300c65a0` ~
                     `3d76d12a74aa38ec3e6866fd64ae56091ed3cbc3ca278ae0c8265ab699ffe2d85`),
                Hash(`0xdd1b9c62d4c62246ea124e5422d5a2e23d3ca9accb0eba0e46cd46708a4e7b4` ~
                     `17f46df34dc2e3cba9a57b1dc35a66dfc2d5ef239ebeaaa00299232bc7e3b7bfa`),
                20,
                Signature(`0x0e0070e5951ef5be897cb593c4c57ce28b7529463f7e5644b1314ab7cc69fd6` ~
                          `25c71e74382a24b7e644d32b0306fe3cf14ecd7de5635c70aa592f4721aa74fe2`)
            ),
        ],
    },
    merkle_tree: GenesisMerkleTree,
    txs: [
        {
            TxType.Freeze,
            outputs: [
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE2.address),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE3.address),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE4.address),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE5.address),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE6.address),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE7.address),
            ],
        },
        {
            TxType.Payment,
            outputs: [
                Output(Amount(61_000_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), GenesisOutputAddress),
            ],
        },
    ],
};

///
unittest
{
    import std.algorithm;
    import agora.consensus.PreImage;
    import agora.common.crypto.ECC;
    import agora.common.crypto.Schnorr;
    import agora.consensus.data.UTXO;

    version (none)
    {
        import std.stdio;
        import std.range;
        import agora.consensus.EnrollmentManager;

        const txs = GenesisBlock.txs;

        if (!txs.isStrictlyMonotonic())
        {
            writeln("WARN: Genesis block transactions are unsorted!");
            txs.enumerate.each!((idx, tx) => writefln("[%d]: %s", idx, tx));
        }

        Hash[] merkle_tree;
        writeln("Merkle root: ", Block.buildMerkleTree(txs, merkle_tree));
        writeln("\tMerkle tree: ", merkle_tree);

        const ValidatorCycle = 20;
        const txhash = txs[0].hashFull();
        Enrollment[] enrolls = txs[0].outputs.enumerate()
            .map!(tup => EnrollmentManager.makeEnrollment(
                      WK.Keys[tup.value.address],
                      UTXO.getHash(txhash, tup.index),
                      ValidatorCycle))
            .array();

        enrolls.sort!((a, b) => a.utxo_key < b.utxo_key);
        writeln("Enrollments: ", enrolls);
    }

    Amount amount;
    assert(GenesisBlock.txs.all!(tx => tx.getSumOutput(amount)));
    assert(amount == Amount.MaxUnitSupply, amount.toString());
    assert(GenesisBlock.merkle_tree.length == GenesisMerkleTree.length);
    assert(GenesisBlock.header.merkle_root == GenesisBlock.merkle_tree[$-1]);
}

private immutable Hash[] GenesisMerkleTree = [
    Hash(`0x6314ce9bc41a7f5b98309c3a3d824647d7613b714c4e3ddbc1c5e9ae46db297` ~
         `15c83127ce259a3851363bff36af2e1e9a51dfa15c36a77c9f8eba6826ff975bc`),
    Hash(`0x7a5bfeb96f9caefa377cb9a7ffe3ea3dd59ea84d4a1c66304ab8c307a4f4770` ~
         `6fe0aec2a73ce2b186a9f45641620995f8c7e4c157cee7940872d96d9b2f0f95c`),
    Hash(`0x788c159d62b565655d9f725786c38e6802038ee73d7a9d187b3be1c7de95aa0` ~
         `ba856bf81bb556d7448488e71f4b89ce6eba319d0536798308112416413289254`),
];

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
    testSymmetry(GenesisBlock.txs[0]);
    testSymmetry(GenesisBlock);
}
