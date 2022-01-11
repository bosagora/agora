/*******************************************************************************

    Implementation of the full node's API.

    See `agora.api.Validator` for a full description of the differences between
    a full node and a validator.

    Dependency_injection:
      To make the code testable, this classes exposes a few functions which are
      used to perform dependency injection. Those functions all follow the same
      pattern: they are `protected`, and called `makeXXX`.
      They can rely on both `this.config` and `this.params` fields being set.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.FullNode;

import agora.api.FullNode;
import agora.api.Handlers;
import agora.consensus.data.Block;
import agora.common.Amount;
import agora.common.BanManager;
import agora.common.ManagedDatabase;
import agora.common.Set;
import agora.common.VibeTask;
import agora.common.Types;
import agora.consensus.Fee;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.state.UTXOSet;
import agora.consensus.EnrollmentManager;
import agora.consensus.pool.Transaction;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.network.Client;
import agora.network.Clock;
import agora.network.Manager;
import agora.node.BlockStorage;
import agora.node.Config;
import agora.node.Registry;
import agora.consensus.Ledger;
import agora.node.TransactionRelayer;
import agora.script.Engine;
import agora.serialization.Serializer;
import agora.stats.App;
import agora.stats.Block;
import agora.stats.EndpointReq;
import agora.stats.Server;
import agora.stats.Tx;
import agora.stats.Utils;
import agora.stats.Validator;
import agora.utils.Backoff;
import agora.utils.Log;
import agora.utils.PrettyPrinter;
import agora.utils.Utility;

import vibe.data.json;
import vibe.web.rest;
import vibe.http.common;

import std.algorithm;
import std.conv : to, text;
import std.datetime.systime : StdClock = Clock, SysTime, unixTimeToStdTime;
import std.exception;
import std.file;
import std.format;
import std.path : buildPath;
import std.range;

import core.time;

/// Maximum number of blocks that will be sent in a call to getBlocksFrom()
private enum uint MaxBatchBlocksSent = 24;

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
    /// Logger instance
    protected Logger log;

    /// Config instance
    protected Config config;

    /// Parameters for consensus-critical constants
    protected immutable(ConsensusParams) params;

    /// Task manager
    protected ITaskManager taskman;

    /// Timer this node has started
    protected ITimer[] timers;

    /// Clock instance
    protected Clock clock;

    /// Network of connected nodes
    protected NetworkManager network;

    /// Transaction pool
    protected TransactionPool pool;

    /// The Ledger is the main class driving consensus
    protected NodeLedger ledger;

    /// Enrollment manager
    protected EnrollmentManager enroll_man;

    /// Set of unspent transaction outputs
    protected UTXOSet utxo_set;

    /// Script execution engine
    protected Engine engine;

    /// Transaction relayer
    protected TransactionRelayer transaction_relayer;

    /***************************************************************************

        Persistence-related fields

        The node implement persistence through 3 databases.

        The blockchain data is binary serialized in a custom format to the disk
        to allow disk space usage to be reduced, as some data can be pruned in
        the long run, and there's almost no overhead in the binary serializer.
        Deleting the blockchain data invalidates both state and cache DB.

        State data, which is derived from the blockchain, such as UTXO set and
        validator set, are stored in the `"state DB". The state DB can be
        removed, either by user action or if found corrupted or inconsistent
        with the blockchain data. In such an event, the Ledger would rebuild
        it from scratch using the blockchain data, an operation which might
        take some time dependening on the number of blocks.

        Cache data is transient data that the node can reasonably loose without
        compromising its role. This includes the pools (enrollments and txs),
        as well as any additional metadata, for example peer list.

    ***************************************************************************/

    protected IBlockStorage storage;

    /// Ditto
    protected ManagedDatabase stateDB;

    /// Ditto
    protected ManagedDatabase cacheDB;

    /***************************************************************************

        Stats-related fields

        Those fields are used to expose internal statistics about the node on
        an HTTP interface that is ultimately queried by a Prometheus server.
        They may be unused if the stats interface is not enabled in the config.

    ***************************************************************************/

    protected StatsServer stats_server;

    /// Ditto
    protected ApplicationStats app_stats;

    /// Ditto
    protected EndpointRequestStats endpoint_request_stats;

    /// Ditto
    private TxStats tx_stats;

    /// Ditto
    private BlockStats block_stats;

    /// Ditto
    private ValidatorPreimagesStats validator_preimages_stats;

    /// Ditto
    private ValidatorCountStats validator_count_stats;


    /***************************************************************************

        List of handlers for specific actions

        Contains network client to servers that are interested in a specific
        event, such as block externalization.
        Those fields are populated based on the `event_handlers` configuration
        section, with one sub-section per event type.

        See_Also:
          https://github.com/bosagora/stoa

    ***************************************************************************/

    protected HandlerInfo!(BlockExternalizedHandler)[] block_handlers;

    /// Ditto
    protected HandlerInfo!(BlockHeaderUpdatedHandler)[] block_header_handlers;

    /// Ditto
    protected HandlerInfo!(PreImageReceivedHandler)[] preimage_handlers;

    /// Ditto
    protected HandlerInfo!(TransactionReceivedHandler)[] transaction_handlers;

    /// Contains informations about handlers
    private static struct HandlerInfo (T)
    {
        /// The client itself
        public T client;

        /// Address corresponding to this client
        public Address address;

        /// Number of unsuccessful attempts
        public uint attempts;

        /// If set, the next time this handler should be tried
        public SysTime disabledUntil;

        ///
        public void onCompletion (Backoff backoff) @safe nothrow
        {
            if (backoff is null) // success
            {
                this.attempts = 0;
                this.disabledUntil = SysTime.init;
            }
            else
            {
                this.attempts++;
                this.disabledUntil = StdClock.currTime() +
                    backoff.getDelay(this.attempts).seconds();
            }
        }
    }

    /// Backoff algorithm
    protected Backoff backoff;

    /// Name registry, if enabled for this node
    protected NameRegistry registry;

    /// Used by `Runner`
    package NameRegistry getRegistry () @safe pure nothrow @nogc return
    {
        return this.registry;
    }

    /***************************************************************************

        Constructor

        Params:
            config = Config instance

    ***************************************************************************/

    public this (Config config)
    {
        import std.datetime.timezone: UTC;

        this.config = config;
        // Return value will be interpreted as seconds, so our base is 10 seconds
        // and a maximum wait time of 6 hours.
        this.backoff = new Backoff(10, /* 6 hours */ 60 * 60 * 6);
        setHashMagic(this.config.node.chain_id);
        this.log = this.makeLogger();
        this.params = FullNode.makeConsensusParams(config);

        this.stateDB = this.makeStateDB();
        this.cacheDB = this.makeCacheDB();
        this.taskman = this.makeTaskManager();
        this.clock = this.makeClock();
        this.network = this.makeNetworkManager(this.taskman, this.clock);
        this.storage = this.makeBlockStorage();
        this.utxo_set = this.makeUTXOSet();
        this.pool = this.makeTransactionPool();
        this.enroll_man = this.makeEnrollmentManager();
        const ulong StackMaxTotalSize = 16_384;
        const ulong StackMaxItemSize = 512;
        this.engine = new Engine(StackMaxTotalSize, StackMaxItemSize);
        this.ledger = this.makeLedger();
        // Note: Needs to be instantiated after `ledger` as it depends on it
        this.transaction_relayer = this.makeTransactionRelayer();

        Utils.getCollectorRegistry().addCollector(&this.collectAppStats);
        Utils.getCollectorRegistry().addCollector(&this.collectStats);
        Utils.getCollectorRegistry().addCollector(&this.collectTxStats);
        Utils.getCollectorRegistry().addCollector(&this.collectBlockStats);
        Utils.getCollectorRegistry().addCollector(&this.collectValidatorStats);

        enum build_version = import(VersionFileName);
        this.app_stats.setMetricTo!"agora_application_info"(
            1, // Unused, see article linked in the struct's documentationx
            build_version,
            __TIMESTAMP__, __VERSION__.to!string,
            config.validator.enabled
                ? config.validator.key_pair.address.toString() : null,
            SysTime(unixTimeToStdTime(this.params.GenesisTimestamp), UTC()).toISOString(),
            // Use second precision to simplify aggregation
            StdClock.currTime!(ClockType.second)(UTC()).toISOString(),
        );

        this.registry = new NameRegistry(config.node.realm, config.registry,
                                         this.ledger, this.cacheDB);
    }

    mixin DefineCollectorForStats!("app_stats", "collectAppStats");
    mixin DefineCollectorForStats!("endpoint_request_stats", "collectStats");

    /***************************************************************************

        Collect all ledger & mempool stats into the collector

        Params:
            collector = the Collector to collect the stats into

    ***************************************************************************/

    private void collectTxStats (Collector collector)
    {
        this.tx_stats.setMetricTo!"agora_transactions_poolsize_gauge"(
            this.pool.length());
        this.tx_stats.setMetricTo!"agora_transactions_amount_gauge"(
            this.getUnspentAmount(this.pool));
        foreach (stat; this.tx_stats.getStats())
            collector.collect(stat.value);
    }

    /// Stats helper: return the total unspent amount
    private ulong getUnspentAmount (TxRange) (ref TxRange transactions)
    {
        Amount tx_amount;
        foreach (const ref Transaction tx; transactions)
            getSumOutput(tx, tx_amount);
        return to!ulong(tx_amount.toString());
    }

    /***************************************************************************

        Collect block stats

        Params:
            collector = the Collector to collect the stats into

    ***************************************************************************/

    private void collectBlockStats (Collector collector)
    {
        this.block_stats.agora_block_height_counter = this.ledger.getBlockHeight();
        collector.collect(this.block_stats);
    }

    /***************************************************************************

        Collect all validator & preimage stats into the collector

        Params:
            collector = the Collector to collect the stats into

    ***************************************************************************/

    private void collectValidatorStats (Collector collector)
    {
        auto validators = this.ledger.getValidators(this.ledger.getBlockHeight() + 1);

        foreach (const ref val; validators)
            this.validator_preimages_stats.setMetricTo!"agora_preimages_counter"(
                val.preimage.height, val.address.toString());

        foreach (stat; this.validator_preimages_stats.getStats())
            collector.collect(stat.value, stat.label);
    }

    /// Helper for stats
    private void recordBlockStats (in Block block) @safe
    {
        const new_count = this.ledger.validatorCount(block.header.height + 1);
        this.block_stats.agora_block_enrollments_gauge = new_count;
        this.block_stats.agora_block_txs_amount_total += getUnspentAmount(block.txs);
        this.block_stats.agora_block_txs_total += block.txs.length;
        this.block_stats.agora_block_externalized_total += 1;
    }

    /// Convenience function to increase an endpoint stats
    protected void recordReq (string endpoint, uint weight = 1) scope
        @safe pure nothrow
    {
        this.endpoint_request_stats.increaseMetricBy!"agora_endpoint_calls_total"(
            weight, endpoint, "http");
    }

    /***************************************************************************

        Begins asynchronous tasks for node discovery and periodic catchup.

    ***************************************************************************/

    public void start ()
    {
        // If we have handlers defined in the config
        if (config.event_handlers.length > 0)
        {
            // Make `BlockExternalizedHandler`s from config
            config.event_handlers.filter!(h => h.type == HandlerType.BlockExternalized)
                .each!(handler => handler.addresses
                    .each!((string address) {
                        auto url = Address(address);
                        this.block_handlers ~= typeof(this.block_handlers[0])(
                            this.network.getBlockExternalizedHandler(url), url);
                    }));

            // Make `BlockHeaderUpdatedHandler`s from config
            config.event_handlers.filter!(h => h.type == HandlerType.BlockHeaderUpdated)
                .each!(handler => handler.addresses
                    .each!((string address) {
                        auto url = Address(address);
                        this.block_header_handlers ~= typeof(this.block_header_handlers[0])(
                            this.network.getBlockHeaderUpdatedHandler(url), url);
                    }));

            // Make `PreImageReceivedHandler`s from config
            config.event_handlers.filter!(h => h.type == HandlerType.PreimageReceived)
                .each!(handler => handler.addresses
                    .each!((string address) {
                        auto url = Address(address);
                        this.preimage_handlers ~= typeof(this.preimage_handlers[0])(
                            this.network.getPreImageReceivedHandler(url), url);
                    }));

            // Make `TransactionReceivedHandler`s from config
            config.event_handlers.filter!(h => h.type == HandlerType.TransactionReceived)
                .each!(handler => handler.addresses
                    .each!((string address) {
                        auto url = Address(address);
                        this.transaction_handlers ~= typeof(this.transaction_handlers[0])(
                            this.network.getTransactionReceivedHandler(url), url);
                    }));
        }

        if (config.node.stats_listening_port != 0)
            this.stats_server = this.makeStatsServer();
        this.transaction_relayer.start();

        // Special case
        // Block externalized handler is set and push for Genesis block.
        if (this.block_handlers.length > 0 && this.getBlockHeight() == 0)
            this.pushBlock(this.params.Genesis);

        this.timers ~= this.taskman.setTimer(
            this.config.node.network_discovery_interval, &this.discoveryTask, Periodic.Yes);
        this.timers ~= this.taskman.setTimer(
            this.config.node.block_catchup_interval, &this.catchupTask, Periodic.Yes);

        // Immediately run discovery to avoid delays at startup
        this.taskman.runTask(&this.discoveryTask);
    }

    /// Returns an already instantiated version of the BanManager
    /// (please also see `NetworkManager.getBanMananger()`)
    package BanManager getBanManager () @safe @nogc nothrow pure
    {
        return this.network.getBanManager();
    }

    /***************************************************************************

        Returns:
            the existing instance of the task manager

    ***************************************************************************/

    public ITaskManager getTaskManager () @safe @nogc nothrow pure
    {
        return this.taskman;
    }

    /***************************************************************************

        Returns:
            the existing instance of the network manager

    ***************************************************************************/

    public NetworkManager getNetworkManager () @safe @nogc nothrow pure
    {
        return this.network;
    }

    /***************************************************************************

        Returns:
            the existing instance of the execution engine

    ***************************************************************************/

    public Engine getEngine () @safe @nogc nothrow pure
    {
        return this.engine;
    }

    /***************************************************************************

        Periodically discovers new nodes in the network

    ***************************************************************************/

    protected void discoveryTask () nothrow
    {
        this.network.discover(this.registry, this.ledger.getEnrolledUTXOs());
    }

    /***************************************************************************

        Periodically retrieve the latest blocks and apply them to the
        provided ledger.

        Params:
            ledger = the Ledger to apply received blocks to

    ***************************************************************************/

    protected void catchupTask () nothrow
    {
        if (this.network.peers.empty())  // no clients yet (discovery)
            return;

        this.network.getBlocksFrom(
            Height(this.ledger.getBlockHeight() + 1),
            &this.addBlocks);
        this.network.getUnknownTXs(this.ledger);
        try
        {
            this.network.getMissingBlockSigs(this.ledger, &this.acceptHeader);
        }
        catch (Exception e)
        {
            log.error("Error sending updated block headers:{}", e);
        }
    }

    /***************************************************************************

        Push the header to upstream servers.

        For Validators this is overridden so that it also adds missing
        signatures it has stored.

        Params:
            header = the block header to distribute

    ***************************************************************************/

    protected void acceptHeader (const(BlockHeader) header) @safe
    {
        this.pushBlockHeader(header);
    }

    /***************************************************************************

        Add blocks to the ledger and add the related pre-images

        This is called by the periodic catch-up process.

        Params:
            blocks = the blocks to be added

        Returns:
            the last read block height, or 0 if none were accepted

    ***************************************************************************/

    private Height addBlocks (const(Block)[] blocks)
        @safe
    {
        foreach (const ref block; blocks)
        {
            // A block might have been externalized in the meantime,
            // so just skip older heights
            if (block.header.height <= this.ledger.getBlockHeight())
                continue;
            else if (auto fail_msg = this.acceptBlock(block))
            {
                log.trace("addBlocks failed during periodic catchup: {}", fail_msg);
                break;
            }
            this.recordBlockStats(block);
        }
        return this.ledger.getBlockHeight();
    }

    /***************************************************************************

        Add block to ledger and remove expired validators from network whitelist

        Params:
            block = block to be added to the Ledger

    ***************************************************************************/

    protected string acceptBlock (in Block block) @trusted
    {
        log.dbg("Fullnode.acceptBlock: height = {}", block.header.height);
        auto old_validators = this.ledger.getValidators(block.header.height);
        log.dbg("Fullnode.acceptBlock: old_validators = {}", old_validators);
        // Attempt to add block to the ledger (it may be there by other means)
        if (auto fail_msg = this.ledger.acceptBlock(block))
        {
            log.dbg("Fullnode.acceptBlock: failed to add block to ledger: {}", fail_msg);
            return fail_msg;
        }

        this.recordBlockStats(block);

        auto validators = this.ledger.getValidators(block.header.height + 1);
        log.dbg("Fullnode.acceptBlock: validators = {}", validators);
        auto expired = setDifference(
            old_validators.map!(vi => vi.utxo),
            validators.map!(vi => vi.utxo));

        log.dbg("Fullnode.acceptBlock: unwhitelist = {}", expired);
        expired.each!(utxo => this.network.unwhitelist(utxo));
        // Just whitelist them all to be sure, no need for `setDifference`
        log.dbg("Fullnode.acceptBlock: whitelist = {}", validators.map!(v => v.utxo));
        validators.each!(validator => this.network.whitelist(validator.utxo));

        // We return if height in ledger is reached for this block to prevent fetching again
        return this.ledger.getBlockHeight() >= block.header.height ? null
            : format!"Ledger is already at height %s"(block.header.height);
    }

    /***************************************************************************

        Called on node shutdown.

        Note that this is called explicitly before any destructors,
        to allow clean shutdown of e.g. databases, which may require
        GC allocations during the shutdown phase.

    ***************************************************************************/

    public void shutdown () @safe
    {
        log.info("Shutting down..");
        this.taskman.logStats();

        // The stats server is standalone, but accepts network
        // requests, hence why we shut it down early on.
        if (this.stats_server !is null)
            this.stats_server.shutdown();

        // Shut down our timers (discovery, catchup)
        foreach (timer; this.timers)
            timer.stop();
        this.timers = null;

        // The relayer depends on the NetworkManager and the pool,
        // so shut its timers down first.
        this.transaction_relayer.shutdown();
        version (none) this.transaction_relayer = null;

        // Now tear down the network
        this.network.shutdown();
        version (none) this.network = null;

        // If the teardown process is out of order / has race conditions,
        // one is likely to see segv thanks to those fields being `null`.
        // But a SEGV is better than memory corruption.
        version (none)
        {
            this.taskman = null;
            this.clock = null;
            this.pool = null;
            this.ledger = null;
            this.enroll_man = null;
            this.utxo_set = null;
            this.engine = null;

            // Finalized by `ManagedDatabase`
            this.storage = null;
            this.stateDB = null;
            this.cacheDB = null;

            this.block_handlers = null;
            this.block_header_handlers = null;
            this.preimage_handlers = null;
            this.transaction_handlers = null;
        }
    }

    /// Make a new instance of the consensus parameters based on the config
    public static makeConsensusParams (in Config config)
    {
        import TESTNET = agora.consensus.data.genesis.Test;
        import COINNET = agora.consensus.data.genesis.Coinnet;

        auto commons_budget = config.node.testing ?
            TESTNET.CommonsBudgetAddress : COINNET.CommonsBudgetAddress;

        immutable Genesis = () {
            if (!config.node.testing)
                return COINNET.GenesisBlock;
            if (!config.node.limit_test_validators)
                return TESTNET.GenesisBlock;

            immutable Block result = {
                header: {
                    merkle_root: TESTNET.GenesisBlock.header.merkle_root,
                    validators: typeof(BlockHeader.validators)(config.node.limit_test_validators),
                    enrollments: TESTNET.GenesisBlock.header.enrollments[0 .. config.node.limit_test_validators],
                },
                merkle_tree: TESTNET.GenesisBlock.merkle_tree,
                txs:         TESTNET.GenesisBlock.txs,
            };
            return result;
        }();

        return new immutable(ConsensusParams)(
                Genesis,
                commons_budget,
                config.consensus);
    }

    /// Returns a newly constructed StatsServer
    protected StatsServer makeStatsServer ()
    {
        return new StatsServer(this.config.node.stats_listening_port);
    }

    /// Returns: The Logger to use for this class
    protected Logger makeLogger ()
    {
        return Logger(__MODULE__);
    }

    /// Returns: A new instance of a `ManagedDatabase` to use as state DB
    protected ManagedDatabase makeStateDB ()
    {
        return new ManagedDatabase(this.config.node.data_dir.buildPath("state.db"));
    }

    /// Returns: A new instance of a `ManagedDatabase` to use as cache DB
    protected ManagedDatabase makeCacheDB ()
    {
        return new ManagedDatabase(this.config.node.data_dir.buildPath("cache.db"));
    }

    /***************************************************************************

        Returns an instance of a NetworkManager

        Unittests can override this method and return a custom NetworkManager.

        Params:
            node_config = the node config
            taskman = task manager
            clock = clock instance

        Returns:
            an instance of a NetworkManager

    ***************************************************************************/

    protected NetworkManager makeNetworkManager (ITaskManager taskman, Clock clock)
    {
        return new NetworkManager(this.config, this.cacheDB, taskman, clock, this);
    }

    protected TransactionRelayer makeTransactionRelayer ()
    {
        return new TransactionRelayerFeeImp(
            this.pool, this.config, &this.network.peers, this.taskman, this.clock,
            &this.ledger.getTxFeeRate);
    }

    /***************************************************************************

        Returns an instance of a TaskManager

        Subclasses can override this method and return
        a TaskManager backed by LocalRest.

        Returns:
            the task manager

    ***************************************************************************/

    protected ITaskManager makeTaskManager ()
    {
        return new VibeTaskManager();
    }

    /***************************************************************************

        Returns an instance of a Clock

        May be overriden in unittests to allow test-adjusted clock times.

        Returns:
            an instance of a Clock

    ***************************************************************************/

    protected Clock makeClock ()
    {
        // non-synchronizing clock (for now)
        return new Clock(
            (out long time_offset) { return true; },
            (Duration duration, void delegate() cb) nothrow @trusted
                { this.timers ~= this.taskman.setTimer(duration, cb, Periodic.Yes); });
    }

    /***************************************************************************

        Returns an instance of a TransactionPool

        Subclasses can override this method and return
        a TransactionPool backed by an in-memory SQLite database.

        Returns:
            the transaction pool

    ***************************************************************************/

    protected TransactionPool makeTransactionPool ()
    {
        return new TransactionPool(this.cacheDB, &getDoubleSpentSelector);
    }

    /***************************************************************************

        Returns an instance of a DoubleSpentSelector

        Subclasses can override this method and return
        a DoubleSpentSelector

        Returns:
            an instance of DoubleSpentSelector

    ***************************************************************************/

    protected size_t getDoubleSpentSelector (Transaction[] txs) nothrow @safe
    {
        return maxIndex!((a, b)
        {
            Amount rate_a;
            Amount rate_b;
            this.ledger.getTxFeeRate(a, rate_a);
            this.ledger.getTxFeeRate(b, rate_b);
            return rate_a < rate_b;
        }
        )(txs);
    }

    /***************************************************************************

        Returns an instance of a UTXOSet

        Unittest code may override this method to provide a Utxo set
        that doesn't do any I/O.

        Returns:
            the UTXOSet instance

    ***************************************************************************/

    protected UTXOSet makeUTXOSet ()
    {
        return new UTXOSet(this.stateDB);
    }

    /***************************************************************************

        Returns an instance of an `IBlockStorage`

        `IBlockStorage` is the object that handles the long-term storage
        of blocks. The base function returns an object that stores on disk,
        however derived classes may extend this to specify a different behavior.

        Returns:
            An instance of a `BlockStorage`

    ***************************************************************************/

    protected IBlockStorage makeBlockStorage () @system
    {
        return new BlockStorage(this.config.node.data_dir);
    }

    /***************************************************************************

        Returns an instance of a EnrollmentManager

        Returns:
            the enrollment manager

    ***************************************************************************/

    protected EnrollmentManager makeEnrollmentManager ()
    {
        return new EnrollmentManager(this.stateDB, this.cacheDB,
            this.config.validator, this.params);
    }

    /***************************************************************************

        Returns an instance of a Ledger to be used for a `Fullnode`.

        It is overridden in `Validator` and also Test-suites can inject
        different behaviour to enable testing.

        Returns:
            An instance of a `Ledger`

    ***************************************************************************/

    protected NodeLedger makeLedger ()
    {
        return new NodeLedger(params, this.engine, this.utxo_set, this.storage,
            this.enroll_man, this.pool, new FeeManager(this.stateDB, this.params),
            &this.onAcceptedBlock);
    }

    /*+*************************************************************************
    *                        FullNode API implementation                       *
    * The following methods are implementation of the API, which is exposed by *
    * our network interface generator (Vibe.d, Localrest) to expose interfaces.*
    * The network code generator will take care of the (de) marshalling of the *
    * parameter and the return value, so those methods can focus on            *
    * the business code.                                                       *
    ***************************************************************************/

    ///
    public override Identity handshake (in PublicKey peer)
    {
        return Identity.init;
    }

    /// GET: /node_info
    public override NodeInfo getNodeInfo () nothrow @safe
    {
        this.recordReq("node_info");
        return this.network.getNetworkInfo();
    }

    /***************************************************************************

        Receive a transaction.

        API:
            POST /transaction

        Params:
            tx = the received transaction

    ***************************************************************************/

    public override TransactionResult postTransaction (in Transaction tx) @safe
    {
        this.recordReq("transaction");
        this.tx_stats.increaseMetricBy!"agora_transactions_received_total"(1);

        // return early if we already have this tx
        if (this.hasTransactionHash(hashFull(tx)))
        {
            this.tx_stats.increaseMetricBy!"agora_transactions_duplicate_total"(1);
            return TransactionResult(TransactionResult.Status.Duplicated);
        }

        if (auto reason = this.ledger.acceptTransaction(tx, config.node.double_spent_threshold_pct,
            config.node.min_fee_pct))
        {
            this.log.info("Rejected tx: {}, txHash: {}, Reason: {}.", prettify(tx), hashFull(tx), reason);
            this.tx_stats.increaseMetricBy!"agora_transactions_rejected_total"(1);
            return TransactionResult(TransactionResult.Status.Rejected, reason);
        }

        log.info("Accepted tx: {}, txHash: {}", prettify(tx), hashFull(tx));
        this.tx_stats.increaseMetricBy!"agora_transactions_accepted_total"(1);
        this.transaction_relayer.addTransaction(tx);
        this.pushTransaction(tx);

        return TransactionResult(TransactionResult.Status.Accepted);
    }

    /// GET: /has_transaction_hash
    public override bool hasTransactionHash (in Hash tx) @safe
    {
        this.recordReq("has_transaction_hash");
        return this.pool.hasTransactionHash(tx);
    }

    /// GET: /block_height
    public override ulong getBlockHeight ()
    {
        this.recordReq("block_height");
        return this.ledger.getBlockHeight();
    }

    /// GET: /blocks_from
    public override const(Block)[] getBlocksFrom (ulong height,
        uint max_blocks)  @safe
    {
        this.recordReq("blocks_from");
        return this.ledger.getBlocksFrom(Height(height))
            .take(min(max_blocks, MaxBatchBlocksSent)).array;
    }

    /// GET: /blocks/:height
    public override const(Block) getBlock (ulong height)  @safe
    {
        this.recordReq("blocks");

        auto blocks = this.ledger.getBlocksFrom(Height(height));
        if (blocks.empty)
            throw new HTTPStatusException(400, "No block at requested height");
        return blocks.front();
    }

    /// GET: /merkle_path
    public override Hash[] getMerklePath (ulong height, in Hash hash) @safe
    {
        this.recordReq("merkle_path");

        const Height stored_height = Height(height);

        if (this.ledger.getBlockHeight() < stored_height)
            return null;

        Block block = this.storage.readBlock(stored_height);
        size_t index = block.findHashIndex(hash);
        if (index >= block.txs.length)
            return null;
        return block.getMerklePath(index);
    }

    /// POST /enrollment
    public override void postEnrollment (in Enrollment enroll, in Height avail_height) @safe
    {
        this.recordReq("postEnrollment");

        // Ignore enrollments targeting a previous Height
        if (avail_height <= this.ledger.getBlockHeight())
        {
            log.trace("Ignoring enrollment {} targeting a previous Height {}", prettify(enroll), avail_height);
            return;
        }

        UTXO utxo;
        Output found_output;
        scope UTXOFinder utxo_finder;
        scope GetPenaltyDeposit getPenaltyDeposit;
        if (this.utxo_set.peekUTXO(enroll.utxo_key, utxo))
        {
            utxo_finder = (in Hash hash, out UTXO found_utxo)
            {
                if (hash == enroll.utxo_key)
                {
                    found_utxo = utxo;
                    return true;
                }
                return false;
            };
            getPenaltyDeposit = &this.ledger.getPenaltyDeposit;
        }
        else
        {
            /// FIXME: Use a proper type and sensible memory allocation pattern
            // We create a extra UTXO set using the transaction pool if there
            // is no UTXO in the UTXO set. We only use transactions that have
            // a frozen UTXO with the right amount.
            version (all)
            {
                foreach (ref Hash hash, ref Transaction tx; this.pool)
                {
                    if (!tx.isFreeze())
                        continue;

                    foreach (size_t idx, output_; tx.outputs)
                    {
                        if (output_.type == OutputType.Freeze &&
                            output_.value >= Amount.MinFreezeAmount)
                        {
                            if (UTXO.getHash(hashFull(tx), idx) == enroll.utxo_key)
                            {
                                found_output = output_;
                                utxo_finder = (in Hash hash, out UTXO found_utxo)
                                {
                                    if (hash == enroll.utxo_key)
                                    {
                                        found_utxo.output = found_output;
                                        return true;
                                    }
                                    return false;
                                };
                                getPenaltyDeposit = (Hash utxo) { return this.params.SlashPenaltyAmount; };
                                break;
                            }
                        }
                    }

                    if (utxo_finder(enroll.utxo_key, utxo))
                        break;
                }
            }
        }

        if (utxo == UTXO.init)
        {
            log.info("Found no UTXO for the enrollment: {}", prettify(enroll));
            return;
        }

        const utxo_address = utxo.output.address;
        if (this.enroll_man.addEnrollment(enroll, utxo_address,
            avail_height, utxo_finder, getPenaltyDeposit))
        {
            log.info("Accepted enrollment: {}", prettify(enroll));
            this.network.peers.each!(p => p.client.sendEnrollment(enroll, avail_height));
        }
    }

    /// GET: /enrollment
    public override Enrollment getEnrollment (in Hash enroll_hash) @safe
    {
        this.recordReq("getEnrollment");
        return this.enroll_man.getEnrollment(enroll_hash);
    }

    /// POST /preimage
    public override void postPreimage (in PreImageInfo preimage) @safe
    {
        this.recordReq("postPreimage");
        log.trace("Received Preimage: {}", prettify(preimage));

        if (this.ledger.addPreimage(preimage))
        {
            log.info("Accepted preimage: {}", prettify(preimage));
            this.network.peers.each!(p => p.client.sendPreimage(preimage));
            this.pushPreImage(preimage);
        }
    }

    /// GET: /preimages
    public override PreImageInfo[] getPreimages (Set!Hash enroll_keys = Set!Hash.init) @safe
    {
        this.recordReq("preimages");

        // if enroll_keys is empty, then all preimages should be returned
        if (enroll_keys.empty())
            return this.ledger.getValidators(this.ledger.getBlockHeight() + 1)
                .map!(vi => vi.preimage).array();


        PreImageInfo[] preimage_infos;
        foreach (const enroll_key; enroll_keys)
        {
            auto preimage_info = this.enroll_man.getValidatorPreimage(enroll_key);
            if (preimage_info != PreImageInfo.init)
                preimage_infos ~= preimage_info;
        }

        return preimage_infos;
    }

    /// GET: /preimages_from
    public override PreImageInfo[] getPreimagesFrom (ulong start_height)
        @safe nothrow
    {
        this.recordReq("preimages_range");

        const known = this.ledger.getBlockHeight();
        // We have no data that could match this query
        if (known < start_height)
            return null;

        return this.enroll_man.getValidatorPreimages(Height(start_height))
            .array();
    }

    /// GET /local_time
    public override TimePoint getLocalTime () @safe nothrow
    {
        this.recordReq("local_time");
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

    protected void onAcceptedBlock (in Block block, bool validators_changed)
        @safe
    {
        this.pushBlock(block);
        if (this.registry)
            this.registry.onAcceptedBlock(block, validators_changed);
    }

    /***************************************************************************

        Push the block data to the `block_handlers` target server list
        set in config.

        Convert block data to JSON serialization and send it POST using Rest.

        Params:
            block = externalized block data

    ***************************************************************************/

    private void pushBlock (const Block block) @trusted
    {
        const now = StdClock.currTime();
        foreach (index, ref handler; this.block_handlers)
        {
            if (handler.disabledUntil > now)
                continue;

            this.taskman.runTask({
                // Work around potential DMD bug
                const idx = index;
                try
                {
                    this.block_handlers[idx].client.pushBlock(block);
                    this.block_handlers[idx].onCompletion(null);
                }
                catch (Exception e)
                {
                    log.error("Error sending block height #{} to {} :{}",
                        block.header.height, this.block_handlers[idx].address, e);
                    this.block_handlers[idx].onCompletion(this.backoff);
                }
            });
        }
    }

    /***************************************************************************

        Push an updated block header to the `blockheader_handlers` target server
        list set in config.
        The blockheader can have signatures from validators added even after the
        block has been externalized.

        Convert block header data to JSON serialization and send it POST using
        Rest.

        Params:
            header = updated block header data

    ***************************************************************************/

    protected void pushBlockHeader (const BlockHeader header) @trusted
    {
        const now = StdClock.currTime();
        foreach (index, ref handler; this.block_header_handlers)
        {
            if (handler.disabledUntil > now)
                continue;

            this.taskman.runTask({
                // Work around potential DMD bug
                const idx = index;
                try
                {
                    this.block_header_handlers[idx].client.pushBlockHeader(header);
                    this.block_header_handlers[idx].onCompletion(null);
                }
                catch (Exception e)
                {
                    log.error("Error sending block header at height #{} to {} :{}",
                        header.height, this.block_header_handlers[idx].address, e);
                    this.block_header_handlers[idx].onCompletion(this.backoff);
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

    protected void pushPreImage (const PreImageInfo pre_image) @trusted
    {
        const now = StdClock.currTime();
        foreach (index, ref handler; this.preimage_handlers)
        {
            if (handler.disabledUntil > now)
                continue;

            this.taskman.runTask({
                // Work around potential DMD bug
                const idx = index;
                try
                {
                    this.preimage_handlers[idx].client.pushPreImage(pre_image);
                    this.preimage_handlers[idx].onCompletion(null);
                }
                catch (Exception e)
                {
                    log.error("Error sending preImage (enroll_key: {}) to {} :{}",
                        pre_image.utxo, this.preimage_handlers[idx].address, e);
                    this.preimage_handlers[idx].onCompletion(this.backoff);
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

    protected void pushTransaction (const Transaction tx) @trusted
    {
        const now = StdClock.currTime();
        foreach (index, ref handler; this.transaction_handlers)
        {
            if (handler.disabledUntil > now)
                continue;

            this.taskman.runTask({
                // Work around potential DMD bug
                const idx = index;
                try
                {
                    this.transaction_handlers[idx].client.pushTransaction(tx);
                    this.transaction_handlers[idx].onCompletion(null);
                }
                catch (Exception e)
                {
                    log.error("Error sending transaction (tx hash: {}) to {} :{}",
                        hashFull(tx), this.transaction_handlers[idx].address, e);
                    this.transaction_handlers[idx].onCompletion(this.backoff);
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
        log.trace("FullNode.getTransactions: called for {} txs", tx_hashes.length);
        this.recordReq("transactions");

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

    /***************************************************************************

         Params:
             from = starting hash

         Returns:
             Transactions in the pool that have a larger hash value

     ***************************************************************************/

    public Transaction[] getTransactions (Hash from) @safe
    {
        return this.pool.getFrom(from);
    }

    /***************************************************************************

        Params:
            heights = Set of block Heights to return header for

        Returns:
            BlockHeader if the client has that block

    ***************************************************************************/

    public BlockHeader[] getBlockHeaders (Set!ulong heights) @safe
    {
        import std.algorithm: min;
        import std.conv;

        this.recordReq("block_headers");
        BlockHeader[] headers;
        if (!heights.empty)
        {
            foreach (block; this.ledger.getBlocksFrom(Height(heights[].minElement)))
            {
                if (block.header.height in heights)
                    headers ~= block.header;
            }
        }
        return headers;
    }

    ///
    public ValidatorInfo[] getValidators (ulong height)
    {
        this.recordReq("validators");
        return this.ledger.getValidators(Height(height), true);
    }

    ///
    public ValidatorInfo[] getValidators ()
    {
        return this.getValidators(this.ledger.getBlockHeight());
    }
}
