/*******************************************************************************

    Contains the SCP consensus driver implementation.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.protocol.Nominator;

import agora.common.BitField;
import agora.common.Config;
import agora.common.ManagedDatabase;
import agora.common.SCPHash;
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
import scpd.types.Stellar_types : uint256, uint512, NodeID;
import scpd.types.Stellar_types : StellarHash = Hash;
import scpd.types.Stellar_SCP;
import scpd.types.Utils;
import scpd.types.XDRBase : opaque_array;

import geod24.bitblob;

import core.stdc.stdint;
import core.stdc.stdlib : abort;

import std.algorithm;
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

    ***************************************************************************/

    public this (immutable(ConsensusParams) params, KeyPair key_pair,
        Clock clock, NetworkManager network, ValidatingLedger ledger,
        EnrollmentManager enroll_man, ITaskManager taskman, string data_dir,
        Duration nomination_interval)
    {
        this.log = Logger(__MODULE__);
        this.params = params;
        this.clock = clock;
        this.network = network;
        this.empty_value = ConsensusData.init.serializeFull().toVec();
        this.kp = key_pair;
        auto node_id = NodeID(uint256(key_pair.address.data[][0 .. uint256.sizeof]));
        const IsValidator = true;
        const no_quorum = SCPQuorumSet.init;  // will be configured by setQuorumConfig()
        this.scp = createSCP(this, node_id, IsValidator, no_quorum);
        this.taskman = taskman;
        this.ledger = ledger;
        this.enroll_man = enroll_man;
        this.scp_envelope_store = this.makeSCPEnvelopeStore(data_dir);
        this.restoreSCPState();
        this.nomination_interval = nomination_interval;
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
            this.known_quorums[hashFull(quorum_set)] = shared_set;
        }

        // set up our own quorum
        auto quorum_set = buildSCPConfig(quorum);
        () @trusted { this.scp.updateLocalQuorumSet(quorum_set); }();
        auto shared_set = makeSharedSCPQuorumSet(quorum_set);
        this.known_quorums[hashFull(quorum_set)] = shared_set;
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

        Overriden in unittests to get fine-grained control
        of when blocks are created:

        - We may want to create blocks faster than `BlockIntervalSeconds`
          in order to speed up the unittests.
        - We may want to wait until we have a specific number of TXs in the
          pool before we start nominating. Otherwise timing issues may cause
          the unittest nodes to nominate wildly different transaction sets,
          skewing the assumptions in the tests and causing failures.

        Returns:
            true if the validator is ready to start nominating

    ***************************************************************************/

    protected bool prepareNominatingSet (out ConsensusData data) @safe
    {
        this.ledger.prepareNominatingSet(data, MaxTransactionsPerBlock);
        if (data.tx_set.length < 1)
            return false;  // not ready to nominate yet

        // check whether the consensus data is valid before nominating it.
        if (auto msg = this.ledger.validateConsensusData(data))
        {
            log.fatal("prepareNominatingSet(): Invalid consensus data: {}. Data: {}",
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
            return;

        const cur_time = this.clock.networkTime();
        const genesis_timestamp = this.params.GenesisTimestamp;

        if (cur_time < genesis_timestamp)
        {
            log.fatal("Clock is out of sync. " ~
                "Current time: {}. Genesis time: {}", cur_time,
                genesis_timestamp);
            return;
        }

        if (cur_time < this.getExpectedBlockTime())
            return;  // too early to nominate

        ConsensusData data;
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
        if (this.scp.nominate(slot_idx, next_dup, this.empty_value))
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

    protected void restoreSCPState ()
    {
        foreach (const ref SCPEnvelope envelope; this.scp_envelope_store)
        {
            this.scp.setStateFromEnvelope(envelope.statement.slotIndex,
                envelope);
            if (!this.scp.isSlotFullyValidated(envelope.statement.slotIndex))
                assert(0);
        }
    }

    /***************************************************************************

        Called when a new SCP Envelope is received from the network.

        Params:
            envelope = the SCP envelope

        Returns:
            true if the SCP protocol accepted this envelope

    ***************************************************************************/

    public void receiveEnvelope (in SCPEnvelope envelope) @trusted
    {
        // ignore messages if `startNominatingTimer` was never called or
        // if `stopNominatingTimer` was called
        if (this.nomination_timer is null)
            return;

        const Block last_block = this.ledger.getLastBlock();
        if (Height(envelope.statement.slotIndex) != last_block.header.height + 1)
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
            Hash random_seed = this.ledger.getExternalizedRandomSeed(
                last_block.header.height, con_data.missing_validators);

            Transaction[] received_tx_set;
            if (auto fail_reason = this.ledger.getValidTXSet(con_data, received_tx_set))
            {
                log.info("Missing TXs while checking envelope signature : {}",
                    prettify(envelope));
                return; // We dont have all the TXs for this block. Try to catchup
            }
            const Block proposed_block = makeNewBlock(last_block,
                received_tx_set, con_data.time_offset, random_seed,
                con_data.enrolls, con_data.missing_validators);
            const block_sig = ValidatorBlockSig(Height(envelope.statement.slotIndex),
                public_key, Scalar(envelope.statement.pledges.confirm_.value_sig));
            if (!this.collectBlockSignature(block_sig, proposed_block.hashFull()))
                return;
        }

        if (this.scp.receiveEnvelope(envelope) != SCP.EnvelopeState.VALID)
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

        Store the latest SCP sate for restore

    ***************************************************************************/

    public void storeLatestState () @safe
    {
        vector!SCPEnvelope envelopes;

        () @trusted
        {
            if (this.scp.empty())
                return;
            envelopes = this.scp.getLatestMessagesSend(this.scp.getHighSlotIndex());
        }();

        ManagedDatabase.beginBatch();
        scope (failure) ManagedDatabase.rollback();

        // Clean the previous envelopes from the DB
        this.scp_envelope_store.removeAll();

        // Store the latest envelopes
        foreach (const ref env; envelopes)
            this.scp_envelope_store.add(env);

        ManagedDatabase.commitBatch();
    }

    /***************************************************************************

        Returns an instance of an SCPEnvelopeStore

        Params:
            data_dir = path to the data directory

        Returns:
            the SCPEnvelopeStore instance

    ***************************************************************************/

    protected SCPEnvelopeStore makeSCPEnvelopeStore (string data_dir)
    {
        return new SCPEnvelopeStore(buildPath(data_dir, "scp_envelopes.dat"));
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
        // challenge = Hash(block) to Scalar
        const Scalar challenge = hashFull(block);

        // rc = r used in signing the commitment
        const Scalar rc = this.enroll_man.getCommitmentNonceScalar(block.header.height);
        log.trace("createBlockSignature: Enrollment commitment CR for validator {} is {}", this.kp.address, rc.toPoint());
        const Scalar r = rc + challenge; // make it unique each challenge
        const Point R = r.toPoint();
        log.trace("createBlockSignature: Block signing commitment R for validator {} is {}", this.kp.address, R);
        return sign(this.kp.secret, R, r, challenge);
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

        const Hash random_seed = this.ledger.getExternalizedRandomSeed(
                last_block.header.height, con_data.missing_validators);

        Transaction[] signed_tx_set;
        if (auto fail_reason = this.ledger.getValidTXSet(con_data, signed_tx_set))
        {
            log.info("Missing TXs while signing confirm ballot {}",
                prettify(envelope));
            return;
        }

        const proposed_block = makeNewBlock(last_block,
            signed_tx_set, con_data.time_offset, random_seed,
            con_data.enrolls, con_data.missing_validators);

        const Signature sig = createBlockSignature(proposed_block);

        envelope.statement.pledges.confirm_.value_sig = opaque_array!32(BitBlob!32(sig.s[]));

        // Store our block signature in the slot_sigs map
        log.trace("signConfirmBallot: ADD block signature at height {} for this node {}",
            last_block.header.height + 1, this.kp.address);
        this.slot_sigs[last_block.header.height + 1][this.kp.address] = sig;
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
        // Determine the R of signature (R, s)
        const Point R = CR + block_challenge.toPoint();
        log.trace("collectBlockSignature: [{}] Enrollment commitment (CR): {}, signing commitment (R): {}",
                  block_sig.public_key, CR, R);
        // Compose the signature (R, s)
        const sig = Signature(R, block_sig.signature.asScalar());
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
        this.slot_sigs[block_sig.height][K] = Signature(R, block_sig.signature.asScalar());
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

        if (this.ledger.checkSelfSlashing(data))
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
        Hash random_seed = this.ledger.getExternalizedRandomSeed(
            last_block.header.height, data.missing_validators);
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
            data.enrolls, data.missing_validators);

        // If we did not sign yet then add signature and gossip to other nodes
        if (this.kp.address !in this.slot_sigs[height])
        {
            log.trace("ADD BLOCK SIG at height {} for this node {}", height, this.kp.address);
            this.slot_sigs[height][this.kp.address] = this.createBlockSignature(block);
        }

        try
        {
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
    }

    /// function for verifying the block which can be overriden in byzantine unit tests
    extern(D) protected void verifyBlock (in Block signed_block)
    {
        if (!this.ledger.acceptBlock(signed_block))
        {
            log.error("Block was not accepted by node {}", this.kp.address);
            assert(0, format!"Block was not accepted"());
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

    /***************************************************************************

        Combine a set of transaction sets into a single transaction set.
        This may be done in arbitrary ways, as long as it's consistent
        (for a given input, the combined output is predictable).

        Params:
            slot_idx = the slot index we're currently reaching consensus for
            candidates = a set of a set of transactions

    ***************************************************************************/

    public override Value combineCandidates (uint64_t slot_idx,
        ref const(set!Value) candidates)
    {
        try
        {
            ConsensusData[] values;
            foreach (ref const(Value) candidate; candidates)
            {
                auto data = deserializeFull!ConsensusData(candidate[]);

                if (auto msg = this.ledger.validateConsensusData(data))
                    assert(0, format!"combineCandidates: Invalid consensus data: %s"(
                        msg));

                log.trace("Combined consensus data: {}", data.prettify);
                values ~= data;
            }
            // Nomination MUST be deterministic so we take the least number of validators missing pre-images
            auto combined = values.sort!("a.missing_validators.length < b.missing_validators.length").front();
            log.info("combineCandidates: from {} candidates took: {}", values.length, combined.prettify);
            const Value val = combined.serializeFull().toVec();
            return duplicate_value(&val);
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
        scope (failure) assert(0);

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

        const seed = this.ledger.getValidatorRandomSeed(Height(slot_idx - 1));
        uint512 hash = uint512(hashMulti(slot_idx, prev[],
            is_priority ? hash_P : hash_N, round_num, node_id, seed));

        uint64_t res = 0;
        for (size_t i = 0; i < res.sizeof; i++)
            res = (res << 8) | hash[][i];

        return res;
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

    public void computeHash (scope HashDg dg) const nothrow @safe @nogc
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
        "0xd0af1ceb655cb7f376076eaaee79b0c6cd5d99258e48c2a9393f3748fdc6c99f333d01433631664c993b39f18938ce98ae74fcf73647b0505a9fcdc0a9ff0201"),
        getStHash().hashFull().to!string);

    prep.counter++;
    assert(getStHash().hashFull() == Hash.fromString(
        "0x64db448aae015955a2c022d7b415619e71b56cb9ca8329f2620ae4468576ebb7bb323d38829d02b89185147c8ba6d0a30ef7630d6c31cdea4703dc8b5c23dc80"),
        getStHash().hashFull().to!string);

    prep_prime.counter++;
    assert(getStHash().hashFull() == Hash.fromString(
        "0x150f1e058a1b4296cb5e2765d475f1183f15c49011a568dd95fe825049d3a8fddbb12fb2e37bbf12de4719afe452e1e9908dd4e88f7dd88200fab8a7ac0f29e9"),
        getStHash().hashFull().to!string);

    () @trusted { st.pledges.prepare_.prepared = null; }();
    assert(getStHash().hashFull() == Hash.fromString(
        "0x47b526fb78d939a2a1814fc2143e6aa9190b96ec37222c6e79ff038fa51ecc7bdf6e58f19b73c2236c9a3c24d21fa253f344c1e740dec225fdc3ccb2e1c8d5c8"),
        getStHash().hashFull().to!string);

    () @trusted { st.pledges.prepare_.preparedPrime = null; }();
    assert(getStHash().hashFull() == Hash.fromString(
        "0x932507364adead54419d46354f43da574c80461aa2ecddc0045e32709b84396cc8cfa024fa029638c61bb1d8cb82744a8270b65df5dc3cfca39a72474cee2e27"),
        getStHash().hashFull().to!string);

    () @trusted { st.pledges.nominate_ = SCPNomination.init; }();
    st.pledges.type_ = SCPStatementType.SCP_ST_NOMINATE;
    assert(getStHash().hashFull() == Hash.fromString(
        "0x3af032546fa5435d63902781b6d1d0432ce08a20b9989b1ad2aaa05a0dc7c161991fd5663fed875a1a72b7ffabbcea951d44ec20f5ecf0514620fcc36e62652c"),
        getStHash().hashFull().to!string);

    () @trusted { st.pledges.confirm_ = SCPStatement._pledges_t._confirm_t.init; }();
    st.pledges.type_ = SCPStatementType.SCP_ST_CONFIRM;
    assert(getStHash().hashFull() == Hash.fromString(
        "0x6770df82a25becf382fa11a8dc23131b9b3559270d7b6936395db2986f91da4d70d148e105e22168110f41aa737d5eb246fdf3927a0c02a41840fb3f5ed597a3"),
        getStHash().hashFull().to!string);

    () @trusted { st.pledges.externalize_ = SCPStatement._pledges_t._externalize_t.init; }();
    st.pledges.type_ = SCPStatementType.SCP_ST_EXTERNALIZE;
    assert(getStHash().hashFull() == Hash.fromString(
        "0x53bf3b4c096a94e0022a09bad1d02a7f447fe4a5060f4981afdcda86a82248a1c611825b2a311cca991d85a5514267d5839887fe52eb42afb4c305f67a92033f"),
        getStHash().hashFull().to!string);

    SCPEnvelope env;
    auto getEnvHash () @trusted { return SCPEnvelopeHash(&env); }

    // empty envelope
    import std.conv;
    assert(getEnvHash().hashFull() == Hash.fromString(
        "0x3f5564eb9fb0586ff40d21fb72fc53001e64323b40fa1697113df3169d61d5251dfdae87cd34e16c9ee4604fd4214d0fd4562b81ac5bacbacecc445977855610"),
    getEnvHash().hashFull().to!string);

    // with a statement
    env.statement = st;
    assert(getEnvHash().hashFull() == Hash.fromString(
        "0x256cdc6a2286a21d4ff4297d6a438939e60195016d15ad4693fd4e6dfa18dff1eac5b4237da250d1065293da9a0c947502c6dccc0cf85d6291da2ac5b36f55f5"),
    getEnvHash().hashFull().to!string);

    // import agora.utils.Test;
    // import std.stdio;
    // writeln(WK.Keys.NODE5.sign(getStHash);
    env.signature = Signature.fromString(
        "0xdf167aadc11b25de15ca6fd4bfb04dc965dea837536a69883c7f3438707eac5d" ~
        "0030310bb98c310134e53f3daf84674b32abd30f505126375a163587cf4008be")
        .toBlob();

    // with a signature
    assert(getEnvHash().hashFull() == Hash.fromString(
        "0x5e6451029926ccc643c740376a618a60caeb271d62b91864113f6edbb0f0784177875cd2e56c65870d256752b6499f21e2955d605945f85e8527a64d1919f421"),
    getEnvHash().hashFull().to!string);
}
