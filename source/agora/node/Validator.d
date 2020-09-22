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
import agora.common.Config;
import agora.common.Hash;
import agora.common.crypto.Key;
import agora.common.Set;
import agora.common.Task;
import agora.common.TransactionPool;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.ConsensusParams;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXOSetValue;
import agora.consensus.EnrollmentManager;
import agora.consensus.protocol.Nominator;
import agora.consensus.Quorum;
import agora.network.Clock;
import agora.network.NetworkManager;
import agora.node.BlockStorage;
import agora.node.FullNode;
import agora.node.Ledger;
import agora.registry.NameRegistryAPI;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

import scpd.types.Stellar_SCP;

import core.stdc.stdlib : abort;
import core.stdc.time;
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

    /// Ctor
    public this (const Config config)
    {
        assert(config.validator.enabled);
        super(config);
        this.quorum_params = QuorumParams(this.params.MaxQuorumNodes,
            this.params.QuorumThreshold);

        this.nominator = this.getNominator(this.params, this.clock,
            this.network, this.config.validator.key_pair, this.ledger, this.taskman,
            this.config.node.data_dir);

        // currently we are not saving preimage info,
        // we only have the commitment in the genesis block
        this.regenerateQuorums(Height(0));
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
        if (!this.enroll_man.isEnrolled(this.utxo_set.getUTXOFinder()))
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
            UTXOSetValue value;
            assert(finder(utxo, size_t.max, value));
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
        this.clock.startSyncing();
        this.taskman.setTimer(this.config.node.preimage_reveal_interval,
            &this.checkRevealPreimage, Periodic.Yes);
        this.network.startPeriodicCatchup(this.ledger);

        if (this.enroll_man.isEnrolled(this.utxo_set.getUTXOFinder()))
            this.nominator.startNominatingTimer();
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
    public override PublicKey getPublicKey () pure nothrow @safe @nogc
    {
        return this.config.validator.key_pair.address;
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
        this.nominator.receiveEnvelope(envelope);
    }

    /***************************************************************************

        Returns an instance of a Nominator.

        Test-suites can inject a badly-behaved nominator in order to
        simulate byzantine nodes.

        Params:
            params = consensus params
            clock = Clock instance
            network = the network manager for gossiping SCPEnvelopes
            key_pair = the key pair of the node
            ledger = Ledger instance
            taskman = the task manager
            data_dir = path to the data directory

        Returns:
            An instance of a `Nominator`

    ***************************************************************************/

    protected Nominator getNominator (immutable(ConsensusParams) params,
        Clock clock, NetworkManager network, KeyPair key_pair, Ledger ledger,
        TaskManager taskman, string data_dir)
    {
        return new Nominator(params, clock, network, key_pair, ledger, taskman,
            data_dir);
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
                if (!this.enroll_man.isEnrolled(this.utxo_set.getUTXOFinder()))
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

    protected final override void onAcceptedBlock (const ref Block block,
        bool validators_changed) @safe
    {
        super.onAcceptedBlock(block, validators_changed);

        // block received either via externalize or getBlocksFrom(),
        // we need to cancel any existing nominating rounds
        this.nominator.stopNominationRound(block.header.height);

        assert(block.header.height >= this.last_shuffle_height);

        const need_shuffle = block.header.height >=
            (this.last_shuffle_height + this.params.QuorumShuffleInterval);

        // regenerate the quorums
        if (validators_changed || need_shuffle)
            this.regenerateQuorums(block.header.height);
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
        if (this.enroll_man.getNextPreimage(preimage))
        {
            this.enroll_man.addPreimage(preimage);
            this.network.sendPreimage(preimage);
            this.pushPreImage(preimage);
            this.enroll_man.updateRevealDistance(this.ledger.getBlockHeight());
        }
    }

    /***************************************************************************

        Calls the base class `shutdown` and store the latest SCP state

    ***************************************************************************/

    override void shutdown ()
    {
        super.shutdown();
        this.nominator.storeLatestState();
    }
}
