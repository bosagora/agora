/*******************************************************************************

    Contains utilities to be used by tests to easily set up test environments

    Since our business code is decoupled from our network code,
    thanks to the `vibe.web.rest` generator, we can fairly naturally make
    unittests for network behavior.
    By using the `localrest` library, we assign each node to a thread and use
    an RPC-style approach to call functions.
    This is non-deterministic, but models a real-life behaviour better.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Base;

version (unittest):

import agora.common.Amount;
import agora.common.BanManager;
import agora.common.Config;
import agora.common.Types;
import agora.common.Hash;
import agora.common.Metadata;
import agora.common.Set;
import agora.common.Task;
import agora.common.TransactionPool;
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXOSet;
import agora.consensus.EnrollmentManager;
import agora.consensus.Genesis;
import agora.network.NetworkManager;
import agora.node.BlockStorage;
import agora.node.FullNode;
import agora.node.Ledger;
import agora.node.Validator;
import agora.utils.Log;
import agora.utils.PrettyPrinter;
import agora.api.FullNode : NodeInfo, NetworkState;
import agora.api.Validator : ValidatorAPI = API;

import scpd.types.Stellar_SCP;

import ocean.util.log.Logger;

static import geod24.LocalRest;
import geod24.Registry;

import std.array;
import std.exception;

import core.runtime;
import core.stdc.time;

/* The following imports are frequently needed in tests */

 // Contains utilities for testing, e.g. `retryFor`
public import agora.utils.Test;
// `core.time` provides duration-related utilities, used e.g. for `retryFor`
public import core.time;
// Useful to express complex pipeline simply
public import std.algorithm;
// Provides `to`, a template to convert anything to anything else
public import std.conv;
// `format` is often used to provide useful error messages
public import std.format;
// Range utilities are often used in combination with `std.algorithm`
public import std.range;
// To print messages to the screen while debugging a test
public import std.stdio;

shared static this()
{
    Runtime.extendedModuleUnitTester = &customModuleUnitTester;
}

/// Custom unnitest runner as a workaround for multi-threading issue:
/// Agora unittests spawn threads, which allocate. The Ocean tests
/// inspect GC stats for memory allocation changes, and potentially fail
/// if during such a test a runaway Agora unnittest child thread allocates.
/// Workaround: Don't run ocean submodule unittests
private UnitTestResult customModuleUnitTester ()
{
    import std.parallelism;
    import std.process;
    import std.string;
    import std.uni;
    import core.atomic;
    import core.sync.mutex;

    // by default emit only errors during unittests.
    // can be re-set by calling code.
    Log.root.level(Log.root.Level.Error, true);

    //
    auto filter = environment.get("dtest").toLower();
    size_t filtered;

    // can't use ModuleInfo[], opApply returns temporaries..
    struct ModTest
    {
        string name;
        void function() test;
    }

    ModTest[] mod_tests;
    ModTest[] single_threaded;

    foreach (ModuleInfo* mod; ModuleInfo)
    {
        if (mod is null)
            continue;

        auto fp = mod.unitTest;
        if (fp is null)
            continue;

        if (mod.name.startsWith("agora") ||
            mod.name.startsWith("scpd"))
        {
            if (filter.length > 0 &&
                !canFind(mod.name.toLower(), filter.save))
            {
                filtered++;
                continue;
            }

            // this test checks GC usage stats before / after tests,
            // but other threads can change the outcome of the GC usage stats
            if (mod.name.startsWith("agora.common.Serializer"))
                single_threaded ~= ModTest(mod.name, fp);
            else
                mod_tests ~= ModTest(mod.name, fp);
        }
    }

    shared size_t executed;
    shared size_t passed;
    shared Mutex print_lock = new shared Mutex();

    void runTest (ModTest mod)
    {
        atomicOp!"+="(executed, 1);
        try
        {
            //writefln("Unittesting %s..", mod.name);
            mod.test();
            atomicOp!"+="(passed, 1);
        }
        catch (Throwable ex)
        {
            synchronized (print_lock)
            {
                writefln("Module tests failed: %s", mod.name);
                writeln(ex);
                CircularAppender().printConsole();  // print logs of the work thread
            }
        }
    }

    // Run single-threaded tests
    foreach (mod; single_threaded)
        runTest(mod);

    foreach (mod; parallel(mod_tests))
        runTest(mod);

    UnitTestResult result = { executed : executed, passed : passed };
    if (filtered > 0)
        writefln("Ran %s/%s tests (%s filtered)", result.executed,
            result.executed + filtered, filtered);

    //result.summarize = true;
    result.runMain = false;
    return result;
}

/// A custom serializer for LocalRest
public struct Serializer
{
    import agora.common.Serializer;

    static immutable(ubyte)[] serialize (T) (auto ref T value) @trusted nothrow
    {
        // `serializeFull` should be `@safe`, but `assumeUnique` is not
        try
            return ((arr) @trusted => assumeUnique(arr))(serializeFull(value));
        catch (Throwable t)
        {
            try
            {
                writeln("ERROR: Serializable: ", T.stringof);
                writeln(t);
            }
            catch (Exception ignored) {}
            assert(0);
        }
    }

    static QT deserialize (QT) (scope immutable(ubyte)[] data) @trusted nothrow
    {
        try
            return deserializeFull!QT(data);
        catch (Throwable t)
        {
            try
            {
                writeln("ERROR: Deserialize:", QT.stringof);
                writeln(t);
            }
            catch (Exception ignored) {}
            assert(0);
        }
    }
}

/// A different default serializer from `LocalRest` for `RemoteAPI`
public alias RemoteAPI (APIType) = geod24.LocalRest.RemoteAPI!(APIType, Serializer);

/*******************************************************************************

    Task manager backed by LocalRest's event loop.

*******************************************************************************/

public class LocalRestTaskManager : TaskManager
{
    static import geod24.LocalRest;

    /***************************************************************************

        Run an asynchronous task in LocalRest's event loop.

        Params:
            dg = the delegate the task should run

    ***************************************************************************/

    public override void runTask (void delegate() dg)
    {
        geod24.LocalRest.runTask(dg);
    }

    /***************************************************************************

        Suspend the current task for the given duration

        Params:
            dur = the duration for which to suspend the task for

    ***************************************************************************/

    public override void wait (Duration dur)
    {
        geod24.LocalRest.sleep(dur);
    }

    /***************************************************************************

        Run an asynchronous task after a given time in LocalRest's

        The task will first run after the given `timeout`, and
        can either repeat or run only once (the default).
        Works similarly to Vibe.d's `setTimer`.

        Params:
            timeout = Determines the minimum amount of time that elapses before
                the timer fires.
            dg = This delegate will be called when the timer fires.
            periodic = Specifies if the timer fires repeatedly or only once.

    ***************************************************************************/

    public override void setTimer (Duration timeout, void delegate() dg,
        Periodic periodic = Periodic.No)
    {
        geod24.LocalRest.setTimer(timeout, dg, periodic);
    }
}

/// A ban manager with a fake clock for reliable unittesting
public class FakeClockBanManager : BanManager
{
    /// the fake current time
    public __gshared time_t time;

    /// Ctor
    public this (Config conf)
    {
        super(conf, null);
    }

    /// Return the fake time
    protected override time_t getCurTime () const @trusted
    {
        return time;
    }

    /// no-op
    public override void load () { }

    /// no-op
    public override void dump () { }
}

/// We use a pair of (key, client) rather than a hashmap client[key],
/// since we want to know the order of the nodes which were configured
/// in the makeTestNetwork() call.
public struct NodePair
{
    ///
    public Address address;

    ///
    public RemoteAPI!TestAPI client;
}

/*******************************************************************************

    Used by unittests to send messages to individual nodes.
    This class is instantiated once per unittest.

*******************************************************************************/

public class TestAPIManager
{
    /// Used by the unittests in order to directly interact with the nodes,
    /// without trying to handshake or do any automatic network discovery.
    /// Also kept here to avoid any eager garbage collection.
    public NodePair[] nodes;

    /// Contains the initial blockchain state of all nodes
    public immutable(Block)[] blocks;

    /// convenience: returns a random-access range which lets us access clients
    auto clients ()
    {
        return nodes.map!(np => np.client);
    }

    /// Registry holding the nodes
    protected Registry reg;

    ///
    public this (immutable(Block)[] blocks)
    {
        this.blocks = blocks;
        this.reg.initialize();
    }

    /***************************************************************************

        Create a new node

        Params:
            conf = the configuration passed on to the Node constructor
            blocks = the blockchain to preload (including genesis)

    ***************************************************************************/

    public void createNewNode (Config conf)
    {
        RemoteAPI!TestAPI api;

        if (conf.node.is_validator)
        {
            api = RemoteAPI!TestAPI.spawn!TestValidatorNode(conf, &this.reg,
                this.blocks, conf.node.timeout.msecs);
        }
        else
        {
            api = RemoteAPI!TestAPI.spawn!TestFullNode(conf, &this.reg,
                this.blocks, conf.node.timeout.msecs);
        }

        this.reg.register(conf.node.address, api.tid());
        this.nodes ~= NodePair(conf.node.address, api);
    }

    /***************************************************************************

        Start each of the nodes

        Params:
            count = Expected number of nodes

    ***************************************************************************/

    public void start ()
    {
        foreach (node; this.nodes)
        {
            // have to wait indefinitely as the constructor is
            // currently a slow routine, stalling the call to start().
            node.client.ctrl.withTimeout(0.msecs,
                (scope TestAPI api) {
                    api.start();
                });
        }
    }

    /***************************************************************************

        Shut down each of the nodes

    ***************************************************************************/

    public void shutdown ()
    {
        foreach (node; this.nodes)
            enforce(this.reg.unregister(node.address));

        foreach (ref node; this.nodes)
        {
            node.client.ctrl.shutdown(
                (TestAPI node) { (cast(FullNode)node).shutdown(); });
            node.client = null;
        }

        this.nodes = null;
    }

    /***************************************************************************

        Print out the logs for each node

    ***************************************************************************/

    public void printLogs (string file = __FILE__, size_t line = __LINE__)
    {
        synchronized  // make sure logging output is not interleaved
        {
            writefln("%s(%s): Node logs:\n", file, line);
            foreach (node; this.nodes)
                node.client.printLog();
        }
    }

    /// fill in the in-memory metadata with the peers before nodes are started
    public void addMetadata ()
    {
        foreach (api_a; this.nodes)
        foreach (api_b; this.nodes)
        {
            if (api_a.address == api_b.address)
                continue;

            api_a.client.metaAddPeer(api_b.address);
            api_b.client.metaAddPeer(api_a.address);
        }
    }

    /***************************************************************************

        Keep polling for nodes to reach discovery, up to 5 seconds.

        If network discovery isn't reached, it will throw an Error.

    ***************************************************************************/

    public void waitForDiscovery (string file = __FILE__, size_t line = __LINE__)
    {
        try
        {
            const timeout = 5.seconds;
            this.nodes.each!(node =>
                retryFor(node.client.getNodeInfo().ifThrown(NodeInfo.init)
                    .state == NetworkState.Complete,
                    timeout,
                    format("Node %s has not completed discovery after %s.",
                        node.address, timeout)));
        }
        catch (Error ex)  // better UX
        {
            ex.file = file;
            ex.line = line;
            throw ex;
        }
    }
}

/*******************************************************************************

    Base class for `NetworkManager` used in unittests.
    This class is instantiated once per unittested node.

    The `NetworkManager` class is the mean used to communicate with other nodes.
    In regular build, it does network communication, but in unittests it should
    not do IO (or appear not to).

    In the current design, all nodes should be instantiated upfront,
    registered via `geod24.Registry`, and located by `getClient`.

*******************************************************************************/

public class TestNetworkManager : NetworkManager
{
    ///
    public Registry* registry;

    /// In LocalRest the address is a custom string (see makeNodeConfig())
    protected Address address;

    /// Constructor
    public this (NodeConfig config, BanManager.Config ban_conf,
        in string[] peers, in string[] dns_seeds, Metadata metadata,
        TaskManager taskman, Registry* reg)
    {
        this.registry = reg;
        this.address = config.address;
        super(config, ban_conf, peers, dns_seeds, metadata, taskman);
    }

    /// No "http://" in unittests, we just use the string as-is
    protected final override string getAddress ()
    {
        return this.address;
    }

    ///
    protected final override ValidatorAPI getClient (Address address,
        Duration timeout)
    {
        auto tid = this.registry.locate(address);
        if (tid != typeof(tid).init)
            return new RemoteAPI!ValidatorAPI(tid, timeout);
        assert(0, "Trying to access node at address '" ~ address ~
               "' without first creating it");
    }

    /***************************************************************************

        Params:
            conf = ban manager config

        Returns:
            an instance of a BanManager with a fake clock

    ***************************************************************************/

    protected override BanManager getBanManager (in BanManager.Config conf,
        cstring _data_dir)
    {
        return new FakeClockBanManager(conf);
    }
}

/// Used to call start/shutdown outside of main, and for dependency injection
public interface TestAPI : ValidatorAPI
{
    ///
    public abstract void start ();

    /// Print out the contents of the log
    public void printLog ();

    ///
    public abstract void metaAddPeer (string peer);

    ///
    public abstract Enrollment createEnrollmentData();

    ///
    public abstract void broadcastPreimage (uint height);
}

/// Contains routines which are implemented by both TestFullNode and
/// TestValidator. Used because TestValidator inherits from Validator but
/// cannot inherit from TestFullNode, as it already inherits from Validator class
/// (multiple-inheritance is not supported in D)
private mixin template TestNodeMixin ()
{
    private Registry* registry;

    /// Blocks to preload into the memory storage
    private immutable(Block)[] blocks;

    ///
    public this (Config config, Registry* reg, immutable(Block)[] blocks)
    {
        this.registry = reg;
        this.blocks = blocks;
        super(config);
    }

    ///
    public override void start ()
    {
        super.start();
    }

    /// Prints out the log contents for this node
    public void printLog ()
    {
        writefln("Log for node: %s", this.config.node.address);
        writeln("======================================================================");
        CircularAppender().printConsole();
        writeln("======================================================================\n");
    }

    protected override IBlockStorage getBlockStorage (string data_dir) @system
    {
        return new MemBlockStorage(this.blocks);
    }

    /// Used by the node
    public override Metadata getMetadata (string _unused) @system
    {
        return new MemMetadata();
    }

    /// Return a transaction pool backed by an in-memory SQLite db
    public override TransactionPool getPool (string) @system
    {
        return new TransactionPool(":memory:");
    }

    /// Return a UTXO set backed by an in-memory SQLite db
    protected override UTXOSet getUtxoSet (string data_dir)
    {
        return new UTXOSet(":memory:");
    }

    /// Used by unittests
    public override void metaAddPeer (Address peer)
    {
        this.metadata.peers.put(peer);
    }

    /// Return a LocalRest-backed task manager
    protected override TaskManager getTaskManager ()
    {
        return new LocalRestTaskManager();
    }

    /// Return an instance of the custom TestNetworkManager
    protected override NetworkManager getNetworkManager (
        in NodeConfig node_config, in BanManager.Config banman_conf,
        in string[] peers, in string[] dns_seeds, Metadata metadata,
        TaskManager taskman)
    {
        assert(taskman !is null);
        return new TestNetworkManager(node_config, banman_conf, peers,
            dns_seeds, metadata, taskman, this.registry);
    }

    /// Return an enrollment manager backed by an in-memory SQLite db
    protected override EnrollmentManager getEnrollmentManager (
        string data_dir, in NodeConfig node_config)
    {
        return new EnrollmentManager(":memory:", node_config.key_pair);
    }
}

/// A FullNode which also implements test routines in TestAPI
public class TestFullNode : FullNode, TestAPI
{
    ///
    mixin TestNodeMixin!();

    /// FullNode does not implement this
    public override void broadcastPreimage (uint height)
    {
        assert(0);
    }

    /// FullNode does not implement this
    public override Enrollment createEnrollmentData ()
    {
        assert(0);
    }

    /// FullNode does not implement this
    public override PublicKey getPublicKey () @safe
    {
        // NetworkManager assumes that if key == PublicKey.init,
        // we are *not* a Validator node, treated as a FullNode instead.
        return PublicKey.init;
    }

    /// FullNode does not implement this
    public override void receiveEnvelope (SCPEnvelope envelope) @safe
    {
        assert(0);
    }
}

/// A Validator which also implements test routines in TestAPI
public class TestValidatorNode : Validator, TestAPI
{
    ///
    mixin TestNodeMixin!();

    /// Create an enrollment data used as information for an validator
    public override Enrollment createEnrollmentData ()
    {
        Hash[] utxo_hashes;
        auto pubkey = this.getPublicKey();
        auto utxos = this.utxo_set.getUTXOs(pubkey);
        foreach (key, utxo; utxos)
        {
            if (utxo.type == TxType.Freeze &&
                utxo.output.value.integral() >= Amount.MinFreezeAmount.integral())
            {
                utxo_hashes ~= key;
            }
        }

        Enrollment enroll;
        this.enroll_man.createEnrollment(utxo_hashes[0],
            this.ledger.getBlockHeight(), enroll);

        return enroll;
    }

    /// Broadcast a pre-image information to the network
    public override void broadcastPreimage (uint height)
    {
        PreImageInfo preimage;
        this.enroll_man.getPreimage(height, preimage);
        this.receivePreimage(preimage);
    }
}

/// Describes a network topology for testing purpose
public enum NetworkTopology
{
    /// A number of nodes which all know about each other. Figure 9 in the SCP paper.
    Simple,

    /// Set a minimal networking config, the node should use network discovery
    /// to connect to a min_listeners number of nodes
    FindNetwork,

    /// Set a minimal networking config, but a full quorum configuration
    /// The node should attempt to connect to all its quorum peers even
    /// if it only knows their public keys
    FindQuorums,

    /// Same as Simple, with one additional non-validating node
    OneNonValidator,

    /// Only one of the nodes is a validator, the rest are full nodes
    OneValidator,

    /// One node is not part of the network for any other nodes
    OneOutsider,
}

/// Node / Network / Quorum configuration for use with makeTestNetwork
public struct TestConf
{
    /// Network topology to use
    NetworkTopology topology = NetworkTopology.Simple;

    /// Number of nodes to instantiate
    size_t nodes = 4;

    /// whether to set up the peers in the config
    bool configure_network = true;

    /// the delay between request retries (in msecs)
    long retry_delay = 100;

    /// minimum clients to connect to (defaults to nodes.length - 1)
    size_t min_listeners;

    /// max retries before a request is considered failed
    size_t max_retries = 20;

    /// request timeout for each node (in msecs)
    long timeout = 5000;

    /// max failed requests before a node is banned
    size_t max_failed_requests = 100;

    /// max listener nodes. If set to 0, set to this.nodes - 1
    size_t max_listeners;

    /// The threshold. If not set, it will default to the number of nodes
    size_t threshold;

    /// the genesis block to use, or GenesisBlock in Genesis.d if not set.
    immutable Block gen_block;
}

/*******************************************************************************

    Creates a test network with the desired topology

    This function's only usage is to create the network topology.
    The actual behavior of the nodes that are part of the network is decided
    by the `TestNetworkManager` implementation.

    Params:
        APIManager = Type of API manager to instantiate
        test_conf = the test configuration

    Returns:
        The set of public key added to the node

*******************************************************************************/

public APIManager makeTestNetwork (APIManager : TestAPIManager = TestAPIManager)(
    in TestConf test_conf)
{
    import agora.common.Serializer;
    import std.digest;
    import std.range;

    // We know we're in the main thread
    // Vibe.d messes with the scheduler - reset it
    static import std.concurrency;
    std.concurrency.scheduler = null;

    assert(test_conf.nodes >= 2, "Creating a network require at least 2 nodes");

    // custom genesis block
    immutable string gen_block_hex = test_conf.gen_block != immutable(Block).init
        ? test_conf.gen_block.serializeFull.toHexString : null;

    size_t full_node_idx;
    size_t validator_idx;

    NodeConfig makeNodeConfig (bool is_validator)
    {
        KeyPair key_pair = KeyPair.random();
        Address address;

        if (is_validator)
            address = format("Validator #%s (%s)",
                validator_idx++, key_pair.address.prettify);
        else
            address = format("FullNode #%s", full_node_idx++);

        NodeConfig conf =
        {
            address : address,
            is_validator : is_validator,
            key_pair : key_pair,
            retry_delay : test_conf.retry_delay, // msecs
            max_retries : test_conf.max_retries,
            timeout : test_conf.timeout,
            min_listeners : test_conf.min_listeners == 0
                ? test_conf.nodes - 1 : test_conf.min_listeners,
            max_listeners : (test_conf.max_listeners == 0)
                ? test_conf.nodes - 1 : test_conf.max_listeners,
            genesis_block : gen_block_hex
        };

        return conf;
    }

    BanManager.Config ban_conf =
    {
        max_failed_requests : test_conf.max_failed_requests,
        ban_duration: 300
    };

    Config makeConfig (NodeConfig self, NodeConfig[] node_confs)
    {
        auto other_nodes =
            node_confs
                .filter!(conf => conf != self)
                .map!(conf => conf.address);

        auto quorum_keys =
            node_confs
                .filter!(conf => conf.is_validator)
                .map!(conf => conf.key_pair.address).array.assumeUnique;

        Config conf =
        {
            banman : ban_conf,
            node : self,
            network : test_conf.configure_network ? assumeUnique(other_nodes.array) : null,
            quorum :
            {
                nodes : quorum_keys,
                threshold : (test_conf.threshold == 0) ? quorum_keys.length : test_conf.threshold
            }
        };

        return conf;
    }

    // each node only has another node in its network, but will discover the
    // entire network through the network discovery phase
    Config makeMinimalNetwork (size_t idx, NodeConfig self, NodeConfig[] node_confs)
    {
        auto prev_node = idx == 0 ? node_confs[$ - 1] : node_confs[idx - 1];

        auto quorum_keys =
            node_confs
                .filter!(conf => conf.is_validator)
                .map!(conf => conf.key_pair.address).array.assumeUnique;

        Config conf =
        {
            banman : ban_conf,
            node : self,
            network : test_conf.configure_network ? [prev_node.address] : null
        };

        return conf;
    }

    // for discovery testing: full quorum, but only 1 node in the 'network' section
    Config makeMinimalNetQuorum (size_t idx, NodeConfig self, NodeConfig[] node_confs)
    {
        auto prev_node = idx == 0 ? node_confs[$ - 1] : node_confs[idx - 1];

        node_confs.each!(conf => assert(conf.is_validator));

        auto quorum_keys =
            node_confs
                .filter!(conf => conf.is_validator)
                .map!(conf => conf.key_pair.address).array.assumeUnique;

        Config conf =
        {
            banman : ban_conf,
            node : self,
            network : test_conf.configure_network ? [prev_node.address] : null,
            quorum :
            {
                nodes : quorum_keys,
                threshold : (test_conf.threshold == 0) ? quorum_keys.length : test_conf.threshold
            }
        };

        return conf;
    }

    NodeConfig[] node_configs;
    Config[] configs;

    final switch (test_conf.topology)
    {
    case NetworkTopology.Simple:
        node_configs = iota(test_conf.nodes).map!(_ => makeNodeConfig(true)).array;
        configs = iota(test_conf.nodes)
            .map!(idx => makeConfig(node_configs[idx], node_configs)).array;
        break;

    case NetworkTopology.FindNetwork:
        node_configs = iota(test_conf.nodes).map!(_ => makeNodeConfig(false)).array;
        configs = iota(test_conf.nodes)
            .map!(idx => makeMinimalNetwork(idx, node_configs[idx], node_configs)).array;
        break;

    case NetworkTopology.FindQuorums:
        node_configs = iota(test_conf.nodes).map!(_ => makeNodeConfig(true)).array;
        configs = iota(test_conf.nodes)
            .map!(idx => makeMinimalNetQuorum(idx, node_configs[idx], node_configs)).array;
        break;

    case NetworkTopology.OneNonValidator:
        node_configs ~= iota(test_conf.nodes - 1).map!(_ => makeNodeConfig(true)).array;
        node_configs ~= makeNodeConfig(false);
        configs = iota(test_conf.nodes)
            .map!(idx => makeConfig(node_configs[idx], node_configs)).array;
        break;

    case NetworkTopology.OneValidator:
        node_configs ~= makeNodeConfig(true);
        node_configs ~= iota(test_conf.nodes - 1).map!(_ => makeNodeConfig(false)).array;
        configs = iota(test_conf.nodes)
            .map!(idx => makeConfig(node_configs[idx], node_configs)).array;
        break;

    case NetworkTopology.OneOutsider:
        node_configs ~= iota(test_conf.nodes).map!(_ => makeNodeConfig(true)).array;
        configs = iota(test_conf.nodes)
            .map!(idx => makeConfig(node_configs[idx], node_configs)).array;

        // add one non-validator outside the network
        node_configs ~= makeNodeConfig(false);
        configs ~= makeConfig(node_configs[$ - 1], node_configs);
        break;
    }

    immutable GenBlock = test_conf.gen_block != immutable(Block).init
        ? test_conf.gen_block : GenesisBlock;

    auto net = new APIManager([GenBlock]);
    foreach (ref conf; configs)
        net.createNewNode(conf);

    return net;
}

/// Returns: the entire ledger from the provided node
public const(Block)[] getAllBlocks (TestAPI node)
{
    import std.range;
    const(Block)[] blocks;

    // note: may return less than asked for, hence the loop
    size_t starting_block = 0;
    while (1)
    {
        auto new_blocks = node.getBlocksFrom(starting_block, uint.max);
        if (new_blocks.length == 0)  // no blocks left
            break;

        // ensure sequential consistency
        foreach (block; new_blocks)
            assert(block.header.height == starting_block++);

        blocks ~= new_blocks;
    }

    return blocks;
}

/// Returns: true if all the nodes contain the same blocks
public bool containSameBlocks (APIS)(APIS nodes, size_t height)
{
    auto first_blocks = nodes[0].getAllBlocks();

    foreach (node; nodes)
    {
        if (node.getBlockHeight() != height)
            return false;

        if (node.getAllBlocks() != first_blocks)
            return false;
    }

    return true;
}
