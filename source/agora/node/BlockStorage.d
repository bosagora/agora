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
import agora.common.Types;
import agora.common.Hash;
import agora.common.Serializer;
import agora.consensus.data.Block;
import agora.utils.Log;

import std.algorithm;
import std.array;
import std.container.rbtree;
import std.digest.crc;
import std.exception;
import std.file;
import std.format;
import std.mmfile;
import std.path;
import std.stdio;


mixin AddLogger!();

/*******************************************************************************

    Define the storage for blocks

*******************************************************************************/

public interface IBlockStorage
{
    @safe:

    /***************************************************************************

        Load and initialize the block storage

        If there was nothing to load, the provided `genesis` block will be added
        to the ledger. In this case the calling code should treat the block
        as new and update the set of UTXOs, etc.

        Params:
            genesis = In case the storage is empty, the genesis block to write
                      to it.

        Throws:
            If the data couldn't be loaded.

    ***************************************************************************/

    public void load (const ref Block genesis);

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

    public void saveBlock (const ref Block block);

    /***************************************************************************

        Update block in the storage with updated signature and bitfield for
        validator signers.

        Params:
            block = `Block` to save

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public bool updateBlockMultiSig (const ref Block block);


    /***************************************************************************

        Attempt to read a block at a specified height from the storage.

        Params:
            block = `Block` to read
            height = height of `Block`

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public bool tryReadBlock (ref Block block, Height height) nothrow;

    /***************************************************************************

        Attempt to read a block with a specified hash from the storage.

        Params:
            block = `Block` to read
            hash = `Hash` of `Block`

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public bool tryReadBlock (ref Block block, in Hash hash) nothrow;

    /***************************************************************************

        Read a block at a specified height from the storage

        Params:
            block = `Block` to read
            height = height of `Block`

        Throws:
            If the block cannot be read

    ***************************************************************************/

    public final void readBlock (ref Block block, Height height)
    {
        if (!this.tryReadBlock(block, height))
            throw new Exception(format("Reading block at height %s failed", height));
    }

    /***************************************************************************

        Read a block with a specified hash from the storage

        Params:
            block = `Block` to read
            hash = `Hash` of `Block`

        Throws:
            If the block cannot be read

    ***************************************************************************/

    public final void readBlock (ref Block block, in Hash hash)
    {
        if (!this.tryReadBlock(block, hash))
            throw new Exception(format("Reading block failed. Hash: %s", hash));
    }
}


/// The map file size
private immutable size_t MapSize = 640 * 1024;

/// The block data size
private immutable size_t DataSize = MapSize - ChecksumSize;

/// The CRC32 checksum size
public immutable size_t ChecksumSize = 4;

private struct HeightPosition
{
    Height              height;
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

/// Return the position of the block by the given height or return zero
private size_t findBlockPosition (IndexHeight self, Height height) @safe nothrow
{
    if (!self.length || self.back.height < height)
        return 0;

    auto finds = self[].find!((a, b) => a.height == b)(height);
    return finds.empty ? 0 : finds.front.position;
}

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

        Params:
            genesis = In case the storage is empty, the genesis block to write
                      to it.

        Throws:
            When it fails to load.

    ***************************************************************************/

    public override void load (const ref Block genesis) @safe
    {
        if (!this.root_path.exists)
            mkdirRecurse(this.root_path);
        this.loadAllIndexes();

        // Add Genesis if the storage is empty
        if (this.height_idx.length == 0)
            this.saveBlock(genesis);
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

        return this.tryReadBlock(block, this.height_idx.back.height);
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
                return this.validateChecksum();

            return true;
        }
        catch (Exception ex)
        {
            log.error("BlockStorage.map: {}", ex);
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

    public override void saveBlock (const ref Block block) @safe
    {
        if ((this.height_idx.length > 0) &&
            (this.height_idx.back.height >= block.header.height))
            throw new Exception("BlockStorage internals are inconsistent");

        size_t last_pos, last_size;
        if (this.length == ulong.max)
        {
            if (this.height_idx.length > 0)
            {
                last_pos = this.height_idx.back.position;

                if (!this.readSizeT(last_pos, last_size))
                    throw new Exception("BlockStorage: Failed to read a size_t");

                this.length = last_pos + size_t.sizeof + last_size;
            }
            else
            {
                last_pos = 0;
                last_size = 0;
                this.length = 0;
            }
        }

        const size_t block_position = this.length;
        const size_t data_position = block_position + size_t.sizeof;

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
            throw new Exception("BlockStorage: Failed to write a size_t");

        this.length += size_t.sizeof + block_size;

        if (!this.writeChecksum())
            throw new Exception("BlockStorage: Failed to write checksum");

        // add to index of height
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
            throw new Exception("Blockstorage: Failed to save the index");
    }

    /***************************************************************************

        Update block in the file.
        This is intended for updating the multi-sig header signature field
        The block size should be identical and this will not update unless it is

        Params:
            block = `Block` to save

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public override bool updateBlockMultiSig (const ref Block block) @safe nothrow
    {
        try
        {
            const size_t block_position = this.height_idx.findBlockPosition(block.header.height);
            if (block_position == 0)
                return false;
            Block original_block;
            if (!tryReadBlock(original_block, block.header.height))
                throw new Exception("original block could not be read from disk!");

            if (block.merkle_tree != original_block.merkle_tree)
                throw new Exception("block merkle_tree has changed!");

            ubyte[Hash.sizeof] original_hash_bytes = hashFull(original_block.header)[];
            ubyte[Hash.sizeof] hash_bytes = hashFull(block.header)[];

            // The block hash does not include the header signature and bitfield
            // So they should be the same
            if (original_hash_bytes != hash_bytes)
                throw new Exception("block hash has changed!");

            const size_t data_position = block_position + size_t.sizeof;

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
                throw new Exception("failed to write block data size");

            this.length += size_t.sizeof + block_size;

            if (!this.writeChecksum())
                assert(0);

            return true;
        }
        catch (Exception ex)
        {
            log.error("BlockStorage.updateBlockMultiSig: not updated : {}", ex);
            return false;
        }
    }

    /// See `BlockStorage.tryReadBlock(ref Block, size_t)`
    public override bool tryReadBlock (ref Block block, Height height) @safe nothrow
    {
        try
        {
            const block_pos = this.height_idx.findBlockPosition(height);
            if (height != 0 && block_pos == 0)
            {
                log.trace("BlockStorage.readBlock({}): Couldn't find block at this height", height);
                return false;
            }

            this.readBlockAtPosition(block, block_pos);
            return true;
        }
        catch (Exception ex)
        {
            log.trace("BlockStorage.readBlock({}): {}", height, ex);
            return false;
        }
    }

    /// See `BlockStorage.tryReadBlock(ref Block, Hash)`
    public override bool tryReadBlock (ref Block block, in Hash hash)
        @safe nothrow
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
            log.trace("BlockStorage.readBlock({}): {}", hash, ex);
            return false;
        }
    }

    /// Ditto
    private void readBlockAtPosition (ref Block block, size_t position) @safe
    {
        size_t pos = position + size_t.sizeof;
        scope DeserializeDg dg = (size) @safe
        {
            ubyte[] res = this.read(pos, size);
            pos += size;
            return res;
        };
        block = deserializeFull!Block(dg);
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
        try
        {
            ubyte[] data = this.read(pos, pos+size_t.sizeof);
            value = *cast(size_t*)(data.ptr);
            return true;
        }
        catch (Exception e)
            return false;
    }

    /***************************************************************************

        Read data from the file.

        Params:
            from   = Start position of range to read
            length = Amount of data to read

        Throws:
            `Exception` on error (e.g. IO) or if the position is out of bound.

        Returns:
            Data read, if successfull

    ***************************************************************************/

    private ubyte[] read (size_t from, size_t length) @trusted
    {
        // If the read is within the same file
        if (
            (this.file !is null) &&
            (from / DataSize == this.file_index) &&
            ((from + length) / DataSize == this.file_index))
        {
            const size_t x0 = from - this.file_base + ChecksumSize;
            const size_t x1 = x0 + length;
            return cast(ubyte[])this.file[x0 .. x1];
        }
        else
        {
            // Otherwise we're slow as we have to read accross files
            ubyte[] data = new ubyte[](length);
            foreach (idx, ref b; data)
            {
                const size_t pos = (from + idx);
                if (!this.map(pos / DataSize))
                    throw new Exception(format("Unabled to map data at position %d", pos));
                b = this.file[pos - this.file_base + ChecksumSize];
            }
            return data;
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
            log.error("BlockStorage.write: {}", ex);
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
            log.error("BlockStorage.writeByte({}): {}", pos, ex);
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
        Height height,
        ubyte[Hash.sizeof] hash,
        size_t pos) @safe nothrow
    {
        try
        {
            File idx_file = File(this.index_path, "a+b");
            idx_file.seek(0, SEEK_END);

            serializePart(height, (scope v) @trusted => idx_file.rawWrite(v),
                CompactMode.No);
            () @trusted { idx_file.rawWrite(hash); }();
            serializePart(pos, (scope v) @trusted => idx_file.rawWrite(v),
                CompactMode.No);

            idx_file.close();

            return true;
        }
        catch (Exception ex)
        {
            log.error("BlockStorage.saveIndex(height:{}, pos:{}): {}",
                      height, pos, ex);
            return false;
        }
    }

    /***************************************************************************

        Read the index data stored in the index file.

        If the data file does not exists, this function will simply clear
        the indexes.

        Throws:
            In case of IO or deserialization error

    ***************************************************************************/

    private void loadAllIndexes () @safe
    {
        this.height_idx.clear();
        this.hash_idx.clear();

        if (!this.index_path.exists)
            return;

        File idx_file = File(this.index_path, "rb");
        scope (exit) idx_file.close();

        size_t record_size = (size_t.sizeof * 2 + Hash.sizeof);
        size_t record_count = idx_file.size / record_size;

        scope DeserializeDg dg = (size) @trusted
        {
            ubyte[] res;
            res.length = size;
            idx_file.rawRead(res);
            return res;
        };

        Height height;
        size_t pos;
        ubyte[Hash.sizeof] hash;
        const DeserializerOptions opts = { compact: CompactMode.No };
        foreach (idx; 0 .. record_count)
        {
            height = deserializeFull!Height(dg, opts);
            () @trusted { idx_file.rawRead(hash); }();
            pos    = deserializeFull!size_t(dg, opts);
            // add to index of heigth
            this.height_idx.insert(HeightPosition(height, pos));
            // add to index of hash
            this.hash_idx.insert(HashPosition(hash, pos));
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

    /*******************************************************************************

        Calculate the checksum of the provided data

        Params:
            data = the data to calculate the checksum of

        Returns:
            the checksum bytes

    *******************************************************************************/

    private static ubyte[4] makeChecksum (const ubyte[] data) @safe nothrow
    out(result)
    {
        assert(result.length + DataSize <= MapSize,
            "Checksum size is too large to fit in the map");
    }
    body
    {
        assert(data.length < 1 << 20,
            "Data length for checksum should not exceed 1MB");
        return crc32Of(data);
    }

    /***************************************************************************

        Validate the checksum in the memory-mapped blocks.

        Returns:
            `true` if the data matches the checksum, `false` otherwise.

    ***************************************************************************/

    private bool validateChecksum () @trusted
    {
        try
        {
            auto file_name = this.getFileName(this.file_index);
            const ubyte[] actual = cast(ubyte[])this.file[0 .. ChecksumSize];
            const ubyte[] data = cast(ubyte[])this.file[ChecksumSize .. MapSize];
            const expected = makeChecksum(data);
            if (actual != expected)
            {
                log.error("Block file {} is corrupt. Actual: {}, expected: {}",
                          file_name, actual, expected);
                return false;
            }
            return true;
        }
        catch (Exception ex)
        {
            log.error("BlockStorage.validateChecksum: {}", ex);
            return false;
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
            const ubyte[4] checksum = makeChecksum(
                cast(ubyte[])this.file[ChecksumSize .. MapSize]);

            foreach (idx, val; checksum)
                this.file[idx] = val;

            return true;
        }
        catch (Exception ex)
        {
            log.error("BlockStorage.writeChecksum: {}", ex);
            return false;
        }
    }
}

/*******************************************************************************

    Define the memory storage for blocks

    Implemented using only memory without file IO.

*******************************************************************************/

public class MemBlockStorage : IBlockStorage
{
    // we already know the blocks in the ctor,
    // but we should only load them on the call to load()
    // see also: #599
    private const(Block)[] _to_load;

    /// Storage for all the blocks
    private ubyte[][] blocks;

    /// Index is block height
    private IndexHeight height_idx;

    /// Index is block hash
    private IndexHash hash_idx;

    /// Ctor
    public this (const(Block)[] blocks = null)
    {
        this._to_load = blocks;
        this.height_idx = new IndexHeight();
        this.hash_idx = new IndexHash();
    }

    /// No-op: MemBlockStorage does no I/O
    public override void load (const ref Block genesis) @safe
    {
        // Allow `load` to be called multiple times
        // This is useful when wanting to simulate persistence
        // in a network integration test.
        if (this.blocks.length)
            return;

        if (this._to_load.length == 0)
            return this.saveBlock(genesis);

        foreach (const ref block; this._to_load)
            this.saveBlock(block);
    }

    invariant ()
    {
        // Basic consistenty checks
        assert(this.height_idx.length == this.hash_idx.length);
        assert(this.height_idx.length == this.blocks.length);

        // Make sure we have no empty block
        foreach (blk; this.blocks)
            assert(blk.length > 0);
    }

    /***************************************************************************

        Read the last block from array.

        Params:
            block = will contain the block if the read was successful

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public bool readLastBlock (ref Block block) @safe
    {
        if (this.height_idx.length == 0)
            return false;

        return this.tryReadBlock(block, this.height_idx.back.height);
    }

    /***************************************************************************

        Save block to array.

        Params:
            block = `Block` to save

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public void saveBlock (const ref Block block) @safe
    {
        if (this.blocks.length != block.header.height)
            throw new Exception("BlockStorage: Expected blocks in serial order");

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
    }

    /***************************************************************************

        Update block in the array.
        This is intended for updating the multi-sig header signature field
        The block size should be identical and this will not update unless it is

        Params:
            block = `Block` to save

        Returns:
            Returns true if success, otherwise returns false.

    ***************************************************************************/

    public override bool updateBlockMultiSig (const ref Block block) @safe nothrow
    {
        scope (failure) assert(0, "BlockStorage: Block Signature update failed");

        if (this.blocks.length < block.header.height)
            return false;

        this.blocks[block.header.height.value] = serializeFull!Block(block);

        return true;
    }

    /// See `IBlockStorage.tryReadBlock(ref Block, size_t)`
    public bool tryReadBlock (ref Block block, Height height) @safe nothrow
    {
        if ((this.height_idx.length == 0) ||
            (this.height_idx.back.height < height))
            return false;

        auto finds
            = this.height_idx[].find!( (a, b) => a.height == b)(height);

        if (finds.empty)
            return false;

        try block = deserializeFull!Block(this.blocks[finds.front.position]);
        catch (Exception e) return false;
        return true;
    }

    /// See `IBlockStorage.tryReadBlock(ref Block, hash)`
    public bool tryReadBlock (ref Block block, in Hash hash) @safe nothrow
    {
        ubyte[Hash.sizeof] hash_bytes = hash[];

        auto finds
            = this.hash_idx[].find!((a, b) => a.hash == b)(hash_bytes);

        if (finds.empty)
            return false;

        try block = deserializeFull!Block(this.blocks[finds.front.position]);
        catch (Exception e) return false;
        return true;
    }
}

/// test memory storage
unittest
{
    MemBlockStorage memory_storage = new MemBlockStorage();
    testStorage(memory_storage);
}

/// test disk storage
// N.B. This is disabled by default as tests may become flaky if they rely on IO
version (none)
unittest
{
    import agora.utils.Test;

    auto temp_dir = makeCleanTempDir(__MODULE__);
    assert(temp_dir.exists);
    scope(exit) mkdirRecurse(temp_dir);

    auto diskStorage = new BlockStorage(temp_dir);
    scope(exit) diskStorage.release();

    testStorage(diskStorage);
}

version (unittest)
private void testStorage (IBlockStorage storage)
{
    import agora.common.crypto.Key;
    import agora.consensus.data.genesis.Test;
    import agora.consensus.data.Enrollment;
    import agora.consensus.data.Transaction;
    import agora.utils.Test;
    import std.algorithm.comparison;
    import std.range;

    const size_t BlockCount = 50;

    const(Block)[] blocks;
    Hash[] block_hashes;

    blocks ~= GenesisBlock;
    storage.load(GenesisBlock);
    block_hashes ~= hashFull(GenesisBlock.header);
    Transaction[] last_txs;
    Transaction[] txs;
    Block last_block;

    void genBlocks (size_t count)
    {
        if (!last_txs.length)
        {
            txs = genesisSpendable().map!(txb => txb.sign()).array();
            last_block = makeNewTestBlock(blocks[$ - 1], txs);
            last_txs = txs;

            blocks ~= last_block;
            block_hashes ~= hashFull(last_block.header);
            storage.saveBlock(last_block);

            count--;
        }

        while (--count)
        {
            txs = last_txs.map!(tx => TxBuilder(tx).sign()).array();
            Enrollment[] no_enrollments = null;
            uint[] no_missing_validator = null;
            last_block = makeNewTestBlock(blocks[$ - 1], txs, no_enrollments,
                Hash.init,
                no_missing_validator,
                genesis_validator_keys[0 .. $ - 1], // last validator will not sign
                (PublicKey k)
                {
                    return 0;
                });
            last_txs = txs;

            blocks ~= last_block;
            block_hashes ~= hashFull(last_block.header);
            storage.saveBlock(last_block);
        }
    }

    genBlocks(BlockCount);

    // load
    Block[] loaded_blocks;
    loaded_blocks.length = BlockCount;
    foreach (idx; 0 .. BlockCount)
        storage.readBlock(loaded_blocks[idx], Height(idx));

    // compare
    assert(equal(blocks, loaded_blocks));

    Block block;

    // Test updating the signature
    assert(storage.tryReadBlock(block, Height(BlockCount - 1)));
    auto prev_signature = block.header.signature;
    iota(0, 5).each!(i => assert(block.header.validators[i],
        format!"validator bit %s should be set"(i)));
    assert(!block.header.validators[5], "validator bit 5 should not be set");
    Block updated_block = multiSigTestBlock(block,
        (PublicKey key)
        {
            return 0;
        },
        genesis_validator_keys);
    storage.updateBlockMultiSig(updated_block);
    assert(storage.tryReadBlock(block, Height(BlockCount - 1)));
    iota(0, 6).each!(i => assert(block.header.validators[i],
        format!"validator bit %s should be set after update"(i)));
    assert(block.header.signature != prev_signature);

    // test of random access
    import std.random;

    auto rnd = rndGen;

    Block random_block;
    foreach (height; iota(BlockCount).randomCover(rnd))
    {
        storage.readBlock(random_block, Height(height));
        assert(random_block.header.height == height);
    }

    foreach (idx; iota(BlockCount).randomCover(rnd))
    {
        storage.readBlock(random_block, block_hashes[idx]);
        assert(hashFull(random_block.header) == block_hashes[idx]);
    }

    // test loading in constructor
    auto txs_1 = genesisSpendable().map!(txb => txb.sign()).array();
    auto block_2 = makeNewTestBlock(GenesisBlock, txs_1);
    const ctor_blocks = [ GenesisBlock, cast(const(Block))block_2 ];
    scope store = new MemBlockStorage(ctor_blocks);
    assert(!store.tryReadBlock(block, Height(0)));  // nothing loaded yet
    // If `MemBlockStorage` doesn't load the blocks from the constructor,
    // `ctor_blocks[1]` will be used as genesis which will then fail this test
    store.load(ctor_blocks[1]);
    assert(store.tryReadBlock(block, Height(0)));
    assert(block == ctor_blocks[0]);
    assert(store.tryReadBlock(block, Height(1)));
    assert(block == ctor_blocks[1]);
}
