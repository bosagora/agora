/*******************************************************************************

    Contains primitives related to the genesis block

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.Genesis;

import agora.common.Amount;
import agora.common.Hash;
import agora.common.Types;
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.validation.Block;
import agora.utils.Test;

/// Contains a pointer to the genesis block.
version (unittest)
    private immutable(Block)* gen_block = &UnitTestGenesisBlock;
else
    private immutable(Block)* gen_block = &CoinNetGenesisBlock;

/*******************************************************************************

    Returns:
        a reference to the genesis block.

*******************************************************************************/

pragma(inline, true)
public ref immutable(Block) GenesisBlock () nothrow @safe @nogc
{
    return *gen_block;
}

/*******************************************************************************

    Set a custom Genesis block. Any subsequent call to `GenesisBlock`
    will refer to the Block as configured here.

    Params:
        block = the new Genesis block to use

*******************************************************************************/

pragma(inline, true)
public void setGenesisBlock (immutable Block* block)
    @safe
{
    assert(block !is null);

    if (auto reason = isGenesisBlockInvalidReason(*block))
        throw new Exception(reason);

    gen_block = block;
}

/*******************************************************************************

    Returns:
        a reference to the genesis transaction

*******************************************************************************/

pragma(inline, true)
public ref immutable(Transaction) GenesisTransaction () nothrow @safe @nogc
{
    return gen_block.txs[1];
}

/*******************************************************************************

    The genesis block as used by most unittests

    Note that this is more of a 'test' block than a 'unittest' block,
    and it's currently used in a few integration test, hence why it is not
    `version (unittest)`.

    It contains a total of 500M initial coins, of which 12M have been frozen
    among 6 nodes, and the rest is evenly split between 8 outputs (61M each).

*******************************************************************************/

private immutable Block UnitTestGenesisBlock = {
    header: {
        prev_block:  Hash.init,
        height:      Height(0),
        merkle_root: UnitTestGenesisMerkleTree[$ - 1],
        enrollments: [
            Enrollment(
                Hash(`0x46883e83778481d640a95fcffd6e1a1b6defeaac5a8001cd3f99e17576b809c` ~
                     `7e9bc7a44c3917806765a5ff997366e217ff54cd4da09c0c51dc339c47052a3ac`),
                Hash(`0xe5a721c94a3fc70abc6ea490164afc684de4395c7337fd2527529a9c62df191` ~
                     `40e076f6107c03ac2680e3c2b29db29233c9add36db25aac2d7aec09baf029a38`),
                1008,
                Signature(`0x034c6cfbdece8eeca9e7ed8e5fce86150f29a0dce90bb5ff33857f5752266af` ~
                          `3dc8b89135fe3f5df9e2815b9bdb763c41b8b2dab5911e313acc82470c2147422`)
            ),

            Enrollment(
                Hash(`0x4dde806d2e09367f9d5bdaaf46deab01a336a64fdb088dbb94edb171560c63c` ~
                     `f6a39377bf0c4d35118775681d989dee46531926299463256da303553f09be6ef`),
                Hash(`0xd409b6b1d4f39baf8e7dd4d7bf01be89eebe6fd2f724ba5aa7ef7529f542381` ~
                     `4142acee417e62e289b87c17bf4cb531f1bfe12cbeae3dd842af279e127bd2843`),
                1008,
                Signature(`0x046affb4dbae903a47e75dac343e66e0fe1ee8c99a0f072e210458632316e6f` ~
                          `e2692d0b8b04133a34716169a4b1d33d77c3e585357d8a2a2c48a772275255c01`)
            ),

            Enrollment(
                Hash(`0x8c1561a4475df42afa0830da1f8a678ad4b1d82b6c610f7b03ce69b7e0fabcf` ~
                     `537d48ecd0aee6f1cab14290a0fc6313c729edf928ff3576f8656f3b7be5670e0`),
                Hash(`0xd83ee1b8609ddbed2dc7c8608704565e6a4122121aaf770d7cf75d74f8ec67d` ~
                     `01730df8b9104c4424b959da15c1076fca90a4eff23153f246c71b13973733942`),
                1008,
                Signature(`0x0b9b073c924ffbb26ca026939bbf19bf65769c1e375b9855ec5aadf1cb1e0d7` ~
                          `77e3d4753b6b4ccdb35c2864be4195e83b7b8433ca1d27a57fb9f48a631001304`)
            ),

            Enrollment(
                Hash(`0x94908ec79866cf54bb8e87b605e31ce0b5d7c3090f3498237d83edaca9c8ba2` ~
                     `d3d180c572af46c1221fb81add163e14adf738df26e3679626e82113b9fe085b0`),
                Hash(`0x34fde2fb7140b7c65da081fafc5e883dabf22ab4a3db655a11ea934d664a7eb` ~
                     `12e10dde55c27d6f127c83a53322d615e97ab3b4d2f64a1b150d586e8cd16acda`),
                1008,
                Signature(`0x03ac63d9fdeb0952db6676556e07ad14efcceb9f03711b73f697e774c552400` ~
                          `8fd787c4518b78ab9ed73a3760741d557ac2aca631fc2796be86fcf391d3a6634`)
            ),

            Enrollment(
                Hash(`0xb20da9cfbda971f3f573f55eabcd677feaf12f7948e8994a97cdf9e570799b7` ~
                     `1631e87bb9ebce0d6a402275adfb6e365fdb72139c18559a10df0e5fe4bae08eb`),
                Hash(`0x52df29767ea498e78e50a6db1ec4095cead3b4d11a368d5c2c5859042764f97` ~
                     `f1955cd3cc73190f97431e2736805a986f61d4be67bb9a82eab54c85bcfbe6cdb`),
                1008,
                Signature(`0x0b05b49b2a4776645f765288380e945b3e81ea883aec2d6c9815db70138f332` ~
                          `2d79a36ace4d3097869dc009b8939fc83bdf940c8822c6931d5c09326aa746b31`)
            ),

            Enrollment(
                Hash(`0xdb3931bd87d2cea097533d82be0a5e36c54fec8e5570790c3369bd8300c65a0` ~
                     `3d76d12a74aa38ec3e6866fd64ae56091ed3cbc3ca278ae0c8265ab699ffe2d85`),
                Hash(`0x23dc305988b8ff32232256192f2350fe8cde4f54c60ca266c444489b9081702` ~
                     `0d3c38148f877b8b16a80e46ce35e1a3e66a5309786282b816627961e1dcb088e`),
                1008,
                Signature(`0x0e251a27c71664bd6105b5f3817c5833971f13a57c02457fcc1c7f7cc937553` ~
                          `55c71e74382a24b7e644d32b0306fe3cf14ecd7de5635c70aa592f4721aa74fe2`)
            ),
        ],
    },
    merkle_tree: UnitTestGenesisMerkleTree,
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
                Output(Amount(61_000_000L * 10_000_000L), UnitTestGenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), UnitTestGenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), UnitTestGenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), UnitTestGenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), UnitTestGenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), UnitTestGenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), UnitTestGenesisOutputAddress),
                Output(Amount(61_000_000L * 10_000_000L), UnitTestGenesisOutputAddress),
            ],
        },
    ],
};

///
unittest
{
    import std.algorithm;
    import agora.consensus.PreImage;
    import agora.common.crypto.ECC;
    import agora.common.crypto.Schnorr;
    import agora.consensus.data.UTXOSetValue;

    version (none)
    {
        import std.stdio;
        import std.range;

        const txs = UnitTestGenesisBlock.txs;

        if (!txs.isStrictlyMonotonic())
        {
            writeln("WARN: Genesis block transactions are unsorted!");
            txs.enumerate.each!((idx, tx) => writefln("[%d]: %s", idx, tx));
        }

        Hash[] merkle_tree;
        writeln("Merkle root: ", Block.buildMerkleTree(txs, merkle_tree));
        writeln("\tMerkle tree: ", merkle_tree);

        auto caches = [
            PreImageCache(PreImageCycle.NumberOfCycles, 1008),
            PreImageCache(PreImageCycle.NumberOfCycles, 1008),
            PreImageCache(PreImageCycle.NumberOfCycles, 1008),
            PreImageCache(PreImageCycle.NumberOfCycles, 1008),
            PreImageCache(PreImageCycle.NumberOfCycles, 1008),
            PreImageCache(PreImageCycle.NumberOfCycles, 1008),
        ];

        Pair[] kps;
        foreach (idx, outps; txs[0].outputs)
        {
            kps ~= Pair(secretKeyToCurveScalar(WK.Keys[outps.address].secret));
            kps[idx].V = kps[idx].v.toPoint();
            caches[idx].reset(
                hashMulti(kps[idx].v, "consensus.preimages", uint(0)));
        }

        Enrollment[] enrolls;
        const txhash = txs[0].hashFull();
        foreach (idx, ref outp; txs[0].outputs)
        {
            Pair sigNoise = Pair(
                Scalar(hashMulti(kps[idx].v, "consensus.signature.noise", ulong(0))));
            sigNoise.V = sigNoise.v.toPoint();
            enrolls ~= Enrollment(
                UTXOSetValue.getHash(txhash, idx), caches[idx][$ - 1], 1008);
            enrolls[$ - 1].enroll_sig = sign(
                kps[idx], sigNoise, enrolls[idx]);
        }

        enrolls.sort!((a, b) => a.utxo_key < b.utxo_key);
        writeln("Enrollments: ", enrolls);
    }

    Amount amount;
    assert(UnitTestGenesisBlock.txs.all!(tx => tx.getSumOutput(amount)));
    assert(amount == Amount.MaxUnitSupply, amount.toString());
    assert(UnitTestGenesisBlock.merkle_tree.length == UnitTestGenesisMerkleTree.length);
    assert(UnitTestGenesisBlock.header.merkle_root == UnitTestGenesisBlock.merkle_tree[$-1]);
}

private immutable Hash[] UnitTestGenesisMerkleTree = [
    Hash(`0x6314ce9bc41a7f5b98309c3a3d824647d7613b714c4e3ddbc1c5e9ae46db297` ~
         `15c83127ce259a3851363bff36af2e1e9a51dfa15c36a77c9f8eba6826ff975bc`),
    Hash(`0x7a5bfeb96f9caefa377cb9a7ffe3ea3dd59ea84d4a1c66304ab8c307a4f4770` ~
         `6fe0aec2a73ce2b186a9f45641620995f8c7e4c157cee7940872d96d9b2f0f95c`),
    Hash(`0x788c159d62b565655d9f725786c38e6802038ee73d7a9d187b3be1c7de95aa0` ~
         `ba856bf81bb556d7448488e71f4b89ce6eba319d0536798308112416413289254`),
];

/// GCOQEOHAUFYUAC6G22FJ3GZRNLGVCCLESEJ2AXBIJ5BJNUVTAERPLRIJ
private immutable PublicKey UnitTestGenesisOutputAddress = UnitTestGenesisAddressUbyte;

///
private immutable ubyte[] UnitTestGenesisAddressUbyte =
    [
        0x9D, 0x02, 0x38, 0xE0, 0xA1, 0x71, 0x40, 0x0B,
        0xC6, 0xD6, 0x8A, 0x9D, 0x9B, 0x31, 0x6A, 0xCD,
        0x51, 0x09, 0x64, 0x91, 0x13, 0xA0, 0x5C, 0x28,
        0x4F, 0x42, 0x96, 0xD2, 0xB3, 0x01, 0x22, 0xF5,
    ];

unittest
{
    assert(UnitTestGenesisOutputAddress.toString()
           == `GCOQEOHAUFYUAC6G22FJ3GZRNLGVCCLESEJ2AXBIJ5BJNUVTAERPLRIJ`);
}

unittest
{
    import agora.common.Serializer;
    testSymmetry(UnitTestGenesisBlock.txs[0]);
    testSymmetry(UnitTestGenesisBlock);
}

/// The genesis block as defined by CoinNet
private immutable Block CoinNetGenesisBlock =
{
    header:
    {
        prev_block:  Hash.init,
        height:      Height(0),
        merkle_root: CoinNetGenesisMerkleRoot,
    },
    txs: [ CoinNetGenesisTransaction ],
    merkle_tree: [ CoinNetGenesisMerkleRoot ],
};

///
unittest
{
    assert(CoinNetGenesisBlock.header.prev_block == Hash.init);
    assert(CoinNetGenesisBlock.header.height == 0);
    assert(CoinNetGenesisBlock.header.merkle_root == CoinNetGenesisBlock.merkle_tree[0]);
    assert(CoinNetGenesisBlock.merkle_tree.length == 1);
    assert(CoinNetGenesisBlock.header.merkle_root == hashFull(CoinNetGenesisTransaction));
}

///
private immutable Hash CoinNetGenesisMerkleRoot =
    Hash(`0x5d7f6a7a30f7ff591c8649f61eb8a35d034824ed5cd252c2c6f10cdbd223671` ~
         `3dc369ef2a44b62ba113814a9d819a276ff61582874c9aee9c98efa2aa1f10d73`);


/// The single transaction that are part of the genesis block
private immutable Transaction CoinNetGenesisTransaction =
{
    TxType.Payment,
    inputs: [],
    outputs: [
        Output(Amount(62_500_000L * 10_000_000L), CoinNetGenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), CoinNetGenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), CoinNetGenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), CoinNetGenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), CoinNetGenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), CoinNetGenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), CoinNetGenesisOutputAddress),
        Output(Amount(62_500_000L * 10_000_000L), CoinNetGenesisOutputAddress),
    ],
};

// TODO: Replace with the foundation's pubkey
/// GCOQEOHAUFYUAC6G22FJ3GZRNLGVCCLESEJ2AXBIJ5BJNUVTAERPLRIJ
private immutable PublicKey CoinNetGenesisOutputAddress = CoinNetGenesisAddressUbyte;

///
private immutable ubyte[] CoinNetGenesisAddressUbyte =
    [
        0x9D, 0x02, 0x38, 0xE0, 0xA1, 0x71, 0x40, 0x0B,
        0xC6, 0xD6, 0x8A, 0x9D, 0x9B, 0x31, 0x6A, 0xCD,
        0x51, 0x09, 0x64, 0x91, 0x13, 0xA0, 0x5C, 0x28,
        0x4F, 0x42, 0x96, 0xD2, 0xB3, 0x01, 0x22, 0xF5,
    ];

unittest
{
    assert(CoinNetGenesisOutputAddress.toString()
           == `GCOQEOHAUFYUAC6G22FJ3GZRNLGVCCLESEJ2AXBIJ5BJNUVTAERPLRIJ`);
}

unittest
{
    import agora.common.Serializer;
    testSymmetry(CoinNetGenesisTransaction);
    testSymmetry(CoinNetGenesisBlock);
}
