/*******************************************************************************

    Function definition and helper related to Deserialization

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Deserializer;

import agora.common.Types;
import agora.common.crypto.Key;

import std.range;

/// test various serialization / deserialization of types
unittest
{
    import agora.consensus.data.Block;
    import agora.common.Hash;
    import agora.common.Serializer;
    import agora.consensus.data.Transaction;
    import agora.consensus.Genesis;

    ubyte[] block_bytes = serializeFull(GenesisBlock);
    // TODO: This trigger a DMD bug about array comparison
    assert(cast(const)deserializeFull!Block(block_bytes) == GenesisBlock);

    // Check that there is no trailing data
    ubyte[] blocks_data = serializeFull(GenesisBlock) ~ serializeFull(GenesisBlock);

    void deserializeArrayEntry () @safe
    {
        scope DeserializeDg dg = (size) @safe
        {
            scope(exit) blocks_data = blocks_data[size .. $];
            return blocks_data[0 .. size];
        };

        Block newblock;
        newblock.deserialize(dg);
        // TODO: This trigger a DMD bug about array comparison
        assert(cast(const)newblock == GenesisBlock);
    }

    deserializeArrayEntry();
    deserializeArrayEntry();

    // transaction test
    auto tx_bytes = serializeFull(GenesisTransaction);
    assert(deserializeFull!Transaction(tx_bytes) == GenesisTransaction);

    // test of various field types
    static struct S
    {
        uint i;
        string s;

        void serialize (scope SerializeDg dg) const @safe
        {
            serializePart(this.i, dg);
            serializePart(this.s, dg);
        }

        void deserialize (scope DeserializeDg dg) @safe
        {
            deserializePart(this.i, dg);
            char[] buffer;
            deserializePart(buffer, dg);
            this.s = buffer.idup;
        }
    }

    auto s = S(42, "foo");
    auto bytes = serializeFull(s);
    assert(bytes.deserializeFull!S == s);
}

/// Type of delegate deserializeDg
public alias DeserializeDg = ubyte[] delegate(size_t size) @safe;

///
unittest
{
    import agora.common.Amount;

    static struct Foo
    {
        ubyte a;
        ushort b;
        uint c;
        ulong d;
        Amount e;
        ubyte[] f;
    }
    /// See the example in `agora.common.Serializer` for the serialization part
    ubyte[] data = [
        1,                       // ubyte(1)
        253, 255, 255,           // ushort.max
        254, 255, 255, 255, 255, // uint.max
        255, 255, 255, 255, 255, 255, 255, 255, 255, // ulong.max
        100,                     // Amount(100)
        3, 1, 2, 3];             // ubyte[1,2,3]
    assert(deserializeFull!Foo(data) == Foo(1, ushort.max, uint.max, ulong.max,
        Amount(100), [1, 2, 3]));
}

/*******************************************************************************

    Deserialize a struct and return it.

    Params:
        T = Type of struct to deserialize
        data = Binary serialized representation of `T` to be deserialized
        compact = Whether integers are serialized in variable-length form
    Returns:
        The deserialized struct

*******************************************************************************/

public T deserializeFull (T) (scope ubyte[] data) @safe
{
    scope DeserializeDg dg = (size) @safe
    {
        ubyte[] res = data[0 .. size];
        data = data[size .. $];
        return res;
    };
    return deserializeFull!T(dg);
}

/// Ditto
public T deserializeFull (T) (scope DeserializeDg dg) @safe
{
    T value;
    deserializePart(value, dg);
    return value;
}

/// Ditto
public void deserializePart (T) (ref T record, scope DeserializeDg dg) @safe
    if (is(T == struct))
{
    import geod24.bitblob;

    static if (is(typeof(T.init.deserialize(DeserializeDg.init))))
        record.deserialize(dg);
    // BitBlob are fixed size and thus, value types
    // If we use an `ubyte[]` overload, the deserializer looks for the length
    else static if (is(T : BitBlob!N, size_t N))
        record = T(dg(T.Width));
    else
        foreach (const ref field; record.tupleof)
            deserializePart(field, dg);
}

/// Enum support
public void deserializePart (T)(ref T record, scope DeserializeDg dg)
    @trusted
    if (is(T == enum))
{
    import std.traits;
    OriginalType!T orig_val;
    deserializePart(orig_val, dg);
    record = cast(T)(orig_val);
}

/// Ditto
public void deserializePart (ref ubyte record, scope DeserializeDg dg)
    @trusted
{
    record = dg(record.sizeof)[0];
}

/// Ditto
public void deserializePart (ref ushort record, scope DeserializeDg dg)
    @trusted
{
    deserializeVarInt(record, dg);
}

/// Ditto
public void deserializePart (ref uint record, scope DeserializeDg dg)
    @trusted
{
    deserializeVarInt(record, dg);
}

/// Ditto
public void deserializePart (ref long record, scope DeserializeDg dg)
    @trusted
{
    record = *cast(long*)(dg(record.sizeof).ptr);
}

/// Ditto
public void deserializePart (ref ulong record, scope DeserializeDg dg, CompactMode compact = CompactMode.Yes)
    @trusted
{
    if (compact == CompactMode.Yes)
        deserializeVarInt(record, dg);
    else
        record = *cast(ulong*)(dg(record.sizeof).ptr);
}

/// Ditto
public void deserializePart (ref char[] record, scope DeserializeDg dg)
    @trusted
{
    size_t length;
    deserializeVarInt(length, dg);
    record = cast(char[])dg(length);
}

/// Ditto
public void deserializePart (ref string record, scope DeserializeDg dg)
    @trusted
{
    size_t length;
    deserializeVarInt(length, dg);
    record = (cast(char[])dg(length)).idup;
}

/// Ditto
public void deserializePart (ref ubyte[] record, scope DeserializeDg dg)
    @trusted
{
    size_t length;
    deserializeVarInt(length, dg);
    record = dg(length);
}

/// Ditto
public void deserializePart (ref uint[] record, scope DeserializeDg dg)
    @trusted
{
    size_t length;
    deserializeVarInt(length, dg);

    record = cast(uint[])dg(length * uint.sizeof);

    // serialized in little-endian format
    version (BigEndian)
    {
        foreach (ref uint elem; record)
            elem = swapEndian(elem);
    }
}

/// Ditto
public void deserializePart (ref Hash[] record, scope DeserializeDg dg)
    @trusted
{
    size_t length;
    deserializePart(length, dg);
    record = uninitializedArray!(Hash[])(length);
    foreach (ref val; record)
        deserializePart(val, dg);
}

/*******************************************************************************

    Deserialize an integer of variable length using Bitcoin-style encoding

    VarInt Size
    size_tag is first a ubyte
    size_tag <= 0xFC(252)  -- 1 byte   ubyte
    size_tag == 0xFD       -- 3 bytes  (0xFD + ushort)
    size_tag == 0xFE       -- 5 bytes  (0xFE + uint)
    size_tag == 0xFF       -- 9 bytes  (0xFF + ulong)

    Params:
        T = Type of unsigned integer to deserialize
        num = Value to store the result of deserialization into
        dg = source of binary data

    See_Also: https://learnmeabitcoin.com/glossary/varint
*******************************************************************************/

private void deserializeVarInt (T) (ref T num, scope DeserializeDg dg)
    @safe
    if (is(T == ushort) || is(T == uint) || is(T == ulong))
{
    const ubyte int_size = dg(ubyte.sizeof)[0];
    assert(int_size >= 0);

    T read (InType)() @trusted
    {
        import std.exception;
        auto value = *cast(InType*)dg(InType.sizeof).ptr;
        static if (T.max < InType.max)
            enforce(value <= T.max);
        return cast(T)value;
    }

    if (int_size <= 0xFC)
        num = cast(T)(int_size);
    else if (int_size == 0xFD)
        num = read!ushort();
    else if (int_size == 0xFE)
        num = read!uint();
    else if (int_size == 0xFF)
        num = read!ulong();
    else
        assert(0);
}

/// For varint
unittest
{
    ubyte[] data = [
        0x00,                           // ulong.init
        0xFC,                           // ulong(0xFC) == 1 byte
        0xFD, 0xFD, 0x00,               // ulong(0xFD) == 3 bytes
        0xFD, 0xFF, 0x00,               // ulong(0xFE) == 3 bytes
        0xFD, 0xFF, 0xFF,               // ushort.max == 3 bytes
        0xFE, 0x00, 0x00, 0x01, 0x00,   // 0x10000u   == 5 bytes
        0xFE, 0xFF, 0xFF, 0xFF, 0xFF,   // uint.max   == 5 bytes
        // 0x100000000u == 9bytes
        0xFF, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
        // ulong.max == 9bytes
        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF];

    static struct Foo
    {
        ulong a;
        ulong b;
        ulong c;
        ulong d;
        ushort e;
        uint f;
        uint g;
        ulong h;
        ulong i;
    }
    assert(deserializeFull!Foo(data) == Foo(ulong.init, 252uL, 253uL, 255uL,
        ushort.max, 0x10000u, uint.max, 0x100000000u, ulong.max));
}

/// endianess tests
unittest
{
    static struct S
    {
        uint[] arr;
    }

    S s;  // always serialized in little-endian format
    assert([3, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0]
        .deserializeFull!S.arr == [0, 1, 2]);
}

/// BitBlob tests
unittest
{
    ubyte[64] serialized;
    serialized[$/2] = 0xFF;
    Hash /* BitBlob!512 */ val = deserializeFull!Hash(serialized);
    assert(val == Hash(
        `0x00000000000000000000000000000000000000000000000000000000000000FF`
        ~ `0000000000000000000000000000000000000000000000000000000000000000`));

}
