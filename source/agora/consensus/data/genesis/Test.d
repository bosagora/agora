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
            // boa1xzval2a3cdxv28n6slr62wlczslk3juvk7cu05qt3z55ty2rlfqfc6egsh2
        Enrollment(
            Hash(`0x00df246a2c315a3ea2403abc15fb8393c861654985054847440a1c07ad56af0c792e7722c82b73207469f962129bd5142062d66ff6b71e79637b786d9050d43b`),
            Hash(`0x45a81942081ea00788a26187464fa79f6cefc3c09417167c64f638010ab40728d671c1725c6b30770e67a91688ab936a2bc1a402cf4cd2ffffa48f6c199f6332`),
            20,
            Signature.fromString(`0xe3f959407fe99cb23f352be4477bbef8f619a11283319192418ac869eeb2040608899a842eabbd09a2eddd31de78f36eadd80cca5cdb4529b7737bfe51afc449`)),
        // boa1xzval4nvru2ej9m0rptq7hatukkavemryvct4f8smyy3ky9ct5u0s8w6gfy
        Enrollment(
            Hash(`0x398b5d2d4cdaefb7d28b56137b06170fac0b61e94b06670c9cb171880836e7e0d656bc37b174e907e966f7caaeac6d44327affcc8166c4e1e7c2c7a0d705ac20`),
            Hash(`0x672401404e947aaae126a9e8c150facf0fea6d7b607725f4ada6de369fdd54d8079c2555ed52f80e160f9c78b5f650372d01daa765924a5e50a0db530a58e510`),
            20,
            Signature.fromString(`0x07ffcebf03b8e7c2f14209f0999bfbd80f2704d69d1383434c9c0ff7f52ad22c05702179697d380c7f976cbeab3bf9aa9ab995e75d4b329ab282df94856b52af`)),
        // boa1xzval3ah8z7ewhuzx6mywveyr79f24w49rdypwgurhjkr8z2ke2mycftv9n
        Enrollment(
            Hash(`0x8583f3e4df1428a74c06e8266626e43675f160bdab7a8fa2f08f5931440147f7858955802b349626a486e18bd95f58ba15f0fa88dfbf3a5dcec878cd64838893`),
            Hash(`0x072582e862efa9daf7a53a100989a07ad0ee0f0d5bfadf74909d6a6b3cf3c7a7e5d2e218f51df416d052b486e0d65608cbe70e51f0372fd211d68f353d299c0c`),
            20,
            Signature.fromString(`0x375eefbe1990a6e37b2f9a11b1ba68e3c8f8d0976f51a5de55e4d58a6798cd4f0d01b743c2f4d896914df0477790eafe6eab24d58f33bed756827e3028cc0205`)),
        // boa1xrval5rzmma29zh4aqgv3mvcarhwa0w8rgthy3l9vaj3fywf9894ycmjkm8
        Enrollment(
            Hash(`0x91913c4daff74612e122c38b2aceb1c7dea38a01f4a8120f8d79730696af1329153f3d91f14d2fae64f5692edf401a8a3e4b1e8c961ae1e31815ab4b606f51c8`),
            Hash(`0x27892eed27841003e3a5a6ad1e6de90fcb2bc0627ca138bdc0b12b1bbb413e3ca06331de912a90a5787a602511fbf5663903b8fee57f6b1f1978f93439e237bb`),
            20,
            Signature.fromString(`0xe9a3c6c63d9810e61561fb7e4379849d57d7d47942d6ca4ecf993ad7aafe76f5075d4e67b3f13b00e5f2776642c84416e028308a3afe1b0101cf0bc97c73a5d8`)),
        // boa1xrval7gwhjz4k9raqukcnv2n4rl4fxt74m2y9eay6l5mqdf4gntnzhhscrh
        Enrollment(
            Hash(`0xa5a485b67fd6e478366c256ff543f70b131810919a7010b413e9cbec1d4ab02aeb8088a8cc5c51ca8dc64d6486a38b72b9e55e5bf62b6eb34955219c57db6bda`),
            Hash(`0x0d74a7d76f9157f307e9f9b2792931479ba62bfed768e1e21675ebd20f8db701444bb319e037913a378f913e65611710ac8ad26251807ae2e288ffa1d6d30a8e`),
            20,
            Signature.fromString(`0x018389f5876ebac77ad4c2269415bf8a5b14e2374e9d30a933f70a10abbca2a40fe1fbaf1af6d0cbd4fa632841c86233345c05596d1835e38e8b40d2d318ef2c`)),
        // boa1xrval6hd8szdektyz69fnqjwqfejhu4rvrpwlahh9rhaazzpvs5g6lh34l5
        Enrollment(
            Hash(`0xada56d41308399ae70eba69c1192e3b486439676942f22895dc7ceaca599d1fbabc5a8f6202a5a4ebae3eb5fa85a6f12cb51d48cb5c54233d33e0c2c0b5afb97`),
            Hash(`0xe2f3bf5daf2d2522289cc93901e7a9d4fd5df8e85efa93960fa8eb46a85a45781f3121bb895fa5203108f3d690d21085f9c1cfccbd98de9b8e7e95ae070bcf5d`),
            20,
            Signature.fromString(`0xa72ed0e4b392632c51a923a79b319d9db6c5269319bb94ecff4588c18d0a9a1c0d8643332da454d7a9e7c1272ebf1d93ba2f1ff3b121921d00d81062e14480b9`)),
        ],
    },
    merkle_tree: GenesisMerkleTree,
    txs: [
        Transaction(
            TxType.Freeze,
            [
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
    Hash(`0x669b0c098d740f6926341d1167cd7f03e221aebb47453258c4e5736e41d6b0c0b04d4f850a98a7dfbb5974aed61097603836a1968a882791246fc9e66ada36f6`),
    Hash(`0xd4b2011f46b7de32e6a3f51eae35c97440b7adf427df7725d19575b8a9a8256552939656f8b5d4087b9bcbbe9219504e31f91a85fb1709683cbefc3962639ecd`),
    Hash(`0x255b9a117f5abbbb7f1a38c5184b84d8fd4109c8f7f0e41472e0ac82adaae9ae41615e8eca8be9dcb7cc775aa9869ad617101a4f045e13a8232d73fbc2cf9a9e`)
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
    WK.Keys.NODE2,
    WK.Keys.NODE4,
    WK.Keys.NODE3,
    WK.Keys.NODE5,
    WK.Keys.NODE7,
    WK.Keys.NODE6,
];
