/*******************************************************************************

    Define the storage for blocks

    The file is divided into multiple parts.
    The number of blocks in a file is fixed.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.BlockStorage;

import agora.common.Amount;
import agora.common.Data;
import agora.common.Deserializer;
import agora.common.Hash;
import agora.common.Serializer;
import agora.consensus.data.Block;
import agora.consensus.Genesis;

import std.algorithm;
import std.container.rbtree;
import std.digest.crc;
import std.exception;
import std.file;
import std.format;
import std.mmfile;
import std.path;
import std.stdio;

/*******************************************************************************

    Define the storage for blocks

*******************************************************************************/

public interface IBlockStorage
{
    @safe nothrow:

    /***************************************************************************

        Load the block storage. If there was nothing to load,
        a Genesis block will be added to the ledger. In this case the calling
        code should treat the block as new and update the set of UTXOs, etc.

        Returns:
            `false` if the data couldn't be loaded, `true` otherwise.

    ***************************************************************************/

    public bool load ();

    /***************************************************************************

        Read the last block from the storage.

        Params:
            block = The last block

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public bool readLastBlock (ref Block block);


    /***************************************************************************

        Save block to the storage.

        Params:
            block = `Block` to save

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public bool saveBlock (const ref Block block);


    /***************************************************************************

        Read block from the storage.

        Params:
            block = `Block` to read
            height = height of `Block`

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public bool readBlock (ref Block block, size_t height);


    /***************************************************************************

        Read block from the storage.

        Params:
            block = `Block` to read
            hash = `Hash` of `Block`

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public bool readBlock (ref Block block, Hash hash);
}


/// The map file size
private immutable size_t MapSize = 640 * 1024;

/// The block data size
private immutable size_t DataSize = MapSize - ChecksumSize;

/// The CRC32 checksum size
private immutable size_t ChecksumSize = 4;

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

/*******************************************************************************

    Defines storage for Blocks using memory map file
    The file is divided into multiple parts.

*******************************************************************************/

public class BlockStorage : IBlockStorage
{
    /// Instance of memory mapped file
    private MmFile file;

    /// Path to the directory which contains the block files
    private string root_path;

    /// Index of current file
    private size_t file_index;

    /// Index is block height
    private IndexHeight height_idx;

    /// Index is block hash
    private IndexHash hash_idx;

    /// Size of Block Data
    private size_t length;

    /// Base Position of current file
    private size_t file_base;

    /// Saving current block
    private bool is_saving;

    /// Pre-allocated constant file path
    private immutable string index_path;

    /***************************************************************************

        Construct an instance of a `BlockStorage`

        Params:
            path = Path to the directory where the block files are stored

        Note:
            The object is not usable after construction.
            This is to keep the constructor simple and free of side effect / IO.
            The `load` method needs to be called to load the indexes.

    ***************************************************************************/

    public this (string path) nothrow @safe pure
    {
        this.root_path = path;
        this.file_index = ulong.max;
        this.length = ulong.max;
        this.is_saving = false;

        this.index_path = buildPath(this.root_path, "index.dat");

        this.height_idx = new IndexHeight();
        this.hash_idx = new IndexHash();
    }

    /***************************************************************************

        Load the blockchain from the storage

        Performs loading of the index and the last batch of blocks from disk.

        Returns:
            `false` when it fails to load.

    ***************************************************************************/

    public override bool load () @safe nothrow
    {
        try if (!this.root_path.exists)
            mkdirRecurse(this.root_path);
        catch (Exception e)
            return false;

        if (!this.loadAllIndexes())
            return false;

        // Add Genesis if the storage is empty
        if (this.height_idx.length == 0)
        {
            if (!this.saveBlock(GenesisBlock))
                return false;
        }
        return true;
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
        return buildPath(this.root_path, format("B%012d.dat", index));
    }

    /***************************************************************************

        Read the last block from the storage.

        Params:
            block = will contain the block if the read was successful

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public override bool readLastBlock (ref Block block) @safe nothrow
    {
        if (this.height_idx.length == 0)
            return false;

        return this.readBlock(block, this.height_idx.back.height);
    }

    /***************************************************************************

        Open memory mapped file.

        If it was mapping the same file, just return.
        If it was mapping the other file, close previously mapped file.

        Params:
            findex = the index of the file.

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    private bool map (size_t findex) @trusted nothrow
    {
        try {
            if (this.file !is null)
            {
                if (findex == this.file_index)
                    return true;

                if (this.is_saving && !this.writeChecksum())
                    assert(0);

                this.release();
            }

            this.file_index = findex;
            const file_name = this.getFileName(this.file_index);
            bool file_exist = std.file.exists(file_name);

            this.file =
                new MmFile(
                    file_name,
                    MmFile.Mode.readWrite,
                    MapSize,
                    null
                );

            this.file_base = DataSize * this.file_index;
            if (file_exist)
                this.validateChecksum();

            return true;
        }
        catch (Exception ex)
        {
            this.writeLog("BlockStorage.map: ", ex);
            return false;
        }
    }

    /***************************************************************************

        Release memory mapped file.

    ***************************************************************************/

    public void release () @trusted
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

    public override bool saveBlock (const ref Block block) @safe nothrow
    {
        try
        {
            if ((this.height_idx.length > 0) &&
                (this.height_idx.back.height >= block.header.height))
                return false;

            size_t last_pos, last_size, block_position, data_position;
            if (this.length == ulong.max)
            {
                if (this.height_idx.length > 0)
                {
                    last_pos = this.height_idx.back.position;

                    if (!this.readSizeT(last_pos, last_size))
                        return false;

                    this.length = last_pos + size_t.sizeof + last_size;
                }
                else
                {
                    last_pos = 0;
                    last_size = 0;
                    this.length = 0;
                }
            }

            block_position = this.length;
            data_position = block_position + size_t.sizeof;

            this.is_saving = true;
            scope(exit) this.is_saving = false;
            size_t block_size = 0;
            scope SerializeDg dg = (scope const(ubyte[]) data) nothrow @safe
            {
                // write to memory
                if (!this.write(data_position + block_size, data))
                    assert(0);

                block_size += data.length;
            };
            serializePart(block, dg);

            // write block data size
            if (!this.writeSizeT(block_position, block_size))
                return false;

            this.length += size_t.sizeof + block_size;

            if (!this.writeChecksum())
                assert(0);

            // add to index of heigth
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

            if (!this.saveIndex(block.header.height, hash_bytes, block_position))
                return false;

            return true;
        }
        catch (Exception ex)
        {
            this.writeLog("BlockStorage.saveBlock: ", ex);
            return false;
        }
    }

    /***************************************************************************

        Read block from the file.

        Params:
            block = `Block` to read
            height = height of `Block`

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public override bool readBlock (ref Block block, size_t height) @safe nothrow
    {
        if ((this.height_idx.length == 0) ||
            (this.height_idx.back.height < height))
            return false;

        auto finds
            = this.height_idx[].find!( (a, b) => a.height == b)(height);

        if (finds.empty)
            return false;

        try
        {
            this.readBlockAtPosition(block, finds.front.position);
            return true;
        }
        catch (Exception ex)
        {
            this.writeLog("BlockStorage.readBlock: ", ex);
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

    public override bool readBlock (ref Block block, Hash hash) @safe nothrow
    {
        ubyte[Hash.sizeof] hash_bytes = hash[];

        auto finds
            = this.hash_idx[].find!((a, b) => a.hash == b)(hash_bytes);

        if (finds.empty)
            return false;

        try
        {
            this.readBlockAtPosition(block, finds.front.position);
            return true;
        }
        catch (Exception ex)
        {
            this.writeLog("BlockStorage.readBlock: ", ex);
            return false;
        }
    }

    /// Ditto
    private void readBlockAtPosition (ref Block block, size_t position) @safe
    {
        size_t pos = position + size_t.sizeof;
        scope DeserializeDg dg = (size) nothrow @safe
        {
            ubyte[] res;
            if (!this.read(pos, pos + size, res))
                assert(0);
            pos += size;
            return res;
        };
        block.deserialize(dg);
    }

    /***************************************************************************

        Read type of `size_t` data

        Params:
            pos = position of memory mapped file
            value = type of `size_t`

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    private bool writeSizeT (size_t pos, size_t value) @trusted nothrow
    {
        foreach (idx, e; (cast(const ubyte*)&value)[0 .. size_t.sizeof])
            if (!this.writeByte(pos + idx, e))
                return false;
        return true;
    }

    /***************************************************************************

        Read type of `size_t` data

        Params:
            pos = position of memory mapped file
            value = type of `size_t`

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    private bool readSizeT (size_t pos, ref size_t value) @trusted nothrow
    {
        ubyte[] data;
        if (!this.read(pos, pos+size_t.sizeof, data))
            return false;

        value = *cast(size_t*)(data.ptr);
        return true;
    }

    /***************************************************************************

        Read data from the file.

        Params:
            from = Start position of range to read
            to   = End position of range to read
            data = Array of unsigned bytes read

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    private bool read (size_t from, size_t to, ref ubyte[] data)
        @trusted nothrow
    {
        if (
            (this.file !is null) &&
            (from / DataSize == this.file_index) &&
            (to / DataSize == this.file_index))
        {
            try
            {
                const size_t x0 = from - this.file_base + ChecksumSize;
                const size_t x1 = to - this.file_base + ChecksumSize;
                data = cast(ubyte[])this.file[x0 .. x1];
                return true;
            }
            catch (Exception ex)
            {
                this.writeLog("BlockStorage.read: ", ex);
                return false;
            }
        }
        else
        {
            data.length = to - from;
            foreach (idx; from .. to)
                if (!this.readByte(idx, data[idx-from]))
                    return false;
            return true;
        }
    }

    /***************************************************************************

        Write data to the file.

        Params:
            pos  = Start position of range to write
            data = Array of unsigned bytes to be written to file

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    private bool write (size_t pos, const ubyte[] data) @trusted nothrow
    {
        try
        {
            if (
                (this.file !is null) &&
                (pos / DataSize == this.file_index) &&
                ((pos + data.length) / DataSize == this.file_index))
            {
                const size_t x0 = pos - this.file_base + ChecksumSize;
                foreach (idx, e; data)
                    this.file[x0+idx] = e;
            }
            else
            {
                foreach (idx, e; data)
                    if (!this.writeByte(pos + idx, e))
                        return false;
            }
            return true;
        }
        catch (Exception ex)
        {
            this.writeLog("BlockStorage.write: ", ex);
            return false;
        }
    }

    /***************************************************************************

        Read unsigned byte to the file.

        Params:
            pos = Position to read
            data = Unsigned bytes read from file

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    private bool readByte (size_t pos, ref ubyte data) @trusted nothrow
    {
        try
        {
            if (!this.map(pos / DataSize))
                return false;

            data = this.file[pos - this.file_base + ChecksumSize];
            return true;
        }
        catch (Exception ex)
        {
            writeLog("BlockStorage.readBytes: ", ex);
            return false;
        }
    }

    /***************************************************************************

        Write unsigned byte to the file.

        Params:
            pos  = Start position of range to write
            data = Unsigned bytes to be written to file

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    private bool writeByte (size_t pos, ubyte data) @trusted nothrow
    {
        try
        {
            if (!this.map(pos / DataSize))
                return false;

            this.file[pos - this.file_base + ChecksumSize] = data;
            return true;
        }
        catch (Exception ex)
        {
            this.writeLog("BlockStorage.writeByte: ", ex);
            return false;
        }
    }

    /***************************************************************************

        Store index data for one block in the file.

        Params:
            height = height of `Block`
            hash = hash of `Block`
            pos = position of memory mapped file

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    private bool saveIndex (
        size_t height,
        ubyte[Hash.sizeof] hash,
        size_t pos) @safe nothrow
    {
        try
        {
            File idx_file = File(this.index_path, "a+b");
            idx_file.seek(0, SEEK_END);

            serializePart(height, (scope v) => idx_file.rawWrite(v));
            idx_file.rawWrite(hash);
            serializePart(pos, (scope v) => idx_file.rawWrite(v));

            idx_file.close();

            return true;
        }
        catch (Exception ex)
        {
            this.writeLog("BlockStorage.saveIndex: ", ex);
            return false;
        }
    }

    /***************************************************************************

        Read the index data stored in the index file.

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    private bool loadAllIndexes () @safe nothrow
    {
        try
        {
            size_t height;
            ubyte[Hash.sizeof] hash;
            size_t pos;

            this.height_idx.clear();
            this.hash_idx.clear();

            if (!this.index_path.exists)
                return true;

            File idx_file = File(this.index_path, "rb");

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
            return true;
        }
        catch (Exception ex)
        {
            this.writeLog("BlockStorage.loadAllIndexes: ", ex);
            return false;
        }
    }

    /***************************************************************************

        Remove the index file.

        Params:
            path = path to the data directory

    ***************************************************************************/

    public static void removeIndexFile (string path)
    {
        string name = buildPath(path, "index.dat");
        if (name.exists)
            name.remove();
    }

    /***************************************************************************

        Write error message

        Params:
            func = function name
            ex = Instance of `Exception`

    ***************************************************************************/

    private void writeLog (string func, Exception ex) @trusted nothrow
    {
        scope (failure) assert(0);
        stderr.writeln(func, ex.message);
    }

    /*******************************************************************************

        Calculate the checksum of the provided data

        Params:
            data = the data to calculate the checksum of

        Returns:
            the checksum bytes

    *******************************************************************************/

    private static ubyte[] makeChecksum (const ubyte[] data) @safe nothrow
    out(result)
    {
        assert(result.length + DataSize <= MapSize,
            "Checksum size is too large to fit in the map");
    }
    body
    {
        assert(data.length < 1 << 20,
            "Data length for checksum should not exceed 1MB");

        scope crc32 = new CRC32Digest();
        crc32.put(data);
        static ubyte[4] buffer;
        return () @trusted { return crc32.finish(buffer); }();
    }

    /*******************************************************************************

        Validate the checksum in the memory-mapped blocks.
        If validation fails, it throws an AssertError.

    *******************************************************************************/

    private void validateChecksum () @trusted
    {
        try
        {
            auto file_name = this.getFileName(this.file_index);
            const ubyte[] actual = cast(ubyte[])this.file[0 .. ChecksumSize];
            const ubyte[] data = cast(ubyte[])this.file[ChecksumSize .. MapSize];
            const expected = makeChecksum(data);
            if (actual != expected)
            {
                stderr.writefln("[ERROR] %s Block file is corrupt.", file_name);
                assert(0);
            }
        }
        catch (Exception ex)
        {
            this.writeLog("BlockStorage.validateChecksum: ", ex);
            assert(0);
        }
    }

    /*******************************************************************************

        Read the file data, calculate checksum,
        and write checksum to file at start point

        Returns:
            true if the checksum was successful

    *******************************************************************************/

    private bool writeChecksum () @trusted nothrow
    {
        try
        {
            const ubyte[] checksum = makeChecksum(
                cast(ubyte[])this.file[ChecksumSize .. MapSize]);

            foreach (idx, val; checksum)
                this.file[idx] = val;

            return true;
        }
        catch (Exception ex)
        {
            this.writeLog("BlockStorage.writeChecksum: ", ex);
            return false;
        }
    }
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


/*******************************************************************************

    Define the memory storage for blocks

    Implemented using only memory without file IO.

*******************************************************************************/

public class MemBlockStorage : IBlockStorage
{
    /// Storage for all the blocks
    private ubyte[][] blocks;

    /// Index is block height
    private IndexHeight height_idx;

    /// Index is block hash
    private IndexHash hash_idx;

    /// Ctor
    public this ()
    {
        this.height_idx = new IndexHeight();
        this.hash_idx = new IndexHash();
        this.saveBlock(GenesisBlock);
    }

    /// No-op: MemBlockStorage does no I/O
    public override bool load () { return true; }

    /***************************************************************************

        Read the last block from array.

        Params:
            block = will contain the block if the read was successful

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public bool readLastBlock (ref Block block) @safe nothrow
    {
        if (this.height_idx.length == 0)
            return false;

        return this.readBlock(block, this.height_idx.back.height);
    }

    /***************************************************************************

        Save block to array.

        Params:
            block = `Block` to save

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public bool saveBlock (const ref Block block) @safe nothrow
    {
        scope (failure) assert(0);

        if (this.blocks.length != block.header.height)
            return false;

        size_t block_position = this.blocks.length;

        this.blocks ~= serializeFull!Block(block);

        // add to index of heigth
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
        return true;
    }

    /***************************************************************************

        Read block from array.

        Params:
            block = `Block` to read
            height = height of `Block`

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public bool readBlock (ref Block block, size_t height) @safe nothrow
    {
        if ((this.height_idx.length == 0) ||
            (this.height_idx.back.height < height))
            return false;

        auto finds
            = this.height_idx[].find!( (a, b) => a.height == b)(height);

        if (finds.empty)
            return false;

        block = deserialize!Block(this.blocks[finds.front.position]);
        return true;
    }

    /***************************************************************************

        Read block from array.

        Params:
            block = `Block` to read
            hash = `Hash` of `Block`

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public bool readBlock (ref Block block, Hash hash) @safe nothrow
    {
        ubyte[Hash.sizeof] hash_bytes = hash[];

        auto finds
            = this.hash_idx[].find!((a, b) => a.hash == b)(hash_bytes);

        if (finds.empty)
            return false;

        block = deserialize!Block(this.blocks[finds.front.position]);
        return true;
    }

    /***************************************************************************

        Write error message

        Params:
            func = function name
            ex = Instance of `Exception`

    ***************************************************************************/

    private void writeLog (string func, Exception ex) @trusted nothrow
    {
        scope (failure) assert(0);
        stderr.writeln(func, ex.message);
    }
}


///
unittest
{
    import agora.common.crypto.Key;
    import agora.consensus.data.Transaction;
    import agora.consensus.Genesis;
    import std.algorithm.comparison;

    const size_t BlockCount = 50;
    MemBlockStorage storage = new MemBlockStorage();

    const(Block)[] blocks;
    Hash[] block_hashes;

    auto gen_key_pair = getGenesisKeyPair();
    blocks ~= GenesisBlock;
    storage.saveBlock(GenesisBlock);
    block_hashes ~= hashFull(GenesisBlock.header);
    Transaction[] last_txs;

    void genBlocks (size_t count)
    {
        while (--count)
        {
            auto txs = makeChainedTransactions(gen_key_pair, last_txs, 1);
            auto block = makeNewBlock(blocks[$ - 1], txs);
            last_txs = txs;

            blocks ~= block;
            block_hashes ~= hashFull(block.header);
            storage.saveBlock(block);
        }
    }

    genBlocks(BlockCount);

    // load
    Block[] loaded_blocks;
    loaded_blocks.length = BlockCount;
    foreach (idx; 0 .. BlockCount)
        storage.readBlock(loaded_blocks[idx], idx);

    // compare
    assert(equal(blocks, loaded_blocks));

    // test of random access
    import std.random;
    import std.range;

    auto rnd = rndGen;

    Block random_block;
    foreach (height; iota(BlockCount).randomCover(rnd))
    {
        storage.readBlock(random_block, height);
        assert(random_block.header.height == height);
    }

    foreach (idx; iota(BlockCount).randomCover(rnd))
    {
        storage.readBlock(random_block, block_hashes[idx]);
        assert(hashFull(random_block.header) == block_hashes[idx]);
    }
}
