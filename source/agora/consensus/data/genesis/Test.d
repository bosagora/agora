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
        time_offset: 0, // In subsequent blocks this will be the offset in seconds from Genesis time
        validators:  BitField!ubyte(6),
        signature:   Signature.init,

        enrollments: [
            // GDNODE5T7TWJ2S4UQSTM7KDHU2HQHCJUXFYLPZDDYGXIBUAH3U3PJQC2
            Enrollment(
                Hash(`0x343ed4d889685819205edd3ba3fdd8609a1d172289b2d19717f26e70875aa769f24a2f6ac50d3ebe1e17229f85a691ad5224937c960b34c458718f033a04c396`),
                Hash(`0xfa8568d8d02174646a2517c251d6b6ac8d420adf4c23be43017ad96682fc75b770a664c12b59b8ea72aeb8982af693cfccb5399c4c06945e0a008ba04ef7e681`),
                20,
                Signature(`0x0038aaff8b34e836d0afe56573efcee7f7b8fc7c2b0e0eb63f03b6bf358020b95f34bd8102d5ba207997e965befd2ee3d160975e89a3e5b3ec8828cfd343d2fb`)),
            // GDNODE3EWQKF33TPK35DAQ3KXAYSOT4E4ACDOVJMDZQDVKP66IMJEACM
            Enrollment(
                Hash(`0x35b80b9acf91ea94fee620a581be90d611f3606fd358cba62eb1fe878e236e00ef0c631e480db5d84b8ceb67f7a7f7e45cfbd8204dea08a62694be6b3b69df61`),
                Hash(`0xebefd1d1963b5d13fac421a22b24e79614bff43cac44bb1547f6adfb627947e7e96e90d896c2a29c86e1dd32844c03515b7500b17d2330e3e483b3641757395b`),
                20,
                Signature(`0x08e50e97258059c53555d6c1bfed3c86dc5bec7d33a1be05f33a7f226c41ae2e1218a86be4688ceb07beeb0b0075381c54dfe1f4308a91ae941d15cd7f41b569`)),
            // GDNODE7J5EUK7T6HLEO2FDUBWZEXVXHJO7C4AF5VZAKZENGQ4WR3IX2U
            Enrollment(
                Hash(`0x6575799330349ff754280131aed7642785d4af4e7eaba5106790f316ac01db7c9e361b08fbdee646a12e11fb4e15e72fc6a0e93989f9ac657dd0ecbff863f0b0`),
                Hash(`0x4098fd7c004416598820eea2328e02c4635274ea3e1f752bd6e7b766a90e39b188e76d36845da20c39da8c811439a157eaafb4b905c24765cd515ddd7881eddc`),
                20,
                Signature(`0x0b3101b110ce6967979a2c6f186af79b87ce26061ef007d0099d56960d3e12c00bced1b26662120995ea8e6e653200046c11946ed5b04d4ab63896cfa68196a6`)),
            // GDNODE2IMTDH7SZHXWDS24EZCMYCEJMRZWB3S4HLRIUP6UNGKVVFLVHQ
            Enrollment(
                Hash(`0x87470103d62ace366a7af11790d5f13275398dc4ffea7c3d2772654df490fc287177ba374c1a5dd3092ffbde0c2cdb07b101900c2c4fe0686602966f82ac6dc8`),
                Hash(`0x64753bfb115131794ced4ebe52160d7e86e3d337b0ab1cd1fee6270ed2444f6b363e9baf4b57a34d26a22937429f7c54be838de8331853ab19c4cc71070c8814`),
                20,
                Signature(`0x0e88661618d282921cb28d5d0326d701711df3de30d04e98bfb3662b143d59b03ca99ef16da721056ce99cb062ed11ce4fdb739df183b1a679a625df26333435`)),
            // GDNODE4KTE7VQUHVBLXIGD7VEFY57X4XV547P72D37SDG7UEO7MWOSNY
            Enrollment(
                Hash(`0xa66b50f7c6e5a1534194befd7927e5564ff541d5f0ee9d5716d64925b1f6fb63d87cb06d564c392b3224e6d56b41481cae6de85bfe503eed3f35036bb05e7b44`),
                Hash(`0xb3d4363fd5cf265c5cd3f132cd3ddcef4c38a1532170e570bd9910713dbeb745c06f9ea67be89a8773b5b20303c97be965ce76daee770081da15accc8672a2cd`),
                20,
                Signature(`0x0be57eb8687e2c36d60fa013d707d58797a992724f258ef425815a07e79fa067826c0c30281d6613fe5c7612935a5a38498b370b0d374a35b194ae45e37d27d7`)),
            // GDNODE6ZXW2NNOOQIGN24MBEZRO5226LSMHGQA3MUAMYQSTJVR7XT6GH
            Enrollment(
                Hash(`0xffab71132fd455674975d1fee62d2c06c8ec0e34f7592daade820fbd70035cf33a40dd2c65ef06e6709866178ab5b6dada1284bb13db957407fc014102a84be6`),
                Hash(`0x91e80b2a2cc84014c0c58dbdb414ab5102bedb4a6c5525bb825452f8b4f4accf0d2cd21c1a233de9db9a61ec53bc5d31882a0b6ef3483294926a7aa73598f846`),
                20,
                Signature(`0x0b0d15ca0902727c6c4783502afc1ca838bc7c51d9f995a1cbc4861f8ba27844ff95519ec859543215f0347cfe092b3043c7ba96174e12fe8915a7726840b016`)),
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
    Hash(`0x60c5d8c0783c8370344cb3d2f198586e98ca2b9f94a6c118148556582a972d6421521ffdeb4bb20b961140c0dabc4b1dc1a519f045d30bc2fbea6679c171a038`),
    Hash(`0xb14a82e8b6a9dcbefc735533914c990a7ba2c53ac6896d37ee5b89bfaa9421ea4c2bf136cfce509d201828443e944353b762e3964a9a040d2e0e036712c4fd9e`),
    Hash(`0x390f0690b0a8c202e839d5056f2acf2b5658df7162b44968c61a6b72a033edf4f8a394f71aa81dfdc9989793f7aa820751cc5c09be4e37475d92467692f74e1d`)
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
    import agora.serialization.Serializer;
    testSymmetry(GenesisBlock.txs[0]);
    testSymmetry(GenesisBlock);
}
