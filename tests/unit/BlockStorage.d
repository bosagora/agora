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
import agora.common.Data;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.consensus.Genesis;
import agora.node.BlockStorage;

import std.algorithm.comparison;
import std.file;
import std.path;

///
private void main ()
{
    const size_t count = 300;

    string path = buildPath(getcwd, ".cache");
    if (path.exists)
        rmdirRecurse(path);

    mkdir(path);

    BlockStorage.removeIndexFile(path);
    BlockStorage storage = new BlockStorage(path);

    KeyPair[] key_pairs = [
        KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random,
        KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random
    ];
    const(Block)[] blocks;
    Hash[] block_hashes;

    blocks ~= GenesisBlock;
    storage.saveBlock(blocks[$ - 1]);

    // We can use a random keypair because blocks are not validated
    auto gen_key_pair = KeyPair.random();
    const Transaction last_tx = blocks[$ - 1].txs[$-1];
    Hash gen_tx_hash = hashFull(last_tx);
    block_hashes ~= hashFull(blocks[$ - 1].header);
    Transaction tx;

    // save
    foreach (idx; 1 .. count)
    {
        tx = Transaction(
            [
                Input(gen_tx_hash, 0)
            ],
            [
                Output(Amount(1_000), key_pairs[idx % 8].address)
            ]
        );
        tx.inputs[0].signature = gen_key_pair.secret.sign(hashFull(tx)[]);
        blocks ~= makeNewBlock(blocks[$ - 1], [tx]);
        block_hashes ~= hashFull(blocks[$ - 1].header);
        storage.saveBlock(blocks[$ - 1]);
    }

    // load
    Block[] loaded_blocks;
    loaded_blocks.length = count;
    foreach (idx; 0 .. count)
        storage.readBlock(loaded_blocks[idx], idx);

    // compare
    assert(equal(blocks, loaded_blocks));

    // test of random access
    import std.random;
    import std.range;

    auto rnd = rndGen;

    Block random_block;
    foreach (height; iota(count).randomCover(rnd))
    {
        storage.readBlock(random_block, height);
        assert(random_block.header.height == height);
    }

    foreach (idx; iota(count).randomCover(rnd))
    {
        storage.readBlock(random_block, block_hashes[idx]);
        assert(hashFull(random_block.header) == block_hashes[idx]);
    }

    storage.release();

    //  Verify index data that is already stored.
    BlockStorage other = new BlockStorage(path);
    other.load();

    foreach (height; iota(count).randomCover(rnd))
    {
        other.readBlock(random_block, height);
        assert(random_block.header.height == height);
    }

    foreach (idx; iota(count).randomCover(rnd))
    {
        other.readBlock(random_block, block_hashes[idx]);
        assert(hashFull(random_block.header) == block_hashes[idx]);
    }

    other.release();
}
