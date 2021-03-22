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
            // GDNODE2JBW65U6WVIOESR3OTJUFOHPHTEIL4GQINDB3MVB645KXAHG73
            Enrollment(
                Hash(`0x1da29910b5ed5b9ea3bd4207016f485f763b44bd289444a4cef77faa96480d6833ce0b215c3ed6e00e9119352e49bb3e04054e0fca5fef35aeb47a9e425d7ddf`),
                Hash(`0x87b84a41392a6de113dfebf8374de46e5b65dcdcfbb00d49804b5b198ed984bf67d736bf26812160a6e36f02ea040d305dc2f82a5dfb7006b772da4db395eb7b`),
                20,
                Signature.fromString(`0x7c07d85a9d03fb09b20de2cad0b37f244790e13e525ebd898caa0b5e8bc8cb68081ee969fc1360c64ad7ca923ad3fac2cbfc0b51c21581cbdc75ddb7783b9c99`)),
            // GDNODE5EDFDRT5YGK2MOZ2E3EKW76CB6NYPRAUX2CW2UMT423LWWDSMG
            Enrollment(
                Hash(`0x3764508f77003808ba8b27ec0c8706ea7b4efdc8211e132dd8f1509643859af5489292694ef14ce1a77f56fd21f7ef3d57e4b013458aea2d915a82ecd4cf3533`),
                Hash(`0xa734608d4abc75b04326cd00a832aa88544fceae34c3e1cd6d529b8da5da6d39ab667475084cc0fc888f38ef0d541b4abbd31a19a705ac04f79d05a428b4ae28`),
                20,
                Signature.fromString(`0x30719c79055dd96c9a5ba718472ce5dd1577b64ce7b3a3d41629b572fd12f0940b9e638e9984b1e685eff1a940f1f046ebbb37aaedeeb78e31a256a75d01863a`)),
            // GDNODE4XYKLOKSF6OAZR5XXR6ATSE5UFTUZLCHHTFJMOEELFSEMDNQO2
            Enrollment(
                Hash(`0x6100ee7a7e00e18e06b743a7ae90e91781c09e0f1791ee2849ce15caf4c6ee1f3aebc23768f98153d8e3fb10ac66267e06acc31dccbfdbe671294a7fded22432`),
                Hash(`0xba5dad5171a266ff0cdda2a7ecb53496c45c1c2c581b5eca85cf0ca55862314eaf5c48be5faabda74dedf4b9965c5f8b7be37cc1904e9e59e699b0cda3689b1a`),
                20,
                Signature.fromString(`0xe2fd8f31f3e08c172ad11fb8119921faaff55e42f87b002dc6429391ee4222e40f093333a1be99564f3ec6929a88f80660e51e80b567028e5ca97ff8d0453ec5`)),
            // GDNODE3OVP5Z6WN43WU4JKVDJ6OS2WGZZ3PLR3XFEY7C2SV2DTZT27NU
            Enrollment(
                Hash(`0x740c6279bb59d9d6e098dab2485f5914aa5cea9ba39639f62c81041dacaf12e887de30089d1d887bc6e96eaecd076be9aac5f158af94c73def6ce255d6aad4f1`),
                Hash(`0x9a52cf5dd72ff2fdefa0d239cb1ffc9f2412ff2ed1eb587673b51b213620e3a771199fd25d2256c32f27c3d9d1ea95f39791afabf23b673537b6d338c914ebbd`),
                20,
                Signature.fromString(`0xc1b5bc1d4ef1e5fdf40ff0214403aefe9cdc133215edb0ea154425c82d1330280a473e54219fd4729bf5929307eafb9e572da56f46909f5376ce1cd13f75c768`)),
            // GDNODE7P5SNNH2YVUOVCDSJHQB3DL64V76QUSE2V5YRNY6HGK4YN6ZQQ
            Enrollment(
                Hash(`0xac296969fc6c59a53beb080d1d4f62d344779d9877aca1d374918815a424d50176e0c1bd79355ffb0424c43db050ad97bf799027639f1c65a2f44ae5326f5b8a`),
                Hash(`0x82994a61db724defb752ab528d5ceb44dd1c3972d475e474884bd796a776c5c648338a7993b8708055e7a0c5f159e03c29248c4c6366154bb5f095dee839ed9a`),
                20,
                Signature.fromString(`0xfdf2aaff0376e29d0dbef2ce2af762b696dcecdcd6bef57d953ad86609bb88510ed4216ab113d1f35889d64684659ace998ffe3d527e19dd3d36ec8fa351ce65`)),
            // GDNODE6M7LJF3DCJ2KAIBNXKHKIDATFT7TMXCBPELHEPEFCZN3IX2G3K
            Enrollment(
                Hash(`0xf86b2a5c800d872737b925df21923eee6eb998c705135e3165f3afd95131e39ec4d74a1b33eb3ea7a54524c183338d01bc79391f44bc6604a8f9e2cd0e324411`),
                Hash(`0x9f615ec8b4f35ad0e461c0fa2cf1350067478f034ee76cd0907f110da3bb7449fa1f71c7c25120ba1c5ca856e503e2fc70f30c2f80faf910fde185e81bac73ca`),
                20,
                Signature.fromString(`0x9f1b8cb72338c0504226a7ae33ee1889810eabdb7d618f95739a0ba6b902c39e08c37de5609a026267d8fd5325b4d58a40c4f2ea526332b138f20ccf72677792`)),
            ],
    },
    merkle_tree: GenesisMerkleTree,
    txs: [
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
    Hash(`0x4ef4f7195db2e20f36b46cb3cda1f529b77e2cd8423241d1a4a779f3d7845d4f6543a6147956bf4fe52d5f5925a04102de59b2854f90fb3e8cc1a0e85fe9b11d`),
    Hash(`0xb8f5a5f4544e75b5837a370d0070361aaaf97d3b02070d3d9845598c5f55105b6bd9ac8e9c53e74679db77cb512ffd88a9916754744f6b5eb2a812929651f84f`),
    Hash(`0xb33f170692b3db7f3b172b3d2c0c6b01eef033c0b3023e36ad24adacf2bb28732caf313ed873fa9b1dcc058b198a909c065181d9eb36559c5b71c85eba7f0e34`)
];

/// GDGENES4KXH7RQJELTONR7HSVISVSQ5POSVBEWLR6EEIIL72H24IEDT4
private immutable PublicKey GenesisOutputAddress = GenesisAddressUbyte;

///
private immutable ubyte[] GenesisAddressUbyte = [
    204, 70, 146, 92, 85, 207, 248, 193,
    36, 92, 220, 216, 252, 242, 170, 37,
    89, 67, 175, 116, 170, 18, 89, 113,
    241, 8, 132, 47, 250, 62, 184, 130
    ];

unittest
{
    assert(GenesisOutputAddress.toString()
           == `GDGENES4KXH7RQJELTONR7HSVISVSQ5POSVBEWLR6EEIIL72H24IEDT4`, GenesisOutputAddress.data.toString());
}

/// GDCOMMO272NFWHV5TQAIQFEDLQZLBMVVOJTHC3F567ZX4ZSRQQQWGLI3
public immutable PublicKey CommonsBudgetAddress = CommonsBudgetUbyte;

///
private immutable ubyte[] CommonsBudgetUbyte = [
    196, 230, 49, 218, 254, 154, 91, 30,
    189, 156, 0, 136, 20, 131, 92, 50,
    176, 178, 181, 114, 102, 113, 108, 189,
    247, 243, 126, 102, 81, 132, 33, 99
    ];

unittest
{
    assert(CommonsBudgetAddress.toString()
           == `GDCOMMO272NFWHV5TQAIQFEDLQZLBMVVOJTHC3F567ZX4ZSRQQQWGLI3`, CommonsBudgetAddress.toString());
}

unittest
{
    import agora.serialization.Serializer;
    testSymmetry(GenesisBlock.txs[0]);
    testSymmetry(GenesisBlock.txs[1]);
    testSymmetry(GenesisBlock);
}

public KeyPair[] genesis_validator_keys = [
    WK.Keys.NODE2,
    WK.Keys.NODE3,
    WK.Keys.NODE4,
    WK.Keys.NODE5,
    WK.Keys.NODE6,
    WK.Keys.NODE7
];
