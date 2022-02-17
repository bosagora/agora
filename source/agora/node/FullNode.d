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
import agora.consensus.BlockStorage;
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
import agora.network.VibeManager;
import agora.node.Config;
import agora.node.Registry;
import agora.consensus.Ledger;
import agora.node.TransactionRelayer;
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

    /// Node is shutting down
    protected bool is_shutting_down;

    /// Config instance
    protected Config config;

    /// Parameters for consensus-critical constants
    protected immutable(ConsensusParams) params;

    /// Task manager
    protected ITaskManager taskman;

    ///
    protected enum TimersIdx
    {
        Discovery,
        BlockCatchup,
        ClockTick,
    }

    /// Timers this node has started
    protected ITimer[int] timers;

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
        public void onCompletion (bool needBackoff) @safe nothrow
        {
            if (!needBackoff) // success
            {
                this.attempts = 0;
                this.disabledUntil = SysTime.init;
            }
            else
            {
                this.attempts++;
                // Return value will be interpreted as seconds, so our base is 10 seconds
                // and a maximum wait time of 6 hours.
                this.disabledUntil = StdClock.currTime() +
                    getDelay(this.attempts, 10, /* 6 hours */ 60 * 60 * 6).seconds();
            }
        }
    }

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
        setHashMagic(this.config.consensus.chain_id);
        this.log = this.makeLogger();
        this.params = FullNode.makeConsensusParams(config);

        this.stateDB = this.makeStateDB();
        this.cacheDB = this.makeCacheDB();
        this.storage = this.makeBlockStorage();
        this.taskman = this.makeTaskManager();
        this.clock = this.makeClock();
        this.pool = new TransactionPool(this.cacheDB, &getDoubleSpentSelector);
        this.enroll_man = this.makeEnrollmentManager();
        this.ledger = this.makeLedger();

        this.network = this.makeNetworkManager();
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
                                         this.ledger, this.cacheDB, this.taskman,
                                         this.network);
        this.network.setRegistry(this.registry);

        // Create timers
        this.timers[TimersIdx.Discovery] = this.taskman.createTimer(&this.discoveryTask);
        this.timers[TimersIdx.BlockCatchup] = this.taskman.createTimer(&this.catchupTask);
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
        this.block_stats.agora_block_height_counter = this.ledger.height();
        collector.collect(this.block_stats);
    }

    /***************************************************************************

        Collect all validator & preimage stats into the collector

        Params:
            collector = the Collector to collect the stats into

    ***************************************************************************/

    private void collectValidatorStats (Collector collector)
    {
        auto validators = this.ledger.getValidators(this.ledger.height() + 1);

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
                            this.network.makeBlockExternalizedHandler(url), url);
                    }));

            // Make `BlockHeaderUpdatedHandler`s from config
            config.event_handlers.filter!(h => h.type == HandlerType.BlockHeaderUpdated)
                .each!(handler => handler.addresses
                    .each!((string address) {
                        auto url = Address(address);
                        this.block_header_handlers ~= typeof(this.block_header_handlers[0])(
                            this.network.makeBlockHeaderUpdatedHandler(url), url);
                    }));

            // Make `PreImageReceivedHandler`s from config
            config.event_handlers.filter!(h => h.type == HandlerType.PreimageReceived)
                .each!(handler => handler.addresses
                    .each!((string address) {
                        auto url = Address(address);
                        this.preimage_handlers ~= typeof(this.preimage_handlers[0])(
                            this.network.makePreImageReceivedHandler(url), url);
                    }));

            // Make `TransactionReceivedHandler`s from config
            config.event_handlers.filter!(h => h.type == HandlerType.TransactionReceived)
                .each!(handler => handler.addresses
                    .each!((string address) {
                        auto url = Address(address);
                        this.transaction_handlers ~= typeof(this.transaction_handlers[0])(
                            this.network.makeTransactionReceivedHandler(url), url);
                    }));
        }

        this.timers[TimersIdx.ClockTick] = this.clock.start(this.taskman);
        this.stats_server = this.makeStatsServer();
        this.transaction_relayer.start();

        this.registry.start();

        // Special case
        // Block externalized handler is set and push for Genesis block.
        if (this.block_handlers.length > 0 && this.ledger.height() == 0)
            this.pushBlock(this.params.Genesis);

        // Immediately run discovery to avoid delays at startup (it will re-arm the timer)
        this.taskman.runTask(&this.discoveryTask);

        // re-arm the other timers
        this.startTaskTimer(TimersIdx.BlockCatchup, this.config.node.block_catchup_interval);
    }

    private void startTaskTimer (in TimersIdx timer_id, in Duration interval) @trusted nothrow
    {
        log.dbg("{}: re-arm timer index {}", __FUNCTION__, timer_id);
        if (!this.is_shutting_down)
            this.timers[timer_id].rearm(interval, false);
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

        Periodically discovers new nodes in the network

    ***************************************************************************/

    protected void discoveryTask () nothrow
    {
        this.network.discover(this.ledger.getEnrolledUTXOs());
        this.startTaskTimer(TimersIdx.Discovery, this.config.node.network_discovery_interval);
    }

    /***************************************************************************

        Periodically retrieve the latest blocks and apply them to the
        provided ledger.

        Params:
            ledger = the Ledger to apply received blocks to

    ***************************************************************************/

    protected void catchupTask () nothrow
    {
        scope (exit)
        {
            this.startTaskTimer(TimersIdx.BlockCatchup, this.config.node.block_catchup_interval);
        }

        if (this.network.peers.empty())
        {
            // TODO: Iff the node is the single validator for the network,
            // this should not be printed, or at least not be `warn`.
            this.log.warn("Could not perform catchup yet because we have no peer");
            return;
        }

        try
        {
            this.network.getMissingBlockSigs(this.ledger, &this.acceptHeader);
        }
        catch (Exception e)
        {
            log.error("Error sending updated block headers:{}", e);
        }

        const Height expected = this.ledger.expectedHeight(this.clock.utcTime());
        if (expected < this.ledger.height)
            this.log.warn("Our current Ledger state is ahead of the expected height (current: {}, expected: {}",
                          this.ledger.height, expected);
        else if (expected > this.ledger.height)
        {
            const size_t missing = expected - this.ledger.height;
            this.log.info("Ledger out of sync, missing {} blocks (current height: {}, delay: {})",
                          missing, this.ledger.height, this.ledger.params.BlockInterval * missing);

            this.network.getBlocksFrom(
                this.ledger.height + 1,
                &this.addBlocks);
        }
        // Otherwise we don't print a message, as the Ledger is up to date.

        this.network.getUnknownTXs(this.ledger);
    }

    /***************************************************************************

        Push the header to upstream servers.

        For Validators this is overridden so that it also adds missing
        signatures it has stored.

        Params:
            header = the block header to distribute

    ***************************************************************************/

    protected void acceptHeader (BlockHeader header) @safe
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
            if (block.header.height <= this.ledger.height())
                continue;
            else if (auto fail_msg = this.acceptBlock(block))
            {
                log.trace("addBlocks failed during periodic catchup: {}", fail_msg);
                break;
            }
            this.recordBlockStats(block);
        }
        return this.ledger.height();
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
        return this.ledger.height() >= block.header.height ? null
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
        this.is_shutting_down = true;
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

        // The handlers are just arrays on which we iterate,
        // so setting them to null doesn't incur any risk.
        this.block_handlers = null;
        this.block_header_handlers = null;
        this.preimage_handlers = null;
        this.transaction_handlers = null;

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

            // Finalized by `ManagedDatabase`
            this.storage = null;
            this.stateDB = null;
            this.cacheDB = null;
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
            if (!config.node.test_validators)
                return TESTNET.GenesisBlock;

            immutable Block result = {
                header: {
                    merkle_root: TESTNET.GenesisBlock.header.merkle_root,
                    validators: typeof(BlockHeader.validators)(config.node.test_validators),
                    enrollments: TESTNET.GenesisBlock.header.enrollments[0 .. config.node.test_validators],
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
        auto stat_intf = this.config.interfaces.find!(intf => intf.type == InterfaceConfig.Type.stats);
        if (stat_intf.empty)
            return null;
        return new StatsServer(stat_intf.front.address, stat_intf.front.port);
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

        Returns:
            an instance of a NetworkManager

    ***************************************************************************/

    protected NetworkManager makeNetworkManager ()
    {
        return new VibeNetworkManager(
            this.config, this.cacheDB, this.taskman, this.clock, this);
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
        return new Clock((out Duration time_offset) { return true; });
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
        return new NodeLedger(params, this.stateDB, this.storage,
            this.enroll_man, this.pool, &this.onAcceptedBlock);
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
    public override NodeInfo getNodeInfo () @safe
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
        return this.ledger.height();
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

        if (this.ledger.height() < stored_height)
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
        if (avail_height <= this.ledger.height())
        {
            log.trace("Ignoring enrollment {} targeting a previous Height {}", prettify(enroll), avail_height);
            return;
        }

        scope UTXOFinder utxo_finder = (in Hash hash, out UTXO found_utxo) @safe nothrow
        {
            return this.ledger.peekUTXO(hash, found_utxo) || this.pool.peekUTXO(hash, found_utxo);
        };
        scope GetPenaltyDeposit getPenaltyDeposit = (Hash hash)
        {
            UTXO utxo;
            if (this.ledger.peekUTXO(hash, utxo))
                return this.ledger.getPenaltyDeposit(hash);

            if (this.pool.peekUTXO(hash, utxo))
                return this.params.SlashPenaltyAmount;
            else
                return 0.coins;
        };

        UTXO utxo;
        if (!utxo_finder(enroll.utxo_key, utxo))
        {
            log.info("Found no UTXO for the enrollment: {}", prettify(enroll));
            return;
        }

        const utxo_address = utxo.output.address;
        if (this.enroll_man.addEnrollment(enroll, utxo_address,
            avail_height, utxo_finder, getPenaltyDeposit))
        {
            log.info("Accepted enrollment: {}", prettify(enroll));
            this.network.peers.each!(p => p.sendEnrollment(enroll, avail_height));
        }
    }

    /// GET: /enrollment
    public override Enrollment getEnrollment (in Hash enroll_hash) @safe
    {
        this.recordReq("getEnrollment");
        return this.enroll_man.enroll_pool.getEnrollment(enroll_hash);
    }

    /// POST /preimage
    public override Height postPreimage (in PreImageInfo preimage) @safe
    {
        this.recordReq("postPreimage");
        log.trace("Received Preimage: {}", prettify(preimage));

        if (this.ledger.addPreimage(preimage))
        {
            log.info("Accepted preimage: {}", prettify(preimage));
            this.network.peers.each!(p => p.sendPreimage(preimage));
            this.pushPreImage(preimage);
        }

        return this.enroll_man.getValidatorPreimage(preimage.utxo).height;
    }

    /// GET: /preimages
    public override PreImageInfo[] getPreimages (Set!Hash enroll_keys = Set!Hash.init) @safe
    {
        this.recordReq("preimages");

        // if enroll_keys is empty, then all preimages should be returned
        if (enroll_keys.empty())
            return this.ledger.getValidators(this.ledger.height() + 1)
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
    public override PreImageInfo[] getPreimagesFrom (ulong start_height) @safe
    {
        this.recordReq("preimages_range");

        const known = this.ledger.height();
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
        return this.clock.utcTime();
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
        log.dbg("{}: height {}", __PRETTY_FUNCTION__, block.header.height);
        this.pushBlock(block);
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
        if (this.is_shutting_down)
            return;
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
                    this.block_handlers[idx].onCompletion(false);
                }
                catch (Exception e)
                {
                    log.error("Error sending block height #{} to {} :{}",
                        block.header.height, this.block_handlers[idx].address, e);
                    this.block_handlers[idx].onCompletion(true);
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

    protected void pushBlockHeader (in BlockHeader header) @trusted
    {
        if (this.is_shutting_down)
            return;
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
                    this.block_header_handlers[idx].onCompletion(false);
                }
                catch (Exception e)
                {
                    log.error("Error sending block header at height #{} to {} :{}",
                        header.height, this.block_header_handlers[idx].address, e);
                    this.block_header_handlers[idx].onCompletion(true);
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
        if (this.is_shutting_down)
            return;
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
                    this.preimage_handlers[idx].onCompletion(false);
                }
                catch (Exception e)
                {
                    log.error("Error sending preImage (enroll_key: {}) to {} :{}",
                        pre_image.utxo, this.preimage_handlers[idx].address, e);
                    this.preimage_handlers[idx].onCompletion(true);
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
        if (this.is_shutting_down)
            return;
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
                    this.transaction_handlers[idx].onCompletion(false);
                }
                catch (Exception e)
                {
                    log.error("Error sending transaction (tx hash: {}) to {} :{}",
                        hashFull(tx), this.transaction_handlers[idx].address, e);
                    this.transaction_handlers[idx].onCompletion(true);
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
        return this.getValidators(this.ledger.height() + 1);
    }

    ///
    public override WrappedConsensusParams getConsensusParams ()
    {
        return WrappedConsensusParams(this.params);
    }
}
