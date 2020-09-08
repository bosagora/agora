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
import agora.network.NetworkManager;
import agora.node.BlockStorage;
import agora.node.FullNode;
import agora.node.Ledger;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

import scpd.types.Stellar_SCP;

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

    /// Ctor
    public this (const Config config)
    {
        assert(config.node.is_validator);
        super(config);
        this.quorum_params = QuorumParams(this.params.MaxQuorumNodes,
            this.params.QuorumThreshold);

        this.nominator = this.getNominator(this.network,
            this.config.node.key_pair, this.ledger, this.enroll_man,
            this.taskman);

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
        import std.algorithm : map;
        this.last_shuffle_height = height;

        // we're not enrolled and don't care about quorum sets
        if (!this.enroll_man.isEnrolled(this.utxo_set.getUTXOFinder()))
        {
            this.qc = QuorumConfig.init;
            return;
        }

        Hash[] keys;
        if (!this.enroll_man.getEnrolledUTXOs(keys) || keys.length == 0)
        {
            log.fatal("Could not retrieve enrollments / no enrollments found");
            assert(0);
        }

        static QuorumConfig[] other_qcs;
        this.rebuildQuorumConfig(this.qc, other_qcs, height);
        this.nominator.setQuorumConfig(this.qc, other_qcs);
        buildRequiredKeys(this.config.node.key_pair.address, this.qc,
            this.required_peer_keys);
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
        qc = buildQuorumConfig(this.config.node.key_pair.address,
            keys, this.utxo_set.getUTXOFinder(), rand_seed,
            this.quorum_params);

        auto pub_keys = this.getEnrolledPublicKeys(keys);
        other_qcs.length = 0;
        () @trusted { assumeSafeAppend(other_qcs); }();

        foreach (pub_key; pub_keys.filter!(
            pk => pk != this.config.node.key_pair.address))  // skip our own
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
        this.startPeriodicDiscovery();
        this.taskman.setTimer(this.config.node.preimage_reveal_interval,
            &this.checkRevealPreimage, Periodic.Yes);
        this.network.startPeriodicCatchup(this.ledger, &this.nominator.isNominating);
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
        return this.config.node.key_pair.address;
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
        // we're not enrolled and don't care about messages
        if (!this.enroll_man.isEnrolled(this.utxo_set.getUTXOFinder()))
            return;

        this.nominator.receiveEnvelope(envelope);
    }

    /***************************************************************************

        Returns an instance of a Nominator.

        Test-suites can inject a badly-behaved nominator in order to
        simulate byzantine nodes.

        Params:
            network = the network manager for gossiping SCPEnvelopes
            key_pair = the key pair of the node
            ledger = Ledger instance
            enroll_man = Enrollment manager
            taskman = the task manager

        Returns:
            An instance of a `Nominator`

    ***************************************************************************/

    protected Nominator getNominator (NetworkManager network, KeyPair key_pair,
        Ledger ledger, EnrollmentManager enroll_man, TaskManager taskman)
    {
        return new Nominator(network, key_pair, ledger, enroll_man, taskman);
    }

    /***************************************************************************

        Called when a transaction was accepted into the transaction pool.
        Currently, nomination is triggered by an inclusion of a new transaction
        in the transaction pool.
        In the future, this will be replaced with a nominating timer.

    ***************************************************************************/

    protected final override void onAcceptedTransaction () @safe
    {
        if (!this.enroll_man.isEnrolled(this.utxo_set.getUTXOFinder()))
            return;  // nothing to do, we're not an active validator

        // check if there's enough txs in the pool, and start nominating
        this.nominator.tryNominate();
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
}
