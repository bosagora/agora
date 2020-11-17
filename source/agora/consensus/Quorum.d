/*******************************************************************************

    Contains the quorum generator algorithm.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.Quorum;

import agora.common.Amount;
import agora.common.BitField;
import agora.common.Config;
import agora.common.crypto.Key;
import agora.common.Hash;
import agora.common.Set;
import agora.common.Types;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.state.UTXOSet;

import scpd.Cpp;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types : uint256, NodeID;
import scpd.types.Utils;
import scpd.types.XDRBase;
import scpd.quorum.QuorumTracker;

import ocean.core.Test;

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

public QuorumConfig buildQuorumConfig (in PublicKey key,
    in Hash[] utxo_keys, scope UTXOFinder finder, in Hash rand_seed,
    const ref QuorumParams params)
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
    auto added = BitField!uint(stakes.length);
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

        quorum.nodes ~= stakes[idx].key;
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
    auto quorums = buildTestQuorums(Amount.MinFreezeAmount.only, keys,
        hashFull(1), QuorumParams.init, 0);
    verifyQuorumsSanity(quorums);
    verifyQuorumsIntersect(quorums);
    test!"=="(countNodeInclusions(quorums, keys), [1]);
}

// 2 nodes
unittest
{
    auto keys = getKeys(2);
    auto quorums = buildTestQuorums(Amount.MinFreezeAmount.repeat(2), keys,
        hashFull(1), QuorumParams.init, 1);
    verifyQuorumsSanity(quorums);
    verifyQuorumsIntersect(quorums);
    test!"=="(countNodeInclusions(quorums, keys), [2, 2]);
}

// 3 nodes with equal stakes
unittest
{
    auto keys = getKeys(3);
    auto quorums = buildTestQuorums(Amount.MinFreezeAmount.repeat(3), keys,
        hashFull(1), QuorumParams.init, 2);
    verifyQuorumsSanity(quorums);
    verifyQuorumsIntersect(quorums);
    test!"=="(countNodeInclusions(quorums, keys), [3, 3, 3]);
}

// 4 nodes with equal stakes
unittest
{
    auto keys = getKeys(4);
    auto quorums = buildTestQuorums(Amount.MinFreezeAmount.repeat(4), keys,
        hashFull(1), QuorumParams.init, 3);
    verifyQuorumsSanity(quorums);
    verifyQuorumsIntersect(quorums);
    test!"=="(countNodeInclusions(quorums, keys), [4, 4, 4, 4]);
}

// 8 nodes with equal stakes
unittest
{
    auto keys = getKeys(8);
    auto quorums_1 = buildTestQuorums(Amount.MinFreezeAmount.repeat(8), keys,
        hashFull(1), QuorumParams.init, 4);
    verifyQuorumsSanity(quorums_1);
    verifyQuorumsIntersect(quorums_1);
    test!"=="(countNodeInclusions(quorums_1, keys), [7, 8, 7, 6, 8, 7, 7, 6]);

    auto quorums_2 = buildTestQuorums(Amount.MinFreezeAmount.repeat(8), keys,
        hashFull(2), QuorumParams.init, 5);
    verifyQuorumsSanity(quorums_2);
    verifyQuorumsIntersect(quorums_2);
    test!"=="(countNodeInclusions(quorums_2, keys), [8, 6, 7, 7, 6, 8, 6, 8]);
}

// 16 nodes with equal stakes
unittest
{
    auto keys = getKeys(16);
    auto quorums_1 = buildTestQuorums(Amount.MinFreezeAmount.repeat(16), keys,
        hashFull(1), QuorumParams.init, 6);
    verifyQuorumsSanity(quorums_1);
    verifyQuorumsIntersect(quorums_1);
    test!"=="(countNodeInclusions(quorums_1, keys),
        [8, 6, 8, 3, 7, 8, 8, 8, 8, 7, 7, 4, 6, 8, 7, 9]);

    auto quorums_2 = buildTestQuorums(Amount.MinFreezeAmount.repeat(16), keys,
        hashFull(2), QuorumParams.init, 7);
    verifyQuorumsSanity(quorums_2);
    verifyQuorumsIntersect(quorums_2);
    test!"=="(countNodeInclusions(quorums_2, keys),
        [6, 7, 8, 5, 6, 9, 8, 6, 7, 8, 9, 6, 9, 7, 5, 6]);
}

// 16 nodes with linearly ascending stakes
unittest
{
    auto amounts = iota(16)
        .map!(idx => Amount(400000000000uL + (100000000000uL * idx)));
    auto keys = getKeys(16);
    auto quorums_1 = buildTestQuorums(amounts, keys, hashFull(1),
        QuorumParams.init, 8);
    verifyQuorumsSanity(quorums_1);
    verifyQuorumsIntersect(quorums_1);
    test!"=="(countNodeInclusions(quorums_1, keys),
        [2, 5, 5, 6, 6, 6, 9, 4, 8, 7, 11, 9, 10, 5, 8, 11]);

    auto quorums_2 = buildTestQuorums(amounts, keys, hashFull(2),
        QuorumParams.init, 9);
    verifyQuorumsSanity(quorums_2);
    verifyQuorumsIntersect(quorums_2);
    test!"=="(countNodeInclusions(quorums_2, keys),
        [4, 5, 2, 4, 7, 8, 5, 8, 8, 7, 8, 9, 8, 12, 8, 9]);
}

// 16 nodes where two nodes own 66% of the stake
unittest
{
    auto keys = getKeys(16);
    auto amounts = Amount(400000000000uL).repeat(16).array;
    amounts[0] = amounts[$ - 1] = Amount(400000000000uL * 14);
    auto quorums_1 = buildTestQuorums(amounts, keys, hashFull(1),
        QuorumParams.init, 10);
    verifyQuorumsSanity(quorums_1);
    verifyQuorumsIntersect(quorums_1);
    test!"=="(countNodeInclusions(quorums_1, keys),
        [16, 8, 5, 10, 6, 5, 4, 6, 6, 5, 4, 6, 4, 5, 6, 16]);

    auto quorums_2 = buildTestQuorums(amounts, keys, hashFull(2),
        QuorumParams.init, 11);
    verifyQuorumsSanity(quorums_2);
    verifyQuorumsIntersect(quorums_2);
    test!"=="(countNodeInclusions(quorums_2, keys),
        [16, 5, 8, 4, 4, 7, 6, 7, 3, 11, 6, 7, 3, 3, 6, 16]);
}

// 32 nodes where two nodes own 66% of the stake
unittest
{
    auto keys = getKeys(32);
    auto amounts = Amount(400000000000uL).repeat(32).array;
    amounts[0] = amounts[$ - 1] = Amount(400000000000uL * 30);
    auto quorums_1 = buildTestQuorums(amounts, keys, hashFull(1),
        QuorumParams.init, 12);
    verifyQuorumsSanity(quorums_1);
    // verified to work but disabled because it runs slow with a
    // non-max threshold (~20 seconds)
    //verifyQuorumsIntersect(quorums_1);
    test!"=="(countNodeInclusions(quorums_1, keys),
        [32, 7, 5, 5, 5, 4, 4, 6, 4, 3, 5, 6, 8, 3, 10, 7, 7, 6, 4, 6, 6, 4, 4,
        5, 4, 3, 7, 4, 6, 6, 6, 32]);

    auto quorums_2 = buildTestQuorums(amounts, keys, hashFull(2),
        QuorumParams.init, 13);
    verifyQuorumsSanity(quorums_2);
    // verified to work but disabled because it runs slow with a
    // non-max threshold (~20 seconds)
    //verifyQuorumsIntersect(quorums_2);
    test!"=="(countNodeInclusions(quorums_2, keys),
        [31, 7, 5, 6, 6, 2, 3, 9, 3, 6, 8, 3, 7, 5, 7, 10, 5, 3, 5, 3, 5, 5, 6,
        1, 7, 8, 6, 4, 4, 6, 7, 31]);
}

// 64 nodes where two nodes own 66% of the stake
unittest
{
    auto keys = getKeys(64);
    auto amounts = Amount(400000000000uL).repeat(64).array;
    amounts[0] = amounts[$ - 1] = Amount(400000000000uL * 62);
    auto quorums_1 = buildTestQuorums(amounts, keys, hashFull(1),
        QuorumParams.init, 14);
    verifyQuorumsSanity(quorums_1);
    // verified to work but disabled because it runs slow with a
    // non-max threshold (~20 minutes)
    //verifyQuorumsIntersect(quorums_1);
    test!"=="(countNodeInclusions(quorums_1, keys),
        [63, 2, 6, 5, 5, 2, 5, 6, 6, 4, 4, 1, 7, 8, 7, 5, 4, 5, 6, 5, 5, 6, 9,
        1, 6, 5, 4, 11, 7, 9, 4, 4, 3, 7, 4, 5, 9, 4, 5, 4, 4, 4, 5, 5, 5, 5, 6,
        7, 5, 2, 5, 4, 6, 4, 10, 3, 6, 4, 10, 6, 3, 4, 4, 63]);

    auto quorums_2 = buildTestQuorums(amounts, keys, hashFull(2),
        QuorumParams.init, 15);
    verifyQuorumsSanity(quorums_2);
    // verified to work but disabled because it runs slow with a
    // non-max threshold (~20 minutes)
    //verifyQuorumsIntersect(quorums_2);
    test!"=="(countNodeInclusions(quorums_2, keys),
        [61, 7, 5, 9, 5, 3, 3, 7, 7, 7, 5, 4, 4, 7, 5, 6, 4, 6, 4, 5, 6, 4, 4,
        3, 4, 8, 6, 5, 6, 4, 4, 2, 8, 4, 3, 7, 4, 6, 5, 6, 5, 6, 6, 6, 4, 3, 3,
        3, 6, 8, 7, 2, 4, 7, 3, 4, 8, 8, 7, 9, 5, 6, 3, 62]);
}

// 128 nodes where two nodes own 66% of the stake
unittest
{
    auto keys = getKeys(128);
    auto amounts = Amount(400000000000uL).repeat(128).array;
    amounts[0] = amounts[$ - 1] = Amount(400000000000uL * 126);
    auto quorums_1 = buildTestQuorums(amounts, keys, hashFull(1),
        QuorumParams.init, 16);
    verifyQuorumsSanity(quorums_1);
    // not verified to work.
    //verifyQuorumsIntersect(quorums_1);
    test!"=="(countNodeInclusions(quorums_1, keys),
        [124, 8, 5, 4, 7, 6, 3, 1, 7, 5, 2, 2, 4, 4, 4, 11, 3, 4, 3, 5, 5, 8, 6,
        3, 6, 7, 4, 3, 4, 7, 6, 7, 8, 6, 4, 4, 7, 7, 6, 4, 6, 5, 6, 4, 4, 4, 4,
        6, 4, 6, 3, 9, 5, 6, 2, 4, 4, 5, 3, 4, 6, 5, 2, 3, 4, 2, 5, 3, 3, 7, 5,
        2, 5, 6, 5, 9, 10, 2, 7, 4, 5, 9, 6, 7, 4, 6, 4, 6, 6, 4, 6, 4, 6, 2, 6,
        9, 8, 4, 4, 4, 7, 7, 7, 2, 6, 6, 6, 5, 8, 4, 7, 5, 2, 5, 7, 5, 6, 6, 7,
        7, 4, 3, 3, 7, 6, 6, 5, 124]);

    auto quorums_2 = buildTestQuorums(amounts, keys, hashFull(2),
        QuorumParams.init, 17);
    verifyQuorumsSanity(quorums_2);
    // not verified to work.
    //verifyQuorumsIntersect(quorums_2);
    test!"=="(countNodeInclusions(quorums_2, keys),
        [124, 4, 5, 3, 10, 7, 4, 2, 2, 7, 3, 7, 5, 7, 3, 3, 5, 5, 4, 4, 4, 5, 9,
        2, 7, 11, 7, 3, 7, 5, 3, 3, 6, 7, 7, 9, 4, 6, 8, 5, 3, 7, 7, 4, 5, 6, 7,
        5, 3, 6, 3, 8, 3, 7, 7, 4, 4, 2, 5, 6, 4, 7, 3, 4, 6, 7, 5, 2, 11, 5, 3,
        6, 8, 5, 5, 6, 5, 8, 3, 7, 7, 7, 3, 3, 1, 3, 4, 9, 2, 7, 3, 3, 6, 8, 4,
        6, 5, 4, 5, 7, 9, 2, 3, 5, 5, 3, 6, 5, 7, 4, 6, 5, 3, 4, 8, 4, 5, 4, 5,
        6, 3, 7, 5, 3, 4, 1, 9, 124]);
}

// using various different quorum parameter configurations
unittest
{
    QuorumParams qp_1 = { MaxQuorumNodes : 4, QuorumThreshold : 80 };
    auto keys = getKeys(10);
    auto quorums_1 = buildTestQuorums(Amount.MinFreezeAmount.repeat(10), keys,
        hashFull(1), qp_1, 18);
    verifyQuorumsSanity(quorums_1);
    verifyQuorumsIntersect(quorums_1);
    quorums_1.byValue.each!(qc => test!"<="(qc.nodes.length, 4));
    quorums_1.byValue.each!(qc => test!"=="(qc.threshold, 4));
    test!"=="(countNodeInclusions(quorums_1, keys),
        [4, 2, 6, 4, 4, 4, 2, 5, 6, 3]);

    QuorumParams qp_2 = { MaxQuorumNodes : 8, QuorumThreshold : 80 };
    auto quorums_2 = buildTestQuorums(Amount.MinFreezeAmount.repeat(10), keys,
        hashFull(1), qp_2, 19);
    verifyQuorumsSanity(quorums_2);
    verifyQuorumsIntersect(quorums_2);
    quorums_2.byValue.each!(qc => test!"<="(qc.nodes.length, 8));
    quorums_2.byValue.each!(qc => test!"=="(qc.threshold, 7));
    test!"=="(countNodeInclusions(quorums_2, keys),
        [7, 7, 5, 9, 9, 8, 7, 9, 10, 9]);

    QuorumParams qp_3 = { MaxQuorumNodes : 8, QuorumThreshold : 60 };
    auto quorums_3 = buildTestQuorums(Amount.MinFreezeAmount.repeat(10), keys,
        hashFull(1), qp_3, 20);
    verifyQuorumsSanity(quorums_3);
    verifyQuorumsIntersect(quorums_3);
    quorums_3.byValue.each!(qc => test!"<="(qc.nodes.length, 8));
    quorums_3.byValue.each!(qc => test!"=="(qc.threshold, 5));
    test!"=="(countNodeInclusions(quorums_3, keys),
        [7, 8, 8, 9, 9, 9, 6, 9, 8, 7]);
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
    test!"=="(toShortHash(hash1), 4236719086673626116uL);
    const hash2 = hashMulti(WK.Keys.A.address, 2);
    test!"=="(toShortHash(hash2), 4202969883338957134uL);
}

/*******************************************************************************

    Create a random number generator which uses the node's public key hashed
    with the random seed as an initializer for the RNG engine.

    Using the Mersene Twister 19937 64-bit random number generator.
    The public key is reduced to a short hash of 8 bytes which is then
    used to initialize the RNG generator.

    Params
        key = the public key of a node
        rand_seed = the random seed

    Returns:
        a Mersenne Twister 64bit random generator

*******************************************************************************/

private auto getGenerator (const ref PublicKey key, in Hash rand_seed)
    @safe nothrow
{
    Mt19937_64 gen;
    const hash = hashMulti(key, rand_seed);
    gen.seed(toShortHash(hash));
    return gen;
}

/// The pair of (key, stake) for each node
private struct NodeStake
{
    /// the node key
    private PublicKey key;

    /// the node stake
    private Amount amount;
}

/*******************************************************************************

    Build a list of NodeStake's in descending stake order

    Params
        filter = the node's own key should be filtered here
        utxo_keys = the list of enrollments' UTXO keys
        finder = delegate to find the public key & stake of each UTXO key

    Returns:
        the list of stakes in descending stake order

*******************************************************************************/

private NodeStake[] buildStakesDescending (const ref PublicKey filter,
    in Hash[] utxo_keys, scope UTXOFinder finder) @safe nothrow
{
    static NodeStake[] stakes;
    stakes.length = 0;
    () @trusted { assumeSafeAppend(stakes); }();

    foreach (utxo_key; utxo_keys)
    {
        UTXO value;
        assert(finder(utxo_key, value), "UTXO for validator not found!");

        if (value.output.address != filter)
            stakes ~= NodeStake(value.output.address, value.output.value);
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
private QuorumConfig[PublicKey] buildTestQuorums (Range)(Range amounts,
    const(PublicKey)[] keys, const auto ref Hash rand_seed,
    const auto ref QuorumParams params, int id)
{
    assert(amounts.length == keys.length);
    QuorumConfig[PublicKey] quorums;
    TestUTXOSet storage = new TestUTXOSet;
    foreach (idx, const ref amount; amounts.save.enumerate)
    {
        Transaction tx =
        {
            type : TxType.Freeze,
            outputs: [Output(amount, keys[idx])]
        };

        // simulating our own UTXO hashes to make the tests stable
        Hash txhash = hashMulti(id, idx, amount);
        foreach (size_t out_idx, ref output_; tx.outputs)
        {
            Hash h = UTXO.getHash(txhash, out_idx);
            UTXO v = {
                type: tx.type,
                output: output_
            };
            storage[txhash] = v;
        }
    }

    Hash[] utxos = storage.keys;
    foreach (idx, _; amounts.enumerate)
    {
        quorums[keys[idx]] = buildQuorumConfig(
            keys[idx], utxos, &storage.peekUTXO, rand_seed, params);
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
private size_t[] countNodeInclusions (QuorumConfig[PublicKey] quorums,
    in PublicKey[] keys)
{
    size_t[const(PublicKey)] counts;
    foreach (_, const ref qc; quorums)
        qc.nodes.each!(node => counts[node]++);

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
private void verifyQuorumsSanity (in QuorumConfig[PublicKey] quorums)
{
    import scpd.scp.QuorumSetUtils;

    foreach (key, quorum; quorums)
    {
        auto scp_quorum = toSCPQuorumSet(quorum);
        const bool ExtraChecks = true;
        const(char)* fail_reason;
        enforce(isQuorumSetSane(scp_quorum, ExtraChecks, &fail_reason),
            format("Quorum %s fails sanity check before normalization: %s",
                    quorum, fail_reason.fromStringz));

        normalizeQSet(scp_quorum);
        enforce(isQuorumSetSane(scp_quorum, ExtraChecks, &fail_reason),
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
private void verifyQuorumsIntersect (QuorumConfig[PublicKey] quorums)
{
    // @bug@: Need to fix linking issues with QuorumIntersectionChecker.create()
}
else
private void verifyQuorumsIntersect (QuorumConfig[PublicKey] quorums)
{
    import scpd.quorum.QuorumIntersectionChecker;

    auto qm = QuorumTracker.QuorumMap.create();
    foreach (key, quorum; quorums)
    {
        auto scp = toSCPQuorumSet(quorum);
        auto scp_quorum = makeSharedSCPQuorumSet(scp);
        auto scp_key = NodeID(uint256(key));
        qm[scp_key] = scp_quorum;
    }

    auto qic = QuorumIntersectionChecker.create(qm);
    assert(qic.networkEnjoysQuorumIntersection());

    auto splits = qic.getPotentialSplit();
    assert(splits.first.length == 0 && splits.second.length == 0);
}
