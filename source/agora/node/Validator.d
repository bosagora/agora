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
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
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

    /// The current quorum configuration (changes as active enrollments change)
    protected QuorumConfig qc;

    /// The current required set of peer keeys to connect to
    protected Set!PublicKey required_peer_keys;

    /// Ctor
    public this (const Config config)
    {
        assert(config.node.is_validator);
        super(config, &this.onValidatorsChanged);

        this.nominator = this.getNominator(this.network,
            this.config.node.key_pair, this.ledger, this.taskman);
        this.onValidatorsChanged();
    }

    /***************************************************************************

        Called when the active validator set has changed after a block
        was externalized.

        Regenerates the quorum set config and updates the Nominator
        with the new quorum set.

        The background network discovery task will automatically attempt to
        find the Validator nodes in the quorum set configuration and connect
        to them.

    ***************************************************************************/

    private void onValidatorsChanged () nothrow @trusted
    {
        try
        {
            this.qc = this.rebuildQuorumConfig();
            this.nominator.setQuorumConfig(this.qc);
            buildRequiredKeys(this.config.node.key_pair.address, this.qc,
                this.required_peer_keys);
        }
        catch (Exception ex)
        {
            log.fatal("onValidatorsChanged() failed: {}", ex);
            abort();
        }
    }

    /***************************************************************************

        Generate the quorum configuration for this node based on the
        blockchain state (enrollments).

        Returns:
            the generated quorum configuration

    ***************************************************************************/

    private QuorumConfig rebuildQuorumConfig ()
    {
        Hash[] keys;
        if (!this.enroll_man.getEnrolledUTXOs(keys) || keys.length == 0)
        {
            log.fatal("Could not retrieve enrollments / no enrollments found");
            assert(0);
        }

        return buildQuorumConfig(this.config.node.key_pair.address,
            keys, this.utxo_set.getUTXOFinder());
    }

    /***************************************************************************

        Begins asynchronous tasks for node discovery and periodic catchup.

    ***************************************************************************/

    public override void start ()
    {
        this.startPeriodicDiscovery();
        this.taskman.setTimer(10.seconds, &this.checkRevealPreimage, Periodic.Yes);
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
            taskman = the task manager

        Returns:
            An instance of a `Nominator`

    ***************************************************************************/

    protected Nominator getNominator (NetworkManager network, KeyPair key_pair,
        Ledger ledger, TaskManager taskman)
    {
        return new Nominator(network, key_pair, ledger, taskman);
    }

    /***************************************************************************
        Called when a transaction was accepted into the transaction pool.
        Currently, nomination is triggered by an inclusion of a new transaction
        in the transaction pool.
        In the future, this will be replaced with a nominating timer.
    ***************************************************************************/

    protected final override void onAcceptedTransaction () @safe
    {
        // check if there's enough txs in the pool, and start nominating
        this.nominator.tryNominate();
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
        in QuorumConfig quorum_conf, ref Set!PublicKey nodes) @safe
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
        if (!this.enroll_man.needRevealPreimage(this.ledger.getBlockHeight()))
            return;

        PreImageInfo preimage;
        if (this.enroll_man.getNextPreimage(preimage))
        {
            this.receivePreimage(preimage);
            this.enroll_man.increaseNextRevealHeight();
        }
    }
}
