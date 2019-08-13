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
import agora.consensus.data.Block;
import agora.common.Data;
import agora.common.Hash;
import agora.common.crypto.Key;
import agora.consensus.data.Transaction;

/*******************************************************************************

    Creates the genesis block.
    The output address is currently hardcoded to a randomly generated value,
    it will be replaced later with the proper address.

    Returns:
        the genesis block

*******************************************************************************/

public const(Block) getGenesisBlock ()
{
    Block block;
    block.header.height = 0;
    block.txs ~= getGenesisTx();
    block.header.merkle_root = block.buildMerkleTree();
    return block;
}

///
unittest
{
    // ensure the genesis block is always the same
    assert(getGenesisBlock() == getGenesisBlock());
}

/*******************************************************************************

    Returns:
        the genesis transaction

*******************************************************************************/

public Transaction getGenesisTx ()
{
    import agora.consensus.data.Block;
    import std.algorithm;
    import std.range;
    import std.format;

    Output[] outputs = iota(Block.TxsInBlock).map!(
        _ => Output(Amount(40_000_000 / Block.TxsInBlock), GenesisOutputAddress)
        ).array;

    return Transaction(
        [Input(Hash.init, 0)],
        outputs
    );
}

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


version (unittest)
{
    /***************************************************************************

        Get the key-pair which can spend the UTXO in the genesis transaction.

        In unittests, we need the genesis key pair to be known for us to be
        able to test anything. Hence the genesis block has a different value.

        Seed:    SCT4KKJNYLTQO4TVDPVJQZEONTVVW66YLRWAINWI3FZDY7U4JS4JJEI4
        Address: GCOQEOHAUFYUAC6G22FJ3GZRNLGVCCLESEJ2AXBIJ5BJNUVTAERPLRIJ

        Returns:
            the key pair which can spend the UTXO in the genesis transaction

    ***************************************************************************/

    public KeyPair getGenesisKeyPair ()
    {
        return KeyPair.fromSeed(
            Seed.fromString(
                "SCT4KKJNYLTQO4TVDPVJQZEONTVVW66YLRWAINWI3FZDY7U4JS4JJEI4"));
    }

    // Check that the public key matches, temporarily
    unittest
    {
        assert(getGenesisKeyPair().address == GenesisOutputAddress);
    }
}
