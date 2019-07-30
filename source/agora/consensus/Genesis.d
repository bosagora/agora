/*******************************************************************************

    Contains primitives related to the genesis block

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.Genesis;

import agora.common.Block;
import agora.common.Data;
import agora.common.Hash;
import agora.common.Transaction;
import agora.common.crypto.Key;

/*******************************************************************************

    Creates the genesis block.
    The output address is currently hardcoded to a randomly generated value,
    it will be replaced later with the proper address.

    Returns:
        the genesis block

*******************************************************************************/

public Block getGenesisBlock ()
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
    import agora.common.Block;
    import std.algorithm;
    import std.range;
    import std.format;

    Output[] outputs = iota(Block.TxsInBlock).map!(
        _ => Output(Amount(40_000_000 / Block.TxsInBlock), getGenesisKeyPair().address)
        ).array;

    return Transaction(
        [Input(Hash.init, 0)],
        outputs
    );
}

/*******************************************************************************

    Get the key-pair which can spend the UTXO in the genesis transaction.

    Used for unittests, will be removed later.
    The associated address is :
    GCOQEOHAUFYUAC6G22FJ3GZRNLGVCCLESEJ2AXBIJ5BJNUVTAERPLRIJ

    Returns:
        the key pair which can spend the UTXO in the genesis transaction

*******************************************************************************/

public KeyPair getGenesisKeyPair ()
{
    return KeyPair.fromSeed(
        Seed.fromString(
            "SCT4KKJNYLTQO4TVDPVJQZEONTVVW66YLRWAINWI3FZDY7U4JS4JJEI4"));
}
