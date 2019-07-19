/*******************************************************************************

    Function definition and helper related to serialization

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.BlockSerialize;

import agora.common.Data;

/// Type of delegate SerializeDg
public alias SerializeDg = void delegate(scope const(ubyte)[]) pure nothrow @safe;

public ubyte[] serializeFull (T) (scope const auto ref T record)
    nothrow @safe
{
    ubyte[] res;
    scope SerializeDg dg = (scope const(ubyte[]) data) nothrow @safe
    {
        res ~= data;
    };
    serializePart(record, dg);

    return res;
}

/// Ditto
public void serializePart (T) (scope const auto ref T record, scope SerializeDg dg)
    pure nothrow @safe
    if (is(T == struct))
{
    static assert(is(typeof(T.init.serialize(SerializeDg.init))),
                "Struct `" ~ T.stringof ~
                "` does not implement `serialize(scope SerializeDg) const nothrow` function");
    record.serialize(dg);
}

/// Ditto
public void serializePart () (scope const auto ref Hash record, scope SerializeDg dg)
    pure nothrow @safe
{
    dg(record[]);
}

/// Ditto
public void serializePart (scope const Signature record, scope SerializeDg dg)
    pure nothrow @trusted
{
   dg(record[]);
}

/// Ditto
public void serializePart (ubyte record, scope SerializeDg dg)
    pure nothrow @trusted
{
    dg((cast(ubyte*)&record)[0 .. ubyte.sizeof]);
}

/// Ditto
public void serializePart (ushort record, scope SerializeDg dg)
    pure nothrow @trusted
{
    dg((cast(ubyte*)&record)[0 .. ushort.sizeof]);
}

/// Ditto
public void serializePart (uint record, scope SerializeDg dg)
    pure nothrow @trusted
{
    dg((cast(ubyte*)&record)[0 .. uint.sizeof]);
}

/// Ditto
public void serializePart (ulong record, scope SerializeDg dg)
    pure nothrow @trusted
{
    dg((cast(ubyte*)&record)[0 .. ulong.sizeof]);
}

/// Ditto
public void serializePart (scope cstring record, scope SerializeDg dg)
    pure nothrow @trusted
{
    dg(cast(const ubyte[])record);
}
