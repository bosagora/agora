/*******************************************************************************

    Implementation of the Validator API.

    Copyright:
        Copyright (c) 2019 - 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.Validator;

import agora.api.Validator;
import agora.common.Amount;
import agora.common.Config;
import agora.common.crypto.Key;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Params;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.ValidatorBlockSig;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.protocol.Nominator;
import agora.consensus.Quorum;
import agora.consensus.state.UTXODB;
import agora.consensus.protocol.Data;
import agora.crypto.Hash;
import agora.network.Clock;
import agora.network.NetworkManager;
import agora.node.admin.AdminInterface;
import agora.node.BlockStorage;
import agora.node.FullNode;
import agora.node.Ledger;
import agora.registry.NameRegistryAPI;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

import scpd.types.Stellar_SCP;

import std.algorithm : each;

import core.stdc.stdlib : abort;
import core.time;

mixin AddLogger!();

/*******************************************************************************

    Implementation of the Validator node

    This class implement the business code of the node.
    Communication with the other nodes is handled by the `Network` class.

*******************************************************************************/

public class Validator : FullNode, API
{
    /// Nominator instance
    protected Nominator nominator;

    /// The current required set of peer keeys to connect to
    protected Set!PublicKey required_peer_keys;

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

    /// admin interface
    protected AdminInterface admin_interface;

    /// Ctor
    public this (const Config config)
    {
        assert(config.validator.enabled);
        super(config);
        this.quorum_params = QuorumParams(this.params.MaxQuorumNodes,
            this.params.QuorumThreshold);

        this.nominator = this.getNominator(
            this.clock, this.network, this.ledger, this.enroll_man, this.taskman);
        this.nominator.onInvalidNomination = &this.invalidNominationHandler;

        // currently we are not saving preimage info,
        // we only have the commitment in the genesis block
        this.regenerateQuorums(this.ledger.getBlockHeight());

        this.admin_interface = new AdminInterface(config,
            this.config.validator.key_pair, this.clock);
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

    private void regenerateQuorums (Height height) nothrow @safe
    {
        this.last_shuffle_height = height;

        // we're not enrolled and don't care about quorum sets
        if (!this.enroll_man.isEnrolled(&this.utxo_set.peekUTXO))
        {
            this.nominator.stopNominatingTimer();
            this.qc = QuorumConfig.init;
            return;
        }

        static QuorumConfig[] other_qcs;
        this.rebuildQuorumConfig(this.qc, other_qcs, height);
        this.nominator.setQuorumConfig(this.qc, other_qcs);
        buildRequiredKeys(this.config.validator.key_pair.address, this.qc,
            this.required_peer_keys);

        if (this.started)
            this.nominator.startNominatingTimer();
    }

    /***************************************************************************

        Generate the quorum configuration for this node and all other validator
        nodes in the network, based on the blockchain state (enrollments).

        Params:
            qc = will contain the quorum configuration
            other_qcs = will contain the list of other nodes' quorum configs.

    ***************************************************************************/

    private void rebuildQuorumConfig (ref QuorumConfig qc,
        ref QuorumConfig[] other_qcs, Height height) nothrow @safe
    {
        import std.algorithm;

        Hash[] keys;
        if (!this.enroll_man.getEnrolledUTXOs(keys) || keys.length == 0)
        {
            log.fatal("Could not retrieve enrollments / no enrollments found");
            assert(0);
        }

        const rand_seed = this.enroll_man.getRandomSeed(keys, height);
        qc = buildQuorumConfig(this.config.validator.key_pair.address,
            keys, this.utxo_set.getUTXOFinder(), rand_seed,
            this.quorum_params);

        auto pub_keys = this.getEnrolledPublicKeys(keys);
        other_qcs.length = 0;
        () @trusted { assumeSafeAppend(other_qcs); }();

        foreach (pub_key; pub_keys.filter!(
            pk => pk != this.config.validator.key_pair.address))  // skip our own
        {
            other_qcs ~= buildQuorumConfig(pub_key, keys,
                this.utxo_set.getUTXOFinder(), rand_seed, this.quorum_params);
        }
    }

    /***************************************************************************

        Params:
            utxos = the list of enrolled utxos

        Returns:
            the list of all enrolled public keys

    ***************************************************************************/

    protected PublicKey[] getEnrolledPublicKeys (Hash[] utxos) @safe nothrow
    {
        PublicKey[] keys;
        auto finder = this.utxo_set.getUTXOFinder();
        foreach (utxo; utxos)
        {
            UTXO value;
            assert(finder(utxo, value));
            keys ~= value.output.address;
        }

        return keys;
    }

    /***************************************************************************

        Begins asynchronous tasks for node discovery and periodic catchup.

    ***************************************************************************/

    public override void start ()
    {
        this.started = true;
        this.network.startPeriodicNameRegistration();
        this.startPeriodicDiscovery();
        this.startStatsServer();
        this.clock.startSyncing();
        this.taskman.setTimer(this.config.validator.preimage_reveal_interval,
            &this.checkRevealPreimage, Periodic.Yes);
        this.startPeriodicCatchup();

        if (this.config.admin.enabled)
            this.admin_interface.start();

        if (this.enroll_man.isEnrolled(&this.utxo_set.peekUTXO))
            this.nominator.startNominatingTimer();
        if (this.config.validator.recurring_enrollment)
            this.checkAndEnroll(this.ledger.getBlockHeight());
    }

    /***************************************************************************

        Starts the periodic network discovery task.

    ***************************************************************************/

    private void startPeriodicDiscovery ()
    {
        this.taskman.runTask(
        ()
        {
            void discover () { this.network.discover(this.required_peer_keys); }
            discover();  // avoid delay
            this.taskman.setTimer(5.seconds, &discover, Periodic.Yes);
        });
    }

    /// GET /public_key
    public override PublicKey getPublicKey () pure nothrow @safe
    {
        endpoint_request_stats.increaseMetricBy!"agora_endpoint_calls_total"(
            1, "public_key", "http");
        return this.config.validator.key_pair.address;
    }

    /***************************************************************************

        Store the block in the ledger if valid.
        If block is not yet signed by this node then sign it and also
        gossip the block sig from this node to other nodes.

        Params:
            block = block to be added to the Ledger

    ***************************************************************************/

    protected override bool acceptBlock(const ref Block block) @trusted
    {
        import agora.common.BitField;
        import agora.crypto.Schnorr;
        import std.algorithm;
        import std.range;
        import std.format;

        if (auto err = this.ledger.validateBlock(block))
        {
            log.error("Block failed to validate: {}", err);
            // Maybe the block was already added to the ledger
            return this.ledger.getBlockHeight() >= block.header.height;
        }
        auto sig = this.nominator.createBlockSignature(block);
        auto multi_sig = Sig.fromBlob(block.header.signature);
        auto validators = this.enroll_man.getCountOfValidators(block.header.height);
        auto signed_validators = BitField!ubyte(validators);
        iota(0, validators).each!(i => signed_validators[i]= block.header.validators[i]);

        // Make sure the indexes are up to date
        this.nominator.enroll_man.updateValidatorIndexMaps(block.header.height);
        auto node_validator_index = this.nominator.enroll_man
            .getIndexOfValidator(block.header.height, this.nominator.schnorr_pair.V);

        // It can be a block before this validator was enrolled
        if (node_validator_index == ulong.max)
        {
            log.trace("This validator {} was not active at height {}",
                this.nominator.node_public_key, block.header.height);
            return this.ledger.acceptBlock(block);
        }
        assert(node_validator_index < validators, format!"The validator index %s is invalid"(node_validator_index));
        if (signed_validators[node_validator_index])
        {
            log.trace("This node's signature is already in the block signature");
            // Gossip this signature as it may have been only shared via ballot signing
            this.network.gossipBlockSignature(ValidatorBlockSig(block.header.height,
                this.nominator.node_public_key, sig.s));
        }
        else
        {
            signed_validators[node_validator_index] = true;
            this.network.gossipBlockSignature(ValidatorBlockSig(block.header.height,
                this.nominator.node_public_key, sig.s));
            log.trace("Periodic Catchup: ADD to block signature R: {} and s: {}",
                sig.R, sig.s.toString(PrintMode.Clear));
            const signed_block = block.updateSignature(
                multiSigCombine([ multi_sig, sig ]).toBlob(), signed_validators);
            return this.ledger.acceptBlock(signed_block);
        }
        return this.ledger.acceptBlock(block);
    }

    /***************************************************************************

        Receive an SCP envelope.

        API:
            PUT /envelope

        Params:
            envelope = the SCP envelope

    ***************************************************************************/

    public override void receiveEnvelope (SCPEnvelope envelope) @safe
    {
        endpoint_request_stats.increaseMetricBy!"agora_endpoint_calls_total"(
            1, "receive_envelope", "http");
        this.nominator.receiveEnvelope(envelope);
    }

    /***************************************************************************

        Receive a block signature.

        API:
            PUT /block_sig

        Params:
            block_sig = the block signature of a validator (part of multisig)

    ***************************************************************************/

    public override void receiveBlockSignature (ValidatorBlockSig block_sig) @safe
    {
        endpoint_request_stats.increaseMetricBy!"agora_endpoint_calls_total"(1, "receive_block_signature", "http");
        this.nominator.receiveBlockSignature(block_sig);
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

    protected Nominator getNominator (Clock clock, NetworkManager network,
        Ledger ledger, EnrollmentManager enroll_man, TaskManager taskman)
    {
        return new Nominator(
            this.params, this.config.validator.key_pair, clock, network, ledger,
            enroll_man, taskman, this.config.node.data_dir);
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

    protected override Clock getClock (TaskManager taskman)
    {
        return new Clock((out long time_offset)
            {
                // not enrolled - no need to synchronize clocks
                if (!this.enroll_man.isEnrolled(&this.utxo_set.peekUTXO))
                    return false;

                return this.network.getNetTimeOffset(this.qc.threshold,
                    time_offset);
            },
            (Duration duration, void delegate() cb) nothrow @trusted
                { this.taskman.setTimer(duration, cb, Periodic.Yes); });
    }

    /***************************************************************************

        Calls the base class `onAcceptedBlock` and additionally
        shuffles the quorum set if the new block header height
        is `QuorumShuffleInterval` blocks newer than the last
        shuffle height.

        Params:
            block = the block which was added to the ledger

    ***************************************************************************/

    protected final override void onAcceptedBlock (in Block block,
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
            this.regenerateQuorums(block.header.height);

        // Re-enroll if our enrollment is about to expire
        if (this.config.validator.recurring_enrollment)
            this.checkAndEnroll(block.header.height);

        // note: may context switch, should be called last after quorums
        // are regenerated above.
        super.onAcceptedBlock(block, validators_changed);
    }

    /***************************************************************************

        Build the list of required quorum peers to connect to

        Supports recalling `sub_quorums` config structures.

        Params:
            filter = the key to filter out (the self node)
            quorum_conf = The SCP quorum set configuration
            nodes = Will contain the set of public keys to connect to

    ***************************************************************************/

    private static void buildRequiredKeys (in PublicKey filter,
        in QuorumConfig quorum_conf, ref Set!PublicKey nodes) @safe nothrow
    {
        foreach (node; quorum_conf.nodes)
        {
            if (node != filter)
                nodes.put(node);
        }

        foreach (sub_conf; quorum_conf.quorums)
            buildRequiredKeys(filter, sub_conf, nodes);
    }

    /***************************************************************************

        Periodically check for pre-images revelation
        Increase the next reveal height by revelation period if necessary.

    ***************************************************************************/

    private void checkRevealPreimage () @safe
    {
        PreImageInfo preimage;
        if (this.enroll_man.getNextPreimage(preimage,
            this.ledger.getBlockHeight()))
        {
            this.enroll_man.addPreimage(preimage);
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
        this.nominator.storeLatestState();
        if (this.config.admin.enabled)
            this.admin_interface.stop();
    }

    /***************************************************************************

        Check if the current enrollment is about to expire or validator is not
        enrolled. Enroll when necessary.

        Params:
            block_height = Current block height

    ***************************************************************************/

    protected void checkAndEnroll (Height block_height) @safe
    {
        Hash enroll_key = this.enroll_man.getEnrolledUTXO(
            this.utxo_set.getUTXOFinder());

        if (enroll_key == Hash.init &&
            (enroll_key = this.getFrozenUTXO()) == Hash.init)
            return; // Not enrolled and no frozen UTXO

        const enrolled = this.enroll_man.getEnrolledHeight(enroll_key);

        // This validators enrollment will expire next cycle or not enrolled at all
        if (enrolled == ulong.max ||
            block_height + 1 >= enrolled + this.params.ValidatorCycle)
        {
            log.trace("Sending Enrollment at height {} for {} cycles with {}",
                block_height, this.params.ValidatorCycle, enroll_key);
            this.network.peers.each!(p => p.client.sendEnrollment(
                this.enroll_man.createEnrollment(enroll_key, block_height + 1)));
        }
    }

    /***************************************************************************

        Get a frozen UTXO owned by the Validator

        Return:
            Returns hash of a UTXO eligible for staking

    ***************************************************************************/

    private Hash getFrozenUTXO () @safe
    {
        const pub_key = this.getPublicKey();
        foreach (key, utxo; this.utxo_set.getUTXOs(pub_key))
        {
            if (utxo.type == TxType.Freeze &&
                utxo.output.value.integral() >= Amount.MinFreezeAmount.integral())
                return key;
        }

        return Hash.init;
    }

    /***************************************************************************

        A delegate to be called by Nominator when node's own nomination is
        invalid

        Params:
            data = Invalid ConsensusData
            msg = Reason

    ***************************************************************************/

    protected void invalidNominationHandler (in ConsensusData data, in string msg)
        @safe
    {
        // Network needs Validators, see if we can enroll
        if (this.config.validator.recurring_enrollment &&
            msg == Ledger.InvalidConsensusDataReason.NotEnoughValidators)
            this.checkAndEnroll(this.ledger.getBlockHeight());
    }
}
