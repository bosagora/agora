/*******************************************************************************

    Function definition and helper related to serialization

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Serializer;

import agora.common.Data;

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
    static struct Foo
    {
        uint a;
        ubyte[] b;

        mixin DefaultSerializer!();
    }

    const Foo f = Foo(uint.max, [1, 2, 3]);
    assert(serializeFull(f) == [255, 255, 255, 255, 3, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3]);
}

/*******************************************************************************

    Serialize a struct and return it as a ubyte[].

    Params:
        T = Type of struct to serialize
        record = Instance of `T` to serialize
        dg  = Serialization delegate, when this struct is a nested struct

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
    dg((cast(ubyte*)&record)[0 .. ushort.sizeof]);
}

/// Ditto
public void serializePart (uint record, scope SerializeDg dg)
    @trusted
{
    dg((cast(ubyte*)&record)[0 .. uint.sizeof]);
}

/// Ditto
public void serializePart (ulong record, scope SerializeDg dg)
    @trusted
{
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
