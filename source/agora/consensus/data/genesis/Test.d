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
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.genesis.Test;

import agora.common.Amount;
import agora.common.BitField;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr: Signature;
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
            // boa1xzval7zrjx7wn00tpcqyxpfyayf32je8apv3h2g5km0rgpljg49a7s6we9a
            Enrollment(
                Hash(`0x6345aba9fde44d84f25e8af8bdbff11c79022583faede4365a6166c73dd47ad6a9f438ff1194b3dc746ec5f852740d656a2037dc74a1490c5210e291a47ad908`),
                Hash(`0x06a2eeac81698aea05affba70c00a9e2622c7e325d54f576c671e8413dd5267645d4529d40351fbf7fa91d0c32c857ca1266e7cb36b102d5d9552337893a8159`),
                20,
                Signature.fromString(`0xb56a75da79b33302c86a5f045623bc07653b34e28ed2556d79a73ec0f18764710501a9950b416df776cf0fe2ba431e6b849e81e646dd268634db532b628fd28d`)),
            // boa1xzval4nvru2ej9m0rptq7hatukkavemryvct4f8smyy3ky9ct5u0s8w6gfy
            Enrollment(
                Hash(`0x7c8afc049c831996bf200ef2b2578bb2cc34db0ba43f99a9c801118ca03305dbd4f503f021e27ee134e24bd4d4d0f2a50d1d08ecbbcecca76fdd66ec554b7e86`),
                Hash(`0x672401404e947aaae126a9e8c150facf0fea6d7b607725f4ada6de369fdd54d8079c2555ed52f80e160f9c78b5f650372d01daa765924a5e50a0db530a58e510`),
                20,
                Signature.fromString(`0x07ffcebf03b8e7c2f14209f0999bfbd80f2704d69d1383434c9c0ff7f52ad22c0a8dc2be0be84ffafa1178aae82b9a8c8bcef1d1df8681214060e924f8dbd8ec`)),
            // boa1xzval5zfar2etl3xzkkyec5xvy03pxnhn9l4c0anl6pejep0xn9wwsrmnc4
            Enrollment(
                Hash(`0x80acad90666fd2718e154ab7da1f5a2288576769f32cc6d0a70275f9263fd6fb8ed72bff0a9a77514be9db6010831a85e38f3fbf1c9248ad2e8e03d15b12a4e6`),
                Hash(`0x80d87200cfc5777e715d10a2b8af4e4e45ba3739ae795929395175e5d48dba96c2e6cc91335969bc8268a5b708e551cb5c467bda86db226c1eca1c7bf3c9c666`),
                20,
                Signature.fromString(`0x638462eb1fc11f30625c3e4b40f4bfc475ae7744035ecff9233182d7bf8899db0c0d7051c3da572a0dfb3442922dde9b1b5ceb031bdf589a9800ca8972d892a1`)),
            // boa1xzval6zletrt49ls5r2mqylcljutfat6dtd5hwslp2gxas5kwvsw5ngea9p
            Enrollment(
                Hash(`0x9ce6dfe9e615c9dc8c013775b4e329b8886e613f4c1fa6cf278fa109ee66a8d6830bd77c87c3724ce7067969c28bdf4a390c43313d96b0b5a5084256d886552c`),
                Hash(`0xd2926f32ce6c21628b91bb986a22653ca96a94663a0c01392fc1eab39126a1948a67fd32c7f03be4c23cd5eafb1b57703121542b46bfeb1d4b03a6ee5bfbc999`),
                20,
                Signature.fromString(`0x152a0838e5d230ad84d572a9b5843a108f388c853548cbd231258e54976b4f7309b0e74d9b55335bd795ee962a65cb6f16ff264265c50f41c8ab3ba8182b6e35`)),
            // boa1xzval2a3cdxv28n6slr62wlczslk3juvk7cu05qt3z55ty2rlfqfc6egsh2
            Enrollment(
                Hash(`0xad38d124357fbd5d17c9d503530046138df2c2700b2131ce6d707f3c6ac90c87024a3073459d478161c9aec987959dcfbf48b56c809c539fc723575314f866fe`),
                Hash(`0x45a81942081ea00788a26187464fa79f6cefc3c09417167c64f638010ab40728d671c1725c6b30770e67a91688ab936a2bc1a402cf4cd2ffffa48f6c199f6332`),
                20,
                Signature.fromString(`0xe3f959407fe99cb23f352be4477bbef8f619a11283319192418ac869eeb204060343bb644ff1422b47a4f2adc6dc01a5aac5cab87ba5c98846cfc6ecbb3506ba`)),
            // boa1xzval3ah8z7ewhuzx6mywveyr79f24w49rdypwgurhjkr8z2ke2mycftv9n
            Enrollment(
                Hash(`0xde754f22af3c60aef503ecea158b768285bd1f69938920a37937c05f70847d9819b840b9900a115097c5111e3e1ce41e102f18779035d9c482668a17e66b02ad`),
                Hash(`0x072582e862efa9daf7a53a100989a07ad0ee0f0d5bfadf74909d6a6b3cf3c7a7e5d2e218f51df416d052b486e0d65608cbe70e51f0372fd211d68f353d299c0c`),
                20,
                Signature.fromString(`0x375eefbe1990a6e37b2f9a11b1ba68e3c8f8d0976f51a5de55e4d58a6798cd4f0058c7d460eeaa1f365806d60c602cd87628627f6f295934b2e00f796202e024`)),
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
    Hash(`0x0814c44d41983bc5fc2d11a15d32bcbaf9dad884a6f020d4945f5e44a07dd80c5ffc902b514274692f9b40a8e431389982f03214f79d3e94686a184520fbaba3`),
    Hash(`0xd4b2011f46b7de32e6a3f51eae35c97440b7adf427df7725d19575b8a9a8256552939656f8b5d4087b9bcbbe9219504e31f91a85fb1709683cbefc3962639ecd`),
    Hash(`0xdf5f08f6aa4aef4f89fe1361706987523dadebc5b2ac78cc23b5e91dd1016c0cd331f1d45bdb3281336ed4e3414bb4885f1c764a05aab079f692f90735123c68`)
];

/// GDGENES4KXH7RQJELTONR7HSVISVSQ5POSVBEWLR6EEIIL72H24IEDT4
private immutable PublicKey GenesisOutputAddress = WK.Keys.Genesis.address;

/// GDCOMMO272NFWHV5TQAIQFEDLQZLBMVVOJTHC3F567ZX4ZSRQQQWGLI3
public immutable PublicKey CommonsBudgetAddress = WK.Keys.CommonsBudget.address;

unittest
{
    import agora.serialization.Serializer;
    testSymmetry(GenesisBlock.txs[0]);
    testSymmetry(GenesisBlock.txs[1]);
    testSymmetry(GenesisBlock);
}

// These are the genesis validators ordered to match Genesis enrollments
public immutable KeyPair[] genesis_validator_keys = [
    WK.Keys.NODE7,
    WK.Keys.NODE4,
    WK.Keys.NODE5,
    WK.Keys.NODE6,
    WK.Keys.NODE2,
    WK.Keys.NODE3,
];
