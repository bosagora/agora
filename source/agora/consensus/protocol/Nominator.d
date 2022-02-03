/*******************************************************************************

    Contains the SCP consensus driver implementation.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.protocol.Nominator;

import agora.common.Amount;
import agora.common.BitMask;
import agora.common.ManagedDatabase;
import agora.serialization.Serializer;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Params;
import agora.consensus.data.Enrollment;
import agora.consensus.data.UTXO;
import agora.consensus.data.ValidatorBlockSig;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.protocol.Data;
import agora.consensus.protocol.Config;
import agora.consensus.protocol.EnvelopeStore;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr;
import agora.network.Clock;
import agora.network.Manager;
import agora.consensus.Ledger;
import agora.utils.Log;
import agora.utils.SCPPrettyPrinter;
import agora.utils.PrettyPrinter;

import scpd.Cpp;
import scpd.scp.SCP;
import scpd.scp.SCPDriver;
import scpd.scp.Slot;
import scpd.scp.Utils;
import scpd.types.Stellar_types : NodeID, StellarHash = Hash;
import scpd.types.Stellar_SCP;
import scpd.types.Utils;
import scpd.types.XDRBase : opaque_array;

import geod24.bitblob;

import core.stdc.stdint;

import std.algorithm;
import std.container : DList;
import std.conv;
import std.format;
import std.path : buildPath;
import std.range : assumeSorted, chain;
import core.time;

// TODO: The block should probably have a size limit rather than a maximum
//  number of transactions.
//  But for now set a maximum number of transactions to a thousand
enum MaxTransactionsPerBlock = 1000;

/// Ditto
public extern (C++) class Nominator : SCPDriver
{
    /// Logger instance
    protected Logger log;

    /// Node is shutting down
    protected bool is_shutting_down;

    /// Consensus parameters
    protected immutable(ConsensusParams) params;

    /// Clock instance
    private Clock clock;

    /// SCP instance
    protected SCP* scp;

    /// Network manager for gossiping SCPEnvelopes
    private NetworkManager network;

    /// Key pair of this node
    protected KeyPair kp;

    /// Task manager
    private ITaskManager taskman;

    /// Ledger instance
    protected ValidatingLedger ledger;

    /// The mapping of all known quorum sets
    private SCPQuorumSetPtr[NodeID] known_quorums;

    private alias TimerType = Slot.timerIDs;
    static assert(TimerType.max == 1);

    /// Currently active timers grouped by type
    private ITimer[TimerType.max + 1] active_timers;

    /// Whether we're in the asynchronous stage of nominating
    private bool is_nominating;

    /// Last height that we finished the nomination round
    private Height heighest_ballot_height;

    ///
    protected enum TimersIdx
    {
        /// Periodic nomination timer. It runs every second and checks the clock
        /// time to see if it's time to start nominating. We do not use the
        /// `BlockInterval` interval directly because this makes the timer
        /// succeptible to clock drift. Instead, the clock is checked every second.
        /// Note that Clock network synchronization is not yet implemented.
        Nomination,
        /// Timer used for processing queued incoming SCP Envelope messages
        Envelope,
        /// Timer passed in from FullNode or Validator to trigger block,
        /// signature and tx catchup
        Catchup,
    }

    /// Timers this node has started not including the SCP slot timers
    protected ITimer[TimersIdx.max + 1] timers;

    /// SCPEnvelopeStore instance
    protected SCPEnvelopeStore store;

    /// Signatures we receive early
    private Set!ValidatorBlockSig early_sigs;

    /// How many blocks into the future we will store early signatures
    private const EarlySignatureThreshold = 3;

    // Height => Point (UTXO hash) => Signature
    private Signature[Hash][Height] slot_sigs;

    /// Enrollment manager
    public EnrollmentManager enroll_man;

    /// hash of previous block
    private Hash prev_value_hash;

    /// Used as "prev_value" when nominating
    private Value prev_value;

    /// User configured nomination frequency
    private const Duration nomination_interval;

    /// User configured nomination frequency
    private Duration round_timeout;

    /// Delegate called when node's own nomination is invalid
    public extern (D) void delegate (in ConsensusData data, in string msg)
        @safe onInvalidNomination;

    /// Delegate called when a block is to be externalized
    public extern (D) string delegate (in Block) @safe acceptBlock;

    /// The missing validators at the start of the nomination round
    protected uint[] initial_missing_validators;

    /// List of incoming SCPEnvelopes that need to be processed
    private DList!SCPEnvelope queued_envelopes;

    /// Envelope process task delay
    private enum EnvTaskDelay = 10.msecs;

    /// catchup task delay
    private enum CatchupTaskDelay = 10.msecs;

    /// Hashes of Values we fully validated for a slot
    private Set!Hash fully_validated_value;

    /// Hashes of envelopes we have processed already
    private Set!Hash seen_envs;

    /// Block ready to externalize once majority signatures are added
    private Block pending_block;

extern(D):

    /***************************************************************************

        Constructor

        Params:
            params = consensus params
            key_pair = the key pair of this node
            clock = clock instance
            network = the network manager for gossiping SCP messages
            ledger = needed for SCP state restoration & block validation
            enroll_man = used to look up the commitment & preimages
            taskman = used to run timers
            data_dir = path to the data directory
            nomination_interval = How often to trigger `checkNominate`
            externalize = delegate called when a block is to be externalized

    ***************************************************************************/

    public this (immutable(ConsensusParams) params, KeyPair key_pair,
        Clock clock, NetworkManager network, ValidatingLedger ledger,
        EnrollmentManager enroll_man, ITaskManager taskman, ITimer catchup_timer,
        ManagedDatabase cacheDB,
        Duration nomination_interval,
        string delegate (in Block) @safe externalize)
    {
        assert(externalize !is null);

        this.log = Logger(__MODULE__);
        this.params = params;
        this.clock = clock;
        this.network = network;
        this.kp = key_pair;
        this.taskman = taskman;
        this.ledger = ledger;
        this.enroll_man = enroll_man;
        this.store = new SCPEnvelopeStore(cacheDB);
        // Create stopped timers
        this.timers[TimersIdx.Envelope] = this.taskman.createTimer(&this.envelopeProcessTask);
        this.timers[TimersIdx.Nomination] = this.taskman.createTimer(&this.checkNominate);
        this.timers[TimersIdx.Catchup] = catchup_timer; // Created in caller

        // Find the node id of this validator and create an SCPObject
        Hash[] utxo_keys;
        this.enroll_man.getEnrolledUTXOs(Height(1), utxo_keys);
        const this_utxo = this.enroll_man.getEnrollmentKey();
        NodeID node_id = utxo_keys.countUntil(this_utxo);
        this.updateSCPObject(node_id);
        this.restoreSCPState();
        this.nomination_interval = nomination_interval;
        this.round_timeout = this.nomination_interval;
        this.acceptBlock = externalize;
    }

    /// Shut down the timers
    public void shutdown () @safe
    {
        this.is_shutting_down = true;
        log.info("{}: Shutdown timers", __FUNCTION__);
        this.timers[].chain(this.active_timers[]).each!((t)
        {
            if (t !is null)
                t.stop();
        });
        this.storeLatestState();
    }

    /// Processes incoming queued envelopes
    private void envelopeProcessTask ()
    {
        while (!this.queued_envelopes.empty && this.pending_block == Block.init)
        {
            auto env = this.queued_envelopes.front;
            this.queued_envelopes.removeFront();
            this.handleSCPEnvelope(env);
        }
    }

    /***************************************************************************

        Create or update Stellar SCP object

        A validator creates SCP object with the UTXO for enrollment. This
        checks that the UTXO key for enrollment exists and new SCP should be
        created because of new enrollment of this node. If there is an
        existing SCP object, this just change the node id for the SCP object.

        Params:
            node_id = the node id of this validator

    ***************************************************************************/

    public void updateSCPObject (in NodeID node_id)
        nothrow @safe
    {
        import scpd.types.Stellar_types;
        try
        {
            // TODO: We should apply the situation where this validator has
            // enrolled with another UTXO after its previous enrollment expired.
            if (this.scp is null)
            {
                const IsValidator = true;
                const no_quorum = SCPQuorumSet.init;  // will be configured by setQuorumConfig()
                () @trusted {
                    this.scp = createSCP(this, node_id, IsValidator, no_quorum);
                }();
            }
            else
            {
                () @trusted {
                    this.scp.changeNodeID(node_id);
                }();
            }
        }
        catch (Exception e)
        {
            log.fatal("updateSCPObject: Exception thrown: {}", e);
            assert(0);
        }
    }

    /***************************************************************************

        Update our quorum configuration and store the mapping of all quorums
        for lookup in getQSet().

        Params:
            node_id = the node id of this validator
            quorums = the mapping of all active validators' quorums

    ***************************************************************************/

    public void setQuorumConfig (ref const(NodeID) node_id,
        const(QuorumConfig)[NodeID] quorums) nothrow @safe
    {
        // If a nomination is running, we determine the nomination is not
        // fatal only when the slot id is for the next height. In that case,
        // we stop the nomination and set the new quorum set.
        if(this.is_nominating)
        {
            const height = this.ledger.height();
            try
            {
                () @trusted {
                    const slot_idx = this.scp.getHighSlotIndex();
                    if (slot_idx == height.value + 1)
                        this.stopNominationRound(Height(slot_idx));
                    else
                    {
                        log.fatal("Invalid call to setQuorumConfig for SCP " ~
                            "slot #{} at ledger height #{}", slot_idx, height);
                        assert(0);
                    }
                }();
            }
            catch (Exception e)
            {
                log.error("setQuorumConfig: Exception thrown: {} " ~
                    "at height #{}", e, height);
            }
        }

        () @trusted { this.known_quorums.clear(); }();

        foreach (qpair; quorums.byKeyValue)  // opApply2 is not nothrow..
        {
            auto quorum_set = buildSCPConfig(qpair.value);
            auto shared_set = makeSharedSCPQuorumSet(quorum_set);
            this.known_quorums[qpair.key] = shared_set;

            if (qpair.key == node_id)
                () @trusted { this.scp.updateLocalQuorumSet(quorum_set); }();
        }
    }

    /***************************************************************************

        Arm a task timer

        Helper function to arm a task timer unless we are shutting down.
        Our timers are non-periodic, so we achieve periodic behavior
        by re-arming manually.

        Params:
          timer_id = The index of the timer
          interval = The interval to rearm the timer with.

    ***************************************************************************/

    private void armTaskTimer (in TimersIdx timer_id, in Duration interval)
        @trusted nothrow
    {
        if (!this.is_shutting_down)
        {
            if (!this.timers[timer_id].pending())
            {
                this.log.dbg("Re-arming timer {} for {}", timer_id, interval);
                this.timers[timer_id].rearm(interval, false);
            }
        }
        else
            this.log.dbg("Not re-arming timer {} for {} because we are shutting down",
                         timer_id, interval);
    }

    /***************************************************************************

        Start nominating.

        This is called from the Validator class when we first detect we are
        a validator.

    ***************************************************************************/

    public void start () @safe nothrow
    {
        log.info("Starting nominating timer..");
        this.armTaskTimer(TimersIdx.Nomination, this.nomination_interval);
    }

    /***************************************************************************

        Stops nominating.

        This should be called once when a Node's enrollment expires.

    ***************************************************************************/

    public void stopNominatingTimer () @safe nothrow
    {
        log.info("Stopping nominating timer.");
        this.timers[TimersIdx.Nomination].stop();
    }

    /***************************************************************************

        Stop the nominating round. Should be called after a block is accepted
        to the ledger.

        This does not stop the periodic nomination check timer,
        but it stops the node from continuing nominating any transaction sets
        which were proposed based on a previous ledger state.

        This routine should be called after every externalize event and
        after any valid block is received from the network (getBlocksFrom()).

        Params:
            height = the block height

    ***************************************************************************/

    public void stopNominationRound (Height height) @safe nothrow
    {
        this.is_nominating = false;
        () @trusted {
            if (this.scp !is null)
                this.scp.stopNomination(height);
        }();

        foreach (timer; this.active_timers)
        {
            if (timer !is null)
                timer.stop();
        }

        this.active_timers[] = null;
    }

    /***************************************************************************

        Check whether we're ready to nominate a new block.

        Returns:
            true if the validator is ready to start nominating

    ***************************************************************************/

    protected bool prepareNominatingSet (out ConsensusData data) @safe
    {
        this.ledger.prepareNominatingSet(data);

        // check whether the consensus data is valid before nominating it.
        if (auto msg = this.ledger.validateConsensusData(data, data.missing_validators))
        {
            this.log.error("prepareNominatingSet(): Invalid consensus data: {}. Data: {}",
                    msg, data.prettify);
            if (this.onInvalidNomination)
                this.onInvalidNomination(data, msg);
            return false;
        }

        return true;
    }

    /***************************************************************************

        Gets the expected block nomination time offset from Genesis start time.

        Returns:
            the expected block nomination time for the provided height

    ***************************************************************************/

    protected TimePoint getExpectedBlockTime () @safe @nogc nothrow pure
    {
        return this.params.GenesisTimestamp +
            (ledger.height() + 1) * this.params.BlockInterval;
    }

    /***************************************************************************

        The main nominating function.

        This function is called periodically by the nominating timer.

        The function will return early if either one of these are true:
        - We're already in the asynchronous stage of nominating or balloting
        - The current time is < getExpectedBlockTime(slot_idx)

    ***************************************************************************/

    protected void checkNominate () @safe
    {
        scope (exit)
        {
            this.armTaskTimer(TimersIdx.Nomination, this.round_timeout);
        }
        const slot_idx = this.ledger.height() + 1;
        const cur_time = this.clock.networkTime();
        const next_nomination = this.getExpectedBlockTime();
        if (cur_time < next_nomination)
        {
            this.log.trace(
                "checkNominate(): Too early to nominate (current: {}, next: {})",
                cur_time, next_nomination);
            return;
        }

        if (this.heighest_ballot_height >= slot_idx)
        {
            this.log.trace("checkNominate(): Balloting already started for height {}" ~
                " skipping new nomination", slot_idx);
            () @trusted
            {
                foreach (const ref env; this.scp.getLatestMessagesSend(slot_idx))
                    this.emitEnvelope(env);
            } ();
            return;
        }

        ConsensusData data;
        // `prepareNomintingSet` will log something if it returns `false`
        if (!this.prepareNominatingSet(data))
            return;

        if (!this.is_nominating)
            this.initial_missing_validators = data.missing_validators;

        log.info("Nominating {} at {}", data.prettify, cur_time);
        this.is_nominating = true;

        this.nominate(slot_idx, data);
    }

    /***************************************************************************

        Convert the quorum config into a normalizec SCP quorum config

        Params:
            config = the quorum configuration

    ***************************************************************************/

    private static SCPQuorumSet buildSCPConfig (in QuorumConfig config)
        @safe nothrow
    {
        import scpd.scp.QuorumSetUtils;
        auto scp_quorum = toSCPQuorumSet(config);
        () @trusted { normalizeQSet(scp_quorum); }();
        return scp_quorum;
    }

    /***************************************************************************

        Nominate a new data set to the quorum.
        Failure to nominate is only logged.

        Params:
            slot_idx = the index of the slot to nominate for
            next = the proposed data set for the provided slot index

    ***************************************************************************/

    protected void nominate (ulong slot_idx, in ConsensusData next) @trusted
    {
        log.info("{}(): Proposing tx set for slot {}, ledger is at height {}",
            __FUNCTION__, slot_idx, this.ledger.lastBlock().header.height);

        const lastBlockHash = this.ledger.lastBlock.hashFull();
        if (prev_value_hash != lastBlockHash)
        {
            // Use hash of previous block as the previous slot value for randomizing
            prev_value = lastBlockHash.serializeFull().toVec();
            prev_value_hash = lastBlockHash;
        }

        auto next_value = next.serializeFull().toVec();
        auto next_dup = duplicate_value(&next_value);
        auto nextval = this.wrapValue(next_dup);

        if (this.scp.nominate(slot_idx, nextval, prev_value))
        {
            log.info("{}(): Tx set triggered new nomination", __FUNCTION__);
        }
        else
        {
            log.info("{}(): Tx set didn't trigger new nomination", __FUNCTION__);
            const Height expected = this.ledger.expectedHeight(this.clock.utcTime());
            if (expected > this.ledger.height)
            {
                log.info("{}(): Behind expected height so resend latest envleopes"
                    , __FUNCTION__);
                foreach (const ref env; this.scp.getLatestMessagesSend(slot_idx))
                    this.emitEnvelope(env);
            }
        }
    }

    /***************************************************************************

        Restore SCP's internal state based on the stored latest envelopes

    ***************************************************************************/

    protected void restoreSCPState () @trusted
    {
        foreach (bool proc, const ref SCPEnvelope envelope; this.store)
        {
            if (!proc)
            {
                this.queued_envelopes.insertBack(envelope.serializeFull.deserializeFull!SCPEnvelope());
                this.armTaskTimer(TimersIdx.Envelope, EnvTaskDelay);
                continue;
            }
            auto shared_env = this.wrapEnvelope(envelope);
            this.scp.setStateFromEnvelope(envelope.statement.slotIndex,
                shared_env);
            if (!this.scp.isSlotFullyValidated(envelope.statement.slotIndex))
                assert(0);
        }
    }

    /***************************************************************************

        Called when a new SCP Envelope is received from the network.
        It queues it up for processing by the envelope process fiber.

        Params:
            envelope = the SCP envelope

    ***************************************************************************/

    public void receiveEnvelope (in SCPEnvelope envelope) @trusted
    {
        auto env_hash = envelope.hashFull();
        log.dbg("{}: Received envelope with hash {}", __FUNCTION__, env_hash);
        if (env_hash !in this.seen_envs)
        {
            auto copied = envelope.clone();
            if (copied.statement.pledges.type_ == SCPStatementType.SCP_ST_NOMINATE)
                this.queued_envelopes.insertBack(copied);
            else
                this.queued_envelopes.insertFront(copied);
            if (this.pending_block == Block.init)
                this.armTaskTimer(TimersIdx.Envelope, EnvTaskDelay);
            else
                log.dbg("{}: We have a pending block #{} to externalize so do not process any more envelopes yet",
                    __FUNCTION__, this.pending_block.header.height);
            this.seen_envs.put(env_hash);
        }
    }

    /***************************************************************************

        Called to process a queued incoming SCP Envelope.

        Params:
            envelope = the SCP envelope

    ***************************************************************************/

    private void handleSCPEnvelope (in SCPEnvelope envelope) @trusted
    {
        const Block last_block = this.ledger.lastBlock();
        // Don't use `height - tolerance` as it could underflow
        if (envelope.statement.slotIndex <= last_block.header.height)
        {
            log.trace("{}: Ignoring envelope with slot id {} as ledger is at height {}",
                __FUNCTION__, envelope.statement.slotIndex, last_block.header.height.value);
            return;  // slot was already externalized
        }

        const env_height = Height(envelope.statement.slotIndex);
        // If the envelope is too early then trigger catchup task
        if (env_height > last_block.header.height + 1)
        {
            log.dbg("{}: Envelope is for height {} but ledger is only at height {}.",
                __FUNCTION__, env_height, last_block.header.height);
            this.armTaskTimer(TimersIdx.Catchup, CatchupTaskDelay);
        }

        // If the node is not enrolled at the height then return early
        if (!this.enroll_man.isEnrolled(env_height, &this.ledger.peekUTXO))
        {
            log.dbg("{}: Skip this envelope as this node is not enrolled at height {}", __FUNCTION__, env_height);
            return;
        }

        Hash utxo = this.getNodeUTXO(envelope.statement.slotIndex, envelope.statement.nodeID);
        if (utxo == Hash.init)
        {
            log.trace("{}: No UTXO for the nodeID {} at the slot {}",
                __FUNCTION__, envelope.statement.nodeID, envelope.statement.slotIndex);
            return;
        }

        if (utxo == this.enroll_man.getEnrollmentKey)
        {
            log.dbg("{}: Ignore this envelope as it is from this node", __FUNCTION__);
            return;
        }

        UTXO utxo_value;
        if (!this.ledger.peekUTXO(utxo, utxo_value))
        {
            log.trace("{}: Couldn't find UTXO {} at height {} to validate envelope's signature",
                __FUNCTION__, utxo, last_block.header.height);
            return;
        }
        const PublicKey public_key = utxo_value.output.address;
        const Scalar challenge = SCPStatementHash(&envelope.statement).hashFull();
        if (!public_key.isValid())
        {
            log.trace("{}: Invalid point from public_key {}", __FUNCTION__, public_key);
            return;
        }
        if (!verify(public_key, envelope.signature.toSignature(), challenge))
        {
            // If it fails signature verification, it might not originate from said key
            log.trace("{}: Envelope failed signature verification for {}", __FUNCTION__, public_key);
            return;
        }

        log.trace("{}: Received signed envelope: {}", __FUNCTION__, scpPrettify(&envelope, &this.getQSet));
        if (envelope.statement.pledges.type_ == SCPStatementType.SCP_ST_NOMINATE)
        {
            // show some tolerance to early nominations
            ulong tolerance = this.params.BlockInterval.total!"seconds" / 20; // 5%

            // too early to nominate a new block
            if (this.clock.networkTime() + tolerance < this.getExpectedBlockTime())
            {
                log.trace("{}: Ignoring early nomination for height {}", __FUNCTION__, envelope.statement.slotIndex);
                return;
            }
        }

        Set!Hash missing_txs;
        auto values = Slot.getStatementValues(envelope.statement);
        foreach (value; values)
        {
            auto idx_value_hash = hashMulti(envelope.statement.slotIndex,
                value);
            if (idx_value_hash in this.fully_validated_value)
                continue;

            ConsensusData data;
            try
                data = deserializeFull!ConsensusData(value[]);
            catch (Exception ex)
                return;

            auto missing = this.ledger.getUnknownTXsFromSet(Set!Hash.from(data.tx_set));
            missing.each!(hash => missing_txs.put(hash));
        }

        auto shared_env = this.wrapEnvelope(envelope);
        if (missing_txs.length > 0 && this.handleMissingTxEnvelope(shared_env, missing_txs, utxo))
            return;

        if (this.scp.receiveEnvelope(shared_env) != SCP.EnvelopeState.VALID)
            log.trace("{}: SCP indicated invalid envelope: {}", __FUNCTION__, scpPrettify(&envelope, &this.getQSet));
        else
            this.emitEnvelope(shared_env.getEnvelope());
    }

    /***************************************************************************

        Called to process a SCP envelope that references unknown TX hashes

        Params:
            shared_env = the SCP envelope
            missing_txs = Set of unknown TX hashes
            peer_utxo = stake of the peer that the envelope belongs to

        Returns:
            success/failure

    ***************************************************************************/

    private bool handleMissingTxEnvelope (SCPEnvelopeWrapperPtr shared_env, Set!Hash missing_txs, Hash peer_utxo) @trusted
    {
        auto peer = this.network.getPeerByStake(peer_utxo);
        if (!peer)
            return false;

        log.trace("Missing {} TXs while handling envelope from {} for slot {}", missing_txs.length,
            shared_env.getEnvelope().statement.nodeID, shared_env.getEnvelope().statement.slotIndex);

        auto heap_env = new SCPEnvelopeWrapperPtr(shared_env);
        this.taskman.runTask({
            try
            {
                Transaction[] txs;
                do
                {
                    txs = peer.getTransactions(missing_txs);
                    txs.each!((tx) {
                        this.ledger.acceptTransaction(tx);
                        missing_txs.remove(tx.hashFull());
                    });
                } while(missing_txs.length > 0 && txs.length > 0);
                if (this.scp.receiveEnvelope(*heap_env) != SCP.EnvelopeState.VALID)
                    log.trace("SCP indicated invalid envelope: {}", scpPrettify(&(*heap_env).getEnvelope(), &this.getQSet));
                else
                    this.emitEnvelope((*heap_env).getEnvelope());
            }
            catch (Exception) {}
        });
        return true;
    }

    /***************************************************************************

        Called when a new Block Signature is received from the network.

        Params:
            block_sig = the structure with details of the block signature

        Returns:
            Updated block header

    ***************************************************************************/

    public const(BlockHeader) receiveBlockSignature (in ValidatorBlockSig block_sig) @safe
    {
        const cur_height = this.ledger.height();
        log.trace("{}: Received Signature {} for Validator with staked utxo {} for block {} at ledger height {}",
            __FUNCTION__, block_sig.signature, block_sig.utxo, block_sig.height, cur_height);

        if (block_sig.height == 0 || block_sig.height > cur_height + EarlySignatureThreshold)
            return BlockHeader.init; // We want the caller to ignore this signature

        const pendingBlockSig = (block_sig.height == this.pending_block.header.height);

        if (!pendingBlockSig && block_sig.height > cur_height) // Too early for this signature
        {
            early_sigs.put(block_sig);
            return BlockHeader.init; // We want the caller to ignore this signature
        }

        Block block = pendingBlockSig ? this.pending_block : this.ledger.getBlocksFrom(Height(block_sig.height)).front;

        if (this.collectBlockSignature(block_sig, block.hashFull()))
        {
            log.dbg("{}: Signature is for {} block #{}",
                __FUNCTION__, pendingBlockSig ? "pending" : "ledger", block.header.height);
            if (pendingBlockSig)
                this.updateMultiSignature(this.pending_block.header);
            else
            {
                this.updateMultiSignature(block.header);
                this.ledger.updateBlockMultiSig(block.header);
                return block.header;
            }
        }
        return BlockHeader.init; // We want the caller to ignore this signature
    }

    /***************************************************************************

        Store the latest SCP state and the queued SCP envelopes,
        for restoring later.

    ***************************************************************************/

    public void storeLatestState () @safe
    {
        vector!SCPEnvelope envelopes;

        () @trusted
        {
            if (this.scp is null || this.scp.empty())
                return;

            envelopes = this.scp.getExternalizingState(this.scp.getHighSlotIndex());
        }();

        this.store.lock();
        scope (failure) this.store.unlock(false);
        scope (success) this.store.unlock(true);

        // Clean the previous envelopes from the DB
        this.store.removeAll();

        // Store the latest envelopes
        foreach (const ref env; envelopes)
            this.store.add(env, true);

        // Store the queued envelopes
        foreach (const ref env; this.queued_envelopes[])
            this.store.add(env, false);
    }

    /***************************************************************************

        Sign this block using our private key / pre-image.

        This will only returns the new signature, the block won't be modified.

        Params:
            block = the block to sign

    ***************************************************************************/

    protected Signature signBlock (in Block block) @safe nothrow
    {
        return block.header.sign(this.kp.secret,
            this.enroll_man.getOurPreimage(block.header.height));
    }

    /// If we have majority signatures then externalize to the ledger otherwise check again after receiving signatures
    private void checkExternalize () @safe nothrow
    {
        const block = this.pending_block;
        if (block.header.height == 0)
            return; // pending block has been reset already

        try
        {
            if (block.header.height == this.ledger.height + 1)
            {
                if (block.header.validators.percentage > 50)
                {
                    log.info("{}: Ready to externalize block #{} to the ledger", __FUNCTION__, block.header.height);
                    this.verifyBlock(block);
                }
                else
                {
                    log.dbg("{}: Will not yet externalize block #{} as we only have {} / {} signatures",
                        __FUNCTION__, block.header.height, block.header.validators.setCount,
                        block.header.validators.count);
                    this.armTaskTimer(TimersIdx.Catchup, CatchupTaskDelay);
                    return;
                }
            }
            this.pending_block = Block.init;
            // Reset the nomination timer
            this.round_timeout = this.nomination_interval;
            this.armTaskTimer(TimersIdx.Nomination, this.round_timeout);
            // Enable envelope processing again
            this.armTaskTimer(TimersIdx.Envelope, EnvTaskDelay);
        }
        catch (Exception exc)
        {
            log.warn("{}: Exception thrown: {}", __FUNCTION__, exc);
        }
    }

    /// function for verifying the block which can be overriden in byzantine unit tests
    protected void verifyBlock (in Block signed_block) @safe
    {
        // We call `{Validator,FullNode}.acceptBlock` here (via delegate),
        // instead of calling `Ledger.acceptBlock` directly.
        // The reason for that is that those classes have some special logic
        // which applies when a block is externalize (for example if the quorum
        // config changes or the list of validators change,
        // new network connections might need to be established).
        if (auto fail_msg = this.acceptBlock(signed_block))
        {
            log.error("Block was not accepted by node {}: {}", this.kp.address, fail_msg);
            assert(0, "Block was not accepted: " ~ fail_msg);
        }
    }

    /// function for gossip of block sig which can be overriden in byzantine unit tests
    protected void gossipBlockSignature (in ValidatorBlockSig block_sig)
        @safe nothrow
    {
        // Send to other nodes in the network
        this.network.gossipBlockSignature(block_sig);
    }

    /***************************************************************************

        Add missing block signatures to provided block header if known

        Params:
            header = header to be updated

    ***************************************************************************/

    public void updateMultiSignature (ref BlockHeader header) @safe
    {
        const validators = this.ledger.getValidators(header.height);

        if (header.height !in this.slot_sigs)
        {
            log.trace("No signatures in memory at height {}", header.height);
            return;
        }
        log.dbg("{}: Before updating block signature for block {}, mask: {}",
            __FUNCTION__, header.height, header.validators);
        const Signature[Hash] block_sigs = this.slot_sigs[header.height];

        auto validator_mask = BitMask(validators.length);
        auto sigs_to_add = [ header.signature ];
        foreach (idx, const ref val; validators)
        {
            if (header.validators[idx]) // in the header already
                validator_mask[idx] = true;
            else if (val.utxo() in block_sigs) // We have the missing signature
            {
                validator_mask[idx] = true;
                const sig = block_sigs[val.utxo()];
                sigs_to_add ~= sig;
                log.trace("updateMultiSignature: Adding missing signature for {} at height {}",
                    val.address, header.height);
                this.gossipBlockSignature(ValidatorBlockSig(header.height, val.utxo(), sig.R));
            }
        }
        header.updateSignature(multiSigCombine(sigs_to_add), validator_mask);
        log.trace("{}: Updated block signature for block {}, mask: {}",
            __FUNCTION__, header.height, header.validators);
        this.checkExternalize();
        return;
    }

    /***************************************************************************

        Collect the block signature for a gossiped signature only if the
        signature is valid for validator and block hash

        Params:
            block_sig = the structure with the block signature details
            block_hash = the hash of the proposed block

        Returns:
            true if verified

    ***************************************************************************/

    private bool collectBlockSignature (in ValidatorBlockSig block_sig,
        in Hash block_hash) @safe nothrow
    {
        auto sigs = block_sig.height in this.slot_sigs;
        if (sigs && block_sig.utxo in (*sigs))
        {
            log.trace("Signature already collected for this node at height {}", block_sig.height);
            return false;
        }

        // Using `assumeSorted` and `getValidator` being a random access range
        // means that the search should be `O(ln(n))`.
        ValidatorInfo validator;
        try
        {
            auto validators = this.ledger.getValidators(block_sig.height);
            auto result = validators.assumeSorted.find!(v => v.utxo() == block_sig.utxo);
            if (result.empty())
            {
                log.warn("Couldn't find validator {} at height {}", block_sig.utxo, block_sig.height);
                return false;
            }
            validator = result.front();
        }
        catch (Exception exc)
        {
            log.error("Exception happened with calling `getValidators` in `collectBlockSignature: {}", exc);
            return false;
        }

        if (validator.preimage.height < block_sig.height)
        {
            log.warn("collectBlockSignature: Validator {} has preimage at height {} but sig: {}",
                     validator.utxo(), validator.preimage.height, block_sig);
            return false;
        }

        if (!BlockHeader.verify(
                validator.address, validator.preimage[block_sig.height],
                block_sig.signature, block_hash))
        {
            log.warn("collectBlockSignature: INVALID Block signature received for slot {} from node {}",
                block_sig.height, block_sig.utxo);
            return false;
        }
        log.trace("collectBlockSignature: VALID block signature at height {} for node {}",
            block_sig.height, block_sig.utxo);
        // collect the signature
        const Scalar s = validator.preimage[block_sig.height];
        this.slot_sigs[block_sig.height][block_sig.utxo] = Signature(block_sig.signature, s);
        return true;
    }

    extern (C++):

    /***************************************************************************

        Signs the SCPEnvelope with the node's private key.

        Params:
            envelope = the SCPEnvelope to sign

    ***************************************************************************/

    public override void signEnvelope (ref SCPEnvelope envelope)
    {
        const Scalar challenge = SCPStatementHash(&envelope.statement).hashFull();
        envelope.signature = this.kp.sign(challenge).toBlob();
        log.trace("SIGN Envelope signature {}: {}", envelope.signature,
                  scpPrettify(&envelope, &this.getQSet));
    }

    /***************************************************************************

        Validates the provided transaction set for the provided slot index,
        and returns a status code of the validation.

        Params:
            slot_idx = the slot index we're currently reaching consensus for
            value = the transaction set to validate
            nomination = whether we're validating values for the nomination
                         protocol, or ballot protocol

    ***************************************************************************/

    public override ValidationLevel validateValue (uint64_t slot_idx,
        ref const(Value) value, bool nomination) nothrow
    {
        auto idx_value_hash = hashMulti(slot_idx, value);
        if (idx_value_hash in this.fully_validated_value)
            return ValidationLevel.kFullyValidatedValue;

        ConsensusData data;
        try
        {
            data = deserializeFull!ConsensusData(value[]);
        }
        catch (Exception ex)
        {
            log.error("validateValue(): Received un-deserializable tx set. " ~
                "Error: {}", ex.msg);
            return ValidationLevel.kInvalidValue;
        }

        if (auto fail_reason = this.ledger.validateConsensusData(data, this.initial_missing_validators))
        {
            if (fail_reason == this.ledger.InvalidConsensusDataReason.NotInPool)
            {
                log.trace("validateValue(): This node can not yet fully validate this value: {}. Data: {}", fail_reason, data.prettify);
                this.armTaskTimer(TimersIdx.Catchup, CatchupTaskDelay);
                return ValidationLevel.kMaybeValidValue;
            }
            if (fail_reason == this.ledger.InvalidConsensusDataReason.MisMatchingCoinbase)
            {
                log.error("validateValue(): Validation failed: {}. Will check for missing signatures", fail_reason);
                this.armTaskTimer(TimersIdx.Catchup, CatchupTaskDelay);
            }
            else
            {
                log.error("validateValue(): Validation failed: {}. Data: {}", fail_reason, data.prettify);
                return ValidationLevel.kInvalidValue;
            }
        }
        this.fully_validated_value.put(idx_value_hash);
        return ValidationLevel.kFullyValidatedValue;
    }

    /***************************************************************************

        Called when consenus has been reached for the provided slot index and
        the transaction set. If successful this node's block signature is
        gossiped to the network in case missing from other nodes.

        Params:
            slot_idx = the slot index
            value = the transaction set

    ***************************************************************************/

    public override void valueExternalized (uint64_t slot_idx,
        ref const(Value) value) nothrow
    {
        Height height = Height(slot_idx);
        const Height last_height = this.ledger.height();
        log.trace("valueExternalized: attempt to add slot id {} to ledger at height {}", height, last_height);
        if (height != last_height + 1)
        {
            log.trace("valueExternalized: Will not externalize envelope with slot id {} as ledger is at height {}",
                height, last_height);
            return;  // slot was already externalized or envelope is too new
        }
        ConsensusData data = void;
        try
            data = deserializeFull!ConsensusData(value[]);
        catch (Exception exc)
        {
            log.fatal("Deserialization of C++ Value failed: {}", exc);
            assert(0, exc.message);
        }

        log.info("Externalized consensus data set at {}: {}", height, prettify(data));
        try
        {
            Transaction[] externalized_tx_set;
            if (auto fail_reason = this.ledger.getValidTXSet(data, externalized_tx_set))
            {
                log.info("Missing TXs while externalizing at Height {}: {}",
                    height, prettify(data));
                return;
            }

            this.pending_block = this.ledger.buildBlock(
                externalized_tx_set, data.enrolls, data.missing_validators);

            // Now we add our signature and gossip to other nodes
            log.trace("ADD BLOCK SIG at height {} for this node {}", height, this.kp.address);
            const self = this.enroll_man.getEnrollmentKey();
            this.slot_sigs[height][self] = this.signBlock(this.pending_block);
            this.updateMultiSignature(this.pending_block.header);
            // Now add any early signatures we received
            early_sigs[].each!(sig => this.receiveBlockSignature(sig));
            early_sigs.clear();
        }
        catch (Exception exc)
        {
            log.fatal("Externalization of SCP data failed: {}", exc);
            assert(0, exc.message);
        }
        this.initial_missing_validators = [];
        log.trace("valueExternalized: added slot id {} to ledger at height {}", height, last_height);
        () @trusted { this.fully_validated_value.clear(); }();
        () @trusted { this.seen_envs.clear(); }();
    }

    /***************************************************************************

        Params:
            node_id = the node's id of the quorum set

        Returns:
            the SCPQuorumSetPtr for the provided node ID, or null if not found

    ***************************************************************************/

    public override SCPQuorumSetPtr getQSet (ref const(NodeID) node_id)
    {
        if (auto quorum = node_id in this.known_quorums)
            return *quorum;

        log.error("getQSet SCPQuorumSetPtr.init, id: {}", node_id);
        return SCPQuorumSetPtr.init;
    }

    /***************************************************************************

        Floods the given SCPEnvelope to the network of connected peers.

        Params:
            envelope = the SCPEnvelope to flood to the network.

    ***************************************************************************/

    public override void emitEnvelope (ref const(SCPEnvelope) envelope) nothrow
    {
        SCPEnvelope copy;
        try
            copy = envelope.serializeFull.deserializeFull!SCPEnvelope();
        catch (Exception e)
            assert(0);
        log.trace("{}: {} to peers {}", __FUNCTION__, scpPrettify(&copy, &this.getQSet),
            this.network.validators().map!(p => p.identity().key));
        this.network.validators().each!(v => v.sendEnvelope(copy));
    }

    /***************************************************************************

        Get the UTXO hash for the index of the validator at a height

        Params:
            slot_idx = the height for which we search the index of the validator
            index = the index of the validator

        Returns:
            the hash of the frozen UTXO

    ***************************************************************************/

    public Hash getNodeUTXO (uint64_t slot_index, uint64_t index)
        @safe nothrow
    {
        Hash utxo;
        ValidatorInfo[] validators;
        try
        {
            validators = this.ledger.getValidators(Height(slot_index));
            if (validators.length > index)
                utxo = validators[index].utxo;
        }
        catch (Exception exc)
        {
            log.error("Exception happened with calling `getValidators` in `getNodeID: {}", exc);
        }
        return utxo;
    }

    /// Used for holding consensus candidate values. It contains precomputed
    /// fields to speed up sorting.
    static struct CandidateHolder
    {
        /// Consensus data
        public ConsensusData consensus_data;
        /// Hash of the consensus data
        public Hash hash;
        /// The total amount of fees of the transactions in the consensus data
        public Amount total_rate;

        /// Comparison function, which sorts by
        /// 1. length of missing validators (smallest first), or if it ties
        /// 2. length of enrollments (smallest last), or if it ties
        /// 3. total adjusted fee (smallest last), or if it ties
        /// 4. hash of the candidate (smallest last)
        public int opCmp (in CandidateHolder other) const @safe scope pure nothrow @nogc
        {
            if (this.consensus_data.missing_validators.length <
                other.consensus_data.missing_validators.length)
                    return -1;
            else if (this.consensus_data.missing_validators.length >
                     other.consensus_data.missing_validators.length)
                return 1;

            if (this.consensus_data.enrolls.length > other.consensus_data.enrolls.length)
                return -1;
            else if (this.consensus_data.enrolls.length < other.consensus_data.enrolls.length)
                return 1;

            if (this.total_rate > other.total_rate)
                return -1;
            else if (this.total_rate < other.total_rate)
                return 1;

            if (this.consensus_data.tx_set.length > other.consensus_data.tx_set.length)
                return -1;
            else if (this.consensus_data.tx_set.length < other.consensus_data.tx_set.length)
                return 1;

            if (this.hash > other.hash)
                return -1;
            else if (this.hash < other.hash)
                return 1;

            return 0;
        }
    }

    @safe pure nothrow unittest
    {
        CandidateHolder candidate_holder;
        CandidateHolder[] candidate_holders;

        // The candidate with the least missing validators is preferred
        candidate_holder.consensus_data.missing_validators = [1, 2, 3];
        candidate_holders ~= candidate_holder;

        candidate_holder.consensus_data.missing_validators = [1, 2];
        candidate_holders ~= candidate_holder;

        candidate_holder.consensus_data.missing_validators = [1, 2, 3, 4, 5];
        candidate_holders ~= candidate_holder;

        assert(candidate_holders.sort().front.consensus_data.missing_validators == [1, 2]);

        // If multiple candidates have the same number of missing validators, then
        // the candidate with the higher adjusted fee is preferred.
        candidate_holders[1].total_rate = Amount(10);

        candidate_holder.consensus_data.missing_validators = [3, 4];
        candidate_holder.total_rate = Amount(12);
        candidate_holders ~= candidate_holder;

        assert(candidate_holders.sort().front.consensus_data.missing_validators == [3, 4]);

        // If multiple candidates have the same number of missing validators, and
        // adjusted total fee, then the candidate with lower hash is preferred.
        candidate_holder.consensus_data.missing_validators = [2, 4];
        candidate_holder.hash = "not zero".hashFull();
        candidate_holders ~= candidate_holder;

        assert(candidate_holders.sort().front.consensus_data.missing_validators == [2, 4]);
    }

    /***************************************************************************

        Combine a set of transaction sets into a single transaction set.
        This may be done in arbitrary ways, as long as it's consistent
        (for a given input, the combined output is predictable). Please see
        CandidateHolder.opCmp for the actual implementation of which candidate
        is chosen.

        Params:
            slot_idx = the slot index we're currently reaching consensus for
            candidates = a set of a set of transactions

    ***************************************************************************/

    public override ValueWrapperPtr combineCandidates (uint64_t slot_idx,
        ref const(ValueWrapperPtrSet) candidates)
    {
        log.dbg("combineCandidates for slot i: {}", cast(ulong) slot_idx);
        try
        {
            CandidateHolder[] candidate_holders;
            foreach (ref const cand; candidates)
            {
                auto candidate = cand.getValue();
                auto data = deserializeFull!ConsensusData(candidate[]);
                log.trace("Consensus data: {}", data.prettify);

                Amount total_rate;
                foreach (const ref tx_hash; data.tx_set)
                {
                    Amount rate;
                    auto errormsg = this.ledger.getTxFeeRate(tx_hash, rate);
                    if (errormsg == NodeLedger.InvalidConsensusDataReason.NotInPool)
                        continue; // most likely a CoinBase Transaction
                    else if (errormsg)
                        assert(0);
                    total_rate += rate;
                }

                CandidateHolder candidate_holder =
                {
                    consensus_data: data,
                    hash: data.hashFull(),
                    total_rate = total_rate,
                };
                candidate_holders ~= candidate_holder;
            }

            auto chosen_consensus_data = candidate_holders.sort().front;
            log.trace("Chosen consensus data for slot i: {} : {}", cast(ulong) slot_idx, chosen_consensus_data.prettify);

            const Value val = chosen_consensus_data.serializeFull().toVec();
            auto dupe_val = duplicate_value(&val);
            return this.wrapValue(dupe_val);
        }
        catch (Exception ex)
        {
            assert(0, format!"combineCandidates: slot %u. Exception: %s"(
                slot_idx, ex.to!string));
        }
        // should not reach here
        assert(0, format!"combineCandidates: no valid candidate for slot %u."(
            slot_idx));
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
        const type = cast(TimerType) timer_type;
        assert(type >= TimerType.min && type <= TimerType.max);
        if (auto timer = this.active_timers[type])
        {
            timer.stop();
            this.active_timers[type] = null;
        }

        if (callback is null || timeout == 0)
            return;
        this.active_timers[type] = this.taskman.setTimer(
            timeout.msecs, { callCPPDelegate(callback); });
    }

    // `getHashOf` computes the hash for the given vector of byte vector
    override StellarHash getHashOf (ref vector!Value vals) const nothrow
    {
        return StellarHash(hashMulti(vals)[][0 .. Hash.sizeof]);
    }

    // SCP hook that is called for new ballots
    override void startedBallotProtocol(uint64_t slot_idx,
        ref const(SCPBallot) ballot) nothrow
    {
        if (Height(slot_idx) > this.heighest_ballot_height)
        {
            this.heighest_ballot_height = Height(slot_idx);
            log.info("Balloting started for slot idx {}", slot_idx);
        }
    }

    // Returns internal SCP state for latest slot
    public string[] getSCPState () @trusted
    {
        import agora.utils.SCPPrettyPrinter;
        import std.conv;
        string[] envs;
        auto high_slot = this.scp.getHighSlotIndex();
        foreach (const ref SCPEnvelope env; this.scp.getLatestMessagesSend(high_slot))
            envs ~= to!string(scpPrettify(&env, &this.getQSet));
        foreach (const ref SCPEnvelope env; this.scp.getExternalizingState(high_slot))
            envs ~= to!string(scpPrettify(&env, &this.getQSet));
        return envs;
    }

    /***************************************************************************

        `computeTimeout` computes a timeout given a round number
        it should be sufficiently large such that nodes in a
        quorum can exchange 4 messages

        Params:
            roundNumber = round number

    ***************************************************************************/

    protected override milliseconds computeTimeout(uint32_t roundNumber)
    {
        auto base = min(this.nomination_interval, 1.seconds);
        // double the timeout every 16 validators
        auto val_multipler = 1 + this.ledger.validatorCount(this.ledger.height()) / 16;
        this.round_timeout = base * val_multipler * roundNumber;
        const timeout = milliseconds(round_timeout.total!"msecs".to!long);
        log.dbg("{}: roundNumber {} timeout = {} msecs", __FUNCTION__, roundNumber, timeout);
        return timeout;
    }
}

/// Adds hashing support to SCPStatement
private struct SCPStatementHash
{
    // sanity check in case a new field gets added.
    // todo: use .tupleof tricks for a more reliable field layout change check
    static assert(SCPNomination.sizeof == 48);

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

    public void computeHash (scope HashDg dg) const scope
        @safe pure nothrow @nogc
    {
        hashPart(this.st.nodeID, dg);
        hashPart(this.st.slotIndex, dg);
        hashPart(this.st.pledges.type_, dg);
        this.st.pledges.apply!computeHash(dg);
    }

    /***************************************************************************

        Compute the hash for a prepare pledge statement.

        Params:
            prep = the prepare pledge statement
            dg = Hashing function accumulator

    ***************************************************************************/

    public static void computeHash (
        const ref SCPStatement._pledges_t._prepare_t prep,
        scope HashDg dg) @safe pure nothrow @nogc
    {
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
        scope HashDg dg) @safe pure nothrow @nogc
    {
        hashPart(conf.ballot, dg);
        hashPart(conf.nPrepared, dg);
        hashPart(conf.nCommit, dg);
        hashPart(conf.nH, dg);
    }

    /***************************************************************************

        Compute the hash for an externalize pledge statement.

        Params:
            ext = the externalize pledge statement
            dg = Hashing function accumulator

    ***************************************************************************/

    public static void computeHash (
        const ref SCPStatement._pledges_t._externalize_t ext, scope HashDg dg)
        @safe pure nothrow @nogc
    {
        hashPart(ext.commit, dg);
        hashPart(ext.nH, dg);
    }

    /***************************************************************************

        Compute the hash for a nomination pledge statement.

        Params:
            nom = the nomination pledge statement
            dg = Hashing function accumulator

    ***************************************************************************/

    public static void computeHash (const ref SCPNomination nom, scope HashDg dg)
        @safe pure nothrow @nogc
    {
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

    public void computeHash (scope HashDg dg) scope const @trusted pure nothrow @nogc
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

    Hash[] st_hashes;
    st_hashes ~= getStHash().hashFull();

    prep.counter++;
    st_hashes ~= getStHash().hashFull();

    prep_prime.counter++;
    st_hashes ~= getStHash().hashFull();

    () @trusted { st.pledges.prepare_.prepared = null; }();
    st_hashes ~= getStHash().hashFull();

    () @trusted { st.pledges.prepare_.preparedPrime = null; }();
    st_hashes ~= getStHash().hashFull();

    () @trusted { st.pledges.nominate_ = SCPNomination.init; }();
    st.pledges.type_ = SCPStatementType.SCP_ST_NOMINATE;
    st_hashes ~= getStHash().hashFull();

    () @trusted { st.pledges.confirm_ = SCPStatement._pledges_t._confirm_t.init; }();
    st.pledges.type_ = SCPStatementType.SCP_ST_CONFIRM;
    st_hashes ~= getStHash().hashFull();

    () @trusted { st.pledges.externalize_ = SCPStatement._pledges_t._externalize_t.init; }();
    st.pledges.type_ = SCPStatementType.SCP_ST_EXTERNALIZE;
    st_hashes ~= getStHash().hashFull();

    SCPEnvelope env;
    auto getEnvHash () @trusted { return SCPEnvelopeHash(&env); }

    Hash[] env_hashes;

    // empty envelope
    import std.conv;
    env_hashes ~= getEnvHash().hashFull();

    // with a statement
    env.statement = st;
    env_hashes ~= getEnvHash().hashFull();

    // import agora.utils.Test;
    // import std.stdio;
    // writeln(WK.Keys.NODE5.sign(getStHash));
    env.signature = Signature.fromString(
        "0x8e506b0d32457a3e6e2c7ba14dec178a53c567430e71dd036301c8246d8a782b" ~
        "3c4fdf745375bd2fed645433e2a9364b95d6e3931c29ea7fb445bc6ee80867a6")
        .toBlob();

    // with a signature
    env_hashes ~= getEnvHash().hashFull();

    assert(Set!Hash.from(st_hashes).length == st_hashes.length);
    assert(Set!Hash.from(env_hashes).length == env_hashes.length);
}

// Size assumptions made by this module
unittest
{
    static assert(StellarHash.sizeof == Hash.sizeof);
}
