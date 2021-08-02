/*******************************************************************************

    Test that `Serializer` performs NRVO correctly

    NRVO (named return value optimization) is the act of allocating space for
    a return value in the call stack of the caller, and passing a pointer
    to that memory to the callee.
    It allows to avoid copying and moving when an aggregate is returned.
    It is particularly useful when an aggregate is returned from deep down
    a stack call, when an aggregate is large, or if it has elaborate semantics
    (non-default copy constructor, postblit, destructor).

    Usually, to tell if a type is being copied or moved, one can simply
    `@disable` postblit and the copy constructor (and optionally `opAssign`).
    However, the frontend sometimes moves structs despite this,
    so this is not enough.
    This module aims at testing that NRVO is actually performed by the compiler,
    since we cannot trust the frontend to tell us.

    See_Also:
      - Discussion that started this module:
        https://forum.dlang.org/thread/miuevyfxbujwrhghmiuw@forum.dlang.org
      - Target-specific support (only return-on-stack aggregates are NRVO'd):
        https://github.com/dlang/dmd/blob/b2d6cd459aa159fa0d7cdf7a02d647e62e7b1225/src/dmd/target.d#L409-L574
        (Note: Might differ on LDC/GDC for D linkage)
      - How function define if they are able to do NRVO:
        https://github.com/dlang/dmd/blob/b2d6cd459aa159fa0d7cdf7a02d647e62e7b1225/src/dmd/func.d#L2457
      - How return statement are rewritten:
        https://github.com/dlang/dmd/blob/b2d6cd459aa159fa0d7cdf7a02d647e62e7b1225/src/dmd/func.d#L70

    Copyright:
        Copyright (c) 2020-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.NRVO;

import agora.common.Types;
import agora.serialization.Serializer;

import std.stdio;

/// Tiny helpers for avoiding `cast`-hell
const(void)* ptr (T) (const ref T  s) if (is(T == struct)) { return cast(const(void)*) &s; }
/// Ditto
const(void)* ptr (T) (const ref T* s)                      { return cast(const(void)*)  s; }

/*******************************************************************************

    A struct that does side effect

    This struct can be used to make sure the ctor is only called once.
    The downside is that side effect might affect the ability to do NRVO.
    Use `check` to get a decent error message.

*******************************************************************************/

struct SideEffect (T)
{
    @disable this(this);
    @disable this(const ref SideEffect);
    @disable ref SideEffect opAssign (const ref SideEffect);

    __gshared const(T)* pointer;

    /// Overload for `deserialized`
    this (T v) @trusted nothrow @nogc
    {
        assert(pointer is null, "Pointer should be re-initialized!");
        pointer = &this.value;
    }

    /// Overload for manual test
    static if (is(typeof(T.tupleof)))
        this (typeof(T.tupleof) args) @trusted nothrow @nogc
        {
            assert(pointer is null, "Pointer should be re-initialized!");
            pointer = &this.value;
        }

    T value;

    ///
    void serialize (scope SerializeDg dg) const scope @safe
    {
        serializePart(this.value, dg);
    }

    ///
    public static QT fromBinary (QT) (
        scope DeserializeDg dg, in DeserializerOptions opts)
        @safe
    {
        return QT(deserializeFull!(typeof(QT.value))(dg, opts));
    }

    /// Check that `pointer is &this` and reset it
    public void check (string message, int line = __LINE__) const scope
    {
        if (ptr(pointer) !is ptr(this))
        {
            writeln("Error: ", typeof(this).stringof, " ", message, " (", line,
                    "): this=", &this, ", pointer=", pointer, ", diff=",
                    ptr(this) - ptr(pointer));
            assert(0);
        }
        pointer = null;
    }
}

///
unittest
{
    static struct S1
    {
        SideEffect!ubyte se;
        uint val;
    }

    static struct S2
    {
        S1 s1;
        ulong val;
    }

    auto inst1 = S2(S1(SideEffect!ubyte(42)));
    inst1.s1.se.check("Checking manually initialized value");

    const data = serializeFull(inst1);
    assert(data.length);
    auto inst2 = deserializeFull!S2(data);
    inst2.s1.se.check("Checking deserialized value");
}

enum Good : uint
{
    Baguette,
    Croissant,
    Choucroute,
    Chocolat,
}

struct Container (alias Struct, bool useForceNRVO = false)
{
    @disable this(this);
    @disable this(const ref Container);
    @disable ref Container opAssign (const ref Container);

    Good type_;
    union {
        Struct!Field1 f1;
        Struct!Field2 f2;
        Struct!Field3 f3;
        Struct!Field4 f4;
    }

    private static struct Field1 { string data; }
    private static struct Field2 { uint[2] data; }
    private static struct Field3 { ubyte[4] data; }
    private static struct Field4 { ulong[2] data; }

    /// Helper to keep calling code sane
    public void check (string message, int line = __LINE__) const
    {
        final switch (this.type_)
        {
            // Rightmost bound is exclude so we need the +1
            static foreach (Good entry; Good.min .. cast(Good)(Good.max + 1))
            {
            case entry:
                return this.tupleof[entry + 1].check(message, line);
            }
        }
    }

    void serialize (scope SerializeDg dg) const @trusted
    {
        serializePart(this.type_, dg);
    SWITCH: final switch (this.type_)
        {
            // Rightmost bound is excluded so we need the +1
            static foreach (Good entry; Good.min .. cast(Good)(Good.max + 1))
            {
            case entry:
                serializePart(this.tupleof[entry + 1], dg);
                break SWITCH;
            }
        }
    }

    static if (useForceNRVO)
    {
        static QT fromBinary (QT) (
            scope DeserializeDg dg, const ref DeserializerOptions opts)
        {
            auto type = deserializeFull!Good(dg, opts);
            final switch (type)
            {
                // Rightmost bound is exclude so we need the +1
                static foreach (Good entry; Good.min .. cast(Good)(Good.max + 1))
                {
                case entry:
                    return forceNRVO!(entry, QT)(dg, opts);
                }
            }
        }

        static QT forceNRVO (Good type, QT) (
            scope DeserializeDg dg, const ref DeserializerOptions opts)
        {
            static if (type == Good.Baguette)
                QT f = { type_: type, f1: deserializeFull!(typeof(QT.f1))(dg, opts) };
            else static if (type == Good.Croissant)
                QT f = { type_: type, f2: deserializeFull!(typeof(QT.f2))(dg, opts) };
            else static if (type == Good.Choucroute)
                QT f = { type_: type, f3: deserializeFull!(typeof(QT.f3))(dg, opts) };
            else static if (type == Good.Chocolat)
                QT f = { type_: type, f4: deserializeFull!(typeof(QT.f4))(dg, opts) };
            else
                static assert(0, "Unsupported enum value: " ~ type.stringof);
            return f;
        }
    }
    else
    {
        static QT fromBinary (QT) (
            scope DeserializeDg dg, in DeserializerOptions opts)
        {
            auto type = deserializeFull!Good(dg, opts);
            final switch (type)
            {
            case Good.Baguette:
                return () {
                    QT f = { type_: type, f1: deserializeFull!(typeof(QT.f1))(dg, opts) };
                    return f;
                }();
            case Good.Croissant:
                return () {
                    QT f = { type_: type, f2: deserializeFull!(typeof(QT.f2))(dg, opts) };
                    return f;
                }();
            case Good.Choucroute:
                return () {
                    QT f = { type_: type, f3: deserializeFull!(typeof(QT.f3))(dg, opts) };
                    return f;
                }();
            case Good.Chocolat:
                return () {
                    QT f = { type_: type, f4: deserializeFull!(typeof(QT.f4))(dg, opts) };
                    return f;
                }();
            }
        }
    }
}

/// Test that our approach to ensure NRVO on unions actually works
version(none) unittest
{
    /// Accept an initialized val
    static void doTest (C) (in C val, int line = __LINE__)
    {
        val.check("Checking constructed value", line);
        auto data = serializeFull(val);
        assert(data.length);
        scope vald = deserializeFull!C(data);
        vald.check("Checking deserialized value", line);
    }

    static void doTestWithDifferentFromBinary (bool useForceNRVO) ()
    {
        alias SRContainer = Container!(SelfRef, useForceNRVO);
        alias SEContainer = Container!(SideEffect, useForceNRVO);

        // // string
        SEContainer se1 = { Good.Baguette, f1: typeof(SEContainer.f1)("Hello World") };
        doTest(se1);
        // uint[2]
        SEContainer se2 = { Good.Croissant, f2: typeof(SEContainer.f2)([42, 420]) };
        doTest(se2);
        // ubyte[4]
        SEContainer se3 = { Good.Choucroute, f3: typeof(SEContainer.f3)([16, 32, 64, 128]) };
        doTest(se3);
        // ulong[2]
        SEContainer se4 = { Good.Chocolat, f4: typeof(SEContainer.f4)([ulong.max / 4, ulong.max / 16]) };
        doTest(se4);

        // string
        SRContainer sr1 = { Good.Baguette, f1: typeof(SRContainer.f1).T("Hello World") };
        doTest(sr1);
        // uint[2]
        SRContainer sr2 = { Good.Croissant, f2: typeof(SRContainer.f2).T([42, 420]) };
        doTest(sr2);
        // ubyte[4]
        SRContainer sr3 = { Good.Choucroute, f3: typeof(SRContainer.f3).T([16, 32, 64, 128]) };
        doTest(sr3);
        // ulong[2]
        SRContainer sr4 = { Good.Chocolat, f4: typeof(SRContainer.f4).T([ulong.max / 4, ulong.max / 16]) };
        doTest(sr4);
    }

    doTestWithDifferentFromBinary!true();

    // Suggested by https://forum.dlang.org/post/szzqmmhxjcyxmenhrxfk@forum.dlang.org
    // However it does not work:
    // Error: const(Struct!string) Checking deserialized value (346): this=700003ECCBE0, pointer=700003ECCAE8, diff=248
    version(none) doTestWithDifferentFromBinary!false();
}

/*******************************************************************************
    Test that NRVO is performed correctly on a type
    NRVO (named return value optimization) is an important technique whereas
    large types are passed as hidden pointer rather than copied or moved around.
    Not only is it useful for performance, but it prevents structs with interior
    pointers from breaking (e.g. `std::string`).
    The check relies on a constructor taking an interior pointer, hence the data
    in the struct does not matter.
*******************************************************************************/

public void testNRVO (S) ()
{
    alias Tested = TypeMapper!(S, SelfRef);

    Tested inst;
    pragma(msg, typeof(Tested.tupleof));
    inst.check("Checking manually initialized value");

    const data = serializeFull(inst);
    assert(data.length);
    inst.check("Checking that the value was not modified");

    auto inst2 = deserializeFull!Tested(data);
    inst2.check("Checking deserialized value");
}

/*******************************************************************************

    Map a type to another type, applying `Map` when possible

    Params:
      TSym = The type to map.
      Map = The mapping function. When it doesn't "return" anything,
            that is when `is(typeof(Map!S))` is `false`, `TypeMapper` will
            recursively descend into the type. If the above condition is `true`,
            `TypeMapper` will alias itself to the result.
            Implementation can recusrively call `TypeMapper` from within `Map`
            to allow recursion to continue.
      skipMap = A boolean to skip the application of map for this level.
                Will not propagate. Useful when using `TypeMapper` recursively.

    Returns:
      A new type, the result of applying `Map` to `Sym` recursively.

*******************************************************************************/

private template TypeMapper (TSym, alias Map, bool skipMap = false)
{
    // If the Map function is valid, use it
    static if (!skipMap && is(Map!TSym))
    {
        pragma(msg, "Aliasing: TypeMapper!", TSym, " to ", Map!TSym);
        alias TypeMapper = Map!TSym;
    }
    // Otherwise get the symbol of the fields
    else static if (is(TSym == struct))
    {
        static struct TypeMapper_
        {
            static foreach (idx, Field; typeof(TSym.tupleof))
                mixin("TypeMapper!(Field, Map) ", __traits(identifier, TSym.tupleof[idx]), ";");
        }
        alias TypeMapper = TypeMapper_;
    }
    else static if (is(TSym == E[N], E, size_t N))
        alias TypeMapper = TypeMapper!(E, Map)[N];
    else static if (is(TSym == E[], E))
        alias TypeMapper = TypeMapper!(E, Map)[];
    else static if (is(TSym == E*, E))
        alias TypeMapper = TypeMapper!(E, Map)*;
    else static if (is(TSym == V[K], V, K))
        alias TypeMapper = TypeMapper!(V, Map)[TypeMapper!(K, Map)];
    else static if (is(TSym == class))
        static assert(0, "`class` are not supported");
    else
        alias TypeMapper = TSym;
}

///
unittest
{
    static struct S1
    {
        void* ptr;
        void* ptr2;
    }

    static struct S2
    {
        S1 f1;
        S1 f2;
    }

    static struct S3
    {
        S2[4] field;
    }

    template Map (T)
    {
        static if (is(T == E*, E))
            alias Map = const(E)*;
        else
            static assert(0);
    }

    alias Mapped = TypeMapper!(S3, Map);
    static assert(is(typeof(Mapped.field[0].f2.ptr) == const(void)*));
}

/*******************************************************************************
    A self-referencing struct
    This is one of the best way to check if a struct does NRVO.
    The constructor should only be called once, and any move that elide the
    postblit / copy ctor will lead to a different address for `&this` and `self`
    Use `check` to get a decent error message.
*******************************************************************************/

public struct SelfRef (OrigType) if (is(OrigType == struct))
{
    private alias Hack(X) = SelfRef!X;

    public alias T = TypeMapper!(OrigType, Hack, true);

    // This is not enough, unfortunately
    @disable this(this);
    //@disable this(const ref SelfRef);
    @disable ref SelfRef opAssign (const ref SelfRef);

    // Note: Struct needs to be big enough to ensure NRVO,
    // otherwise registers may be used
    T value;
    T*[8] self;

    ///
    void serialize (scope SerializeDg dg) const @safe
    {
        serializePart(this.value, dg);
    }

    ///
    public static QT fromBinary (QT) (
        scope DeserializeDg dg, in DeserializerOptions opts)
        @safe
    {
        auto ret = QT(deserializeFull!(typeof(QT.value))(dg, opts));
        () @trusted { (cast()ret.self[0]) = &ret.value; }();
        return ret;
    }

    /// Check that `self is &this`
    public void check (string message, int line = __LINE__) const
    {
        import std.stdio;

        if ((cast(const void*) this.self[0]) !is (cast(const void*) &this))
        {
            writeln("Error: ", typeof(this).stringof, " ", message, " (", line,
                    "): this=", &this, ", self=", this.self[0], ", diff=",
                    (cast(const void*) &this) - (cast(const void*) this.self[0]));
            assert(0);
        }

        foreach (ref field; this.tupleof)
        {
            static if (is(typeof(field.check(message, line))))
                field.check(message, line);
        }
    }
}

///
unittest
{
    static struct S0
    {
        ulong[4] a;
        ulong[4] b;
    }

    static struct S1
    {
        SelfRef!S0 sr;
        uint val;
    }

    static struct S2
    {
        S1 s1;
        ulong val;
    }

    // Test that `fromBinary` does not disable NRVO
    {
        SelfRef!S0 inst1;
        const data = serializeFull(inst1);
        auto inst2 = deserializeFull!(SelfRef!S0)(data);
        inst2.check("Checking deserialized value");
    }

    // Nested test
    {
        S2 inst1;
        const data = serializeFull(inst1);
        auto inst2 = deserializeFull!S2(data);
        inst2.s1.sr.check("Checking deserialized value");
    }
}
