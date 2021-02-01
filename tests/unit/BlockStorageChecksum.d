/*******************************************************************************

    Contains checksum tests.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module unit.BlockStorageChecksum;

import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.consensus.data.genesis.Test;
import agora.node.BlockStorage;
import agora.utils.Test;

import std.file;
import std.exception;
import std.path;
import std.stdio;

/// blocks to write
const size_t BlockCount = 300;

///
private void main ()
{
    auto path = makeCleanTempDir();

    writeBlocks(path);
    corruptBlocks(path);

    BlockStorage storage = new BlockStorage(path);
    scope (exit) storage.release();

    // Checksum detection test
    assertThrown!Exception(storage.readBlock(Height(0)));
}

/// Write the block data to disk
private void writeBlocks (string path)
{
    BlockStorage.removeIndexFile(path);
    BlockStorage storage = new BlockStorage(path);

    const(Block)[] blocks;
    blocks ~= GenesisBlock;

    foreach (block_idx; 0 .. BlockCount)
    {
        Transaction[8] txs;
        auto block = makeNewBlock(blocks[$ - 1], txs[], blocks[$ - 1].header.timestamp + 1, null, Hash.init, null);
        storage.saveBlock(block);
        blocks ~= block;
    }

    storage.release();
}

/// Corrupt the block data on disk
private void corruptBlocks (string dir_path)
{
    foreach (string path; dirEntries(dir_path, SpanMode.shallow))
    {
        assert(path.isFile);

        auto block_file = File(path, "r+b");
        block_file.seek(ChecksumSize + 1, SEEK_SET);

        ubyte[1] bytes;
        block_file.rawRead(bytes);

        // write a modified byte
        bytes[0]++;
        block_file.seek(ChecksumSize + 1, SEEK_SET);
        block_file.rawWrite(bytes);
    }
}
