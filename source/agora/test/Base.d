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
import agora.common.Block;
import agora.common.Config;
import agora.common.Data;
import agora.common.Hash;
import agora.common.Metadata;
import agora.common.Set;
import agora.common.Task;
import agora.common.Transaction;
import agora.common.TransactionPool;
import agora.common.crypto.Key;
import agora.network.NetworkManager;
import agora.node.API;
import agora.node.Ledger;
import agora.node.Node;

import core.stdc.time;
import std.array;
import std.algorithm.iteration;
import std.exception;
import std.format;

import core.time;

/// Required initialization
shared static this ()
{
    import agora.common.TransactionPool;
    TransactionPool.initialize();
}

/*******************************************************************************

    Task manager backed by LocalRest's event loop.

*******************************************************************************/

public class LocalRestTaskManager : TaskManager
{
    /***************************************************************************

        Run an asynchronous task in LocalRest's event loop.

        Params:
            dg = the delegate the task should run

    ***************************************************************************/

    public override void runTask (void delegate() dg)
    {
        static import geod24.LocalRest;
        geod24.LocalRest.runTask(dg);
    }

    /***************************************************************************

        Suspend the current task for the given duration

        Params:
            dur = the duration for which to suspend the task for

    ***************************************************************************/

    public override void wait (Duration dur)
    {
        static import geod24.LocalRest;
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
        super(conf);
    }

    /// Return the fake time
    protected override time_t getCurTime () const @trusted
    {
        return time;
    }
}

/*******************************************************************************

    Base class for `NetworkManager` used in unittests

    The `NetworkManager` class is the mean used to communicate with other nodes.
    In regular build, it does network communication, but in unittests it should
    not do IO (or appear not to).

    In the current design, all nodes should be instantiated upfront,
    registered via `std.concurrency.register`, and located by `getClient`.

*******************************************************************************/

public class TestNetworkManager : NetworkManager
{
    static import std.concurrency;
    import geod24.LocalRest;
    import core.time;
    import core.stdc.time;

    /// Used by the unittests in order to directly interact with the nodes,
    /// without trying to handshake or do any automatic network discovery.
    /// Also kept here to avoid any eager garbage collection.
    public RemoteAPI!TestAPI[PublicKey] apis;

    /// Workaround compiler bug that triggers in `std.concurrency`
    protected __gshared std.concurrency.Tid[string] tbn;

    /// Ctor
    public this () { super(); }

    /// ditto
    public this (NodeConfig config, BanManager.Config ban_conf,
        in string[] peers, in string[] dns_seeds, Metadata metadata)
    {
        super(config, ban_conf, peers, dns_seeds, metadata);
        // NetworkManager assumes IP are used but we use pubkey
        this.banman.banUntil(config.key_pair.address.toString(), time_t.max);
    }

    ///
    protected final override API getClient (Address address, Duration timeout)
    {
        if (auto ptr = address in tbn)
            return new RemoteAPI!API(*ptr, timeout);
        assert(0, "Trying to access node at address '" ~ address ~
               "' without first creating it");
    }

    /// Initialize a new node
    protected void createNewNode (PublicKey address, Config conf)
    {
        auto api = RemoteAPI!TestAPI.spawn!(TestNode!TestNetworkManager)(conf);
        tbn[address.toString()] = api.tid();
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
        this.apis.each!(a => a.shutdown());
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

    /***************************************************************************

        Returns:
            an instance of a LocalRest-backed task manager

    ***************************************************************************/

    protected override TaskManager getTaskManager ()
    {
        return new LocalRestTaskManager();
    }

    /***************************************************************************

        Params:
            conf = ban manager config

        Returns:
            an instance of a BanManager with a fake clock

    ***************************************************************************/

    protected override BanManager getBanManager (in BanManager.Config conf)
    {
        return new FakeClockBanManager(conf);
    }

}

/// Used to call start/shutdown outside of main, and for dependency injection
public interface TestAPI : API
{
    ///
    public abstract void start();

    ///
    public abstract void shutdown ();

    ///
    public abstract void metaAddPeer(string peer);
}

/// Ditto
public final class TestNode (Net) : Node!Net, TestAPI
{
    ///
    public this (Config config)
    {
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

    /// Used by unittests
    public override void metaAddPeer (Address peer)
    {
        this.metadata.peers.put(peer);
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
        NetworkT = Type of `NetworkManager` to instantiate
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

public NetworkT makeTestNetwork (NetworkT : TestNetworkManager)
    (NetworkTopology topology, size_t nodes, bool configure_network = true,
        long retry_delay = 100, size_t max_retries = 20, long timeout = 500,
        size_t max_failed_requests = 100)
{
    import std.algorithm;
    import std.array;
    import vibe.core.log;

    // by default emit only errors during unittests.
    // can be re-set by calling code.
    setLogLevel(LogLevel.error);

    // We know we're in the main thread
    // Vibe.d messes with the scheduler - reset it
    static import std.concurrency;
    std.concurrency.scheduler = null;

    assert(nodes >= 2, "Creating a network require at least 2 nodes");

    final switch (topology)
    {
    case NetworkTopology.Simple:
        immutable(Config)[] configs;
        immutable(KeyPair)[] key_pairs;
        NodeConfig[] node_configs;

        foreach (idx; 0 .. nodes)
        {
            key_pairs ~= KeyPair.random;

            NodeConfig node_conf =
            {
                key_pair : key_pairs[idx],
                retry_delay : retry_delay, // msecs
                max_retries : max_retries,
                timeout : timeout,
                min_listeners : nodes - 1,
            };

            node_configs ~= node_conf;
        }

        foreach (idx; 0 .. nodes)
        {
            // note: cannot add our own key as a validator (there is a safety check)
            // todo: add this check in the unittests
            auto other_pairs = key_pairs[0 .. idx] ~ key_pairs[idx + 1 .. $];

            BanManager.Config ban_conf =
            {
                max_failed_requests : max_failed_requests,
                ban_duration: 300
            };

            Config conf =
            {
                banman : ban_conf,
                node : node_configs[idx],
                network : configure_network
                    ? assumeUnique(other_pairs.map!(k => k.address.toString()).array)
                    : null,
            };

            configs ~= conf;
        }

        auto net = new NetworkT();

        // Workaround https://issues.dlang.org/show_bug.cgi?id=20002
        TestNetworkManager base_net = net;

        foreach (idx, ref conf; configs)
        {
            const address = node_configs[idx].key_pair.address;
            base_net.createNewNode(address, conf);
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
