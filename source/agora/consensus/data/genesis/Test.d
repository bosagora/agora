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
                Hash(`0x1a1ae2be7afbe367e8e588474d93806b66b773c741b184dc5b4c59640e998644d2ebb0b866ac25dc053b06fd815a86d11c718f77c9e4d0fce1bdbb58486ee751`),
                Hash(`0xaf43c67d9dd0f53de3eaede63cdcda8643422d62205df0b5af65706ec28b372adb785ce681d559d7a7137a4494ccbab4658ce11ec75a8ec84be5b73590bffceb`),
                20,
                Signature(`0x02efb7bdfe591dc1e717cbdf4fe03d03d7df620b7fa345f212076274cf8d1ca07e3d4753b6b4ccdb35c2864be4195e83b7b8433ca1d27a57fb9f48a631001304`)),
            Enrollment(
                Hash(`0x25f5484830881b7e7d1247f8d607ead059344ade42abb56c68e63a4870303e165cbfd08078cca8e6be193848bc520c9538df4fadb8f551ea8db58792a17b8cf1`),
                Hash(`0xdd1b9c62d4c62246ea124e5422d5a2e23d3ca9accb0eba0e46cd46708a4e7b417f46df34dc2e3cba9a57b1dc35a66dfc2d5ef239ebeaaa00299232bc7e3b7bfa`),
                20,
                Signature(`0x0d51673d57b315aefcd062c4baaa3ba8d381a5138351985641d4fc6f3b9e2ec55c71e74382a24b7e644d32b0306fe3cf14ecd7de5635c70aa592f4721aa74fe2`)),
            Enrollment(
                Hash(`0x4fab6478e5283258dd749edcb303e48f4192f199d742e14b348711f4bbb116b197e63429c6fa608621681e625baf1b045a07ecf12f2e0b04c38bee449f5eacff`),
                Hash(`0xa0502960ddbe816729f60aeaa480c7924fb020d864deec6a9db778b8e56dd2ff8e987be748ff6ca0a43597ecb575da5d532696e376dc70bb4567b5b1fa512cb4`),
                20,
                Signature(`0x0f8f2876a05d3bbbc4359fdc6e83b7bf290f36e839d61687b714166f1b5a023ad79a36ace4d3097869dc009b8939fc83bdf940c8822c6931d5c09326aa746b31`)),
            Enrollment(
                Hash(`0xbf150033f0c3123f0b851c3a97b6cf5335b2bc2f4e9f0c2f3d44b863b10c261614d79f72c2ec0b1180c9135893c3575d4a1e1951a0ba24a1a25bfe8737db0aef`),
                Hash(`0x0a8201f9f5096e1ce8e8de4147694940a57a188b78293a55144fc8777a774f2349b3a910fb1fb208514fb16deaf49eb05882cdb6796a81f913c6daac3eb74328`),
                20,
                Signature(`0x06b347fc8dd258d3f9ccb70bfec4912a01c035bb5c07a2f0b54f7388b7472cdadc8b89135fe3f5df9e2815b9bdb763c41b8b2dab5911e313acc82470c2147422`)),
            Enrollment(
                Hash(`0xc0abcbff07879bfdb1495b8fdb9a9e5d2b07a689c7b9b3c583459082259be35687c125a1ddd6bd28b4fe8533ff794d3dba466b5f91117bbf557c3f1b6ff50e5f`),
                Hash(`0xd0348a88f9b7456228e4df5689a57438766f4774d760776ec450605c82348c461db84587c2c9b01c67c8ed17f297ee4008424ad3e0e5039179719d7e9df297c1`),
                20,
                Signature(`0x0e1707cd39104bdb5ccb86f4cc41df58ef4100cc561bf430bbbbaf285680c49d2692d0b8b04133a34716169a4b1d33d77c3e585357d8a2a2c48a772275255c01`)),
            Enrollment(
                Hash(`0xd827d6a201a4e7630dee1f19ed3670b6012610457c8c729a2077b4fcafcfcc7a48a640aac29ae79e25f80ca1cbf535b779eebb7609304041ec1f13ec21dcbc8d`),
                Hash(`0xa24b7e6843220d3454523ceb7f9b43f037e56a01d2bee82958b080dc6350ebac2da12b561cbd96c6fb3f5ae5a3c8df0ac2c559ae1c45b11d42fdf866558112bc`),
                20,
                Signature(`0x06bf56cf8a02b95d4f425c63efb0bdf4bbc54b00c83ae6cef400040f4a68b95ffd787c4518b78ab9ed73a3760741d557ac2aca631fc2796be86fcf391d3a6634`))
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
    Hash(`0x5208f03b3b95e90b3bff5e0daa1d657738839624d6605845d6e2ef3cf73d0d0ef5aff7d58bde1e00e1ccd5a502b26f569021324a4b902b7e66594e94f05e074c`),
    Hash(`0xb3aaf405f53560a6f6d5dd9dd83d7b031da480c0640a2897f2e2562c4670dfe84552d84daf5b1b7c63ce249d06bf54747cc5fdc98178a932fff99ab1372e873b`),
    Hash(`0xb12632add7615e2c4203f5ec5747c26e4fc7f333f95333ddfa4121a66b84499d35e5ce022ab667791549654b97a26e86054b0764ec23ee0cd3830de8f3f73364`)
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
