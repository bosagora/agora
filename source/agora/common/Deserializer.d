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

/// Type of delegate deserializeDg
public alias DeserializeDg = ubyte[] delegate(size_t size) @safe;

/// Default deserializer implementation
public mixin template DefaultDeserializer ()
{
    static assert(is(typeof(this) == struct),
        "`DefaultDeserializer` needs to be mixed in a `struct` context");

    /***************************************************************************

        Deserialize all members of this `struct`, in the order they appear.

        Params:
            dg = source of binary data

    ***************************************************************************/

    public void deserialize (scope DeserializeDg dg) @safe
    {
        foreach (ref entry; this.tupleof)
            deserializePart(entry, dg);
    }
}

///
unittest
{
    static struct Foo
    {
        uint a;
        ubyte[] b;

        mixin DefaultDeserializer!();
    }

    /// See the example in `agora.common.Serializer` for the serialization part
    ubyte[] data = [255, 255, 255, 255, 3, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3];
    assert(deserializeFull!Foo(data) == Foo(uint.max, [1, 2, 3]));
}


/*******************************************************************************

    Deserialize a struct and return it.

    Params:
        T = Type of struct to deserialize
        data = Binary serialized representation of `T` to be deserialized

    Returns:
        The deserialized struct

*******************************************************************************/

public T deserializeFull (T) (scope ubyte[] data) @safe
{
    T value;

    scope DeserializeDg dg = (size) @safe
    {
        ubyte[] res = data[0 .. size];
        data = data[size .. $];
        return res;
    };

    deserializePart(value, dg);
    return value;
}

/// Ditto
public void deserializePart (T) (ref T record, scope DeserializeDg dg) @safe
    if (is(T == struct))
{
    static assert(is(typeof(T.init.deserialize(DeserializeDg.init))),
                "Struct `" ~ T.stringof ~
                "` does not implement `deserialize(scope DeserializeDg) nothrow` function");
    record.deserialize(dg);
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
public void deserializePart (ref Hash record, scope DeserializeDg dg)
    @safe
{
    record = Hash(dg(Hash.sizeof));
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
    record = *cast(ushort*)(dg(record.sizeof).ptr);
}

/// Ditto
public void deserializePart (ref int record, scope DeserializeDg dg)
    @trusted
{
    record = *cast(int*)(dg(record.sizeof).ptr);
}

/// Ditto
public void deserializePart (ref uint record, scope DeserializeDg dg)
    @trusted
{
    record = *cast(uint*)(dg(record.sizeof).ptr);
}

/// Ditto
public void deserializePart (ref ulong record, scope DeserializeDg dg)
    @trusted
{
    record = *cast(ulong*)(dg(record.sizeof).ptr);
}

/// Ditto
public void deserializePart (ref long record, scope DeserializeDg dg)
    @trusted
{
    record = *cast(long*)(dg(record.sizeof).ptr);
}

/// Ditto
public void deserializePart (ref char[] record, scope DeserializeDg dg)
    @trusted
{
    auto length = *cast(size_t*)(dg(size_t.sizeof).ptr);
    record = cast(char[])dg(length);
}

/// Ditto
public void deserializePart (ref ubyte[] record, scope DeserializeDg dg)
    @trusted
{
    auto length = *cast(size_t*)(dg(size_t.sizeof).ptr);
    record = dg(length);
}

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
        int i;
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
    assert(deserializeFull!S(bytes) == s);
}
