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
import agora.consensus.data.UTXOSet;
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

import ocean.util.log.Logger;

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

    /// Ctor
    public this (const Config config)
    {
        assert(config.node.is_validator);
        super(config);

        // instantiating Nominator can fail if the quorum configuration
        // fails the checkSanity() test, and we must release resources.
        scope (failure)
        {
            this.pool.shutdown();
            this.utxo_set.shutdown();
            this.enroll_man.shutdown();
        }

        // build the list of required quorum peers to connect to
        auto qc = this.buildQuorumConfig();
        this.nominator = this.getNominator(this.network,
            this.config.node.key_pair, this.ledger, this.taskman, qc);
    }

    /***************************************************************************

        Generate the quorum configuration for this node based on the
        blockchain state (enrollments).

        Returns:
            the generated quorum configuration

    ***************************************************************************/

    private QuorumConfig buildQuorumConfig ()
    {
        Enrollment[] enrollments;
        if (!this.enroll_man.getValidators(enrollments))
            assert(0, "Could not retrieve enrollments!");  // should not happen

        if (enrollments.length == 0)
            assert(0, "No enrollments found!");  // should not happen

        return .buildQuorumConfig(this.config.node.key_pair.address,
            enrollments, this.utxo_set.getUTXOFinder());
    }

    /// The first task method, loading from disk, node discovery, etc
    public override void start ()
    {
        this.taskman.runTask(
        {
            // build the list of required quorum peers to connect to
            Set!PublicKey required_peer_keys;
            auto qc = this.buildQuorumConfig();
            buildRequiredKeys(this.config.node.key_pair.address, qc,
                required_peer_keys);

            log.info("Doing network discovery..");
            this.network.discover(required_peer_keys);
            this.network.startPeriodicCatchup(this.ledger, &this.nominator.isNominating);
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
            quorum_config = the SCP quorum set configuration

        Returns:
            An instance of a `Nominator`

    ***************************************************************************/

    protected Nominator getNominator (NetworkManager network, KeyPair key_pair,
        Ledger ledger, TaskManager taskman, in QuorumConfig quorum_config)
    {
        return new Nominator(network, key_pair, ledger, taskman, quorum_config);
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
}
