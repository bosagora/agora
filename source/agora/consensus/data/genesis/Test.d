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
                Hash(`0x0b3e25b86a1899d389d33f902f5927d5f5dcf4c9a685dc489fe92b313497bc8cf086e8b0a5043d4ce660952f0283f349c78f70837e09a94a60e155b0a0bc2300`),
                Hash(`0xa0502960ddbe816729f60aeaa480c7924fb020d864deec6a9db778b8e56dd2ff8e987be748ff6ca0a43597ecb575da5d532696e376dc70bb4567b5b1fa512cb4`),
                20,
                Signature(`0x0cffff758523ed6ee8f70840ef5cb55af99758eb44d94f5f1ebae21da7f12e96d79a36ace4d3097869dc009b8939fc83bdf940c8822c6931d5c09326aa746b31`)),
            Enrollment(
                Hash(`0x20079a453337c187521a88dcf6df4b3cc321a85759d3117ef4d2c7f671d796454b866606ef32df36ebbfacf3d9550e160159365223242454f8947747f5ad922b`),
                Hash(`0xd0348a88f9b7456228e4df5689a57438766f4774d760776ec450605c82348c461db84587c2c9b01c67c8ed17f297ee4008424ad3e0e5039179719d7e9df297c1`),
                20,
                Signature(`0x069624b0b10feaa09d2a26a5e4ec46d5b996fed33a043d1e42c6a12e692c5cc02692d0b8b04133a34716169a4b1d33d77c3e585357d8a2a2c48a772275255c01`)),
            Enrollment(
                Hash(`0x3f0be353f1ba93cc51e31effcf09054a3ca349c1a82456c6e4c274cd5394a07ba00092ac1bd5fc2230d80670d3364c6449863df797a0ce5c39ea553dd1bbb60b`),
                Hash(`0x0a8201f9f5096e1ce8e8de4147694940a57a188b78293a55144fc8777a774f2349b3a910fb1fb208514fb16deaf49eb05882cdb6796a81f913c6daac3eb74328`),
                20,
                Signature(`0x02a50d2b6c39b0f820a2c33747bf7f6e705a346978ef84fa52d2abd4d2cdfe83dc8b89135fe3f5df9e2815b9bdb763c41b8b2dab5911e313acc82470c2147422`)),
            Enrollment(
                Hash(`0x66385a5250cca6c3a2cd730b06567a83cb418c1f8c275850f865626ff41af38314490d0f41c903faff2559cccb5ffa3ae6415915d239c3444b7826cd8afa3e8a`),
                Hash(`0xdd1b9c62d4c62246ea124e5422d5a2e23d3ca9accb0eba0e46cd46708a4e7b417f46df34dc2e3cba9a57b1dc35a66dfc2d5ef239ebeaaa00299232bc7e3b7bfa`),
                20,
                Signature(`0x0d3c74d8b896506f4a855f6908b9a98d0807b0cca11be3a558f6f97f75a082105c71e74382a24b7e644d32b0306fe3cf14ecd7de5635c70aa592f4721aa74fe2`)),
            Enrollment(
                Hash(`0xbda223c93cc038c213bb4e539f9765b8769a712945bedec1f96601f231898b26b00a351eb3786f4911ba7af089bb9abe912a463ffd7af9030f22058fc036a287`),
                Hash(`0xaf43c67d9dd0f53de3eaede63cdcda8643422d62205df0b5af65706ec28b372adb785ce681d559d7a7137a4494ccbab4658ce11ec75a8ec84be5b73590bffceb`),
                20,
                Signature(`0x0a25b29b422d8f072fdbe144e6202481c00c2be59c5b8f62d98db6191d5c7ac77e3d4753b6b4ccdb35c2864be4195e83b7b8433ca1d27a57fb9f48a631001304`)),
            Enrollment(
                Hash(`0xe46e16cc5e6c3619aba0a20d2c9bc657ecff595c861567c7ffa3496211011c50909940642ec6c3ff0db9c54ea8e6daa4d3cfd7f7782c7f3f649f977f4b94b0fe`),
                Hash(`0xa24b7e6843220d3454523ceb7f9b43f037e56a01d2bee82958b080dc6350ebac2da12b561cbd96c6fb3f5ae5a3c8df0ac2c559ae1c45b11d42fdf866558112bc`),
                20,
                Signature(`0x0e73f1f4d98ce428a124fc6634ce46b9493225b9451de04d161da178ed0978fffd787c4518b78ab9ed73a3760741d557ac2aca631fc2796be86fcf391d3a6634`))
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
    Hash(`0x6e176dbb84020c05a75e553ad484809c52ad6270670de2c196d6762a052de69` ~
         `e1f447998b734df500e68590f7fc98f9a6831aa54f70e51b5d8378a6edc6f8c44`),
    Hash(`0x8f3d1816da37ea5de24371809d4e173ca4bff017c90e1412c33333b9a3e3a17` ~
         `4fd6946fb14f1cac015d62b85502934dd17ca53788fd1d73b22beb0b6ace61643`),
    Hash(`0x5a62a4e81157b8c9ea4987bf46c015e8c9e6493b2bfe95814fab9db0df23f0d` ~
         `afb38e55b1d593d99a8b5e677127a7182cf29fc5ccf78c1997097af809ca9cbaf`)
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
