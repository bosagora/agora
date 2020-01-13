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

import agora.common.BanManager;
import agora.consensus.data.Block;
import agora.consensus.data.UTXOSet;
import agora.common.Config;
import agora.common.Types;
import agora.common.Hash;
import agora.common.Metadata;
import agora.common.Set;
import agora.common.Task;
import agora.common.TransactionPool;
import agora.common.crypto.Key;
import agora.consensus.data.Transaction;
import agora.network.NetworkManager;
import agora.node.API;
import agora.node.Ledger;
import agora.node.Node;
import agora.utils.Log;

import ocean.util.log.Logger;

import geod24.LocalRest;
import geod24.Registry;

import core.stdc.time;
import std.array;
import std.algorithm.iteration;
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

    UnitTestResult result;
    foreach (mod; parallel(mod_tests))
    {
        ++result.executed;

        try
        {
            //writefln("Unittesting %s..", mod.name);
            mod.test();
            ++result.passed;
        }
        catch (Throwable ex)
        {
            writefln("Module tests failed: %s", mod.name);
            writeln(ex);
        }
    }

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
    public RemoteAPI!TestAPI[PublicKey] apis;

    /// Registry holding the nodes
    protected Registry reg;

    ///
    public this ()
    {
        this.reg.initialize();
    }

    /// Initialize a new node
    public void createNewNode (PublicKey address, Config conf)
    {
        auto api = RemoteAPI!TestAPI.spawn!(TestNode)(conf, &this.reg);
        this.reg.register(address.toString(), api.tid());
        this.apis[address] = api;
    }

    /***************************************************************************

        Start each of the nodes

        Params:
            count = Expected number of nodes

    ***************************************************************************/

    public void start ()
    {
        this.apis.each!(a => a.start());
    }

    /***************************************************************************

        Shut down each of the nodes

    ***************************************************************************/

    public void shutdown ()
    {
        foreach (key, ref api; this.apis)
        {
            api.shutdown();
            api.ctrl.shutdown();
            api = null;
        }

        this.apis = null;
    }

    /***************************************************************************

        Print out the logs for each node

    ***************************************************************************/

    public void printLogs ()
    {
        synchronized  // make sure logging output is not interleaved
        {
            import std.stdio;
            foreach (key, api; this.apis)
            {
                writefln("Log for node %s:", key);
                writeln("======================================================================");
                api.printLog();
                writeln("======================================================================\n");
            }
        }
    }

    /// fill in the in-memory metadata with the peers before nodes are started
    public void addMetadata ()
    {
        auto keys = this.apis.keys.array;

        foreach (key_x; keys)
        foreach (key_y; keys)
        {
            if (key_x == key_y)
                continue;

            this.apis[key_x].metaAddPeer(key_y.toString());
            this.apis[key_y].metaAddPeer(key_x.toString());
        }
    }

    /***************************************************************************

        Keep polling and waiting for nodes to all reach discovery,
        up to 10 attempts and a sleep time between each attempt;

        Returns:
            the public keys of the nodes which reached discovery

    ***************************************************************************/

    public PublicKey[] getDiscoveredNodes ()
    {
        import std.stdio;
        import core.thread;

        const attempts = 10;

        bool[PublicKey] fully_discovered;

        foreach (_; 0 .. attempts)
        {
            foreach (key, api; this.apis)
            try
            {
                if (api.getNetworkInfo().state == NetworkState.Complete)
                    fully_discovered[key] = true;
            }
            catch (Exception ex)
            {
                // just continue
            }

            // we're done
            if (fully_discovered.length == this.apis.length)
                break;

            // try again
            auto sleep_time = 1.seconds;  // should be enough time
            writefln("Sleeping for %s. Discovered %s/%s nodes", sleep_time,
                fully_discovered.length, this.apis.length);
            Thread.sleep(sleep_time);
        }

        return fully_discovered.byKey.array;
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
        return new TestNetworkManager(node_config, banman_conf, peers,
            dns_seeds, metadata, taskman, this.registry);
    }
}

/// Describes a network topology for testing purpose
public enum NetworkTopology
{
    /// 4 nodes which all know about each other. Figure 9 in the SCP paper.
    Simple,

    /// 4 nodes, 3 required, correspond to Figure 2 in the SCP paper
    Balanced,

    /// 10 nodes, Figure 3 in the SCP paper
    Tiered,

    /// 6 nodes, Figure 4 in the SCP paper
    Cyclic,

    /// Single point of failure, Figure 7 in the SCP paper
    SinglePoF,
}

/*******************************************************************************

    Creates a test network with the desired topology

    This function's only usage is to create the network topology.
    The actual behavior of the nodes that are part of the network is decided
    by the `TestNetworkManager` implementation.

    Params:
        APIManager = Type of API manager to instantiate
        topology = Network topology to adopt
        nodes    = Number of nodes to instantiated
        configure_network = whether to set up the peers in the config
        retry_delay = the delay between request retries (in msecs)
        max_retries = max retries before a request is considered failed
        timeout = request timeout (in msecs)
        max_failed_requests = max failed requests before a node is banned

    Returns:
        The set of public key added to the node

*******************************************************************************/

public APIManager makeTestNetwork (APIManager : TestAPIManager = TestAPIManager)
    (NetworkTopology topology, size_t nodes, bool configure_network = true,
        long retry_delay = 100, size_t max_retries = 20, long timeout = 500,
        size_t max_failed_requests = 100)
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

    assert(nodes >= 2, "Creating a network require at least 2 nodes");

    NodeConfig makeNodeConfig ()
    {
        NodeConfig conf =
        {
            key_pair : KeyPair.random(),
            retry_delay : retry_delay, // msecs
            max_retries : max_retries,
            timeout : timeout,
            min_listeners : nodes - 1,
        };

        return conf;
    }

    Config makeConfig (NodeConfig self, NodeConfig[] node_confs)
    {
        BanManager.Config ban_conf =
        {
            max_failed_requests : max_failed_requests,
            ban_duration: 300
        };

        auto other_nodes =
            node_confs
                .filter!(conf => conf != self)
                .map!(conf => conf.key_pair.address.toString());

        auto quorum_keys = assumeUnique(
            node_confs.map!(conf => conf.key_pair.address).array);

        Config conf =
        {
            banman : ban_conf,
            node : self,
            network : configure_network ? assumeUnique(other_nodes.array) : null,
            quorum : { nodes : quorum_keys }
        };

        return conf;
    }

    final switch (topology)
    {
    case NetworkTopology.Simple:
        auto node_configs = iota(nodes).map!(_ => makeNodeConfig()).array;
        auto configs = iota(nodes)
            .map!(idx => makeConfig(node_configs[idx], node_configs)).array;

        auto net = new APIManager();
        foreach (idx, ref conf; configs)
        {
            const address = node_configs[idx].key_pair.address;
            net.createNewNode(address, conf);
        }

        return net;

    case NetworkTopology.Balanced:
    case NetworkTopology.Tiered:
    case NetworkTopology.Cyclic:
    case NetworkTopology.SinglePoF:
        assert(0, "Not implemented");
    }
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
public bool containSameBlocks (API)(API[] nodes, size_t height)
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
