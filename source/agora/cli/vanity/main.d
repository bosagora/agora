/*******************************************************************************

    A vanity address generator

    This tool is used to generate the "well-known" keypairs used in unittests.
    Note that we generate the binary data directly to limit CTFE overhead.

    `stdout` is used for output of the address (so it can be redirected as the
    list is large), and `stderr` for debugging.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.cli.vanity.main;

import agora.common.crypto.Key;

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

/// Stored globally to avoid large stack / TLS issues
__gshared Seed[KeyCountTarget] result;

void main (string[] args)
{
    shared size_t found;
    foreach (_; parallel(iota(42)))
    {
    NextKey:
        while (atomicLoad(found) < result.length)
        {
            auto tmp = KeyPair.random();

            // TODO: Use binary to avoid `toString` call
            const addr = tmp.address.toString();

            // Make sure we starts with `GD`
            if (addr[1] != FirstChar)
                continue;

            // Find match for letter(s)
            if (addr[2] < 'A' || addr[2] > 'Z')
                continue;

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
                        // If already found, ignore
                        if (!cas(&result[index][][0], ubyte.init, ubyte(1)))
                            continue NextKey;
                        atomicOp!("+=")(found, 1);
                        result[index] = tmp.seed;
                        //printKey(name, tmp);
                        stderr.write("\rKeys found: ", atomicLoad(found), "/", KeyCountTarget);
                        stderr.flush();
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

    foreach (index, ref seed; result)
    {
        const name = indexName(index);
        auto kp = KeyPair.fromSeed(seed);
        printKey(name, kp);
    }
}

/// Print the key to stdout
private void printKey (const(char)[] name, KeyPair kp)
{
    stdout.writefln("/// %s: %s", name, kp.address);
    stdout.writefln("static immutable %s = KeyPair(PublicKey(%s), SecretKey(%s), Seed(%s));",
                    name.strip, kp.address[], kp.secret[], kp.seed[]);
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
