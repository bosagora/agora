/*******************************************************************************

    Create blocks with multiple transactions and test that they are
    read properly.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module unit.BlockStorageMultiTx;

import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Hash;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.consensus.Genesis;
import agora.node.BlockStorage;
import agora.utils.Test;

import std.algorithm.comparison;
import std.array;
import std.file;
import std.path;

/// The maximum number of block in one file
private immutable ulong MFILE_MAX_BLOCK = 100;

/// blocks to test
const size_t BlockCount = 300;

///
private void main ()
{
    auto path = makeCleanTempDir();

    BlockStorage storage = new BlockStorage(path);
    storage.load();
    const(Block)[] blocks;
    blocks ~= GenesisBlock;

    const(Transaction)[] last_txs = genesisSpendable().array;
    foreach (block_idx; 0 .. BlockCount)
    {
        // create enough tx's for a single block
        auto txs = makeChainedTransactions([WK.Keys.Genesis.address], last_txs, 1);

        auto block = makeNewBlock(blocks[$ - 1], txs, null);
        storage.saveBlock(block);
        blocks ~= block;
        last_txs = txs;
    }

    //// load
    Block[] loaded_blocks;
    loaded_blocks.length = BlockCount + 1;
    foreach (idx; 0 .. BlockCount + 1)
        storage.readBlock(loaded_blocks[idx], Height(idx));
    size_t idx;

    assert(loaded_blocks == blocks);
}
