/*******************************************************************************

    Defines the memory mapped file of a block.

    The file is divided into multiple parts.
    The number of blocks in a file is fixed.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.BlockStorage;

import agora.common.Amount;
import agora.common.Block;
import agora.common.Deserializer;
import agora.common.Serializer;

import std.algorithm.comparison;
import std.file;
import std.format;
import std.mmfile;
import std.path;


/// The size of header
const MFILE_HEAD_SIZE = size_t.sizeof;

/// The maximum number of block in one file
const MFILE_MAX_BLOCK = 100;

/// The map file size
const MFILE_MAP_SIZE = 640 * 1024;


/// Ditto
public class BlockStorage
{
    /// Instance of memory mapped file
    private MmFile file;

    /// Path of block data
    private string path;

    /// Index of current file
    private size_t file_index;

    /// Index is block height, Value is position of file
    /// We will change to index file in the next step.
    private size_t[] block_positions;

    /// The size of data. Exclude the size of the header and the reserved size
    private size_t data_size;

    /// Ctor
    public this (string path)
    {
        this.path = path;
        this.file_index =
            max(0, this.block_positions.length-1) / MFILE_MAX_BLOCK;
        this.data_size = 0;
    }

    /***************************************************************************

        Make a file name using the index.

        Params:
            index = the index of the file.

        Returns:
            Returns the file name.

    ***************************************************************************/

    private string getFileName (size_t index)
    {
        return buildPath(this.path, format("B%012d.dat", index));
    }

    /***************************************************************************

        Open memory mapped file.

        If it was mapping the same file, just return.
        If it was mapping the other file, close previously mapped file.
        If a size change occurs, open it again.

        Params:
            findex = the index of the file.

    ***************************************************************************/

    public void map (size_t findex)
    {
        // It's already mapped,
        if ((this.file !is null) && (findex == this.file_index))
            return;

        if (this.file !is null)
            this.unMap();

        this.file_index = findex;

        this.file =
            new MmFile(
                this.getFileName(this.file_index),
                MmFile.Mode.readWrite,
                MFILE_MAP_SIZE,
                null
            );
        this.data_size = this.readDataLength();
    }

    /***************************************************************************

        Close memory mapped file.

    ***************************************************************************/

    public void unMap ()
    {
        if (this.file is null)
            return;
        import core.memory : GC;

        destroy(this.file);
        GC.free(&this.file);
        this.file = null;
    }

    /***************************************************************************

        Save block to the file.

        Params:
            block = `Block` to save

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public bool saveBlock (const ref Block block)
    {
        if (block.header.height != this.block_positions.length)
            return false;

        const ubyte[] serialized_block = serializeFull(block);

        const size_t fidx = block.header.height / MFILE_MAX_BLOCK;
        const size_t bidx = block.header.height % MFILE_MAX_BLOCK;
        size_t pos;

        this.map(fidx);

        // first in this file
        if (bidx == 0)
        {
            pos = 0;
            // resize to serialized_block.length
            this.data_size = serialized_block.length + size_t.sizeof;
            this.writeDataLength(this.data_size);
        }
        else
        {
            pos = this.data_size;
            // increase size by serialized_block.length
            this.data_size += serialized_block.length + size_t.sizeof;
            this.writeDataLength(this.data_size);
        }

        // add information to the look up table.
        this.block_positions ~= (MFILE_MAP_SIZE * fidx + pos);

        this.writeSizeT(MFILE_HEAD_SIZE + pos, serialized_block.length);

        // write to memory
        size_t b = MFILE_HEAD_SIZE + pos + size_t.sizeof;
        foreach (idx, ref e; serialized_block)
            this.file[b + idx] = e;

        return true;
    }

    /***************************************************************************

        Read block from the file.

        Params:
            block = `Block` to read
            height = height of `Block`

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public bool readBlock (ref Block block, size_t height)
    {
        if (height >= this.block_positions.length)
            return false;

        const size_t fidx = height / MFILE_MAX_BLOCK;
        this.map(fidx);

        const size_t x0 = this.block_positions[height] - fidx * MFILE_MAP_SIZE;
        const size_t block_size = this.readSizeT(MFILE_HEAD_SIZE + x0);

        assert(x0 < this.data_size);

        const size_t x2 = x0 + MFILE_HEAD_SIZE + size_t.sizeof;
        const size_t x3 = x2 + block_size;

        block = deserialize!Block(cast(ubyte[])this.file[x2 .. x3]);

        return true;
    }

    /***************************************************************************

        Write data length to file header

        Params:
            length = The size of data

    ***************************************************************************/

    private void writeDataLength (size_t length)
    {
        this.writeSizeT(0, length);
    }

    /***************************************************************************

        Read data length to file header

        Returns:
            The size of data in file header

    ***************************************************************************/

    private size_t readDataLength ()
    {
        return this.readSizeT(0);
    }

    /***************************************************************************

        Read type of `size_t` data

        Params:
            pos = position of memory mapped file
            value = type of `size_t`

    ***************************************************************************/

    private void writeSizeT (size_t pos, size_t value)
    {
        foreach (idx, e; (cast(const ubyte*)&value)[0 .. size_t.sizeof])
            this.file[pos+idx] = e;
    }

    /***************************************************************************

        Read type of `size_t` data

        Params:
            pos = position of memory mapped file

        Returns:
            type of `size_t`

    ***************************************************************************/

    private size_t readSizeT (size_t pos)
    {
        ubyte[] values = cast(ubyte[])this.file[pos .. pos + size_t.sizeof];
        return *cast(size_t*)&(values[0]);
    }
}

/// Create and store 1000 blocks and read again. And read 100 random.
version(none) unittest
{
    import agora.common.crypto.Key;
    import agora.common.Data;
    import agora.common.Hash;
    import agora.common.Transaction;
    import agora.consensus.Genesis;

    import std.algorithm.comparison;

    string path = buildPath(getcwd, ".cache");
    if (!path.exists)
        mkdir(path);

    BlockStorage storage = new BlockStorage(path);

    KeyPair[] key_pairs = [
        KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random,
        KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random
    ];
    Block[] blocks;

    blocks ~= getGenesisBlock();
    storage.saveBlock(blocks[$ - 1]);

    auto gen_key_pair = getGenesisKeyPair();
    Transaction last_tx = blocks[$ - 1].txs[$-1];
    Hash gen_tx_hash = hashFull(last_tx);

    Transaction tx;

    // save
    foreach (idx; 1 .. 300)
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
        storage.saveBlock(blocks[$ - 1]);
    }

    // load
    Block[] loaded_blocks;
    loaded_blocks.length = 300;
    foreach (idx; 0 .. 300)
        storage.readBlock(loaded_blocks[idx], idx);

    // compare
    assert(equal(blocks, loaded_blocks));

    // checks data file
    foreach (idx; 0 .. 3)
        assert(storage.getFileName(idx).exists);

    // test of random access
    import std.random;
    import std.range;

    auto rnd = rndGen;

    Block random_block;
    foreach (height; iota(100).randomCover(rnd))
    {
        storage.readBlock(random_block, height);
        assert(random_block.header.height == height);
    }

    storage.unMap();

    foreach (idx; 0 .. 3)
        storage.getFileName(idx).remove();
}
