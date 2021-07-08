/*******************************************************************************

    This is an implementation of a bitmask that once initialized will have a
    fixed number of bits for holding `true` / `false` (`1` / `0`) values.
    It allocates the required number of `ubytes` in the constructor and does not
    allow reading or writing to bits beyond the fixed count which is set during
    construction.
    This type is created for use as the validators signing bitmask and any
    changes should ensure that it does not compromise that use.

*******************************************************************************/

module agora.common.BitMask;

public struct BitMask
{
    import std.algorithm;
    import std.conv;
    import std.format;
    import std.range;

    @safe:

    /// Serialization
    public void toString (scope void delegate (scope const char[]) @safe sink) const
    {
        formattedWrite(sink, "%s", iota(this.length).map!(i => this[i] ? "1" : "0").join(""));
    }

    /// Support for Vibe.d serialization
    public string toString () const
    {
        string ret;
        scope void delegate (scope const char[]) @safe sink = (scope v) { ret ~= v; };
        this.toString(sink);
        return ret;
    }

    pure:

    /// Support for Vibe.d deserialization
    public static BitMask fromString (scope const(char)[] str)
    {
        auto bitmask = BitMask(str.length);
        str.enumerate.each!((i, c)
        {
            if (c == '1')
                bitmask[i] = true;
        });
        return bitmask;
    }

    nothrow:

    /// Count of active validators who are expected / allowed to sign the block
    private size_t length;

    /// return the count of active validators
    public size_t count () const scope @nogc
    {
        return this.length;
    }

    /// Bytes to hold bits to indicate if a validator has signed
    private ubyte[] bytes;

    public this (size_t length) inout
    {
        this.length = length;
        if (length > 0)
            this.bytes = new inout(ubyte)[1 + ((length - 1) / 8)];
    }

    public this (size_t length, in ubyte[] bytes)
    {
        this(length);
        this.bytes[] = bytes;
    }

    // set the bits that are set in given BitMask
    public auto opOpAssign (string op : "|") (in BitMask add)
    {
        assert(this.length == add.length, "BitMask assignment must be for same bit length");
        this.bytes[] |= add.bytes[];
        return this;
    }

    /// return the indices of bits set
    public auto setIndices () const
    {
        return iota(this.length).filter!(i => this[i]);
    }

    /// return the indices of bits not set
    public auto notSetIndices () const
    {
        return iota(this.length).filter!(i => !this[i]);
    }

    /// return the count of bits set to `true`
    public size_t setCount () const
    {
        return this.setIndices.count!(i => this[i]);
    }

    /// Support for sorting by count of set bits not value
    public int opCmp (in typeof(this) rhs) const
    {
        assert(this.length == rhs.length, "Comparing different sized BitMasks is not valid");
        return this.setCount < rhs.setCount ? -1 : 1;
    }

    // support setting a bit (asserts if trying to unset a bit)
    public auto opIndexAssign(bool set, size_t bit_index) @nogc
    {
        if (bit_index >= this.length)
                assert(0, "Attempt to set index beyond length of bitmask");
        const size_t byte_index = (bit_index) / 8;
        if (set)
            this.bytes[byte_index] |= mask(bit_index);
        else
            assert(0, "Only setting bits is allowed!");
        return this;
    }

    /// Gets a single bit's value
    public bool opIndex (size_t bit_index) const @nogc
    {
        if (bit_index >= this.length)
            assert(0, "Attempt to get index beyond length of bitmask");
        return !!(this.bytes[bit_index / 8] & mask(bit_index));
    }

    /// Gets a bit mask which only includes a given index within a ubyte
    pragma(inline, true)
    private static ubyte mask (size_t index) @nogc
    {
        return (1 << (8 - 1 - (index % 8)));
    }
}

version (unittest)
{
    import agora.serialization.Serializer;

    import std.algorithm;
    import std.range;
}

unittest
{
    auto bitmask = BitMask(10);
    assert(bitmask.toString == "0000000000");
    bitmask[1] = true;
    assert(bitmask.toString == "0100000000");
    assert(bitmask[1]);
}

/// More set than unset
unittest
{
    auto bitmask = BitMask.fromString("01011");
    only(1,3,4).each!(i => assert(bitmask[i]));
    only(0,2).each!(i => assert(!bitmask[i]));
    assert(bitmask.length == 5);
}

/// Test with more than 8 bits
unittest
{
    auto bitmask = BitMask.fromString("111011111");
    assert(bitmask.length == 9);
    assert(bitmask.toString == "111011111");
    auto bitmask_copy = BitMask(9);
    bitmask_copy |= bitmask;
    assert(!bitmask_copy[3]);
    only(0,1,2,4,5).each!(i => assert(bitmask_copy[i]));
}

/// Test serialization
unittest
{
    auto bitmask = BitMask(12);
    testSymmetry(bitmask);
    bitmask[1] = true;
    auto bitmask2 = bitmask.serializeFull.deserializeFull!BitMask;
    assert(bitmask2.length == bitmask.length);
    assert(bitmask2.setCount == bitmask.setCount);
    assert(bitmask2 == bitmask);
}
