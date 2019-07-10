/*******************************************************************************

    Function definition and helper related to hashing

    The actual definition of the `Hash` type is in `agora.common.Data`,
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

import agora.common.Data;

import libsodium;


///
nothrow @nogc @safe unittest
{
    static struct Struct
    {
        ulong foo;
        string bar;

        void computeHash (scope HashDg dg) const nothrow @safe @nogc
        {
            // We can hash in any order we want
            hashPart(this.bar, dg);
            hashPart(this.foo, dg);
        }
    }

    Struct st = Struct(42, "42");
    // This gives the same result as if `foo` and the content of `bar` were
    // stored contiguously in memory and hashed
    Hash r2 = hashFull(st);
    // Result is stable
    assert(hashFull(Struct(42, "42")) == r2);

    // Alternatively, simple string messages can be hashed
    Hash abc = hashFull("abc");

    // And any basic type
    Hash ulm = hashFull(ulong.max);
}


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
    static assert(is(typeof(T.init.computeHash(HashDg.init))),
                  "Struct `" ~ T.stringof ~
                  "` does not implement `computeHash(scope HashDg) const nothrow @nogc` function");
    record.computeHash(state);
}

/// Ditto
public void hashPart () (scope const auto ref Hash record, scope HashDg state)
    /*pure*/ nothrow @nogc @safe
{
    state(record[]);
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
public void hashPart (scope cstring record, scope HashDg state) /*pure*/ nothrow @nogc @trusted
{
    state(cast(const ubyte[])record);
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
