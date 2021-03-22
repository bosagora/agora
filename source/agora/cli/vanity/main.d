/*******************************************************************************

    A vanity address generator

    This tool is used to generate the "well-known" keypairs used in unittests.
    Note that we generate the binary data directly to limit CTFE overhead.

    `stdout` is used for output of the address (so it can be redirected as the
    list is large), and `stderr` for debugging.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.cli.vanity.main;

import agora.crypto.ECC;
import agora.crypto.Key;
import agora.crypto.Types;

import core.atomic;
import std.parallelism;
import std.range;
import std.stdio;
import std.string;

/// Change this directly to generate different size
enum size_t MaxNameSize = 3;

/**
 * Addresses always start with G{A,B,C,D}
 * We pick the addresses that start with GD, then match our expected
 * char, and are followed by a `2`, so that we have an 'end marker'
 * in case we want more letters (e.g. AA or AAA).
 * Removing this check will yield much better performance at the expense of less
 * predictable pattern.
 */
enum char FirstChar = 'D';
/// The end marker to use after the pattern
enum char EndMarker = '2';

/// The index at which the pattern starts
enum size_t FirstIdx = 2;
/// The number of `EndMarker` that should be after the pattern
enum size_t MarkerCount = 2;

// Constant that depend on the previous constant
alias Name = char[MaxNameSize];
immutable size_t KeyCountTarget = totalKeyCount(MaxNameSize);
enum size_t LastIdx = FirstIdx + MaxNameSize;

/// Useful constant for iteration
immutable Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
static assert(Alphabet.length == 26);

immutable string[] SpecialNames = [
    "GENESIS",
    "COMMONS",
    "NODE2",
    "NODE3",
    "NODE4",
    "NODE5",
    "NODE6",
    "NODE7",
];

/// Stored globally to avoid large stack / TLS issues
__gshared Scalar[KeyCountTarget + SpecialNames.length] result;
__gshared bool[KeyCountTarget + SpecialNames.length] foundMap;

void main (string[] args)
{
    shared size_t found;
    foreach (_; parallel(iota(42)))
    {
    NextKey:
        while (atomicLoad(found) < result.length)
        {
            auto tmp = Pair.random();

            // TODO: Use binary to avoid `toString` call
            const addr = PublicKey(tmp.V).toString();

            // Make sure we starts with `GD`
            if (addr[1] != FirstChar)
                continue;

            // Find match for letter(s)
            if (addr[2] < 'A' || addr[2] > 'Z')
                continue;

            if (auto index = specialNameIndex(addr))
            {
                // If already found, still print it as they are pretty rare
                if (!found.onFound(index, tmp.v))
                {
                    stderr.writeln("\nFound another candidate for special names: ",
                                 addr, SecretKey(tmp.v).toString(PrintMode.Clear));
                    continue NextKey;
                }

                stderr.writeln("\nFound special name: ", addr, " - ",
                               SecretKey(tmp.v).toString(PrintMode.Clear));
                continue NextKey;
            }

            size_t endMarkerSeen;
            immutable MarkerStart = LastIdx - FirstIdx;
        Search:
            foreach (size_t idx, char c; addr[FirstIdx .. LastIdx + MarkerCount])
            {
                switch (c)
                {
                    // Maybe a match?
                case EndMarker:
                    // All good
                    if (++endMarkerSeen >= MarkerCount)
                    {
                        const name = addr[FirstIdx .. FirstIdx + 1 + idx - MarkerCount];
                        const index = nameIndex(name);
                        // Whether we already found it or not, we go to the next key
                        found.onFound(index, tmp.v);
                        continue NextKey;
                    }
                    continue Search;

                    // Longer key, store it and keep looking
                case 'A': .. case 'Z':
                    if (endMarkerSeen || idx >= MarkerStart)
                        continue NextKey;
                    continue Search;

                    // No match
                default:
                    continue NextKey;
                }
            }
        }
    }

    foreach (index, ref seed; result[0 .. KeyCountTarget])
    {
        const name = indexName(index);
        auto kp = Pair.fromScalar(seed);
        printKey(name, kp);
    }

    writeln("==================================================");
    foreach (index, ref seed; result[KeyCountTarget .. $])
    {
        auto kp = Pair.fromScalar(seed);
        printKey(SpecialNames[index], kp);
    }
}

/// Little helper function. Returns `false` if the key is already known
private bool onFound (ref shared size_t found, size_t index, Scalar value)
{
    // If already found, still print it as they are pretty rare
    if (!cas(&foundMap[index], false, true))
        return false;

    found.atomicOp!("+=")(1);
    result[index] = value;
    stderr.write("\rKeys found: ", atomicLoad(found), "/", foundMap.length);
    stderr.flush();
    return true;
}

/// Print the key to stdout
private void printKey (const(char)[] name, Pair kp)
{
    stdout.writefln("/// %s: %s", name, PublicKey(kp.V));
    stdout.writefln("static immutable %s = KeyPair(PublicKey(Point(%s)), SecretKey(Scalar(%s)));",
                    name.strip, kp.V[], kp.v[]);
}

/// Check special target: GENESIS, COMMONS, NODE...
private size_t specialNameIndex (const(char)[] name)
{
    static foreach (idx, n; SpecialNames)
    {
        if (name[2 .. 2 + n.length] == n)
        {
            static if (idx == 0 || idx == 1)
                return (name[2 + n.length] >= '0' && name[2 + n.length] <= '9')
                    ? idx + KeyCountTarget: 0;
            else
                return (name[2 + n.length] >= 'A' && name[2 + n.length] <= 'Z')
                    ? idx + KeyCountTarget: 0;
        }
    }

    return 0;
}

//
unittest
{
    assert(specialNameIndex("GDGENESIS42") == KeyCountTarget + 0);
    assert(specialNameIndex("GDCOMMONS42") == KeyCountTarget + 1);
    assert(specialNameIndex("GDNODE2A")    == KeyCountTarget + 2);
    assert(specialNameIndex("GDNODE3B")    == KeyCountTarget + 3);
    assert(specialNameIndex("GDNODE4C")    == KeyCountTarget + 4);
    assert(specialNameIndex("GDNODE5D")    == KeyCountTarget + 5);
    assert(specialNameIndex("GDNODE6E")    == KeyCountTarget + 6);
    assert(specialNameIndex("GDNODE7F")    == KeyCountTarget + 7);

    assert(specialNameIndex("GDGENESISS123") == 0);
    assert(specialNameIndex("GDCOMMONSA456") == 0);
    assert(specialNameIndex("GDNODE74FF")    == 0);
    assert(specialNameIndex("GDNODES24FF")   == 0);
}

/// Returns: The total number of keys for this range and all smaller ranges
private size_t totalKeyCount (size_t count) pure nothrow @nogc @safe
{
    size_t result;
    while (count)
    {
        result += 26 ^^ count;
        --count;
    }
    return result;
}

unittest
{
    static assert(totalKeyCount(0) == 0);
    static assert(totalKeyCount(1) == 26);
    static assert(totalKeyCount(2) == 26 + 26 * 26);
    static assert(totalKeyCount(3) == 26 + 26 * 26 + 26 * 26 * 26);
}

/// Returns: The index of a given pattern
private size_t nameIndex (scope const(char)[] name) pure nothrow @nogc @safe
{
    assert(name.length <= Name.length, name);
    size_t result;
    immutable bool needOffset = name.length > 1;
    foreach (size_t index, char c; name)
    {
        assert(c >= 'A' && c <= 'Z');
        const multiplier = (c - 'A') + (index + 1 < name.length);
        result += multiplier * Alphabet.length ^^ (name.length - 1 - index);
    }
    return result;
}

unittest
{
    // Total: 26 * 26 * 26 + 26 * 26 + 26 - 1
    size_t idx;
    Name name;

    // First 26
    {
        foreach (c1; 'A' .. cast(char)('Z' + 1))
        {
            name[0] = c1;
            assert(idx++ == nameIndex(name[0 .. 1]));
        }
    }

    // Next 26 * 26
    static if (Name.length >=  2)
    {
        foreach (c1; 'A' .. cast(char)('Z' + 1))
        foreach (c2; 'A' .. cast(char)('Z' + 1))
        {
            name[0 .. 2] = [c1, c2];
            assert(idx++ == nameIndex(name[0 .. 2]));
        }
    }

    // Last 26 * 26 * 26
    static if (Name.length >=  3)
    {
        foreach (c1; 'A' .. cast(char)('Z' + 1))
        foreach (c2; 'A' .. cast(char)('Z' + 1))
        foreach (c3; 'A' .. cast(char)('Z' + 1))
        {
            name = [c1, c2, c3];
            assert(idx++ == nameIndex(name));
        }
    }

    static assert(Name.length <= 3, "Add tests for `nameIndex` with `Name.length > 3`");
}

/// Returns: The name at a given index
private const(char)[] indexName (size_t index) //pure nothrow @safe
{
    Name result;
    size_t iterations = 1;

    while (index >= totalKeyCount(iterations))
        iterations++;

    for (size_t iter = 0; iter < iterations; ++iter)
    {
        result[$ - 1 - iter] = Alphabet[index % $];
        index /= Alphabet.length;
        index--;
    }
    return result[$ - iterations .. $].dup;
}

unittest
{
    assert(indexName(0) == "A");
    assert(indexName(3) == "D");
    assert(indexName(25) == "Z");
    static if (Name.length >= 2)
    {
        assert(indexName(26) == "AA");
        assert(indexName(26 * 2) == "BA");
        assert(indexName(26 * 2 + 1) == "BB");
        assert(indexName(26 * 3 - 1) == "BZ");
        assert(indexName(26 + 26 * 25) == "ZA");
        assert(indexName(26 + 26 * 26 - 1) == "ZZ");
    }
    static if (Name.length >= 3)
    {
        assert(indexName(26 + 26 * 26) == "AAA");
        assert(indexName(26 + 26 * 26 + 26 * 26 * 26) == "ZAA");
        assert(indexName(25 + 26 * 25 + 26 * 26 * 26) == "ZZZ");
    }

    foreach (idx; 0 .. totalKeyCount(Name.length))
        assert(nameIndex(indexName(idx)) == idx);

    static assert(Name.length <= 3, "Add tests for `indexName` with `Name.length > 3`");
}
