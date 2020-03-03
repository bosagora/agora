/*******************************************************************************

    Contains a templated BitField implementation

    This module implement a clean room bit field type, with a configurable
    backing store type.

    The reason to provide a configurable type is to allow users to control
    exactly the size (and alignment) of their bit fields,
    which is needed when the data type is serialized, either for network
    communication or blockchain storage.

    This also explains why we cannot rely on Phobos' own bitfield type,
    as it is backed by `size_t`.

    Note:
    Currently BitField does not implement any optimization.
    Eventually, using some functions from `core.bitop`, ensuring word-sized
    operations (e.g. when setting / testing multiple values) might be beneficial

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.BitField;

import agora.common.Hash;
import agora.common.Serializer;
import agora.common.Types;

import std.algorithm;
import std.math;
import std.traits;

///
unittest
{
    // Create a bitfield with `ubyte` (8 bits) granularity
    auto bf1 = BitField!ubyte(6);
    // The number of bits available is always rounded up
    // to be a multiple of `T.sizeof`
    assert(bf1.length == 8);

    // Test with `uint` (32 bits granularity)
    auto bf2 = BitField!uint(6);
    assert(bf2.length == 32);

    // BitField of different type can compare
    assert(bf1 != bf2);
    // And will compare equal when their length and content match
    auto bf3 = BitField!ubyte(32);
    assert(bf3.length == 32); // Same length as `bf2`
    assert(bf2 == bf3);
    assert(bf3 == bf2);

    // One can trivially set and get individual bits
    bf2[10] = true;
    assert(bf2[10]);
    assert(bf2 != bf3);
    bf2[10] = false;
    assert(!bf2[10]);
    assert(bf2 == bf3);
}

/// See module documentation
public struct BitField (T = uint)
{
    @safe pure nothrow:

    static assert (isUnsigned!T,
                   "BitField only accepts unsigned integer types, not: " ~ T.stringof);

    ///
    private enum BitsPerT = (T.sizeof * 8);

    /// Backing store: Should be private but Vibe.d cannot serialize it...
    public T[] _storage;

    /***************************************************************************

        Construct a BitField to hold at least `min_num_bits`

        This constructor is the allocating counterpart of the one that takes
        an array as argument. Essentially the following two constructs are
        identical in the object they produce:
        ---
        auto bf1 = BitField!uint(new uint[5]);
        auto bf2 = BitField!uint(160 /* 160 = 5 uints * 32 bits per uint)
        ---
        The argument is a *minimum* value, and will be rounded up to a multiple
        of `T.sizeof * 8`.
        This is because, when making a BitField of size 6 (less than a byte),
        we would require extra logic to store the actual size of the bit field
        and prohibit out of bound usage.
        Instead, `BitField`s are always of a multiple of `T` size, but we give
        the user control over `T`.

        Params:
          min_num_bits = Minimum number of bits this BitField must support

    ***************************************************************************/

    public this (size_t min_num_bits) inout
    {
        this._storage = new inout(T)[(min_num_bits + BitsPerT - 1) / BitsPerT];
    }

    @nogc:

    /***************************************************************************

        Build a `BitField` from an existing storage

        Params:
          storage = Backing store to use for BitField.

    ***************************************************************************/

    public this (inout(T)[] storage) inout
    {
        this._storage = storage;
    }

    /// Returns the number of bits in the bitfield
    public size_t length () const
    {
        return this._storage.length * BitsPerT;
    }

    /// Supports setting a single bit to a value
    public bool opIndexAssign (bool value, size_t index)
    {
        if (index >= this.length())
            assert(0);

        if (value)
            this._storage[index / BitsPerT] |= mask(index);
        else
            // This line triggers an annoying deprecation which we can't
            // seem to get rid of. TODO: Report to DMD
            this._storage[index / BitsPerT] &= ~mask(index);
        return value;
    }

    /// Gets a single bit's value
    public bool opIndex (size_t index)
    {
        if (index >= this.length())
            assert(0);
        return !!(this._storage[index / BitsPerT] & mask(index));
    }

    /// Compare BitField of same length
    public bool opEquals (OtherT) (const auto ref BitField!OtherT other) const
    {
        // Always do the comparison from the PoV of the BitField with
        // the largest data type
        static if (OtherT.sizeof > T.sizeof)
            return other.opEquals(this);
        else
        {
            if (this.length() != other.length())
                return false;

            ref T get (size_t idx) @trusted
            {
                return (cast(T*) other._storage.ptr)[idx];
            }

            foreach (idx, ref v; this._storage)
                if (v != get(idx))
                    return false;

            return true;
        }
    }

    /// Gets a bit mask which only include a given index within a `T`
    pragma(inline, true)
    private static T mask (size_t index)
    {
        return (1 << (BitsPerT - 1 - (index % BitsPerT)));
    }
}

// opEquals tests
unittest
{
    auto bf1 = BitField!uint(6);
    bf1[0] = true;
    bf1[2] = true;
    bf1[4] = true;

    auto bf2 = bf1;
    assert(bf1 == bf2);

    bf2 = BitField!uint(6);
    assert(bf2 != bf1);

    bf2[0] = true;
    bf2[2] = true;
    bf2[4] = true;
    assert(bf2 == bf1);

    bf2[5] = true;
    assert(bf2 != bf1);
}

// Serialization tests
unittest
{
    testSymmetry!(BitField!ubyte)();
    testSymmetry!(BitField!ushort)();
    testSymmetry!(BitField!uint)();
    testSymmetry!(BitField!ulong)();

    // less than 1 byte
    {
        auto bf = BitField!uint(6);
        bf[0] = bf[5] = true;
        testSymmetry(bf);
    }

    // exactly 1 byte
    {
        auto bf = BitField!uint(8);
        bf[0] = bf[7] = true;
        testSymmetry(bf);
    }

    // more than 1 byte
    {
        auto bf = BitField!uint(12);
        bf[0] = bf[1] = true;
        testSymmetry(bf);
    }

    // 3 bytes
    {
        auto bf = BitField!uint(28);
        bf[0] = bf[27] = true;
        testSymmetry(bf);
    }

    // more than 4 bytes (backing store is uint)
    {
        auto bf = BitField!uint(40);
        bf[0] = bf[39] = true;
        testSymmetry(bf);
    }
}
