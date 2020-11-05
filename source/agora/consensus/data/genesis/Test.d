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
                Hash(`0x23f35dcecc3c7ab1c91bfbd24c9568a63fdfe273bfc263ebaf81349c063c43a32b978fb5d058281f39c6c0a9b918a4a6b7c0f16b2e37f738ba0c2999a692afbf`),
                Hash(`0x0a8201f9f5096e1ce8e8de4147694940a57a188b78293a55144fc8777a774f2349b3a910fb1fb208514fb16deaf49eb05882cdb6796a81f913c6daac3eb74328`),
                20,
                Signature(`0x09acec80dfe1c10b8b936ad9169774e3c58362ea02fab0171f8c845c0fa23835dc8b89135fe3f5df9e2815b9bdb763c41b8b2dab5911e313acc82470c2147422`)),
            Enrollment(
                Hash(`0x376109201ce9be10edfe3d5f44255a2d0909587ef310efe9d52bfa95089b70766d979b8b31fbf6cc24dcf0150fc8cc05de1c7861bc63015c3bd65cef155b2000`),
                Hash(`0xa24b7e6843220d3454523ceb7f9b43f037e56a01d2bee82958b080dc6350ebac2da12b561cbd96c6fb3f5ae5a3c8df0ac2c559ae1c45b11d42fdf866558112bc`),
                20,
                Signature(`0x0e45db90c589997b5dbea336bd98d2fa41aeedb9de773b74a8550ca11ce0ab52fd787c4518b78ab9ed73a3760741d557ac2aca631fc2796be86fcf391d3a6634`)),
            Enrollment(
                Hash(`0x3a917147a39298356b4bc700c44957d8d766b33ccf68bd53b8ec22437d82ac33db409cf0b27c34baf6c9bd2a37d8d2e163eb61a071757819150298c78b51a330`),
                Hash(`0xa0502960ddbe816729f60aeaa480c7924fb020d864deec6a9db778b8e56dd2ff8e987be748ff6ca0a43597ecb575da5d532696e376dc70bb4567b5b1fa512cb4`),
                20,
                Signature(`0x0afcc65a1f66efec2f190494d948f5ff39b0283cd8ed354b85ca8bd880b48aa2d79a36ace4d3097869dc009b8939fc83bdf940c8822c6931d5c09326aa746b31`)),
            Enrollment(
                Hash(`0x80378d786d26ef24bb9f7fe3d8d0c642014652c13c77ee11c7b808c6e0df213b1b2da78bf07072b2dcdda9d1e02d95cdaa00e7f7b790014ccf0ea48e685aa3a1`),
                Hash(`0xd0348a88f9b7456228e4df5689a57438766f4774d760776ec450605c82348c461db84587c2c9b01c67c8ed17f297ee4008424ad3e0e5039179719d7e9df297c1`),
                20,
                Signature(`0x0ebf6f19cd0bcb369d3237061661573a2b6d975c2d32eda0863bd2622847348c2692d0b8b04133a34716169a4b1d33d77c3e585357d8a2a2c48a772275255c01`)),
            Enrollment(
                Hash(`0xb954b65741a81c8869903a44b6858c570daa2f1b550e13458f4df24c271668ddf11a52eec663b72dfbb354192d570eb9734277df6feddf53554ed1e7df81724b`),
                Hash(`0xaf43c67d9dd0f53de3eaede63cdcda8643422d62205df0b5af65706ec28b372adb785ce681d559d7a7137a4494ccbab4658ce11ec75a8ec84be5b73590bffceb`),
                20,
                Signature(`0x0481968fc244690c7973a0df68cf28f42ec35823d334eabc4cc29d01662860fb7e3d4753b6b4ccdb35c2864be4195e83b7b8433ca1d27a57fb9f48a631001304`)),
            Enrollment(
                Hash(`0xcb11dbc5864a63bc7cb6ea1ebc8485f80bae3e5cc95b8c1b6e6d3bdba73637a8f86089a92289e357c45e02ad73abecdd94e9986e8070b3bba5befed449855d50`),
                Hash(`0xdd1b9c62d4c62246ea124e5422d5a2e23d3ca9accb0eba0e46cd46708a4e7b417f46df34dc2e3cba9a57b1dc35a66dfc2d5ef239ebeaaa00299232bc7e3b7bfa`),
                20,
                Signature(`0x0723a0a7f353b76f8e95ee4122c413169f443936147ff14dfe18ee589726551f5c71e74382a24b7e644d32b0306fe3cf14ecd7de5635c70aa592f4721aa74fe2`))
        ]
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
    Hash(`0x8072b135e72dd84d59793d97839680f96300ec783bdc9786ee418a50eb40914f88a5de87e12df58d227bd454b08710a9b2fa9a84ee1f3bbc82bd00ac1f360c48`),
    Hash(`0xf806b1fcc4173e6c132def50f0d4f6fce90b7a3964520f42133e2f7e7389949128262d42351eec08da45428f83f1c2c0aa65798445661eda77b8fb2388766dc0`),
    Hash(`0x73585acc894828ca72d5a5d55cea406e665a7e8f768b14f1ce08c058a19ac52a87ab693f6cc8cd32fa98613c80c7a78411f5751c0670727c35022e33d1710131`)
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
