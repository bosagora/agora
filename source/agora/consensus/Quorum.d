/*******************************************************************************

    Contains the quorum generator algorithm.

    Note that if you use AscendingQuadratic for too many nodes it will
    assert as you will quickly run out of BOA.

    Note thatintersection checks take roughly ~2 minutes for a configuration
    of 16 nodes with their quorums, by default we disable these checks for
    many nodes unless overriden with -version=EnableAllIntersectionChecks.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.Quorum;

/// Force intersection checks on all unittests
//version = EnableAllIntersectionChecks;

/// Generate new assertion blocks when calibrating the algorithm
//version = CalibrateQuorumBalancing;

import agora.common.Amount;
import agora.common.BitField;
import agora.common.Config;
import agora.common.crypto.Key;
import agora.common.Hash;
import agora.common.Set;
import agora.common.Types;
import agora.consensus.data.Enrollment;
import agora.consensus.data.UTXOSet;
import agora.consensus.EnrollmentManager;
import agora.utils.PrettyPrinter;

import scpd.Cpp;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types : uint256, NodeID;
import scpd.types.Utils;
import scpd.types.XDRBase;
import scpd.quorum.QuorumIntersectionChecker;
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
    import agora.utils.Log;
    import std.conv;
    import std.stdio;
}

/*******************************************************************************

    Minimum number of nodes to include in a quorum.
    The range is inclusive: length <= MIN_NODES_IN_QUORUM.

    This is a soft limit, if there are less total nodes in the network than
    MIN_NODES_IN_QUORUM then all of the nodes will be included in each node's
    quorum set.

    Since some nodes may have a large amount of stake compared to the
    rest of the network, we want to ensure that other nodes get a chance of
    inclusion in a quorum set.

    For example, with nodes with this given stake
    (assume units are multiples of MinFreezeAmount):

    n0: 10, n1: 1, n2: 1, n3: 1, n4: 1

    Despite n0 having significantly more stake than the rest of the nodes,
    we do not want to centralize the quorum configuration to only include
    this one node. This would lead to too much political (voting) power.

    The voting power of a BOA holder may be increased by spawning multiple nodes,
    for example:

    [x0: 4, x1: 3, x2: 3], n2: 1, n3: 1, n4: 1, nE: 5

    However, this will lead to the BOA holder to receive less rewards than if
    they spawned a single node with 10 units. It's their choice on how to
    distribute their voting power vs rewards ratio.

*******************************************************************************/

private enum MIN_NODES_IN_QUORUM = 5;

/*******************************************************************************

    Maximum number of nodes to include in a quorum.

    Note: this may be relaxed in the future.

*******************************************************************************/

private enum MAX_NODES_IN_QUORUM = 7;

/*******************************************************************************

    Build the quorum configuration for the entire network of the given
    registered enrollments. The random seed is used to shuffle the quorums.

    Params:
        enrolls = the array of registered enrollments
        finder = the delegate to find UTXOs with
        rand_seed = the source of randomness

    Returns:
        the map of all quorum configurations

*******************************************************************************/

public QuorumConfig[PublicKey] buildQuorumConfigs ( Enrollment[] enrolls,
    UTXOFinder finder, Hash rand_seed )
{
    Amount[PublicKey] all_stakes = buildStakes(enrolls, finder);

    QuorumConfig[PublicKey] quorums;
    foreach (node, amount; all_stakes)
        quorums[node] = buildQuorumConfig(node, enrolls, finder, rand_seed);

    return quorums;
}

/*******************************************************************************

    Build the quorum configuration for the given node key and the registered
    enrollments. The random seed is used to shuffle the quorum config.

    Params:
        node_key = the key of the node
        enrolls = the array of registered enrollments
        finder = the delegate to find UTXOs with
        rand_seed = the source of randomness

    Returns:
        the map of all quorum configurations

*******************************************************************************/

public QuorumConfig buildQuorumConfig ( PublicKey node_key,
    Enrollment[] enrolls, UTXOFinder finder, Hash rand_seed )
{
    Amount[PublicKey] all_stakes = buildStakes(enrolls, finder);
    NodeStake[] stakes_by_price = orderStakesDescending(all_stakes);

    const Amount min_quorum_amount = Amount(
        cast(ulong)(0.67 *
            stakes_by_price.map!(stake => stake.amount.getRaw()).sum));

    auto node_stake = node_key in all_stakes;
    assert(node_stake !is null);

    return buildQuorumImpl(node_key, *node_stake, stakes_by_price,
        min_quorum_amount, rand_seed);
}

/// 2 nodes with equal stakes
unittest
{
    auto enrolls = genEnrollsAndFinder(2, prev => prev);
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 128, n1: 128], counts.pretty);
}

/// 3 nodes with equal stakes
unittest
{
    auto enrolls = genEnrollsAndFinder(3, prev => prev);
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 192, n1: 192, n2: 192], counts.pretty);
}

/// 3 nodes with ascending stakes
unittest
{
    auto enrolls = genEnrollsAndFinder(3, prev => prev.mustAdd(Amount.MinFreezeAmount));
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 101, n1: 192, n2: 192], counts.pretty);
}

/// 3 nodes with descending stakes
unittest
{
    auto enrolls = genEnrollsAndFinder(3, prev => prev.mustSub(Amount.MinFreezeAmount),
        Amount.MinFreezeAmount.mul(3));
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 192, n1: 192, n2: 102], counts.pretty);
}

/// 3 nodes with ascending quadratic stakes
unittest
{
    auto enrolls = genEnrollsAndFinder(3, prev => prev.mustAdd(prev));
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 96, n1: 134, n2: 192], counts.pretty);
}

/// 4 nodes with equal stakes
unittest
{
    auto enrolls = genEnrollsAndFinder(4, prev => prev);
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 193, n1: 196, n2: 196, n3: 183], counts.pretty);
}

/// 4 nodes with ascending stakes
unittest
{
    auto enrolls = genEnrollsAndFinder(4, prev => prev.mustAdd(Amount.MinFreezeAmount));
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 111, n1: 139, n2: 217, n3: 256], counts.pretty);
}

/// 4 nodes with ascending quadratically increasing stakes
unittest
{
    auto enrolls = genEnrollsAndFinder(4, prev => prev.mustAdd(prev));
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 96, n1: 117, n2: 219, n3: 256], counts.pretty);
}

/// 8 nodes with equal stakes
unittest
{
    auto enrolls = genEnrollsAndFinder(8, prev => prev);
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 331, n1: 315, n2: 309, n3: 333, n4: 321, n5: 316, n6: 319, n7: 316], counts.pretty);
}

/// 8 nodes with ascending stakes
unittest
{
    auto enrolls = genEnrollsAndFinder(8, prev => prev.mustAdd(Amount.MinFreezeAmount));
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 134, n1: 206, n2: 259, n3: 303, n4: 345, n5: 398, n6: 404, n7: 438], counts.pretty);
}

/// 8 nodes with ascending quadratically increasing stakes
// todo: fails with the quorum split check,
// awaiting answer on https://stellar.stackexchange.com/q/3038/2227
version (none)
unittest
{
    auto enrolls = genEnrollsAndFinder(8, prev => prev.mustAdd(prev));
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 110, n1: 134, n2: 158, n3: 167,
                      n4: 216, n5: 253, n6: 284, n7: 326,
                      n8: 347, n9: 405, n10: 392, n11: 430,
                      n12: 429, n13: 480, n14: 488, n15: 501], counts.pretty);
}

/// 16 nodes with equal stakes
unittest
{
    auto enrolls = genEnrollsAndFinder(16, prev => prev);
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 318, n1: 310, n2: 308, n3: 328, n4: 312, n5: 327, n6: 317, n7: 303, n8: 314, n9: 322, n10: 327, n11: 337, n12: 327, n13: 334, n14: 285, n15: 351], counts.pretty);
}

/// 16 nodes with ascending stakes
unittest
{
    auto enrolls = genEnrollsAndFinder(16, prev => prev.mustAdd(Amount.MinFreezeAmount));
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 90, n1: 125, n2: 185, n3: 182, n4: 222, n5: 246, n6: 299, n7: 296, n8: 345, n9: 358, n10: 397, n11: 443, n12: 467, n13: 441, n14: 503, n15: 521], counts.pretty);
}

/// 16 nodes with ascending stakes (Freeze * 2)
unittest
{
    auto enrolls = genEnrollsAndFinder(16, prev => prev.mustAdd(Amount.MinFreezeAmount.mul(2)));
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 82, n1: 107, n2: 157, n3: 182, n4: 211, n5: 253, n6: 280, n7: 321, n8: 337, n9: 363, n10: 386, n11: 461, n12: 486, n13: 444, n14: 513, n15: 537], counts.pretty);
}

/// 16 nodes with ascending stakes (Freeze * 4)
unittest
{
    auto enrolls = genEnrollsAndFinder(16, prev => prev.mustAdd(Amount.MinFreezeAmount.mul(4)));
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 75, n1: 106, n2: 141, n3: 184, n4: 195, n5: 263, n6: 280, n7: 313, n8: 328, n9: 376, n10: 392, n11: 468, n12: 479, n13: 456, n14: 516, n15: 548], counts.pretty);
}

/// 32 nodes with equal stakes
unittest
{
    auto enrolls = genEnrollsAndFinder(32, prev => prev);
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 302, n1: 323, n2: 307, n3: 328, n4: 315, n5: 338, n6: 295, n7: 310, n8: 307, n9: 305, n10: 312, n11: 332, n12: 330, n13: 349, n14: 321, n15: 355, n16: 314, n17: 338, n18: 303, n19: 312, n20: 319, n21: 332, n22: 306, n23: 313, n24: 343, n25: 325, n26: 309, n27: 268, n28: 339, n29: 331, n30: 319, n31: 340], counts.pretty);
}

/// 32 nodes with ascending stakes
unittest
{
    auto enrolls = genEnrollsAndFinder(32, prev => prev.mustAdd(Amount.MinFreezeAmount));
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 82, n1: 93, n2: 111, n3: 129, n4: 145, n5: 172, n6: 176, n7: 186, n8: 179, n9: 226, n10: 249, n11: 248, n12: 282, n13: 267, n14: 285, n15: 307, n16: 330, n17: 377, n18: 352, n19: 382, n20: 404, n21: 356, n22: 427, n23: 440, n24: 463, n25: 462, n26: 483, n27: 464, n28: 532, n29: 524, n30: 545, n31: 562], counts.pretty);
}

/// 64 nodes with equal stakes
unittest
{
    auto enrolls = genEnrollsAndFinder(64, prev => prev);
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 336, n1: 294, n2: 335, n3: 353, n4: 312, n5: 314, n6: 325, n7: 325, n8: 296, n9: 314, n10: 334, n11: 312, n12: 319, n13: 303, n14: 298, n15: 350, n16: 318, n17: 333, n18: 330, n19: 326, n20: 334, n21: 325, n22: 333, n23: 358, n24: 344, n25: 297, n26: 303, n27: 312, n28: 324, n29: 328, n30: 313, n31: 306, n32: 324, n33: 320, n34: 308, n35: 307, n36: 313, n37: 285, n38: 310, n39: 324, n40: 316, n41: 349, n42: 308, n43: 348, n44: 307, n45: 312, n46: 297, n47: 304, n48: 317, n49: 321, n50: 318, n51: 320, n52: 334, n53: 287, n54: 327, n55: 318, n56: 329, n57: 286, n58: 311, n59: 308, n60: 346, n61: 346, n62: 335, n63: 341], counts.pretty);
}

/// 64 nodes with ascending stakes
unittest
{
    auto enrolls = genEnrollsAndFinder(64, prev => prev.mustAdd(Amount.MinFreezeAmount));
    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 72, n1: 78, n2: 95, n3: 86, n4: 99, n5: 120, n6: 119, n7: 134, n8: 139, n9: 136, n10: 146, n11: 171, n12: 177, n13: 175, n14: 182, n15: 201, n16: 187, n17: 194, n18: 208, n19: 237, n20: 231, n21: 242, n22: 240, n23: 253, n24: 245, n25: 273, n26: 263, n27: 271, n28: 301, n29: 257, n30: 276, n31: 316, n32: 329, n33: 320, n34: 332, n35: 401, n36: 365, n37: 360, n38: 379, n39: 365, n40: 431, n41: 382, n42: 366, n43: 395, n44: 422, n45: 442, n46: 450, n47: 465, n48: 469, n49: 484, n50: 489, n51: 454, n52: 516, n53: 448, n54: 480, n55: 480, n56: 503, n57: 539, n58: 504, n59: 535, n60: 547, n61: 568, n62: 590, n63: 546], counts.pretty);
}

/// Test buildQuorumConfig() manually with specific inputs
unittest
{
    auto enrolls = genEnrollsAndFinder(64, prev => prev.mustAdd(Amount.MinFreezeAmount));
    auto rand_seed = hashFull(0);

    auto q0_h1 = buildQuorumConfig(n0, enrolls.expand, rand_seed);
    Assert(q0_h1 == QuorumConfig(4, [n20, n35, n0, n60, n25]), q0_h1.pretty);

    auto q0_h2 = buildQuorumConfig(n0, enrolls.expand, hashFull(rand_seed));
    Assert(q0_h2 == QuorumConfig(4, [n41, n47, n0, n62, n7]), q0_h2.pretty);

    auto q63_h1 = buildQuorumConfig(n63, enrolls.expand, rand_seed);
    Assert(q63_h1 == QuorumConfig(4, [n57, n63, n60, n58, n49]), q63_h1.pretty);

    auto q63_h2 = buildQuorumConfig(n63, enrolls.expand, hashFull(rand_seed));
    Assert(q63_h2 == QuorumConfig(4, [n57, n34, n63, n61, n49]), q63_h2.pretty);
}

/// Test with outlier nodes with a large stake ratio
unittest
{
    auto enrolls = genEnrollsAndFinder(64,
        amount => Amount.MinFreezeAmount, // all other nodes have minimum stake
        Amount.MinFreezeAmount.mul(10));  // first node has most stake

    auto counts = countNodeInclusions(enrolls, getRandSeeds(64));
    Assert(counts == [n0: 1986, n1: 286, n2: 273, n3: 299, n4: 297, n5: 306, n6: 291, n7: 272, n8: 307, n9: 340, n10: 305, n11: 294, n12: 290, n13: 276, n14: 288, n15: 292, n16: 261, n17: 294, n18: 293, n19: 295, n20: 327, n21: 299, n22: 294, n23: 312, n24: 299, n25: 297, n26: 301, n27: 306, n28: 277, n29: 318, n30: 265, n31: 287, n32: 286, n33: 301, n34: 298, n35: 304, n36: 287, n37: 262, n38: 290, n39: 281, n40: 302, n41: 314, n42: 291, n43: 314, n44: 284, n45: 319, n46: 286, n47: 291, n48: 286, n49: 254, n50: 304, n51: 272, n52: 301, n53: 313, n54: 306, n55: 289, n56: 287, n57: 283, n58: 290, n59: 308, n60: 299, n61: 261, n62: 279, n63: 311], counts.pretty);
}

/*******************************************************************************

    Build the quorum configuration for the given public key and the staked
    enrollments. The random seed is used to shuffle the quorum.

    The node's quorum will consist of nodes whos sum of stakes will
    be at least min_amount, or less if MAX_NODES_IN_QUORUM has been reached.

    Params:
        node_key = the key of the node for which to generate the quorum
        node_stake = the stake of the node for which to generate the quorum
        stakes = the list of stakes in descending order
        min_amount = the minimum amount a node's quorum's sum of stake should
                     be reached (unless MAX_NODES_IN_QUORUM is reached first)
        rand_seed = the source of randomness

    Notes:
        dice() should be replaced / improved to be more efficient,
        see also https://issues.dlang.org/show_bug.cgi?id=5849

*******************************************************************************/

private QuorumConfig buildQuorumImpl (PublicKey node_key, Amount node_stake,
    in NodeStake[] stakes, const Amount min_amount, in Hash rand_seed)
{
    QuorumConfig quorum;
    Amount quorum_sum;  // sum of the staked amount of the quorum for this node

    // to filter out duplicates generated by dice()
    auto added_nodes = BitField!uint(stakes.length);
    auto rnd_gen = getGenerator(node_key, rand_seed);

    // node must have itself in the quorum set
    quorum.nodes ~= node_key;
    if (!quorum_sum.add(node_stake))
        assert(0);

    // there may be less total nodes in the network than MIN_NODES_IN_QUORUM
    const MIN_NODES = min(MIN_NODES_IN_QUORUM, stakes.length);

    while (quorum.nodes.length < MIN_NODES &&
        quorum_sum < min_amount &&
        quorum.nodes.length < MAX_NODES_IN_QUORUM)
    {
        const idx = dice(rnd_gen, stakes.map!(stake => stake.amount.integral));
        auto qnode = stakes[idx];
        if (qnode.key == node_key || added_nodes[idx]) // skip self or duplicate
            continue;

        // we want a predictable order of nodes
        auto insert_idx = quorum.nodes.countUntil!(node => node >= qnode.key);
        if (insert_idx == -1)
            quorum.nodes ~= qnode.key;
        else
            quorum.nodes.insertInPlace(insert_idx, qnode.key);

        added_nodes[idx] = true;
        if (!quorum_sum.add(qnode.amount))
            assert(0);
    }

    const majority = max(1, cast(size_t)ceil(0.67 * quorum.nodes.length));
    quorum.threshold = majority;

    return quorum;
}

/*******************************************************************************

    Verify that the provided quorum sets are considered sane by SCP.

    The quorums are checked both pre and post-normalization,
    with extra safety checks enabled.

    Params:
        quorums = the quorum map of (node => quorum) to verify

    Throws:
        AssertError if the quorum is not considered sane by SCP.

*******************************************************************************/

private void verifyQuorumsSanity (QuorumConfig[PublicKey] quorums)
{
    import scpd.scp.QuorumSetUtils;

    foreach (key, quorum; quorums)
    {
        version (unittest)
            auto prettyKey = () => pretty(key);
        else
            alias prettyKey = key;

        auto scp_quorum = toSCPQuorumSet(quorum);
        const(char)* reason;
        enforce(isQuorumSetSane(scp_quorum, true, &reason),
            format("Key %s with %s fails sanity check before normalization: %s",
                    prettyKey, quorum.toToml, reason.to!string));

        normalizeQSet(scp_quorum);
        enforce(isQuorumSetSane(scp_quorum, true, &reason),
            format("Key %s with %s fails sanity check after normalization: %s",
                    prettyKey, quorum.toToml, reason.to!string));
    }
}

/*******************************************************************************

    Verify that all the quorums intersect according to the quorum checker
    routines designed by Stellar

    Params:
        quorums = the quorums to check

    Returns:
        true if all the quorums enjoy quorum intersection

*******************************************************************************/

private bool verifyQuorumsIntersect (QuorumConfig[PublicKey] quorums)
{
    auto qm = QuorumTracker.QuorumMap.create();
    foreach (key, quorum; quorums)
    {
        auto scp = toSCPQuorumSet(quorum);
        auto scp_quorum = makeSharedSCPQuorumSet(scp);
        auto scp_key = NodeID(uint256(key));
        qm[scp_key] = scp_quorum;
    }

    auto qic = QuorumIntersectionChecker.create(qm);
    if (!qic.networkEnjoysQuorumIntersection())
        return false;

    auto splits = qic.getPotentialSplit();

    if (splits.first.length != 0 ||
        splits.second.length != 0)
    {
        version (unittest)
        {
            writefln("Splits: first: %s second: %s",
                splits.first[].map!(node_id => key_to_simple[PublicKey(node_id)]),
                splits.second[].map!(node_id => key_to_simple[PublicKey(node_id)]));

            writefln("Quorum: %s", quorums.pretty(0));
        }

        return false;
    }

    return true;
}

/// Create a shorthash from a 64-byte blob to initialize the rnd generator
private ulong toShortHash (const ref Hash hash) @trusted
{
    import libsodium.crypto_shorthash;
    import std.bitmanip;

    // generated once with 'crypto_shorthash_keygen'
    static immutable ubyte[crypto_shorthash_KEYBYTES] PublicKey =
        [111, 165, 189, 80, 37, 5, 16, 194, 39, 214, 156, 169, 235, 221, 21, 126];

    ubyte[ulong.sizeof] short_hash;
    crypto_shorthash(short_hash.ptr, hash[].ptr, 64, PublicKey.ptr);

    // endianess: need to be consistent how ubyte[4] is interpreted as a ulong
    return littleEndianToNative!ulong(short_hash[]);
}

///
unittest
{
    const hash = Hash(
        "0xe0343d063b14c52630563ec81b0f91a84ddb05f2cf05a2e4330ddc79bd3a06e57" ~
        "c2e756f276c112342ff1d6f1e74d05bdb9bf880abd74a2e512654e12d171a74");
    assert(toShortHash(hash) == 7283894889895411012uL);
}

/*******************************************************************************

    Create a random number generator which uses the hash of the random seed
    and a node's public key as an initializer for the engine.

    Using the Mersene Twister 19937 64-bit random number generator.
    The source of randomness is hashed together with the public key of the node,
    and then reduced from 64-bytes to to a short hash of 8 bytes,
    which is then fed to the RND generator.

    Params
        node_key = the public key of a node
        rand_seed = the source of randomness

    Returns:
        a Mersenne Twister 64bit random generator

*******************************************************************************/

private auto getGenerator (PublicKey node_key, Hash rand_seed)
{
    auto hash = hashMulti(node_key, rand_seed);
    Mt19937_64 gen;
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

    For each enrollment find the staked amount from the associated UTXO
    in the Enrollment, and build a key => amount map.

    Params
        enrolls = the list of enrollments
        finder = UTXO finder delegate

    Returns:
        a mapping of all keys => staken amount

*******************************************************************************/

private Amount[PublicKey] buildStakes (Enrollment[] enrolls, UTXOFinder finder)
{
    Amount[PublicKey] stakes;
    foreach (enroll; enrolls)
    {
        UTXOSetValue value;
        assert(finder(enroll.utxo_key, size_t.max, value),
            "UTXO for validator not found!");
        assert(value.output.address !in stakes,
            "Cannot have multiple enrollments for one validator!");

        stakes[value.output.address] = value.output.value;
    }

    return stakes;
}

/*******************************************************************************

    Params:
        stake_map = the map of node keys => their stake

    Returns:
        a descending set of nodes based on their stakes

*******************************************************************************/

private NodeStake[] orderStakesDescending (Amount[PublicKey] stake_map)
{
    auto stakes = stake_map
        .byKeyValue
        .map!(pair => NodeStake(pair.key, pair.value))
        .array;

    stakes.sort!((a, b) => a.amount > b.amount);
    return stakes;
}

/*******************************************************************************

    Generates a .toml syntax file that can be used with the go-scp
    tool in https://github.com/bobg/scp/blob/master/cmd/lunch/lunch.go
    for easy testing.

    Format example:

        [alice]
        Q = {t = 2, m = [{n = "bob"}, {n = "carol"}]}

        [bob]
        Q = {t = 2, m = [{n = "alice"}, {n = "carol"}]}

        [carol]
        Q = {t = 2, m = [{n = "alice"}, {n = "bob"}]}

    Or nested:

        [alice]
        Q = {t = 1, m = [{q = {t = 2, m = [{n = "bob"}, {n = "carol"}]}},
                         {q = {t = 2, m = [{n = "dave"}, {n = "elsie"}]}}]}

    Params:
        quorums = the quorum set
        level = indentation level

*******************************************************************************/

private string toToml (QuorumConfig[PublicKey] quorums)
{
    return quorums.byKeyValue.map!(pair =>
        format("[%s]\n%s", pair.key.pretty, toToml(pair.value)))
            .join("\n\n");
}

/// ditto
private string toToml (QuorumConfig config, size_t level = 0)
{
    string result;

    result ~= format("%s = {t = %s, m = [",
        level == 0 ? "Q" : "q",
        config.threshold);

    // nodes
    auto nodes = config.nodes
        .map!(qnode => format(`{n = "%s"}`, qnode.pretty))
        .join(", ");

    result ~= nodes.to!string;

    // subquorums (recursive)
    if (config.quorums.length > 0)
    {
        result ~= ", ";
        auto subq = config.quorums
            .map!(qsub => format("{ %s}", toToml(qsub, level + 1)))
            .join(", ");

        result ~= subq.to!string;
    }

    result ~= "]}";
    return result;
}

/// The rest is support code for testing, quorum prettify routines, etc.
version (unittest):

/// prettier formatting for [sets of] public keys
private auto pretty (Set!PublicKey input)
{
    return input._set.byKey.map!(key => key.pretty);
}

/// converts "GA..." => n0 / n1, etc for easier debugging
private string[PublicKey] key_to_simple;

static this ()
{
    foreach (node_idx; 0 .. pregen_seeds.length)
        key_to_simple[getTestKey(node_idx)] = format("n%s", node_idx);
}

/// ditto
private string pretty (QuorumConfig[PublicKey] conf, size_t seed_idx)
{
    auto keys = conf.keys;
    sort!((a, b) => key_to_simple[a] < key_to_simple[b])(keys);

    string res;
    auto hash = hashFull(seed_idx);
    res ~= format("\nrand idx: %s (seed: %s)\n", seed_idx, hash.prettify);

    foreach (key; keys)
    {
        auto quorum = conf[key];
        auto nodes = quorum.nodes.map!(node => key_to_simple[node]).array;
        sort(nodes);

        res ~= format("\n%s: QuorumConfig(thresh: %s, nodes: %s)",
            key_to_simple[key],
            quorum.threshold,
            nodes);
    }

    return res;
}

/// ditto
private string pretty (QuorumConfig conf)
{
    auto nodes = conf.nodes.map!(node => key_to_simple[node]).array;
    return format("\nQuorumConfig(%s, %s)",
        conf.threshold,
        nodes);
}

// convenience so we can use [n0, n1] when refering to public keys in the tests
static foreach (node_idx; 0 .. pregen_seeds.length)
    mixin("PublicKey n%s;".format(node_idx));

// convenience so we can use [n0, n1] when refering to public keys in the tests
static this ()
{
    static foreach (node_idx; 0 .. pregen_seeds.length)
        mixin("n%1$s = getTestKey(%1$s);".format(node_idx));
}

/*******************************************************************************

    Build the quorum configs for the given enrollments and range of seeds,
    and return a map of the number of times each node was included in
    another node's quorum set.

    Returns:
        the map of node => quorum set inclusion counts

*******************************************************************************/

private int[PublicKey] countNodeInclusions (Enrolls, Range)(
    Enrolls enrolls, Range seeds)
{
    int[PublicKey] counts;
    foreach (rand_seed; seeds)
    {
        auto quorums = buildQuorumConfigs(enrolls.expand, rand_seed);
        verifyQuorumsSanity(quorums);

        // Intersection checks take roughly ~2 minutes for a configuration
        // of 16 node quorums, and grows exponentially after that.
        // By default we disable these checks unless overriden with
        // -version=EnableAllIntersectionChecks
        version (EnableAllIntersectionChecks)
            const bool check_intersections = true;
        else
            const bool check_intersections = quorums.length <= 8;

        if (check_intersections && !verifyQuorumsIntersect(quorums))
        {
            CircularAppender().printConsole();  // print out SCP logs
            assert(false);
        }

        foreach (key, quorum; quorums)
        {
            foreach (node; quorum.nodes)
                counts[node]++;
        }
    }

    return counts;
}

/// Generate random seeds by hashing a range of numbers: [0 .. count)
private auto getRandSeeds (size_t count)
{
    // using 'ulong' to get consistent hashes
    return iota(0, count).map!(idx => hashFull(cast(ulong)idx));
}

/// ditto
private string pretty (PublicKey input)
{
    // convert arbitrary hashes into user-readable strings like "Andrew, Dave, etc"
    static string toUserReadable (Hash hash)
    {
        const names =
        [
            "Aaron",
            "Adam",
            "Alex",
            "Andrew",
            "Anthony",
            "Austin",
            "Ben",
            "Brandon",
            "Brian",
            "Charles",
            "Chris",
            "Daniel",
            "David",
            "Edward",
            "Eric",
            "Ethan",
            "Fred",
            "George",
            "Iain",
            "Jack",
            "Jacob",
            "James",
            "Jason",
            "Jeremy",
            "John",
            "Jonathan",
            "Joseph",
            "Josh",
            "Justin",
            "Kevin",
            "Kyle",
            "Luke",
            "Mark",
            "Martin",
            "Mathew",
            "Matthew",
            "Michael",
            "Nathan",
            "Nicholas",
            "Nick",
            "Patrick",
            "Paul",
            "Peter",
            "Philip",
            "Richard",
            "Robert",
            "Ryan",
            "Samuel",
            "Scott",
            "Sean",
            "Simon",
            "Stephen",
            "Steven",
            "Thomas",
            "Timothy",
            "Tyler",
            "William",
            "Zach",
        ];

        static size_t last_used;
        static string[Hash] hashToName;

        if (auto name = hash in hashToName)
        {
            return *name;
        }
        else
        {
            string name = names[last_used];
            last_used++;

            if (last_used >= names.length)
                assert(0);  // need more names

            hashToName[hash] = name;
            return name;
        }
    }

    return toUserReadable(input[].hashFull());
}

/// convenience, since Amount does not implement multiplication
private Amount mul (in Amount amount, in size_t multiplier)
{
    if (multiplier == 0)
        return Amount.init;

    Amount result = Amount(0);
    foreach (_; 0 .. multiplier)
        result.mustAdd(amount);
    return result;
}

/// Generate a tuple pair of (Enrollment[], UTXOFinder)
private auto genEnrollsAndFinder (size_t enroll_count,
    const(Amount) delegate (Amount) getAmount,
    Amount initial_amount = Amount.MinFreezeAmount,
    size_t line = __LINE__)
{
    import agora.common.Amount;
    import agora.consensus.data.Transaction;
    import agora.consensus.Genesis;

    TestUTXOSet storage = new TestUTXOSet;
    Enrollment[] enrolls;

    Amount prev_amount;
    foreach (idx; 0 .. enroll_count)
    {
        Amount amount;
        if (idx == 0)
            amount = initial_amount;
        else
            amount = getAmount(prev_amount);

        Transaction tx =
        {
            type : TxType.Freeze,
            outputs: [Output(amount, getTestKey(idx))]
        };

        storage.put(tx);
        prev_amount = amount;
    }

    foreach (utxo; storage.keys)
    {
        Enrollment enroll =
        {
            utxo_key : utxo,
            cycle_length : 1008
        };

        enrolls ~= enroll;
    }

    return tuple(enrolls, &storage.findUTXO);
}

private PublicKey getTestKey (size_t idx)
{
    return KeyPair.fromSeed(Seed.fromString(pregen_seeds[idx])).address;
}

private string pretty (int[PublicKey] counts)
{
    string res;

    int[string] result;
    foreach (key, count; counts)
        result[key_to_simple[key]] = count;

    auto keys = result.keys;
    sort!((a, b) => a[1..$].to!int < b[1..$].to!int)(keys);

    foreach (key; keys)
        res ~= format("%s: %s, ", key, result[key]);

    return res;
}

// using pregenerated seeds to test the determenistic behavior of the algorithm
// note: sorted for easier comparison with PublicKey[]
private immutable string[64] pregen_seeds =
[
    "SA2ET2TX6HK2THTC2HNTTTUIRPCOVPYCAICVWHD5ENFIP3YEFPEN4N67",
    "SA3BUVIQVJZ5JLPMCRO5FU7D3XOYIMNCOJV6WCWGLVAQQQH6OVZRK7AH",
    "SA3ES4M6ZC7ECGWOH3C75NIE66OS27ZV56FMJQCU4NRKWVA6WSN4EC7A",
    "SA3KKMIPVFWC54KIZWO3JSF57O6HGLTLNHJOOAAN3V5ADRR7B25YFBAB",
    "SA3WV2XWBXCPQEZPJ3EYCMQIROHGLUCIP2M5R2P7JWFVGIEAW3SSTXI3",
    "SA46KRZR5XFZ4V7PQEQNOHQMLLCSNPZYPSCD4FJRYTAWUJ6PXQJF3ALS",
    "SA4C6SXL6GDVAQNLEMS7YNN6HKN5NEYTVYAWA3WFQKBHN5FVS72SFJA6",
    "SA4L3QPE3BSOR3PC6DUVRJEONEWT7ZDLZIL6TYPWTYTY2INANWFU5TXM",
    "SA4OWN3CF2DAXCTX6ANRB6PDBRBRT5SZBXAHUAUZJEABDJQP7S6YJSA2",
    "SA4UEJWCWFKOEDBRESZBOXT7BP2CD4J5TBSK2VIV26P53CCQGKTDKSEX",
    "SA4VX3DOL7PQZ4QZNNMD5XIGRFO67UUYNQVRV2IHVLVNQUY3RCGLBRYD",
    "SA4WK62LK4TGH7AQJV5IULK7WWDGUXZYOL3VOVDMP7JADSH2ANES7AX2",
    "SA7NEUIUDYLCDPIZVYT5SIQECKECTJMSYEVVWGPTODNJSVTZVAUUBXDN",
    "SAAB7SEPJYBNG63YDLBSEVDLUMIB5KPMNDOOAX4M3CTHX7BFXPMKMLLV",
    "SAACDG64DGPNXJTWEL4TBM3G3UR4FTHL7NKWDVDOJD6KSUF437AMWWAV",
    "SAAQZQUY4N73D6ZLPIZUY2TYDF2EHJJQQFL7TXJ6TGKHBYFSB3P24ER2",
    "SAAW6Q2JDOZHWF3EME2F4TXSKRPJFTEGKDFXRRXPS2EJVT6VP3IYKNOU",
    "SAB43JTPSVCVL5ZZKHF2APVB5X45RQIUMJKKZXGRDHKYZ3IZNKQ2KSPJ",
    "SACHUQ7N5DHIJKNNO4YO27CCBK2DT7WEP5ZMP6KQFL6722X3OSZBEC7A",
    "SACSTOE2UROE4TTGR3WLRE5BI5KR4WITLVTUATLRF7CEXTSSJNSECPAO",
    "SAEJHT4LTJQPJXOBHON2OANK3RIWHYXDMUTT63U3KGS6FXLZQJ5EL4UU",
    "SAEP7HH6PHKJZARLY33SOSONFUQ6VXVULN6JMIOJ57UX3YSSUFSMWXPO",
    "SAFITM4H4VZI5Q3PG5WFLEBQAIMT5C7M5N3DL4RHMYX3U5KFCU4GJHVG",
    "SAFQV3JHAAQM3NYTBOG5VI65JC66GVM7LQ2YPXZOC2S5V2WQOUF234U7",
    "SAGVJ3JR4O7CVB6ZOS76FK3ZZEBBJ7RUSBOJR7XBVMCGFKBGQSFZ2SS6",
    "SAH2T5IKSVKNG6S7KQHZAORDPUKJ4FLQVSPGRPZPJW4SKCGNVNGMNMUN",
    "SAHQZH4NDVKGEMURNALWXLGIPF6LI4VKPP2VFVZVLIPZCXKWKUUIF67N",
    "SAI45UJSDWVCLBGPCWAKBRMFJJJRGMBKFV7Y2V547FIMKG7SRYUY77XH",
    "SAIFS45TVW4JWIKMUNXY2UVZDF5UFBJQVICSFZIG26SA5BFBWLM7YU7P",
    "SAINISV2XBB5HE42PM3MRLYRGNYAFVDFIDIKAC2JKZ6UKE36HM7PNRQR",
    "SAJOOW54GPWWFMTBUKGN72E3IJPKSBU6LXBQB2KVTYKVZ6RK3ZMWY7OV",
    "SAKEY5AP6ERGV64XEXMCIEP5N7ZVIOH2ZCMW2DDXWQ7HUQ4WCPXKDW4S",
    "SALDKUFLM63EPIM73TJQQMZMKJLBONQTT2GOYT45EXEUATURT4ONUKMQ",
    "SALN44QGB3PCTI25BC6G2AIASJB4GOL5IWR2EJ3VW3ALSHPKTXOFBNKJ",
    "SALR7IE2O7PCZKAZFTLLIYVQ3LIUS7WTNATPMXSB6OSSI62JW4UQ6MDP",
    "SANQPAHZWL7PMBW3QUKRTF2GOV7SNBMA23XQ34LTMQQ4OFYEQQB4GPVD",
    "SAOB43HVXBKH2NLLLXTYKFOF6P2XCOVUGANCI22IZDSGFM2NVQIOAPUN",
    "SAP6DYQFWKHG3WQ3REX6VJEYNP4A3NIS5ENZXQ4BJTWZLJ6USDPLSOTW",
    "SAPA7HDD2JA6Q45EQIUXMBUNFTCCIA3TGWX6GNWNPF47TSAQRYMJNZAW",
    "SAPDPOZCHWQD6RRNK6ZCAWG4HJVCOR3YKM3PEA3JHI3ZXOUB4RO36OTV",
    "SAQ7BTOZJ4G7TECC6DD4G6QCRN6AUUXYZHUDXRDF672GFDNNKDR534MO",
    "SAQEQ475K4BTKTW5RRZGX6NGRM37SOPIEM3OGVD2WNZMGZHIFDE65KQQ",
    "SAR5W42DCT25H2BJT75CK4A7YBR3JT52D27JEL6X4C7JPZOZJCQHBOI7",
    "SARDEFGFB7I2BS3PDAPQLZXLCBARJPUO3TX3ZZKKSXN6UOU4ZRWL3UY3",
    "SASHHP7BAYKG7UWNGUWDRQT75PBYVQ2K3F475J2BNDSME5GNTS3ZX2CJ",
    "SASN3GQBF2UJD5C6AILBXEDSFNJYK7O52R3GT3HFAWYAO4V4MYSVJU32",
    "SAT7VZQTLY3S5QYPHYPVNE3XIKIRNNNUSR7IS4VIRZCSTKRTFRC6Y4VQ",
    "SATBU2ZDCWOU3AXWL6SW7Y5SGLD3Q3UWRJD2BC2K66T76C3CNELF6JZA",
    "SATDNRQ56C2MWFCKHG7JNT4POSGGQSYQCVVOIOINZF2XBF7UIXZIKOBS",
    "SAU5UUNFJVOGEGGI52NLRJLRYCERGX4ACQMFYXYWADELX7GRRIDYLFPF",
    "SAUH5D3C5NFRO6XOYBC23VTVIMEXGUFB4FJQRK2WEIOVRJ5RVCMOSOCC",
    "SAV3NTUPZCKUDM7IALYMM6KOZBIBG256QUISQEUGQALWHRFEEBZX5MVQ",
    "SAVSOLLRFSFY66RDFPAUF7FV7S6XMYSS222PGVSXLZDJOHR7QOI2LTBL",
    "SAVTHZUIURET5QKUOT2FSL7YKEHMDACXWI4GDN3XOUOZAQJP5VMDLYWE",
    "SAVX7N3LOS3QEJENDMQJ5RUJGWYAUTK7P5BWFUSLHRBKH3IUFSOY2LDZ",
    "SAXEOVH52XG3RT77CBXDUTGH5KKMBBEQ444FM4RS3II3FTEXZXX5ILX4",
    "SAYCEKZOJOWQQZNZ25GZQLCO4N76PHRQ5D2XJIFWG3NGGLVWJL45HKJD",
    "SAYHVSHRSACT5XPUMSEGN53CHXMN37R4VDOZWKYG34EBVEFE5DJAWP5C",
    "SAYTIAI5WWUPH3HXLQBS5SJDNBR226TYWPEAJOPQG3UFUQF5UAPSABWA",
    "SAZAAGLAG5TO4EHP6QLOT6JEYKUSSXUW3SODIXRMEXPFCWKHTQZX7G6W",
    "SB2R6PWVM2TEUEY7KYAGEA6ZFAQZGUBJOX2XWWUHDWYVQDAXVLR6JTMQ",
    "SB34TUEXAXDGBH7RBJM7VNA5CHU52B5N6K6IYTYL3C35XCIOG5LUHH24",
    "SB3GJFPE7HZ7PY6UWHDPSVUXSIHAPGU3NLRISBR4FGY5QJ3GQPFZSSZF",
    "SB4CCMDOQJK7LHS6BAZ2PMB4IMYW26CP25RGBYXZCLMP33GGWFYSF2XQ",
];

/// Convenience: If we adjust the algorithm we want to make it easy to replace
/// all the assertions blocks in this module. Use -version=CalibrateQuorumBalancing
/// to enable printouts without throwing an exception.
private void Assert (lazy bool exp, lazy string diag, size_t line = __LINE__)
{
    import core.exception;

    try
    {
        assert(exp, diag);
    }
    catch (AssertError ae)
    {
        version (CalibrateQuorumBalancing)
        {
            import std.stdio;
            writefln("%s(%s): %s", __FILE__, line, diag);
        }
        else
        {
            ae.line = line;
            throw ae;
        }
    }
}
