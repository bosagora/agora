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
            // boa1xrval5rzmma29zh4aqgv3mvcarhwa0w8rgthy3l9vaj3fywf9894ycmjkm8
            Enrollment(
                Hash(`0x29bba03aa33cb09e2aa1d35d59c67bd088b619674cea51a2f72c7208c5c524bf6e3824a70de3bec3f8cb91d92afbbd4b469c2d9f83836e0bea71a99a253185d8`),
                Hash(`0x27892eed27841003e3a5a6ad1e6de90fcb2bc0627ca138bdc0b12b1bbb413e3ca06331de912a90a5787a602511fbf5663903b8fee57f6b1f1978f93439e237bb`),
                20,
                Signature.fromString(`0xe9a3c6c63d9810e61561fb7e4379849d57d7d47942d6ca4ecf993ad7aafe76f507308aa930f14be1bac345b316f80a3a2d2d20faa4699be8bd698c8e5ca039c0`)),
            // boa1xrval6hd8szdektyz69fnqjwqfejhu4rvrpwlahh9rhaazzpvs5g6lh34l5
            Enrollment(
                Hash(`0x5735b3bcb1b36b6cb274712f991724e69e6fa2e3e3e503c99b1ed057db664e4c3de3b0e2647ee6e8d167295731e2326b5b3e76b0e9d1b7ba123980248b1f815c`),
                Hash(`0xe2f3bf5daf2d2522289cc93901e7a9d4fd5df8e85efa93960fa8eb46a85a45781f3121bb895fa5203108f3d690d21085f9c1cfccbd98de9b8e7e95ae070bcf5d`),
                20,
                Signature.fromString(`0xa72ed0e4b392632c51a923a79b319d9db6c5269319bb94ecff4588c18d0a9a1c02cc0878d374f2ec8b19ff4c6c89f62807c72950c971a188c1f2e582d0e682a4`)),
            // boa1xzval2a3cdxv28n6slr62wlczslk3juvk7cu05qt3z55ty2rlfqfc6egsh2
            Enrollment(
                Hash(`0x85f4701e9fb2f87a7adfc53130c3abe591f6b329e3a4c78e70d61d2bcced73b35819f0b1f3e8f1721089b8695ca66a072a2660ffa8465d2cc45e8edd38237252`),
                Hash(`0x45a81942081ea00788a26187464fa79f6cefc3c09417167c64f638010ab40728d671c1725c6b30770e67a91688ab936a2bc1a402cf4cd2ffffa48f6c199f6332`),
                20,
                Signature.fromString(`0xe3f959407fe99cb23f352be4477bbef8f619a11283319192418ac869eeb20406030b7acb4bbaae0c64b2538c88b19fdd6b36e838b5d1649fd2f0eb6d0140b6e8`)),
            // boa1xzval4nvru2ej9m0rptq7hatukkavemryvct4f8smyy3ky9ct5u0s8w6gfy
            Enrollment(
                Hash(`0x96e29a18810e95f621146e5823549dfa6ad7e51b585d4997d2a61797af22d6ef100f6e2aeeed1d40613a166657398b7ab52abd9cf9e964e010808382a8183cd0`),
                Hash(`0x672401404e947aaae126a9e8c150facf0fea6d7b607725f4ada6de369fdd54d8079c2555ed52f80e160f9c78b5f650372d01daa765924a5e50a0db530a58e510`),
                20,
                Signature.fromString(`0x07ffcebf03b8e7c2f14209f0999bfbd80f2704d69d1383434c9c0ff7f52ad22c0a0d0dc8781e81b0d3b05499a6341c69fd53f726eefa9b266fb32b83575c73c3`)),
            // boa1xzval3ah8z7ewhuzx6mywveyr79f24w49rdypwgurhjkr8z2ke2mycftv9n
            Enrollment(
                Hash(`0x9c875bc97609b7871ecc827a528819b3c14149abdc1d6d2f6173025cd374d22941d1f82e5717abac3ea45ca851f69b1c2744a3239448cf905049516eab6df3d7`),
                Hash(`0x072582e862efa9daf7a53a100989a07ad0ee0f0d5bfadf74909d6a6b3cf3c7a7e5d2e218f51df416d052b486e0d65608cbe70e51f0372fd211d68f353d299c0c`),
                20,
                Signature.fromString(`0x375eefbe1990a6e37b2f9a11b1ba68e3c8f8d0976f51a5de55e4d58a6798cd4f0170a897c1656580989af4ea061fe2ba0b61c8f282d419d2dedff8bc2aa28c4b`)),
            // boa1xrval7gwhjz4k9raqukcnv2n4rl4fxt74m2y9eay6l5mqdf4gntnzhhscrh
            Enrollment(
                Hash(`0xd17c08680d5099718e06a5f590235d8ed4e18bd03e3e4ed0e61a0a8a76a19f083b9a85f9304cbbcc7fd4593940f19ae6157334256abeda8e7ff3f2351a1d1ec2`),
                Hash(`0x0d74a7d76f9157f307e9f9b2792931479ba62bfed768e1e21675ebd20f8db701444bb319e037913a378f913e65611710ac8ad26251807ae2e288ffa1d6d30a8e`),
                20,
                Signature.fromString(`0x018389f5876ebac77ad4c2269415bf8a5b14e2374e9d30a933f70a10abbca2a40c1afd038a27dd1bce01dd2aced17cff2a1ea6fe8a46ec6fa32bcb969298e78b`)),
            ],
    },
    merkle_tree: GenesisMerkleTree,
    txs: [
        Transaction(
            TxType.Freeze,
            [
                // If we want these in order NODE2, NODE3 .. NODE7
                // then we need to make sure the value of the Public key is in same order
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE2.address),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE3.address),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE4.address),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE5.address),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE6.address),
                Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE7.address),
            ]),
        Transaction(
            TxType.Payment,
            [
                Output(Amount(61_000_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), GenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), GenesisOutputAddress),
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
    Hash(`0x17c2087b91d548c0fab63c1a639597264ec1cd55099bd9acfeb8e42eb5b85b8d07c6c7328b3ad6d5b15fa0e44b5de3060804dbb0ff0dd1d866daed13f999c615`),
    Hash(`0x8b56491e3ee6ee46caa7c5be6ef56fbffc34e6e4bd53db88689de69546ca8f316928e67865c773a48bba4ba066321b967a48f895062a635b0d27a8540b093562`),
    Hash(`0x8c24eaafbf9477ca05db3b957c99f275a19e35b056c7b5bc508c6d572380a915193dfab32fb00d1b0c70df1583783966bd6c4e20f0d88f1baa257030d65ebeed`)
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
    WK.Keys.NODE6,
    WK.Keys.NODE2,
    WK.Keys.NODE4,
    WK.Keys.NODE3,
    WK.Keys.NODE7,
];
