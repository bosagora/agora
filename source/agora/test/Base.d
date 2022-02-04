/*******************************************************************************

    Contains utilities to be used by tests to easily set up test environments

    Since our business code is decoupled from our network code,
    thanks to the `vibe.web.rest` generator, we can fairly naturally make
    unittests for network behavior.
    By using the `localrest` library, we assign each node to a thread and use
    an RPC-style approach to call functions.
    This is non-deterministic, but models a real-life behaviour better.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Base;

version (unittest):

import agora.api.FullNode : NodeInfo, NetworkState;
import agora.api.Registry;
import agora.api.Handlers;
import agora.common.BanManager;
import agora.common.BitMask;
import agora.common.DNS;
import agora.common.Ensure;
import agora.common.ManagedDatabase;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.BlockStorage;
import agora.consensus.data.genesis.Test;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.ValidatorBlockSig;
import agora.consensus.EnrollmentManager;
import agora.consensus.Fee;
import agora.consensus.Ledger;
import agora.consensus.pool.Transaction;
import agora.consensus.PreImage;
import agora.consensus.protocol.Data;
import agora.consensus.protocol.Nominator;
import agora.consensus.Quorum;
import agora.consensus.state.UTXOSet;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.network.Client;
import agora.network.Clock;
import agora.network.DNSResolver;
import agora.network.Manager;
import agora.node.Config;
import agora.node.FullNode;
import agora.node.Registry;
import agora.node.TransactionRelayer;
import agora.node.Validator;
import agora.utils.Log;
import agora.utils.PrettyPrinter;
public import agora.utils.Utility : retryFor;
import agora.utils.Workarounds;

import scpd.types.Stellar_SCP;

static import geod24.LocalRest;
import geod24.Registry;
import geod24.concurrency;

import std.array;
import std.exception;
import std.range;
import std.typecons;

import core.atomic : atomicLoad, atomicStore;
import core.exception;
import core.runtime;
import core.stdc.time;
import core.thread;

/* The following imports are frequently needed in tests */

public import agora.common.Amount;
public import agora.common.Types;
public import agora.consensus.data.Block;
public import agora.consensus.data.Enrollment;
public import agora.consensus.data.Transaction;

/// In order to `filter` (LocalRest) any method, the `API` type is needed
public import agora.api.Validator;
/// Any test implementing their own nodes will need to use `Config`
public import agora.node.Config : Config;
/// Allows to easily configure the loggers
public import agora.utils.Log : LogLevel;
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
// Make inheriting much easier
public import std.traits : Parameters;

// Convenience constants
public const size_t GenesisValidators = GenesisBlock.header.enrollments.count();
public const uint GenesisValidatorCycle = 20;

/// Initialized from the unittest runner and never overriden afterwards
private __gshared LogLevel defaultLogLevel = LogLevel.Info;

shared static this ()
{
    Runtime.extendedModuleUnitTester = &customModuleUnitTester;
}

/// Workaround for issue likely related to dub #225,
/// expects a main() function and invokes it after unittesting.
void main () { }

void testAssertHandler (string file, ulong line, string msg) nothrow
{
    // `std.typecons` test an assert failure, so handle it explicitly
    static immutable Typecons = "std/typecons.d";
    if (file.length >= Typecons.length && file[$ - Typecons.length .. $] == Typecons)
        throw new AssertError(msg, file, line);

    try
    {
        scope output = stdout.lockingTextWriter();
        output.formattedWrite(
            "================================ ASSERT HANDLER ===============================\n");
        output.formattedWrite!"[%s:%s] Assertion thrown during test: %s\n"
            (file, line, msg);

        // Print stack trace starting from the failing line
        scope trace = defaultTraceHandler(null);
        bool findStart = false;
        foreach (traceLine; trace)
        {
            if (!findStart)
            {
                if (traceLine.canFind("_d_assert"))
                    findStart = true;
                continue;
            }
            output.formattedWrite("%s\n", traceLine);
        }

        // We only want to print the logs if we're in the main thread,
        // which means we are unittests non-`agora.test` modules.
        // Modules in `agora.test` use network tests and they will call `printLogs`
        // on failure for each nodes themselves
        // See https://github.com/bosagora/agora/issues/1972
        if (Thread.getThis().isMainThread())
            CircularAppender!()().print(output);
        stdout.flush();
    }
    catch (Exception exc)
    {
        scope exc_name = typeid(exc).name;
        printf("Could not print thread logs because of %.*s (%.*s:%llu): %.*s\n",
            cast(int) exc_name.length, exc_name.ptr,
            cast(int) file.length, file.ptr, line, cast(int) msg.length, msg.ptr);
    }
    // We still want a stack trace, so throw anyway
    throw new AssertError(msg, file, line);
}

/// Custom unittest runner as a workaround for multi-threading issue:
/// Agora unittests spawn threads, which allocate. The Ocean tests
/// inspect GC stats for memory allocation changes, and potentially fail
/// if during such a test a runaway Agora unittest child thread allocates.
/// Workaround: Don't run ocean submodule unittests
private UnitTestResult customModuleUnitTester ()
{
    import std.parallelism;
    import std.process;
    import std.string;
    import std.uni;
    import std.conv;
    import core.atomic;
    import core.sync.semaphore;
    import core.thread.osthread;

    // display the thread's log buffer when an assertion fails during a test
    assertHandler = &testAssertHandler;

    //
    const chatty = ("dchatty" in environment) ?
        to!bool(environment["dchatty"]) : false;
    defaultLogLevel = environment.get("dloglevel", "Info").to!LogLevel;
    const all_single_threaded = ("dsinglethreaded" in environment) ?
        to!bool(environment["dsinglethreaded"]) : false;
    const should_fail_early = ("dfailearly" in environment) ?
        to!bool(environment["dfailearly"]) : true;
    auto filter = environment.get("dtest").toLower();
    size_t filtered;

    // Set the default log level for this thread
    Log.root.level(defaultLogLevel, true);

    // can't use ModuleInfo[], opApply returns temporaries..
    struct ModTest
    {
        string name;
        void function() test;
    }

    struct Tests
    {
        /// Simple tests are every tests not in 'agora.tests' package
        /// They run serially and first, as they might be checking GC usage
        ModTest[] simple;

        /// Integrations test that should run single-threaded
        ModTest[] serial;

        /// Integration tests that run multi-threaded (unless disabled)
        ModTest[] parallel;

        /// Integrations test that should run single-threaded even in a multi-threaded
        /// settings (heavy tests) - They are separate from serial because
        /// they must run last
        ModTest[] heavy;
    }

    Tests allTests;
    foreach (ModuleInfo* mod; ModuleInfo)
    {
        if (mod is null)
            continue;

        auto fp = mod.unitTest;
        if (fp is null)
            continue;

        // If it's not in the agora or scpd package, we don't care about it,
        // because it's one of our dependency (e.g. vibe.d or even Phobos)
        if (!mod.name.startsWith("agora") &&
            !mod.name.startsWith("scpd"))
            continue;

        if (filter.length > 0 && !canFind(mod.name.toLower(), filter.save))
        {
            filtered++;
            continue;
        }

        // We first run "simple" tests (e.g. those outside of this package)
        if (!mod.name.startsWith("agora.test."))
        {
            allTests.simple ~= ModTest(mod.name, fp);
            continue;
        }

        if (all_single_threaded)
            allTests.serial ~= ModTest(mod.name, fp);
        else if (mod.name == "agora.test.ManyValidators")
            allTests.heavy ~= ModTest(mod.name, fp);
        // due to problems with the parallelism test,
        // the test is performed with single threads
        else version (Windows)
            allTests.serial ~= ModTest(mod.name, fp);
        else
            allTests.parallel ~= ModTest(mod.name, fp);
    }

    shared size_t executed;
    shared size_t passed;

    bool runTest (ModTest mod)
    {
        atomicOp!"+="(executed, 1);
        try
        {
            import std.datetime.stopwatch : AutoStart, StopWatch;

            // Clear the buffer otherwise we may end up printing messages
            // from previous tests on failure
            // For nodes this is node in `agora.utils.Log`
            CircularAppender!()().clear();

            if (chatty)
            {
                auto output = stdout.lockingTextWriter();
                output.formattedWrite("Unittesting %s", mod.name);
                stdout.flush();
            }
            auto sw = StopWatch(AutoStart.yes);
            mod.test();
            sw.stop();
            if (chatty)
            {
                auto output = stdout.lockingTextWriter();
                output.formattedWrite(" (took %s)\n", sw.peek());
                stdout.flush();
            }

            atomicOp!"+="(passed, 1);
            return true;
        }
        catch (Throwable ex)
        {
            auto output = stdout.lockingTextWriter();
            output.formattedWrite("Module tests failed: %s\n", mod.name);
            output.formattedWrite("%s\n", ex);
            // print logs of the work thread
            CircularAppender!()().print(output);
            stdout.flush();
        }
        return false;
    }

    bool runSerially (ModTest[] thoseTests)
    {
        foreach (mod; thoseTests)
            if (!runTest(mod))
                if (should_fail_early)
                    return false;
        return true;
    }

    auto available_cores = new Semaphore(totalCPUs);
    auto finished_tasks_num = new Semaphore(0);
    // we cannot use phobos' parallel function, as that function will not
    // re-initialize static variables at the start of a new task
    void runInParallel (ModTest[] parallel_tests)
    {
        class WorkThread : Thread
        {
            ModTest test;
            this (ModTest test)
            {
                this.test = test;
                super(&this.run);
            }

            void run ()
            {
                scope (exit)
                {
                    available_cores.notify();
                    finished_tasks_num.notify();
                }
                runTest(this.test);
            }
        }

        while (parallel_tests.length)
        {
            auto test = parallel_tests.front;
            parallel_tests.popFront();

            // wait for a core to become available
            available_cores.wait();

            (new WorkThread(test)).start();
        }
    }

    // Run single-threaded tests
    const failed_early = !runSerially(allTests.simple) || !runSerially(allTests.serial);
    if (!failed_early)
    {
        // Then multi-threaded tests
        runInParallel(allTests.parallel);
        runInParallel(allTests.heavy);

        // waiting for all parallel tasks to finish
        iota(allTests.parallel.length).each!(x => finished_tasks_num.wait());
    }

    UnitTestResult result = { executed : executed, passed : passed };
    if (filtered > 0)
        writefln("Ran %s/%s tests (%s filtered)", result.executed,
            result.executed + filtered, filtered);
    if (failed_early)
    {
        writefln("Single threaded test failed early. Only %s/%s tests have been run",
                 executed,
                 allTests.simple.length + allTests.serial.length +
                 allTests.parallel.length + allTests.heavy.length);
    }

    // result.summarize = true;
    result.runMain = false;
    return result;
}

/// A custom serializer for LocalRest
public struct Serializer
{
    import agora.serialization.Serializer;

    static immutable(ubyte)[] serialize (T) (auto ref T value)
    {
        // `serializeFull` should be `@safe`, but `assumeUnique` is not
        return ((arr) @trusted => assumeUnique(arr))(serializeFull(value));
    }

    static QT deserialize (QT) (in ubyte[] data) @trusted
    {
        return deserializeFull!QT(data);
    }
}

/// A different default serializer from `LocalRest` for `RemoteAPI`
public alias RemoteAPI (APIType) = geod24.LocalRest.RemoteAPI!(APIType, Serializer);

/*******************************************************************************

    Task manager backed by LocalRest's event loop.

*******************************************************************************/

public class LocalRestTaskManager : ITaskManager
{
    static import geod24.LocalRest;

    /***************************************************************************

        Run an asynchronous task in LocalRest's event loop.

        Params:
            dg = the delegate the task should run

    ***************************************************************************/

    public override void runTask (void delegate() nothrow dg) nothrow
    {
        this.tasks_started++;
        geod24.LocalRest.runTask(dg);
    }

    @safe nothrow:
    /***************************************************************************

        Suspend the current task for the given duration

        Params:
            dur = the duration for which to suspend the task for

    ***************************************************************************/

    public override void wait (Duration dur) @trusted
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

        Return:
           An `ITimer` interface with the ability to control the timer

    ***************************************************************************/
    alias setTimer = typeof(super).setTimer;

    /// Ditto
    public override ITimer setTimer (Duration timeout,
        SafeTimerHandler dg, Periodic periodic = Periodic.No)
    {
        this.tasks_started++;
        return new LocalRestTimer(geod24.LocalRest.setTimer(timeout, dg,
            periodic));
    }

    /***************************************************************************

        Creates a new timer without arming it

        Works similarly to Vibe.d's `createTimer`.

        Params:
            dg = This delegate will be called when the timer fires

        Returns:
            An `ITimer` interface with the ability to control the timer

    ***************************************************************************/
    alias createTimer = typeof(super).createTimer;

    /// Ditto
    public override ITimer createTimer (SafeTimerHandler dg)
    {
        return new LocalRestTimer(geod24.LocalRest.createTimer(dg));
    }
}

/*******************************************************************************

    LocalRest only timer (for unittests)

*******************************************************************************/

private final class LocalRestTimer : ITimer
{
    import LocalRest = geod24.LocalRest;

    private LocalRest.Timer timer;

    @safe nothrow:
    public this (LocalRest.Timer timer)
    {
        this.timer = timer;
    }

    /// Ditto
    public override void stop ()
    {
        this.timer.stop();
    }

    /// Ditto
    public override void rearm (Duration timeout, bool periodic)
    {
        this.timer.rearm(timeout, periodic);
    }

    /// Ditto
    public override bool pending ()
    {
        return this.timer.pending();
    }
}

/// We use a pair of (key, client) rather than a hashmap client[key],
/// since we want to know the order of the nodes which were configured
/// in the makeTestNetwork() call.
public struct APIPair (API)
{
    ///
    public Address address;

    ///
    public RemoteAPI!API client;

    ///
    public inout(API) api () inout @safe pure nothrow @nogc
    {
        return this.client;
    }

    /// Expose the `api` by default so one doesn't accidentally use `ctrl`
    alias api this;
}

/// Holds an `APIPair` along with the node's time
public struct NodePair
{
    ///
    public this (Address address, RemoteAPI!TestAPI client, shared(TimePoint)* time)
        @safe pure nothrow @nogc
    {
        this.pair = APIPair!TestAPI(address, client);
        this.cur_time = time;
    }

    /// Underlying APIPair
    public APIPair!TestAPI pair;
    public alias pair this;

    /// the adjustable local clock time for this node.
    /// This does not affect request timeouts and is only
    /// used in the Nomination protocol.
    private shared(TimePoint)* cur_time;

    /// Get the current clock time
    @property TimePoint time () @trusted @nogc nothrow
    {
        return atomicLoad(*this.cur_time);
    }

    /// Set the new time
    @property void time (TimePoint new_time) @trusted @nogc nothrow
    {
        atomicStore(*this.cur_time, new_time);
    }
}

/*******************************************************************************

    Instantiate and manages an in-memory test network.

    Allows unittests to spawn, communicate, and control the full network.
    Each unittest block should instantiate this class at most once.
    Multiple configuration points exist, such as `createNewNode` (to inject
    different node types), `createNameRegistry`, etc...

*******************************************************************************/

public class TestNetwork (TValidator = TestValidator, TFullNode = TestFullNode)
    : TestAPIManager
{
    ///
    mixin ForwardCtor!();

    ///
    public override void createNewNode (
        Config conf, string file = __FILE__, int line = __LINE__)
    {
        if (conf.validator.enabled)
            this.addNewNode!TValidator(conf, file, line);
        else
            this.addNewNode!TFullNode(conf, file, line);
    }
}

/// Ditto
public class TestAPIManager
{
    /// Test configuration
    protected TestConf test_conf;

    /// The name registry used in this network
    public NodePair dns;

    /// Used by the unittests in order to directly interact with the nodes,
    /// without trying to handshake or do any automatic network discovery.
    /// Also kept here to avoid any eager garbage collection.
    public NodePair[] nodes;

    /// Contains the initial blockchain state of all nodes
    public immutable(Block)[] blocks;

    /// Start time of the tests
    public const TimePoint test_start_time;

    /// The initial clock time of every spawned node. Note that if there were
    /// any extra blocks loaded (`blocks` in the ctor) then the initial time
    /// will be test_start_time + (last_height * block_interval)
    protected TimePoint initial_time;

    /// convenience: returns a random-access range which lets us access clients
    public auto clients ()
    {
        return this.nodes.map!(np => np.client);
    }

    /// Convenience function to get a range of all nodes instantiated as validators
    public auto validators ()
    {
        // This is a crude way to get validators, but it works
        return this.nodes.filter!(n => n.client.handshake(PublicKey.init).key != PublicKey.init).map!(n => n.client);
    }

    /// Registry holding the nodes
    protected AnyRegistry registry;

    ///
    public this (immutable(Block)[] blocks, TestConf test_conf,
        TimePoint test_start_time)
    {
        this.test_conf = test_conf;
        this.blocks = blocks;
        this.test_start_time = test_start_time;
        this.initial_time = test_start_time;
        this.registry.initialize();
    }

    /***************************************************************************

        Sets the clock time to the expected clock time to produce a block at
        the given height, and verifies that the nodes have generated a block
        at the given block height.

        The overload allows passing a subset of nodes indices to verify the
        block heights for only these nodes. Note that the clock time is adjusted
        for all nodes (this is what most tests expect).

        Params:
            height = the expected block height
            timeout = the request timeout to each node

    ***************************************************************************/

    public void expectHeight (Height height, Duration timeout = 10.seconds,
        string file = __FILE__, int line = __LINE__)
    {
        this.expectHeight(iota(this.clients.length), height, timeout,
            file, line);
    }

    /// Ditto
    public void expectHeight (Idxs)(Idxs clients_idxs, Height height,
        Duration timeout = 10.seconds,
        string file = __FILE__, int line = __LINE__)
    {
        static assert (isInputRange!Idxs);

        this.setTimeFor(height);
        clients_idxs.each!(idx =>
            retryFor(clients[idx].getBlockHeight() == height, timeout,
                format("Node %s has block height %s. Expected: %s",
                    idx, clients[idx].getBlockHeight(), height), file, line));
    }

    /***************************************************************************

        Checks the needed pre-images are revealed, sets the clock time to the
        expected clock time to produce a block at the given height, and verifies
        that the nodes have generated a block at the given block height.

        The overload allows passing a subset of node indices to verify the block
        heights for only these nodes. Note that the clock time is adjusted
        for all nodes (this is what most tests expect).

        Params:
            height = the expected block height
            enroll_header = the header which contains enrollment information
            timeout = the request timeout to each node

    ***************************************************************************/

    public void expectHeightAndPreImg (Height height,
        const(BlockHeader) enroll_header = GenesisBlock.header,
        Duration timeout = 10.seconds,
        string file = __FILE__, int line = __LINE__)
    {
        this.expectHeightAndPreImg(iota(this.test_conf.node.test_validators), height, enroll_header,
            timeout, file, line);
    }

    /// Ditto
    public void expectHeightAndPreImg (Idxs)(Idxs clients_idxs, Height height,
        const(BlockHeader) enroll_header = GenesisBlock.header,
        Duration timeout = 10.seconds,
        string file = __FILE__, int line = __LINE__)
    {
        static assert (isInputRange!Idxs);

        assert(height > enroll_header.height);
        this.waitForPreimages(clients_idxs, enroll_header.enrollments, height, timeout);
        this.expectHeight(clients_idxs, height, timeout, file, line);
    }

    /***************************************************************************

        Checks if all the nodes contain the given height of pre-images for
        the given enrollments.

        The overload allows passing a subset of nodes to verify the height
        for only these nodes.

        Params:
            enrolls = the enrollments whose pre-image will be checked
            height = the expected height of pre-images
            timeout = the request timeout to each node

    ***************************************************************************/

    public void waitForPreimages (const(Enrollment)[] enrolls, Height height,
        Duration timeout = 10.seconds)
    {
        this.waitForPreimages(iota(this.test_conf.node.test_validators), enrolls, height, timeout);
    }

    /// Ditto
    public void waitForPreimages (Idxs)(Idxs clients_idxs,
        const(Enrollment)[] enrolls, Height height,
        Duration timeout = 10.seconds)
    {
        static assert (isInputRange!Idxs);
        import std.algorithm.searching : any;

        clients_idxs.each!(idx =>
            enrolls.enumerate.each!((idx_enroll, enroll) {
                if (clients_idxs.canFind(idx_enroll))
                    retryFor(this.clients[idx].getPreimages(Set!Hash.from(enroll.utxo_key.only))
                        .any!(preimage => preimage.height >= height),
                            timeout, format!"Client #%s has no preimage for client #%s at distance %s"
                            (idx, idx_enroll, height));
            }));
    }

    /***************************************************************************

        Set the new clock time for all node instances based on the block height.

        The overload allows passing a subset of nodes to simulate clock drift.

        Note that `synchronizeClocks()` must be called manually to adjust the
        net time clock offset of each node.

        Params:
            new_time = the new clock time

    ***************************************************************************/

    public void setTimeFor (Height height)
    {
        this.setTimeFor(this.nodes, height);
    }

    /// Ditto
    public void setTimeFor (Pairs)(Pairs pairs, Height height)
    {
        static assert (isInputRange!Pairs);

        const exp_time = this.test_start_time +
            this.test_conf.consensus.block_interval.total!"seconds" * height;
        // We also need to set the registry time, because otherwise their Ledger
        // will reject new blocks as they exceed tolerance.
        // Note that this relies on the time moving forward only.
        this.dns.time = exp_time;
        foreach (pair; pairs)
            pair.time = exp_time;
    }

    /***************************************************************************

        Synchronize the clocks of all nodes.

        Note that this is not done implicitly in `setTimeFor` as this might
        only synchronize the clocks for a subset of the passed clients.

    ***************************************************************************/

    public void synchronizeClocks ()
    {
        // calculate the network time offset based on the node's quorum set
        foreach (node; this.nodes)
            node.client.synchronizeClock();
    }

    /***************************************************************************

        Create a new node

        Params:
            conf = the configuration passed on to the Node constructor

    ***************************************************************************/

    public void createNewNode (Config conf, string file = __FILE__, int line = __LINE__)
    {
        if (conf.validator.enabled)
            this.addNewNode!TestValidatorNode(conf, file, line);
        else
            this.addNewNode!TestFullNode(conf, file, line);
    }

    /***************************************************************************

        Convenience templated function to be called from overriding classes

        Params:
          conf = The configuration for this node (usually forwarded from
                 within `createNewNode`)
          eArgs = The arguments `NodeType` has which are after `TestFullNode`'s
                  (or `TestValidatorNode`'s) constructor arguments.
          file = File this function is called for, forwarded to localrest for
                 better debugging output.
          line = Line this function is called for, forwarded to localrest for
                 better debugging output.

        Note:
          The "extra arguments" parameter, `eArgs`, makes a few assumptions
          which might not hold in the future, most importantly:
          - `TestFullNode` and `TestValidatorNode` have the same ctor args;
          - Arguments for `NodeType` are in the same order as its parent;

    ***************************************************************************/

    public TestAPI addNewNode (NodeType : TestAPI) (Config conf,
        Parameters!(NodeType.__ctor)[Parameters!(TestValidatorNode.__ctor).length .. $] eArgs,
        string file = __FILE__, int line = __LINE__)
    {
        auto time = new shared(TimePoint)(this.initial_time);
        auto api = RemoteAPI!TestAPI.spawn!NodeType(conf, &this.registry,
            this.blocks, this.test_conf, time, eArgs,
            conf.node.timeout, file, line);

        foreach (ref interf; conf.interfaces)
        {
            // The 'interfaces' technically contains netmask on which to bind,
            // so we're "abusing" it by using a fixed IP.
            auto address = Address("agora://" ~ interf.address);
            assert(this.registry.register(address.host, api.listener()));
            this.nodes ~= NodePair(address, api, time);
        }
        return api;
    }

    /***************************************************************************

        Create a new name registry

        The name registry is a full node that exposes a more advanced interface.
        It is not part of the `nodes` array, but is reachable as a designed
        address (currently "10.8.8.8").

        Params:
          conf = The `FullNode` configuration to use.
          file = File this function is called for, forwarded to localrest for
                 better debugging output.
          line = Line this function is called for, forwarded to localrest for
                 better debugging output.

    ***************************************************************************/

    public void createNameRegistry (Config conf, string file, int line)
    {
        assert(conf.interfaces.length == 1);

        auto time = new shared(TimePoint)(this.initial_time);
        auto cli = RemoteAPI!FullRegistryAPI.spawn!RegistryNode(
            conf, &this.registry, this.blocks, this.test_conf, time,
            conf.node.timeout, file, line);
        auto casted = new RemoteAPI!(TestAPI)(cli.listener(), conf.node.timeout);

        auto address = Address("agora://" ~ conf.interfaces[0].address);
        this.dns = NodePair(address, casted, time);
        assert(this.registry.register(address.host, cli.listener()));
    }

    /***************************************************************************

        Start each of the nodes

        Params:
            count = Expected number of nodes

    ***************************************************************************/

    public void start ()
    {
        scope startDg = (scope TestAPI api) { api.start(); };

        // have to wait indefinitely as the constructor is
        // currently a slow routine, stalling the call to start().
        this.dns.client.ctrl.withTimeout(0.msecs, startDg);
        foreach (node; this.nodes)
            node.client.ctrl.withTimeout(0.msecs, startDg);
    }

    /***************************************************************************

        Shut down each of the nodes

        Params:
          printLogs = Whether or not to print nodes logs

    ***************************************************************************/

    public void shutdown (bool printLogs = false)
    {
        /// Private functions used for `shutdown`
        static void shutdownWithLogs (Object node)
        {
            (cast(FullNode)node).shutdown();
            (cast(TestAPI)node).printLog();
        }
        static void shutdownSilent (Object node)
        {
            (cast(FullNode)node).shutdown();
        }

        foreach (ref node; this.nodes)
        {
            node.client.ctrl.shutdown(
                printLogs ? &shutdownWithLogs : &shutdownSilent);
            node.client = null;
        }

        this.registry.clear();
        this.nodes = null;

        this.dns.client.ctrl.shutdown(
            printLogs ? &shutdownWithLogs : &shutdownSilent);
        this.dns.client = null;
    }

    /***************************************************************************

        Restart a specific node

        This routine restarts the given `client`, making sure it gracefully
        shuts down then restart properly.

        Params:
          client = Reference to the client to restart

    ***************************************************************************/

    public void restart (scope RemoteAPI!TestAPI client)
    {
        client.ctrl.restart((Object node) { (cast(FullNode)node).shutdown(); });
        client.ctrl.withTimeout(0.msecs, (scope TestAPI api) { api.start(); });
    }

    /***************************************************************************

        Print out the logs for each node

    ***************************************************************************/

    public void printLogs (string file = __FILE__, int line = __LINE__)
    {
        synchronized  // make sure logging output is not interleaved
        {
            writeln("---------------------------- START OF LOGS ----------------------------");
            writefln("%s(%s): Node logs:\n", file, line);
            foreach (node; this.nodes)
            {
                try
                    node.client.printLog();
                catch (Exception ex)
                    writefln("Could not print logs for node %s: %s", node.address, ex.message);
            }
            writeln("Registry logs:");
            try
                this.dns.printLog();
            catch (Exception ex)
                writefln("Could not print registry logs (%s): %s", this.dns.address, ex.message);
        }
    }

    /***************************************************************************

        Keep polling for nodes to reach discovery, up to 5 seconds.

        If network discovery isn't reached, it will throw an Error.

    ***************************************************************************/

    public void waitForDiscovery (Duration timeout = 5.seconds,
        string file = __FILE__, int line = __LINE__)
    {
        foreach (idx, ref node; this.nodes)
        {
            NodeInfo ni;
            retryFor({
                    ni = node.client.getNodeInfo().ifThrown(NodeInfo.init);
                    return ni.state == NetworkState.Complete;
                }(),
                timeout,
                format("Node %s (%s) has not completed discovery after %s: %s",
                       idx, node.address, timeout, ni),
                file, line,
            );
        }
    }

    /***************************************************************************

        Add blocks up to the provided height

        This is a helper function to enable some common steps to getting blocks
            externalized during the Network Unit tests

        Params:
            height = the desired block height
            client_idxs = client indices for the participating validators

    ***************************************************************************/

    public void generateBlocks (Height height, bool no_txs = false,
        string file = __FILE__, int line = __LINE__)
    {
        this.generateBlocks(iota(this.test_conf.node.test_validators), height, no_txs, file, line);
    }

    /// Ditto
    public void generateBlocks (Idxs)(Idxs client_idxs, Height height,
        bool no_txs = false, string file = __FILE__, int line = __LINE__)
    {
        static assert (isInputRange!Idxs);

        // Get the last block from the first client
        auto client = this.clients[client_idxs.front];
        const last_block = client.getBlock(client.getBlockHeight());

        // Call addBlock for each block to be externalised for these clients
        iota(height - last_block.header.height)
            .each!(_ => this.addBlock(client_idxs, no_txs, file, line));
    }

    /**************************************************************************

        Add a block

        This is a helper function to perform the steps required to get a block
            externalized during the Network Unit tests

        Params:
            client_idxs = client indices for the participating validators

    ***************************************************************************/

    void addBlock (bool no_txs = false,
        string file = __FILE__, int line = __LINE__)
    {
        this.addBlock(iota(0, this.test_conf.node.test_validators), no_txs, file, line);
    }

    /// Ditto
    void addBlock (Idxs)(Idxs client_idxs, bool no_txs = false,
        string file = __FILE__, int line = __LINE__)
    {
        static assert (isInputRange!Idxs);

        auto first_client = this.clients[client_idxs.front];
        auto last_height = first_client.getBlockHeight();
        // target height will be one more than previous block
        Height target_height = Height(last_height + 1);

        if (!no_txs)
        {
            auto utxo_pairs = first_client.getSpendables(1.coins, OutputType.Payment);
            auto tx = TxBuilder(utxo_pairs[0].utxo.output.address) // refund
                .attach(utxo_pairs.map!(p => tuple(p.utxo.output, p.hash)))
                .sign();

            first_client.postTransaction(tx);
            // Wait for tx gossipping before setting time for block
            client_idxs.each!(idx =>
                retryFor(this.clients[idx].hasTransactionHash(tx.hashFull()),
                    4.seconds, format!"[%s:%s] Client #%s did not receive tx in expected time for height %s"
                        (file, line, idx, target_height)));
        }

        // Get preimage height from enrollment to this next block
        auto enrolled_height = target_height <= GenesisValidatorCycle ? 0
            : target_height - ((target_height - 1) % GenesisValidatorCycle) - 1;
        assert(enrolled_height % GenesisValidatorCycle == 0,
            format!"[%s:%s] Invalid enroll height calculated as %s for target height %s"
                (file, line, enrolled_height, target_height));
        // Check block is at target height for the participating clients
        const enroll_block = first_client.getBlock(enrolled_height);
        this.expectHeightAndPreImg(client_idxs, target_height,
            enroll_block.header, 10.seconds, file, line);
    }

    /**************************************************************************

        Prepare frozen utxo for outsiders to enroll

        This is a helper function to find unspent utxo and make a transaction
            with frozen outputs to be used to enroll.

        Params:
            client_idxs = client indices for the outsider validators

    ***************************************************************************/

    Transaction freezeUTXO (Idxs)(Idxs client_idxs)
    {
        static assert (isInputRange!Idxs);

        auto first_client = this.clients[0];

        const keys = client_idxs.map!(i => this.nodes[i].getPublicKey().key).array;

        // Collect enough utxo for all to enroll
        Amount expected = Amount.MinFreezeAmount + 10_000.coins;
        assert(expected.mul(keys.length));
        auto utxo_pairs = first_client.getSpendables(expected, OutputType.Payment);

        return TxBuilder(utxo_pairs[0].utxo.output.address) // refund
            .attach(utxo_pairs.map!(p => tuple(p.utxo.output, p.hash)))
            .draw(Amount.MinFreezeAmount, keys) // draw min freeze to enroll for each
            .sign(OutputType.Freeze);
    }

    /***************************************************************************

        Enroll validator

        This is a helper function to enroll a validator and wait till
            other validators have the enroll on their pool

        Params:
            client_idx = the index of the client to enroll
            client_idxs = client indices for the participating validators

    ***************************************************************************/

    void enroll (size_t client_idx)
    {
        enroll(iota(this.test_conf.node.test_validators), client_idx);
    }

    /// Ditto
    void enroll (Idxs)(Idxs client_idxs, size_t client_idx,
        string file = __FILE__, int line = __LINE__)
    {
        static assert (isInputRange!Idxs);

        auto enroll = clients[client_idx].setRecurringEnrollment(true);
        client_idxs.each!(idx =>
            retryFor(this.clients[idx].getEnrollment(enroll.utxo_key) == enroll,
                5.seconds,
                format!"[%s:%s] Client #%s enrollment not in pool of client #%s"
                    (file, line, client_idx, idx)));
    }

    /***************************************************************************

        Assert all the nodes contain the same blocks

        This is a helper function to confirm all nodes have the same blocks
        Note that the `from` and `to` are reversed to enable default value

        Params:
            client_idxs = client indices for the nodes to be checked
            to = expected block height of the nodes
            from = start of range for comparing the blocks

    ***************************************************************************/

    void assertSameBlocks (Height to, Height from = Height(0),
        string file = __FILE__, int line = __LINE__)
    {
        assertSameBlocks(iota(this.test_conf.node.test_validators), to, from, file, line);
    }

    /// Ditto
    void assertSameBlocks (Idxs)(Idxs client_idxs, Height to,
        Height from = Height(0), string file = __FILE__, int line = __LINE__)
    {
        static assert (isInputRange!Idxs);
        assert(to >= from,
            format!"[%s:%s] Please provide valid heights as params. Not %s .. %s"
            (file, line, from, to));

        client_idxs.each!(idx =>
            retryFor(Height(this.clients[idx].getBlockHeight()) == to,
                5.seconds,
                format!"[%s:%s] Expected height %s for client #%s not %s"
                    (file, line, to, idx,
                        this.clients[idx].getBlockHeight())));

        // Compare blocks one at a time
        iota(from, to + 1).each!(h =>
            retryFor(client_idxs.map!(idx =>
                this.clients[idx].getBlocksFrom(h, 1).hashFull).uniq().count() == 1, 5.seconds,
                format!"[%s:%s] Clients %s blocks are not all the same for block %s: %s"
                (file, line, client_idxs, h, client_idxs.fold!((s, i) =>
                    s ~ format!"\n\n========== Client #%s (%s) ==========%s"
                        (i, this.nodes[i].address,
                        prettify(this.clients[i].getBlocksFrom(h, 1))))(""))));
    }

    /// Expect a TX to be externalized within certain number of blocks
    void expectTxExternalization (Transaction tx, ulong n_blocks = 3)
    {
        this.expectTxExternalization(only(tx.hashFull()), n_blocks);
    }

    /// Ditto
    void expectTxExternalization (Hash tx_hash, ulong n_blocks = 3)
    {
        this.expectTxExternalization(only(tx_hash), n_blocks);
    }

    /// Ditto
    void expectTxExternalization (Hashes)(Hashes tx_hashes, ulong n_blocks = 3)
    {
        Set!Hash hashes = Set!Hash.from(tx_hashes);
        auto last_height = Height(this.clients.map!(client => client.getBlockHeight()).maxElement);
        foreach (idx; 0 .. n_blocks)
        {
            auto next_height = Height(last_height + idx + 1);
            this.expectHeightAndPreImg(next_height);
            auto block = this.clients[0].getBlock(next_height);
            block.txs.each!(tx => hashes.remove(tx.hashFull()));
            if (hashes.length == 0)
                return;
        }
        throw new Exception(format!"TXs %s were not externalized in %d blocks!"(tx_hashes, n_blocks));
    }

    /// Post a transaction to clients and ensure it is accepted by them (put in the tx pool)
    public void postAndEnsureTxInPool (in Transaction tx)
    {
        this.postAndEnsureTxInPool(iota(this.clients.length), tx);
    }

    /// Ditto
    public void postAndEnsureTxInPool (Idxs) (Idxs clients_idxs, in Transaction tx)
    {
        clients_idxs.each!(idx => this.clients[idx].postTransaction(tx));
        this.ensureTxInPool(clients_idxs, tx.hashFull());
    }

    /// Ensure that a transaction has been put in the tx pools of the client indices
    public void ensureTxInPool (Idxs) (Idxs clients_idxs, in Hash hash)
    {
        retryFor(clients_idxs.all!(idx => this.clients[idx].hasTransactionHash(hash)), 3.seconds);
    }

    /// Ditto
    public void ensureTxInPool (in Hash hash)
    {
        this.ensureTxInPool(iota(this.clients.length), hash);
    }

    /// Returns: A newly instantiated DNS resolver usable for testing
    public DNSResolver makeDNSResolver (
        Address[] peer_addrs = null, Duration timeout = 10.seconds)
    {
        return new LocalRestDNSResolver(peer_addrs, this.registry, timeout);
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
    import agora.api.Handlers;

    /// Remove this once `registerListener` is gone
    private string address;

    /// This is the "network router": It takes an address (e.g. an IPv4)
    /// and converts it to a pointer (e.g. something that can route the message).
    public AnyRegistry* registry;

    /// Constructor
    public this (Parameters!(NetworkManager.__ctor) args, string address,
                 AnyRegistry* reg)
    {
        super(args);
        this.registry = reg;
        this.address = address;
    }

    ///
    protected final override TestAPI getClient (Address address)
    {
        auto tid = this.registry.locate!TestAPI(address.host);
        if (tid != typeof(tid).init)
            return new RemoteAPI!TestAPI(tid, this.config.node.timeout);
        assert(0, format("Trying to access node at address '%s' from '%s' without first creating it",
                         address, this.address));
    }

    ///
    public override RemoteAPI!NameRegistryAPI getRegistryClient (string address)
    {
        assert(address != string.init, "Requested address for registry is empty");
        const url = Address(address);
        auto tid = this.registry.locate!NameRegistryAPI(url.host);
        if (tid != typeof(tid).init)
            return new RemoteAPI!NameRegistryAPI(tid, this.config.node.timeout);
        assert(0, "Trying to access name registry at address '" ~ address ~
               "' without first creating it");
    }

    /// Returns an instance of a DNSResolver
    public override DNSResolver makeDNSResolver (Address[] peer_addrs = null)
    {
        return new LocalRestDNSResolver(peer_addrs, *this.registry);
    }

    ///
    protected final override BlockExternalizedHandler getBlockExternalizedHandler
        (Address address)
    {
        import std.typecons : BlackHole;
        auto tid = this.registry.locate!BlockExternalizedHandler(address.host);
        if (tid != typeof(tid).init)
            return new RemoteAPI!BlockExternalizedHandler(tid, 5.seconds);

        return new BlackHole!BlockExternalizedHandler();
    }

    ///
    protected final override BlockHeaderUpdatedHandler getBlockHeaderUpdatedHandler
        (Address address)
    {
        assert(0, "Not supported");
    }

    ///
    protected final override PreImageReceivedHandler getPreImageReceivedHandler
        (Address address)
    {
        assert(0, "Not supported");
    }

    ///
    protected final override TransactionReceivedHandler getTransactionReceivedHandler
        (Address address)
    {
        assert(0, "Not supported");
    }
}

/*******************************************************************************

    API implemented by the test nodes runs by LocalRest

    This API inherits from the validator API, and simply adds a few functions that
    should not be public in a real-world scenario, but are needed in our test
    setup. Those functions trigger a specific action (e.g. `start`, `printLog`),
    or in rare cases are a way to force a node to take a specific action.

    However, adding a method here should be carefully considered, as most of the
    time, the prefered approach to test a specific behavior on a node would be
    to instantiate a different kind of node (derive from `TestFullNode` or
    `TestValidatorNode` and implement the desired behavior), as this approach
    will be localized to the test, instead of being available to every tests.

    Besides the current functions, extra functionalities that would fit in this
    interface would be machine state changes, e.g. `removeDisk`.

*******************************************************************************/

public interface TestAPI : API
{
    /***************************************************************************

        Start the node

        The `FullNode` have a `start` method that is scheduled by the `main`
        function to start discovery / catchup, etc...
        Since our node is not instantiated through `main`, the `APIManager`
        will call this function directly after instantiating a new node.

    ***************************************************************************/

    public void start ();

    /***************************************************************************

        Print out the contents of the log

        Each node logs to their own buffer in their own Thread, which is written
        to a circular buffer to save on memory.
        Calling this function will dump the content of the node's log buffer
        to stderr. `TestAPIManager` provides a convenient way to call
        this method for every node, and most tests will do this on test failure.

    ***************************************************************************/

    public void printLog ();

    /***************************************************************************

        Clear a node's logs

        This forces a node to clear its logs, which can be useful for tests
        that produce a lot of logs, for example when many blocks are created.

    ***************************************************************************/

    public void clearLog ();

    /***************************************************************************

        Toggle enrollment

        Check if the next enrollment is available or validator is not enrolled.
        Make a node to enroll when necessary.

        Params:
            doIt = if the enrollments will be renewed continuouly or not

        Returns:
            The `Enrollment` used to enroll with,
            or `Enrollment.init` if an enrollment is not possible

    ***************************************************************************/

    public Enrollment setRecurringEnrollment (bool doIt);

    ///
    public QuorumConfig getQuorumConfig ();

    /// Get the active validator count for the current block height
    public ulong countActive (in Height height);

    /// Get the list of expected quorum configs
    public QuorumConfig[] getExpectedQuorums (in PublicKey[], Height);

    /***************************************************************************

        Synchronize the node's clock with the network

    ***************************************************************************/

    public void synchronizeClock ();

    /***************************************************************************

        Returns:
            the adjusted clock time taking into account the clock drift compared
            to the median value of the quorum set clock measurements

    ***************************************************************************/

    public TimePoint getNetworkTime ();

    /***************************************************************************

        Returns:
            true if the tx hash was at one point accepted to the tx pool,
            even if it was later removed (e.g. during block externalization)

    ***************************************************************************/

    public bool hasAcceptedTxHash (Hash tx_hash);

    /***************************************************************************

        Get unspent outputs from the test UTXO set

        Params:
            minimum = minimum Amount needed in the returned unspent UTXOs
            output_type = output type (payment / freeze) of desired utxos

        Returns:
            Array of `UTXOPair` that can be used by calling test code to create
            a `Transaction` using `TxBuilder`

    ***************************************************************************/

    public UTXOPair[] getSpendables (Amount minimum,
        OutputType output_type = OutputType.Payment);

    /***************************************************************************

        Params:
            owner = PublicKey of utxo owner

        Returns:
            Array of `UTXOPair` that belong to the provided owner

    ***************************************************************************/

    public UTXOPair[] getUTXOs (PublicKey owner);

    /***************************************************************************

        Params:
            hash = utxo hash value

        Returns:
            UTXO for provided hash value

    ***************************************************************************/

    public UTXO getUTXO (Hash hash);

    /***************************************************************************

        Params:
            address = the address of node to query

        Returns:
            if `address` is banned or not

    ***************************************************************************/

    public bool isBanned (Address address);

    /***************************************************************************

        Params:
            utxo = the frozen utxo

        Returns:
            if `utxo` still has penalty deposit or not

    ***************************************************************************/

    public Amount getPenaltyDeposit (Hash utxo);
}

/// Return type for `TestAPI.getUTXOs`
public struct UTXOPair
{
    ///
    public Hash hash;

    ///
    public UTXO utxo;
}

/// Contains routines which are implemented by both TestFullNode and
/// TestValidator. Used because TestValidator inherits from Validator but
/// cannot inherit from TestFullNode, as it already inherits from Validator class
/// (multiple-inheritance is not supported in D)
private mixin template TestNodeMixin ()
{
    /// The network registry (note that the parent class has a `registry` member)
    protected AnyRegistry* nregistry;

    /// pointer to the unittests-adjusted clock time
    protected shared(TimePoint)* cur_time;

    /// All txs which were at one point accepted into the tx pool
    protected Set!Hash accepted_txs;

    /// Blocks to preload into the memory storage
    private immutable(Block)[] blocks;

    ///
    public override void start ()
    {
        super.start();
    }

    /// Prints out the log contents for this node
    public override void printLog ()
    {
        auto output = stdout.lockingTextWriter();
        output.formattedWrite("Log for node: %s\n", this.config.interfaces[0].address);
        output.put("======================================================================\n");
        CircularAppender!()().print(output);
        output.put("======================================================================\n\n");
        stdout.flush();
    }

    ///
    public override void clearLog ()
    {
        CircularAppender!()().clear();
    }

    protected override IBlockStorage makeBlockStorage () @system
    {
        return new MemBlockStorage(this.blocks);
    }

    protected override ManagedDatabase makeStateDB ()
    {
        return new ManagedDatabase(":memory:");
    }

    protected override ManagedDatabase makeCacheDB ()
    {
        return new ManagedDatabase(":memory:");
    }

    /// Return a LocalRest-backed task manager
    protected override ITaskManager makeTaskManager ()
    {
        return new LocalRestTaskManager();
    }

    /// Return an instance of the custom TestNetworkManager
    protected override NetworkManager makeNetworkManager (
        ITaskManager taskman, Clock clock)
    {
        assert(taskman !is null);
        return new TestNetworkManager(
            this.config, this.cacheDB, taskman, clock, this,
            this.config.interfaces[0].address,
            this.nregistry);
    }

    /// Return an enrollment manager backed by an in-memory SQLite db
    protected override EnrollmentManager makeEnrollmentManager ()
    {
        return super.makeEnrollmentManager();
    }

    /// Get the active validator count for the current block height
    public override ulong countActive (in Height height)
    {
        return this.ledger.validatorCount(height);
    }

    /// Manually initiate a clock synchronization event
    public override void synchronizeClock ()
    {
        this.clock.synchronize();
    }

    /// Return the adjusted clock time
    public override TimePoint getNetworkTime ()
    {
        return this.clock.networkTime();
    }

    /***************************************************************************

        Overrides base function to keep statistics about accepted txs.

    ***************************************************************************/

    public override TransactionResult postTransaction (in Transaction tx) @safe
    {
        auto result = super.postTransaction(tx);
        const tx_hash = tx.hashFull();
        if (tx_hash !in this.accepted_txs &&
            this.pool.hasTransactionHash(tx_hash))
            this.accepted_txs.put(tx_hash);

        return result;
    }

    /***************************************************************************

        Returns:
            true if the tx hash was at one point accepted to the tx pool,
            even if it was later removed (e.g. during block externalization)

    ***************************************************************************/

    public bool hasAcceptedTxHash (Hash tx_hash)
    {
        return !!(tx_hash in this.accepted_txs);
    }

    ///
    public override UTXOPair[] getSpendables (Amount minimum,
        OutputType output_type = OutputType.Payment)
    {
        UTXOPair[] result;
        Amount accumulated;
        foreach (const ref Hash key, const ref UTXO value; this.ledger.utxos)
        {
            if (value.output.type == output_type && !this.pool.spending(key))
            {
                result ~= UTXOPair(key, value);
                accumulated += value.output.value;
                if (accumulated >= minimum)
                    return result;
            }
        }
        throw new Exception("Exhausted UTXO without finding enough coins!");
    }

    ///
    public override UTXOPair[] getUTXOs (PublicKey owner)
    {
        return this.ledger.utxos.getUTXOs(owner).byKeyValue
            .map!((pair) => UTXOPair(pair.key, pair.value)).array;
    }

    ///
    public override UTXO getUTXO (Hash hash)
    {
        UTXO result;
        if (!this.ledger.peekUTXO(hash, result))
            throw new Exception(format("UTXO not found: %s", hash));
        return result;
    }

    /// Check if an address is banned
    public override bool isBanned (Address address)
    {
        return this.network.getBanManager().isBanned(address);
    }

    ///
    public override Amount getPenaltyDeposit (Hash utxo)
    {
        return this.ledger.getPenaltyDeposit(utxo);
    }

}

///
public class TestClock : Clock
{
    ///
    private shared(TimePoint)* cur_time;

    ///
    public this (ITaskManager taskman, GetNetTimeOffset getNetTimeOffset,
        shared(TimePoint)* cur_time)
    {
        super(getNetTimeOffset,
            (Duration duration, void delegate() cb) nothrow @trusted
                { taskman.setTimer(duration, cb, Periodic.Yes); });
        this.cur_time = cur_time;
    }

    ///
    public override TimePoint localTime ()
    {
        return atomicLoad(*this.cur_time);
    }

    /// we manually sync the clocks in the tests, not using the timer
    public override void startSyncing () @safe nothrow
    {

    }
}

/// A FullNode which also implements test routines in TestAPI
public class TestFullNode : FullNode, TestAPI
{
    ///
    mixin TestNodeMixin!();

    ///
    public this (Config config, AnyRegistry* reg, immutable(Block)[] blocks,
        in TestConf test_conf, shared(TimePoint)* cur_time)
    {
        this.nregistry = reg;
        this.blocks = blocks;
        this.cur_time = cur_time;

        // Keep in sync with `TestValidator` ctor
        Log.root.level(atomicLoad(defaultLogLevel), true);
        foreach (const ref settings; config.logging)
        {
            auto log = settings.name ? Log.lookup(settings.name) : Log.root;
            log.level(settings.level, settings.propagate);
        }

        super(config);
    }

    /// Provides a unittest-adjusted clock source for the node
    protected override TestClock makeClock ()
    {
        return new TestClock(this.taskman,
            (out Duration time_offset) { return true; }, this.cur_time);
    }

    /// ditto
    public override Enrollment setRecurringEnrollment (bool doIt)
    {
        assert(0);
    }

    /// FullNode does not implement this
    public override Identity getPublicKey (PublicKey key = PublicKey.init) @safe
    {
        // NetworkManager assumes that if key == PublicKey.init,
        // we are *not* a Validator node, treated as a FullNode instead.
        return Identity.init;
    }

    /// FullNode does not implement this
    public override void postEnvelope (SCPEnvelope envelope) @safe
    {
        assert(0);
    }

    /// ditto
    public override void postBlockSignature (ValidatorBlockSig block_sig) @safe
    {
        assert(0);
    }

    /// ditto
    public override QuorumConfig getQuorumConfig ()
    {
        assert(0);
    }

    /// ditto
    public override QuorumConfig[] getExpectedQuorums (in PublicKey[], Height)
    {
        assert(0);
    }
}

/// A Validator which also implements test routines in TestAPI
public class TestValidatorNode : Validator, TestAPI
{
    ///
    mixin TestNodeMixin!();

    ///
    public this (Config config, AnyRegistry* reg, immutable(Block)[] blocks,
                 in TestConf test_conf, shared(TimePoint)* cur_time)
    {
        this.nregistry = reg;
        this.blocks = blocks;
        this.cur_time = cur_time;

        // This is normally done by `agora.node.Runner`
        // By default all output is written to the appender
        Log.root.level(atomicLoad(defaultLogLevel), true);
        foreach (const ref settings; config.logging)
        {
            auto log = settings.name ? Log.lookup(settings.name) : Log.root;
            log.level(settings.level, settings.propagate);
        }

        super(config);
    }

    /// ditto
    public override Enrollment setRecurringEnrollment (bool doIt)
    {
        this.config.validator.recurring_enrollment = doIt;
        if (this.config.validator.recurring_enrollment)
            return this.checkAndEnroll(this.ledger.height());

        return Enrollment.init;
    }

    /// ditto
    public override QuorumConfig getQuorumConfig ()
    {
        return this.qc;
    }

    /// Provides a unittest-adjusted clock source for the node
    protected override TestClock makeClock ()
    {
        return new TestClock(this.taskman,
            (out Duration time_offset)
            {
                return this.network.getNetTimeOffset(this.qc.threshold,
                    time_offset);
            },
            this.cur_time);
    }

    /// Gets the expected quorum config for the given keys and height
    public override QuorumConfig[] getExpectedQuorums (in PublicKey[] pub_keys,
        Height height)
    {
        Hash[] utxos;
        // We add one to height as we are interested in active validators in next block
        assert(this.enroll_man.getEnrolledUTXOs(height + 1, utxos) && utxos.length > 0);
        // See `Validator.rebuildQuorumConfig`
        const rand_seed = this.ledger.height() == height ?
            this.ledger.lastBlock().header.randomSeed() :
            this.ledger.getBlocksFrom(height).front.header.randomSeed();
        QuorumConfig[] quorums;
        foreach (idx, utxo; utxos)
        {
            UTXO utxo_value;
            this.ledger.peekUTXO(utxo, utxo_value);
            quorums ~= buildQuorumConfig(idx, utxos,
                this.ledger.getUTXOFinder(), rand_seed, this.quorum_params);
        }
        return quorums;
    }
}

/// Convenience mixin for deriving classes
public mixin template ForwardCtor ()
{
    ///
    public this (Parameters!(typeof(super).__ctor) args)
    {
        super(args);
    }
}

/// Describes a network topology for testing purpose
public enum NetworkTopology
{
    /// The nodes know about each other's IPs,
    /// and additionally outsider nodes will connect to them.
    FullyConnected,

    /// The nodes are connected in a chain: v1 <- v2 <- v3 <- v1,
    /// and additionally outsider nodes are minimally connected to them
    /// via v1 <- o1, v2 <- o2 (o = outsider node)
    MinimallyConnected,
}

/*******************************************************************************

    Network-wide configuration

    This struct is provided as an argument to `makeTestNetwork` and holds
    configuration members that affect the whole network.

    Those members are either used as input to `makeTestNetwork` (e.g. the number
    of nodes is specified by `full_nodes` / `outsider_validators`) or as a base
    value for each node's configuration.

    Note that configuration of base value should *not* be done using
    struct literals, but with default initialization then assignment.
    ---
    unittest
    {
        // This is wrong, as it will use `NodeConfig`'s defaults,
        // which are different from `TestConf`'s defaults
        version (Wrong)
            TestConf conf = { node: { min_listeners: 0 } };
        // This is correct:
        TestConf conf;
        conf.node.max_listeners = 0;
    }
    ---

*******************************************************************************/

public struct TestConf
{
    /// Network topology to use
    public NetworkTopology topology = NetworkTopology.FullyConnected;

    /// Extra blocks to generate in addition to the genesis block
    public size_t extra_blocks = 0;

    /// Number of full nodes to instantiate
    public size_t full_nodes = 0;

    /// Number of extra validators which are initially outside the network
    public size_t outsider_validators = 0;

    /// whether to set up the peers in the config
    public bool configure_network = true;

    /***************************************************************************

        Base configuration for the nodes, matches `agora.node.Config : Config`

    ***************************************************************************/

    /// If the enrollments will be renewed or not at the end of the cycle
    /// Matches the eponymous field in the `consensus` section.
    public bool recurring_enrollment = true;

    /// How often the validator should try to catchup for the preimages for the
    /// next block
    /// Matches the eponymous field in the `validator` section.
    public Duration preimage_catchup_interval = 1.seconds;

    // How often we should check for pre-images to reveal
    public Duration preimage_reveal_interval = 1.seconds;

    // How far in the future (in unit of blocks) pre-images can be revealed
    public size_t max_preimage_reveal = 6;

    /// max failed requests before a node is banned
    /// Matches the eponymous field in the `banman` section.
    public size_t max_failed_requests = 100;

    /// Base values for the `node` section
    public NodeConfig node = {
        /// Minimum number of clients to connect to
        /// Setting this to `size_t.max` makes it default to `nodes.length - 1`
        min_listeners: size_t.max,
        /// Maximum listener nodes
        /// Setting this to `size_t.max` makes it default to the number of nodes
        /// present in the network.
        max_listeners: size_t.max,

        // Catchup needs to happens much more frequently than in production
        block_catchup_interval: 1.seconds,

        // The default is much longer, but in unittests latency is negligible
        retry_delay: 300.msecs,
        timeout: 300.msecs,
        max_retries: 10,

        // Always set to true, cannot be overriden, but also set here for clarity
        testing: true,

        // As testing is set to True it is possible to use a subset of the validators in the GenesisBlock
        test_validators: 6,

        // Unittest realm
        realm: Domain.fromSafeString("unittest.bosagora.io."),
    };

    /// Base values for the `consensus` section
    public ConsensusConfig consensus = {
        // `genesis_timestamp` shouldn't be set, as one should use `setTimeFor`

        // `validator_cycle` is set to 20 to match the genesis block
        // Do not set it dynamically, it will be overridden
    };

    /***
        Base values for the `logging` section

        By default, the nodes will log at the default log level, which is either
        the value of the `dloglevel` environment variable,
        or `Info` if the variable is not set.

        Any setting provided here will override this default value and
        propagate to child loggers. For example, if the unittest binary is called
        with `dloglevel=Error`, and the following is used, the nodes will
        only log messages at `Error` level or above, except for the SCP log
        messages which will be at `Trace` level:
        ---
        TestConf conf = {
            logging: [
                {
                    name: "SCP",
                    level: LogLevel.Trace,
                },
            ],
        };
        ---
    */
    public immutable(LoggerConfig)[] logging;

    /// Event handler config
    public immutable(EventHandlerConfig)[] event_handlers;
}

/*******************************************************************************

    Creates a test network with the desired topology

    This function's only usage is to create the network topology.
    The actual behavior of the nodes that are part of the network is decided
    by the `TestNetworkManager` implementation.

    Params:
        APIManager = Type of API manager to instantiate
        test_conf = the test configuration
        params = the consensus-critical constants
        eArgs = The arguments `APIManager` has which are after `TestAPIManager`'s
                constructor arguments.

    Returns:
        The set of public key added to the node

*******************************************************************************/

public APIManager makeTestNetwork (APIManager : TestAPIManager = TestAPIManager)
    (in TestConf test_conf, Parameters!(APIManager.__ctor)[Parameters!(TestAPIManager.__ctor).length .. $] eArgs,
    string file = __FILE__, int line = __LINE__)
{
    import std.digest;
    import std.range;

    // We know we're in the main thread
    // Vibe.d messes with the scheduler - reset it
    static import std.concurrency;
    std.concurrency.scheduler = null;

    const registryCount = 1;
    const TotalNodes = test_conf.node.test_validators + test_conf.full_nodes +
        test_conf.outsider_validators + registryCount;

    ConsensusConfig makeConsensusConfig ()
    {
        ConsensusConfig result = test_conf.consensus;
        result.validator_cycle = GenesisValidatorCycle;
        return result;
    }

    InterfaceConfig makeInterfaceConfig (string address)
    {
        InterfaceConfig conf =
        {
            address : address,
        };

        return conf;
    }

    NodeConfig makeNodeConfig ()
    {
        NodeConfig conf = test_conf.node;
        conf.testing = true;
        conf.registry_address = "dns://10.8.8.8";
        const selfCount = 1;
        if (conf.min_listeners == size_t.max)
            conf.min_listeners = (test_conf.node.test_validators + test_conf.full_nodes) - selfCount;
        if (conf.max_listeners == size_t.max)
            conf.max_listeners = TotalNodes - selfCount;
        return conf;
    }

    BanManager.Config ban_conf =
    {
        max_failed_requests : test_conf.max_failed_requests,
        ban_duration: 300.seconds,
    };

    immutable(Address[]) makeNetworkConfig (size_t idx, Address[] addresses)
    {
        if (!test_conf.configure_network)
            return null;

        assert(addresses.length > 0);
        idx %= addresses.length;  // clamp to limit

        // nodes form a network chain: n2 <- n0 <- n1 <- n2
        if (test_conf.topology == NetworkTopology.MinimallyConnected)
            return [(idx == 0) ? addresses[$ - 1] : addresses[idx - 1]]
                .assumeUnique;
        else
            return addresses.idup;
    }

    Config makeValidatorConfig (size_t idx, KeyPair key_pair,
        Address self_address, Address[] addresses)
    {
        Hash cycle_seed;
        Height cycle_seed_height;
        getCycleSeed(key_pair, GenesisValidatorCycle, cycle_seed, cycle_seed_height);
        assert(cycle_seed != Hash.init);
        assert(cycle_seed_height != Height(0));
        const ValidatorConfig validator = {
            enabled : true,
            key_pair : key_pair,
            addresses_to_register : [ self_address ],
            recurring_enrollment : test_conf.recurring_enrollment,
            name_registration_interval : 10.seconds,
            preimage_reveal_interval : test_conf.preimage_reveal_interval,
            nomination_interval: 100.msecs,
            max_preimage_reveal: test_conf.max_preimage_reveal,
            preimage_catchup_interval: test_conf.preimage_catchup_interval,
            cycle_seed : cycle_seed,
            cycle_seed_height : cycle_seed_height,
        };

        Config conf =
        {
            banman : ban_conf,
            node : makeNodeConfig(),
            interfaces: [ makeInterfaceConfig(self_address.host) ],
            consensus: makeConsensusConfig(),
            validator : validator,
            network : cast(immutable) makeNetworkConfig(idx, addresses),
            logging: test_conf.logging,
            event_handlers : test_conf.event_handlers,
        };

        return conf;
    }

    Config makeFullNodeConfig (size_t idx, Address self_address,
        Address[] addresses)
    {
        Config conf =
        {
            banman : ban_conf,
            node : makeNodeConfig(),
            interfaces: [ makeInterfaceConfig(self_address.host) ],
            consensus: makeConsensusConfig(),
            network : cast(immutable) makeNetworkConfig(idx, addresses),
            logging: test_conf.logging,
            event_handlers : test_conf.event_handlers,
        };

        return conf;
    }

    Address validatorAddress (size_t idx, KeyPair key)
    {
        return Address(format("agora://10.0.0.%s", idx));
    }

    Address fullNodeAddress (size_t idx)
    {
        return Address(format("agora://10.0.255.%s", idx));
    }

    auto outsider_validators_keys = WK.Keys.byRange()
        .takeExactly(test_conf.outsider_validators);

    auto validator_keys = genesis_validator_keys[0 .. test_conf.node.test_validators] ~ outsider_validators_keys.array;

    // all enrolled and un-enrolled validators
    auto validator_addresses = validator_keys.enumerate
        .map!(en => validatorAddress(en.index, en.value)).array;

    // only enrolled validators
    auto enrolled_addresses = genesis_validator_keys.enumerate
        .takeExactly(test_conf.node.test_validators)
        .map!(en => validatorAddress(en.index, en.value)).array;

    auto full_node_addresses = test_conf.full_nodes.iota.map!(
        idx => fullNodeAddress(idx)).array;

    // full nodes and enrolled validators will connect to other enrolled validators
    // and other full nodes (but not to outsider nodes)
    auto connect_addresses = enrolled_addresses.chain(full_node_addresses);

    auto validator_configs = validator_keys.enumerate
        .map!(en => makeValidatorConfig(
            en.index,
            en.value,
            validator_addresses[en.index],
            connect_addresses.filter!(  // don't connect the validator to itself
                addr => addr != validator_addresses[en.index]).array));

    auto full_node_configs = test_conf.full_nodes
        .iota
        .map!(index => makeFullNodeConfig(
            index + enrolled_addresses.length,
            full_node_addresses[index],
            connect_addresses.filter!(  // don't connect the fullnode to itself
                addr => addr != full_node_addresses[index]).array));

    auto all_configs = validator_configs.chain(full_node_configs).array;

    immutable Block Genesis = {
        header: {
            merkle_root: GenesisBlock.header.merkle_root,
            validators: typeof(BlockHeader.validators)(test_conf.node.test_validators),
            enrollments: GenesisBlock.header.enrollments[0 .. test_conf.node.test_validators],
        },
        merkle_tree: GenesisBlock.merkle_tree,
        txs:         GenesisBlock.txs,
    };
    immutable(Block)[] blocks;
    blocks = generateExtraBlocks(Genesis, test_conf.extra_blocks);

    auto net = new APIManager(blocks, test_conf, validator_configs[0].consensus.genesis_timestamp, eArgs);

    import configy.Attributes : SetInfo;
    Config registry_config = {
      banman : ban_conf,
      node : makeNodeConfig(),
      interfaces: [ makeInterfaceConfig("10.8.8.8") ],
      consensus: makeConsensusConfig(),
      network : connect_addresses.array.idup,
      logging: test_conf.logging,
      event_handlers : test_conf.event_handlers,
      registry: {
          enabled: true,
          validators: {
              authoritative: SetInfo!bool(true, true),
              primary: SetInfo!string("name.registry", true),
              allow_transfer: [ZoneConfig.IPAddress("127.0.0.127")],
              soa: { email: SetInfo!string("test@testnet", true), },
          },
          flash: {
              authoritative: SetInfo!bool(true, true),
              primary: SetInfo!string("name.registry", true),
              soa: { email: SetInfo!string("test@testnet", true), },
          },
      },
    };
    net.createNameRegistry(registry_config, file, line);

    foreach (ref conf; all_configs)
        net.createNewNode(conf, file, line);

    return net;
}

/// API manager that creates nodes that are too lazy to reveal preimages
/// (except when explicitly set to reveal)
class LazyAPIManager(PreImageVN = NoPreImageVN) : TestAPIManager
{
    public shared bool reveal_preimage = false;

    ///
    mixin ForwardCtor!();

    ///
    public override void createNewNode (Config conf, string file, int line)
    {
        if (conf.validator.enabled == true)
            this.addNewNode!PreImageVN(conf, &this.reveal_preimage, file, line);
        else
            super.createNewNode(conf, file, line);
    }
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

/*******************************************************************************

    Generate a set of blocks with spend transactions

    Params:
        gen_block = the genesis block
        count = the number of extra blocks to generate. If 0, the return
                blockchain will only contain the genesis block.

    Returns:
        The blockchain, including the provided genesis block

*******************************************************************************/

private immutable(Block)[] generateExtraBlocks (
    ref immutable Block gen_block, size_t count)
{
    const(Block)[] blocks = [gen_block];
    if (count == 0)
        return blocks.assumeUnique;  // just the genesis block

    foreach (_; 0 .. count)
    {
        auto txs = blocks[$ - 1].spendable().map!(txb => txb.sign());
        const block = makeNewTestBlock(blocks[$ - 1], txs);
        blocks ~= block;
    }
    return blocks.assumeUnique;
}

/// This derived `TestValidatorNode` does not reveal any preimages
/// until told to do so. Make sure to set `reveal_preimage` using atomic ops.
public class NoPreImageVN : TestValidatorNode
{
    private shared bool* reveal_preimage;

    ///
    public this (Parameters!(TestValidatorNode.__ctor) args,
        shared(bool)* reveal_preimage)
    {
        this.reveal_preimage = reveal_preimage;
        super(args);
    }

    protected override void onPreImageRevealTimer ()
    {
        if (atomicLoad(*this.reveal_preimage))
            super.onPreImageRevealTimer();
    }

    /// GET: /preimages
    public override PreImageInfo[] getPreimagesFrom (ulong start_height) @safe
    {
        if (atomicLoad(*this.reveal_preimage))
            return super.getPreimagesFrom(start_height);
        const ek = this.enroll_man.getEnrollmentKey();
        return super.getPreimagesFrom(start_height)
            .filter!(pi => pi.utxo != ek).array();
    }

    /// GET: /preimages_for_enroll_keys
    public override PreImageInfo[] getPreimages (Set!Hash enroll_keys = Set!Hash.init) @safe
    {
        const self = this.enroll_man.getEnrollmentKey();
        const reveal = atomicLoad(*this.reveal_preimage);
        return super.getPreimages(enroll_keys)
            .filter!(pi => reveal || pi.utxo != self)
            .array();
    }
}

/// No-op transaction relayed, can be used to prevent gossipping
public class NoGossipTransactionRelayer : TransactionRelayer
{
    ///
    public override void start () {}

    ///
    public override void shutdown () @safe {}

    ///
    public override string addTransaction (in Transaction tx) @safe { return null; }
}

/// Interface combining `TestAPI`, `NameRegistryAPI`, and methods for DNS queries
package interface FullRegistryAPI : TestAPI, NameRegistryAPI
{
    /// Perform an UDP request
    public Message queryUDP (in Message query);

    /// Perform a TCP request
    public Message queryTCP (in Message query);
}

/// Mimics a DNS UDP Socket
private struct DNSQuery
{
    /// DNS message
    public Message msg;

    /// A channel that the client will wait the response on
    public Channel!Message response_chan;
}

/// A node that implements `FullRegistryAPI`
public class RegistryNode : TestFullNode, FullRegistryAPI
{
    import agora.flash.api.FlashAPI;
    import agora.flash.Node;

    ///
    mixin ForwardCtor!();

    /// Forwards to the registry's methods
    public const(RegistryPayload) getValidator (PublicKey public_key) @safe
    {
        return this.registry.getValidator(public_key);
    }

    /// Ditto
    public void postValidator(RegistryPayload registry_payload) @safe
    {
        this.registry.postValidator(registry_payload);
    }

    /// Ditto
    public const(RegistryPayload) getFlashNode(PublicKey public_key) @safe
    {
        return this.registry.getFlashNode(public_key);
    }

    /// Ditto
    public void postFlashNode(RegistryPayload registry_payload, KnownChannel channel)
        @safe
    {
        return this.registry.postFlashNode(registry_payload, channel);
    }

    ///
    public override Message queryUDP (in Message query)
    {
        Message result;
        this.registry.answerQuestions(query, "127.0.0.127",
            (in Message msg) @trusted { result = msg.clone(); },
            false);
        return result;
    }

    ///
    public override Message queryTCP (in Message query)
    {
        Message result;
        this.registry.answerQuestions(query, "127.0.0.127",
            (in Message msg) @trusted { result = msg.clone(); },
            true);
        return result;
    }
}

///
public final class LocalRestDNSResolver : DNSResolver
{
    ///
    private FullRegistryAPI[] peers;

    /***************************************************************************

        Instantiate a new object of this type

        Params:
          addresses = Addresses of the DNS servers to use
          router = Localrest registry to resolve `addresses`
          timmeout = Timeout to use for queries

    ***************************************************************************/

    public this (Address[] addresses, ref AnyRegistry router,
                 Duration timeout = 10.seconds)
    {
        foreach (addr; addresses)
            this.addResolver(addr, router, timeout);
    }

    /// Add a new peer / resolver to query
    public void addResolver (Address address, ref AnyRegistry router,
                             Duration timeout = 10.seconds)
    {
        auto tid = router.locate!FullRegistryAPI(address.host);
        assert(tid !is typeof(tid).init),
            format("Trying to access DNS registry at address '%s' without first creating it",
                   address);
        this.peers ~= new RemoteAPI!FullRegistryAPI(tid, timeout);
    }

    /***************************************************************************

        Query the server with given `msg` and return the response

        Params:
            msg = DNS message

    ***************************************************************************/

    public override ResourceRecord[] query (Message msg) @trusted
    {
        const tcp = msg.questions.length > 0 && msg.questions[0].qtype == QTYPE.AXFR;
        foreach (p; this.peers)
        {
            auto answer = !tcp ? p.queryUDP(msg) : p.queryTCP(msg);
            log.trace("Got response from for '{}' : {}", msg, answer);
            if (answer.header.RCODE == Header.RCode.NoError)
                return answer.answers;
        }
        log.trace("None of the {} had an answer for '{}' : {}", this.peers.length, msg);
        return null;
    }
}
