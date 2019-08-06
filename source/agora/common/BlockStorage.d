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
import agora.common.Data;
import agora.common.Deserializer;
import agora.common.Hash;
import agora.common.Serializer;

import std.algorithm;
import std.container.rbtree;
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

const HASH_SIZE = 64;

private struct HeightPosition
{
    size_t              height;
    size_t              position;
}

private struct HashPosition
{
    ubyte[HASH_SIZE]    hash;
    size_t              position;
}

alias IndexHeight = RedBlackTree!(HeightPosition, "(a.height < b.height)");
alias IndexHash = RedBlackTree!(HashPosition, "(a.hash < b.hash)");

/// Ditto
public class BlockStorage
{
    /// Instance of memory mapped file
    private MmFile file;

    /// Path of block data
    private string path;

    /// Index of current file
    private size_t file_index;

    /// The size of data. Exclude the size of the header and the reserved size
    private size_t data_size;

    /// Index is block height
    private IndexHeight height_idx;

    /// Index is block hash
    private IndexHash hash_idx;

    /// Ctor
    public this (string path)
    {
        this.path = path;
        this.file_index = 0;
        this.data_size = 0;

        this.height_idx = new IndexHeight();
        this.hash_idx = new IndexHash();
    }

    /***************************************************************************

        Make a file name using the index.

        Params:
            index = the index of the file.

        Returns:
            Returns the file name.

    ***************************************************************************/

    private string getFileName (size_t index) @safe
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

    public void map (size_t findex) @trusted
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

    public void unMap () @trusted
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

    public bool saveBlock (const ref Block block) @safe
    {
        if ((this.height_idx.length > 0) &&
            (this.height_idx.back.height >= block.header.height))
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

        // add to index of heigth
        const size_t block_position = (MFILE_MAP_SIZE * fidx + pos);
        this.height_idx.insert(
            HeightPosition(
                block.header.height,
                block_position
            )
        );

        // add to index of hash
        ubyte[HASH_SIZE] hash_bytes = hashFull(block.header)[0..HASH_SIZE];
        this.hash_idx.insert(
            HashPosition(
                hash_bytes,
                block_position
            )
        );

        // write block data size
        this.writeSizeT(MFILE_HEAD_SIZE + pos, serialized_block.length);

        // write to memory
        this.write(MFILE_HEAD_SIZE + pos + size_t.sizeof, serialized_block);

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

    public bool readBlock (ref Block block, size_t height) @safe
    {
        if ((this.height_idx.length == 0) ||
            (this.height_idx.back.height < height))
            return false;

        auto finds
            = this.height_idx[].find!( (a, b) => a.height == b)(height);

        if (!finds.empty)
        {
            const size_t position = finds.front.position;

            this.map(position / MFILE_MAP_SIZE);

            const size_t x0 = position % MFILE_MAP_SIZE;
            const size_t block_size = this.readSizeT(MFILE_HEAD_SIZE + x0);

            assert(x0 < this.data_size);

            const size_t x2 = x0 + MFILE_HEAD_SIZE + size_t.sizeof;
            const size_t x3 = x2 + block_size;

            block = deserialize!Block(this.read(x2, x3));

            return true;
        }
        else
        {
            return false;
        }
    }

    /***************************************************************************

        Read block from the file.

        Params:
            block = `Block` to read
            hash = `Hash` of `Block`

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public bool readBlock (ref Block block, Hash hash) @safe
    {
        ubyte[HASH_SIZE] hash_bytes = hash[0..HASH_SIZE];

        auto finds
            = this.hash_idx[].find!((a, b) => a.hash == b)(hash_bytes);

        if (!finds.empty)
        {
            const size_t position = finds.front.position;

            this.map(position / MFILE_MAP_SIZE);

            const size_t x0 = position % MFILE_MAP_SIZE;
            const size_t block_size = this.readSizeT(MFILE_HEAD_SIZE + x0);

            assert(x0 < this.data_size);

            const size_t x2 = x0 + MFILE_HEAD_SIZE + size_t.sizeof;
            const size_t x3 = x2 + block_size;

            block = deserialize!Block(this.read(x2, x3));

            return true;
        }
        else
        {
            return false;
        }
    }

    /***************************************************************************

        Write data length to file header

        Params:
            length = The size of data

    ***************************************************************************/

    private void writeDataLength (size_t length) @safe
    {
        this.writeSizeT(0, length);
    }

    /***************************************************************************

        Read data length to file header

        Returns:
            The size of data in file header

    ***************************************************************************/

    private size_t readDataLength () @safe
    {
        return this.readSizeT(0);
    }

    /***************************************************************************

        Read type of `size_t` data

        Params:
            pos = position of memory mapped file
            value = type of `size_t`

    ***************************************************************************/

    private void writeSizeT (size_t pos, size_t value) @trusted
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

    private size_t readSizeT (size_t pos) @trusted
    {
        ubyte[] values = cast(ubyte[])this.file[pos .. pos + size_t.sizeof];
        return *cast(size_t*)&(values[0]);
    }

    /***************************************************************************

        Read data from the file.

        Params:
            from = Start position of range to read
            to   = End position of range to read

        Returns:
            Returns array of unsigned bytes read

    ***************************************************************************/

    private ubyte[] read (size_t from, size_t to) @trusted
    {
        assert(this.file !is null);
        assert(this.getFileLength >= to);

        return cast(ubyte[])this.file[from .. to];
    }

    /***************************************************************************

        Write data to the file.

        Params:
            pos  = Start position of range to write
            data = Array of unsigned bytes to be written to file

    ***************************************************************************/

    private void write (size_t pos, const ubyte[] data) @trusted
    {
        assert(this.file !is null);
        assert(this.getFileLength >= pos+data.length);

        foreach (idx, ref e; data)
            this.file[pos + idx] = e;
    }

    /***************************************************************************

        Get memory mapped file size

        Returns:
            Returns size of file if is mapped, or 0 if is not mapped

    ***************************************************************************/

    private size_t getFileLength () @trusted
    {
        if (this.file is null)
            return 0;

        return this.file.length;
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
    Hash[] block_hashes;

    blocks ~= getGenesisBlock();
    storage.saveBlock(blocks[$ - 1]);

    auto gen_key_pair = getGenesisKeyPair();
    Transaction last_tx = blocks[$ - 1].txs[$-1];
    Hash gen_tx_hash = hashFull(last_tx);
    block_hashes ~= hashFull(blocks[$ - 1].header);
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
        block_hashes ~= hashFull(blocks[$ - 1].header);
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
    foreach (height; iota(300).randomCover(rnd))
    {
        storage.readBlock(random_block, height);
        assert(random_block.header.height == height);
    }

    foreach (idx; iota(300).randomCover(rnd))
    {
        storage.readBlock(random_block, block_hashes[idx]);
        assert(hashFull(random_block.header) == block_hashes[idx]);
    }

    storage.unMap();

    foreach (idx; 0 .. 3)
        storage.getFileName(idx).remove();
}
