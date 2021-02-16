/*******************************************************************************

    Defines a genesis block suitable for testing purpose

    This genesis block is used in multiple places:
    - Unittests;
    - Network unittests (modules `agora.test`);
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
import agora.common.Types;
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.crypto.Hash;
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
            // GDNODE6ZXW2NNOOQIGN24MBEZRO5226LSMHGQA3MUAMYQSTJVR7XT6GH
            Enrollment(
                Hash(`0x1a1ae2be7afbe367e8e588474d93806b66b773c741b184dc5b4c59640e998644d2ebb0b866ac25dc053b06fd815a86d11c718f77c9e4d0fce1bdbb58486ee751`),
                Hash(`0x3712f9aa91099107b563ee54315f9d8e90159b3e75395b4545fd594b9b7e23b4c1dec672f4d2341bb9e961de35b5ce1ed3d2e063b7c1f59ee1679621b087a428`),
                20,
                Signature(`0x0d419a4c6d9afa1d6053990da9d0a94fc516422935576cea2eae21f9c00be5317e3d4753b6b4ccdb35c2864be4195e83b7b8433ca1d27a57fb9f48a631001304`)),

            /// GDNODE3EWQKF33TPK35DAQ3KXAYSOT4E4ACDOVJMDZQDVKP66IMJEACM
            Enrollment(
                Hash(`0x25f5484830881b7e7d1247f8d607ead059344ade42abb56c68e63a4870303e165cbfd08078cca8e6be193848bc520c9538df4fadb8f551ea8db58792a17b8cf1`),
                Hash(`0xa9123912972492f84182402a104f1f248e1aa1853ad365a2a65f4831d7567a8552c950c8d31bdf60d77a7dbfa70c88317cd0b797cd3e64fea3e4c3311e59a658`),
                20,
                Signature(`0x092d1e09e7aadd12eff90bc668bff1153e9ef8cb9fa85acfb752c3ef3d6b4b175c71e74382a24b7e644d32b0306fe3cf14ecd7de5635c70aa592f4721aa74fe2`)),

            // GDNODE2IMTDH7SZHXWDS24EZCMYCEJMRZWB3S4HLRIUP6UNGKVVFLVHQ
            Enrollment(
                Hash(`0x4fab6478e5283258dd749edcb303e48f4192f199d742e14b348711f4bbb116b197e63429c6fa608621681e625baf1b045a07ecf12f2e0b04c38bee449f5eacff`),
                Hash(`0xb4b9252dc29b16f9624d3d94fa5c3dc8c7b82e086327a89dfc08a32642ed62bbd7ec6edf040ab13b8719dab7ec7f67d9d4927cc2a9970107bfe397acfaceebb8`),
                20,
                Signature(`0x014106f116cb4fd537e0c47c02bc9149c4730670170ee059b20624dc15d7fca5d79a36ace4d3097869dc009b8939fc83bdf940c8822c6931d5c09326aa746b31`)),

            // GDNODE4KTE7VQUHVBLXIGD7VEFY57X4XV547P72D37SDG7UEO7MWOSNY
            Enrollment(
                Hash(`0xbf150033f0c3123f0b851c3a97b6cf5335b2bc2f4e9f0c2f3d44b863b10c261614d79f72c2ec0b1180c9135893c3575d4a1e1951a0ba24a1a25bfe8737db0aef`),
                Hash(`0x4e3900af87f47b5a2b73e0bf10d598a69e7f2d43211141fbb993e26d17cf1fd9e376db5d34039e03420da00bc5b8513af23943f533ac8dae2205d5cbfd1d727d`),
                20,
                Signature(`0x08c8d426a634a4980baa5bd16a28567f1e2c28655d753b6e0573f285d7a9eab1dc8b89135fe3f5df9e2815b9bdb763c41b8b2dab5911e313acc82470c2147422`)),

            // GDNODE7J5EUK7T6HLEO2FDUBWZEXVXHJO7C4AF5VZAKZENGQ4WR3IX2U
            Enrollment(
                Hash(`0xc0abcbff07879bfdb1495b8fdb9a9e5d2b07a689c7b9b3c583459082259be35687c125a1ddd6bd28b4fe8533ff794d3dba466b5f91117bbf557c3f1b6ff50e5f`),
                Hash(`0xa2c12a9fd9f4e2c5bb75dfdc90603d80c75a73d6d91624afa2ca47f4d8e710c79aa00a3da5a6b7391100b10ac256a7714c93fe8dcc933a98db3d0827510dcc13`),
                20,
                Signature(`0x05aba63cb2b7783e940fa41ac587fd20bf594d92f4a5567016761220c25304972692d0b8b04133a34716169a4b1d33d77c3e585357d8a2a2c48a772275255c01`)),

            // GDNODE5T7TWJ2S4UQSTM7KDHU2HQHCJUXFYLPZDDYGXIBUAH3U3PJQC2
            Enrollment(
                Hash(`0xd827d6a201a4e7630dee1f19ed3670b6012610457c8c729a2077b4fcafcfcc7a48a640aac29ae79e25f80ca1cbf535b779eebb7609304041ec1f13ec21dcbc8d`),
                Hash(`0x5ae7cd3f8b52ff6442cfa166d4c61bf6531b397d884859dc973a1b68e989f147bf19ac7ee2b86c559589a96b136322f65768cf1d880ee8beeb8076f12bdd2ee3`),
                20,
                Signature(`0x060b7fcf3922889bee23a603b10d81454a8b629ca12850dc60ef5cd69aa69721fd787c4518b78ab9ed73a3760741d557ac2aca631fc2796be86fcf391d3a6634`))
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
    import agora.common.Serializer;
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

///
unittest
{
    import std.algorithm;

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
