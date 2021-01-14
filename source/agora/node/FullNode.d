/*******************************************************************************

    Implementation of the full node's API.

    See `agora.api.Validator` for a full description of the differences between
    a full node and a validator.

    Dependency_injection:
      To make the code testable, this classes exposes a few functions which are
      used to perform dependency injection. Those functions all follow the same
      pattern: they are `protected`, and called `getXXX`.
      They can rely on both `this.config` and `this.params` fields being set.

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
import agora.api.handler.TransactionReceivedHandler;
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
import agora.node.TransactionPool;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.Fee;
import agora.consensus.state.UTXODB;
import agora.consensus.EnrollmentManager;
import agora.consensus.Fee;
import agora.network.Clock;
import agora.network.NetworkClient;
import agora.network.NetworkManager;
import agora.node.BlockStorage;
import agora.node.Ledger;
import agora.stats.App;
import agora.stats.EndpointReq;
import agora.stats.Server;
import agora.stats.Utils;
import agora.utils.Log;
import agora.utils.PrettyPrinter;
import agora.utils.Utility;

import scpd.types.Utils;

import vibe.core.core;
import vibe.data.json;
import vibe.http.router;
import vibe.http.server;
import vibe.web.rest;

import std.algorithm;
import std.conv : to;
import std.exception;
import std.file;
import std.path : buildPath;
import std.range;

import core.stdc.time;
import core.time;

mixin AddLogger!();

/// Maximum number of blocks that will be sent in a call to getBlocksFrom()
private enum uint MaxBatchBlocksSent = 20;

/// Maximum number of transactions that will be sent in a call to
/// getTransactionByHash
private enum uint MaxBatchTranscationsSent = 100;

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

    /// Stats server
    protected StatsServer stats_server;

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

    /// Transaction Received Handler list
    protected TransactionReceivedHandler[Address] transaction_handlers;

    /// Endpoint request stats
    protected EndpointRequestStats endpoint_request_stats;

    /// Application-wide stats
    protected ApplicationStats app_stats;

    /// The checker of transaction data payload
    protected FeeManager fee_man;

    /***************************************************************************

        Constructor

        Params:
            config = Config instance

    ***************************************************************************/

    public this (const Config config)
    {
        import TESTNET = agora.consensus.data.genesis.Test;
        import COINNET = agora.consensus.data.genesis.Coinnet;

        this.config = config;

        auto commons_budget = config.node.testing ?
            TESTNET.CommonsBudgetAddress : COINNET.CommonsBudgetAddress;
        this.params = new immutable(ConsensusParams)(
                config.node.testing ?
                    TESTNET.GenesisBlock : COINNET.GenesisBlock,
                commons_budget,
                config.consensus.validator_cycle,
                config.consensus.max_quorum_nodes,
                config.consensus.quorum_threshold,
                config.consensus.quorum_shuffle_interval,
                config.node.block_interval_sec,
                config.consensus.tx_payload_max_size,
                config.consensus.tx_payload_fee_factor,
                config.consensus.validator_tx_fee_cut,
                config.consensus.payout_period,
                config.consensus.slash_penalty_amount);

        this.taskman = this.getTaskManager();
        this.clock = this.getClock(this.taskman);
        this.metadata = this.getMetadata();
        this.network = this.getNetworkManager(this.metadata, this.taskman, this.clock);
        this.storage = this.getBlockStorage();
        this.pool = this.getPool();
        this.utxo_set = this.getUtxoSet();
        this.enroll_man = this.getEnrollmentManager();
        this.fee_man = this.getFeeManager();
        this.ledger = new Ledger(params, this.utxo_set,
            this.storage, this.enroll_man, this.pool, this.fee_man, this.clock,
            config.node.block_timestamp_tolerance, &this.onAcceptedBlock);
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

        Utils.getCollectorRegistry().addCollector(&this.collectAppStats);
        Utils.getCollectorRegistry().addCollector(&this.collectStats);
        enum build_version = import(VersionFileName);
        this.app_stats.setMetricTo!"agora_application_info"(
            1, // Unused, see article linked in the struct's documentationx
            build_version,
            __TIMESTAMP__, __VERSION__.to!string,
            config.validator.enabled
                ? config.validator.key_pair.address.toString() : null,
        );
    }

    mixin DefineCollectorForStats!("app_stats", "collectAppStats");
    mixin DefineCollectorForStats!("endpoint_request_stats", "collectStats");

    /***************************************************************************

        Begins asynchronous tasks for node discovery and periodic catchup.

    ***************************************************************************/

    public void start ()
    {
        this.startPeriodicDiscovery();
        this.startPeriodicCatchup();
        this.startStatsServer();
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

        Periodically retrieve the latest blocks and apply them to the
        provided ledger.

        Params:
            ledger = the Ledger to apply received blocks to

    ***************************************************************************/

    protected void startPeriodicCatchup ()
    {
        this.taskman.runTask(
        ()
        {
            void catchup ()
            {
                if (this.network.peers.empty())  // no clients yet (discovery)
                    return;

                this.network.getBlocksFrom(
                    Height(this.ledger.getBlockHeight() + 1),
                    // if any blocks fail validation => short-circuit
                    blocks => blocks.all!(block => this.acceptBlock(block)));
                this.network.getUnknownTXs(this.ledger);
            }
            catchup(); // avoid delay
            this.taskman.setTimer(this.network.node_config.block_catchup_interval, &catchup, Periodic.Yes);
        });
    }

    /***************************************************************************

        Function that is overriden in Validator to enable block signing during
            periodic catchup.

        Params:
            block = block to be added to the Ledger

    ***************************************************************************/

    protected bool acceptBlock(const ref Block block) @trusted
    {
        return this.ledger.acceptBlock(block);
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
        this.stopStatsServer();
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
        this.endpoint_request_stats
            .increaseMetricBy!"agora_endpoint_calls_total"(1, "node_info", "http");
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
        this.endpoint_request_stats
            .increaseMetricBy!"agora_endpoint_calls_total"(1, "transaction", "http");
        auto tx_hash = hashFull(tx);
        if (this.pool.hasTransactionHash(tx_hash))
            return;

        if (this.ledger.acceptTransaction(tx))
        {
            log.info("Accepted transaction: {} ({})", prettify(tx), tx_hash);
            this.network.gossipTransaction(tx);
            this.pushTransaction(tx);
        }
    }

    /// GET: /has_transaction_hash
    public override bool hasTransactionHash (Hash tx) @safe
    {
        this.endpoint_request_stats
            .increaseMetricBy!"agora_endpoint_calls_total"(
                1, "has_transaction_hash", "http");
        return this.pool.hasTransactionHash(tx);
    }

    /// GET: /block_height
    public override ulong getBlockHeight ()
    {
        this.endpoint_request_stats
            .increaseMetricBy!"agora_endpoint_calls_total"(1, "block_height", "http");
        return this.ledger.getBlockHeight();
    }

    /// GET: /blocks_from
    public override const(Block)[] getBlocksFrom (ulong block_height,
        uint max_blocks)  @safe
    {
        this.endpoint_request_stats
            .increaseMetricBy!"agora_endpoint_calls_total"(1, "blocks_from", "http");
        return this.ledger.getBlocksFrom(Height(block_height))
            .take(min(max_blocks, MaxBatchBlocksSent)).array;
    }

    /// Start the StatsServer
    public void startStatsServer ()
    {
        if (config.node.stats_listening_port != 0)
            this.stats_server = getStatsServer();
    }

    /// Stop the StatsServer
    public void stopStatsServer ()
    {
        if (this.stats_server !is null)
            this.stats_server.shutdown();
    }

    /// Returns a newly constructed StatsServer
    protected StatsServer getStatsServer ()
    {
        return new StatsServer(this.config.node.stats_listening_port);
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

    protected NetworkManager getNetworkManager (Metadata metadata,
        TaskManager taskman, Clock clock)
    {
        return new NetworkManager(this.config, metadata, taskman, clock);
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

        Returns:
            the transaction pool

    ***************************************************************************/

    protected TransactionPool getPool ()
    {
        return new TransactionPool(
            this.config.node.data_dir.buildPath("tx_pool.dat"));
    }

    /***************************************************************************

        Returns an instance of a UTXOSet

        Unittest code may override this method to provide a Utxo set
        that doesn't do any I/O.

        Returns:
            the UTXOSet instance

    ***************************************************************************/

    protected UTXOSet getUtxoSet ()
    {
        return new UTXOSet(this.config.node.data_dir.buildPath("utxo_set.dat"));
    }

    /***************************************************************************

        Returns an instance of a DataPayloadChecker

        Unittests can override this method.

        Returns:
            the DataPayloadChecker instance

    ***************************************************************************/

    protected FeeManager getFeeManager ()
    {
        return new FeeManager(
            this.config.node.data_dir.buildPath("fee_manager.dat"),
            this.params);
    }

    /***************************************************************************

        Reads the metadata from the provided disk path.

        Subclasses can override this method and return
        a Metadata object which loads/dumps data in memory
        rather than on disk, to avoid I/O (e.g. for unittesting)

        Returns:
            the metadata loaded from disk

    ***************************************************************************/

    protected Metadata getMetadata () @system
    {
        return new DiskMetadata(this.config.node.data_dir);
    }

    /***************************************************************************

        Returns an instance of a BlockStorage or MemoryStorage

        Returns:
            Returns instance of `MemoryStorage` if data_dir is empty,
            otherwise returns instance of `BlockStorage`

    ***************************************************************************/

    protected IBlockStorage getBlockStorage () @system
    {
        version (unittest)
        {
            return new MemBlockStorage();
        }
        else
        {
            return new BlockStorage(this.config.node.data_dir);
        }
    }

    /***************************************************************************

        Returns an instance of a EnrollmentManager

        Returns:
            the enrollment manager

    ***************************************************************************/

    protected EnrollmentManager getEnrollmentManager ()
    {
        return new EnrollmentManager(
            this.config.node.data_dir.buildPath("validator_set.dat"),
            this.config.validator.key_pair, this.params);
    }

    /// GET: /merkle_path
    public override Hash[] getMerklePath (ulong block_height, Hash hash) @safe
    {
        this.endpoint_request_stats.increaseMetricBy!"agora_endpoint_calls_total"(1, "merkle_path", "http");
        return this.ledger.getMerklePath(Height(block_height), hash);
    }

    /// PUT: /enroll_validator
    public override void enrollValidator (Enrollment enroll) @safe
    {
        this.endpoint_request_stats.increaseMetricBy!"agora_endpoint_calls_total"(1, "enroll_validator", "http");

        UTXO utxo;
        this.utxo_set.peekUTXO(enroll.utxo_key, utxo);
        if (this.enroll_man.addEnrollment(enroll, utxo.output.address,
            this.ledger.getBlockHeight(), this.utxo_set.getUTXOFinder()))
        {
            log.info("Accepted enrollment: {}", prettify(enroll));
            this.network.sendEnrollment(enroll);
        }
    }

    /// GET: /enrollment
    public override Enrollment getEnrollment (Hash enroll_hash) @safe
    {
        this.endpoint_request_stats.increaseMetricBy!"agora_endpoint_calls_total"(1, "enrollment", "http");
        return this.enroll_man.getEnrollment(enroll_hash);
    }

    /// PUT: /receive_preimage
    public override void receivePreimage (PreImageInfo preimage) @safe
    {
        this.endpoint_request_stats.increaseMetricBy!"agora_endpoint_calls_total"(1, "receive_preimage", "http");
        log.trace("Received Preimage: {}", prettify(preimage));

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
        this.endpoint_request_stats.increaseMetricBy!"agora_endpoint_calls_total"(1, "preimage", "http");
        return this.enroll_man.getValidatorPreimage(enroll_key);
    }

    /// GET /local_time
    public override time_t getLocalTime () @safe nothrow
    {
        this.endpoint_request_stats.increaseMetricBy!"agora_endpoint_calls_total"(1, "local_time", "http");
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

    /***************************************************************************

        Push the transaction to the `transaction_handlers` target server list
        set in config.

        Convert `Transaction` to JSON serialization and send it POST using Rest.

        Params:
            tx = Received `Transaction`

    ***************************************************************************/

    protected void pushTransaction (const Transaction tx) @safe
    {
        foreach (address, handler; this.transaction_handlers)
        {
            runTask({
                try
                {
                    handler.pushTransaction(tx);
                }
                catch (Exception e)
                {
                    log.error("Error sending transaction (tx hash: {}) to {} :{}",
                        hashFull(tx), address, e);
                }
            });
        }
    }

    /***************************************************************************

        Params:
            tx_hashes = A Set of Transaction hashes

        Returns:
            Transactions, if found in the pool, corresponding to the
            requested hashes

    ***************************************************************************/

    public Transaction[] getTransactions (Set!Hash tx_hashes) @safe
    {
        Transaction[] found_txs;
        foreach (hash; tx_hashes)
        {
            if (found_txs.length >= MaxBatchTranscationsSent)
                break;
            auto tx = this.pool.getTransactionByHash(hash);
            if (tx != Transaction.init)
                found_txs ~= tx;
        }
        return found_txs;
    }
}
