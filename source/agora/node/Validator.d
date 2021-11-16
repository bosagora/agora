/*******************************************************************************

    Implementation of the Validator API.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.Validator;

import agora.api.Validator;
import agora.common.Amount;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.data.ValidatorBlockSig;
import agora.consensus.EnrollmentManager;
import agora.consensus.protocol.Data;
import agora.consensus.protocol.Nominator;
import agora.consensus.Quorum;
import agora.consensus.state.UTXOSet;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.network.Clock;
import agora.network.Manager;
import agora.node.admin.AdminInterface;
import agora.node.BlockStorage;
import agora.node.Config;
import agora.node.FullNode;
import agora.consensus.Ledger;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types : NodeID;

import std.algorithm;
import std.range : array, enumerate;

import core.time;

/*******************************************************************************

    Implementation of the Validator node

    This class implement the business code of the node.
    Communication with the other nodes is handled by the `Network` class.

*******************************************************************************/

public class Validator : FullNode, API
{
    /// Nominator instance
    protected Nominator nominator;

    /// The current required set of peers UTXOs to connect to
    protected UTXO[Hash] required_peer_utxos;

    /// Currently active quorum configuration
    protected QuorumConfig qc;

    /// Quorum generator parameters
    protected QuorumParams quorum_params;

    /// The last height at which a quorum shuffle took place.
    /// If a new block is externalized and `last_shuffle_height`
    /// is >= `QuorumShuffleInterval` then the quorum will be reshuffled again.
    private Height last_shuffle_height = Height(0);

    /// Workaround: onRegenerateQuorums() is called from within the ctor,
    /// but LocalScheduler is not instantiated yet.
    private bool started;

    /// Ctor
    public this (Config config)
    {
        assert(config.validator.enabled);
        super(config);
        this.quorum_params = QuorumParams(this.params.MaxQuorumNodes,
            this.params.QuorumThreshold);

        auto vledger = cast(ValidatingLedger) this.ledger;
        assert(vledger !is null);
        this.nominator = this.makeNominator(
            this.clock, this.network, vledger, this.enroll_man, this.taskman);
        this.nominator.onInvalidNomination = &this.invalidNominationHandler;

        // Make sure our ValidatorSet has our pre-image
        // This is especially important on initialization, as replaying blocks
        // does not call `onAcceptedBlock`.
        PreImageInfo self;
        if (this.ledger.enrollment_manager.getNextPreimage(self, this.ledger.getBlockHeight()))
            this.ledger.addPreimage(self);

        // currently we are not saving preimage info,
        // we only have the commitment in the genesis block
        this.regenerateQuorums(this.ledger.getBlockHeight());
    }

    /***************************************************************************

        Called when the active validator set has changed after a block
        was externalized.

        Regenerates the quorum set config and updates the Nominator
        with the new quorum set.

        The background network discovery task will automatically attempt to
        find the Validator nodes in the quorum set configuration and connect
        to them.

        Params:
            height = the height at which the validator set changed.
                     Note that it may be different to 'ledger.getBlockHeight()'
                     when the node is booting up for the first time as we
                     currently only have commitment info from GenesisBlock,
                     and lack preimages.

    ***************************************************************************/

    private void regenerateQuorums (Height height) @safe
    {
        this.last_shuffle_height = height;
        this.required_peer_utxos = typeof(this.required_peer_utxos).init;

        // we're not enrolled and don't care about quorum sets
        if (!this.enroll_man.isEnrolled(height + 1, &this.utxo_set.peekUTXO))
        {
            this.nominator.stopNominatingTimer();
            this.qc = QuorumConfig.init;
            return;
        }

        // We get the enrollment key for this validator.
        auto this_utxo = this.enroll_man.getEnrollmentKey();

        Hash[] utxo_keys;
        // We add one to height as we are interested in enrolled at next block
        if (!this.enroll_man.getEnrolledUTXOs(height + 1, utxo_keys) ||
            utxo_keys.length == 0)
        {
            log.fatal("Could not retrieve enrollments / no enrollments found");
            assert(0);
        }

        // We create new SCP object if the enrollment key is changed.
        NodeID node_id = utxo_keys.countUntil(this_utxo);
        this.nominator.updateSCPObject(node_id);

        static QuorumConfig[NodeID] quorums;
        this.rebuildQuorumConfig(quorums, utxo_keys, height);
        this.qc = quorums[node_id];
        this.nominator.setQuorumConfig(node_id, quorums);
        buildRequiredKeys(this_utxo, this.qc, utxo_keys,
            &this.utxo_set.peekUTXO, this.required_peer_utxos);

        if (this.started)
            this.nominator.startNominatingTimer();
    }

    /***************************************************************************

        Generate the quorum configurations for all the actively enrolled
        validators, using their combined preimages to shuffle the quorums.

        Params:
            quorums = will contain the mapping of all quorum configs
            utxos = The UTXO hashes of all the validators
            height = current block height

    ***************************************************************************/

    private void rebuildQuorumConfig (ref QuorumConfig[NodeID]quorums,
        in Hash[] utxos, Height height) @safe
    {
        import std.algorithm;
        import std.array;

        // We take random seed from last block as next is not available yet
        // In the fast path, this is called immediately after a block has been
        // externalized, so we can simply use the Ledger. Otherwise we need
        // to run from storage.
        const rand_seed = this.ledger.getBlockHeight() == height ?
            this.ledger.getLastBlock().header.randomSeed() :
            this.ledger.getBlocksFrom(height).front.header.randomSeed();
        foreach (utxo; utxos)
        {
            const idx = utxos.countUntil(utxo);
            quorums[idx] = buildQuorumConfig(idx, utxos,
                this.utxo_set.getUTXOFinder(), rand_seed, this.quorum_params);
        }
    }

    /***************************************************************************

        Begins asynchronous tasks for node discovery and periodic catchup.

    ***************************************************************************/

    public override void start ()
    {
        this.started = true;
        // Note: Switching the next two lines leads to test failure
        // It should not, and this needs to be fixed eventually
        if (auto timer = this.network.startPeriodicNameRegistration())
            this.timers ~= timer;
        super.start();

        this.clock.startSyncing();
        this.timers ~= this.taskman.setTimer(
            this.config.validator.preimage_reveal_interval,
            &this.onPreImageRevealTimer, Periodic.Yes);

        this.timers ~= this.taskman.setTimer(
            this.config.validator.preimage_reveal_interval,
            &this.preImageCatchupTask, Periodic.Yes);

        if (this.enroll_man.isEnrolled(this.ledger.getBlockHeight() + 1, &this.utxo_set.peekUTXO))
            this.nominator.startNominatingTimer();
        if (this.config.validator.recurring_enrollment)
            this.checkAndEnroll(this.ledger.getBlockHeight());
    }

    /// Ditto
    protected override void discoveryTask ()
    {
        this.network.discover(this.registry, this.required_peer_utxos);
    }

    ///
    public override Identity handshake (in PublicKey peer)
    {
        return this.getPublicKey(peer);
    }

    /***************************************************************************

        Periodically retrieve pre-images if we are missing any.

    ***************************************************************************/

    protected void preImageCatchupTask () nothrow
    {
        import std.algorithm.mutation : remove;

        if (this.network.peers.empty())  // no clients yet (discovery)
            return;

        // Only query pre-images if we need them, to avoid flooding peers
        // with queries
        const next_height = this.ledger.getBlockHeight() + 1;

        if (!this.enroll_man.isEnrolled(next_height, &this.utxo_set.peekUTXO))
            return;

        // Currently using this hack as we know we hold a ValidatingLedger,
        // but we store it as a simple Ledger. A future refactor should get
        // rid of this cast.
        auto vledger = cast(ValidatingLedger) this.ledger;
        assert(vledger !is null);

        auto validators = () {
            try return this.ledger.getValidators(next_height);
            catch (Exception exc)
            {
                log.error("PreImage catchup task errored: {}", exc);
                return null;
            }
        }();
        if (!validators.length) return;

        auto missing = Set!Hash.from(
            validators.filter!(en => en.preimage.height < next_height)
            .map!(vi => vi.utxo));
        if (!missing.length)
            return;

        log.warn("Currently missing pre-images for next height ({}): {}",
                 next_height, missing);

        auto query = this.network.peers[]
            .map!(peer => peer.client.getPreimages(missing));

        foreach (preimages; query)
        {
            // FIXME: Since the above `getPreimages` request yield,
            // we may be waking up as the node is shutting down.
            // When that happens, the node nullify its fields for safety,
            // which leads to a SEGV. It's a very rare case in the wild,
            // but happens regularly in the test environment.
            // A foolproof solution would be to either interrupt the task,
            // or block until it returns. But the following `null` check
            // should be enough to catch most of the SEGV without major
            // effort on our asynchronous framework.
            if (this.ledger is null) return;

            preimages.each!((PreImageInfo pi) {
                if (this.ledger.addPreimage(pi))
                {
                    try this.pushPreImage(pi);
                    catch (Exception exc) {}

                    // We updated a pre-image, but it's still behind
                    if (pi.height < next_height)
                        return;
                    // Updated a pre-image, but not one of those that we were looking for
                    if (!missing.remove(pi.utxo))
                        return;

                    log.info("Caught up preimage: {}", prettify(pi));
                }
            });
            if (!missing.length)
                break;
        }
    }

    /// GET /public_key
    public override Identity getPublicKey (PublicKey key = PublicKey.init) nothrow @safe
    {
        import agora.flash.OnionPacket : generateSharedSecret;
        import libsodium.crypto_auth;

        this.recordReq("public_key");

        auto enroll_key = this.enroll_man.getEnrollmentKey();
        Identity id = Identity(this.config.validator.key_pair.address,
            enroll_key == Hash.init ? this.getFrozenUTXO() : enroll_key);
        if (key == PublicKey.init)
            return id;

        Hash shared_sec = generateSharedSecret(false,
            this.config.validator.key_pair.secret, key).hashFull();
        static assert(shared_sec.sizeof >= crypto_auth_KEYBYTES);

        id.mac.length = crypto_auth_BYTES;
        () @trusted { crypto_auth (id.mac.ptr, id.key[].ptr,
            id.key[].length, shared_sec[].ptr); } ();
        return id;
    }

    /***************************************************************************

        Store the block in the ledger if valid.
        If block is not yet signed by this node then sign it and also
        gossip the block sig from this node to other nodes.

        Params:
            block = block to be added to the Ledger

    ***************************************************************************/

    protected override string acceptBlock (in Block block) @trusted
    {
        import agora.common.BitMask;
        import std.algorithm;
        import std.range;
        import std.format;

        if (auto fail_msg = super.acceptBlock(block))
            return fail_msg;

        auto signed_validators = BitMask(block.header.validators.count);
        signed_validators.copyFrom(block.header.validators);

        const self_utxo = this.enroll_man.getEnrollmentKey();
        auto validators = this.ledger.getValidators(block.header.height);
        const ptrdiff_t node_validator_index = validators.countUntil!(v => v.utxo() == self_utxo);
        // It can be a block before this validator was enrolled
        if (node_validator_index < 0)
        {
            log.trace("This validator {} was not active at height {}",
                this.config.validator.key_pair.address, block.header.height);
            return format!"Validator %s was not active at height %s"
                (this.config.validator.key_pair.address, block.header.height);
        }

        const this_utxo = this.enroll_man.getEnrollmentKey();
        auto sig = this.nominator.signBlock(block);
        assert(node_validator_index < block.header.validators.count,
            format!"The validator index %s is invalid"(node_validator_index));
        if (signed_validators[node_validator_index])
        {
            log.trace("This node's signature is already in the block signature");
            // Gossip this signature as it may have been only shared via ballot signing
            this.network.gossipBlockSignature(
                ValidatorBlockSig(block.header.height, this_utxo, sig.R));
        }
        else
        {
            log.warn("This node's signature is not in the block signature. " ~
                "However, we will not sign in case we signed a different block " ~
                "at this height and could reveal our private key.");
        }
        return null;
    }

    /***************************************************************************

        Receive an SCP envelope.

        API:
            POST /envelope

        Params:
            envelope = the SCP envelope

    ***************************************************************************/

    public override void postEnvelope (SCPEnvelope envelope) @safe
    {
        this.recordReq("postEnvelope");
        this.nominator.receiveEnvelope(envelope);
    }

    /***************************************************************************

        Receive a block signature.

        API:
            POST /block_signature

        Params:
            block_sig = the block signature of a validator (part of multisig)

    ***************************************************************************/

    public override void postBlockSignature (ValidatorBlockSig block_sig) @safe
    {
        this.recordReq("postBlockSignature");
        this.nominator.receiveBlockSignature(block_sig);
    }

    /// Returns: The Logger to use for this class
    protected override Logger makeLogger ()
    {
        return Logger(this.config.validator.key_pair.address.toString());
    }

    /***************************************************************************

        Returns an instance of a Nominator.

        Test-suites can inject a badly-behaved nominator in order to
        simulate byzantine nodes.

        Params:
            clock = Clock instance
            network = the network manager for gossiping SCPEnvelopes
            ledger = Ledger instance
            enroll_man = Enrollment manager
            taskman = the task manager

        Returns:
            An instance of a `Nominator`

    ***************************************************************************/

    protected Nominator makeNominator (Clock clock, NetworkManager network,
        ValidatingLedger ledger, EnrollmentManager enroll_man, ITaskManager taskman)
    {
        return new Nominator(
            this.params, this.config.validator.key_pair, clock, network, ledger,
            enroll_man, taskman, this.cacheDB,
            this.config.validator.nomination_interval, &this.acceptBlock);
    }

    /***************************************************************************

        Returns an instance of a `ValidatingLedger`.

        Test-suites can inject different behaviour to enable testing.

        Returns:
            An instance of a `ValidatingLedger`

    ***************************************************************************/

    protected override ValidatingLedger makeLedger ()
    {
        return new ValidatingLedger(this.params, this.engine,
            this.utxo_set, this.storage, this.enroll_man, this.pool,
            this.stateDB, &this.onAcceptedBlock);
    }

    /***************************************************************************

        Get a Clock instance. May be overriden in unittests to
        simulate clock disparities, as well as provide a custom
        median retrieveal delegate to simulate delays (task.wait() calls).

        Params:
            taskman = task manager used to spawn timers

        Returns:
            a Clock instance

    ***************************************************************************/

    protected override Clock makeClock ()
    {
        return new Clock((out long time_offset)
            {
                return this.network.getNetTimeOffset(this.qc.threshold,
                    time_offset);
            },
            (Duration duration, void delegate() cb) nothrow @trusted
                { this.timers ~= this.taskman.setTimer(duration, cb, Periodic.Yes); });
    }

    /***************************************************************************

        Instantiate a new instance of the Admin interface

        This function needs to be called after the node is fully set-up.

    ***************************************************************************/

    public AdminInterface makeAdminInterface ()
    {
        return new AdminInterface(this.config.validator.key_pair, this.clock,
            this.enroll_man);
    }

    /***************************************************************************

        Calls the base class `onAcceptedBlock` and additionally
        shuffles the quorum set if the new block header height
        is `QuorumShuffleInterval` blocks newer than the last
        shuffle height.

        Params:
            block = the block which was added to the ledger

    ***************************************************************************/

    protected override void onAcceptedBlock (in Block block,
        bool validators_changed) @safe
    {
        assert(block.header.height >= this.last_shuffle_height);

        // block received either via externalize or getBlocksFrom(),
        // we need to cancel any existing nominating rounds.
        this.nominator.stopNominationRound(block.header.height);

        const need_shuffle = block.header.height >=
            (this.last_shuffle_height + this.params.QuorumShuffleInterval);

        // regenerate the quorums
        if (validators_changed || need_shuffle)
        {
            // Try to register immediately if we are a validator for the next cycle
            if (this.enroll_man.isEnrolled(block.header.height + 1, &this.utxo_set.peekUTXO))
                this.network.onRegisterName();
            this.regenerateQuorums(block.header.height);
        }

        // Re-enroll if our enrollment is about to expire and the block is recent enough
        auto cur_offset = this.clock.networkTime() - this.params.GenesisTimestamp;
        if (this.config.validator.recurring_enrollment &&
            block.header.time_offset > cur_offset - 3 * this.params.BlockInterval.total!"seconds")
            this.checkAndEnroll(block.header.height);

        // FIXME: Add our pre-image to the validator set so that `getValidators`
        // works as expected. This will need to be fixed in the Ledger in the
        // future, as `onPreImageRevealTimer` has some issues, but doing it here
        // allows us to unify usage of `getValidators`.
        PreImageInfo self;
        if (this.ledger.enrollment_manager.getNextPreimage(self, block.header.height))
            this.ledger.addPreimage(self);

        // note: may context switch, should be called last after quorums
        // are regenerated above.
        super.onAcceptedBlock(block, validators_changed);
    }

    /***************************************************************************

        Build the list of required quorum peers to connect to

        Supports recalling `sub_quorums` config structures.

        Params:
            filter_utxo = the UTXO to filter out (UTXO of the self node)
            quorum_conf = The SCP quorum set configuration
            utxos = The UTXO hashes of all the validators
            peekUTXO = An `UTXOFinder` without replay-protection
            nodes = Will contain the set of public keys to connect to

    ***************************************************************************/

    private static void buildRequiredKeys (in Hash filter_utxo,
        in QuorumConfig quorum_conf, in Hash[] utxos,
        scope UTXOFinder peekUTXO, ref UTXO[Hash] nodes)
        @safe nothrow
    {
        import std.algorithm;

        foreach (utxo; utxos.filter!(utxo => utxo != filter_utxo))
        {
            UTXO utxo_value;
            assert(peekUTXO(utxo, utxo_value));
            nodes[utxo] = utxo_value;
        }

        foreach (sub_conf; quorum_conf.quorums)
            buildRequiredKeys(filter_utxo, sub_conf, utxos, peekUTXO, nodes);
    }

    /***************************************************************************

        Periodically called to perform pre-images revelation.

        Increase the next reveal height by revelation period if necessary.

    ***************************************************************************/

    protected void onPreImageRevealTimer () @safe
    {
        PreImageInfo preimage;
        if (this.enroll_man.getNextPreimage(preimage,
            this.ledger.getBlockHeight()))
        {
            this.ledger.addPreimage(preimage);
            this.network.peers.each!(p => p.client.sendPreimage(preimage));
            this.pushPreImage(preimage);
        }
    }

    /***************************************************************************

        Calls the base class `shutdown` and store the latest SCP state

    ***************************************************************************/

    override void shutdown ()
    {
        super.shutdown();
        this.nominator.stopNominatingTimer();
        this.nominator.storeLatestState();
    }

    /***************************************************************************

        Check if the next enrollment is available or validator is not enrolled.
        Enroll when necessary.

        Params:
            height = Current block height

        Returns:
            The `Enrollment` used to enroll with, or `Enrollment.init`
            if not enrolled

    ***************************************************************************/

    protected Enrollment checkAndEnroll (Height height) @safe
    {
        auto next_height = height + 1;
        Hash enroll_key = this.enroll_man.getEnrolledUTXO(height,
            this.utxo_set.getUTXOFinder());

        if (enroll_key == Hash.init &&
            (enroll_key = this.getFrozenUTXO()) == Hash.init)
            return Enrollment.init; // Not enrolled and no frozen UTXO

        const enrolled = this.enroll_man.validator_set.getEnrolledHeight(next_height, enroll_key);

        // This validators enrollment will expire next cycle or not enrolled at all
        const avail_height = enrolled == ulong.max ?
                                next_height : enrolled + this.params.ValidatorCycle;

        if (avail_height > height + 2) // We are near the end of the cycle
            return Enrollment.init;
        const enrollment = this.enroll_man.createEnrollment(enroll_key, avail_height);
        log.trace("Sending Enrollment for enrolling {} at height {} (to validate blocks {} to {})",
            this.enroll_man.getEnrollmentPublicKey(), avail_height, avail_height + 1, avail_height + this.params.ValidatorCycle);
        this.enroll_man.enroll_pool.addValidated(enrollment, avail_height);
        this.network.peers.each!(p => p.client.sendEnrollment(enrollment));
        return enrollment;
    }

    /***************************************************************************

        Get a frozen UTXO owned by the Validator

        Return:
            Returns hash of a UTXO eligible for staking

    ***************************************************************************/

    private Hash getFrozenUTXO () @safe nothrow
    {
        const pub_key = this.config.validator.key_pair.address;
        foreach (utxo; this.utxo_set.getUTXOs(pub_key).byKeyValue)
        {
            if (utxo.value.output.type == OutputType.Freeze &&
                utxo.value.output.value.integral() >= Amount.MinFreezeAmount.integral())
                return utxo.key;
        }

        return Hash.init;
    }

    /***************************************************************************

        A delegate to be called by Nominator when node's own nomination is
        invalid

        Params:
            _ = Consensus data that triggered the error
            msg = Reason

    ***************************************************************************/

    protected void invalidNominationHandler (in ConsensusData _, in string msg)
        @safe
    {
        // Network needs Validators, see if we can enroll
        if (this.config.validator.recurring_enrollment &&
            msg == Ledger.InvalidConsensusDataReason.NotEnoughValidators)
            this.checkAndEnroll(this.ledger.getBlockHeight());
    }
}
