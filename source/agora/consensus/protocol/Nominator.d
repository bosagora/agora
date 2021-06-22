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
import agora.common.BitField;
import agora.common.Config;
import agora.common.ManagedDatabase;
import agora.serialization.Serializer;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.protocol.Data;
import agora.consensus.data.Params;
import agora.consensus.data.Enrollment;
import agora.consensus.data.ValidatorBlockSig;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.SCPEnvelopeStore;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr;
import agora.network.Clock;
import agora.network.Manager;
import agora.node.Ledger;
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
import core.stdc.stdlib : abort;

import std.algorithm;
import std.container : DList;
import std.conv;
import std.format;
import std.path : buildPath;
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
    private SCPQuorumSetPtr[Hash] known_quorums;

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
    protected SCPEnvelopeStore scp_envelope_store;

    // Height => Point (public key) => Signature
    private Signature[PublicKey][Height] slot_sigs;

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
    public extern (D) bool delegate (const ref Block) @safe acceptBlock;

    /// Nomination start time
    protected TimePoint nomination_start_time;

    /// List of incoming SCPEnvelopes that need to be processed
    private DList!SCPEnvelope queued_envelopes;

    /// Timer used for processing queued incoming SCP Envelope messages
    private ITimer envelope_timer;

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
        bool delegate (const ref Block) @safe externalize)
    {
        assert(externalize !is null);

        this.log = Logger(__MODULE__);
        this.params = params;
        this.clock = clock;
        this.network = network;
        this.empty_value = ConsensusData.init.serializeFull().toVec();
        this.kp = key_pair;
        auto node_id = NodeID(key_pair.address.data[][0 .. NodeID.sizeof]);
        const IsValidator = true;
        const no_quorum = SCPQuorumSet.init;  // will be configured by setQuorumConfig()
        this.scp = createSCP(this, node_id, IsValidator, no_quorum);
        this.taskman = taskman;
        this.ledger = ledger;
        this.enroll_man = enroll_man;
        this.scp_envelope_store = new SCPEnvelopeStore(cacheDB);
        this.restoreSCPState();
        this.nomination_interval = nomination_interval;
        this.acceptBlock = externalize;
        this.envelope_timer = this.taskman.setTimer(10.msecs,
            &this.envelopeProcessTask, Periodic.Yes);
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

        Set or update the quorum configuration

        The node additionally takes the list of all other validator's quorum
        configurations and saves them for later lookup by getQSet().

        Params:
            quorum = the quorum config for this node
            other_quorums = the quorum config for all other nodes in the network

    ***************************************************************************/

    public void setQuorumConfig (const ref QuorumConfig quorum,
        const(QuorumConfig)[] other_quorums) nothrow @safe
    {
        assert(!this.is_nominating);
        () @trusted { this.known_quorums.clear(); }();

        // store the list of other node's quorum hashes
        foreach (qc; other_quorums)
        {
            auto quorum_set = buildSCPConfig(qc);
            auto shared_set = makeSharedSCPQuorumSet(quorum_set);
            const hash = this.getHashOfQuorum(quorum_set);
            this.known_quorums[hash] = shared_set;
        }

        // set up our own quorum
        auto quorum_set = buildSCPConfig(quorum);
        () @trusted { this.scp.updateLocalQuorumSet(quorum_set); }();
        auto shared_set = makeSharedSCPQuorumSet(quorum_set);
        const hash = this.getHashOfQuorum(quorum_set);
        this.known_quorums[hash] = shared_set;
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
        () @trusted { this.scp.stopNomination(height); }();

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
        if (data.tx_set.length < 1)
        {
            this.log.trace("prepareNominatingSet(): No transaction to nominate yet");
            return false;
        }

        // check whether the consensus data is valid before nominating it.
        if (auto msg = this.ledger.validateConsensusData(data))
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

        if (this.nomination_start_time == 0)
            this.nomination_start_time = cur_time;

        ConsensusData data;
        // `prepareNomintingSet` will log something if it returns `false`
        if (!this.prepareNominatingSet(data))
            return;

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
        foreach (bool proc, const ref SCPEnvelope envelope; this.scp_envelope_store)
        {
            if (!proc)
            {
                this.queued_envelopes.insertBack(cast()envelope);
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

        // Outdated envelopes might contain block signatures which we want to add
        // Hence, define a certain tolerance for us to accept those.
        // See https://github.com/bosagora/agora/issues/1875
        static immutable ConfirmTolerance = 10;

        const Block last_block = this.ledger.getLastBlock();
        // Don't use `height - tolerance` as it could underflow
        if (envelope.statement.slotIndex + ConfirmTolerance < last_block.header.height)
        {
            log.trace("receiveEnvelope: Ignoring envelope with slot id {} as ledger is at height {}",
                envelope.statement.slotIndex, last_block.header.height.value);
            return;  // slot was already externalized or envelope is too new
        }

        const PublicKey public_key = PublicKey(envelope.statement.nodeID[]);
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

        log.trace("Received signed envelope: {}", scpPrettify(&envelope));
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

            // If it's an old envelope, we're only interested in the signature
            if (envelope.statement.slotIndex <= last_block.header.height)
            {
                const sig = ValidatorBlockSig(
                    Height(envelope.statement.slotIndex), public_key,
                    Scalar(envelope.statement.pledges.confirm_.value_sig));
                auto blocks = this.ledger.getBlocksFrom(Height(envelope.statement.slotIndex));
                if (this.collectBlockSignature(sig, blocks[0].hashFull()))
                    log.trace("Added signature for {} from CONFIRM ballot", public_key);
                else
                    log.info("Couldn't add signature for {}'s CONFIRM ballot", public_key);
                return;
            }

            Hash random_seed = this.ledger.getRandomSeed(
                last_block.header.height + 1, con_data.missing_validators);

            Transaction[] received_tx_set;
            if (auto fail_reason = this.ledger.getValidTXSet(con_data, received_tx_set))
            {
                log.info("Missing TXs while checking envelope signature : {}",
                    scpPrettify(&envelope));
                return; // We dont have all the TXs for this block. Try to catchup
            }
            const Block proposed_block = makeNewBlock(last_block,
                received_tx_set, con_data.time_offset, random_seed,
                this.enroll_man.getCountOfValidators(last_block.header.height + 1),
                con_data.enrolls, con_data.missing_validators);
            const block_sig = ValidatorBlockSig(Height(envelope.statement.slotIndex),
                public_key, Scalar(envelope.statement.pledges.confirm_.value_sig));
            if (!this.collectBlockSignature(block_sig, proposed_block.hashFull()))
                return;
        }

        auto shared_env = this.wrapEnvelope(envelope);
        if (this.scp.receiveEnvelope(shared_env) != SCP.EnvelopeState.VALID)
            log.trace("SCP indicated invalid envelope: {}", scpPrettify(&envelope));
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
                    block_sig.signature, block_sig.public_key, block_sig.height);
        if (block_sig.height > cur_height)
            return;

        const block = this.ledger.getBlocksFrom(Height(block_sig.height)).front;
        if (!this.collectBlockSignature(block_sig, block.hashFull()))
            return;
        const signed_block = this.updateMultiSignature(block);
        if (signed_block == Block.init)
        {
            log.trace("Failed to add signature {} for block {} public key {}",
                block_sig.signature, block_sig.height, block_sig.public_key);
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
            if (this.scp.empty())
                return;

            envelopes = this.scp.getExternalizingState(this.scp.getHighSlotIndex());
        }();

        ManagedDatabase.beginBatch();
        scope (failure) ManagedDatabase.rollback();

        // Clean the previous envelopes from the DB
        this.scp_envelope_store.removeAll();

        // Store the latest envelopes
        foreach (const ref env; envelopes)
            this.scp_envelope_store.add(env, true);

        // Store the queued envelopes
        foreach (const ref env; this.queued_envelopes[])
            this.scp_envelope_store.add(env, false);

        ManagedDatabase.commitBatch();
    }

    /***************************************************************************

        Create the block signature for this node.
        This signature will be combined with other validator's signatures
        using Schnorr multisig.

        Params:
            block = the block to sign

    ***************************************************************************/

    public Signature createBlockSignature (in Block block) @safe nothrow
    {
        return block.header.createBlockSignature(this.kp.secret,
            this.enroll_man.getOurPreimage(block.header.height),
            ulong((block.header.height - 1) / this.params.ValidatorCycle));
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
                  scpPrettify(&envelope));
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
            const Hash random_seed = this.ledger.getRandomSeed(
                    last_block.header.height + 1, con_data.missing_validators);
            Transaction[] signed_tx_set;
            if (auto fail_reason = this.ledger.getValidTXSet(con_data, signed_tx_set))
            {
                log.info("Missing TXs while signing confirm ballot {}",
                    scpPrettify(&envelope));
                return;
            }

            const proposed_block = makeNewBlock(last_block,
                signed_tx_set, con_data.time_offset, random_seed,
                this.enroll_man.getCountOfValidators(last_block.header.height + 1),
                con_data.enrolls, con_data.missing_validators);

            const Signature sig = createBlockSignature(proposed_block);

            envelope.statement.pledges.confirm_.value_sig = opaque_array!32(BitBlob!32(sig.s[]));

            // Store our block signature in the slot_sigs map
            log.trace("signConfirmBallot: ADD block signature at height {} for this node {}",
                last_block.header.height + 1, this.kp.address);
            this.slot_sigs[last_block.header.height + 1][this.kp.address] = sig;
        }
        catch (Exception e)
        {
            log.error("signConfirmBallot: Exception thrown: {}", e);
            return;
        }

    }

    /***************************************************************************

        Collect the block signature for a confirmed ballot or gossiped signature
        only if the signature is valid for validator and block hash

        Params:
            block_sig = the structure with the block signature details
            block_hash = the hash of the proposed block

        Returns:
            true if verified

    ***************************************************************************/

    private bool collectBlockSignature (in ValidatorBlockSig block_sig,
        in Hash block_hash) @safe nothrow
    {
        const PublicKey K = block_sig.public_key;
        if (!K.isValid())
        {
            log.warn("Invalid point from public_key {}", block_sig.public_key);
            return false;
        }
        const Scalar block_challenge = block_hash;
        // Fetch the R from enrollment commitment for signing validator
        const CR = this.enroll_man.getCommitmentNonce(block_sig.public_key, block_sig.height);
        // Get the preimage at ledger height
        const preimage_info = this.enroll_man.validator_set.getPreimageAt(
            this.enroll_man.validator_set.getEnrollmentForKey(block_sig.height, block_sig.public_key),
            block_sig.height);
        if (preimage_info.hash == Hash.init)
        {
            log.warn("collectBlockSignature: No preimage for {} to sign block at height {}", block_sig.public_key, block_sig.height);
            return false;
        }
        // Determine the R of signature (R, s)
        Point R = CR + Scalar(preimage_info.hash).toPoint();
        // Compose the signature (R, s)
        const sig = Signature(R, block_sig.signature);
        // Check this signature is valid for this block and signing validator
        if (!verify(sig, block_challenge, K))
        {
            log.warn("collectBlockSignature: INVALID Block signature received for slot {} from node {}",
                block_sig.height, block_sig.public_key);
            return false;
        }
        log.trace("collectBlockSignature: VALID block signature at height {} for node {}",
            block_sig.height, block_sig.public_key);
        // collect the signature
        this.slot_sigs[block_sig.height][K] = Signature(R, block_sig.signature);
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

        if (this.ledger.isSelfSlashing(Height(slot_idx), data))
        {
            log.warn("validateValue(): Marking {} for data slashing us as invalid",
                     nomination ? "nomination" : "vote");
            return ValidationLevel.kInvalidValue;
        }

        if (auto fail_reason = this.ledger.validateConsensusData(data))
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
        const Block last_block = this.ledger.getLastBlock();
        if (height != last_block.header.height + 1)
        {
            log.trace("valueExternalized: Will not externalize envelope with slot id {} as ledger is at height {}",
                height, last_block.header.height);
            return;  // slot was already externalized or envelope is too new
        }
        ConsensusData data = void;
        try
            data = deserializeFull!ConsensusData(value[]);
        catch (Exception exc)
        {
            log.fatal("Deserialization of C++ Value failed: {}", exc);
            abort();
        }

        // enrollment data may be empty, but not transaction set
        if (data.tx_set.length == 0)
            assert(0, format!"Transaction set empty for slot %s"(height));

        log.info("Externalized consensus data set at {}: {}", height, prettify(data));
        try
        {
            Hash random_seed = this.ledger.getRandomSeed(
                height, data.missing_validators);
            Transaction[] externalized_tx_set;
            if (auto fail_reason = this.ledger.getValidTXSet(data,
                externalized_tx_set))
            {
                log.info("Missing TXs while externalizing at Height {}: {}",
                    height, prettify(data));
                return;
            }
            const block = makeNewBlock(last_block,
                externalized_tx_set, data.time_offset, random_seed,
                this.enroll_man.getCountOfValidators(last_block.header.height + 1),
                data.enrolls, data.missing_validators);

            // If we did not sign yet then add signature and gossip to other nodes
            if (this.kp.address !in this.slot_sigs[height])
            {
                log.trace("ADD BLOCK SIG at height {} for this node {}", height, this.kp.address);
                this.slot_sigs[height][this.kp.address] = this.createBlockSignature(block);
            }

            const signed_block = this.updateMultiSignature(block);
            if (signed_block == Block.init)
            {
                log.warn("Not ready to externalize this block at height {} on node {}", height, this.kp.address);
                gossipBlockSignature(ValidatorBlockSig(height, this.kp.address,
                    this.slot_sigs[height][this.kp.address].s));
                return;
            }
            this.verifyBlock(signed_block);
        }
        catch (Exception exc)
        {
            log.fatal("Externalization of SCP data failed: {}", exc);
            abort();
        }
        this.gossipBlockSignature(ValidatorBlockSig(height, this.kp.address,
                    this.slot_sigs[height][this.kp.address].s));
        this.nomination_start_time = 0;
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
        if (!this.acceptBlock(signed_block))
        {
            auto msg = this.ledger.validateBlock(signed_block);
            log.error("Block was not accepted by node {}: {}", this.kp.address, msg);
            assert(0, "Block was not accepted: " ~ msg);
        }
    }

    /// function for gossip of block sig which can be overriden in byzantine unit tests
    extern(D) protected void gossipBlockSignature (in ValidatorBlockSig block_sig)
        nothrow
    {
        // Send to other nodes in the network
        this.network.gossipBlockSignature(block_sig);
    }

    /// If more than half have signed create a combined Schnorr multisig and return the updated block
    private Block updateMultiSignature (in Block block) @safe
    {
        auto all_validators = this.enroll_man.getCountOfValidators(block.header.height);

        if (block.header.height !in this.slot_sigs)
        {
            log.warn("No signatures at height {}", block.header.height);
            return Block.init;
        }
        const Signature[PublicKey] block_sigs = this.slot_sigs[block.header.height];

        auto validator_mask = BitField!ubyte(all_validators);
        foreach (K; block_sigs.byKey())
        {
            ulong idx = this.enroll_man.getIndexOfValidator(block.header.height, K);
            if (idx == ulong.max)
            {
                log.warn("Unable to determine index of validator {} at block height {}",
                    PublicKey(K[]), block.header.height, block.header.height);
                return Block.init;
            }
            validator_mask[idx] = true;
        }
        // There must exist signatures for at least half the validators to externalize
        if (block_sigs.length <= all_validators / 2)
        {
            log.warn("Only {} signed. Require more than {} out of {} validators to sign for externalizing slot height {}.",
                block_sigs.length, all_validators / 2, all_validators, block.header.height);
            return Block.init;
        }
        Block signed_block = block.updateSignature(
            multiSigCombine(block_sigs.byValue), validator_mask);
        log.trace("Updated block signatures for block {}, mask: {}",
                block.header.height, validator_mask);
        return signed_block;
    }

    /***************************************************************************

        Params:
            qSetHash = the hash of the quorum set

        Returns:
            the SCPQuorumSet pointer for the provided quorum set hash

    ***************************************************************************/

    public override SCPQuorumSetPtr getQSet (ref const(StellarHash) qSetHash)
    {
        if (auto scp_quroum = qSetHash in this.known_quorums)
            return *scp_quroum;

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
        log.trace("Emitting envelope: {}", scpPrettify(&envelope));

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

    /// Used for holding consensus candidate values. It contains precomputed
    /// fields to speed up sorting.
    static struct CandidateHolder
    {
        /// Consensus data
        public ConsensusData consensus_data;
        /// Hash of the consensus data
        public Hash hash;
        /// The total amount of fees of the transactions in the consensus data
        public Amount total_adjusted_fee;

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

            if (this.total_adjusted_fee > other.total_adjusted_fee)
                return -1;
            else if (this.total_adjusted_fee < other.total_adjusted_fee)
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
        candidate_holders[1].total_adjusted_fee = Amount(10);

        candidate_holder.consensus_data.time_offset = 4;
        candidate_holder.consensus_data.missing_validators = [3, 4];
        candidate_holder.total_adjusted_fee = Amount(12);
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
        log.info("combineCandidates: {}", slot_idx);

        try
        {
            CandidateHolder[] candidate_holders;
            foreach (ref const cand; candidates)
            {
                auto candidate = cand.getValue();
                auto data = deserializeFull!ConsensusData(candidate[]);
                log.trace("Consensus data: {}", data.prettify);

                // Only allowed in unittests, as validating the consensus data
                // for all the candidates might take long.
                version (unittest)
                if (auto msg = this.ledger.validateConsensusData(data))
                    assert(0, format!"combineCandidates: Invalid consensus data: %s"(
                        msg));

                Amount total_adjusted_fee;
                foreach (const ref tx_hash; data.tx_set)
                {
                    Amount adjusted_fee;
                    auto errormsg = this.ledger.getAdjustedTXFee(tx_hash, adjusted_fee);
                    if (errormsg == Ledger.InvalidConsensusDataReason.NotInPool)
                        continue; // most likely a CoinBase Transaction
                    else if (errormsg)
                        assert(0);
                    total_adjusted_fee.mustAdd(adjusted_fee);
                }

                CandidateHolder candidate_holder =
                {
                    consensus_data: data,
                    hash: data.hashFull(),
                    total_adjusted_fee = total_adjusted_fee,
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
    static assert(SCPNomination.sizeof == 112);

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
        scope HashDg dg) @safe pure nothrow @nogc
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
        @safe pure nothrow @nogc
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
        @safe pure nothrow @nogc
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
        "0x5364136f3ae0093a65e9371a66368512bb80b748ad4362eea14c16eb0c1276eee842cf88cd1116dfe833496e4e627e315f6b5568f0d1e18dc93d43692c5c13d0"));

    prep.counter++;
    assert(getStHash().hashFull() == Hash.fromString(
        "0x8fe1c781219cc7bdf803ca4ac734c9c2e29d1d4de7184dc04d0da7eab5e8d3f2bc29a0df230b984ff652c98a142b3a5e2516f3fa9d4e0631e4a90318d12aedfc"));

    prep_prime.counter++;
    assert(getStHash().hashFull() == Hash.fromString(
        "0x48d0cc62dc9a015c5c4b941a91cff376b0b5cb52897027ac8ad79aa8a29246e59a11dfcde18ad8e94979f4051fe3525cb0a0852e7d26595ca4ac98f3dec4fe20"));

    () @trusted { st.pledges.prepare_.prepared = null; }();
    assert(getStHash().hashFull() == Hash.fromString(
        "0x308409f19835412fca6c22f95bf2097fd292f5190ac35db78907ce76a56b435817d7b912f5ca23e89a9793d59953506035323f7f92c63434eb0c1116fe667eb0"));

    () @trusted { st.pledges.prepare_.preparedPrime = null; }();
    assert(getStHash().hashFull() == Hash.fromString(
        "0xcdf64b3616112b53c9e0d422a876f1644d69a15b638a1341a29dc5362c827d2d57e0e5f7a5e4a25a0b475167edd6fbe0b01feb0599342c4148a83ac1d1a70a4d"));

    () @trusted { st.pledges.nominate_ = SCPNomination.init; }();
    st.pledges.type_ = SCPStatementType.SCP_ST_NOMINATE;
    assert(getStHash().hashFull() == Hash.fromString(
        "0x0664bde2dd296bcc77d039dfd17495dc90a1c478777acfbd09de70298dda4c96d8266f61746e980838e1f404c9eb266e213d06904c4c3c21211f0f0f829d3fa6"));

    () @trusted { st.pledges.confirm_ = SCPStatement._pledges_t._confirm_t.init; }();
    st.pledges.type_ = SCPStatementType.SCP_ST_CONFIRM;
    assert(getStHash().hashFull() == Hash.fromString(
        "0x99b6963f5d75c2edf026bfc440a0e400e116f1ef332224f144fc8703356daed752167738a55ce7be4787eb15a58f11ed31df2cfb1586b0e5fca65090b8853285"));

    () @trusted { st.pledges.externalize_ = SCPStatement._pledges_t._externalize_t.init; }();
    st.pledges.type_ = SCPStatementType.SCP_ST_EXTERNALIZE;
    assert(getStHash().hashFull() == Hash.fromString(
        "0x51e9f93b9acd323694d0192e7ff10fe2d9aa2a6fbc55877aa88b8ca29efcc119b1d8113961c71657e359c5aa8fc6a195db589b974a7bc030ca81e6b80f415e95"));

    SCPEnvelope env;
    auto getEnvHash () @trusted { return SCPEnvelopeHash(&env); }

    // empty envelope
    import std.conv;
    assert(getEnvHash().hashFull() == Hash.fromString(
        "0xcbebb1c5901e6d7cd593b4608d9815dbb723e92b27abbfe863ff31a422b91da54198b33f03195a84682108504b03a98d0b87cd6c7bc34b2265f686cce7ea21e3"));

    // with a statement
    env.statement = st;
    assert(getEnvHash().hashFull() == Hash.fromString(
        "0x77d1b82e4ccff42730d9f0d11e7629bc518abb9258954e4060e6f843ea561abaacab37ba9af571c0bd27f22302f579970b4b5dd0d3f34b91a79526a7041982ef"));

    // import agora.utils.Test;
    // import std.stdio;
    // writeln(WK.Keys.NODE5.sign(getStHash));
    env.signature = Signature.fromString(
        "0x969c0879ffedac8d03034a60b59cf9ff8f195052ae5e5fae247823fe349462a0" ~
        "08f8a0f915d0598cbab106a5bda6ccabe30327f2c4bc980ed817592a9bebb04b")
        .toBlob();

    // with a signature
    assert(getEnvHash().hashFull() == Hash.fromString(
        "0x5ee8649f04528b083a2bd03d666d7ced845681be58f93bdc5964cf3af2bc1f7c19511084c698f0d500ae4c6c9a38f5d0ecc41fa42f68dc5f355e8f518e793a7d"));
}

// Size assumptions made by this module
unittest
{
    static assert(NodeID.sizeof == PublicKey.sizeof);
    static assert(StellarHash.sizeof == Hash.sizeof);
}
