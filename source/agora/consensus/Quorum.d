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
import agora.consensus.data.UTXOSetValue;
import agora.consensus.EnrollmentManager;

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

/// Maximum number of nodes to include in a quorum.
private enum MAX_NODES_IN_QUORUM = 7;

/// Threshold to use for the quorum configuration (e.g. 0.80 = 80%)
private enum double THRESHOLD = 0.80;

/*******************************************************************************

    Build the quorum configuration for the given public key and the registered
    enrollment keys.

    Params:
        key = the key of the node for which to generate the quorum
        utxo_keys = the list of UTXO keys of all the active enrollments
        finder = UTXO finder delegate

*******************************************************************************/

public QuorumConfig buildQuorumConfig ( const ref PublicKey key,
    in Hash[] utxo_keys, scope UTXOFinder finder ) @safe nothrow
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
    auto RNG_gen = getGenerator(key);
    auto stake_amounts = stakes.map!(stake => stake.amount.integral);

    static assumeNothrow (T)(lazy T exp) nothrow
    {
        try return exp();
        catch (Exception ex) assert(0, ex.msg);
    }

    // +1 as we already added ourself
    const MaxNodes = min(stakes.length + 1, MAX_NODES_IN_QUORUM);
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
    quorum.threshold = max(1, cast(uint)ceil(THRESHOLD * quorum.nodes.length));
    return quorum;
}

/// 1 node
unittest
{
    auto keys = getKeys(1);
    auto quorums = buildTestQuorums(Amount.MinFreezeAmount.only, keys);
    verifyQuorumsSanity(quorums);
    verifyQuorumsIntersect(quorums);
    test!"=="(countNodeInclusions(quorums, keys), [1]);
}

// 2 nodes
unittest
{
    auto keys = getKeys(2);
    auto quorums = buildTestQuorums(Amount.MinFreezeAmount.repeat(2), keys);
    verifyQuorumsSanity(quorums);
    verifyQuorumsIntersect(quorums);
    test!"=="(countNodeInclusions(quorums, keys), [2, 2]);
}

// 3 nodes with equal stakes
unittest
{
    auto keys = getKeys(3);
    auto quorums = buildTestQuorums(Amount.MinFreezeAmount.repeat(3), keys);
    verifyQuorumsSanity(quorums);
    verifyQuorumsIntersect(quorums);
    test!"=="(countNodeInclusions(quorums, keys), [3, 3, 3]);
}

// 4 nodes with equal stakes
unittest
{
    auto keys = getKeys(4);
    auto quorums = buildTestQuorums(Amount.MinFreezeAmount.repeat(4), keys);
    verifyQuorumsSanity(quorums);
    verifyQuorumsIntersect(quorums);
    test!"=="(countNodeInclusions(quorums, keys), [4, 4, 4, 4]);
}

// 8 nodes with equal stakes
unittest
{

    auto keys = getKeys(8);
    auto quorums = buildTestQuorums(Amount.MinFreezeAmount.repeat(8), keys);
    verifyQuorumsSanity(quorums);
    verifyQuorumsIntersect(quorums);
    test!"=="(countNodeInclusions(quorums, keys), [8, 5, 8, 8, 8, 8, 7, 4]);
}

// 16 nodes with equal stakes
unittest
{
    auto keys = getKeys(16);
    auto quorums = buildTestQuorums(Amount.MinFreezeAmount.repeat(16), keys);
    verifyQuorumsSanity(quorums);
    verifyQuorumsIntersect(quorums);
    test!"=="(countNodeInclusions(quorums, keys),
        [6, 7, 10, 8, 6, 6, 5, 7, 9, 7, 7, 6, 7, 5, 6, 10]);
}

// 16 nodes with linearly ascending stakes
unittest
{
    auto amounts = iota(16)
        .map!(idx => Amount(400000000000uL + (100000000000uL * idx)));
    auto keys = getKeys(16);
    auto quorums = buildTestQuorums(amounts, keys);
    verifyQuorumsSanity(quorums);
    verifyQuorumsIntersect(quorums);
    test!"=="(countNodeInclusions(quorums, keys),
        [2, 3, 8, 3, 7, 6, 4, 10, 6, 8, 8, 9, 8, 9, 13, 8]);
}

// 16 nodes where two nodes own 66% of the stake
unittest
{
    auto keys = getKeys(16);
    auto amounts = Amount(400000000000uL).repeat(16).array;
    amounts[0] = amounts[$ - 1] = Amount(400000000000uL * 14);
    auto quorums = buildTestQuorums(amounts, keys);
    verifyQuorumsSanity(quorums);
    verifyQuorumsIntersect(quorums);
    test!"=="(countNodeInclusions(quorums, keys),
        [16, 7, 6, 7, 4, 4, 4, 10, 4, 7, 2, 9, 5, 5, 6, 16]);
}

// 32 nodes where two nodes own 66% of the stake
unittest
{
    auto keys = getKeys(32);
    auto amounts = Amount(400000000000uL).repeat(32).array;
    amounts[0] = amounts[$ - 1] = Amount(400000000000uL * 30);
    auto quorums = buildTestQuorums(amounts, keys);
    verifyQuorumsSanity(quorums);
    // verified to work but disabled because it runs slow with a
    // non-max threshold (~20 seconds)
    //verifyQuorumsIntersect(quorums);
    test!"=="(countNodeInclusions(quorums, keys),
        [32, 6, 6, 6, 5, 4, 7, 4, 3, 7, 7, 5, 6, 3, 4, 7, 4, 7, 6, 3, 3, 6, 7,
        4, 3, 5, 6, 7, 5, 11, 3, 32]);
}

// 64 nodes where two nodes own 66% of the stake
unittest
{
    auto keys = getKeys(64);
    auto amounts = Amount(400000000000uL).repeat(64).array;
    amounts[0] = amounts[$ - 1] = Amount(400000000000uL * 62);
    auto quorums = buildTestQuorums(amounts, keys);
    verifyQuorumsSanity(quorums);
    // verified to work but disabled because it runs slow with a
    // non-max threshold (~20 minutes)
    //verifyQuorumsIntersect(quorums);
    test!"=="(countNodeInclusions(quorums, keys),
        [64, 7, 5, 3, 7, 6, 6, 4, 6, 6, 6, 6, 2, 4, 9, 5, 6, 1, 5, 5, 5, 8, 8,
        3, 2, 9, 8, 6, 7, 4, 4, 6, 4, 4, 7, 3, 3, 5, 5, 7, 6, 6, 6, 6, 7, 8, 5,
        4, 4, 4, 5, 2, 2, 6, 3, 6, 5, 5, 7, 3, 3, 7, 4, 63]);
}

// 128 nodes where two nodes own 66% of the stake
unittest
{
    auto keys = getKeys(128);
    auto amounts = Amount(400000000000uL).repeat(128).array;
    amounts[0] = amounts[$ - 1] = Amount(400000000000uL * 126);
    auto quorums = buildTestQuorums(amounts, keys);
    verifyQuorumsSanity(quorums);
    // not verified to work.
    //verifyQuorumsIntersect(quorums);
    test!"=="(countNodeInclusions(quorums, keys),
        [123, 5, 5, 4, 7, 5, 5, 5, 7, 6, 6, 6, 1, 4, 2, 4, 4, 6, 3, 5, 6, 5, 3,
        6, 6, 3, 3, 7, 8, 5, 5, 10, 4, 6, 5, 4, 7, 5, 5, 6, 6, 3, 4, 8, 6, 3, 6,
        7, 8, 8, 8, 5, 6, 2, 8, 5, 4, 4, 7, 7, 8, 5, 7, 4, 4, 4, 4, 4, 5, 2, 4,
        5, 2, 4, 4, 5, 4, 5, 9, 4, 2, 5, 7, 8, 5, 6, 4, 4, 3, 5, 7, 4, 7, 4, 3,
        3, 6, 6, 8, 5, 4, 6, 8, 5, 3, 6, 4, 8, 5, 6, 4, 6, 7, 2, 7, 4, 5, 6, 7,
        4, 4, 2, 3, 9, 3, 5, 4, 127]);
}

version (unittest)
private const(PublicKey)[] getKeys (size_t count)
{
    return WK.Keys.byRange.take(count).map!(kp => kp.address).array;
}

/// Create a shorthash from a 64-byte blob for RNG initialization
private ulong toShortHash (const ref PublicKey key) @trusted nothrow
{
    import libsodium.crypto_shorthash;
    import std.bitmanip;

    // using a once-generated initialization vector
    static immutable ubyte[crypto_shorthash_KEYBYTES] IV =
        [111, 165, 189, 80, 37, 5, 16, 194, 39, 214, 156, 169, 235, 221, 21, 126];
    ubyte[ulong.sizeof] short_hash;
    crypto_shorthash(short_hash.ptr, key[].ptr, key[].length, IV.ptr);

    // assume a specific endianess for consistency in how we convert to ulong
    return littleEndianToNative!ulong(short_hash[]);
}

///
unittest
{
    test!"=="(toShortHash(WK.Keys.A.address), 13323068528962985137uL);
    test!"=="(toShortHash(WK.Keys.B.address), 7384142154118289865uL);
}

/*******************************************************************************

    Create a random number generator which uses the node's public key as an
    initializer for the RNG engine.

    Using the Mersene Twister 19937 64-bit random number generator.
    The public key is reduced to a short hash of 8 bytes which is then
    used to initialize the RNG generator.

    Params
        key = the public key of a node

    Returns:
        a Mersenne Twister 64bit random generator

*******************************************************************************/

private auto getGenerator (PublicKey key) @safe nothrow
{
    Mt19937_64 gen;
    gen.seed(toShortHash(key));
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
    in Hash[] utxo_keys, UTXOFinder finder) @safe nothrow
{
    static NodeStake[] stakes;
    stakes.length = 0;
    () @trusted { assumeSafeAppend(stakes); }();

    foreach (utxo_key; utxo_keys)
    {
        UTXOSetValue value;
        assert(finder(utxo_key, size_t.max, value),
            "UTXO for validator not found!");

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
    const(PublicKey)[] keys)
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

        storage.put(tx);
    }

    Hash[] utxos = storage.keys;
    foreach (idx, _; amounts.enumerate)
    {
        quorums[keys[idx]] = buildQuorumConfig(
            keys[idx], utxos, &storage.findUTXO);
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
    const ref PublicKey[] keys)
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
private void verifyQuorumsSanity (const ref QuorumConfig[PublicKey] quorums)
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
