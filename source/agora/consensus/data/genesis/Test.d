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
            // boa1xpvald2ydpxzl9aat978kv78y5g24jxy46mcnl7munf4jyhd0zjrc5x62kn
            Enrollment(
                Hash(`0x096b57f1c92133073e432102d24b00148f5874fbb63f7fff216d832cb3cbed2b26d8017ba878c9d191bc2934ad742fd7830fe90a42c12faba550de4c25f77e64`),
                Hash(`0x50169f7f3473df6cf06c0002a045807e23a531dad99db2958ee600566a3bf40942083ad8f9c867969cb1613aa396e18c66221488288e95d6d7997aa0d66dc2ac`),
                20,
                Signature.fromString(`0x4ca0f595a11e5b5c21a07a443fd66e76da0651b3635ce4d4e7fba6eb328786bc0590180d0dbd2bb119c3b33d20ea7bd326eabc70efed85660c797941a231d282`)),
            // boa1xzvald5dvy54j7yt2h5yzs2432h07rcn66j84t3lfdrlrwydwq78cz0nckq
            Enrollment(
                Hash(`0x1f855b74bc623e9767e228362a7517c30d123bbeeae98d85fa933e5d24762f3040a220e327f023b23c562e36f673e9fa972e846efd6326dcafb9784b94937dbe`),
                Hash(`0x177c0517316d030ce6551949f9fa549bab9fcefb915b5ff74d1512863fba9ad42fb2ef76faed2187f3d787439a2177d23c6fb601c42c30926a2b51df3c5b0a46`),
                20,
                Signature.fromString(`0x89f1a9ac65fb96236b7867f6f6df6464e36cd9e36b987ef0dc89d30b18ae4fbd0e0b0716e58e7f9e53268e027d6c627dbfb326732b454c8184262dcad3a0bde4`)),
            // boa1xrvald4v2gy790stemq4gg37v4us7ztsxq032z9jmlxfh6xh9xfak4qglku
            Enrollment(
                Hash(`0x2f8b231aa4fd35c6a5c68a97fed32120da48cf6d40ccffc93d8dc41a3016eb56434b2c44144a38efe459f98ddc2660b168f1c92a48fe65711173385fb4a269e1`),
                Hash(`0x350c2e15b70e103f20c72e25b1e394fbb575c79642d6ffe889e35c335dbedc9ba08d37c074bda5ba6e5d9fd9abc85a0ec802bf2eb67fd1c9976adb00fe79fb83`),
                20,
                Signature.fromString(`0xf13cd27e7eb867e589c2baeae7c36ddfd2f6b6188d3622c21711e342ba360da308dd7f1841ba94dd0a25c6e1ff0c4f8e95fc323f2d6298089de3c66b7e385fe7`)),
            // boa1xzvald7hxvgnzk50sy04ha7ezgyytxt5sgw323zy8dlj3ya2q40e6elltwq
            Enrollment(
                Hash(`0x47a38b066ca55ef3e855b0c741ebd301b3fa38a86f9ed3507ab08794f24eddbd279eeb5bddde331cdaaf44401fcedb0f2f23d117607864c43bdb0cf587df13d7`),
                Hash(`0xce834b914e9b785ccdc019f6bfce61e4b89ac705b6e4d0716469778260cd8929444ea0598f6ef4bd12582507e00789c88e782571cc186313728c0b0ac721a262`),
                20,
                Signature.fromString(`0x39ef7531e3aa7d8b305f83e9b61e2598ef62a4d49b75e245799d9277c277e3760d2d9ab8a645e8886adf1c8bf322ae78fb0dbcad70441c247f88ffb30eafbfdf`)),
            // boa1xrvald6jsqfuctlr4nr4h9c224vuah8vgv7f9rzjauwev7j8tj04qee8f0t
            Enrollment(
                Hash(`0x53b6a6da4ee9cd2bc803ccfe06db19b8e557f68ff23d05ea691ebabcd50f10c30cb658f8c0e72141263377d00d481a9b514b92c07aacf80e8642881cffdd5381`),
                Hash(`0x792bd41ffbf85d0cabf378c5a35a13c170d768f705d73611521a798ed09f0c18311e29090d5fb25b0fdba867a7c1bb4a75ab9a3adc2fa00edf81e5ababda7472`),
                20,
                Signature.fromString(`0xacc66460b3915e3bb753abee0237be2e4bb868697a86a66a3f2fc8d3b90ad29b0ccaad5ca5122f4ef08234ff87f83b0280d7e1126a01ac9b84ca5e9223943306`)),
            // boa1xrvald3zmehvpcmxqm0kn6wkaqyry7yj3cd8h975ypzlyz00sczpzhsk308
            Enrollment(
                Hash(`0xb25467a2a15176ae3d293051e01d1e402036a9fbbbbea0d49878ccf4244bd8546c2d42622309efccf884901e3e27b12f4fef3fb2a8f81317d7e375a0f648c2ad`),
                Hash(`0x02d96ac1260f94770ae09a781451f37b11971095e726f54b15a4a0bfce728bb47937a3038c21f7b37ed1d77f6d895e38d72d3748c393bccd0caa17fb54dd7c0a`),
                20,
                Signature.fromString(`0x4e001c67df605a44ae211f5db3235ec9403412572f3f35981d5e3c15744c7cdd09d9cb0b46de4cf55856bf5dd013c6f37b0db61a7f57ad5ba9b70cd34e3e49db`)),
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
    Hash(`0xd37793e642273aeccbcbfc6be8e19a6007c5147e1116123e44a5e42e4be11495561e535484a2922120c556161f7ae55433bd124bedbf935f3f5b9a414b7af34e`),
    Hash(`0xd4b2011f46b7de32e6a3f51eae35c97440b7adf427df7725d19575b8a9a8256552939656f8b5d4087b9bcbbe9219504e31f91a85fb1709683cbefc3962639ecd`),
    Hash(`0x94747147a0ca093d1099d1b2e0d9e2de9d89e0b887a56ffafb17f473cd0317de36ab7ecd2bdc1148d542bce9501aa1b978c722822a281e45034088286700059e`)
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

public immutable KeyPair[] genesis_validator_keys = [
    WK.Keys.NODE2,
    WK.Keys.NODE3,
    WK.Keys.NODE4,
    WK.Keys.NODE5,
    WK.Keys.NODE6,
    WK.Keys.NODE7
];
