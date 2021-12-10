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
import agora.common.BitMask;
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

    The genesis block as used by most tests (Chain ID: 0)

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
        validators:  BitMask(0),
        signature:   Signature.init,
        enrollments: [
        // boa1xrval5rzmma29zh4aqgv3mvcarhwa0w8rgthy3l9vaj3fywf9894ycmjkm8
        Enrollment(
            Hash(`0x0666c4d505b55b6840fbb669ec08a1849e699d5a30ba246989b65ea71292f8ac9a3d7126ca9061313d3225d6e324146f37cdc5dab51facbbc3beead6854e89a4`),
            Hash(`0x12f7fc1c953a13101e60c823ecd502fc9215a4dc7c1f3408db37ed70e62e45f9dda92c3b0592ad3fde04c4241bfe65e207704db9794e6fd92641f54a17747ab3`),
            Signature.fromString(`0x6d7a10ce4912b89806800cd66c6b58e66ccb78625afa865119c6d598aa061d18098e45596199261710d32c8c1b6565a1b2341cae9f773b6dca53dc26b7d49cf2`)),
        // boa1xzval3ah8z7ewhuzx6mywveyr79f24w49rdypwgurhjkr8z2ke2mycftv9n
        Enrollment(
            Hash(`0x2b1fcfb62b868a53287fbdfbc17631f5a4e1cfdb91e58dfc0a8ebf083e92994dd327b0b574c81f0e29394d3abbf67f609ad67bce49c9d9b59672fa5a61a37495`),
            Hash(`0x659467b85b216489e090d8b77e4de9fa67d4c0824ee27a798d302e3cac0f2e527abe04db5e84a87fadb101edb60342687fec3d094af2a4bfdd3f73b4176f00a0`),
            Signature.fromString(`0xa669a117712a49b470c2bfe885015a185c60fc158b8086a74f585804bf8962de0f076c77115f49a043035fd293318d8c9462f943db4d9a9b7c9bc9cccfd1254f`)),
        // boa1xrval7gwhjz4k9raqukcnv2n4rl4fxt74m2y9eay6l5mqdf4gntnzhhscrh
        Enrollment(
            Hash(`0x6bceb7f5997df362bd0808826ef9577d7f8389bf9c75a471362aa5a24f1d64c9074850f29c6c078e2a7fa8555ec81fde75c2c8b6a8c0adc8d75057bbcb51116a`),
            Hash(`0x3c4e8f32879e16a6d856f6360045ad263b7be2c22cfa55d6178dcf138955b92748a105cf9cc3f697b8b6dfc126ab81fb56a7349f57b9ddb443fbd880658b94f0`),
            Signature.fromString(`0x221c3179366b4f12cb2ac1a323c312a2c56d96854b9b1aa0a50eb348766b50f5080735f10ccaba022a8e6d540b679a5453d622bd398915c143b5cbb4195da1d7`)),
        // boa1xrval6hd8szdektyz69fnqjwqfejhu4rvrpwlahh9rhaazzpvs5g6lh34l5
        Enrollment(
            Hash(`0x84daa1d361afd9238041431b838500103eeb16d7952486077830a31a77ecc31d40f3a9d3f3a1c92dc3a0e5723ba6de9d87f107a73c73aef6a45bf9862c663493`),
            Hash(`0x2ef9c7042d38c6a212907ff065e355d0ce78cf315ba63c37dff58fbe4f484ccddaf03753918730a79a64927b2c1e4996296506abfeb484d8fe338311494cc3b3`),
            Signature.fromString(`0x8ff3e4f89919ce3f010223ffa03ea908c4963cddae7165fa9eaa53d071780d1a086bf1e2594e6745c597cbedd491fa3aa568e58faee89a31ec05bb8f5c1a1e28`)),
        // boa1xzval4nvru2ej9m0rptq7hatukkavemryvct4f8smyy3ky9ct5u0s8w6gfy
        Enrollment(
            Hash(`0x94b78736ae8ddf97f05a30e549f5eab377648a9116f3033ab7dcb8c9528ee717fd8d94dae7fe3ecc9d43290204ca2a41f710e798a3446b553c7a415d968e7177`),
            Hash(`0xbdb489da86fb8aeda9d09478b1936d9dc57b243eae9d31381270e533d48985a2a235e880c4b225e8a2f23aace36a6c5590ef47d5c3143b5115bc5137b6a200c2`),
            Signature.fromString(`0x7702482cdbed0ef9751cad41ca46b172edbd4c0db7fe8536ecb82e87aead31fa01fb58b031b139074ef97a17d7c746fe9261b194bad95a906648bee08234f199`)),
        // boa1xzval2a3cdxv28n6slr62wlczslk3juvk7cu05qt3z55ty2rlfqfc6egsh2
        Enrollment(
            Hash(`0xa3c2660bd4c65d6153bbe5bfac2cff06f68364c92e1f2619a4faede13943267df958efd9117c87125180241d678ff7278557fb8e83e486872a1eb8d83c41b4e1`),
            Hash(`0x5666c8993722e5ba725a60174fa2ec28c37ea0569e0366c612b278de7afa0e25c40d6e1a3f1e3c62fe67712df211f989f0f4cb3f0a2745d24e9f830c88c3d6c3`),
            Signature.fromString(`0x0c7110ea3fcc9fd683ad4b0edcd8956a8716830dee4c8755e773d10f611b32aa0e32d68f5c7961054356148e99c9abc978019fca71b1d4fc9685ecc6a9575fd1`)),
        ],
    },
    merkle_tree: GenesisMerkleTree,
    txs: [
        Transaction(
            [
                // If we want these in order NODE2, NODE3 .. NODE7
                // then we need to make sure the value of the Public key is in same order
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE2.address, OutputType.Freeze),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE3.address, OutputType.Freeze),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE4.address, OutputType.Freeze),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE5.address, OutputType.Freeze),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE6.address, OutputType.Freeze),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE7.address, OutputType.Freeze),
            ]),
        Transaction(
            [
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE8.address, OutputType.Freeze),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE9.address, OutputType.Freeze),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE10.address, OutputType.Freeze),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE11.address, OutputType.Freeze),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE12.address, OutputType.Freeze),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE13.address, OutputType.Freeze),
            ]),
        Transaction(
            [
                Output(Amount(59_500_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(59_500_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(59_500_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(59_500_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(59_500_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(59_500_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(59_500_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(59_500_000L * 10_000_000L), GenesisOutputAddress),
            ]),
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
    assert(GenesisBlock.merkle_tree.length == 7);
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
    assert(amount == Amount(500_000_000_0000000), amount.toString());
    assert(GenesisBlock.merkle_tree.length == GenesisMerkleTree.length);
    assert(GenesisBlock.header.merkle_root == GenesisBlock.merkle_tree[$-1]);
}

private immutable Hash[] GenesisMerkleTree = [
    Hash(`0xaf63ca7d0b555bbbe65d398165c3d921421114003ee6d42fe11a1b4eaafa6d6e9a57ffc6d35b820d001beeebdcdec9a9d6b7d34fe0062a6d9eb719d8d47237f2`),
    Hash(`0xbf5685b8bc230a0463d1b5c64a8dd3cab09de95cd6e71649a43af680569770b279646a8a5453bd157a6d2066850c27e941c662eb22c8ebae922989487bc53e58`),
    Hash(`0xf1b227276819be01f574bad7bcb26afddafbc14a3cb6052c5006e4b35c483e20864ba8388adcf8f9870cc2a028ec41dc563a91b8c09d13f95277e0b5bdad1ac3`),
    Hash(`0xf1b227276819be01f574bad7bcb26afddafbc14a3cb6052c5006e4b35c483e20864ba8388adcf8f9870cc2a028ec41dc563a91b8c09d13f95277e0b5bdad1ac3`),
    Hash(`0x0ab1d2f167db7529ce0663388e65e7f5435d575a08eda158ff8cda871aaefc8cc38bf2e84de39d41bbb7936ad3decf78ff7a9760dfd84f6712d09ca5f0f511cc`),
    Hash(`0x3fe30fe15a6355264d72224d6661ced1da44c57ea020a45a9cde6f3af9d85a82a88ee984100ea4b9dd426f6af43c4f4f7abb71c7a22a98a4c188328439dbfd72`),
    Hash(`0x0923b97e7a4dc9443089471545e796115ef5ad2eed8e92bb8b1de4744f94a95e297a536eb7c152752ca685af7602bc296f5590c2ddf0d91e4fe3dd24fb8e3f72`),
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
    WK.Keys.NODE5,
    WK.Keys.NODE3,
    WK.Keys.NODE7,
    WK.Keys.NODE6,
    WK.Keys.NODE4,
    WK.Keys.NODE2,
];
