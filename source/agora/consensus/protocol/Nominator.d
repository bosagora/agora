/*******************************************************************************

    Contains the SCP consensus driver implementation.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.protocol.Nominator;

import agora.common.crypto.Key;
import agora.common.Config;
import agora.common.Hash : Hash, HashDg, hashPart, hashFull;
import agora.common.Serializer;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.ConsensusData;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.network.NetworkManager;
import agora.node.Ledger;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

import scpd.Cpp;
import scpd.scp.SCP;
import scpd.scp.SCPDriver;
import scpd.scp.Slot;
import scpd.scp.Utils;
import scpd.types.Stellar_types;
import scpd.types.Stellar_types : StellarHash = Hash;
import scpd.types.Stellar_SCP;
import scpd.types.Utils;

import core.stdc.stdint;
import core.time;

mixin AddLogger!();

/// Ditto
public extern (C++) class Nominator : SCPDriver
{
    /// SCP instance
    protected SCP* scp;

    /// Network manager for gossiping SCPEnvelopes
    private NetworkManager network;

    /// Key pair of this node
    private KeyPair key_pair;

    /// Task manager
    private TaskManager taskman;

    /// Ledger instance
    private Ledger ledger;

    /// The set of active timers
    /// Todo: SCPTests.cpp uses fake timers,
    /// Similar to how we use FakeClockBanManager!
    private Set!ulong timers;

    /// The quorum set
    private SCPQuorumSetPtr[StellarHash] quorum_set;

    private alias TimerType = Slot.timerIDs;
    static assert(TimerType.max == 1);

    /// Tracks unique incremental timer IDs
    private ulong[TimerType.max + 1] last_timer_id;

    /// Timer IDs with >= of the active timer will be allowed to run
    private ulong[TimerType.max + 1] active_timer_ids;

    /// Quorum config
    private const QuorumConfig quorum_conf;

    /// Whether we're in the process of nominating
    private bool is_nominating;

extern(D):

    /***************************************************************************

        Constructor

        Params:
            network = the network manager for gossiping SCP messages
            key_pair = the key pair of this node
            ledger = needed for SCP state restoration & block validation
            taskman = used to run timers
            config = the quorum configuration

    ***************************************************************************/

    public this (NetworkManager network, KeyPair key_pair, Ledger ledger,
        TaskManager taskman, ref const QuorumConfig config)
    {
        this.network = network;
        this.quorum_conf = config;
        this.key_pair = key_pair;
        auto node_id = NodeID(StellarHash(key_pair.address));
        const IsValidator = true;
        auto quorum_set = verifyBuildSCPConfig(config);
        this.scp = createSCP(this, node_id, IsValidator, quorum_set);
        this.taskman = taskman;
        this.ledger = ledger;

        auto localQSet = makeSharedSCPQuorumSet(this.scp.getLocalQuorumSet());

        const bytes = ByteSlice.make(XDRToOpaque(*localQSet));
        auto quorum_hash = sha256(bytes);
        this.quorum_set[quorum_hash] = localQSet;

        this.restoreSCPState(ledger);
    }

    /***************************************************************************

        Returns:
            true if we're currently in the process of nominating

    ***************************************************************************/

    public bool isNominating () @safe @nogc nothrow
    {
        return this.is_nominating;
    }

    /***************************************************************************

        Try to begin a nomination round.

        If there is already one in progress, or if there are not enough
        transactions in the tx pool, return early.

    ***************************************************************************/

    public void tryNominate () @safe
    {
        // if we received another transaction while we're nominating, don't nominate again.
        // todo: when we change nomination to be time-based (rather than input-based),
        // then remove this part as it will be handled by a timer
        if (this.is_nominating)
            return;

        this.is_nominating = true;
        scope (exit) this.is_nominating = false;

        ConsensusData data;
        this.ledger.prepareNominatingSet(data);
        if (data.tx_set.length == 0)
            return;  // not ready yet

        // note: we are not passing the previous tx set as we don't really
        // need it at this point (might later be necessary for chain upgrades)
        auto slot_idx = this.ledger.getBlockHeight() + 1;
        this.nominate(slot_idx, data);
    }

    /***************************************************************************

        Verify the quorum configuration, and create a normalized SCPQuorum.

        Params:
            config = the quorum configuration

        Throws:
            an Exception if the quorum configuration is invalid

    ***************************************************************************/

    private static SCPQuorumSet verifyBuildSCPConfig (
        ref const QuorumConfig config)
    {
        import scpd.scp.QuorumSetUtils;

        auto scp_quorum = toSCPQuorumSet(config);
        normalizeQSet(scp_quorum);

        // todo: assertion fails do the misconfigured(?) threshold of 1 which
        // is lower than vBlockingSize in QuorumSetSanityChecker::checkSanity
        const ExtraChecks = false;
        const(char)* reason;
        if (!isQuorumSetSane(scp_quorum, ExtraChecks, &reason))
        {
            import std.conv;
            string failure = reason.to!string;
            log.fatal(failure);
            throw new Exception(failure);
        }

        return scp_quorum;
    }

    /***************************************************************************

        Nominate a new data set to the quorum.
        Failure to nominate is only logged.

        Params:
            slot_idx = the index of the slot to nominate for
            next = the proposed data set for the provided slot index

    ***************************************************************************/

    private void nominate (ulong slot_idx, ConsensusData next) @trusted
    {
        log.info("{}(): Proposing tx set for slot {}", __FUNCTION__, slot_idx);

        auto prev_value = ConsensusData.init.serializeFull().toVec();
        auto next_value = next.serializeFull().toVec();
        if (this.scp.nominate(slot_idx, next_value, prev_value))
        {
            log.info("{}(): Tx set nominated", __FUNCTION__);
        }
        else
        {
            log.info("{}(): Tx set rejected nomination", __FUNCTION__);
        }
    }

    /***************************************************************************

        Restore SCP's internal state based on the provided ledger state

        Params:
            ledger = the ledger instance

    ***************************************************************************/

    private void restoreSCPState (Ledger ledger)
    {
        import agora.common.Serializer;
        import scpd.types.Stellar_SCP;
        import scpd.types.Utils;
        import scpd.types.Stellar_types : StellarHash = Hash, NodeID;
        import std.range;

        auto key = StellarHash(this.key_pair.address);
        auto pub_key = NodeID(key);

        foreach (block_idx, block; ledger.getBlocksFrom(0).enumerate)
        {
            Value block_value = block.serializeFull().toVec();

            SCPStatement statement =
            {
                nodeID: pub_key,
                slotIndex: block_idx,
                pledges: {
                    type_: SCPStatementType.SCP_ST_EXTERNALIZE,
                    externalize_: {
                        commit: {
                            counter: 0,
                            value: block_value,
                        },
                        nH: 0,
                    },
                },
            };

            SCPEnvelope env = SCPEnvelope(statement);
            this.scp.setStateFromEnvelope(block_idx, env);
            if (!this.scp.isSlotFullyValidated(block_idx))
                assert(0);
        }

        // there should at least be a genesis block
        if (this.scp.empty())
            assert(0);
    }

    /***************************************************************************

        Called when a new SCP Envelope is received from the network.

        Params:
            envelope = the SCP envelope

        Returns:
            true if the SCP protocol accepted this envelope

    ***************************************************************************/

    public void receiveEnvelope (SCPEnvelope envelope) @trusted
    {
        const cur_height = this.ledger.getBlockHeight();
        if (envelope.statement.slotIndex <= cur_height)
        {
            log.trace("Rejected envelope with outdated slot #{} (ledger: #{})",
                envelope.statement.slotIndex, cur_height);
            return;  // slot was already externalized, ignore outdated message
        }

        if (this.scp.receiveEnvelope(envelope) != SCP.EnvelopeState.VALID)
            log.info("Rejected invalid envelope: {}", envelope);
    }

    extern (C++):


    /***************************************************************************

        Signs the SCPEnvelope with the node's private key.

        todo: Currently not signing yet. To be done.

        Params:
            envelope = the SCPEnvelope to sign

    ***************************************************************************/

    public override void signEnvelope (ref SCPEnvelope envelope)
    {
    }

    /***************************************************************************

        Validates the provided transaction set for the provided slot index,
        and returns a status code of the validation.

        Params:
            slot_idx = the slot index we're currently reaching consensus for
            value = the transaction set to validate
            nomination = unused, seems to be stellar-specific

    ***************************************************************************/

    public override ValidationLevel validateValue (uint64_t slot_idx,
        ref const(Value) value, bool nomination) nothrow
    {
        scope (failure) assert(0);

        try
        {
            auto data = deserializeFull!ConsensusData(cast(ubyte[])value[]);

            if (auto fail_reason = this.ledger.validateConsensusData(data))
            {
                log.error("validateValue(): Validation failed: {}. Data: {}",
                    fail_reason, data);
                return ValidationLevel.kInvalidValue;
            }
        }
        catch (Exception ex)
        {
            log.error("validateValue(): Received un-deserializable tx set. " ~
                "Error: {}", ex.message);
            return ValidationLevel.kInvalidValue;
        }

        return ValidationLevel.kFullyValidatedValue;
    }

    /***************************************************************************

        Called when consenus has been reached for the provided slot index and
        the transaction set.

        Params:
            slot_idx = the slot index
            value = the transaction set

    ***************************************************************************/

    public override void valueExternalized (uint64_t slot_idx,
        ref const(Value) value)
    {
        scope (failure) assert(0);

        if (slot_idx <= this.ledger.getBlockHeight())
            return;  // slot was already externalized

        auto bytes = cast(ubyte[])value[];
        auto data = deserializeFull!ConsensusData(bytes);

        // enrollment data may be empty, but not transaction set
        if (data.tx_set.length == 0)
            assert(0, "Transaction set empty");

        log.info("Externalized consensus data set at {}: {}", slot_idx, data);
        if (!this.ledger.onExternalized(data))
            assert(0);
    }

    /***************************************************************************

        Params:
            qSetHash = the hash of the quorum set

        Returns:
            the SCPQuorumSet pointer for the provided quorum set hash

    ***************************************************************************/

    public override SCPQuorumSetPtr getQSet (ref const(StellarHash) qSetHash)
    {
        if (auto scp_quroum = qSetHash in this.quorum_set)
            return *scp_quroum;

        return SCPQuorumSetPtr.init;
    }

    /***************************************************************************

        Floods the given SCPEnvelope to the network of connected peers.

        Params:
            envelope = the SCPEnvelope to flood to the network.

    ***************************************************************************/

    public override void emitEnvelope (ref const(SCPEnvelope) envelope)
    {
        try
        {
            SCPEnvelope env = cast()envelope;

            // deep-dup as SCP stores pointers to memory on the stack
            env.statement.pledges = SCPStatement._pledges_t.fromString(
                env.statement.pledges.toString());
            this.network.gossipEnvelope(env);
        }
        catch (Exception ex)
        {
            import std.conv;
            assert(0, ex.to!string);
        }
    }

    /***************************************************************************

        Combine a set of transaction sets into a single transaction set.
        This may be done in arbitrary ways, as long as it's consistent
        (for a given input, the combined output is predictable).

        For simplicity we currently only pick the first transaction set
        to become the "combined" transaction set.

        Params:
            slot_idx = the slot index we're currently reaching consensus for
            candidates = a set of a set of transactions

    ***************************************************************************/

    public override Value combineCandidates (uint64_t slot_idx,
        ref const(set!Value) candidates)
    {
        scope (failure) assert(0);

        foreach (ref const(Value) candidate; candidates)
        {
            auto data = deserializeFull!ConsensusData(cast(ubyte[])candidate[]);

            if (auto msg = this.ledger.validateConsensusData(data))
            {
                log.error("combineCandidates(): Invalid consensus data: {}", msg);
                continue;
            }
            else
            {
                log.info("combineCandidates: {}", slot_idx);
            }

            // todo: currently we just pick the first of the candidate values,
            // but we should ideally pick tx's out of the combined set
            return data.serializeFull().toVec();
        }

        assert(0);  // should not reach here
    }

    /***************************************************************************

        Used for setting and clearing C++ callbacks which fire after a
        given timeout.

        On the D side we spawn a new task which waits until a timer expires.

        The callback is a C++ delegate, we use a helper function to invoke it.

        Params:
            slot_idx = the slot index we're currently reaching consensus for.
            timer_type = the timer type (see Slot.timerIDs).
            timeout = the timeout of the timer, in milliseconds.
            callback = the C++ callback to call.

    ***************************************************************************/

    public override void setupTimer (ulong slot_idx, int timer_type,
        milliseconds timeout, CPPDelegate!SCPCallback* callback)
    {
        scope (failure) assert(0);

        const type = cast(TimerType) timer_type;
        assert(type >= TimerType.min && type <= TimerType.max);
        if (callback is null || timeout == 0)
        {
            // signal deactivation of all current timers with this timer type
            this.active_timer_ids[type] = this.last_timer_id[type] + 1;
            return;
        }

        const timer_id = ++this.last_timer_id[type];
        this.taskman.runTask(
        {
            this.taskman.wait(timeout.msecs);

            // timer was cancelled
            if (timer_id < this.active_timer_ids[type])
                return;

            callCPPDelegate(callback);
        });
    }
}

/// Adds hashing support to SCPStatement
private struct SCPStatementHash
{
    // sanity check in case a new field gets added.
    // todo: use .tupleof tricks for a more reliable field layout change check
    static assert(SCPNomination.sizeof == 80);

    /// instance pointer
    private const SCPStatement* st;

    /// Ctor
    public this (const SCPStatement* st) @safe @nogc nothrow pure
    {
        assert(st !is null);
        this.st = st;
    }

    /***************************************************************************

        Compute the hash for SCPStatement.
        Note: trusted due to union access.

        Params:
            dg = Hashing function accumulator

    ***************************************************************************/

    public void computeHash (scope HashDg dg) const nothrow @trusted @nogc
    {
        hashPart(this.st.nodeID, dg);
        hashPart(this.st.slotIndex, dg);
        hashPart(this.st.pledges.type_, dg);

        final switch (this.st.pledges.type_)
        {
            case SCPStatementType.SCP_ST_PREPARE:
                computeHash(this.st.pledges.prepare_, dg);
                break;

            case SCPStatementType.SCP_ST_CONFIRM:
                computeHash(this.st.pledges.confirm_, dg);
                break;

            case SCPStatementType.SCP_ST_EXTERNALIZE:
                computeHash(this.st.pledges.externalize_, dg);
                break;

            case SCPStatementType.SCP_ST_NOMINATE:
                computeHash(this.st.pledges.nominate_, dg);
                break;
        }
    }

    /***************************************************************************

        Compute the hash for a prepare pledge statement.

        Params:
            prep = the prepare pledge statement
            dg = Hashing function accumulator

    ***************************************************************************/

    public static void computeHash (
        const ref SCPStatement._pledges_t._prepare_t prep,
        scope HashDg dg) nothrow @safe @nogc
    {
        hashPart(prep.quorumSetHash[], dg);
        hashPart(prep.ballot, dg);

        /// these two can legitimately be null in the protocol
        if (prep.prepared !is null)
            hashPart(*prep.prepared, dg);

        /// ditto
        if (prep.preparedPrime !is null)
            hashPart(*prep.preparedPrime, dg);

        hashPart(prep.nC, dg);
        hashPart(prep.nH, dg);
    }

    /***************************************************************************

        Compute the hash for a confirm pledge statement.

        Params:
            conf = the confirm pledge statement
            dg = Hashing function accumulator

    ***************************************************************************/

    public static void computeHash (
        const ref SCPStatement._pledges_t._confirm_t conf,
        scope HashDg dg) nothrow @safe @nogc
    {
        hashPart(conf.ballot, dg);
        hashPart(conf.nPrepared, dg);
        hashPart(conf.nCommit, dg);
        hashPart(conf.nH, dg);
        hashPart(conf.quorumSetHash[], dg);
    }

    /***************************************************************************

        Compute the hash for an externalize pledge statement.

        Params:
            ext = the externalize pledge statement
            dg = Hashing function accumulator

    ***************************************************************************/

    public static void computeHash (
        const ref SCPStatement._pledges_t._externalize_t ext, scope HashDg dg)
        nothrow @safe @nogc
    {
        hashPart(ext.commit, dg);
        hashPart(ext.nH, dg);
        hashPart(ext.commitQuorumSetHash[], dg);
    }

    /***************************************************************************

        Compute the hash for a nomination pledge statement.

        Params:
            nom = the nomination pledge statement
            dg = Hashing function accumulator

    ***************************************************************************/

    public static void computeHash (const ref SCPNomination nom, scope HashDg dg)
        nothrow @safe @nogc
    {
        hashPart(nom.quorumSetHash[], dg);
        hashPart(nom.votes[], dg);
        hashPart(nom.accepted[], dg);
    }
}

/// Adds hashing support to SCPEnvelope
private struct SCPEnvelopeHash
{
    /// instance pointer
    private const SCPEnvelope* env;

    /// Ctor
    public this (const SCPEnvelope* env) @safe @nogc pure nothrow
    {
        assert(env !is null);
        this.env = env;
    }

    /***************************************************************************

        Compute the hash for SCPEnvelope

        Params:
            dg = Hashing function accumulator

    ***************************************************************************/

    public void computeHash (scope HashDg dg) const nothrow @trusted @nogc
    {
        hashPart(SCPStatementHash(&this.env.statement), dg);
        hashPart(this.env.signature[], dg);
    }
}

/// ditto
@safe unittest
{
    SCPStatement st;
    SCPBallot prep;
    SCPBallot prep_prime;

    import std.conv;

    () @trusted {
        st.pledges.prepare_ = SCPStatement._pledges_t._prepare_t.init;
        st.pledges.prepare_.prepared = &prep;
        st.pledges.prepare_.preparedPrime = &prep_prime;
        st.pledges.type_ = SCPStatementType.SCP_ST_PREPARE;
    }();

    auto getStHash () @trusted { return SCPStatementHash(&st); }

    assert(getStHash().hashFull() == Hash.fromString(
        "0x266223f3385aecddc64e02e21cb655d1693002d5da8e49e2c9a73afe0cf3ceac4" ~
        "90b28fdfb42b0d67e7796593907947fb227b1045cf9b14785ba7d34c4305dbf"));

    prep.counter++;
    assert(getStHash().hashFull() == Hash.fromString(
        "0xdc8135b6c7757a1f68db0d792be67764ae3337e02b9cb2cd460fe3fa051a435b1" ~
        "7a82ebd71d9ae00b36a9fcb90fd2b1e1d01bffbe335e1eda7de14ebf1c70a8d"));

    prep_prime.counter++;
    assert(getStHash().hashFull() == Hash.fromString(
        "0x0f4629c0571c806488b6ff737053963e42dc72427ac4de8293b69c674102efbd5" ~
        "709928a32c60008359bd518da08c8a79a0ed38b722f61f741fc7df0f96bd99a"));

    () @trusted { st.pledges.prepare_.prepared = null; }();
    assert(getStHash().hashFull() == Hash.fromString(
        "0x6f056828fa1f7d59fca4279d37a3a933da1360718270872f9c37be67ab10aabdb" ~
        "e0e4d889509f27f4957dc13b0082ac61d1acce19e599a89440679d36fe42ff9"));

    () @trusted { st.pledges.prepare_.preparedPrime = null; }();
    assert(getStHash().hashFull() == Hash.fromString(
        "0x328bcea198398bb6a52036b641f0fcc50ae7d3b97490bfe1e020441d158104458" ~
        "29a63bb892da3ce2e539e1aa5a9f688695aefd54f967c197415ff834f0f0b22"));

    () @trusted { st.pledges.nominate_ = SCPNomination.init; }();
    st.pledges.type_ = SCPStatementType.SCP_ST_NOMINATE;
    assert(getStHash().hashFull() == Hash.fromString(
        "0xc359847b8ddce220c896386c6b05fd12acb36fb850bd4b3959cf97516b9360eda" ~
        "98f9728911e678c342e23e38e300b1872faeddfa4ccd619404f3d9b7fc17439"));

    () @trusted { st.pledges.confirm_ = SCPStatement._pledges_t._confirm_t.init; }();
    st.pledges.type_ = SCPStatementType.SCP_ST_CONFIRM;
    assert(getStHash().hashFull() == Hash.fromString(
        "0x118121cc790639f11190bb5ea1f8023c7889f8484b69b2d13b7056f831b2b5741" ~
        "afe7511a59d24f193fcce5c19080a5ca74ebc8487f1f340d70092066cd11f90"));

    () @trusted { st.pledges.externalize_ = SCPStatement._pledges_t._externalize_t.init; }();
    st.pledges.type_ = SCPStatementType.SCP_ST_EXTERNALIZE;
    assert(getStHash().hashFull() == Hash.fromString(
        "0x3c5a1a66ecf0c1e8992f448718fb1f4a6cbfb9527adba408644caefda8c1b1353" ~
        "98dbc0c33174280e8b0a5fb835dc707f06394c1205f8be545e5f70c771b421d"));

    SCPEnvelope env;
    auto getEnvHash () @trusted { return SCPEnvelopeHash(&env); }

    // empty envelope
    import std.conv;
    assert(getEnvHash().hashFull() == Hash.fromString(
        "0x328bcea198398bb6a52036b641f0fcc50ae7d3b97490bfe1e020441d158104458" ~
        "29a63bb892da3ce2e539e1aa5a9f688695aefd54f967c197415ff834f0f0b22"),
    getEnvHash().hashFull().to!string);

    // with a statement
    env.statement = st;
    assert(getEnvHash().hashFull() == Hash.fromString(
        "0x3c5a1a66ecf0c1e8992f448718fb1f4a6cbfb9527adba408644caefda8c1b1353" ~
        "98dbc0c33174280e8b0a5fb835dc707f06394c1205f8be545e5f70c771b421d"),
    getEnvHash().hashFull().to!string);

    alias Sig = agora.common.Types.Signature;
    Sig sig;  // be warned: toVec() will point to stack-allocated memory
    () @trusted
    {
        auto seed = "SAI4SRN2U6UQ32FXNYZSXA5OIO6BYTJMBFHJKX774IGS2RHQ7DOEW5SJ";
        auto pair = KeyPair.fromSeed(Seed.fromString(seed));
        auto msg = getStHash().hashFull();
        sig = pair.secret.sign(msg[]);
        env.signature = sig[].toVec();
    }();

    // with a signature
    assert(getEnvHash().hashFull() == Hash.fromString(
        "0xa2f59501721aafdc8cc7298cae9270345093ade244590ea89116770a4329cb437" ~
        "c9836eb8ca624c803ae6b85bcfaed802318d07c89a2e9efb145b9c8e5617095"),
    getEnvHash().hashFull().to!string);
}
