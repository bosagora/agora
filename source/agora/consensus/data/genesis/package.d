/*******************************************************************************

    Contains primitives related to the genesis block

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.genesis;

import agora.common.Amount;
import agora.common.Hash;
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.validation.Block;

/// Contains a pointer to the genesis block.
version (unittest)
{
    import Mod = agora.consensus.data.genesis.Test;
    private immutable(Block)* gen_block = &Mod.GenesisBlock;
}
else
{
    import Mod = agora.consensus.data.genesis.Coinnet;
    private immutable(Block)* gen_block = &Mod.GenesisBlock;
}

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

    Build a Genesis block from the provided data

    This function is intended to be used when the hard-coded genesis block
    needs to be replaced, e.g. when the parameters are changed or a new network
    is created. It shouldn't be used in non-test code.

*******************************************************************************/

public immutable(Block) makeGenesis (
    Transaction[] txs, Enrollment[] enrolls, Signature delegate(Hash) sigcb)
{
    Block genesis;
    // Add provided txs and generate Merkle tree
    genesis.txs ~= txs;
    genesis.header.merkle_root = genesis.buildMerkleTree();

    // Add all enrollments and their signatures
    genesis.header.enrollments ~= enrolls;
    genesis.header.validators = typeof(BlockHeader.validators)(enrolls.length);
    foreach (cnt; 0 .. enrolls.length)
        genesis.header.validators[cnt] = true;
    genesis.header.signature = sigcb(genesis.header.hashFull());

    if (const reason = genesis.isGenesisBlockInvalidReason())
        assert(0, reason);

    return cast(immutable)(genesis);
}
