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

/*******************************************************************************

    Helper struct to manage a range of pre-images

    When dealing with pre-images, the only unrecoverable data is the seed.
    Everything else is, by definition, derived from the seed.
    As a result, we can compress the data as much as we want,
    to reduce memory usage. However, this comes at the cost of more computation.

    For example, if we have cycles of 10 pre-images, we can first compute the
    seed (H0), then reveal our initial commitment (H9). This will cost us
    9 hash operations. Then on the next reveal, in order to get H8, we need to
    perform 8 hash operations, then 7 for H7, etc...

    If we want to improve this, we can store intermediate results:
    when generating H9, we do perform 9 hash operations, but store H5.
    Hence, when generating H8 and H7, we only need to perform
    3 and 2 hash operations, respectively, and will never need to perform more
    than 4 operations (save the initial commitment).

    This structure is a mean to generalize this approach, with arbitrary count
    and arbitrary sample size (interval, or distance, between saved pre-images).

*******************************************************************************/

public struct PreImageCache
{
    @safe nothrow:

    /// Store the actual preimages
    private Hash[] data;

    /// Interval between two preimages in `data`
    private const ulong interval;

    /// Construct an instance using already existing data
    public this (inout(Hash)[] data_, ulong sample_size) inout @nogc pure
    {
        this.data = data_;
        this.interval = sample_size;
    }

    /***************************************************************************

        Construct an instance and allocate memory

        This takes a `count` of pre-image and a sample size, or distance.
        For example, if one wish to represent a range of 1000 pre-images with
        this cache, and perform no more than 5 hash operations each time,
        the `sample_size` should be `5` and the `count` should be `200`
        (1000 / 5).

        Params:
          count = Number of samples to store (number of entries in the array)
          sample_size = Distance between two pre-images

    ***************************************************************************/

    public this (ulong count, ulong sample_size) pure
    {
        assert(count > 1, "A count of less than 2 does not make sense");
        assert(sample_size > 1, "A distance of less than 2 does not make sense");

        this.interval = sample_size;
        this.data = new Hash[](count);
    }

    /***************************************************************************

        Populate this cache from the `seed`

        Params:
          seed = Initial value to derive preimage from. This will always be the
                 first value of the array.
          length = The number of entries to populate.
                   This can be used when large sample size are used,
                   and one wish to stop initialization past a certain threshold.

        Returns:
          The result of hashing seed `sample_size * (count + 1) - 1` times
          if `length == 0`, or `sample_size * (length + 1) - 1` otherwise,
          provided `length <= count`.

    ***************************************************************************/

    public Hash reset (Hash seed, size_t length)
    {
        // Set the length, so that extra entries are not accessible through
        // `opIndex`
        assert(length > 0, "The length of the array should be at least 1");
        this.data.length = length;
        () @trusted { assumeSafeAppend(this.data); }();
        return this.reset(seed);
    }

    /// Ditto
    public Hash reset (Hash seed) @nogc
    {
        size_t count = 0;
        immutable end = this.data.length * this.interval - 1;
        foreach (idx, ref entry; this.data)
        {
            entry = seed;
            do
                seed = hashFull(seed);
            while ((++count % end) % this.interval);
        }
        return seed;
    }

    /***************************************************************************

        Get the hash at index `idx` in the cycle

        Will perform at most `cycle_length % interval` computations.

    ***************************************************************************/

    public Hash opIndex (size_t index) const @nogc
    {
        immutable startIndex = (index / this.interval);
        // This will trigger out of bound if needed
        // We could possibly silently allow to index arbitrarily outside the
        // array by just taking the computational hit, since indexing past the
        // end means we are generating new pre-images, but it sounds like abuse
        Hash value = this.data[startIndex];
        foreach (_; (startIndex * this.interval) .. index)
            value = hashFull(value);
        return value;
    }

    /// Returns: The number of preimages this cache can represent
    public size_t length () const pure nothrow @nogc @safe
    {
        return this.interval * this.data.length;
    }

    /// Ditto
    alias opDollar = length;
}

///
unittest
{
    Hash[32] data;
    data[0] = hashFull("Hello World");
    foreach (idx, ref entry; data[1 .. $])
        entry = hashFull(data[idx]);

    // First case and last two are degenerate
    immutable intervals = [2, 4, 8, 16];
    foreach (interval; intervals)
    {
        auto cache = PreImageCache(data.length / interval, interval);
        auto last = cache.reset(data[0]);
        assert(last == data[$-1]);
        foreach (idx, const ref value; data)
            assert(value == cache[idx]);

        assert(cache[$-1] == last);
        assert(cache[cache.length - 1] == last);

        switch (interval)
        {
        case 32:
        case 16:
        case 8:
        case 4:
        case 2:
        case 1:
            assert(cache.data.length == (32 / interval));
            size_t data_idx;
            foreach (idx, const ref entry; cache.data)
            {
                assert(entry == data[data_idx]);
                data_idx += interval;
            }
            break;

        case 64:
            assert(cache.data.length == 1);
            assert(cache.data[0] == data[0]);
            break;
        case 0:
            assert(cache.data.length == 32);
            assert(cache.data[] == data[]);
            break;

        default:
            assert(0);
        }
    }
}
