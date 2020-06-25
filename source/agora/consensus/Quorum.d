/*******************************************************************************

    Contains the quorum generator algorithm.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.Quorum;

import agora.common.Config;
import agora.common.crypto.Key;
import agora.common.Set;
import agora.common.Types;
import agora.consensus.data.Enrollment;
import agora.consensus.data.UTXOSetValue;

import std.algorithm;
import std.array;
import std.exception;
import std.format;
import std.math;
import std.range;
import std.string;

/*******************************************************************************

    Build the quorum configuration for the given public key and the staked
    enrollments.

    Params:
        node_key = the key of the node for which to generate the quorum
        keys = the array of registered enrollment UTXO keys
        finder = UTXO finder delegate

    Returns:
        the generated quorum config

*******************************************************************************/

public QuorumConfig buildQuorumConfig ( const ref PublicKey node_key,
    in Hash[] keys, in UTXOFinder finder )
{
    Set!PublicKey all_nodes = getPublicKeys(keys, finder);

    QuorumConfig quorum;
    all_nodes.each!(node => quorum.nodes ~= node);
    quorum.nodes.sort();
    quorum.threshold = quorum.nodes.length;

    return quorum;
}

///
unittest
{
    // test various node counts up to 1000 (hard limit)
    foreach (num_nodes; iota(1, 11).map!(n => min(1000, 2 ^^ n)))
    {
        auto data = genTestEnrolls(num_nodes);
        foreach (key; data.keys)
        {
            auto quorum = buildQuorumConfig(key,
                data.enrolls.map!(enr => enr.utxo_key).array, data.finder);
            verifyQuorumSanity(quorum);
            const expected = QuorumConfig(num_nodes, data.keys);
            assert(quorum == expected,
                format("Expected: %s. Got: %s", expected, quorum));
        }
    }
}

/*******************************************************************************

    For each enrollment find the associated public key,
    and return the set of keys.

    Params
        utxo_keys = the list of enrollments' UTXO keys
        finder = UTXO finder delegate

    Returns:
        a set of all enrolled public keys

*******************************************************************************/

private Set!PublicKey getPublicKeys (in Hash[] utxo_keys, in UTXOFinder finder)
{
    Set!PublicKey keys;
    foreach (utxo_key; utxo_keys)
    {
        UTXOSetValue value;
        if (!finder(utxo_key, size_t.max, value))
            assert(0, "UTXO for validator not found!");  // should never happen

        if (value.output.address in keys)  // should never happen
            assert(0, "Cannot have multiple enrollments for one validator!");

        keys.put(value.output.address);
    }

    return keys;
}

/*******************************************************************************

    Params:
        num_enrollments = the number of enrollments to create

    Returns:
        a tuple of (Enrollment[], UTXOFinder)

*******************************************************************************/

version (unittest)
private auto genTestEnrolls (size_t num_enrollments)
{
    struct Result
    {
        PublicKey[] keys;
        Enrollment[] enrolls;
        UTXOFinder finder;
    }

    import agora.common.Amount;
    import agora.consensus.data.Transaction;

    TestUTXOSet storage = new TestUTXOSet;
    KeyPair[] key_pairs = num_enrollments.iota.map!(x => KeyPair.random()).array;

    foreach (idx; 0 .. num_enrollments)
    {
        Transaction tx =
        {
            type : TxType.Freeze,
            outputs: [Output(Amount.MinFreezeAmount, key_pairs[idx].address)]
        };

        storage.put(tx);
    }

    Enrollment[] enrolls;
    foreach (utxo; storage.keys)
    {
        const Enrollment enroll =
        {
            utxo_key : utxo,
            cycle_length : 1008
        };

        enrolls ~= enroll;
    }

    // cast: we need a mutable so we can sort
    PublicKey[] keys = key_pairs.map!(k => cast()k.address).array;
    keys.sort();
    return Result(keys, enrolls, &storage.findUTXO);
}

/*******************************************************************************

    Verify that the provided quorum configuration is considered sane by SCP.

    Params:
        quorum = the quorum config

    Throws:
        an Exception if the quorum is not considered sane by SCP.

*******************************************************************************/

version (unittest)
private void verifyQuorumSanity (const ref QuorumConfig quorum)
{
    import scpd.scp.QuorumSetUtils;
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
