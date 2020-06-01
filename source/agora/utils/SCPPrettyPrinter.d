/*******************************************************************************

    Contains pretty-printing routines specialized for SCP types.

    As the integration test-suite imports into PrettyPrinter,
    we want to avoid adding a dependency to SCP.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.SCPPrettyPrinter;

import agora.common.Types;
import agora.common.Amount;
import agora.common.Config;
import agora.common.Serializer;
import agora.common.Types;
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.data.ConsensusData;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.utils.PrettyPrinter;

import scpd.Cpp;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types : StellarHash = Hash;

import std.algorithm;
import std.format;
import std.range;

/*******************************************************************************

    Returns a formatting prettifier for SCPEnvelope.

    Params:
        env = a pointer to SCPEnvelope
        get_qset = getter for quorum sets. If null it won't be used.

*******************************************************************************/

public SCPEnvelopeFmt scpPrettify (in SCPEnvelope* env,
    in GetQSetDg get_qset = null) nothrow @trusted @nogc
{
    return SCPEnvelopeFmt(env, get_qset);
}

/// Formatting struct for `SCPBallot`, deserializes Value types as ConsensusData
public struct SCPBallotFmt
{
    private const(SCPBallot) ballot;

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @trusted nothrow
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
                    prettify(  // cast: deserializer should take const(ubyte)[]
                    (cast(ubyte[])this.ballot.value[]).deserializeFull!ConsensusData));
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
private alias GetQSetDg = SCPQuorumSetPtr delegate (
    ref const(Hash) qSetHash);

/// Formatting struct for a quorum Hash => QuorumConfig through the use
/// of a quorum getter delegate
private struct QuorumFmt
{
    private const(Hash) hash;
    private const(GetQSetDg) getQSet;

    public void toString (scope void delegate(scope const(char)[]) @safe sink)
        @trusted nothrow
    {
        try
        {
            SCPQuorumSetPtr qset;
            if (this.getQSet !is null)
                qset = this.getQSet(this.hash);

            if (qset.ptr !is null)
            {
                auto qconf = toQuorumConfig(*qset.ptr);
                formattedWrite(sink, "{ hash: %s, quorum: %s }",
                    prettify(this.hash), prettify(qconf));
            }
            else
            {
                formattedWrite(sink, "{ hash: %s, quorum: <unknown> }",
                    prettify(this.hash));
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
    private const(SCPStatement._pledges_t._prepare_t) prepare;
    private const(GetQSetDg) getQSet;

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @safe nothrow
    {
        try
        {
            formattedWrite(sink,
                "Prepare { qset: %s, ballot: %s, ",
                QuorumFmt(this.prepare.quorumSetHash, this.getQSet),
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
    private const(SCPStatement._pledges_t._confirm_t) confirm;
    private const(GetQSetDg) getQSet;

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @safe nothrow
    {
        try
        {
            formattedWrite(sink,
                "Confirm { qset: %s, ballot: %s, nPrep: %s, nComm: %s, nH: %s }",
                QuorumFmt(this.confirm.quorumSetHash, this.getQSet),
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
    private const(SCPStatement._pledges_t._externalize_t) externalize;
    private const(GetQSetDg) getQSet;

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @safe nothrow
    {
        try
        {
            formattedWrite(sink,
                "Externalize { commitQset: %s, commit: %s, nh: %s }",
                QuorumFmt(this.externalize.commitQuorumSetHash, this.getQSet),
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
    private const(SCPNomination) nominate;
    private const(GetQSetDg) getQSet;

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @trusted nothrow
    {
        try
        {
            formattedWrite(sink,
                "Nominate { qset: %s, ",
                QuorumFmt(this.nominate.quorumSetHash));

            try
            {
                formattedWrite(sink,
                    "votes: %s, ",
                    this.nominate.votes[]
                        .map!(cd => prettify(
                            // cast: deserializer should take const(ubyte)[]
                            (cast(ubyte[])cd[]).deserializeFull!ConsensusData)));
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
                            // cast: deserializer should take const(ubyte)[]
                            (cast(ubyte[])cd[]).deserializeFull!ConsensusData)));
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
    private const(SCPStatement._pledges_t) pledges;
    private const(GetQSetDg) getQSet;

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @trusted nothrow
    {
        try
        {
            final switch (pledges.type_)
            {
                case SCPStatementType.SCP_ST_PREPARE:
                    formattedWrite(sink, "%s", PrepareFmt(this.pledges.prepare_, this.getQSet));
                    break;
                case SCPStatementType.SCP_ST_CONFIRM:
                    formattedWrite(sink, "%s", ConfirmFmt(this.pledges.confirm_, this.getQSet));
                    break;
                case SCPStatementType.SCP_ST_EXTERNALIZE:
                    formattedWrite(sink, "%s", ExternalizeFmt(this.pledges.externalize_, this.getQSet));
                    break;
                case SCPStatementType.SCP_ST_NOMINATE:
                    formattedWrite(sink, "%s", SCPNominationFmt(this.pledges.nominate_, this.getQSet));
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

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @safe nothrow
    {
        try
        {
            formattedWrite(sink,
                "{ node: %s, slotIndex: %s, pledge: %s }",
                prettify(PublicKey(this.statement.nodeID[])),
                cast(ulong)this.statement.slotIndex,  // cast: consistent cross-platform output
                PledgesFmt(this.statement.pledges, getQSet));
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

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @safe nothrow
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

/// ditto
unittest
{
    import agora.common.Config;
    import agora.common.Hash;
    import agora.common.Serializer;
    import agora.common.Set;
    import agora.consensus.data.Enrollment;
    import agora.consensus.data.genesis.Test;
    import scpd.types.Stellar_types : NodeID, uint256, StellarHash = Hash;
    import scpd.types.Utils;

    Hash quorumSetHash;

    Hash key = Hash("0x000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f" ~
                    "1b60a8ce26f000000000019d6689c085ae165831e934ff763ae46a2" ~
                    "a6c172b3f1b60a8ce26f");
    Hash seed = Hash("0X4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB212" ~
                     "7B7AFDEDA33B4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E" ~
                     "2CC77AB2127B7AFDEDA33B");
    Signature sig = Signature("0x000000000000000000016f605ea9638d7bff58d2c0c" ~
                              "c2467c18e38b36367be78000000000000000000016f60" ~
                              "5ea9638d7bff58d2c0cc2467c18e38b36367be78");
    const Enrollment record =
    {
        utxo_key: key,
        random_seed: seed,
        cycle_length: 1008,
        enroll_sig: sig,
    };

    const(ConsensusData) cd =
    {
        tx_set:  GenesisBlock.txs[1 .. $],
        enrolls: [ record, record, ],
    };

    SCPBallot ballot;
    ballot.counter = 42;
    ballot.value = cd.serializeFull[].toVec();

    auto pair = KeyPair.fromSeed(Seed.fromString("SCFPAX2KQEMBHCG6SJ77YTHVOYKUVHEFDROVFCKTZUG7Z6Q5IKSNG6NQ"));

    auto qc = QuorumConfig(2,
        [PublicKey.fromString("GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN"),
         PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5")]);

    auto scp_quorum = toSCPQuorumSet(qc);
    auto qset = makeSharedSCPQuorumSet(scp_quorum);
    auto quorum_hash = hashFull(*qset);
    SCPQuorumSetPtr[Hash] qmap;

    SCPQuorumSetPtr getQSet (ref const(Hash) hash)
    {
        if (auto qset = hash in qmap)
            return *qset;

        return SCPQuorumSetPtr.init;
    }

    SCPEnvelope env;
    env.statement.nodeID = NodeID(uint256(pair.address));

    /** SCP PREPARE */
    env.statement.pledges.type_ = SCPStatementType.SCP_ST_PREPARE;
    env.statement.pledges.prepare_ = SCPStatement._pledges_t._prepare_t.init; // must initialize
    env.statement.pledges.prepare_.quorumSetHash = quorum_hash;
    env.statement.pledges.prepare_.ballot = ballot;
    env.statement.pledges.prepare_.nC = 100;
    env.statement.pledges.prepare_.nH = 200;

    // missing signature
    env.signature = typeof(env.signature).init;

    // missing signature
    static immutable MissingSig = `{ statement: { node: GBUV...KOEK, slotIndex: 0, pledge: Prepare { qset: { hash: 0xc048...6205, quorum: <unknown> }, ballot: { counter: 42, value: { tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] } }, prep: <null>, prepPrime: <null>, nc: 100, nH: 200 } }, sig: 0x0000...0000 }`;

    assert(MissingSig == format("%s", scpPrettify(&env)),
                         format("%s", scpPrettify(&env)));

    env.signature = pair.secret.sign(hashFull(0)[]);

    // null quorum (hash not found)
    static immutable PrepareRes1 = `{ statement: { node: GBUV...KOEK, slotIndex: 0, pledge: Prepare { qset: { hash: 0xc048...6205, quorum: <unknown> }, ballot: { counter: 42, value: { tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] } }, prep: <null>, prepPrime: <null>, nc: 100, nH: 200 } }, sig: 0x0af7...b5ab }`;

    // with quorum mapping
    static immutable PrepareRes2 = `{ statement: { node: GBUV...KOEK, slotIndex: 0, pledge: Prepare { qset: { hash: 0xc048...6205, quorum: { thresh: 2, nodes: [GBFD...CEWN, GBYK...QCY5], subqs: [] } }, ballot: { counter: 42, value: { tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] } }, prep: <null>, prepPrime: <null>, nc: 100, nH: 200 } }, sig: 0x0af7...b5ab }`;

    // 'prep' pointer is set
    static immutable PrepareRes3 = `{ statement: { node: GBUV...KOEK, slotIndex: 0, pledge: Prepare { qset: { hash: 0xc048...6205, quorum: { thresh: 2, nodes: [GBFD...CEWN, GBYK...QCY5], subqs: [] } }, ballot: { counter: 42, value: { tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] } }, prep: { counter: 42, value: { tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] } }, prepPrime: <null>, nc: 100, nH: 200 } }, sig: 0x0af7...b5ab }`;

    // 'preparedPrime' pointer is set
    static immutable PrepareRes4 = `{ statement: { node: GBUV...KOEK, slotIndex: 0, pledge: Prepare { qset: { hash: 0xc048...6205, quorum: { thresh: 2, nodes: [GBFD...CEWN, GBYK...QCY5], subqs: [] } }, ballot: { counter: 42, value: { tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] } }, prep: { counter: 42, value: { tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] } }, prepPrime: { counter: 42, value: { tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] } }, nc: 100, nH: 200 } }, sig: 0x0af7...b5ab }`;

    assert(PrepareRes1 == format("%s", scpPrettify(&env)),
                          format("%s", scpPrettify(&env)));

    assert(PrepareRes1 == format("%s", scpPrettify(&env, null)),
                          format("%s", scpPrettify(&env, null)));

    assert(PrepareRes1 == format("%s", scpPrettify(&env, &getQSet)),
                          format("%s", scpPrettify(&env, &getQSet)));

    // add the quorum hash mapping, it should change the output
    qmap[quorum_hash] = qset;
    assert(PrepareRes2 == format("%s", scpPrettify(&env, &getQSet)),
                          format("%s", scpPrettify(&env, &getQSet)));

    // set 'prepared' pointer
    env.statement.pledges.prepare_.prepared = &env.statement.pledges.prepare_.ballot;
    assert(PrepareRes3 == format("%s", scpPrettify(&env, &getQSet)),
                          format("%s", scpPrettify(&env, &getQSet)));

    // set 'preparedPrime' pointer
    env.statement.pledges.prepare_.preparedPrime = &env.statement.pledges.prepare_.ballot;
    assert(PrepareRes4 == format("%s", scpPrettify(&env, &getQSet)),
                          format("%s", scpPrettify(&env, &getQSet)));

    /** SCP CONFIRM */
    env.statement.pledges.type_ = SCPStatementType.SCP_ST_CONFIRM;
    env.statement.pledges.confirm_ = SCPStatement._pledges_t._confirm_t.init; // must initialize
    env.statement.pledges.confirm_.ballot = ballot;
    env.statement.pledges.confirm_.nPrepared = 42;
    env.statement.pledges.confirm_.nCommit = 100;
    env.statement.pledges.confirm_.nH = 200;

    // confirm without a known hash
    static immutable ConfirmRes1 = `{ statement: { node: GBUV...KOEK, slotIndex: 0, pledge: Confirm { qset: { hash: 0x0000...0000, quorum: <unknown> }, ballot: { counter: 42, value: { tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] } }, nPrep: 42, nComm: 100, nH: 200 } }, sig: 0x0af7...b5ab }`;

    // confirm with a known hash
    static immutable ConfirmRes2 = `{ statement: { node: GBUV...KOEK, slotIndex: 0, pledge: Confirm { qset: { hash: 0xc048...6205, quorum: { thresh: 2, nodes: [GBFD...CEWN, GBYK...QCY5], subqs: [] } }, ballot: { counter: 42, value: { tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] } }, nPrep: 42, nComm: 100, nH: 200 } }, sig: 0x0af7...b5ab }`;

    // un-deserializable value
    static immutable ConfirmRes3 = `{ statement: { node: GBUV...KOEK, slotIndex: 0, pledge: Confirm { qset: { hash: 0xc048...6205, quorum: { thresh: 2, nodes: [GBFD...CEWN, GBYK...QCY5], subqs: [] } }, ballot: { counter: 0, value: <un-deserializable> }, nPrep: 42, nComm: 100, nH: 200 } }, sig: 0x0af7...b5ab }`;

    // unknown hash
    assert(ConfirmRes1 == format("%s", scpPrettify(&env, &getQSet)),
                         format("%s", scpPrettify(&env, &getQSet)));

    // known hash
    env.statement.pledges.confirm_.quorumSetHash = quorum_hash;
    assert(ConfirmRes2 == format("%s", scpPrettify(&env, &getQSet)),
                         format("%s", scpPrettify(&env, &getQSet)));

    // un-deserializable value
    env.statement.pledges.confirm_.ballot = SCPBallot.init;
    assert(ConfirmRes3 == format("%s", scpPrettify(&env, &getQSet)),
                         format("%s", scpPrettify(&env, &getQSet)));

    // unknown hash
    static immutable ExtRes1 = `{ statement: { node: GBUV...KOEK, slotIndex: 0, pledge: Externalize { commitQset: { hash: 0x0000...0000, quorum: <unknown> }, commit: { counter: 42, value: { tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] } }, nh: 100 } }, sig: 0x0af7...b5ab }`;

    // known hash
    static immutable ExtRes2 = `{ statement: { node: GBUV...KOEK, slotIndex: 0, pledge: Externalize { commitQset: { hash: 0xc048...6205, quorum: { thresh: 2, nodes: [GBFD...CEWN, GBYK...QCY5], subqs: [] } }, commit: { counter: 42, value: { tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] } }, nh: 100 } }, sig: 0x0af7...b5ab }`;

    // un-deserializable value
    static immutable ExtRes3 = `{ statement: { node: GBUV...KOEK, slotIndex: 0, pledge: Externalize { commitQset: { hash: 0xc048...6205, quorum: { thresh: 2, nodes: [GBFD...CEWN, GBYK...QCY5], subqs: [] } }, commit: { counter: 0, value: <un-deserializable> }, nh: 100 } }, sig: 0x0af7...b5ab }`;

    /** SCP EXTERNALIZE */
    env.statement.pledges.type_ = SCPStatementType.SCP_ST_EXTERNALIZE;
    env.statement.pledges.externalize_ = SCPStatement._pledges_t._externalize_t.init; // must initialize
    env.statement.pledges.externalize_.commit = ballot;
    env.statement.pledges.externalize_.nH = 100;

    // unknown hash
    assert(ExtRes1 == format("%s", scpPrettify(&env, &getQSet)),
                      format("%s", scpPrettify(&env, &getQSet)));

    // known hash
    env.statement.pledges.externalize_.commitQuorumSetHash = quorum_hash;
    assert(ExtRes2 == format("%s", scpPrettify(&env, &getQSet)),
                      format("%s", scpPrettify(&env, &getQSet)));

    // un-deserializable value
    env.statement.pledges.externalize_.commit = SCPBallot.init;
    assert(ExtRes3 == format("%s", scpPrettify(&env, &getQSet)),
                      format("%s", scpPrettify(&env, &getQSet)));

    // unknown hash
    static immutable NomRes1 = `{ statement: { node: GBUV...KOEK, slotIndex: 0, pledge: Nominate { qset: { hash: 0x0000...0000, quorum: <unknown> }, votes: [{ tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] }, { tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] }], accepted: [{ tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] }, { tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] }] } }, sig: 0x0af7...b5ab }`;

    // known hash
    static immutable NomRes2 = `{ statement: { node: GBUV...KOEK, slotIndex: 0, pledge: Nominate { qset: { hash: 0xc048...6205, quorum: <unknown> }, votes: [{ tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] }, { tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] }], accepted: [{ tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] }, { tx_set: [Type : Payment, Inputs: None
Outputs (8): GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000),
GCOQ...LRIJ(61,000,000), GCOQ...LRIJ(61,000,000)], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] }] } }, sig: 0x0af7...b5ab }`;

    /** SCP NOMINATE */
    env.statement.pledges.type_ = SCPStatementType.SCP_ST_NOMINATE;
    env.statement.pledges.nominate_ = SCPNomination.init; // must initialize

    auto value = cd.serializeFull[].toVec();

    env.statement.pledges.nominate_.votes.push_back(value);
    env.statement.pledges.nominate_.votes.push_back(value);
    env.statement.pledges.nominate_.accepted.push_back(value);
    env.statement.pledges.nominate_.accepted.push_back(value);

    // unknown hash
    assert(NomRes1 == format("%s", scpPrettify(&env, &getQSet)),
                      format("%s", scpPrettify(&env, &getQSet)));

    // known hash
    env.statement.pledges.nominate_.quorumSetHash = quorum_hash;
    assert(NomRes2 == format("%s", scpPrettify(&env, &getQSet)),
                      format("%s", scpPrettify(&env, &getQSet)));
}
