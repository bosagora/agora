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
        validators:  BitMask(0),
        signature:   Signature.init,
        enrollments: [
            // boa1xrval7gwhjz4k9raqukcnv2n4rl4fxt74m2y9eay6l5mqdf4gntnzhhscrh
            Enrollment(
                Hash(`0x210f6551d648a4da654da116b100e941e434e4f232b8579439c2ef64b04819bd2782eb3524c7a29c38c347cdf26006bccac54a58a58f103ae7eb5b252eb53b64`),
                Hash(`0xcfc5b09bc53136c1691e0991ffae7f2657bba248da07fb153ddf08a5109ce1c7d38206bfab6da57d70c428286d65081db992fbade6c67b97c62e9cb2862433e1`),
                Signature.fromString(`0x018389f5876ebac77ad4c2269415bf8a5b14e2374e9d30a933f70a10abbca2a4035ec0640ba07ea8b39416e65ff66d373e25265ce78541b582ac34f2e625fb90`)),
            // boa1xzval2a3cdxv28n6slr62wlczslk3juvk7cu05qt3z55ty2rlfqfc6egsh2
            Enrollment(
                Hash(`0x3b44d65edb3361dd91441ab4f449eeda55644026624c4b8ae12ecf0264fa8a228dbf672ef97e2c4f87fb98ad7099e17b7f9ba7dbe8479672066912b1ea24ba77`),
                Hash(`0xff4e39063d315690608429a08b1b74c4a32c9f1529f1d9a3243ece4227765e98c564da4f8b083494c1b542ffb375b0dfa600be83653a5854d274602533a6d698`),
                Signature.fromString(`0xe3f959407fe99cb23f352be4477bbef8f619a11283319192418ac869eeb204060facc7e99186a09d9d6aa951d548e6ab228196f96ec104ae2f94741efa760344`)),
            // boa1xzval3ah8z7ewhuzx6mywveyr79f24w49rdypwgurhjkr8z2ke2mycftv9n
            Enrollment(
                Hash(`0x7bacc99e9bf827f0fa6dc6a77303d2e6ba6f1591277b896a9305a9e200853986fe9527fd551077a4ac2b511633ada4190a7b82cddaf606171336e1efba87ea8f`),
                Hash(`0xfb40764acd8b0d7a8307278fb4ba9805a1b652c004f8f1dbcf0b1d019632458793b82e662687e041691660ac231223b732ed5339e2793c48233ccb04444806ea`),
                Signature.fromString(`0x375eefbe1990a6e37b2f9a11b1ba68e3c8f8d0976f51a5de55e4d58a6798cd4f023fe780113d551a9afe61f6f56ee0a93fe8752ba92869103b8a1aaa6c8b89e5`)),
            // boa1xrval6hd8szdektyz69fnqjwqfejhu4rvrpwlahh9rhaazzpvs5g6lh34l5
            Enrollment(
                Hash(`0x9b2726e79f05abc107b6531486a46c977414e13ed9f3ee994ec14504964f86fcf9464055b891b9c34020feb72535c300ff19e8b5167eb9d202db1a053d746b2c`),
                Hash(`0xe0dce92ebd44c6398e582e5439dfe03a08a0cb9c45075f6ecbe1edac3bcacf201baddc9c522415eb2f8033f263122becaa7fc078aa2423d39de05df7eaa27c3e`),
                Signature.fromString(`0xa72ed0e4b392632c51a923a79b319d9db6c5269319bb94ecff4588c18d0a9a1c0c754ea4dbea99c0386afb8bfae9a65d5c9ed0fe7ddba53521badbc957271e81`)),
            // boa1xrval5rzmma29zh4aqgv3mvcarhwa0w8rgthy3l9vaj3fywf9894ycmjkm8
            Enrollment(
                Hash(`0xab19131ad8974a20881e2cd0798684a06ca0054160735cdf67fe8ee5a0eb4e28e9bf3f4c735f9ed3da958778978c86b409b8d133f30992141f0ac7e01e7f1255`),
                Hash(`0x2bd87a2f9aa23437d7ce913f3d646bf9f5a5fc0db24822ab7451e3d0746eefd2fab29749c245f8ad2c40718db6fd4de618637575b6c6eef37c58a47968d1ee80`),
                Signature.fromString(`0xe9a3c6c63d9810e61561fb7e4379849d57d7d47942d6ca4ecf993ad7aafe76f50efe67bb7c2a3dd54877b5c2738d4db2f97c277a4e7bad459235e19c9a3fc88d`)),
            // boa1xzval4nvru2ej9m0rptq7hatukkavemryvct4f8smyy3ky9ct5u0s8w6gfy
            Enrollment(
                Hash(`0xdb7664caba94c8d4602c10992c13176307e1e05361c150217166ee77fc4af9bf176f31dc61aba61e634dfc0b4c5f729d59e604607f61c9f66b10c6841f972a0a`),
                Hash(`0x00eb7bc977af8044f37453b7498f0db9e58bb21c5d0065a05d6ca656b40758e62bd2fd18a403b99bfd6f8e2530528a12b76cf70fead17145e503f5a6bb78fb56`),
                Signature.fromString(`0x07ffcebf03b8e7c2f14209f0999bfbd80f2704d69d1383434c9c0ff7f52ad22c09e7b71a5d9bd8605f04db19fdbe35e2078a920ea3cd46b69dac6c2749f64ad1`)),
        ],
    },
    merkle_tree: GenesisMerkleTree,
    txs: [
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
    Hash(`0x5289192825c751ac16649f59f4d4ee7b115af7918c625e944bbf9301a20f77c447d2c54f712fdf224c8d3564d9afcee6a85d70910ec892adb758471f3c55c7c5`),
    Hash(`0x56c1aa99fb4c9795274b8b2ffa6fe555885b9bbf07ecf20c8556bf1c6f7949d9e356b72dcc6d9e2c0ff0afcfbe522b2a5a01f2309ae610c0a457d66d9a0b0165`),
    Hash(`0xeb5e0004d046422c84ddb7b9d54a0eba484a41b5179beda0b3dd7c54c3fca609437a9c8ef16b5bfc2335d9b258eb68908757e0f1a4c725752598aaa962924551`),
    Hash(`0xeb5e0004d046422c84ddb7b9d54a0eba484a41b5179beda0b3dd7c54c3fca609437a9c8ef16b5bfc2335d9b258eb68908757e0f1a4c725752598aaa962924551`),
    Hash(`0xa8becf607ad1721aa25b9378d8b64ec906ea9e383ef079aa6e6e94f09c85979d300e9bdf8513cbdb311123ec0bc1ad6c83cc5ceabd3f58db98a4e75aaeb92244`),
    Hash(`0x932c18001c1787ebd6440c69a4db00bc6bb98527bd0d41e7437df3d26b29b1603fc476c2b00870d304b04b3af4d886f67f12a0052a058919e86947f53af82cad`),
    Hash(`0xc5d27cf200b9da791f976ddaaee3d6f96cc33da9012f862f49f5af676910a70fb3d21b197ee2a53b3bda2e51ef2d870bf5148e8a602cf33d89df5bf3bee1103e`),
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
    WK.Keys.NODE2,
    WK.Keys.NODE3,
    WK.Keys.NODE6,
    WK.Keys.NODE5,
    WK.Keys.NODE4,
];
