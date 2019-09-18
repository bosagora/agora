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
import std.range.primitives;

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

    A template to check if a type has a custom serialization policy

*******************************************************************************/

public template hasSerializeMethod (T)
{
    public enum hasSerializeMethod = is(T == struct)
        && is(typeof(T.init.serialize(SerializeDg.init)));
}

///
unittest
{
    static struct Struct
    {
        void serialize(scope SerializeDg) {}
    }

    static struct DefaultValue
    {
        void serialize(SerializeDg, int = 42) @safe pure nothrow @nogc {}
    }

    static class Class
    {
        void serialize(scope SerializeDg) {}
    }

    static assert(hasSerializeMethod!Struct);
    static assert(hasSerializeMethod!DefaultValue);

    static assert(!hasSerializeMethod!Class);
    static assert(!hasSerializeMethod!int);
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
    if (isInputRange!T && hasLength!T && !hasSerializeMethod!T)
{
    serializePart(record.length, dg);
    foreach (ref v; record)
        serializePart(v, dg);
}

///
unittest
{
    static struct Foo
    {
        const(ubyte)[] bar;
        mixin DefaultSerializer!();
    }

    const(Foo)[] arr = [
        { bar: [ 6, 5, 4,  3, 2, 1, 0 ], },
        { bar: [ 9, 8, 7,  0], },
        { bar: [ 4, 4, 4,  4], },
        { bar: [ 2, 4, 8, 16], },
        { bar: [ 0, 1, 2,  4], },
    ];
    immutable ubyte[] result = [
        5, 0, 0, 0, 0, 0, 0, 0, // arr.length
        7, 0, 0, 0, 0, 0, 0, 0, // arr[0].bar.length
        6, 5, 4, 3, 2, 1, 0,    // arr[0].bar
        4, 0, 0, 0, 0, 0, 0, 0, // arr[1].bar.length
        9, 8, 7, 0,             // arr[1].bar
        4, 0, 0, 0, 0, 0, 0, 0, // arr[2].bar.length
        4, 4, 4, 4,             // arr[2].bar
        4, 0, 0, 0, 0, 0, 0, 0, // arr[3].bar.length
        2, 4, 8, 16,            // arr[3].bar
        4, 0, 0, 0, 0, 0, 0, 0, // arr[4].bar.length
        0, 1, 2, 4,             // arr[4].bar
    ];

    testSerialization(arr, result);
}

/// Ditto
public void serializePart (T) (scope const auto ref T record, scope SerializeDg dg)
    @safe
    if (is(T == struct))
{
    import std.traits : fullyQualifiedName;

    static assert(hasSerializeMethod!T, "Struct `" ~ fullyQualifiedName!T ~
        "` does not implement `serialize(scope SerializeDg) const nothrow` function");
    record.serialize(dg);
}

unittest
{
    static struct DoesNotCompile { int a; }
    DoesNotCompile inst;
    static assert(!is(typeof(() { serializeFull(inst); })));
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

///
unittest
{
    testSerialization(ubyte.max, [ubyte.max]);
    testSerialization(ubyte(0),  [0]);
    testSerialization(ubyte(127), [127]);
}

/// Ditto
public void serializePart (ushort record, scope SerializeDg dg)
    @trusted
{
    dg((cast(ubyte*)&record)[0 .. ushort.sizeof]);
}

///
unittest
{
    testSerialization(ushort.max, [ubyte.max, ubyte.max]);
    testSerialization(ushort(0),  [0, 0]);
    testSerialization(ushort(ushort.max / 2), [ubyte.max, ubyte.max / 2]);
}

/// Ditto
public void serializePart (uint record, scope SerializeDg dg)
    @trusted
{
    dg((cast(ubyte*)&record)[0 .. uint.sizeof]);
}

///
unittest
{
    testSerialization(uint.max, [ubyte.max, ubyte.max, ubyte.max, ubyte.max]);
    testSerialization(uint(0),  [0, 0, 0, 0]);
    testSerialization(uint.max / 2,
        [ubyte.max, ubyte.max, ubyte.max, ubyte.max / 2]);
}

/// Ditto
public void serializePart (ulong record, scope SerializeDg dg)
    @trusted
{
    dg((cast(ubyte*)&record)[0 .. ulong.sizeof]);
}

///
unittest
{
    testSerialization(ulong.max, [ubyte.max, ubyte.max, ubyte.max, ubyte.max,
                                  ubyte.max, ubyte.max, ubyte.max, ubyte.max]);
    testSerialization(ulong(0), [0, 0, 0, 0, 0, 0, 0, 0]);
    testSerialization(ulong.max / 2,
        [ubyte.max, ubyte.max, ubyte.max, ubyte.max, ubyte.max, ubyte.max,
         ubyte.max, ubyte.max / 2]);
}

/// Ditto
public void serializePart (scope cstring record, scope SerializeDg dg)
    @trusted
{
    serializePart(record.length, dg);
    dg(cast(const ubyte[])record);
}

///
unittest
{
    immutable string record = "Hello World";
    immutable ubyte[] result = [11, 0, 0, 0, 0, 0, 0, 0,
        'H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd'];
    testSerialization(record, result);

    testSerialization(string.init, [0, 0, 0, 0, 0, 0, 0, 0]);
}

/// Ditto
public void serializePart (scope const(ubyte)[] record, scope SerializeDg dg)
    @safe
{
    serializePart(record.length, dg);
    dg(record);
}

///
unittest
{
    immutable ubyte[] record = [1, 2, 3, 42];
    immutable ubyte[] result = [4, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 42];
    testSerialization(record, result);
}

version (unittest)
private void testSerialization (T) (scope T record, scope const(ubyte)[] result,
    int line = __LINE__)
{
    import std.format;
    ubyte[] serialized;
    scope SerializeDg dg = (scope v) { serialized ~= v; };
    serializePart(record, dg);
    assert(serialized == result,
           format("%s (%d): %s != %s", T.stringof, line, serialized, result));
}
