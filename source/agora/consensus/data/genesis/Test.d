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
        enrollments: [
            Enrollment(
                Hash(`0x46883e83778481d640a95fcffd6e1a1b6defeaac5a8001cd3f99e17576b809c` ~
                     `7e9bc7a44c3917806765a5ff997366e217ff54cd4da09c0c51dc339c47052a3ac`),
                Hash(`0x34404dca05b15527046f83f03da31a9684d03d2d0204d3cb5849d13fb3c989d` ~
                     `df4f2f04f388355e12f4ed2976e0966d5e02a6f7f1d735ca52e192abbb019c79c`),
                1008,
                Signature(`0x0c2fd79ec6deb83eb2baa4da7bdfe37595bb42a768dcd66abc62943023fa806` ~
                          `8dc8b89135fe3f5df9e2815b9bdb763c41b8b2dab5911e313acc82470c2147422`)
            ),

            Enrollment(
                Hash(`0x4dde806d2e09367f9d5bdaaf46deab01a336a64fdb088dbb94edb171560c63c` ~
                     `f6a39377bf0c4d35118775681d989dee46531926299463256da303553f09be6ef`),
                Hash(`0xd2324c1865135aaba469afa5381df223a4fce45ea1ecca1f6ba2633917aa242` ~
                     `7c3b425e3beccd6077cf8b377ed23c6420d120e2a863f9e31100d10d7fb700967`),
                1008,
                Signature(`0x0e5907fbe526e9d9f7310c5e3d4be7cd39c281d9f32f34cb5d2d522fa4bdc14` ~
                          `b2692d0b8b04133a34716169a4b1d33d77c3e585357d8a2a2c48a772275255c01`)
            ),

            Enrollment(
                Hash(`0x8c1561a4475df42afa0830da1f8a678ad4b1d82b6c610f7b03ce69b7e0fabcf` ~
                     `537d48ecd0aee6f1cab14290a0fc6313c729edf928ff3576f8656f3b7be5670e0`),
                Hash(`0x3372d562f2dd84848c06baadc24bbaa7163cbc516d0bab8c1c215779001ee8e` ~
                     `ad187699f88b2d2dc590a4f3053e9487dd60d2b33f3ef81399ad702626547a7ba`),
                1008,
                Signature(`0x00db1855a7a0dcff59e311e4a038f2e41235081881d0ce4da6e6c6f3d81909a` ~
                          `47e3d4753b6b4ccdb35c2864be4195e83b7b8433ca1d27a57fb9f48a631001304`)
            ),

            Enrollment(
                Hash(`0x94908ec79866cf54bb8e87b605e31ce0b5d7c3090f3498237d83edaca9c8ba2` ~
                     `d3d180c572af46c1221fb81add163e14adf738df26e3679626e82113b9fe085b0`),
                Hash(`0x8827a2c313ada26b42bac150aa7a87d0bab0a9472f244fcba60f465bb8a8595` ~
                     `4bac18b9469e3c0110fec871144df401f7dcb1dab59e1c1add5338098f43b5957`),
                1008,
                Signature(`0x0dad7f1ca61325d10c50a9feb95d034ea88954c9840ee15e23c206a5ea11d67` ~
                          `7fd787c4518b78ab9ed73a3760741d557ac2aca631fc2796be86fcf391d3a6634`)
            ),

            Enrollment(
                Hash(`0xb20da9cfbda971f3f573f55eabcd677feaf12f7948e8994a97cdf9e570799b7` ~
                     `1631e87bb9ebce0d6a402275adfb6e365fdb72139c18559a10df0e5fe4bae08eb`),
                Hash(`0xae5acc1a182469a8da33e25ebf18bba01f31b4599fe56e61acd4cd73849ada4` ~
                     `ed4bfda5eaac47ada6f2223aa4a149170c4c461a96651bd724ee848df4166a951`),
                1008,
                Signature(`0x09cb5c2f1493d207021226b28c190a8b049b5f5a72580464c06d65dd97ebca9` ~
                          `bd79a36ace4d3097869dc009b8939fc83bdf940c8822c6931d5c09326aa746b31`)
            ),

            Enrollment(
                Hash(`0xdb3931bd87d2cea097533d82be0a5e36c54fec8e5570790c3369bd8300c65a0` ~
                     `3d76d12a74aa38ec3e6866fd64ae56091ed3cbc3ca278ae0c8265ab699ffe2d85`),
                Hash(`0xedf7098f88b74d7f80c7bc782dea8c5002ca2dc51333002cc8b596eb0e23af5` ~
                     `e4611d59947fbeb13acab663483172d13993faf6239a5641fb5ca18b4e1764605`),
                1008,
                Signature(`0x018c71ee3eb2030ee6dc60a41bae6119f8d8de7055f63393979dc22b9ce7f5b` ~
                          `e5c71e74382a24b7e644d32b0306fe3cf14ecd7de5635c70aa592f4721aa74fe2`)
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
    import agora.consensus.data.UTXOSetValue;

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

        const ValidatorCycle = 1008;
        const txhash = txs[0].hashFull();
        Enrollment[] enrolls = txs[0].outputs.enumerate()
            .map!(tup => EnrollmentManager.makeEnrollment(
                      WK.Keys[tup.value.address],
                      UTXOSetValue.getHash(txhash, tup.index),
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

unittest
{
    import agora.common.Serializer;
    testSymmetry(GenesisBlock.txs[0]);
    testSymmetry(GenesisBlock);
}
