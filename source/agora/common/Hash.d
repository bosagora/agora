/*******************************************************************************

    Function definition and helper related to hashing

    The actual definition of the `Hash` type is in `agora.common.Types`,
    as parts of the system might pass along `Hash` without having to know
    what / how they were produced.

    However, this module expose functionalities for modules that want to do
    hashing. The interface is designed so that this module knows about the
    hash types, and aggregates implementing the interface only deal with their
    members.

    Due to a language limitation (one can't overload based on return value),
    this module expose two main functions:
    - `hashFull(T)`, which returns a `Hash`
    - `hashPart(T, HashDg)` which does not return anything and should be used
      to accumulate data to hash.

    For safety reason, a data structure currently need to explicitly define
    a `hash` function to support hashing.
    This limitation might be lifted in the future, but a few things
    need to be taken into account:
    - Alignment / packing: We can't have unaligned / unpacked structures
      as it would create malleability issues
    - Non-public members: We can't deal with anything non-public (we can use
      `.tupleof` but it's impossible to tell the usage of the member,
      e.g. it could be a cache of the hash)
    - Indirections / references types

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Hash;

static import agora.common.Types;

import libsodium;


///
nothrow @nogc @safe unittest
{
    static struct SimpleStruct
    {
        ulong foo;
        string bar;
    }

    static struct ComplexStruct
    {
        string irrelevant;
        string bar;
        ulong foo;

        void computeHash (scope HashDg dg) const nothrow @safe @nogc
        {
            // We can hash in any order we want, and ignore anything we want
            hashPart(this.foo, dg);
            hashPart(this.bar, dg);
        }
    }

    const st = SimpleStruct(42, "42");
    // This gives the same result as if `foo` and the content of `bar` were
    // stored contiguously in memory and hashed
    Hash r2 = hashFull(st);
    // Result is stable
    assert(hashFull(SimpleStruct(42, "42")) == r2);
    assert(hashFull(ComplexStruct("Hello World", "42", 42)) == r2);

    // Alternatively, simple string messages can be hashed
    Hash abc = hashFull("abc");

    // And any basic type
    Hash ulm = hashFull(ulong.max);
}

///
public alias Hash = agora.common.Types.Hash;

///
public alias Signature = agora.common.Types.Signature;

/// Type of delegate passed to `hash` function when there's a state
public alias HashDg = void delegate(scope const(ubyte)[]) /*pure*/ nothrow @safe @nogc;


/*******************************************************************************

    Hash a given data structure using BLAKE2b into `state`

    Note that there is no overload for signed types, as only the binary
    representation matters for hashing.

    Params:
      T = Type of struct to hash
      record = Instance of `T` to hash
      state  = State delegate, when this struct is nested in another.

    Returns:
      The `Hash` representing this instance

*******************************************************************************/

public Hash hashFull (T) (scope const auto ref T record)
    nothrow @nogc @trusted
{
    Hash hash = void;
    crypto_generichash_state state;
    crypto_generichash_init(&state, null, 0, Hash.sizeof);
    scope HashDg dg = (scope const(ubyte)[] data) @trusted
                     => cast(void)crypto_generichash_update(&state, data.ptr, data.length);
    hashPart(record, dg);
    crypto_generichash_final(&state, hash[].ptr, Hash.sizeof);
    return hash;
}

/// Ditto
public void hashPart (T) (scope const auto ref T record, scope HashDg state)
    /*pure*/ nothrow @nogc
    if (is(T == struct))
{
    static if (is(typeof(T.init.computeHash(HashDg.init))))
        record.computeHash(state);
    else static if (__traits(compiles, () { const ubyte[] r = T.init[]; }))
        state(record[]);
    else
        foreach (const ref field; record.tupleof)
            hashPart(field, state);
}

/// Ditto
public void hashPart (ubyte record, scope HashDg state) /*pure*/ nothrow @nogc @trusted
{
    state((cast(ubyte*)&record)[0 .. ubyte.sizeof]);
}

/// Ditto
public void hashPart (ushort record, scope HashDg state) /*pure*/ nothrow @nogc @trusted
{
    state((cast(ubyte*)&record)[0 .. ushort.sizeof]);
}

/// Ditto
public void hashPart (uint record, scope HashDg state) /*pure*/ nothrow @nogc @trusted
{
    state((cast(ubyte*)&record)[0 .. uint.sizeof]);
}

/// Ditto
public void hashPart (ulong record, scope HashDg state) /*pure*/ nothrow @nogc @trusted
{
    state((cast(ubyte*)&record)[0 .. ulong.sizeof]);
}

/// Ditto
public void hashPart (scope const(char)[] record, scope HashDg state) /*pure*/ nothrow @nogc @trusted
{
    state(cast(const ubyte[])record);
}

/// Ditto
public void hashPart (scope const(ubyte)[] record, scope HashDg state)
    /*pure*/ nothrow @nogc @safe
{
    state(record);
}

/// Ditto
public void hashPart (T) (scope const auto ref T[] records, scope HashDg state)
    /*pure*/ nothrow @nogc @safe
{
    foreach (ref record; records)
        hashPart(record, state);
}

// Test that the implementation actually matches what the RFC gives
nothrow @nogc @safe unittest
{
    // https://tools.ietf.org/html/rfc7693#appendix-A
    static immutable ubyte[] hdata = [
        0xBA, 0x80, 0xA5, 0x3F, 0x98, 0x1C, 0x4D, 0x0D, 0x6A, 0x27, 0x97, 0xB6,
        0x9F, 0x12, 0xF6, 0xE9,
        0x4C, 0x21, 0x2F, 0x14, 0x68, 0x5A, 0xC4, 0xB7, 0x4B, 0x12, 0xBB, 0x6F,
        0xDB, 0xFF, 0xA2, 0xD1,
        0x7D, 0x87, 0xC5, 0x39, 0x2A, 0xAB, 0x79, 0x2D, 0xC2, 0x52, 0xD5, 0xDE,
        0x45, 0x33, 0xCC, 0x95,
        0x18, 0xD3, 0x8A, 0xA8, 0xDB, 0xF1, 0x92, 0x5A, 0xB9, 0x23, 0x86, 0xED,
        0xD4, 0x00, 0x99, 0x23
    ];
    const abc_exp = Hash(hdata, /*isLittleEndian:*/ true);
    assert(hashFull("abc") == abc_exp);

    static struct Composed
    {
        public char c0;
        private int irrelevant;
        public char c1;
        private ulong say_what;
        public char c2;
        private string baguette;

        public void computeHash (scope HashDg dg) const nothrow @safe @nogc
        {
            // We can hash in any order we want
            hashPart(this.c0, dg);
            hashPart(this.c1, dg);
            hashPart(this.c2, dg);
        }
    }

    Composed str;
    str.c0 = 'a';
    str.c1 = 'b';
    str.c2 = 'c';
    assert(hashFull(str) == abc_exp);
}

/*******************************************************************************

    Hashes multiple arguments together

    Params:
        T = variadic argument types
        args = the arguments

    Returns:
        the hash of all the arguments

*******************************************************************************/

public Hash hashMulti (T...)(auto ref T args) nothrow @nogc @safe
{
    Hash hash = void;
    crypto_generichash_state state;

    auto dg = () @trusted {
        crypto_generichash_init(&state, null, 0, Hash.sizeof);
        scope HashDg dg = (scope const(ubyte)[] data) @trusted
            => cast(void)crypto_generichash_update(&state, data.ptr, data.length);
        return dg;
    }();

    static foreach (idx, _; args)
        hashPart(args[idx], dg);
    () @trusted { crypto_generichash_final(&state, hash[].ptr, Hash.sizeof); }();
    return hash;
}

///
nothrow @nogc @safe unittest
{
    Hash foo = hashFull("foo");
    Hash bar = hashFull("bar");
    const merged = Hash(
        "0xe0343d063b14c52630563ec81b0f91a84ddb05f2cf05a2e4330ddc79bd3a06e57" ~
        "c2e756f276c112342ff1d6f1e74d05bdb9bf880abd74a2e512654e12d171a74");

    assert(hashMulti(foo, bar) == merged);

    const Hash[2] array = [foo, bar];
    assert(hashFull(array[]) == merged);

    static struct S
    {
        public char c0;
        private int unused_1;
        public char c1;
        private int unused_2;
        public char c2;
        private int unused_3;

        public void computeHash (scope HashDg dg) const nothrow @safe @nogc
        {
            hashPart(this.c0, dg);
            hashPart(this.c1, dg);
            hashPart(this.c2, dg);
        }
    }

    auto hash_1 = hashMulti(420, "bpfk", S('a', 0, 'b', 0, 'c', 0));
    auto hash_2 = hashMulti(420, "bpfk", S('a', 1, 'b', 2, 'c', 3));
    assert(hash_1 == hash_2);
}
