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
import agora.api.handler.BlockExternalizedHandler;
import agora.api.handler.PreImageReceivedHandler;
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
import agora.consensus.data.ConsensusParams;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.UTXOSet;
import agora.consensus.EnrollmentManager;
import agora.network.Clock;
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

import std.algorithm;
import std.exception;
import std.file;
import std.path : buildPath;
import std.range;

import core.stdc.time;
import core.time;

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

    /// Parameters for consensus-critical constants
    protected immutable(ConsensusParams) params;

    /// Task manager
    protected TaskManager taskman;

    /// Clock instance
    protected Clock clock;

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

    /// Block Externalized Handler list
    protected BlockExternalizedHandler[Address] block_handlers;

    /// PreImage Received Handler list
    protected PreImageReceivedHandler[Address] preimage_handlers;

    /***************************************************************************

        Constructor

        Params:
            config = Config instance

    ***************************************************************************/

    public this (const Config config)
    {
        import CNG = agora.consensus.data.genesis.Coinnet;

        auto commons_budget =
            config.node.commons_budget_address != PublicKey.init ?
            config.node.commons_budget_address : CNG.CommonsBudgetAddress;

        // custom genesis block provided
        if (config.node.genesis_block.length > 0)
        {
            import std.array;
            import std.conv;

            // hex => bin
            auto block_bytes = config.node.genesis_block.chunks(2).map!(
                twoDigits => twoDigits.parse!ubyte(16)).array();
            auto genesis_block = block_bytes.deserializeFull!(immutable(Block));
            this.params = new immutable(ConsensusParams)(
                genesis_block,
                commons_budget,
                config.node.validator_cycle,
                config.node.max_quorum_nodes,
                config.node.quorum_threshold,
                config.node.quorum_shuffle_interval,
                config.node.genesis_start_time,
                config.node.block_interval_sec);
        }
        else
            this.params = new immutable(ConsensusParams)(
                CNG.GenesisBlock,
                commons_budget,
                config.node.validator_cycle,
                config.node.max_quorum_nodes,
                config.node.quorum_threshold,
                config.node.quorum_shuffle_interval,
                config.node.genesis_start_time,
                config.node.block_interval_sec);

        this.metadata = this.getMetadata(config.node.data_dir);

        this.config = config;
        this.taskman = this.getTaskManager();
        this.clock = this.getClock(this.taskman);
        this.network = this.getNetworkManager(config, this.metadata, this.taskman, this.clock);
        this.storage = this.getBlockStorage(config.node.data_dir);
        this.pool = this.getPool(config.node.data_dir);
        this.utxo_set = this.getUtxoSet(config.node.data_dir);
        this.enroll_man = this.getEnrollmentManager(config.node.data_dir,
            config.validator, params);
        this.ledger = new Ledger(params, this.utxo_set,
            this.storage, this.enroll_man, this.pool, &this.onAcceptedBlock);
        this.exception = new RestException(
            400, Json("The query was incorrect"), string.init, int.init);

        // Make `BlockExternalizedHandler` from config
        foreach (address;
            config.event_handlers.block_externalized_handler_addresses)
            this.block_handlers[address] = this.network
                .getBlockExternalizedHandler(address);

        // Make `PreImageReceivedHandler` from config
        foreach (address;
            config.event_handlers.preimage_updated_handler_addresses)
            this.preimage_handlers[address] = this.network
                .getPreimageReceivedHandler(address);

        // Special case
        // Block externalized handler is set and push for Genesis block.
        if (this.block_handlers.length > 0 && this.getBlockHeight() == 0)
            this.pushBlock(this.params.Genesis);
    }

    /***************************************************************************

        Begins asynchronous tasks for node discovery and periodic catchup.

    ***************************************************************************/

    public void start ()
    {
        this.startPeriodicDiscovery();
        this.network.startPeriodicCatchup(this.ledger);
    }

    /***************************************************************************

        Starts the periodic network discovery task.

    ***************************************************************************/

    private void startPeriodicDiscovery ()
    {
        import core.time;

        this.taskman.runTask(
        ()
        {
            void discover () { this.network.discover(); }
            discover(); // avoid delay
            this.taskman.setTimer(5.seconds, &discover, Periodic.Yes);
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
        this.taskman.logStats();
        this.network.dumpMetadata();
        this.pool = null;
        this.utxo_set = null;
        this.enroll_man = null;
    }

    /***************************************************************************

        Register the given address as a listener for gossip / consensus messages.

        This register the given address into the `NetworkManager`.

        Params:
            address = the address of node to register

    ***************************************************************************/

    public void registerListener (Address address) @trusted
    {
        this.network.registerListener(address);
    }

    /// GET: /node_info
    public override NodeInfo getNodeInfo () pure nothrow @safe
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
        auto tx_hash = hashFull(tx);
        if (this.pool.hasTransactionHash(tx_hash))
            return;

        if (this.ledger.acceptTransaction(tx))
        {
            log.info("Accepted transaction: {} ({})", prettify(tx), tx_hash);
            this.network.gossipTransaction(tx);
        }
    }

    /// GET: /has_transaction_hash
    public override bool hasTransactionHash (Hash tx) @safe
    {
        return this.pool.hasTransactionHash(tx);
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
        return this.ledger.getBlocksFrom(Height(block_height))
            .take(min(max_blocks, MaxBatchBlocksSent)).array;
    }

 /***************************************************************************

        Returns an instance of a NetworkManager

        Unittests can override this method and return a custom NetworkManager.

        Params:
            node_config = the node config
            metadata = metadata containing known peers and other meta info
            taskman = task manager
            clock = clock instance

        Returns:
            an instance of a NetworkManager

    ***************************************************************************/

    protected NetworkManager getNetworkManager (in Config config,
        Metadata metadata, TaskManager taskman, Clock clock)
    {
        return new NetworkManager(config, metadata, taskman, clock);
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

        Returns an instance of a Clock
        May be overriden in unittests to allow test-adjusted clock times.

        Params:
            taskman = a TaskManager instance

        Returns:
            an instance of a Clock

    ***************************************************************************/

    protected Clock getClock (TaskManager taskman)
    {
        // non-synchronizing clock (for now)
        return new Clock(
            (out long time_offset) { return true; },
            (Duration duration, void delegate() cb) nothrow @trusted
                { this.taskman.setTimer(duration, cb, Periodic.Yes); });
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
            params = the consensus-critical constants

        Returns:
            the enrollment manager

    ***************************************************************************/

    protected EnrollmentManager getEnrollmentManager (string data_dir,
        in ValidatorConfig validator_config, immutable(ConsensusParams) params)
    {
        return new EnrollmentManager(buildPath(data_dir, "validator_set.dat"),
            validator_config.key_pair, params);
    }

    /// GET: /merkle_path
    public override Hash[] getMerklePath (ulong block_height, Hash hash) @safe
    {
        return this.ledger.getMerklePath(Height(block_height), hash);
    }

    /// PUT: /enroll_validator
    public override void enrollValidator (Enrollment enroll) @safe
    {
        if (this.enroll_man.addEnrollment(enroll, this.ledger.getBlockHeight(),
            this.utxo_set.getUTXOFinder()))
        {
            log.info("Accepted enrollment: {}", prettify(enroll));
            this.network.sendEnrollment(enroll);
        }
    }

    /// GET: /enrollment
    public override Enrollment getEnrollment (Hash enroll_hash) @safe
    {
        return this.enroll_man.getEnrollment(enroll_hash);
    }

    /// PUT: /receive_preimage
    public override void receivePreimage (PreImageInfo preimage) @safe
    {
        if (this.enroll_man.addPreimage(preimage))
        {
            log.info("Accepted preimage: {}", prettify(preimage));
            this.network.sendPreimage(preimage);
            this.pushPreImage(preimage);
        }
    }

    /// GET: /preimage
    public override PreImageInfo getPreimage (Hash enroll_key)
    {
        return this.enroll_man.getValidatorPreimage(enroll_key);
    }

    /// GET /local_time
    public override time_t getLocalTime () @safe nothrow
    {
        return this.clock.localTime();
    }

    /***************************************************************************

        Called when a block was externalized.

        Calls pushBlock(), but additionally the Validator overrides this
        and implements quorum shuffling.

        Params:
            block = the new block
            validators_changed = whether the validator set has changed

    ***************************************************************************/

    protected void onAcceptedBlock (const ref Block block,
        bool validators_changed) @safe
    {
        this.pushBlock(block);
    }

    /***************************************************************************

        Push the block data to the `block_handlers` target server list
        set in config.

        Convert block data to JSON serialization and send it POST using Rest.

        Params:
            block = externalized block data

    ***************************************************************************/

    private void pushBlock (const Block block) @safe
    {
        foreach (address, handler; this.block_handlers)
        {
            runTask({
                try
                {
                    handler.pushBlock(block);
                }
                catch (Exception e)
                {
                    log.error("Error sending block height #{} to {} :{}",
                        block.header.height, address, e);
                }
            });
        }
    }

    /***************************************************************************

        Push the preimage to the `preimage_handlers` target server list
        set in config.

        Convert `PreImageInfo` to JSON serialization and send it POST
        using Rest.

        Params:
            preImage = Received `PreImageInfo`

    ***************************************************************************/

    protected void pushPreImage (const PreImageInfo pre_image) @safe
    {
        foreach (address, handler; this.preimage_handlers)
        {
            runTask({
                try
                {
                    handler.pushPreImage(pre_image);
                }
                catch (Exception e)
                {
                    log.error("Error sending preImage (enroll_key: {}) to {} :{}",
                        pre_image.enroll_key, address, e);
                }
            });
        }
    }
}
