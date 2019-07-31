/*******************************************************************************

    Defines the memory mapped file of a block.

    The number of files is one.
    We will expand to use multiple files in the next step.

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


const MFILE_HEAD_SIZE = size_t.sizeof;

const MFILE_RESERVE_SIZE = 128 * 1024;

/// Ditto
public class BlockStorage
{
    /// Instance of memory mapped file
    private MmFile file;

    /// Path of block data
    private string path;

    /// Index is block height, Value is position of file
    /// We will change to index file in the next step.
    private size_t[] block_positions;

    /// The size of data. Exclude the size of the header and the reserved size
    private size_t data_size;

    /// Ctor
    public this (string path)
    {
        this.path = path;

        this.data_size = 0;
    }

    /***************************************************************************

        Make a file name using the index.

        Returns:
            Returns the file name.

    ***************************************************************************/

    private string getFileName ()
    {
        return buildPath(this.path, "block_v2.dat");
    }

    /***************************************************************************

        Write data length to file header

        Params:
            length = The size of data

    ***************************************************************************/

    private void writeDataLength (size_t length)
    {
        foreach (idx, e; (cast(const ubyte*)&length)[0 .. size_t.sizeof])
            this.file[idx] = e;
    }

    /***************************************************************************

        Read data length to file header

        Returns:
            The size of data in file header

    ***************************************************************************/

    private size_t readDataLength ()
    {
        ubyte[] values = cast(ubyte[])this.file[0 .. MFILE_HEAD_SIZE];
        return *cast(size_t*)&(values[0]);
    }

    /***************************************************************************

        Open memory mapped file.

        If a size change occurs, open it again.

        Params:
            resize = The size of the file to change. If 0 does not change it.

    ***************************************************************************/

    private void map (size_t resize = 0)
    {
        // It's already mapped, and if it doesn't change its size
        if ((this.file !is null) && (resize == 0))
            return;

        // It's already mapped, and if can use reserved memory
        if ((this.file !is null) && (this.data_size < resize) &&
            (MFILE_HEAD_SIZE + resize < this.file.length))
        {
            this.writeDataLength(resize);
            this.data_size = resize;
            return;
        }

        if (this.file !is null)
            this.unMap();

        const string name = this.getFileName();

        if (resize != 0)
        {
            this.file =
                new MmFile(
                    name,
                    MmFile.Mode.readWrite,
                    resize + MFILE_HEAD_SIZE+MFILE_RESERVE_SIZE,
                    null
                );
            this.writeDataLength(resize);
            this.data_size = resize;
        }
        else
        {
            if (name.exists())
            {
                this.file =
                    new MmFile(
                        name,
                        MmFile.Mode.readWrite,
                        0,
                        null
                    );
                this.data_size = this.readDataLength();
            }
            else
            {
                this.file =
                    new MmFile(
                        name,
                        MmFile.Mode.readWrite,
                        max(MFILE_HEAD_SIZE+MFILE_RESERVE_SIZE, resize),
                        null
                    );
                this.writeDataLength(0);
                this.data_size = 0;
            }

            this.data_size = this.readDataLength();
        }
    }

    /***************************************************************************

        Close memory mapped file.

    ***************************************************************************/

    private void unMap ()
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

        const size_t bidx = block.header.height;
        size_t pos;

        // first in this file
        if (bidx == 0)
        {
            this.map();
            pos = 0;
            // resize to serialized_block.length
            this.map(serialized_block.length);
        }
        else
        {
            this.map();
            pos = this.data_size;
            // increase size by serialized_block.length
            this.map(this.data_size + serialized_block.length);
        }

        // add information to the look up table.
        this.block_positions ~= pos;

        // write to memory
        foreach (idx, ref e; serialized_block)
            this.file[MFILE_HEAD_SIZE + pos + idx] = e;

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

        const size_t next_height = height + 1;
        this.map();

        const size_t x0 = this.block_positions[height];
        size_t x1;

        if (next_height >= this.block_positions.length)
            x1 = this.data_size;
        else
            x1 = this.block_positions[next_height];

        assert(x0 < this.data_size);
        assert(x0 < x1);

        const size_t x2 = x0 + MFILE_HEAD_SIZE;
        const size_t x3 = x1 + MFILE_HEAD_SIZE;
        block = deserialize!Block(cast(ubyte[])this.file[x2 .. x3]);

        return true;
    }

    /***************************************************************************

        Remove data file

    ***************************************************************************/

    public void remove ()
    {
        if (this.file is null)
            return;

        auto name = this.getFileName();
        if (name.exists)
            name.remove();
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
    storage.remove();

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
    foreach (idx; 1 .. 100)
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
    loaded_blocks.length = 100;
    foreach (idx; 0 .. 100)
        storage.readBlock(loaded_blocks[idx], idx);

    // compare
    assert(equal(blocks, loaded_blocks));

    // checks data file
    assert(storage.getFileName().exists);

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

    destroy(storage);
}
