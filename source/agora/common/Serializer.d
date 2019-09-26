/*******************************************************************************

    Function definition and helper related to serialization

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Serializer;

import agora.common.Types;

/// Type of delegate SerializeDg
public alias SerializeDg = void delegate(scope const(ubyte)[]) @safe;

/// Default serializer implementation
public mixin template DefaultSerializer ()
{
    static assert(is(typeof(this) == struct),
        "`DefaultSerializer` needs to be mixed in a `struct` context");

    /***************************************************************************

        Serialize all members of this `struct`, in the order they appear.

        Params:
            dg = serialize function accumulator

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) const @safe
    {
        foreach (const ref entry; this.tupleof)
            serializePart(entry, dg);
    }
}

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
        mixin DefaultSerializer!();
    }
    const Foo f = Foo(1, ushort.max, uint.max, ulong.max, Amount(100), [1, 2, 3]);
    assert(serializeFull(f) == [
        1,                       // ubyte(1)     == 1 byte
        253,255, 255,            // ushort.max   == 3 bytes
        254, 255, 255, 255, 255, // uint.max     == 5 bytes
        255, 255, 255, 255, 255, 255, 255, 255, 255, // ulong.max == 9bytes
        100,                     // Amount(100)  == 1 byte
        3, 1, 2, 3]);            // ubyte[1,2,3] == 4 bytes
}

/*******************************************************************************

    Serialize a struct and return it as a ubyte[].

    Params:
        T = Type of struct to serialize
        record = Instance of `T` to serialize
        dg  = Serialization delegate, when this struct is a nested struct
        compact = Whether integers are serialized in variable-length form

    Returns:
        The serialized `ubyte[]`

*******************************************************************************/

public ubyte[] serializeFull (T) (scope const auto ref T record)
    @safe
    if (is(T == struct))
{
    ubyte[] res;
    scope SerializeDg dg = (scope const(ubyte[]) data) @safe
    {
        res ~= data;
    };
    serializePart(record, dg);

    return res;
}

/// Ditto
public void serializePart (T) (scope const auto ref T record, scope SerializeDg dg)
    @safe
    if (is(T == struct))
{
    static assert(is(typeof(T.init.serialize(SerializeDg.init))),
                "Struct `" ~ T.stringof ~
                "` does not implement `serialize(scope SerializeDg) const nothrow` function");
    record.serialize(dg);
}

/// Ditto
public void serializePart () (scope const auto ref Hash record, scope SerializeDg dg)
    @safe
{
    dg(record[]);
}

/// Ditto
public void serializePart (scope const Signature record, scope SerializeDg dg)
    @trusted
{
   dg(record[]);
}

/// Ditto
public void serializePart (ubyte record, scope SerializeDg dg)
    @trusted
{
    dg((cast(ubyte*)&record)[0 .. ubyte.sizeof]);
}

/// Ditto
public void serializePart (ushort record, scope SerializeDg dg)
    @trusted
{
    toVarInt(record, dg);
}

/// Ditto
public void serializePart (uint record, scope SerializeDg dg)
    @trusted
{
    toVarInt(record, dg);
}

/// Ditto
public void serializePart (ulong record, scope SerializeDg dg, CompactMode compact = CompactMode.Yes)
    @trusted
{
    if (compact == CompactMode.Yes)
        toVarInt(record, dg);
    else
        dg((cast(ubyte*)&record)[0 .. ulong.sizeof]);
}

/// Ditto
public void serializePart (scope cstring record, scope SerializeDg dg)
    @trusted
{
    serializePart(record.length, dg);
    dg(cast(const ubyte[])record);
}

/// Ditto
public void serializePart (scope const(ubyte)[] record, scope SerializeDg dg)
    @safe
{
    serializePart(record.length, dg);
    dg(record);
}

/*******************************************************************************

    Unsigned Integers to Serialized variable length integer
    and return it as a ubyte[].

    VarInt Size
    size <= 0xFC(252)  -- 1 byte   ubyte
    size <= USHORT_MAX -- 3 bytes  (0xFD + ushort)
    size <= UINT_MAX   -- 5 bytes  (0xFE + uint)
    size <= ULONG_MAX  -- 9 bytes  (0xFF + ulong)

    Params:
        T = Type of unsigned integer to serialize
        var = Instance of `T` to serialize
        dg  = Serialization delegate
    Returns:
        The serialized convert variable length integer

*******************************************************************************/

private void toVarInt (T) (const T var, scope SerializeDg dg)
    @trusted
    if (is(T == ushort) || is(T == uint) || is(T == ulong))
{
    assert(var >= 0);
    static immutable ubyte[] type = [0xFD, 0xFE, 0xFF];
    if (var <= 0xFC)
        dg((cast(ubyte*)&(*cast(ubyte*)&var))[0 .. 1]);
    else if (var <= ushort.max)
    {
        dg(type[0..1]);
        dg((cast(ubyte*)&(*cast(ushort*)&var))[0 .. ushort.sizeof]);
    }
    else if (var <= uint.max)
    {
        dg(type[1..2]);
        dg((cast(ubyte*)&(*cast(uint*)&var))[0 .. uint.sizeof]);
    }
    else if (var <= ulong.max)
    {
        dg(type[2..3]);
        dg((cast(ubyte*)&(*cast(ulong*)&var))[0 .. ulong.sizeof]);
    }
    else
        assert(0);
}

/// For varint
unittest
{
    ubyte[] res;
    scope SerializeDg dg = (scope const(ubyte[]) data)
    {
        res ~= data;
    };
    toVarInt(ulong.init, dg);
    assert(res == [0x00]);
    res.length = 0;
    toVarInt(252uL, dg);
    assert(res == [0xFC]);
    res.length = 0;
    toVarInt(253uL, dg);
    assert(res == [0xFD, 0xFD, 0x00]);
    res.length = 0;
    toVarInt(255uL, dg);
    assert(res == [0xFD, 0xFF, 0x00]);
    res.length = 0;
    toVarInt(ushort.max, dg);
    assert(res == [0xFD, 0xFF, 0xFF]);
    res.length = 0;
    toVarInt(0x10000u, dg);
    assert(res == [0xFE, 0x00, 0x00, 0x01, 0x00]);
    res.length = 0;
    toVarInt(uint.max, dg);
    assert(res == [0xFE, 0xFF, 0xFF, 0xFF, 0xFF]);
    res.length = 0;
    toVarInt(0x100000000u, dg);
    assert(res == [0xFF, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00]);
    res.length = 0;
    toVarInt(ulong.max, dg);
    assert(res == [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]);
}
