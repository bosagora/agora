/*******************************************************************************

    Contains a simple Set implementation (wrapper around builtin hashmaps)

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Set;

import agora.common.Data;

import libsodium.randombytes;

import std.algorithm;

import core.stdc.string;

/// simplified Set() code with some convenience methods,
/// could use a drop-in implementation later.
struct Set (T)
{
    ///
    bool[][T] _set;
    alias _set this;

    /// Put an element in the set
    public void put ( T key )
    {
        this._set[key] = [];
    }

    /// Remove an element from the set
    public void remove ( T key )
    {
        this._set.remove(key);
    }

    /// Walk over all elements and call dg(elem)
    public int opApply ( int delegate(T) dg )
    {
        foreach (key; this._set.byKey)
        {
            if (auto ret = dg(key))
                return ret;
        }

        return 0;
    }

    /// Build a new Set out of the provided range
    public static Set from ( Range ) ( Range range)
    {
        typeof(return) map;
        foreach (T item; range)
            map.put(item);
        return map;
    }

    /// Fill an existing set with elements from an array
    public void fill ( const(T)[] rhs )
    {
        foreach (key; rhs)
            this.put(key);
    }
}

/// fill the buffer with the set's keys
private void fillFrom ( T ) ( ref T[] buffer, Set!T input )
{
    buffer.length = input.length;
    assumeSafeAppend(buffer);

    size_t idx;
    foreach (address; input)
        buffer[idx++] = address;
}

/// Pick random 'count' elements from the input set,
/// and return an array of the elements (not very memory-efficient)
public T[] pickRandom (T) ( Set!T input, size_t count )
{
    static T[] buffer;
    buffer.fillFrom(input);

    const expected_count = min(count, buffer.length);

    // todo: a faster method could be to swap(last_idx, new_idx)
    T[] result;
    while (result.length < expected_count)
    {
        auto idx = randombytes_uniform(cast(uint)buffer.length);
        result ~= buffer[idx];
        buffer.dropIndex(idx);
    }

    return result;
}

///
unittest
{
    auto set = Set!int.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    auto randoms = set.pickRandom(5);
    sort(randoms);
    assert(randoms.uniq.count == 5);
}

/**
    Drop element at index from array and update array length.
    Note: This is extremely unsafe, it assumes there are no
    other pointers to the internal slice memory.
*/
private void dropIndex (T) (ref T[] arr, size_t index)
{
    assert(index < arr.length);
    immutable newLen = arr.length - 1;

    if (index != newLen)
        memmove(&(arr[index]), &(arr[index + 1]), T.sizeof * (newLen - index));

    arr.length = newLen;
}

///
unittest
{
    int[] arr = [1, 2, 3];
    arr.dropIndex(1);
    assert(arr == [1, 3]);
}
