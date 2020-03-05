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
import agora.common.Hash : hashFull;
import agora.common.Serializer;
import agora.common.Set;
import agora.common.Task;
import agora.consensus.data.Block;
import agora.consensus.data.ConsensusData;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.network.NetworkClient;
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
import scpd.Util;

import core.stdc.stdint;
import core.time;

mixin AddLogger!();

/// Ditto
public extern (C++) class Nominator : SCPDriver
{
    /// SCP instance
    protected SCP* scp;

    /// Key pair of this node
    private KeyPair key_pair;

    /// Task manager
    private TaskManager taskman;

    /// Ledger instance
    private Ledger ledger;

    /// This node's quorum node clients
    private NetworkClient[PublicKey] peers;

    /// The set of active timers
    /// Todo: SCPTests.cpp uses fake timers,
    /// Similar to how we use FakeClockBanManager!
    private Set!ulong timers;

    /// The set of externalized slot indices
    private Set!uint64_t externalized_slots;

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
            key_pair = the key pair of this node
            ledger = needed for SCP state restoration & block validation
            taskman = used to run timers
            config = the quorum configuration

    ***************************************************************************/

    public this (KeyPair key_pair, Ledger ledger, TaskManager taskman,
        ref const QuorumConfig config)
    {
        this.quorum_conf = config;
        this.key_pair = key_pair;
        auto node_id = NodeID(StellarHash(key_pair.address[]));
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

        import agora.network.NetworkClient;
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

        Set up the clients to which we'll be exchanging consensus messages with.

        Params:
            clients = the set of all clients we're networked with. A subset
                      of the clients are in our quorum set, these will be
                      the clients we exchange SCP messages with.

    ***************************************************************************/

    public void setupNetwork (NetworkClient[PublicKey] clients)
    {
        import std.algorithm;
        import std.array;
        import std.typecons;

        void getNodes (in QuorumConfig conf, ref Set!PublicKey nodes)
        {
            foreach (node; conf.nodes)
                nodes.put(node);

            foreach (sub_conf; conf.quorums)
                getNodes(sub_conf, nodes);
        }

        Set!PublicKey quorum_keys;
        getNodes(this.quorum_conf, quorum_keys);

        this.peers = clients.byKeyValue
            .filter!(item => item.key in quorum_keys)
            .map!(item => tuple(item.key, item.value))
            .assocArray();
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

        auto key = StellarHash(this.key_pair.address[]);
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

    public bool receiveEnvelope (SCPEnvelope envelope) @trusted
    {
        return this.scp.receiveEnvelope(envelope) == SCP.EnvelopeState.VALID;
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

        if (slot_idx in this.externalized_slots)
            return;  // slot was already externalized
        this.externalized_slots.put(slot_idx);

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
            foreach (key, node; this.peers)
            {
                SCPEnvelope env = cast()envelope;

                // deep-dup as SCP stores pointers to memory on the stack
                env.statement.pledges = SCPStatement._pledges_t.fromString(
                    env.statement.pledges.toString());
                node.sendEnvelope(env);
            }
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
