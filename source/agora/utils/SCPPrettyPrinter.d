/*******************************************************************************

    Contains pretty-printing routines specialized for SCP types.

    As the integration test-suite imports into PrettyPrinter,
    we want to avoid adding a dependency to SCP.

    Note:
      This module currently does not use `in` sink as Phobos does not recognize
      them when `-preview=in` is used.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.SCPPrettyPrinter;

import agora.common.Types;
import agora.common.Amount;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.protocol.Data;
import agora.consensus.protocol.Config;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.crypto.Key;
import agora.crypto.Schnorr: Signature;
import agora.node.Config;
import agora.serialization.Serializer;
import agora.utils.PrettyPrinter;

import scpd.Cpp;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types : StellarHash = Hash, NodeID;

import Ocean = ocean.text.convert.Formatter;

import std.algorithm;
import std.format;
import std.range;

/*******************************************************************************

    Returns a formatting prettifier for SCPEnvelope.

    Params:
        env = a pointer to SCPEnvelope
        get_qset = getter for quorum sets. If null it won't be used.

*******************************************************************************/

public SCPEnvelopeFmt scpPrettify (const SCPEnvelope* env,
    const GetQSetDg get_qset = null) nothrow @trusted @nogc
{
    return SCPEnvelopeFmt(env, get_qset);
}

/// Formatting struct for `SCPBallot`, deserializes Value types as ConsensusData
public struct SCPBallotFmt
{
    private const(SCPBallot) ballot;

    public void toString (scope void delegate (in char[]) @safe sink)
        const scope @trusted nothrow
    {
        try
        {
            formattedWrite(sink,
                "{ counter: %s, ",
                this.ballot.counter);

            try
            {
                formattedWrite(sink,
                    "value: %s }",
                    prettify(this.ballot.value[].deserializeFull!ConsensusData));
            }
            catch (Exception ex)
            {
                formattedWrite(sink, "value: <un-deserializable> }");
            }
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

/// SCP Quorum set getter delegate
private alias GetQSetDg = extern(C++) SCPQuorumSetPtr delegate (ref const(NodeID));

/// Formatting struct for a quorum Hash => QuorumConfig through the use
/// of a quorum getter delegate
private struct QuorumFmt
{
    import std.conv;

    private const(NodeID) node_id;
    private const(GetQSetDg) getQSet;

    public void toString (scope void delegate (in char[]) @safe sink)
        const scope @trusted nothrow
    {
        try
        {
            SCPQuorumSetPtr qset = SCPQuorumSetPtr(CppCtor.Use);
            if (this.getQSet !is null)
                qset = this.getQSet(this.node_id);

            if (this.node_id == ulong.max)
                sink("{ id: <unknown>, ");
            else
                formattedWrite(sink, "{ id: %d, ", this.node_id);

            if (qset.ptr is null)
                sink("quorum: <unknown> }");
            else
            {
                auto qconf = toQuorumConfig(*qset.ptr);
                formattedWrite(sink, "quorum: %s }", prettify(qconf));
            }
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

/// Formatting struct for `_prepare_t`
private struct PrepareFmt
{
    private const(NodeID) node_id;
    private const(SCPStatement._pledges_t._prepare_t) prepare;
    private const(GetQSetDg) getQSet;

    public void toString (scope void delegate (in char[]) @safe sink)
        const scope @safe nothrow
    {
        try
        {
            formattedWrite(sink,
                "Prepare { qset: %s, ballot: %s, ",
                QuorumFmt(node_id, this.getQSet),
                SCPBallotFmt(this.prepare.ballot));

            if (this.prepare.prepared !is null)
                formattedWrite(sink, "prep: %s, ",
                    SCPBallotFmt(*this.prepare.prepared));
            else
                formattedWrite(sink, "prep: <null>, ");

            if (this.prepare.preparedPrime !is null)
                formattedWrite(sink, "prepPrime: %s, ",
                    SCPBallotFmt(*this.prepare.preparedPrime));
            else
                formattedWrite(sink, "prepPrime: <null>, ");

            formattedWrite(sink, "nc: %s, nH: %s }",
                this.prepare.nC,
                this.prepare.nH);
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

/// Formatting struct for `_confirm_t`
private struct ConfirmFmt
{
    private const(NodeID) node_id;
    private const(SCPStatement._pledges_t._confirm_t) confirm;
    private const(GetQSetDg) getQSet;

    public void toString (scope void delegate (in char[]) @safe sink)
        const scope @safe nothrow
    {
        try
        {
            formattedWrite(sink,
                "Confirm { qset: %s, ballot: %s, nPrep: %s, nComm: %s, nH: %s }",
                QuorumFmt(this.node_id, this.getQSet),
                SCPBallotFmt(this.confirm.ballot),
                this.confirm.nPrepared,
                this.confirm.nCommit,
                this.confirm.nH);
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

/// Formatting struct for `_externalize_t`
private struct ExternalizeFmt
{
    private const(NodeID) node_id;
    private const(SCPStatement._pledges_t._externalize_t) externalize;
    private const(GetQSetDg) getQSet;

    public void toString (scope void delegate (in char[]) @safe sink)
        const scope @safe nothrow
    {
        try
        {
            formattedWrite(sink,
                "Externalize { commitQset: %s, commit: %s, nh: %s }",
                QuorumFmt(this.node_id, this.getQSet),
                SCPBallotFmt(this.externalize.commit),
                this.externalize.nH);
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

/// Formatting struct for `SCPNomination`, deserializes Value types as ConsensusData
private struct SCPNominationFmt
{
    private const(NodeID) node_id;
    private const(SCPNomination) nominate;
    private const(GetQSetDg) getQSet;

    public void toString (scope void delegate (in char[]) @safe sink)
        const scope @trusted nothrow
    {
        try
        {
            formattedWrite(sink,
                "Nominate { qset: %s, ",
                QuorumFmt(this.node_id, this.getQSet));

            try
            {
                formattedWrite(sink,
                    "votes: %s, ",
                    this.nominate.votes[]
                        .map!(cd => prettify(
                            cd[].deserializeFull!ConsensusData)));
            }
            catch (Exception ex)
            {
                formattedWrite(sink, "votes: <un-deserializable>, ");
            }

            try
            {
                formattedWrite(sink,
                    "accepted: %s }",
                    this.nominate.accepted[]
                        .map!(cd => prettify(
                            cd[].deserializeFull!ConsensusData)));
            }
            catch (Exception ex)
            {
                formattedWrite(sink, "accepted: <un-deserializable> }");
            }
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

/// Formatting struct for `_pledges_t`
private struct PledgesFmt
{
    private const(NodeID) node_id;
    private const(SCPStatement._pledges_t) pledges;
    private const(GetQSetDg) getQSet;

    public void toString (scope void delegate (in char[]) @safe sink)
        const scope @trusted nothrow
    {
        try
        {
            final switch (pledges.type_)
            {
                case SCPStatementType.SCP_ST_PREPARE:
                    formattedWrite(sink, "%s", PrepareFmt(this.node_id,
                        this.pledges.prepare_, this.getQSet));
                    break;
                case SCPStatementType.SCP_ST_CONFIRM:
                    formattedWrite(sink, "%s", ConfirmFmt(this.node_id,
                        this.pledges.confirm_, this.getQSet));
                    break;
                case SCPStatementType.SCP_ST_EXTERNALIZE:
                    formattedWrite(sink, "%s", ExternalizeFmt(this.node_id,
                        this.pledges.externalize_, this.getQSet));
                    break;
                case SCPStatementType.SCP_ST_NOMINATE:
                    formattedWrite(sink, "%s", SCPNominationFmt(this.node_id,
                        this.pledges.nominate_, this.getQSet));
                    break;
            }
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

/// Formatting struct for `SCPStatement`
private struct SCPStatementFmt
{
    private const(SCPStatement) statement;
    private const(GetQSetDg) getQSet;

    public void toString (scope void delegate (in char[]) @safe sink)
        const scope @safe nothrow
    {
        import std.conv;

        try
        {
            string node_id;
            if (this.statement.nodeID == ulong.max)
                node_id = "<unknown>";
            else
                node_id = (cast(ulong)this.statement.nodeID).to!string;

            formattedWrite(sink,
                "{ node: %s, slotIndex: %s, pledge: %s }",
                node_id,
                cast(ulong)this.statement.slotIndex,  // cast: consistent cross-platform output
                PledgesFmt(this.statement.nodeID, this.statement.pledges, getQSet));
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

/// Formatting struct for `SCPEnvelope`
private struct SCPEnvelopeFmt
{
    /// Pointer to SCPEnvelope
    private const SCPEnvelope* envelope;

    /// QuorumSet getter
    private const(GetQSetDg) getQSet;

    /***************************************************************************

        Constructor

        Params:
            env = pointer to an SCPEnvelope
            get_qset = getter for quorum sets. If null it won't be used.

    ***************************************************************************/

    public this (const SCPEnvelope* env, const GetQSetDg getQSet)
        @nogc @trusted nothrow
    {
        assert(env !is null);
        this.envelope = env;
        this.getQSet = getQSet;
    }

    /***************************************************************************

        Stringification support

        Params:
            sink = the delegate to use as a sink

    ***************************************************************************/

    public void toString (scope void delegate (in char[]) @safe sink)
        const scope @safe nothrow
    {
        try
        {
            formattedWrite(sink,
                "{ statement: %s, sig: %s }",
                SCPStatementFmt(this.envelope.statement, this.getQSet),
                prettify(this.envelope.signature));
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

/// Helper function for unittests
version (unittest)
    private void testAssert (T) (string expected, in T toFmt, int line = __LINE__)
    {
        import std.stdio;

        auto phobosResult = format("%s", toFmt);
        auto oceanResult = Ocean.format("{}", toFmt);

        if (expected != phobosResult)
        {
            stderr.writeln("\tPhobos result doesn't match expected output");
            stderr.writeln("\tTest is located at ", __FILE__, ":", line);
            stderr.writeln("\tExpected: ", expected);
            stderr.writeln("\tPhobos:   ", phobosResult);
            stderr.writeln("\tOcean:    ", oceanResult);
            assert(0);
        }
        if (expected != oceanResult)
        {
            stderr.writeln("\tOcean result doesn't match expected output (but Phobos do)");
            stderr.writeln("\tExpected: ", expected);
            stderr.writeln("\tOcean:    ", oceanResult);
            assert(0);
        }
    }

unittest
{
    import agora.common.Set;
    import agora.consensus.data.Enrollment;
    import agora.consensus.data.genesis.Test;
    import agora.crypto.Hash;
    import agora.utils.Test;
    import scpd.types.Stellar_types : NodeID, StellarHash = Hash;
    import scpd.types.Utils;

    Hash key = Hash("0x000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f" ~
                    "1b60a8ce26f000000000019d6689c085ae165831e934ff763ae46a2" ~
                    "a6c172b3f1b60a8ce26f");
    Hash seed = Hash("0X4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB212" ~
                     "7B7AFDEDA33B4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E" ~
                     "2CC77AB2127B7AFDEDA33B");
    Signature sig = Signature.fromString("0x000000000000000000016f605ea9638d7bff58d2c0c" ~
                              "c2467c18e38b36367be78000000000000000000016f60" ~
                              "5ea9638d7bff58d2c0cc2467c18e38b36367be78");
    const Enrollment record =
    {
        utxo_key: key,
        commitment: seed,
        enroll_sig: sig,
    };

    auto tx_hash = Transaction(
    [
        Output(2_000_000.coins, WK.Keys.NODE2.address, OutputType.Freeze),
        Output(2_000_000.coins, WK.Keys.NODE3.address, OutputType.Freeze),
        Output(2_000_000.coins, WK.Keys.NODE4.address, OutputType.Freeze),
        Output(2_000_000.coins, WK.Keys.NODE5.address, OutputType.Freeze),
        Output(2_000_000.coins, WK.Keys.NODE6.address, OutputType.Freeze),
        Output(2_000_000.coins, WK.Keys.NODE7.address, OutputType.Freeze),
    ]).hashFull();

    const(ConsensusData) cd =
    {
        tx_set: [ tx_hash ],
        enrolls: [ record, record, ],
        missing_validators: [0, 2, 4],
    };

    SCPBallot ballot;
    ballot.counter = 42;
    ballot.value = cd.serializeFull[].toVec();

    auto pair = WK.Keys.NODE2;
    auto pair_utxo_key = Hash("0x321efeea33f06eceefcc2ff8a646eac3e7d0d3de52820485b7004105dec3211f3631981a9c436afcd2dfdb264c5546c04855825080b2f6173b67f74c8df321a3");

    auto qc = QuorumConfig(2, [0, 1]);

    auto scp_quorum = toSCPQuorumSet(qc);
    auto qset = makeSharedSCPQuorumSet(scp_quorum);
    auto quorum_hash = hashFull(*qset);

    static struct QSetHandler
    {
        SCPQuorumSetPtr[NodeID] map;

        extern(C++) SCPQuorumSetPtr getQSet (ref const(NodeID) hash)
        {
            if (auto qset = hash in this.map)
                return *qset;

            return SCPQuorumSetPtr.init;
        }
    }
    QSetHandler qset_handler;

    SCPEnvelope env;
    env.statement.nodeID = NodeID(0);

    /** SCP PREPARE */
    env.statement.pledges.type_ = SCPStatementType.SCP_ST_PREPARE;
    env.statement.pledges.prepare_ = SCPStatement._pledges_t._prepare_t.init; // must initialize
    env.statement.pledges.prepare_.ballot = ballot;
    env.statement.pledges.prepare_.nC = 100;
    env.statement.pledges.prepare_.nH = 200;

    // missing signature
    env.signature = typeof(env.signature).init;

    // missing signature
    static immutable MissingSig = `{ statement: { node: 0, slotIndex: 0, pledge: Prepare { qset: { id: 0, quorum: <unknown> }, ballot: { counter: 42, value: { tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] } }, prep: <null>, prepPrime: <null>, nc: 100, nH: 200 } }, sig: 0x0000...0000 }`;

    testAssert(MissingSig, scpPrettify(&env));

    env.signature = sig.toBlob();

    // null quorum (hash not found)
    static immutable PrepareRes1 = `{ statement: { node: 0, slotIndex: 0, pledge: Prepare { qset: { id: 0, quorum: <unknown> }, ballot: { counter: 42, value: { tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] } }, prep: <null>, prepPrime: <null>, nc: 100, nH: 200 } }, sig: 0x0000...be78 }`;

    // with quorum mapping
    static immutable PrepareRes2 = `{ statement: { node: 0, slotIndex: 0, pledge: Prepare { qset: { id: 0, quorum: { thresh: 2, nodes: [0, 1], subqs: [] } }, ballot: { counter: 42, value: { tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] } }, prep: <null>, prepPrime: <null>, nc: 100, nH: 200 } }, sig: 0x0000...be78 }`;

    // 'prep' pointer is set
    static immutable PrepareRes3 = `{ statement: { node: 0, slotIndex: 0, pledge: Prepare { qset: { id: 0, quorum: { thresh: 2, nodes: [0, 1], subqs: [] } }, ballot: { counter: 42, value: { tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] } }, prep: { counter: 42, value: { tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] } }, prepPrime: <null>, nc: 100, nH: 200 } }, sig: 0x0000...be78 }`;

    // 'preparedPrime' pointer is set
    static immutable PrepareRes4 = `{ statement: { node: 0, slotIndex: 0, pledge: Prepare { qset: { id: 0, quorum: { thresh: 2, nodes: [0, 1], subqs: [] } }, ballot: { counter: 42, value: { tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] } }, prep: { counter: 42, value: { tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] } }, prepPrime: { counter: 42, value: { tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] } }, nc: 100, nH: 200 } }, sig: 0x0000...be78 }`;

    testAssert(PrepareRes1, scpPrettify(&env));
    testAssert(PrepareRes1, scpPrettify(&env, null));
    testAssert(PrepareRes1, scpPrettify(&env, &qset_handler.getQSet));

    // add the quorum hash mapping, it should change the output
    qset_handler.map[env.statement.nodeID] = qset;
    testAssert(PrepareRes2, scpPrettify(&env, &qset_handler.getQSet));

    // set 'prepared' pointer
    env.statement.pledges.prepare_.prepared = &env.statement.pledges.prepare_.ballot;
    testAssert(PrepareRes3, scpPrettify(&env, &qset_handler.getQSet));

    // set 'preparedPrime' pointer
    env.statement.pledges.prepare_.preparedPrime = &env.statement.pledges.prepare_.ballot;
    testAssert(PrepareRes4, scpPrettify(&env, &qset_handler.getQSet));

    /** SCP CONFIRM */
    env.statement.pledges.type_ = SCPStatementType.SCP_ST_CONFIRM;
    env.statement.pledges.confirm_ = SCPStatement._pledges_t._confirm_t.init; // must initialize
    env.statement.pledges.confirm_.ballot = ballot;
    env.statement.pledges.confirm_.nPrepared = 42;
    env.statement.pledges.confirm_.nCommit = 100;
    env.statement.pledges.confirm_.nH = 200;

    // confirm without a known hash
    static immutable ConfirmRes1 = `{ statement: { node: <unknown>, slotIndex: 0, pledge: Confirm { qset: { id: <unknown>, quorum: <unknown> }, ballot: { counter: 42, value: { tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] } }, nPrep: 42, nComm: 100, nH: 200 } }, sig: 0x0000...be78 }`;

    // confirm with a known hash
    static immutable ConfirmRes2 = `{ statement: { node: 0, slotIndex: 0, pledge: Confirm { qset: { id: 0, quorum: { thresh: 2, nodes: [0, 1], subqs: [] } }, ballot: { counter: 42, value: { tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] } }, nPrep: 42, nComm: 100, nH: 200 } }, sig: 0x0000...be78 }`;

    // un-deserializable value
    static immutable ConfirmRes3 = `{ statement: { node: 0, slotIndex: 0, pledge: Confirm { qset: { id: 0, quorum: { thresh: 2, nodes: [0, 1], subqs: [] } }, ballot: { counter: 0, value: <un-deserializable> }, nPrep: 42, nComm: 100, nH: 200 } }, sig: 0x0000...be78 }`;
    // unknown id
    env.statement.nodeID = ulong.max;
    testAssert(ConfirmRes1, scpPrettify(&env, &qset_handler.getQSet));

    // known id
    env.statement.nodeID = NodeID(0);
    testAssert(ConfirmRes2, scpPrettify(&env, &qset_handler.getQSet));

    // un-deserializable value
    env.statement.pledges.confirm_.ballot = SCPBallot.init;
    testAssert(ConfirmRes3, scpPrettify(&env, &qset_handler.getQSet));

    // unknown id
    static immutable ExtRes1 = `{ statement: { node: <unknown>, slotIndex: 0, pledge: Externalize { commitQset: { id: <unknown>, quorum: <unknown> }, commit: { counter: 42, value: { tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] } }, nh: 100 } }, sig: 0x0000...be78 }`;
    // known id
    static immutable ExtRes2 = `{ statement: { node: 0, slotIndex: 0, pledge: Externalize { commitQset: { id: 0, quorum: { thresh: 2, nodes: [0, 1], subqs: [] } }, commit: { counter: 42, value: { tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] } }, nh: 100 } }, sig: 0x0000...be78 }`;
    // un-deserializable value
    static immutable ExtRes3 = `{ statement: { node: 0, slotIndex: 0, pledge: Externalize { commitQset: { id: 0, quorum: { thresh: 2, nodes: [0, 1], subqs: [] } }, commit: { counter: 0, value: <un-deserializable> }, nh: 100 } }, sig: 0x0000...be78 }`;

    /** SCP EXTERNALIZE */
    env.statement.pledges.type_ = SCPStatementType.SCP_ST_EXTERNALIZE;
    env.statement.pledges.externalize_ = SCPStatement._pledges_t._externalize_t.init; // must initialize
    env.statement.pledges.externalize_.commit = ballot;
    env.statement.pledges.externalize_.nH = 100;

    // unknown id
    env.statement.nodeID = ulong.max;
    testAssert(ExtRes1, scpPrettify(&env, &qset_handler.getQSet));

    // known id
    env.statement.nodeID = NodeID(0);
    testAssert(ExtRes2, scpPrettify(&env, &qset_handler.getQSet));

    // un-deserializable value
    env.statement.pledges.externalize_.commit = SCPBallot.init;
    testAssert(ExtRes3, scpPrettify(&env, &qset_handler.getQSet));

    // unknown id
    static immutable NomRes1 = `{ statement: { node: <unknown>, slotIndex: 0, pledge: Nominate { qset: { id: <unknown>, quorum: <unknown> }, votes: [{ tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] }, { tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] }], accepted: [{ tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] }, { tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] }] } }, sig: 0x0000...be78 }`;
    // known id
    static immutable NomRes2 = `{ statement: { node: 0, slotIndex: 0, pledge: Nominate { qset: { id: 0, quorum: { thresh: 2, nodes: [0, 1], subqs: [] } }, votes: [{ tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] }, { tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] }], accepted: [{ tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] }, { tx_set: [0xaf63...37f2], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] }] } }, sig: 0x0000...be78 }`;

    /** SCP NOMINATE */
    env.statement.pledges.type_ = SCPStatementType.SCP_ST_NOMINATE;
    env.statement.pledges.nominate_ = SCPNomination.init; // must initialize

    auto value = cd.serializeFull[].toVec();

    env.statement.pledges.nominate_.votes.push_back(value);
    env.statement.pledges.nominate_.votes.push_back(value);
    env.statement.pledges.nominate_.accepted.push_back(value);
    env.statement.pledges.nominate_.accepted.push_back(value);

    // unknown id
    env.statement.nodeID = ulong.max;
    testAssert(NomRes1, scpPrettify(&env, &qset_handler.getQSet));

    // known id
    env.statement.nodeID = NodeID(0);
    testAssert(NomRes2, scpPrettify(&env, &qset_handler.getQSet));
}
