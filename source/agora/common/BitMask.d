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

import agora.serialization.Serializer;

public struct BitMask
{
    import std.algorithm;
    import std.conv;
    import std.format;
    import std.range;

    @safe:

    /// Binary serialize this bitmask (avoid double length serialization)
    public void serialize (scope SerializeDg dg) const
    {
        serializePart(this.length, dg);
        dg(this.bytes);
    }

    /// Binary deserialize this bitmask
    public static QT fromBinary (QT) (
        scope DeserializeDg dg, in DeserializerOptions opts) @safe
    {
        const len = deserializeLength(dg, opts.maxLength);
        const size = BitMask.getSize(len);
        return QT(len, dg(size));
    }

    /// Serialization
    public void toString (scope void delegate (in char[]) @safe sink) const
    {
        formattedWrite(sink, "%s", iota(this.length).map!(i => this[i] ? "1" : "0").join(""));
    }

    /// Support for Vibe.d serialization
    public string toString () const
    {
        string ret;
        scope void delegate (in char[]) @safe sink = (in v) { ret ~= v; };
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
            this.bytes = new inout(ubyte)[BitMask.getSize(length)];
    }

    public this (size_t length, in ubyte[] bytes)
    {
        this(length);
        this.bytes[] = bytes;
    }

    /// Convenience function to map a 'length' to 'bytes.length'
    pragma(inline, true)
    private static size_t getSize (size_t length) @safe pure nothrow @nogc
    {
        return (length / 8) + !!(length % 8);
    }

    // copy bits set from given BitMask bytes
    public void copyFrom (in BitMask rhs)
    {
        assert(this.length == rhs.length);
        this.bytes[] = rhs.bytes;
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

    /// return the percentage of bits set to `true`
    public ubyte percentage () const
    {
        assert(this.length > 0);
        ulong percentage = 100 * this.setCount / this.length;
        assert(percentage <= 100);
        return cast(ubyte)percentage;
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
    import std.algorithm;
    import std.range;
}

unittest
{
    assert(BitMask.getSize(0) == 0);
    assert(BitMask.getSize(1) == 1);
    assert(BitMask.getSize(6) == 1);
    assert(BitMask.getSize(8) == 1);
    assert(BitMask.getSize(9) == 2);
    assert(BitMask.getSize(16) == 2);
    assert(BitMask.getSize(100) == 13);
}

unittest
{
    auto bitmask = BitMask(10);
    assert(bitmask.toString == "0000000000");
    bitmask[1] = true;
    assert(bitmask.toString == "0100000000");
    assert(bitmask[1]);
}

unittest
{
    auto bitmask = BitMask.fromString("01011");
    const bitmask2 = bitmask;
    assert(bitmask2 == bitmask);
    // Now update to new BitMask value
    bitmask = BitMask.fromString("10001");
    assert(bitmask == BitMask.fromString("10001"));
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
    auto bitmask_copy = BitMask.fromString("001011101");
    bitmask_copy = bitmask;
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

/// Test percentage
unittest
{
    auto bitmask50 = BitMask.fromString("010110");
    assert(bitmask50.percentage == 50);
    auto bitmask85 = BitMask.fromString("0111111");
    assert(bitmask85.percentage == 85);
    auto bitmask0 = BitMask.fromString("0000000");
    assert(bitmask0.percentage == 0);
    auto bitmask100 = BitMask.fromString("1111111111111111111111111");
    assert(bitmask100.percentage == 100);
}
