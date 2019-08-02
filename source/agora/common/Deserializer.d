/*******************************************************************************

    Function definition and helper related to Deserialization

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Deserializer;

import agora.common.Data;
import agora.common.Block;
import agora.common.crypto.Key;

/// Type of delegate deserializeDg
public alias DeserializeDg = ubyte[] delegate(size_t size) nothrow @safe;

/*******************************************************************************

    Deserialize a struct and return it.

    Params:
        T = Type of struct to deserialize
        data = Binary serialized representation of `T` to be deserialized

    Returns:
        The deserialized struct

*******************************************************************************/

public T deserialize (T) (scope ubyte[] data) nothrow @safe
    if (is(T == struct) && is(typeof(T.init.deserialize(DeserializeDg.init))))
{
    T value;

    scope DeserializeDg dg = (size) nothrow @safe
    {
        ubyte[] res = data[0 .. size];
        data = data[size .. $];
        return res;
    };

    value.deserialize(dg);
    return value;
}

/// Ditto
public void deserializePart (T) (ref T record, scope DeserializeDg dg)
    nothrow @safe
    if (is(T == struct))
{
    static assert(is(typeof(T.init.deserialize(DeserializeDg.init))),
                "Struct `" ~ T.stringof ~
                "` does not implement `deserialize(scope DeserializeDg) nothrow` function");
    record.deserialize(dg);
}

/// Ditto
public void deserializePart (ref Hash record, scope DeserializeDg dg)
    nothrow @safe
{
    record = Hash(dg(Hash.sizeof));
}

/// Ditto
public void deserializePart (ref ubyte record, scope DeserializeDg dg)
    nothrow @trusted
{
    record = dg(record.sizeof)[0];
}

/// Ditto
public void deserializePart (ref ushort record, scope DeserializeDg dg)
    nothrow @trusted
{
    record = *cast(ushort*)(dg(record.sizeof).ptr);
}

/// Ditto
public void deserializePart (ref uint record, scope DeserializeDg dg)
    nothrow @trusted
{
    record = *cast(uint*)(dg(record.sizeof).ptr);
}

/// Ditto
public void deserializePart (ref ulong record, scope DeserializeDg dg)
    nothrow @trusted
{
    record = *cast(ulong*)(dg(record.sizeof).ptr);
}

/// Ditto
public void deserializePart (ref long record, scope DeserializeDg dg)
    nothrow @trusted
{
    record = *cast(long*)(dg(record.sizeof).ptr);
}

/// test various serialization / deserialization of types
unittest
{
    import agora.common.Hash;
    import agora.common.Serializer;
    import agora.consensus.Genesis;

    const block = getGenesisBlock();

    ubyte[] block_bytes = serializeFull(block);
    assert(deserialize!Block(block_bytes) == block);

    // Check that there is no trailing data
    ubyte[] blocks_data = serializeFull(block) ~ serializeFull(block);

    void deserializeArrayEntry () nothrow @safe
    {
        scope DeserializeDg dg = (size) nothrow @safe
        {
            scope(exit) blocks_data = blocks_data[size .. $];
            return blocks_data[0 .. size];
        };

        Block newblock;
        newblock.deserialize(dg);
        assert(newblock == block);
    }

    deserializeArrayEntry();
    deserializeArrayEntry();
}
