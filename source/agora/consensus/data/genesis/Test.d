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
            Enrollment(
                Hash(`0x0f583ebe5bc15b0ca4b94fd547eb479106aba0786b20b24ba5375f766d79fc82f3dd8488ddffdb1960b5dcda3a1acd76daf9afe6ec004d1152b273ac7b1f5e33`),
                Hash(`0xad4a28584e901f18a884c0246e2b4a587379271ab76494290c00e9ac2876bc49131c9df1d3dd3ee92233b6bf6efd87bc9133be31f744b0d6c73b194caa6e9dcc`),
                20,
                Signature(`0x0dae2564b796b2dac77bc4d822261105bccb651122eec471d22887afc7352d394d8cddd2c9ff4a64051bb4fb46e746cfbb6c71b52c648eb192b02f060828eb15`)),
            Enrollment(
                Hash(`0x426f45d82f8db77c7dfbb804615d29073499ffdaa0ce8785a60a59f0755f3b517fb1ca73ecf0fdb7878754b07ec9e0086e0a6134e466558ef179f81b290a446e`),
                Hash(`0x645caa4a68fc4044698633be0ec7a84282c0600fce2c1e102c9fa66a1edc1e455d305acaa68e5d9f8f41fa90a3b28e5132bb306d135a5f63c029a45d24652908`),
                20,
                Signature(`0x0fa82e3998b206c31eae37bc04445a9a72d91e917d7a0e1b0b9225f4e63f29bb0bbb8436c86248d90d932933dbc72bbce97ba4411b6ecd932ffcb110f93fdaf6`)),
            Enrollment(
                Hash(`0x7dbc08c46e818ec06c8d398ece5e0899ea8503bbcf8cef8828d6d654c82817994784ed12d75d5373fc142060d884f86160519ec54f126687a57141504acd586a`),
                Hash(`0xf909c7fc9a39ff228662aeeaf6006ec31b7287da530ce7bee51b9177d0711da2adda703d648e53f249eae2b363ffcd0785b4ae6a08afab74253b0a75776a9f58`),
                20,
                Signature(`0x07fb41b5db244a371718360f50ba599ed17a8784f200b6f26e012ee384603944ebe1e962a73e176052d5b69f5203835fe7f4398e3d6bbf63f350c469c2139543`)),
            Enrollment(
                Hash(`0xa6af77746dcdade0fc4b1bcab59f4ca5676655ee1c4358e7473f761a988b45294157515127ca28900f14bac00aa86fd249ffbad56255babc4f154d481c0ffabd`),
                Hash(`0xc45f17c18d787c20b3263ba2cfa7e3a3b73c610541e386118c3fcc4bbbefb1211efad324270acc0aeccba0516e14a8384c579e22c5631527ddc4b358a97a5d44`),
                20,
                Signature(`0x067cb1c9f308d51534ec1be3fe2122381a985f08c20c02c551317b210931cacf7d2211a8f9a781b6a8a953abefa978d10d51376bc013c4b49735a6deb48670a6`)),
            Enrollment(
                Hash(`0xb4df2b7edbec816a12035806effbe2c2ace290d9016a0d36d44570c1578db6ae2afe8f44e869a426122c9a2ea74522057d3b0ab66ae4462338b691f4fd910f9e`),
                Hash(`0xf552010ddc44e29344fbebf24792667f64544ae88bc187cfa329dd9f5bf2059425b19308986cb592ffa239b7fd2775ccf3fa878657cfd9af116aa6c5be5a8554`),
                20,
                Signature(`0x089848e691e93f46cbf7e3a0b2122157bf92bc34105bb1008373b83093bf7e48729105ca1d6bf8611b1cd3e1b66645cbe2c1da1e09cf2bd085eae6e59a26be27`)),
            Enrollment(
                Hash(`0xedcd7464dcae48c52949b0a412a39144cafcf1f78134d3d7fae5a4724e4bb21402b39c80ee0c71d2b4b8b892485ca6f2e29a51a40da6cb048c82ab0adc6cb794`),
                Hash(`0x69d5c9613d40f32400221c0628cbcd068fe41346a98b321ab88c27dc0dd98ca5b87b5ccc794a4759694bf5c7dd7f437448bd16dfeaef806b5c66bfcc04174b6c`),
                20,
                Signature(`0x05ad140e40c456493e3d3c18487ce360099eb8c0ecdca0dce845ce5474f6d19da48fc9646fe41804fcd2b7c0f64c5674e4587af433afe4d733dc05c30c5b58a4`)),
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

version (unittest)
{
    import std.algorithm;

    static immutable testGenesisBlockFreezeTransaction = GenesisBlock.txs.filter!(tx => tx.type == TxType.Freeze).front;
    static immutable testGenesisBlockPaymentTransaction = GenesisBlock.txs.filter!(tx => tx.type == TxType.Payment).front;
}

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
    Hash(`0x03638cc6eeee41145406ecdfda16b18f1123311c64c0ed45d77e6439b7e9f62a180a968e55bc046292d6fc7424c44ae2434ceb208a7692a4e9b6b0905148189a`),
    Hash(`0xb86f585b293070f48b7580d417f21d78593875187f5bc1ee723ff761134e6e480c7f918de9544da13ef5864d51ee4faf0ee977530b414df1f602a458cee625b7`),
    Hash(`0x75867fb29a1a7ca458c0e1e1abc5b3ced90ad4ecd3f3ae747698ca4b35bad120c8f19cfde9685df83211af184946644ba7e8ba940c0a39e10e99d2f0b9c18222`)
];

unittest
{
    import std.conv;
    import std.algorithm.sorting : isSorted;

    assert(GenesisBlock.txs.isSorted(), "Block transaction must be sorted!");
    Hash[] merkle_tree;
    GenesisBlock.buildMerkleTree(GenesisBlock.txs, merkle_tree);
    assert(merkle_tree == GenesisMerkleTree, merkle_tree.to!string);
}

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
