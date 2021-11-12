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
import agora.node.Config;
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
import std.range : assumeSorted;
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
    private Height last_confirmed_height;

    /// Periodic nomination timer. It runs every second and checks the clock
    /// time to see if it's time to start nominating. We do not use the
    /// `BlockInterval` interval directly because this makes the timer
    /// succeptible to clock drift. Instead, the clock is checked every second.
    /// Note that Clock network synchronization is not yet implemented.
    private ITimer nomination_timer;

    /// SCPEnvelopeStore instance
    protected SCPEnvelopeStore store;

    // Height => Point (UTXO hash) => Signature
    private Signature[Hash][Height] slot_sigs;

    /// Enrollment manager
    public EnrollmentManager enroll_man;

    /// Used as "prev_value" when nominating
    private const Value empty_value;

    /// User configured nomination frequency
    private const Duration nomination_interval;

    /// Delegate called when node's own nomination is invalid
    public extern (D) void delegate (in ConsensusData data, in string msg)
        @safe onInvalidNomination;

    /// Delegate called when a block is to be externalized
    public extern (D) string delegate (in Block) @safe acceptBlock;

    /// Nomination start time
    protected TimePoint nomination_start_time;

    /// The missing validators at the start of the nomination round
    protected uint[] initial_missing_validators;

    /// List of incoming SCPEnvelopes that need to be processed
    private DList!SCPEnvelope queued_envelopes;

    /// Timer used for processing queued incoming SCP Envelope messages
    private ITimer envelope_timer;

    /// Envelope process task delay
    private enum EnvTaskDelay = 10.msecs;

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
        EnrollmentManager enroll_man, ITaskManager taskman, ManagedDatabase cacheDB,
        Duration nomination_interval,
        string delegate (in Block) @safe externalize)
    {
        assert(externalize !is null);

        this.log = Logger(__MODULE__);
        this.params = params;
        this.clock = clock;
        this.network = network;
        this.empty_value = ConsensusData.init.serializeFull().toVec();
        this.kp = key_pair;
        this.taskman = taskman;
        this.ledger = ledger;
        this.enroll_man = enroll_man;
        this.store = new SCPEnvelopeStore(cacheDB);
        // Create and stop timer immediately
        this.envelope_timer = this.taskman.setTimer(EnvTaskDelay,
            &this.envelopeProcessTask, Periodic.No);
        this.envelope_timer.stop();
        // Find the node id of this validator and create an SCPObject
        Hash[] utxo_keys;
        this.enroll_man.getEnrolledUTXOs(Height(1), utxo_keys);
        const this_utxo = this.enroll_man.getEnrollmentKey();
        NodeID node_id = utxo_keys.countUntil(this_utxo);
        this.updateSCPObject(node_id);
        this.restoreSCPState();
        this.nomination_interval = nomination_interval;
        this.acceptBlock = externalize;
    }

    /// Shut down the envelope processing timer
    public void shutdown () @safe
    {
        this.envelope_timer.stop();
    }

    /// Processes incoming queued envelopes
    private void envelopeProcessTask ()
    {
        while (!this.queued_envelopes.empty)
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
        assert(!this.is_nominating);
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

        Begins the nomination timer

        This should be called once when a Node's enrollment has been confirmed
        on the blockchain.

    ***************************************************************************/

    public void startNominatingTimer () @trusted nothrow
    {
        if (this.nomination_timer !is null)  // already running
            return;

        // For unittests we don't want to wait 1 second between checks
        log.info("Starting nominating timer..");
        this.nomination_timer = this.taskman.setTimer(this.nomination_interval,
            &this.checkNominate, Periodic.Yes);
    }

    /***************************************************************************

        Stops nominating.

        This should be called once when a Node's enrollment expires.

    ***************************************************************************/

    public void stopNominatingTimer () @safe nothrow
    {
        if (this.nomination_timer !is null)
        {
            this.nomination_timer.stop();
            this.nomination_timer = null;
        }
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
        this.ledger.prepareNominatingSet(data, MaxTransactionsPerBlock, this.nomination_start_time);

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

    protected ulong getExpectedBlockTime () @safe @nogc nothrow pure
    {
        return ledger.getLastBlock().header.time_offset +
            this.params.GenesisTimestamp +
            this.params.BlockInterval.total!"seconds";
    }

    /***************************************************************************

        The main nominating function.

        This function is called periodically by the nominating timer.

        The function will return early if either one of these are true:
        - We're already in the asynchronous stage of nominating or balloting
        - The current time is < getExpectedBlockTime(slot_idx)
        - There are no transactions in the pool to nominate yet

    ***************************************************************************/

    private void checkNominate () @safe
    {
        const slot_idx = this.ledger.getBlockHeight() + 1;
        // are we done nominating this round
        if (this.last_confirmed_height >= slot_idx)
        {
            this.log.trace(
                "checkNominate(): Not nominating because we already confirmed ({} >= {})",
                this.last_confirmed_height, slot_idx);
            return;
        }

        const cur_time = this.clock.networkTime();
        const genesis_timestamp = this.params.GenesisTimestamp;

        if (cur_time < genesis_timestamp)
        {
            this.log.error(
                "Clock is out of sync: {} (Current) < {} (Genesis)",
                cur_time, genesis_timestamp);
            return;
        }

        const next_nomination = this.getExpectedBlockTime();
        if (cur_time < next_nomination)
        {
            this.log.trace(
                "checkNominate(): Too early to nominate (current: {}, next: {})",
                cur_time, next_nomination);
            return;
        }

        if (!this.is_nominating)
            this.nomination_start_time = cur_time;

        ConsensusData data;
        // `prepareNomintingSet` will log something if it returns `false`
        if (!this.prepareNominatingSet(data))
            return;

        if (!this.is_nominating)
            this.initial_missing_validators = data.missing_validators;

        log.info("Nominating {} at {}", data.prettify, cur_time);
        this.is_nominating = true;

        // note: we are not passing the previous tx set as we don't really
        // need it at this point (might later be necessary for chain upgrades)
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
        log.info("{}(): Proposing tx set for slot {}", __FUNCTION__, slot_idx);

        auto next_value = next.serializeFull().toVec();
        auto next_dup = duplicate_value(&next_value);
        auto nextval = this.wrapValue(next_dup);

        if (this.scp.nominate(slot_idx, nextval, this.empty_value))
        {
            log.info("{}(): Tx set triggered new nomination", __FUNCTION__);
        }
        else
        {
            log.info("{}(): Tx set didn't trigger new nomination", __FUNCTION__);
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
                this.queued_envelopes.insertBack(cast()envelope);
                this.envelope_timer.rearm(EnvTaskDelay, Periodic.No);
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
        auto copied = envelope.serializeFull.deserializeFull!SCPEnvelope;
        this.queued_envelopes.insertBack(copied);
        this.envelope_timer.rearm(EnvTaskDelay, Periodic.No);
    }

    /***************************************************************************

        Called to process a queued incoming SCP Envelope.

        Params:
            envelope = the SCP envelope

    ***************************************************************************/

    private void handleSCPEnvelope (in SCPEnvelope envelope) @trusted
    {
        // ignore messages if `startNominatingTimer` was never called or
        // if `stopNominatingTimer` was called
        if (this.nomination_timer is null)
            return;

        const Block last_block = this.ledger.getLastBlock();
        // Don't use `height - tolerance` as it could underflow
        if (envelope.statement.slotIndex <= last_block.header.height)
        {
            log.trace("receiveEnvelope: Ignoring envelope with slot id {} as ledger is at height {}",
                envelope.statement.slotIndex, last_block.header.height.value);
            return;  // slot was already externalized
        }

        Hash utxo = this.getNodeUTXO(envelope.statement.slotIndex, envelope.statement.nodeID);
        if (utxo == Hash.init)
        {
            log.trace("No UTXO for the nodeID {} at the slot {}",
                envelope.statement.nodeID, envelope.statement.slotIndex);
            return;
        }

        UTXO utxo_value;
        if (!this.ledger.peekUTXO(utxo, utxo_value))
        {
            log.trace("Couldn't find UTXO {} at height {} to validate envelope's signature",
                utxo, last_block.header.height);
            return;
        }
        const PublicKey public_key = utxo_value.output.address;
        const Scalar challenge = SCPStatementHash(&envelope.statement).hashFull();
        if (!public_key.isValid())
        {
            log.trace("Invalid point from public_key {}", public_key);
            return;
        }
        if (!verify(public_key, envelope.signature.toSignature(), challenge))
        {
            // If it fails signature verification, it might not originate from said key
            log.trace("Envelope failed signature verification for {}", public_key);
            return;
        }

        log.trace("Received signed envelope: {}", scpPrettify(&envelope, &this.getQSet));
        // we check confirmed statements before validating with
        // 'scp.receiveEnvelope()'
        // There are two reasons why:
        // 1. in the example of { N: 6, T: 4 }, we may
        //    receive 4 confimed messages and decide to externalize.
        //    then the 2 additional confirmations would be rejected because the
        //    ledger state has changed and the 2 messages now contain only
        //    double-spend transactions.
        //    so we must collect confirm signatures regardless.
        if (envelope.statement.pledges.type_ == SCPStatementType.SCP_ST_CONFIRM)
        {
            ConsensusData con_data;
            try
            {
                con_data = deserializeFull!ConsensusData(
                    envelope.statement.pledges.confirm_.ballot.value[]);
            }
            catch (Exception ex)
            {
                log.error("Validated envelope has an invalid ballot value: {}. {}",
                    envelope.statement.pledges.confirm_.ballot.value, ex);
                return;
            }
            Transaction[] received_tx_set;
            if (auto fail_reason = this.ledger.getValidTXSet(con_data, received_tx_set))
            {
                log.info("Missing TXs while checking envelope signature : {}",
                    scpPrettify(&envelope, &this.getQSet));
                return; // We dont have all the TXs for this block. Try to catchup
            }
        }
        else if (envelope.statement.pledges.type_ == SCPStatementType.SCP_ST_NOMINATE)
        {
            // show some tolerance to early nominations
            ulong tolerance = this.params.BlockInterval.total!"seconds" / 20; // 5%

            // too early to nominate a new block
            if (this.clock.networkTime() + tolerance < this.getExpectedBlockTime())
            {
                log.trace("Ignoring early nomination for height {}", envelope.statement.slotIndex);
                return;
            }
        }

        auto shared_env = this.wrapEnvelope(envelope);
        if (this.scp.receiveEnvelope(shared_env) != SCP.EnvelopeState.VALID)
            log.trace("SCP indicated invalid envelope: {}", scpPrettify(&envelope, &this.getQSet));
    }

    /***************************************************************************

        Called when a new Block Signature is received from the network.

        Params:
            block_sig = the structure with details of the block signature

    ***************************************************************************/

    public void receiveBlockSignature (in ValidatorBlockSig block_sig) @safe
    {
        const cur_height = this.ledger.getBlockHeight();
        log.trace("Received BLOCK SIG {} from node {} for block {}",
                    block_sig.signature, block_sig.utxo, block_sig.height);
        if (block_sig.height > cur_height)
            return;

        const block = this.ledger.getBlocksFrom(Height(block_sig.height)).front;
        if (!this.collectBlockSignature(block_sig, block.hashFull()))
            return;
        const signed_block = this.updateMultiSignature(block);
        if (signed_block == Block.init)
        {
            log.trace("Failed to add signature {} for block {} utxo {}",
                block_sig.signature, block_sig.height, block_sig.utxo);
            return;
        }
        this.ledger.updateBlockMultiSig(signed_block.header);
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

    public Signature signBlock (in Block block) @safe nothrow
    {
        return block.header.sign(this.kp.secret,
            this.enroll_man.getOurPreimage(block.header.height));
    }

    extern (C++):

    /***************************************************************************

        Signs the SCPEnvelope with the node's private key, and if it's
        a confirm ballot additionally provides the block header signature
        and saves the header signature for later collection on externalize.

        Params:
            envelope = the SCPEnvelope to sign

    ***************************************************************************/

    public override void signEnvelope (ref SCPEnvelope envelope)
    {
        // if we're ready to confirm then derive the block and sign its hash
        if (envelope.statement.pledges.type_ == SCPStatementType.SCP_ST_CONFIRM)
            this.signConfirmBallot(envelope);

        const Scalar challenge = SCPStatementHash(&envelope.statement).hashFull();
        envelope.signature = this.kp.sign(challenge).toBlob();
        log.trace("SIGN Envelope signature {}: {}", envelope.signature,
                  scpPrettify(&envelope, &this.getQSet));
    }

    /***************************************************************************

        Signs the confirm ballot in the SCPEnvelope

        Params:
            envelope = the SCPEnvelope

    ***************************************************************************/

    private void signConfirmBallot (ref SCPEnvelope envelope) nothrow
    {
        assert(envelope.statement.pledges.type_ ==
            SCPStatementType.SCP_ST_CONFIRM);

        const Block last_block = this.ledger.getLastBlock();

        if (Height(envelope.statement.slotIndex) != last_block.header.height + 1)
        {
            log.trace("signConfirmBallot: Ignoring envelope with slot id {} as ledger is at height {}",
                envelope.statement.slotIndex, last_block.header.height);
            return;  // slot was already externalized or envelope is too new
        }

        ConsensusData con_data = () {
            try return deserializeFull!ConsensusData(
                envelope.statement.pledges.confirm_.ballot.value[]);
            catch (Exception ex)
                assert(0);  // this should never happen
        }();

        try
        {
            Transaction[] signed_tx_set;
            if (auto fail_reason = this.ledger.getValidTXSet(con_data, signed_tx_set))
            {
                log.info("Missing TXs while signing confirm ballot {}",
                    scpPrettify(&envelope, &this.getQSet));
                return;
            }
        }
        catch (Exception e)
        {
            log.error("signConfirmBallot: Exception thrown: {}", e);
            return;
        }

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
            log.error("validateValue(): Validation failed: {}. Data: {}",
                fail_reason, data.prettify);
            return ValidationLevel.kInvalidValue;
        }

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
        const Height last_height = this.ledger.getBlockHeight();
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

            const block = this.ledger.buildBlock(
                externalized_tx_set, data.time_offset, data.enrolls, data.missing_validators);

            // Now we add our signature and gossip to other nodes
            log.trace("ADD BLOCK SIG at height {} for this node {}", height, this.kp.address);
            const self = this.enroll_man.getEnrollmentKey();
            this.slot_sigs[height][self] = this.signBlock(block);
            this.gossipBlockSignature(ValidatorBlockSig(height, self,
                this.slot_sigs[height][self].R));
            this.ledger.addHeightAsExternalizing(height);
            this.verifyBlock(this.updateMultiSignature(block));
        }
        catch (Exception exc)
        {
            log.fatal("Externalization of SCP data failed: {}", exc);
            assert(0, exc.message);
        }
        this.nomination_start_time = 0;
        this.initial_missing_validators = [];
    }

    /// function for verifying the block which can be overriden in byzantine unit tests
    extern(D) protected void verifyBlock (in Block signed_block)
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
    extern(D) protected void gossipBlockSignature (in ValidatorBlockSig block_sig)
        nothrow
    {
        // Send to other nodes in the network
        this.network.gossipBlockSignature(block_sig);
    }

    /// Were we active in this block (i.e. we are not catching up after being offline)
    public bool safeToSign (in Height height)
        nothrow
    {
        return !!(height in this.slot_sigs); // true if we were active in nomination during this block
    }

    /// Create a combined Schnorr multisig and return the updated block
    private Block updateMultiSignature (in Block block) @safe
    {
        const validators = this.ledger.getValidators(block.header.height);

        if (block.header.height !in this.slot_sigs)
        {
            log.warn("No signatures at height {}", block.header.height);
            return Block.init;
        }
        const Signature[Hash] block_sigs = this.slot_sigs[block.header.height];

        auto validator_mask = BitMask(validators.length);
        foreach (idx, const ref val; validators)
        {
            if (val.utxo() in block_sigs)
                validator_mask[idx] = true;
        }
        Block signed_block = block.updateSignature(multiSigCombine(block_sigs.byValue),
            validator_mask);
        log.trace("Updated block signature for block {}, mask: {}",
                block.header.height, validator_mask);
        return signed_block;
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
        SCPEnvelope env = cast()envelope;
        log.trace("Emitting envelope: {}", scpPrettify(&envelope, &this.getQSet));

        try
        {
            // deep-dup as SCP stores pointers to memory on the stack
            env.statement.pledges = deserializeFull!(SCPStatement._pledges_t)(
                serializeFull(env.statement.pledges));
        }
        catch (Exception ex)
        {
            assert(0, ex.to!string);
        }

        this.network.validators().each!(v => v.client.sendEnvelope(env));

        // Per SCP rules, once we CONFIRM a NOMINATE; we can't
        // nominate new values. Keep track of the biggest slot_idx we confirmed
        // a NOMINATE on
        if (envelope.statement.slotIndex > this.last_confirmed_height &&
            envelope.statement.pledges.type_ == SCPStatementType.SCP_ST_CONFIRM)
            this.last_confirmed_height = Height(envelope.statement.slotIndex);
    }

    /***************************************************************************

        Get the UTXO hash for the index of the validator at a height

        Params:
            slot_idx = the height for which we search the index of the validator
            index = the index of the validator

        Returns:
            the hash of the frozen UTXO

    ***************************************************************************/

    public StellarHash getNodeUTXO (uint64_t slot_index, uint64_t index)
        @safe nothrow
    {
        Hash utxo;
        ValidatorInfo[] validators;
        try
        {
            validators = this.ledger.getValidators(Height(slot_index));
        }
        catch (Exception exc)
        {
            log.error("Exception happened with calling `getValidators` in `getNodeID: {}", exc);
        }

        if (validators.length > index)
            utxo = validators[index].utxo;

        return StellarHash(utxo[][0 .. StellarHash.sizeof]);
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
        /// 2. total adjusted fee (smallest last), or if it ties
        /// 3. hash of the candidate (smallest first)
        public int opCmp (in CandidateHolder other) const @safe scope pure nothrow @nogc
        {
            if (this.consensus_data.missing_validators.length <
                other.consensus_data.missing_validators.length)
                    return -1;
            else if (this.consensus_data.missing_validators.length >
                     other.consensus_data.missing_validators.length)
                return 1;

            if (this.total_rate > other.total_rate)
                return -1;
            else if (this.total_rate < other.total_rate)
                return 1;

            if (this.consensus_data.tx_set.length > other.consensus_data.tx_set.length)
                return -1;
            else if (this.consensus_data.tx_set.length < other.consensus_data.tx_set.length)
                return 1;

            if (this.hash < other.hash)
                return -1;
            else if (this.hash > other.hash)
                return 1;

            return 0;
        }
    }

    @safe pure nothrow unittest
    {
        CandidateHolder candidate_holder;
        CandidateHolder[] candidate_holders;

        // The candidate with the least missing validators is preferred
        candidate_holder.consensus_data.time_offset = 1;
        candidate_holder.consensus_data.missing_validators = [1, 2, 3];
        candidate_holders ~= candidate_holder;

        candidate_holder.consensus_data.time_offset = 2;
        candidate_holder.consensus_data.missing_validators = [1, 2];
        candidate_holders ~= candidate_holder;

        candidate_holder.consensus_data.time_offset = 3;
        candidate_holder.consensus_data.missing_validators = [1, 2, 3, 4, 5];
        candidate_holders ~= candidate_holder;

        assert(candidate_holders.sort().front.consensus_data.time_offset == 2);

        // If multiple candidates have the same number of missing validators, then
        // the candidate with the higher adjusted fee is preferred.
        candidate_holders[1].total_rate = Amount(10);

        candidate_holder.consensus_data.time_offset = 4;
        candidate_holder.consensus_data.missing_validators = [3, 4];
        candidate_holder.total_rate = Amount(12);
        candidate_holders ~= candidate_holder;

        assert(candidate_holders.sort().front.consensus_data.time_offset == 4);

        // If multiple candidates have the same number of missing validators, and
        // adjusted total fee, then the candidate with lower hash is preferred.
        candidate_holder.consensus_data.time_offset = 5;
        candidate_holder.consensus_data.missing_validators = [6, 7];
        candidate_holders ~= candidate_holder;

        assert(candidate_holders.sort().front.consensus_data.time_offset == 4);
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
        try
        {
            CandidateHolder[] candidate_holders;
            foreach (ref const cand; candidates)
            {
                auto candidate = cand.getValue();
                auto data = deserializeFull!ConsensusData(candidate[]);
                log.trace("Consensus data: {}", data.prettify);

                if (auto msg = this.ledger.validateConsensusData(data, this.initial_missing_validators))
                    assert(0, format!"combineCandidates: Invalid consensus data: %s"(
                        msg));

                Amount total_rate;
                foreach (const ref tx_hash; data.tx_set)
                {
                    Amount rate;
                    auto errormsg = this.ledger.getTxFeeRate(tx_hash, rate);
                    if (errormsg == Ledger.InvalidConsensusDataReason.NotInPool)
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
            log.trace("Chosen consensus data: {}", chosen_consensus_data.prettify);

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

    /***************************************************************************

        Used by the nomination protocol to randomize the order of messages
        between nodes.

        Params:
            slot_idx = the slot index we're currently reaching consensus for.
            prev = the previous data set for the provided slot index.
            is_priority = the flag to check that this call is for priority.
            round_num = the nomination round
            node_id = the id of the node for which this computation is being made

        Returns:
            the 8-byte hash

    ***************************************************************************/

    public override uint64_t computeHashNode (uint64_t slot_idx,
        ref const(Value) prev, bool is_priority, int32_t round_num,
        ref const(NodeID) node_id) nothrow
    {
        const uint hash_N = 1;
        const uint hash_P = 2;

        const seed = this.ledger.getLastBlock().header.hashFull();
        const Hash hash = hashMulti(slot_idx, prev[],
            is_priority ? hash_P : hash_N, round_num, node_id, seed);

        uint64_t res = 0;
        for (size_t i = 0; i < res.sizeof; i++)
            res = (res << 8) | hash[][i];

        return res;
    }

    // `getHashOf` computes the hash for the given vector of byte vector
    override StellarHash getHashOf (ref vector!Value vals) const nothrow
    {
        return StellarHash(hashMulti(vals)[][0 .. Hash.sizeof]);
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

    assert(getStHash().hashFull() == Hash.fromString(
        "0xf3f95c2bcdf182f3c4ab3aa22606983c90676d908bcd053110c560cface4b18ff36d4ab359e3a44332c23ff8280385b8bc22d44ee9ab98878ac947c17e61fe75"));

    prep.counter++;
    assert(getStHash().hashFull() == Hash.fromString(
        "0xcd9c7719642dadd28f3a3fbbbcaca648f8bf35200041f39ed3c3c3ac7d8cc1c589754cff86063998a25c08bcf93ba6ad752df10b8447cfc5b4d43064debca92e"));

    prep_prime.counter++;
    assert(getStHash().hashFull() == Hash.fromString(
        "0xd876318b3559b52fe3dbd7fad5ba2756cfdd1729250c02d0b0b6fe2684eee520c9ce37d787027ef2ff3e79fec1ec73dd500b3ce9abdc724caa7bc45e91b26e9a"));

    () @trusted { st.pledges.prepare_.prepared = null; }();
    assert(getStHash().hashFull() == Hash.fromString(
        "0xca227179325dd0aacec18c20f26ee97d40be1fbe505d685cfb20f297bbf62bdc17fd0da45e6464aa37a24139882ed0cb1db0a3f67b9d63e8b70d726c6dacae21"));

    () @trusted { st.pledges.prepare_.preparedPrime = null; }();
    assert(getStHash().hashFull() == Hash.fromString(
        "0x85988fb0978100d2fc5da08c1e7cef35ad3ada741b81411d7b33d0d326454ceda82fd65166b2668416b70eb2fdd89bb1eb059b2831f1e576b5a553be210b95e5"));

    () @trusted { st.pledges.nominate_ = SCPNomination.init; }();
    st.pledges.type_ = SCPStatementType.SCP_ST_NOMINATE;
    assert(getStHash().hashFull() == Hash.fromString(
        "0x39f437e1ceb4a6c8f70dae0791c29bd1adbf8f9e053137fc7a3ddd7454e51e47546a438f6da2d563c9bb4c38afa0c2af36340ad2d13efc99edee0d25ab815f7f"));

    () @trusted { st.pledges.confirm_ = SCPStatement._pledges_t._confirm_t.init; }();
    st.pledges.type_ = SCPStatementType.SCP_ST_CONFIRM;
    assert(getStHash().hashFull() == Hash.fromString(
        "0x4e9785c61b6302695b3b8a8ccabdd3ff55b34c9b235cdb54e64c28a5afe2623791f8f33129e0d791ba0ea04161f402a3e9abf54f0269b2f78a3ad0e899037ac7"));

    () @trusted { st.pledges.externalize_ = SCPStatement._pledges_t._externalize_t.init; }();
    st.pledges.type_ = SCPStatementType.SCP_ST_EXTERNALIZE;
    assert(getStHash().hashFull() == Hash.fromString(
        "0x8eb8d71b06c7842a5c257a7475522331f04971805ed9b84c036e1c3e232b0e98ceffa015bf146716f28e1f0c20c5d068fca56c5f00431fd44a260cccc342167a"));

    SCPEnvelope env;
    auto getEnvHash () @trusted { return SCPEnvelopeHash(&env); }

    // empty envelope
    import std.conv;
    assert(getEnvHash().hashFull() == Hash.fromString(
        "0xea6365d3a07bb5637e7afc1c4110aeaa6018a1bec5e3fa9104366ab46d9a79b83fd3c4a363d9c6dc7bd2266f3dbef79b8c5da06e9c5f16c6925a4070c00069f3"));

    // with a statement
    env.statement = st;
    assert(getEnvHash().hashFull() == Hash.fromString(
        "0x98fec9d03f95de3fb6e5fefe5afb4aed545532cf1ea0440718a17451480ac4740f9b0389e613eefb1c33247d1ddc111343fd0f19ed26124abb5f8d9a9b15ccb9"));

    // import agora.utils.Test;
    // import std.stdio;
    // writeln(WK.Keys.NODE5.sign(getStHash));
    env.signature = Signature.fromString(
        "0x8e506b0d32457a3e6e2c7ba14dec178a53c567430e71dd036301c8246d8a782b" ~
        "3c4fdf745375bd2fed645433e2a9364b95d6e3931c29ea7fb445bc6ee80867a6")
        .toBlob();

    // with a signature
    assert(getEnvHash().hashFull() == Hash.fromString(
        "0x5c67d7aa06d03a48e2bca081e2eb124afc63908488088271e0da388e76381c4c487cb229cf79839c87728c087077399dba3fe7e435dc71bbbb3de051a6e5a88e"));
}

// Size assumptions made by this module
unittest
{
    static assert(StellarHash.sizeof == Hash.sizeof);
}
