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

import vibe.core.log;

import std.algorithm;
import std.container.rbtree;
import std.exception;
import std.file;
import std.format;
import std.mmfile;
import std.path;
import std.stdio;


/// The size of header
const MFILE_HEAD_SIZE = size_t.sizeof;

/// Amount of reserved size
const MFILE_RESERVE_SIZE = 64 * 1024;

/// The maximum number of block in one file
const MFILE_MAX_BLOCK = 100;

/// The map file size
const MFILE_MAP_SIZE = 640 * 1024;

private struct HeightPosition
{
    size_t              height;
    size_t              position;
}

private struct HashPosition
{
    ubyte[Hash.sizeof]  hash;
    size_t              position;
}

/// Type of RBTree used for height indexing
private alias IndexHeight = RedBlackTree!(HeightPosition, "(a.height < b.height)");
/// Type of RBTree used for hash indexing
private alias IndexHash = RedBlackTree!(HashPosition, "(a.hash < b.hash)");

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

        this.loadAllIndexes();
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
            resize = The size of the file to change. If 0 does not change it.

    ***************************************************************************/

    private void map (size_t findex, size_t resize = 0) @trusted
    {
        // It's already mapped,
        if ((this.file !is null) && (findex == this.file_index))
        {
            // if it doesn't change its size
            if (resize == 0)
                return;

            // if can use reserved memory
            if ((this.data_size < resize) &&
                (MFILE_HEAD_SIZE + resize < this.getFileLength()))
            {
                this.writeDataLength(resize);
                this.data_size = resize;
                return;
            }
        }

        if (this.file !is null)
            this.unMap();

        this.file_index = findex;
        const string name = this.getFileName(this.file_index);

        if (resize != 0)
        {
            this.file =
                new MmFile(
                    name,
                    MmFile.Mode.readWrite,
                    resize + MFILE_HEAD_SIZE + MFILE_RESERVE_SIZE,
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
        }
    }

    /***************************************************************************

        Close memory mapped file.

    ***************************************************************************/

    private void unMap () @trusted
    {
        if (this.file is null)
            return;
        import core.memory : GC;

        destroy(this.file);
        GC.free(&this.file);
        this.file = null;
    }

    /***************************************************************************

        Release memory mapped file.

    ***************************************************************************/

    public void release () @safe
    {
        this.unMap();
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

        // first in this file
        if (bidx == 0)
        {
            pos = 0;
            // resize to serialized_block.length
            size_t size = serialized_block.length + size_t.sizeof;
            this.map(fidx, size);
        }
        else
        {
            this.map(fidx);
            pos = this.data_size;
            // increase size by serialized_block.length
            size_t size = serialized_block.length + size_t.sizeof;
            this.map(fidx, this.data_size + size);
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
        ubyte[Hash.sizeof] hash_bytes = hashFull(block.header)[];
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

        this.saveIndex(block.header.height, hash_bytes, block_position);

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
        ubyte[Hash.sizeof] hash_bytes = hash[];

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

    /***************************************************************************

        Store index data for one block in the file.

        Params:
            height = height of `Block`
            hash = hash of `Block`
            pos = position of memory mapped file

        Returns:
            Returns size of file if is mapped, or 0 if is not mapped

    ***************************************************************************/

    private void saveIndex (
        size_t height,
        ubyte[Hash.sizeof] hash,
        size_t pos) @safe
    {
        File idx_file;
        string file_name = buildPath(this.path, "index.dat");

        try
        {
            idx_file = File(file_name, "a+b");
            idx_file.seek(0, SEEK_END);

            idx_file.writeSizeType(height);
            idx_file.rawWrite(hash);
            idx_file.writeSizeType(pos);

            idx_file.close();
        }
        catch (Exception ex)
        {
            logError("saveIndex: %s",
                () @trusted { return ex.message; }());
        }
    }

    /***************************************************************************

        Read the index data stored in the index file.

    ***************************************************************************/

    private void loadAllIndexes () @safe
    {
        File idx_file;

        size_t height;
        ubyte[Hash.sizeof] hash;
        size_t pos;
        string file_name = buildPath(this.path, "index.dat");

        this.height_idx.clear();
        this.hash_idx.clear();

        if (file_name.exists)
        {
            try
            {
                idx_file = File(file_name, "rb");

                size_t record_size = (size_t.sizeof * 2 + Hash.sizeof);
                size_t record_count = idx_file.size / record_size;
                foreach (idx; 0 .. record_count)
                {
                    height = idx_file.readSizeType();

                    idx_file.rawRead(hash);

                    pos = idx_file.readSizeType();

                    // add to index of heigth
                    this.height_idx.insert(HeightPosition(height, pos));

                    // add to index of hash
                    this.hash_idx.insert(HashPosition(hash, pos));
                }

                idx_file.close();
            }
            catch (Exception ex)
            {
                logError("loadAllIndexes: %s",
                    () @trusted { return ex.message; }());
            }
        }
    }

    /***************************************************************************

        Remove the index file.

    ***************************************************************************/

    public static void removeIndexFile (string path)
    {
        string name = buildPath(path, "index.dat");
        if (name.exists)
            name.remove();
    }
}

/*******************************************************************************

    Write type of `size_t` data to file

    Params:
        file = `File`
        value = Value to write to file

*******************************************************************************/

public void writeSizeType (File file, size_t value) @trusted
{
    file.rawWrite((cast(const ubyte*)&value)[0 .. size_t.sizeof]);
}

/*******************************************************************************

    Read type of `size_t` data for file

    Params:
        file = `File`

    Returns:
        type of `size_t`

*******************************************************************************/

public size_t readSizeType (File file) @trusted
{
    ubyte[size_t.sizeof] buffer;
    file.rawRead(buffer);
    return *cast(size_t*)&(buffer[0]);
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


    const size_t count = 300;

    string path = buildPath(getcwd, ".cache");
    if (!path.exists)
        mkdir(path);

    BlockStorage.removeIndexFile(path);
    BlockStorage storage = new BlockStorage(path);
    foreach (idx; 0 .. count / MFILE_MAX_BLOCK)
    {
        auto name = storage.getFileName(idx);
        if (name.exists) name.remove();
    }

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

    // checks data file
    foreach (idx; 0 .. count / MFILE_MAX_BLOCK)
        assert(storage.getFileName(idx).exists);

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
