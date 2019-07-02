/*******************************************************************************

    Defines the data structure of a block

    The design is influenced by Bitcoin, but will be ammended later.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Block;

import agora.common.Data;
import agora.common.Transaction;


/*******************************************************************************

    The block header which contains a link to the previous block header,
    unless it's the genesis header.

*******************************************************************************/

public struct BlockHeader
{
    /// Hash of the previous block in the chain of blocks
    public Hash prev_block;

    /// Block height (genesis is #0)
    public ulong height;

    /// The hash of the only transaction in the block
    /// (later to be replaced with a merkle root)
    public Hash tx_hash;
}

/*******************************************************************************

    The block which contains the block header and its body (the transactions).

    In the current preliminary design a block contains a single transaction.

*******************************************************************************/

public struct Block
{
    ///
    public BlockHeader header;

    ///
    public Transaction tx;
}
