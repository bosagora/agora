/*******************************************************************************

    IO-performing tests for `agora.common.BlockStorage`

    Create and store 1000 blocks and read again. And read 100 random.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module unit.BlockStorage;

import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.genesis.Test;
import agora.consensus.data.Transaction;
import agora.crypto.Hash;
import agora.node.BlockStorage;
import agora.utils.Test;

import std.algorithm.comparison;
import std.file;
import std.path;

///
private void main ()
{
    const size_t count = 300;

    auto path = makeCleanTempDir();
    BlockStorage storage = new BlockStorage(path);
    const(Block)[] blocks;
    Hash[] block_hashes;

    blocks ~= GenesisBlock;
    storage.load(GenesisBlock);

    const Transaction last_tx = blocks[$ - 1].txs[$-1];
    Hash gen_tx_hash = hashFull(last_tx);
    block_hashes ~= hashFull(blocks[$ - 1].header);
    Transaction tx;

    // save
    foreach (idx; 1 .. count)
    {
        tx = Transaction(
            TxType.Payment,
            [
                Input(gen_tx_hash, 0)
            ],
            [
                Output(Amount(1_000), WK.Keys[idx % 8].address)
            ]
        );
        blocks ~= makeNewBlock(blocks[$ - 1], [tx], blocks[$ - 1].header.timestamp + 1, Hash.init);
        block_hashes ~= hashFull(blocks[$ - 1].header);
        storage.saveBlock(blocks[$ - 1]);
    }

    // load
    Block[] loaded_blocks;
    loaded_blocks.length = count;
    foreach (idx; 0 .. count)
        loaded_blocks[idx] = storage.readBlock(Height(idx));

    // compare
    assert(equal(blocks, loaded_blocks));

    // test of random access
    import std.random;
    import std.range;

    auto rnd = rndGen;

    foreach (height; iota(count).randomCover(rnd))
    {
        auto random_block = storage.readBlock(Height(height));
        assert(random_block.header.height == height);
    }

    foreach (idx; iota(count).randomCover(rnd))
    {
        auto random_block = storage.readBlock(block_hashes[idx]);
        assert(hashFull(random_block.header) == block_hashes[idx]);
    }

    storage.release();

    //  Verify index data that is already stored.
    BlockStorage other = new BlockStorage(path);
    other.load(GenesisBlock);

    foreach (height; iota(count).randomCover(rnd))
    {
        auto random_block = other.readBlock(Height(height));
        assert(random_block.header.height == height);
    }

    foreach (idx; iota(count).randomCover(rnd))
    {
        auto random_block = other.readBlock(block_hashes[idx]);
        assert(hashFull(random_block.header) == block_hashes[idx]);
    }

    other.release();
}
