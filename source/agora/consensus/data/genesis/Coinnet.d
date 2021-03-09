/*******************************************************************************

    Defines the genesis block used by the live network (CoinNet)

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.genesis.Coinnet;

import agora.common.Amount;
import agora.common.BitField;
import agora.common.Types;
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.crypto.Hash;

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
        // GDNODE5T7TWJ2S4UQSTM7KDHU2HQHCJUXFYLPZDDYGXIBUAH3U3PJQC2
        Enrollment(
            Hash(`0x343ed4d889685819205edd3ba3fdd8609a1d172289b2d19717f26e70875aa769f24a2f6ac50d3ebe1e17229f85a691ad5224937c960b34c458718f033a04c396`),
            Hash(`0xdb9a07a3df9d81cbf703bdd898028d3d997b2f182fe0948bb0b48061809bdfaa7370bdc8e07a7fe5906d6dea4ae81a65851c7beaf4869d96d46adc36000c9074`),
            1008,
            Signature(`0x08ed69c2203e12a95dbbecd43ee54f5559ae10194eb0c88f3dc6aa203bbf39295f34bd8102d5ba207997e965befd2ee3d160975e89a3e5b3ec8828cfd343d2fb`)),
        // GDNODE3EWQKF33TPK35DAQ3KXAYSOT4E4ACDOVJMDZQDVKP66IMJEACM
        Enrollment(
            Hash(`0x35b80b9acf91ea94fee620a581be90d611f3606fd358cba62eb1fe878e236e00ef0c631e480db5d84b8ceb67f7a7f7e45cfbd8204dea08a62694be6b3b69df61`),
            Hash(`0x2edd4f08ed5fe8a841e3ee009881a9d114af4c89f76f902fb71b5622b1e0d3416b205c84288c49a51753727e40ce288e833b60244a4e3bfb59a7cf599facea13`),
            1008,
            Signature(`0x08cf989f9c3486f783c421f9a47072bf360a95bc78a584cc1ec21abfa61a2d641218a86be4688ceb07beeb0b0075381c54dfe1f4308a91ae941d15cd7f41b569`)),
        // GDNODE7J5EUK7T6HLEO2FDUBWZEXVXHJO7C4AF5VZAKZENGQ4WR3IX2U
        Enrollment(
            Hash(`0x6575799330349ff754280131aed7642785d4af4e7eaba5106790f316ac01db7c9e361b08fbdee646a12e11fb4e15e72fc6a0e93989f9ac657dd0ecbff863f0b0`),
            Hash(`0x9599d08959bf2f14ca2195737d654a0a57df47cd3ee4eafcd18b2832cb00210d8535aea6453ee46b0a6e0b63e6b0b5378d0aef6f3dcc2920d4062f0fa0c3c9f4`),
            1008,
            Signature(`0x0b29557b0c3e5fc47f5646014d09b872b8040e75b8a91a89071144b473b689720bced1b26662120995ea8e6e653200046c11946ed5b04d4ab63896cfa68196a6`)),
        // GDNODE2IMTDH7SZHXWDS24EZCMYCEJMRZWB3S4HLRIUP6UNGKVVFLVHQ
        Enrollment(
            Hash(`0x87470103d62ace366a7af11790d5f13275398dc4ffea7c3d2772654df490fc287177ba374c1a5dd3092ffbde0c2cdb07b101900c2c4fe0686602966f82ac6dc8`),
            Hash(`0xafd83143f78bbf6b7587d017b98bf836f01b14a008967e7f1baa11adebe0038da7f5b63e95cad7638203ec176f871783c7a22aab80187d66692d16d4f49b3bb8`),
            1008,
            Signature(`0x07a2b7f735b19b95c9450a421071d75a034ef8164dda7fd00967ef38938494d83ca99ef16da721056ce99cb062ed11ce4fdb739df183b1a679a625df26333435`)),
        // GDNODE4KTE7VQUHVBLXIGD7VEFY57X4XV547P72D37SDG7UEO7MWOSNY
        Enrollment(
            Hash(`0xa66b50f7c6e5a1534194befd7927e5564ff541d5f0ee9d5716d64925b1f6fb63d87cb06d564c392b3224e6d56b41481cae6de85bfe503eed3f35036bb05e7b44`),
            Hash(`0x2ee32e16ff70f294b37f4bdc9fcb3b13eb877fbd12a47a3c59e4b9c240f14dcf7b117b1c9d26028c614c687ee24f40e263670410668cae1b022370eac4793886`),
            1008,
            Signature(`0x0b74f6b74117df82e8a1d476cbddb1dc1d65fdaa6bc96a3475e6adff8df850ee826c0c30281d6613fe5c7612935a5a38498b370b0d374a35b194ae45e37d27d7`)),
        // GDNODE6ZXW2NNOOQIGN24MBEZRO5226LSMHGQA3MUAMYQSTJVR7XT6GH
        Enrollment(
            Hash(`0xffab71132fd455674975d1fee62d2c06c8ec0e34f7592daade820fbd70035cf33a40dd2c65ef06e6709866178ab5b6dada1284bb13db957407fc014102a84be6`),
            Hash(`0x83d21697c4548dc5c1d7ceabb9621494ff0c2a61990e5ae7c467789643d95d6f53a8aa2dc51e74693f57e3633a079a3702e1ecae371a71018e732d39e9f64905`),
            1008,
            Signature(`0x00829cb2b109bbdee1c96e043fcc0af4e1e2cb7597a6d0735cedeadc8888af25ff95519ec859543215f0347cfe092b3043c7ba96174e12fe8915a7726840b016`)),
    ];

///
private immutable Hash GenesisMerkleRoot = GenesisMerkleTree[$ - 1];

///
private immutable Transaction[] GenesisTransactions =
    [
        {
            TxType.Payment,
            outputs: [
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(54_750_000L * 10_000_000L), GenesisOutputAddress),
            ],
        },
        {
            TxType.Freeze,
            outputs: [
                Output(Amount(2_000_000L * 10_000_000L), NODE2_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE3_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE4_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE5_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE6_ADDRESS),
                Output(Amount(2_000_000L * 10_000_000L), NODE7_ADDRESS),
            ],
        },
    ];

private immutable Hash[] GenesisMerkleTree = [
    Hash(`0x36a3675f7820dd96982e2f06873b8bc3098b9d0a0933e68ce769ea7d9eaa49cad8f33274940d3ea71e7cd13563c8ce1cfcd441e218b3165f6f18de4fed80f9c1`),
    Hash(`0x60c5d8c0783c8370344cb3d2f198586e98ca2b9f94a6c118148556582a972d6421521ffdeb4bb20b961140c0dabc4b1dc1a519f045d30bc2fbea6679c171a038`),
    Hash(`0xb3d49f612ad1ca3813aeafd55e6cf389deb4066906e8f8e6dfe26d6d9e5a09b7441b0533c2601e526edc6fc36e117e3adf83536f222d74f87f2fed6469e6d300`),
];

// TODO: Replace with the foundation's pubkey
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
    testSymmetry(GenesisTransactions);
    testSymmetry(GenesisBlock);
}

// TODO: Replace with the node's pubkey
/// NODE2: GDNODE2IMTDH7SZHXWDS24EZCMYCEJMRZWB3S4HLRIUP6UNGKVVFLVHQ
public immutable PublicKey NODE2_ADDRESS = PublicKey(
    [
        218, 225, 147, 72, 100, 198, 127, 203, 39, 189, 135, 45, 112, 153, 19, 48,
        34, 37, 145, 205, 131, 185, 112, 235, 138, 40, 255, 81, 166, 85, 106, 85,
    ]);

/// NODE3: GDNODE3EWQKF33TPK35DAQ3KXAYSOT4E4ACDOVJMDZQDVKP66IMJEACM
public immutable PublicKey NODE3_ADDRESS = PublicKey(
    [
        218, 225, 147, 100, 180, 20, 93, 238, 111, 86, 250, 48, 67, 106, 184, 49,
        39, 79, 132, 224, 4, 55, 85, 44, 30, 96, 58, 169, 254, 242, 24, 146
    ]);

/// NODE4: GDNODE4KTE7VQUHVBLXIGD7VEFY57X4XV547P72D37SDG7UEO7MWOSNY
public immutable PublicKey NODE4_ADDRESS = PublicKey(
    [
        218, 225, 147, 138, 153, 63, 88, 80, 245, 10, 238, 131, 15, 245, 33, 113,
        223, 223, 151, 175, 121, 247, 255, 67, 223, 228, 51, 126, 132, 119, 217, 103
    ]);

/// NODE5: GDNODE5T7TWJ2S4UQSTM7KDHU2HQHCJUXFYLPZDDYGXIBUAH3U3PJQC2
public immutable PublicKey NODE5_ADDRESS = PublicKey(
    [
        218, 225, 147, 179, 252, 236, 157, 75, 148, 132, 166, 207, 168, 103, 166,
        143, 3, 137, 52, 185, 112, 183, 228, 99, 193, 174, 128, 208, 7, 221, 54, 244
    ]);

/// NODE6: GDNODE6ZXW2NNOOQIGN24MBEZRO5226LSMHGQA3MUAMYQSTJVR7XT6GH
public immutable PublicKey NODE6_ADDRESS = PublicKey(
    [
        218, 225, 147, 217, 189, 180, 214, 185, 208, 65, 155, 174, 48, 36, 204,
        93, 221, 107, 203, 147, 14, 104, 3, 108, 160, 25, 136, 74, 105, 172, 127, 121
    ]);

/// NODE7: GDNODE7J5EUK7T6HLEO2FDUBWZEXVXHJO7C4AF5VZAKZENGQ4WR3IX2U
public immutable PublicKey NODE7_ADDRESS = PublicKey(
    [
        218, 225, 147, 233, 233, 40, 175, 207, 199, 89, 29, 162, 142, 129, 182, 73,
        122, 220, 233, 119, 197, 192, 23, 181, 200, 21, 146, 52, 208, 229, 163, 180
    ]);
