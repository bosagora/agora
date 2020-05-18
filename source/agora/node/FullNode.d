/*******************************************************************************

    Implementation of the FullNode's API.

    Copyright:
        Copyright (c) 2019 - 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.FullNode;

import agora.api.FullNode;
import agora.consensus.data.Block;
import agora.common.Amount;
import agora.common.BanManager;
import agora.common.Config;
import agora.common.Hash;
import agora.common.Metadata;
import agora.common.crypto.Key;
import agora.common.Serializer;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
import agora.common.TransactionPool;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXOSet;
import agora.consensus.EnrollmentManager;
import agora.consensus.Genesis;
import agora.network.NetworkClient;
import agora.network.NetworkManager;
import agora.node.BlockStorage;
import agora.node.Ledger;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

import scpd.types.Utils;

import vibe.core.core;
import vibe.data.json;
import vibe.http.router;
import vibe.http.server;
import vibe.web.rest;

import ocean.util.log.Logger;

import std.algorithm;
import std.exception;
import std.file;
import std.path : buildPath;
import std.range;

mixin AddLogger!();

/// Maximum number of blocks that will be sent in a call to getBlocksFrom()
private enum uint MaxBatchBlocksSent = 1000;

/*******************************************************************************

    Implementation of the FullNode API

    This class implements the business code of the FullNode.
    Communication with the other nodes is handled by the `Network` class.

*******************************************************************************/

public class FullNode : API
{
    /// Metadata instance
    protected Metadata metadata;

    /// Config instance
    protected const Config config;

    /// Task manager
    protected TaskManager taskman;

    /// Network of connected nodes
    protected NetworkManager network;

    /// Reusable exception object
    protected RestException exception;

    /// Transaction pool
    protected TransactionPool pool;

    /// Set of unspent transaction outputs
    protected UTXOSet utxo_set;

    ///
    protected Ledger ledger;

    /// Blockstorage
    protected IBlockStorage storage;

    /// Enrollment manager
    protected EnrollmentManager enroll_man;

    /// If a custom genesis block is set it will be stored here
    private immutable Block genesis_block;

    /***************************************************************************

        Constructor

        Params:
            config = Config instance

    ***************************************************************************/

    public this (const Config config)
    {
        // custom genesis block provided
        if (config.node.genesis_block.length > 0)
        {
            import std.array;
            import std.conv;

            // hex => bin
            auto block_bytes = config.node.genesis_block.chunks(2).map!(
                twoDigits => twoDigits.parse!ubyte(16)).array();
            this.genesis_block = block_bytes.deserializeFull!(immutable(Block));
            setGenesisBlock(&this.genesis_block);
        }

        this.metadata = this.getMetadata(config.node.data_dir);

        this.config = config;
        this.taskman = this.getTaskManager();
        this.network = this.getNetworkManager(config.node, config.banman,
            config.network, config.dns_seeds, this.metadata, this.taskman);
        this.storage = this.getBlockStorage(config.node.data_dir);
        this.pool = this.getPool(config.node.data_dir);
        scope (failure) this.pool.shutdown();
        this.utxo_set = this.getUtxoSet(config.node.data_dir);
        scope (failure) this.utxo_set.shutdown();
        this.enroll_man = this.getEnrollmentManager(config.node.data_dir, config.node);
        scope (failure) this.enroll_man.shutdown();
        this.ledger = this.getLedger(this.pool, this.utxo_set, this.storage, this.enroll_man, config.node);
        this.exception = new RestException(
            400, Json("The query was incorrect"), string.init, int.init);
    }

    /***************************************************************************

        Returns an instance of a Ledger

        Overridden in Validator to trigger quorum config changes after a new
        block is applied to the ledger.

        Params:
            pool = the transaction pool
            utxo_set = the set of unspent outputs
            storage = the block storage
            enroll_man = the enrollmentManager
            node_config = the node config

        Returns:
            an instance of a Ledger

    ***************************************************************************/

    protected Ledger getLedger (TransactionPool pool,
        UTXOSet utxo_set, IBlockStorage storage, EnrollmentManager enroll_man,
        NodeConfig node_config)
    {
        return new Ledger(pool, utxo_set, storage, enroll_man, node_config);
    }

    /// The first task method, loading from disk, node discovery, etc
    public void start ()
    {
        this.taskman.runTask(
        {
            log.info("Doing network discovery..");
            this.network.discover();
            this.network.startPeriodicCatchup(this.ledger);
        });
    }

    /***************************************************************************

        Called on node shutdown.

        Note that this is called explicitly before any destructors,
        to allow clean shutdown of e.g. databases, which may require
        GC allocations during the shutdown phase.

    ***************************************************************************/

    public void shutdown ()
    {
        log.info("Shutting down..");
        this.network.dumpMetadata();
        this.pool.shutdown();
        this.pool = null;
        this.utxo_set.shutdown();
        this.utxo_set = null;
        this.enroll_man.shutdown();
        this.enroll_man = null;
    }

    /// PUT /register_listener
    public override void registerListener (Address address) @trusted
    {
        this.network.registerListener(address);
    }

    /// GET: /node_info
    public override NodeInfo getNodeInfo () pure nothrow @safe @nogc
    {
        return this.network.getNetworkInfo();
    }

    /***************************************************************************

        Receive a transaction.

        API:
            PUT /transaction

        Params:
            tx = the received transaction

    ***************************************************************************/

    public override void putTransaction (Transaction tx) @safe
    {
        log.trace("Received Transaction: {}", prettify(tx));

        auto tx_hash = hashFull(tx);
        if (this.ledger.hasTransactionHash(tx_hash))
            return;

        if (this.ledger.acceptTransaction(tx))
        {
            // gossip first
            this.network.gossipTransaction(tx);
            this.onAcceptedTransaction();
        }

        if (this.enroll_man.needRevealPreimage(this.ledger.getBlockHeight()))
        {
            PreImageInfo preimage;
            if (this.enroll_man.getNextPreimage(preimage))
            {
                this.receivePreimage(preimage);
                this.enroll_man.increaseNextRevealHeight();
            }
        }
    }

    /// GET: /has_transaction_hash
    public override bool hasTransactionHash (Hash tx) @safe
    {
        return this.ledger.hasTransactionHash(tx);
    }

    /// GET: /block_height
    public override ulong getBlockHeight ()
    {
        return this.ledger.getBlockHeight();
    }

    /// GET: /blocks_from
    public override const(Block)[] getBlocksFrom (ulong block_height,
        uint max_blocks)  @safe
    {
        return this.ledger.getBlocksFrom(block_height)
            .take(min(max_blocks, MaxBatchBlocksSent)).array;
    }

    /***************************************************************************

        Returns an instance of a NetworkManager

        Unittests can override this method and return a custom NetworkManager.

        Params:
            node_config = the node config
            banman_conf = the ban manager config
            peers = the peers to connect to
            dns_seeds = the DNS seeds to retrieve peers from
            metadata = metadata containing known peers and other meta info
            taskman = task manager

        Returns:
            an instance of a NetworkManager

    ***************************************************************************/

    protected NetworkManager getNetworkManager (in NodeConfig node_config,
        in BanManager.Config banman_conf, in string[] peers,
        in string[] dns_seeds, Metadata metadata, TaskManager taskman)
    {
        return new NetworkManager(node_config, banman_conf, peers,
            dns_seeds, metadata, taskman);
    }

    /***************************************************************************

        Returns an instance of a TaskManager

        Subclasses can override this method and return
        a TaskManager backed by LocalRest.

        Returns:
            the task manager

    ***************************************************************************/

    protected TaskManager getTaskManager ()
    {
        return new TaskManager();
    }

    /***************************************************************************

        Returns an instance of a TransactionPool

        Subclasses can override this method and return
        a TransactionPool backed by an in-memory SQLite database.

        Params:
            data_dir = path to the data directory

        Returns:
            the transaction pool

    ***************************************************************************/

    protected TransactionPool getPool (string data_dir)
    {
        return new TransactionPool(buildPath(
            config.node.data_dir, "tx_pool.dat"));
    }

    /***************************************************************************

        Returns an instance of a UTXOSet

        Unittest code may override this method to provide a Utxo set
        that doesn't do any I/O.

        Params:
            data_dir = path to the data directory

        Returns:
            the UTXOSet instance

    ***************************************************************************/

    protected UTXOSet getUtxoSet (string data_dir)
    {
        return new UTXOSet(buildPath(config.node.data_dir, "utxo_set.dat"));
    }

    /***************************************************************************

        Reads the metadata from the provided disk path.

        Subclasses can override this method and return
        a Metadata object which loads/dumps data in memory
        rather than on disk, to avoid I/O (e.g. for unittesting)

        Note: not exposed in the API.

        Params:
            data_dir = path to the data directory

        Returns:
            the metadata loaded from disk

    ***************************************************************************/

    protected Metadata getMetadata (string data_dir) @system
    {
        return new DiskMetadata(data_dir);
    }

    /***************************************************************************

        Returns an instance of a BlockStorage or MemoryStorage

        Note: not exposed in the API.

        Params:
            data_dir = path to the blockdata directory

        Returns:
            Returns instance of `MemoryStorage` if data_dir is empty,
            otherwise returns instance of `BlockStorage`

    ***************************************************************************/

    protected IBlockStorage getBlockStorage (string data_dir) @system
    {
        version (unittest)
        {
            return new MemBlockStorage();
        }
        else
        {
            return new BlockStorage(data_dir);
        }
    }

    /***************************************************************************

        Returns an instance of a EnrollmentManager

        Params:
            data_dir = path to the data dirctory
            node_config = the node config

        Returns:
            the enrollment manager

    ***************************************************************************/

    protected EnrollmentManager getEnrollmentManager (string data_dir,
        in NodeConfig node_config)
    {
        return new EnrollmentManager(buildPath(data_dir, "validator_set.dat"),
            node_config.key_pair);
    }

    /// GET: /merkle_path
    public override Hash[] getMerklePath (ulong block_height, Hash hash) @safe
    {
        return this.ledger.getMerklePath(block_height, hash);
    }

    /// PUT: /enroll_validator
    public override void enrollValidator (Enrollment enroll) @safe
    {
        log.trace("Received Enrollment: {}", prettify(enroll));

        if (this.enroll_man.add(enroll, this.utxo_set.getUTXOFinder()))
        {
            this.network.sendEnrollment(enroll);
        }
    }

    /// GET: /enrollment
    public override Enrollment getEnrollment (Hash enroll_hash) @safe
    {
        Enrollment enroll;
        this.enroll_man.getEnrollment(enroll_hash, enroll);
        return enroll;
    }

    /// PUT: /receive_preimage
    public override void receivePreimage (PreImageInfo preimage) @safe
    {
        log.trace("Received Preimage: {}", prettify(preimage));

        if (this.enroll_man.addPreimage(preimage))
            this.network.sendPreimage(preimage);
    }

    /// GET: /preimage
    public override PreImageInfo getPreimage (Hash enroll_key)
    {
        PreImageInfo preimage;
        this.enroll_man.getValidatorPreimage(enroll_key, preimage);
        return preimage;
    }

    /***************************************************************************

        Called when a transaction was accepted into the transaction pool.
        This is a no-op for FullNode. A Validator node overrides this behavior.

    ***************************************************************************/

    protected void onAcceptedTransaction () @safe
    {
    }
}
