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

import agora.node.Ledger;
import agora.api.Validator;
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
import agora.consensus.data.PreimageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXOSet;
import agora.consensus.EnrollmentManager;
import agora.network.NetworkManager;
import agora.node.Ledger;
import agora.node.Node;
import agora.utils.Log;

import ocean.util.log.Logger;

import geod24.LocalRest;
import geod24.Registry;

import core.stdc.time;
import std.array;
import std.algorithm;
import std.exception;
import std.format;

import core.runtime;
import core.time;

shared static this()
{
    import core.runtime;
    Runtime.extendedModuleUnitTester = &customModuleUnitTester;
}

/// Custom unnitest runner as a workaround for multi-threading issue:
/// Agora unittests spawn threads, which allocate. The Ocean tests
/// inspect GC stats for memory allocation changes, and potentially fail
/// if during such a test a runaway Agora unnittest child thread allocates.
/// Workaround: Don't run ocean submodule unittests
private UnitTestResult customModuleUnitTester ()
{
    import std.algorithm;
    import std.parallelism;
    import std.process;
    import std.stdio;
    import std.string;
    import std.uni;
    import core.atomic;

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

            mod_tests ~= ModTest(mod.name, fp);
        }
    }

    shared size_t executed;
    shared size_t passed;
    foreach (mod; parallel(mod_tests))
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
            writefln("Module tests failed: %s", mod.name);
            writeln(ex);
        }
    }

    UnitTestResult result = { executed : executed, passed : passed };
    if (filtered > 0)
        writefln("Ran %s/%s tests (%s filtered)", result.executed,
            result.executed + filtered, filtered);

    //result.summarize = true;
    result.runMain = false;
    return result;
}

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
    public PublicKey key;

    ///
    public RemoteAPI!TestAPI client;
}

/*******************************************************************************

    Used by unittests to send messages to individual nodes.
    This class is instantiated once per unittest.

*******************************************************************************/

public class TestAPIManager
{
    import core.time;
    import core.stdc.time;

    /// Used by the unittests in order to directly interact with the nodes,
    /// without trying to handshake or do any automatic network discovery.
    /// Also kept here to avoid any eager garbage collection.
    public NodePair[] nodes;

    /// convenience: returns a random-access range which lets us access clients
    auto clients ()
    {
        return nodes.map!(np => np.client);
    }

    /// Registry holding the nodes
    protected Registry reg;

    ///
    public this ()
    {
        this.reg.initialize();
    }

    /***************************************************************************

        Create a new node

        Params:
            address = the address of the node, using PublicKey in unittests
            conf = the configuration passed on to the Node constructor

    ***************************************************************************/

    public void createNewNode (PublicKey address, Config conf)
    {
        auto api = RemoteAPI!TestAPI.spawn!(TestNode)(conf, &this.reg,
            conf.node.timeout.msecs);
        this.reg.register(address.toString(), api.tid());
        this.nodes ~= NodePair(address, api);
    }

    /***************************************************************************

        Start each of the nodes

        Params:
            count = Expected number of nodes

    ***************************************************************************/

    public void start ()
    {
        this.nodes.each!(a => a.client.start());
    }

    /***************************************************************************

        Shut down each of the nodes

    ***************************************************************************/

    public void shutdown ()
    {
        foreach (node; this.nodes)
            enforce(this.reg.unregister(node.key.toString()));

        foreach (ref node; this.nodes)
        {
            node.client.shutdown();
            node.client.ctrl.shutdown();
            node.client = null;
        }

        this.nodes = null;
    }

    /***************************************************************************

        Print out the logs for each node

    ***************************************************************************/

    public void printLogs ()
    {
        synchronized  // make sure logging output is not interleaved
        {
            import std.stdio;
            foreach (node; this.nodes)
            {
                writefln("Log for node %s:", node.key);
                writeln("======================================================================");
                node.client.printLog();
                writeln("======================================================================\n");
            }
        }
    }

    /// fill in the in-memory metadata with the peers before nodes are started
    public void addMetadata ()
    {
        foreach (api_a; this.nodes)
        foreach (api_b; this.nodes)
        {
            if (api_a.key == api_b.key)
                continue;

            api_a.client.metaAddPeer(api_b.key.toString());
            api_b.client.metaAddPeer(api_a.key.toString());
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
                retryFor(node.client.getNetworkInfo().ifThrown(NetworkInfo.init)
                    .state == NetworkState.Complete,
                    timeout,
                    format("Node %s has not completed discovery after %s.",
                        node.key, timeout)));
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

    /// Constructor
    public this (NodeConfig config, BanManager.Config ban_conf,
        in string[] peers, in string[] dns_seeds, Metadata metadata,
        TaskManager taskman, Registry* reg)
    {
        this.registry = reg;
        super(config, ban_conf, peers, dns_seeds, metadata, taskman);
        // NetworkManager assumes IP are used but we use pubkey
        this.banman.banUntil(config.key_pair.address.toString(), time_t.max);
    }

    ///
    protected final override API getClient (Address address, Duration timeout)
    {
        auto tid = this.registry.locate(address);
        if (tid != typeof(tid).init)
            return new RemoteAPI!API(tid, timeout);
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
public interface TestAPI : API
{
    ///
    public abstract void start ();

    ///
    public abstract void shutdown ();

    /// Print out the contents of the log
    public void printLog ();

    ///
    public abstract void metaAddPeer (string peer);

    ///
    public abstract Enrollment createEnrollmentData();

    ///
    public abstract PreimageInfo getPreimage (uint height);

    ///
    public abstract void updateEnrolledHeight (Hash enroll_key, ulong height);
}

/// Ditto
public class TestNode : Node, TestAPI
{
    private Registry* registry;

    ///
    public this (Config config, Registry* reg)
    {
        this.registry = reg;
        super(config);
    }

    ///
    public override void start ()
    {
        super.start();
    }

    ///
    public override void shutdown ()
    {
        super.shutdown();
    }

    /// Prints out the log contents for this node
    public void printLog ()
    {
        CircularAppender().printConsole();
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

        // create an Enrollment object to be used for the enrollment process
        auto enroll = this.createEnrollment(utxo_hashes[0]);

        return enroll;
    }

    /// Get a node's own pre-image information used when revealing it
    public override PreimageInfo getPreimage (uint height)
    {
        PreimageInfo preimage;
        this.enroll_man.getPreimage(height, preimage);
        return preimage;
    }

    /// Set a enrolled height for the enrollment
    public override void updateEnrolledHeight (Hash enroll_key, ulong height)
    {
        this.enroll_man.updateEnrolledHeight(enroll_key, height);
    }
}

/// Describes a network topology for testing purpose
public enum NetworkTopology
{
    /// A number of nodes which all know about each other. Figure 9 in the SCP paper.
    Simple,

    /// Same as Simple, with one additional non-validating node
    OneNonValidator,

    /// Only one of the nodes is a validator, the rest are full nodes
    OneValidator,

    /// 4 nodes, 3 required, correspond to Figure 2 in the SCP paper
    Balanced,

    /// 10 nodes, Figure 3 in the SCP paper
    Tiered,

    /// 6 nodes, Figure 4 in the SCP paper
    Cyclic,

    /// Single point of failure, Figure 7 in the SCP paper
    SinglePoF,
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

    /// max retries before a request is considered failed
    size_t max_retries = 20;

    /// request timeout for each node (in msecs)
    long timeout = 2000;

    /// max failed requests before a node is banned
    size_t max_failed_requests = 100;

    /// The threshold. If not set, it will default to the number of nodes
    size_t threshold;
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
    import std.algorithm;
    import std.array;
    import std.range;
    import ocean.util.log.Logger;

    // by default emit only errors during unittests.
    // can be re-set by calling code.
    Log.root.level(Log.root.Level.Error, true);

    // We know we're in the main thread
    // Vibe.d messes with the scheduler - reset it
    static import std.concurrency;
    std.concurrency.scheduler = null;

    assert(test_conf.nodes >= 2, "Creating a network require at least 2 nodes");

    NodeConfig makeNodeConfig (bool is_validator)
    {
        NodeConfig conf =
        {
            is_validator : is_validator,
            key_pair : KeyPair.random(),
            retry_delay : test_conf.retry_delay, // msecs
            max_retries : test_conf.max_retries,
            timeout : test_conf.timeout,
            min_listeners : test_conf.nodes - 1,
            max_listeners : test_conf.nodes - 1,
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
                .map!(conf => conf.key_pair.address.toString());

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

    Config makeCyclicConfig (size_t idx, NodeConfig self, NodeConfig[] node_confs)
    {
        auto prev_idx = idx == 0 ? node_confs.length - 1 : idx - 1;

        auto other_nodes =
            node_confs
                .filter!(conf => conf != self)
                .map!(conf => conf.key_pair.address.toString());

        immutable quorum_keys = [self.key_pair.address, node_confs[prev_idx].key_pair.address];

        Config conf =
        {
            banman : ban_conf,
            node : self,
            network : test_conf.configure_network ? assumeUnique(other_nodes.array) : null,
            quorum : { nodes : quorum_keys /*, threshold : 2*/ }  // fails with 2
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

    case NetworkTopology.OneNonValidator:
        node_configs ~= iota(test_conf.nodes).map!(_ => makeNodeConfig(true)).array;
        node_configs[$ - 1].is_validator = false;
        configs = iota(test_conf.nodes)
            .map!(idx => makeConfig(node_configs[idx], node_configs)).array;
        break;

    case NetworkTopology.OneValidator:
        node_configs ~= iota(test_conf.nodes).map!(_ => makeNodeConfig(false)).array;
        node_configs[0].is_validator = true;
        configs = iota(test_conf.nodes)
            .map!(idx => makeConfig(node_configs[idx], node_configs)).array;
        break;

    case NetworkTopology.Cyclic:
        node_configs = iota(test_conf.nodes).map!(_ => makeNodeConfig(true)).array;
        node_configs.each!((ref conf) => conf.min_listeners = 1);
        configs = iota(test_conf.nodes)
            .map!(idx => makeCyclicConfig(idx, node_configs[idx], node_configs))
                .array;

        break;

    case NetworkTopology.Balanced:
    case NetworkTopology.Tiered:
    case NetworkTopology.SinglePoF:
        assert(0, "Not implemented");
    }

    auto net = new APIManager();
    foreach (idx, ref conf; configs)
    {
        const address = node_configs[idx].key_pair.address;
        net.createNewNode(address, conf);
    }

    return net;
}

/*******************************************************************************

    Keeps retrying the 'check' condition until it is true,
    or until the timeout expires. It will sleep the main
    thread for 100 msecs between each re-try.

    If the timeout expires, and the 'check' condition is still false,
    it throws an AssertError.

    Params:
        check = the condition to check on
        timeout = time to wait for the check to succeed
        msg = optional AssertException message when the condition fails
              after the timeout expires
        file = file from the call site
        line = line from the call site

    Throws:
        AssertError if the timeout is reached and the condition still fails

*******************************************************************************/

public void retryFor (lazy bool check, Duration timeout,
    lazy string msg = "", string file = __FILE__, size_t line = __LINE__)
{
    import core.exception;
    import core.thread;

    // wait 100 msecs between attempts
    const SleepTime = 100;
    auto attempts = timeout.total!"msecs" / SleepTime;
    const TotalAttempts = attempts;

    while (attempts--)
    {
        if (check)
            return;

        Thread.sleep(SleepTime.msecs);
    }

    auto assert_msg = format("Check condition failed after timeout of %s " ~
        "and %s attempts", timeout, TotalAttempts);

    if (msg.length)
        assert_msg ~= ": " ~ msg;

    throw new AssertError(assert_msg, file, line);
}

///
unittest
{
    import core.exception;
    import std.exception;

    static bool willSucceed () { static int x; return ++x == 2; }
    willSucceed().retryFor(1.seconds);

    static bool willFail () { return false; }
    assertThrown!AssertError(willFail().retryFor(300.msecs));
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
