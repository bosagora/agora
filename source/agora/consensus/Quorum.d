/*******************************************************************************

    Contains the quorum generator algorithm.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.Quorum;

import agora.common.Amount;
import agora.common.BitMask;
import agora.common.Config;
import agora.common.Set;
import agora.common.Types;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.state.UTXOCache;
import agora.crypto.Hash;
import agora.crypto.Key;

import scpd.Cpp;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types : NodeID;
import scpd.types.Utils;
import scpd.types.XDRBase;
import scpd.quorum.QuorumTracker;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.format;
import std.math;
import std.random;
import std.range;
import std.string;
import std.typecons;

version (unittest)
{
    import agora.utils.Test;
    import std.stdio;
}

/// The quorum generator parameters which can be tweaked.
public struct QuorumParams
{
    /// Maximum number of nodes to include in a quorum.
    const MaxQuorumNodes = 7;

    /// Threshold percentage to use for the quorum configuration
    const uint QuorumThreshold = 80;
}

/*******************************************************************************

    Build the quorum configuration for the given public key and the registered
    enrollment keys. The random seed is used to introduce partial randomness
    to the quorum assignment of each node.

    Params:
        key = the key of the node for which to generate the quorum
        utxo_keys = the list of UTXO keys of all the active enrollments
        finder = UTXO finder delegate
        rand_seed = the random seed
        params = quorum generator algorithm tweaking parameters

*******************************************************************************/

public QuorumConfig buildQuorumConfig (in Hash key, in Hash[] utxo_keys,
    scope UTXOFinder finder, in Hash rand_seed, const ref QuorumParams params)
    @safe nothrow
{
    // special-case: only 1 validator is active
    if (utxo_keys.length == 1)
        return QuorumConfig(1, [key]);

    // not including our own
    NodeStake[] stakes = buildStakesDescending(key, utxo_keys, finder);

    QuorumConfig quorum;
    quorum.nodes ~= key;  // add ourself first

    // for filtering duplicates from dice()
    auto added = BitMask(stakes.length);
    auto RNG_gen = getGenerator(key, rand_seed);
    auto stake_amounts = stakes.map!(stake => stake.amount.integral);

    static assumeNothrow (T)(lazy T exp) nothrow
    {
        try return exp();
        catch (Exception ex) assert(0, ex.msg);
    }

    // +1 as we already added ourself
    const MaxNodes = min(stakes.length + 1, params.MaxQuorumNodes);
    while (quorum.nodes.length < MaxNodes)
    {
        // dice() can only throw if the sum of stakes is zero
        auto idx = assumeNothrow(dice(RNG_gen, stake_amounts));
        if (added[idx])  // skip duplicate
            continue;

        quorum.nodes ~= stakes[idx].utxo_key;
        added[idx] = true;  // mark used
    }

    quorum.nodes.sort;
    quorum.threshold = max(1, cast(uint)ceil(
        (params.QuorumThreshold * double(0.01)) * quorum.nodes.length));
    return quorum;
}

/// 1 node
unittest
{
    auto keys = getKeys(1);
    PublicKey[Hash] utxo_to_key;
    auto quorums = buildTestQuorums(Amount.MinFreezeAmount.only, keys,
        hashFull(1), QuorumParams.init, 0, utxo_to_key);
    verifyQuorumsSanity(quorums);
    verifyQuorumsIntersect(quorums);
    assert(countNodeInclusions(quorums, keys, utxo_to_key) == [1]);
}

// 2 nodes
unittest
{
    auto keys = getKeys(2);
    PublicKey[Hash] utxo_to_key;
    auto quorums = buildTestQuorums(Amount.MinFreezeAmount.repeat(2), keys,
        hashFull(1), QuorumParams.init, 1, utxo_to_key);
    verifyQuorumsSanity(quorums);
    verifyQuorumsIntersect(quorums);
    assert(countNodeInclusions(quorums, keys, utxo_to_key) == [2, 2]);
}

// 3 nodes with equal stakes
unittest
{
    auto keys = getKeys(3);
    PublicKey[Hash] utxo_to_key;
    auto quorums = buildTestQuorums(Amount.MinFreezeAmount.repeat(3), keys,
        hashFull(1), QuorumParams.init, 2, utxo_to_key);
    verifyQuorumsSanity(quorums);
    verifyQuorumsIntersect(quorums);
    assert(countNodeInclusions(quorums, keys, utxo_to_key) == [3, 3, 3]);
}

// 4 nodes with equal stakes
unittest
{
    auto keys = getKeys(4);
    PublicKey[Hash] utxo_to_key;
    auto quorums = buildTestQuorums(Amount.MinFreezeAmount.repeat(4), keys,
        hashFull(1), QuorumParams.init, 3, utxo_to_key);
    verifyQuorumsSanity(quorums);
    verifyQuorumsIntersect(quorums);
    assert(countNodeInclusions(quorums, keys, utxo_to_key) == [4, 4, 4, 4]);
}

// 8 nodes with equal stakes
unittest
{
    auto keys = getKeys(8);
    PublicKey[Hash] utxo_to_key;
    auto quorums_1 = buildTestQuorums(Amount.MinFreezeAmount.repeat(8), keys,
        hashFull(1), QuorumParams.init, 4, utxo_to_key);
    verifyQuorumsSanity(quorums_1);
    verifyQuorumsIntersect(quorums_1);
    assert(countNodeInclusions(quorums_1, keys, utxo_to_key) == [7, 6, 8, 8, 7, 8, 7, 5]);

    PublicKey[Hash] utxo_to_key_2;
    auto quorums_2 = buildTestQuorums(Amount.MinFreezeAmount.repeat(8), keys,
        hashFull(2), QuorumParams.init, 5, utxo_to_key_2);
    verifyQuorumsSanity(quorums_2);
    verifyQuorumsIntersect(quorums_2);
    assert(countNodeInclusions(quorums_2, keys, utxo_to_key_2) == [8, 7, 8, 5, 6, 8, 7, 7]);
}

// 16 nodes with equal stakes
unittest
{
    auto keys = getKeys(16);
    PublicKey[Hash] utxo_to_key;
    auto quorums_1 = buildTestQuorums(Amount.MinFreezeAmount.repeat(16), keys,
        hashFull(1), QuorumParams.init, 6, utxo_to_key);
    verifyQuorumsSanity(quorums_1);
    verifyQuorumsIntersect(quorums_1);
    assert(countNodeInclusions(quorums_1, keys, utxo_to_key) ==
        [6, 8, 10, 8, 6, 10, 6, 10, 7, 6, 9, 4, 6, 5, 6, 5]);

    PublicKey[Hash] utxo_to_key_2;
    auto quorums_2 = buildTestQuorums(Amount.MinFreezeAmount.repeat(16), keys,
        hashFull(2), QuorumParams.init, 7, utxo_to_key_2);
    verifyQuorumsSanity(quorums_2);
    verifyQuorumsIntersect(quorums_2);
    assert(countNodeInclusions(quorums_2, keys, utxo_to_key_2) ==
        [5, 9, 4, 8, 9, 8, 9, 7, 5, 5, 7, 7, 9, 8, 5, 7]);
}

// 16 nodes with linearly ascending stakes
unittest
{
    auto amounts = iota(16)
        .map!(idx => Amount(400000000000uL + (100000000000uL * idx)));
    auto keys = getKeys(16);
    PublicKey[Hash] utxo_to_key;
    auto quorums_1 = buildTestQuorums(amounts, keys, hashFull(1),
        QuorumParams.init, 8, utxo_to_key);
    verifyQuorumsSanity(quorums_1);
    verifyQuorumsIntersect(quorums_1);
    assert(countNodeInclusions(quorums_1, keys, utxo_to_key) ==
        [2, 1, 6, 7, 5, 4, 9, 6, 7, 7, 10, 13, 8, 11, 7, 9]);

    PublicKey[Hash] utxo_to_key_2;
    auto quorums_2 = buildTestQuorums(amounts, keys, hashFull(2),
        QuorumParams.init, 9, utxo_to_key_2);
    verifyQuorumsSanity(quorums_2);
    verifyQuorumsIntersect(quorums_2);
    assert(countNodeInclusions(quorums_2, keys, utxo_to_key_2) ==
        [3, 3, 4, 4, 3, 6, 11, 3, 8, 8, 9, 8, 9, 10, 11, 12]);
}

// 16 nodes where two nodes own 66% of the stake
unittest
{
    auto keys = getKeys(16);
    auto amounts = Amount(400000000000uL).repeat(16).array;
    amounts[0] = amounts[$ - 1] = Amount(400000000000uL * 14);
    PublicKey[Hash] utxo_to_key;
    auto quorums_1 = buildTestQuorums(amounts, keys, hashFull(1),
        QuorumParams.init, 10, utxo_to_key);
    verifyQuorumsSanity(quorums_1);
    verifyQuorumsIntersect(quorums_1);
    assert(countNodeInclusions(quorums_1, keys, utxo_to_key) ==
        [16, 5, 7, 9, 4, 8, 7, 5, 5, 7, 6, 6, 4, 4, 4, 15]);

    PublicKey[Hash] utxo_to_key_2;
    auto quorums_2 = buildTestQuorums(amounts, keys, hashFull(2),
        QuorumParams.init, 11, utxo_to_key_2);
    verifyQuorumsSanity(quorums_2);
    verifyQuorumsIntersect(quorums_2);
    assert(countNodeInclusions(quorums_2, keys, utxo_to_key_2) ==
        [16, 6, 4, 7, 6, 7, 4, 4, 6, 10, 6, 6, 7, 5, 3, 15]);
}

// 32 nodes where two nodes own 66% of the stake
unittest
{
    auto keys = getKeys(32);
    auto amounts = Amount(400000000000uL).repeat(32).array;
    amounts[0] = amounts[$ - 1] = Amount(400000000000uL * 30);
    PublicKey[Hash] utxo_to_key;
    auto quorums_1 = buildTestQuorums(amounts, keys, hashFull(1),
        QuorumParams.init, 12, utxo_to_key);
    verifyQuorumsSanity(quorums_1);
    // verified to work but disabled because it runs slow with a
    // non-max threshold (~20 seconds)
    //verifyQuorumsIntersect(quorums_1);
    assert(countNodeInclusions(quorums_1, keys, utxo_to_key) ==
        [32, 4, 3, 5, 5, 6, 7, 5, 5, 7, 8, 6, 3, 5, 5, 3, 8, 4, 4, 5, 5, 4, 8,
         5, 7, 8, 4, 6, 5, 5, 5, 32]);

    PublicKey[Hash] utxo_to_key_2;
    auto quorums_2 = buildTestQuorums(amounts, keys, hashFull(2),
        QuorumParams.init, 13, utxo_to_key_2);
    verifyQuorumsSanity(quorums_2);
    // verified to work but disabled because it runs slow with a
    // non-max threshold (~20 seconds)
    //verifyQuorumsIntersect(quorums_2);
    assert(countNodeInclusions(quorums_2, keys, utxo_to_key_2) ==
        [32, 3, 4, 4, 6, 4, 2, 5, 6, 6, 6, 3, 6, 5, 6, 5, 9, 4, 9, 9, 10, 4, 5,
         10, 6, 3, 9, 4, 2, 3, 2, 32]);
}

// 64 nodes where two nodes own 66% of the stake
unittest
{
    auto keys = getKeys(64);
    auto amounts = Amount(400000000000uL).repeat(64).array;
    amounts[0] = amounts[$ - 1] = Amount(400000000000uL * 62);
    PublicKey[Hash] utxo_to_key;
    auto quorums_1 = buildTestQuorums(amounts, keys, hashFull(1),
        QuorumParams.init, 14, utxo_to_key);
    verifyQuorumsSanity(quorums_1);
    // verified to work but disabled because it runs slow with a
    // non-max threshold (~20 minutes)
    //verifyQuorumsIntersect(quorums_1);
    assert(countNodeInclusions(quorums_1, keys, utxo_to_key) ==
        [63, 6, 6, 4, 5, 5, 6, 2, 7, 2, 9, 4, 3, 3, 12, 4, 2, 3, 5, 6, 5, 4, 3,
         7, 4, 3, 7, 3, 3, 3, 4, 7, 6, 5, 6, 7, 7, 6, 10, 4, 2, 5, 7, 5, 4, 6,
         6, 9, 5, 5, 5, 7, 5, 8, 7, 6, 5, 4, 3, 4, 5, 7, 4, 63]);

    PublicKey[Hash] utxo_to_key_2;
    auto quorums_2 = buildTestQuorums(amounts, keys, hashFull(2),
        QuorumParams.init, 15, utxo_to_key_2);
    verifyQuorumsSanity(quorums_2);
    // verified to work but disabled because it runs slow with a
    // non-max threshold (~20 minutes)
    //verifyQuorumsIntersect(quorums_2);
    assert(countNodeInclusions(quorums_2, keys, utxo_to_key_2) ==
        [62, 8, 4, 7, 8, 4, 5, 6, 5, 2, 3, 6, 4, 6, 3, 8, 3, 8, 5, 5, 7, 3, 5, 2,
         3, 1, 3, 7, 5, 6, 7, 3, 5, 7, 6, 8, 2, 8, 8, 7, 3, 5, 7, 3, 4, 9, 2, 3,
         8, 2, 8, 5, 8, 5, 6, 9, 6, 2, 2, 4, 7, 7, 6, 62]);
}

// 128 nodes where two nodes own 66% of the stake
unittest
{
    auto keys = getKeys(128);
    auto amounts = Amount(400000000000uL).repeat(128).array;
    amounts[0] = amounts[$ - 1] = Amount(400000000000uL * 126);
    PublicKey[Hash] utxo_to_key;
    auto quorums_1 = buildTestQuorums(amounts, keys, hashFull(1),
        QuorumParams.init, 16, utxo_to_key);
    verifyQuorumsSanity(quorums_1);
    // not verified to work.
    //verifyQuorumsIntersect(quorums_1);
    assert(countNodeInclusions(quorums_1, keys, utxo_to_key) ==
        [125, 5, 4, 3, 6, 5, 4, 6, 3, 5, 3, 2, 4, 4, 4, 3, 4, 3, 5, 5, 11, 7, 9,
         4, 4, 3, 4, 5, 4, 6, 3, 8, 3, 6, 7, 4, 9, 4, 5, 6, 5, 6, 6, 2, 4, 3,
         8, 6, 4, 4, 5, 9, 10, 8, 4, 6, 3, 4, 6, 4, 7, 7, 6, 2, 5, 7, 5, 6, 7,
         3, 5, 4, 7, 5, 7, 5, 2, 7, 3, 5, 5, 4, 4, 11, 4, 7, 5, 7, 10, 3, 4, 3,
         5, 4, 8, 7, 5, 3, 4, 4, 3, 2, 2, 5, 5, 4, 7, 3, 4, 7, 6, 8, 5, 3, 4, 6,
         6, 4, 7, 8, 6, 8, 4, 6, 4, 4, 6, 125]);

    PublicKey[Hash] utxo_to_key_2;
    auto quorums_2 = buildTestQuorums(amounts, keys, hashFull(2),
        QuorumParams.init, 17, utxo_to_key_2);
    verifyQuorumsSanity(quorums_2);
    // not verified to work.
    //verifyQuorumsIntersect(quorums_2);
    assert(countNodeInclusions(quorums_2, keys, utxo_to_key_2) ==
        [120, 8, 3, 7, 8, 4, 7, 3, 7, 4, 3, 4, 5, 5, 2, 4, 10, 4, 4, 5, 4, 3, 7,
         5, 5, 5, 6, 6, 2, 5, 7, 8, 7, 3, 5, 3, 8, 3, 3, 3, 4, 5, 8, 4, 6, 3,
         7, 6, 5, 6, 4, 7, 2, 4, 5, 6, 3, 5, 3, 4, 3, 5, 3, 9, 8, 11, 7, 3, 6,
         5, 3, 9, 5, 7, 3, 6, 3, 5, 4, 8, 5, 7, 3, 5, 4, 6, 8, 5, 3, 5, 7, 5,
         7, 8, 1, 7, 4, 3, 7, 3, 3, 5, 4, 5, 3, 6, 5, 8, 5, 3, 7, 8, 1, 7, 9,
         7, 7, 7, 5, 4, 6, 4, 4, 6, 3, 6, 5, 125]);
}

// using various different quorum parameter configurations
unittest
{
    QuorumParams qp_1 = { MaxQuorumNodes : 4, QuorumThreshold : 80 };
    auto keys = getKeys(10);
    PublicKey[Hash] utxo_to_key;
    auto quorums_1 = buildTestQuorums(Amount.MinFreezeAmount.repeat(10), keys,
        hashFull(1), qp_1, 18, utxo_to_key);
    verifyQuorumsSanity(quorums_1);
    verifyQuorumsIntersect(quorums_1);
    quorums_1.byValue.each!(qc => assert(qc.nodes.length <= 4));
    quorums_1.byValue.each!(qc => assert(qc.threshold == 4));
    assert(countNodeInclusions(quorums_1, keys, utxo_to_key) ==
        [5, 6, 6, 3, 2, 4, 3, 4, 3, 4]);

    QuorumParams qp_2 = { MaxQuorumNodes : 8, QuorumThreshold : 80 };
    PublicKey[Hash] utxo_to_key_2;
    auto quorums_2 = buildTestQuorums(Amount.MinFreezeAmount.repeat(10), keys,
        hashFull(1), qp_2, 19, utxo_to_key_2);
    verifyQuorumsSanity(quorums_2);
    verifyQuorumsIntersect(quorums_2);
    quorums_2.byValue.each!(qc => assert(qc.nodes.length <= 8));
    quorums_2.byValue.each!(qc => assert(qc.threshold == 7));
    assert(countNodeInclusions(quorums_2, keys, utxo_to_key_2) ==
        [7, 9, 8, 9, 7, 6, 7, 9, 9, 9]);

    QuorumParams qp_3 = { MaxQuorumNodes : 8, QuorumThreshold : 60 };
    PublicKey[Hash] utxo_to_key_3;
    auto quorums_3 = buildTestQuorums(Amount.MinFreezeAmount.repeat(10), keys,
        hashFull(1), qp_3, 20, utxo_to_key_3);
    verifyQuorumsSanity(quorums_3);
    verifyQuorumsIntersect(quorums_3);
    quorums_3.byValue.each!(qc => assert(qc.nodes.length <= 8));
    quorums_3.byValue.each!(qc => assert(qc.threshold == 5));
    assert(countNodeInclusions(quorums_3, keys, utxo_to_key_3),
        [9, 7, 6, 9, 8, 7, 10, 9, 5, 10]);
}

version (unittest)
private const(PublicKey)[] getKeys (size_t count)
{
    return WK.Keys.byRange.take(count).map!(kp => kp.address).array;
}

/// Create a shorthash from a 64-byte blob for RNG initialization
private ulong toShortHash (in Hash hash) @trusted nothrow
{
    import libsodium.crypto_shorthash;
    import std.bitmanip;

    // using a once-generated initialization vector
    static immutable ubyte[crypto_shorthash_KEYBYTES] IV =
        [111, 165, 189, 80, 37, 5, 16, 194, 39, 214, 156, 169, 235, 221, 21, 126];
    ubyte[ulong.sizeof] short_hash;
    crypto_shorthash(short_hash.ptr, hash[].ptr, hash[].length, IV.ptr);

    // assume a specific endianess for consistency in how we convert to ulong
    return littleEndianToNative!ulong(short_hash[]);
}

///
unittest
{
    const hash1 = hashMulti(WK.Keys.A.address, 1);
    assert(toShortHash(hash1) == 501230441541515792);
    const hash2 = hashMulti(WK.Keys.A.address, 2);
    assert(toShortHash(hash2) == 9723839611455071876);
}

/*******************************************************************************

    Create a random number generator which uses the node's public key hashed
    with the random seed as an initializer for the RNG engine.

    Using the Mersene Twister 19937 64-bit random number generator.
    The public key is reduced to a short hash of 8 bytes which is then
    used to initialize the RNG generator.

    Params
        key = the UTXO key for enrollment of a node
        rand_seed = the random seed

    Returns:
        a Mersenne Twister 64bit random generator

*******************************************************************************/

private auto getGenerator (const ref Hash key, in Hash rand_seed)
    @safe nothrow
{
    Mt19937_64 gen;
    const hash = hashMulti(key, rand_seed);
    gen.seed(toShortHash(hash));
    return gen;
}

/// The pair of (key, utxo_key, stake) for each node
private struct NodeStake
{
    /// the node key
    private PublicKey key;

    /// the UTXO key for enrollment
    private Hash utxo_key;

    /// the node stake
    private Amount amount;
}

/*******************************************************************************

    Build a list of NodeStake's in descending stake order

    Params
        filter = the UTXO of the node's enrollment should be filtered here
        utxo_keys = the list of enrollments' UTXO keys
        finder = delegate to find the public key & stake of each UTXO key

    Returns:
        the list of stakes in descending stake order

*******************************************************************************/

private NodeStake[] buildStakesDescending (const ref Hash filter,
    in Hash[] utxo_keys, scope UTXOFinder finder) @safe nothrow
{
    static NodeStake[] stakes;
    stakes.length = 0;
    () @trusted { assumeSafeAppend(stakes); }();

    foreach (utxo_key; utxo_keys)
    {
        UTXO value;
        assert(finder(utxo_key, value), "UTXO for validator not found!");

        if (utxo_key != filter)
            stakes ~= NodeStake(value.output.address, utxo_key, value.output.value);
    }

    stakes.sort!((a, b) => a.amount > b.amount);
    return stakes;
}

/*******************************************************************************

    Build the quorum configs for the given enrollments and range of seeds,
    and return a map of the number of times each node was included in
    another node's quorum set.

    Returns:
        the map of generated quorum configs

*******************************************************************************/

version (unittest)
private QuorumConfig[Hash] buildTestQuorums (Range)(Range amounts,
    const(PublicKey)[] keys, const auto ref Hash rand_seed,
    const auto ref QuorumParams params, int id, out PublicKey[Hash] utxo_to_key)
{
    assert(amounts.length == keys.length);
    QuorumConfig[Hash] quorums;
    TestUTXOSet storage = new TestUTXOSet;
    Hash[PublicKey] key_to_utxo;
    foreach (idx, const ref amount; amounts.save.enumerate)
    {
        Transaction tx = Transaction([ Output(amount, keys[idx], OutputType.Freeze) ]);

        // simulating our own UTXO hashes to make the tests stable
        Hash txhash = hashMulti(id, idx, amount);
        foreach (size_t out_idx, ref output_; tx.outputs)
        {
            UTXO v = {
                output: output_
            };
            storage[txhash] = v;
            key_to_utxo[keys[idx]] = txhash;
            utxo_to_key[txhash] = keys[idx];
        }
    }


    Hash[] utxos = storage.keys;
    foreach (idx, _; amounts.enumerate)
    {
        quorums[key_to_utxo[keys[idx]]] = buildQuorumConfig(
            key_to_utxo[keys[idx]], utxos, &storage.peekUTXO, rand_seed, params);
    }

    return quorums;
}

/*******************************************************************************

    For each node count the number of times it has been included in
    each quorum configuration.

    Params:
        quorums = the generated quorums
        keys = the keys we want to look up. Used separately from the ones in
            'quorums' to make it easy to test assumed key positions
            [WK.Keys.A, WK.Keys.B], etc.

    Returns:
        the count of each node's inclusion in quorum sets,
        where the index matches the 'keys' array.

*******************************************************************************/

version (unittest)
private size_t[] countNodeInclusions (QuorumConfig[Hash] quorums,
    in PublicKey[] keys, ref PublicKey[Hash] utxo_to_key)
{
    size_t[const(PublicKey)] counts;

    foreach (_, const ref qc; quorums)
        qc.nodes.each!(node => counts[utxo_to_key[node]]++);

    size_t[] results;
    foreach (key; keys)
    {
        assert(key in counts);
        results ~= counts[key];
    }

    return results;
}

/*******************************************************************************

    Verify that the provided quorum sets are considered sane by SCP.

    The quorums are checked both pre and post-normalization,
    with extra safety checks enabled.

    Params:
        quorums = the quorum maps to verify

    Throws:
        an Exception if the quorum is not considered sane by SCP.

*******************************************************************************/

version (unittest)
private void verifyQuorumsSanity (in QuorumConfig[Hash] quorums)
{
    import scpd.scp.QuorumSetUtils;

    foreach (key, quorum; quorums)
    {
        auto scp_quorum = toSCPQuorumSet(quorum);
        const bool ExtraChecks = true;
        const(char)* fail_reason;
        enforce(isQuorumSetSane(scp_quorum, ExtraChecks, fail_reason),
            format("Quorum %s fails sanity check before normalization: %s",
                    quorum, fail_reason.fromStringz));

        normalizeQSet(scp_quorum);
        enforce(isQuorumSetSane(scp_quorum, ExtraChecks, fail_reason),
            format("Quorum %s fails sanity check after normalization: %s",
                    quorum, fail_reason.fromStringz));
    }
}

/*******************************************************************************

    Verify that all the quorums intersect according to the quorum checker
    routines designed by Stellar

    Params:
        quorums = the quorums to check

*******************************************************************************/

version (unittest):
version (Windows)
private void verifyQuorumsIntersect (QuorumConfig[Hash] quorums)
{
    // @bug@: Need to fix linking issues with QuorumIntersectionChecker.create()
}
else
private void verifyQuorumsIntersect (QuorumConfig[Hash] quorums)
{
    import scpd.quorum.QuorumIntersectionChecker;

    auto qm = QuorumTracker.QuorumMap(CppCtor.Use);
    foreach (key, quorum; quorums)
    {
        auto scp = toSCPQuorumSet(quorum);
        auto scp_quorum = makeSharedSCPQuorumSet(scp);
        auto scp_key = NodeID(key[][0 .. NodeID.sizeof]);
        qm[scp_key] = QuorumTracker.NodeInfo(scp_quorum);
    }

    auto qic = QuorumIntersectionChecker.create(qm);
    assert(qic.networkEnjoysQuorumIntersection());

    auto splits = qic.getPotentialSplit();
    assert(splits.first.length == 0 && splits.second.length == 0);
}
