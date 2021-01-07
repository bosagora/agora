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
import agora.common.BitField;
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
import agora.consensus.protocol.Data;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.ValidatorBlockSig;
import agora.consensus.data.Transaction;
import agora.consensus.state.UTXODB;
import agora.consensus.EnrollmentManager;
import agora.consensus.data.genesis.Test;
import agora.consensus.SCPEnvelopeStore;
import agora.consensus.protocol.Nominator;
import agora.consensus.Quorum;
import agora.network.Clock;
import agora.network.NetworkClient;
import agora.network.NetworkManager;
import agora.node.BlockStorage;
import agora.node.FullNode;
import agora.node.Ledger;
import agora.node.Validator;
import agora.registry.NameRegistryAPI;
import agora.registry.NameRegistryImpl;
import agora.utils.Log;
import agora.utils.PrettyPrinter;
public import agora.utils.Utility : retryFor;
import agora.utils.Workarounds;
import agora.api.FullNode : NodeInfo, NetworkState;
import agora.api.Validator : ValidatorAPI = API;

import scpd.types.Stellar_SCP;

static import geod24.LocalRest;
import geod24.Registry;

import std.array;
import std.exception;
import std.range;

import core.atomic : atomicLoad, atomicStore;
import core.exception;
import core.runtime;
import core.stdc.time;
import core.stdc.stdlib : abort;

/* The following imports are frequently needed in tests */

 // Contains utilities for testing, e.g. `retryFor`
public import agora.utils.Test;
public import agora.common.Types : Height;
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

// Convenience constants
public const size_t GenesisValidators = GenesisBlock.header.enrollments.count();
public const uint GenesisValidatorCycle = GenesisBlock
    .header.enrollments[0].cycle_length;

shared static this()
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
        CircularAppender!()().print(output);
    }
    catch (Exception exc)
    {
        scope exc_name = typeid(exc).name;
        printf("Could not print thread logs because of %.*s (%.*s:%lu): %.*s\n",
            cast(int) exc_name.length, exc_name.ptr,
            cast(int) file.length, file.ptr, line, cast(int) msg.length, msg.ptr);
    }
    // TODO: Using `abort` here would give use a core dump,
    // but this gives us a stack trace.
    throw new AssertError(msg, file, line);
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
    import core.sync.semaphore;
    import core.thread.osthread;

    // by default emit only errors during unittests.
    // can be re-set by calling code.
    Log.root.level(Log.root.Level.Error, true);

    // display the thread's log buffer when an assertion fails during a test
    assertHandler = &testAssertHandler;

    //
    const chatty = !!("dchatty" in environment);
    const all_single_threaded = !!("dsinglethreaded" in environment);
    auto filter = environment.get("dtest").toLower();
    size_t filtered;

    // can't use ModuleInfo[], opApply returns temporaries..
    struct ModTest
    {
        string name;
        void function() test;
    }

    ModTest[] single_threaded;
    ModTest[] parallel_tests;
    ModTest[] heavy_tests;

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
            if (all_single_threaded || mod.name == "agora.common.Serializer")
                single_threaded ~= ModTest(mod.name, fp);
            else if (mod.name == "agora.test.ManyValidators")
                heavy_tests ~= ModTest(mod.name, fp);
            else
                // due to problems with the parallelism test,
                // the test is performed with single threads
                version (Windows)
                    single_threaded ~= ModTest(mod.name, fp);
                else
                    parallel_tests ~= ModTest(mod.name, fp);
        }
    }

    shared size_t executed;
    shared size_t passed;

    void runTest (ModTest mod)
    {
        atomicOp!"+="(executed, 1);
        try
        {
            if (chatty)
            {
                auto output = stdout.lockingTextWriter();
                output.formattedWrite("Unittesting %s..\n", mod.name);
            }

            mod.test();
            atomicOp!"+="(passed, 1);
        }
        catch (Throwable ex)
        {
            auto output = stdout.lockingTextWriter();
            output.formattedWrite("Module tests failed: %s\n", mod.name);
            output.formattedWrite("%s\n", ex);
            // print logs of the work thread
            CircularAppender!()().print(output);
        }
    }

    // Run single-threaded tests
    foreach (mod; single_threaded)
        runTest(mod);

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

    runInParallel(parallel_tests);
    runInParallel(heavy_tests);

    //waiting for all parallel tasks to finish
    iota(parallel_tests.length + heavy_tests.length).each!(x => finished_tasks_num.wait());

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

    static QT deserialize (QT) (in ubyte[] data) @trusted nothrow
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

    public override void runTask (void delegate() dg) nothrow
    {
        this.tasks_started++;
        geod24.LocalRest.runTask(dg);
    }

    /***************************************************************************

        Suspend the current task for the given duration

        Params:
            dur = the duration for which to suspend the task for

    ***************************************************************************/

    public override void wait (Duration dur) nothrow
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

    public override ITimer setTimer (Duration timeout, void delegate() dg,
        Periodic periodic = Periodic.No) nothrow
    {
        this.tasks_started++;
        return new LocalRestTimer(geod24.LocalRest.setTimer(timeout, dg,
            periodic));
    }
}

/*******************************************************************************

    LocalRest only timer (for unittests)

*******************************************************************************/

private final class LocalRestTimer : ITimer
{
    import LocalRest = geod24.LocalRest;

    private LocalRest.Timer timer;

    public this (LocalRest.Timer timer) @safe nothrow
    {
        this.timer = timer;
    }

    /// Ditto
    public override void stop () @safe nothrow
    {
        this.timer.stop();
    }
}

/// A ban manager not loading and dumping
public class TestBanManager : BanManager
{
    /// Ctor
    public this (Config conf, Clock clock, cstring data_dir)
    {
        super(conf, clock, data_dir);
    }

    /// no-op
    public override void load () { }

    /// no-op
    public override void dump () { }
}

/// Nominator with custom rules for when blocks should be nominated
public extern (C++) class TestNominator : Nominator
{
extern(D):
    /// number of txs required for nomination
    protected ulong txs_to_nominate;

    /// test start time
    protected ulong test_start_time;

    ///
    public this (immutable(ConsensusParams) params, Clock clock,
        NetworkManager network, KeyPair key_pair, Ledger ledger,
        EnrollmentManager enroll_man, TaskManager taskman, string data_dir,
        ulong txs_to_nominate, ulong test_start_time)
    {
        this.test_start_time = test_start_time;
        this.txs_to_nominate = txs_to_nominate;
        super(params, clock, network, key_pair, ledger, enroll_man, taskman, data_dir);
    }

    protected override ulong getExpectedBlockTime () @safe @nogc nothrow pure
    {
        return max(this.test_start_time, ledger.getLastBlock().header.timestamp) + this.params.BlockIntervalSeconds;
    }

    /// Overrides the default behavior and changes nomination behavior based
    /// on the TestConf 'txs_to_nominate' option
    protected override bool prepareNominatingSet (out ConsensusData data) @safe
    {
        // if 0 take all txs, otherwise nominate exactly this many txs
        this.ledger.prepareNominatingSet(data,
            this.txs_to_nominate ? this.txs_to_nominate : ulong.max);
        if (data.tx_set.length < this.txs_to_nominate)
            return false;  // not enough txs

        // defensive coding, same as base class
        // (but may be overruled by derived classes)
        if (auto msg = this.ledger.validateConsensusData(data))
            return false;

        return true;
    }

    // set the DB instance of SCPEnvelopeStore
    protected void setSCPEnvelopeStore (SCPEnvelopeStore envelope_store)
    {
        this.scp_envelope_store = envelope_store;
    }

    // return a SCPEnvelopeStore backed by an in-memory SQLite db
    protected override SCPEnvelopeStore getSCPEnvelopeStore (string data_dir)
    {
        return new SCPEnvelopeStore(":memory:");
    }
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

    /// the adjustable local clock time for this node.
    /// This does not affect request timeouts and is only
    /// used in the Nomination protocol.
    private shared(time_t)* cur_time;

    /// Get the current clock time
    @property time_t time () @trusted @nogc nothrow
    {
        return atomicLoad(*this.cur_time);
    }

    /// Set the new time
    @property void time (time_t new_time) @trusted @nogc nothrow
    {
        atomicStore(*this.cur_time, new_time);
    }
}

/*******************************************************************************

    Used by unittests to send messages to individual nodes.
    This class is instantiated once per unittest.

*******************************************************************************/

public class TestAPIManager
{
    /// Test configuration
    protected TestConf test_conf;

    /// Used by the unittests in order to directly interact with the nodes,
    /// without trying to handshake or do any automatic network discovery.
    /// Also kept here to avoid any eager garbage collection.
    public NodePair[] nodes;

    /// Contains the initial blockchain state of all nodes
    public immutable(Block)[] blocks;

    /// Start time of the tests
    public const time_t test_start_time;

    /// The initial clock time of every spawned node. Note that if there were
    /// any extra blocks loaded (`blocks` in the ctor) then the initial time
    /// will be test_start_time + (last_height * block_interval)
    protected time_t initial_time;

    /// convenience: returns a random-access range which lets us access clients
    auto clients ()
    {
        return nodes.map!(np => np.client);
    }

    /// Registry holding the nodes
    protected Registry reg;

    /// Name registry
    private RemoteAPI!NameRegistryAPI name_registry;

    ///
    public this (immutable(Block)[] blocks, TestConf test_conf,
        time_t test_start_time)
    {
        this.test_conf = test_conf;
        this.blocks = blocks;
        this.test_start_time = test_start_time;
        this.initial_time = this.getBlockTime(blocks[$ - 1].header.height);
        this.reg.initialize();
        this.createNameRegistry();
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

    public void expectBlock (Height height, Duration timeout = 10.seconds,
        string file = __FILE__, int line = __LINE__)
    {
        this.expectBlock(iota(this.clients.length), height, timeout,
            file, line);
    }

    /// Ditto
    public void expectBlock (Idxs)(Idxs clients_idxs, Height height,
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

    public void expectBlock (Height height, const(BlockHeader) enroll_header,
        Duration timeout = 10.seconds,
        string file = __FILE__, int line = __LINE__)
    {
        this.expectBlock(iota(GenesisValidators), height, enroll_header,
            timeout, file, line);
    }

    /// Ditto
    public void expectBlock (Idxs)(Idxs clients_idxs, Height height,
        const(BlockHeader) enroll_header, Duration timeout = 10.seconds,
        string file = __FILE__, int line = __LINE__)
    {
        static assert (isInputRange!Idxs);

        assert(height > enroll_header.height);
        auto distance = cast(ushort)(height - enroll_header.height - 1);
        waitForPreimages(clients_idxs, enroll_header.enrollments,
            distance, timeout);
        this.expectBlock(clients_idxs, height, timeout, file, line);
    }

    /***************************************************************************

        Checks if all the nodes contain the given distance of pre-images for
        the given enrollments.

        The overload allows passing a subset of nodes to verify the distance
        for only these nodes.

        Params:
            enrolls = the enrollments whose pre-image will be checked
            distance = the expected distance of pre-images
            timeout = the request timeout to each node

    ***************************************************************************/

    public void waitForPreimages (const(Enrollment)[] enrolls, ushort distance,
        Duration timeout = 10.seconds,
        string file = __FILE__, int line = __LINE__)
    {
        this.waitForPreimages(iota(GenesisValidators), enrolls, distance,
            timeout, file, line);
    }

    /// Ditto
    public void waitForPreimages (Idxs)(Idxs clients_idxs,
        const(Enrollment)[] enrolls, ushort distance,
        Duration timeout = 10.seconds,
        string file = __FILE__, int line = __LINE__)
    {
        static assert (isInputRange!Idxs);

        clients_idxs.each!(idx =>
            enrolls.each!(enroll =>
                retryFor(this.clients[idx].getPreimage(enroll.utxo_key)
                    .distance >= distance, timeout)));
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

        const exp_time = this.getBlockTime(height);
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

        Params:
            height = the requested block height

        Returns:
            the expected timestamp for the given block height

    ***************************************************************************/

    public time_t getBlockTime (Height height)
    {
        return to!time_t(this.test_start_time +
            (height * this.test_conf.block_interval_sec));
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

    /// Convenience templated function to be called from overriding classes
    public TestAPI addNewNode (NodeType : TestAPI) (
        Config conf, string file = __FILE__, int line = __LINE__)
    {
        auto time = new shared(time_t)(this.initial_time);
        auto api = RemoteAPI!TestAPI.spawn!NodeType(conf, &this.reg,
            this.blocks, this.test_conf, time,
            conf.node.timeout, file, line);

        this.reg.register(conf.node.address, api.tid());
        this.nodes ~= NodePair(conf.node.address, api, time);
        return api;
    }

    /***************************************************************************

        Create a new name registry

    ***************************************************************************/

    public void createNameRegistry ()
    {
        this.name_registry = RemoteAPI!NameRegistryAPI.spawn!NameRegistryImpl();
        this.reg.register("name.registry", this.name_registry.tid());
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

        Params:
          printLogs = Whether or not to print nodes logs

    ***************************************************************************/

    public void shutdown (bool printLogs = false)
    {
        foreach (node; this.nodes)
            enforce(this.reg.unregister(node.address));

        /// Private functions used for `shutdown`
        static void shutdownWithLogs (TestAPI node)
        {
            (cast(FullNode)node).shutdown();
            node.printLog();
        }
        static void shutdownSilent (TestAPI node)
        {
            (cast(FullNode)node).shutdown();
        }

        foreach (ref node; this.nodes)
        {
            node.client.ctrl.shutdown(
                printLogs ? &shutdownWithLogs : &shutdownSilent);
            node.client = null;
        }

        this.nodes = null;

        enforce(this.reg.unregister("name.registry"));
        name_registry.ctrl.shutdown();
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
        client.ctrl.restart((TestAPI node) { (cast(FullNode)node).shutdown(); });
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
                {
                    node.client.printLog();
                }
                catch (Exception ex)
                {
                    writefln("Could not print logs for node: %s", ex.message);
                }
            }
        }
    }

    /***************************************************************************

        Keep polling for nodes to reach discovery, up to 5 seconds.

        If network discovery isn't reached, it will throw an Error.

    ***************************************************************************/

    public void waitForDiscovery (Duration timeout = 5.seconds,
        string file = __FILE__, int line = __LINE__)
    {
        try
        {
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

    /***************************************************************************

        Add blocks up to the provided height

        This is a helper function to enable some common steps to getting blocks
            externalized during the Network Unit tests

        Params:
            block_height = the desired block height
            client_idxs = client indices for the participating validators

    ***************************************************************************/

    public void generateBlocks (Height block_height,
        string file = __FILE__, int line = __LINE__)
    {
        generateBlocks(iota(GenesisValidators), block_height, file, line);
    }

    /// Ditto
    public void generateBlocks (Idxs)(Idxs client_idxs, Height block_height,
        string file = __FILE__, int line = __LINE__)
    {
        static assert (isInputRange!Idxs);

        // Get the last block from the first client
        auto lastBlock = this.clients[client_idxs.front].getAllBlocks()[$ -1];

        // Call addBlock for each block to be externalised for these clients
        iota(block_height - lastBlock.header.height)
            .each!(_ => this.addBlock(client_idxs, file, line));
    }

     /**************************************************************************

        Add a block

        This is a helper function to perform the steps required to get a block
            externalized during the Network Unit tests

        Params:
            client_idxs = client indices for the participating validators

    ***************************************************************************/

    void addBlock (string file = __FILE__, int line = __LINE__)
    {
        addBlock(iota(0, GenesisValidators), file, line);
    }

    /// Ditto
    void addBlock (Idxs)(Idxs client_idxs,
        string file = __FILE__, int line = __LINE__)
    {
        static assert (isInputRange!Idxs);

        auto first_client = this.clients[client_idxs.front];
        auto all_blocks = first_client.getAllBlocks();

        // traget height will be one more than previous block
        Height target_height = Height(all_blocks[$ - 1].header.height + 1);

        assert(all_blocks.length > 0,
            format!"[%s:%s] No blocks in first client!"(file, line));

        // Get spendables from last block
        auto spendables = all_blocks[$ - 1].spendable().array;

        // Ensure at least one tx will be taken
        auto tx_count = max(1, this.test_conf.txs_to_nominate);

        // Show the last block if not enough spendables
        assert(spendables.length >= tx_count,
            format!"[%s:%s] Less than %s spendables in block:\n%s"
                (file, line, tx_count, prettify(all_blocks[$ - 1])));

        // Send transactions to the first client
        spendables.takeExactly(tx_count)
            .map!(txb => txb.sign())
            .each!(tx => first_client.putTransaction(tx));

        // Get preimage distance from enrollment to this next block
        ushort distance = cast(ushort) (((target_height - 1) % GenesisValidatorCycle));
        assert(distance < GenesisValidatorCycle && distance >= 0,
            format!"[%s:%s] Expected distance between 0 and %s not %s, target height %s"
                (file, line, GenesisValidatorCycle - 1, distance, target_height));
        auto enrolled_height = target_height - distance - 1;
        assert(enrolled_height % GenesisValidatorCycle == 0,
            format!"[%s:%s] Invalid enroll height calculated as %s"
                (file, line, enrolled_height));
        // Check block is at target height for the participating clients
        expectBlock(client_idxs, target_height,
            all_blocks[enrolled_height].header, 10.seconds, file, line);
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
        enroll(iota(GenesisValidators), client_idx);
    }

    /// Ditto
    void enroll (Idxs)(Idxs client_idxs, size_t client_idx,
        string file = __FILE__, int line = __LINE__)
    {
        static assert (isInputRange!Idxs);

        Enrollment enroll = this.clients[client_idx].createEnrollmentData();
        clients[client_idx].enrollValidator(enroll);
        client_idxs.each!(idx =>
            retryFor(this.clients[idx].getEnrollment(enroll.utxo_key) == enroll,
                5.seconds,
                format!"[%s:%s] Client #%s enrollment not in pool of client #%s"
                    (file, line, client_idx, idx)));
    }

    /***************************************************************************

        Assert all the nodes contain the same blocks

        This is a helper function to confirm all nodes have the same blocks

        Params:
            client_idxs = client indices for the nodes to be checked
            height = expected block height of the nodes

    ***************************************************************************/

    void assertSameBlocks (Height height,
        string file = __FILE__, int line = __LINE__)
    {
        assertSameBlocks(iota(GenesisValidators), height, file, line);
    }

    /// Ditto
    void assertSameBlocks (Idxs)(Idxs client_idxs, Height height,
        string file = __FILE__, int line = __LINE__)
    {
        static assert (isInputRange!Idxs);

        client_idxs.each!(idx =>
            retryFor(Height(this.clients[idx].getBlockHeight()) == height,
                5.seconds,
                format!"[%s:%s] Expected height %s for client #%s not %s"
                    (file, line, height, idx,
                        this.clients[idx].getBlockHeight())));

        retryFor(client_idxs.map!(idx =>
            this.clients[idx].getAllBlocks()).uniq().count() == 1,
            5.seconds,
            format!"[%s:%s] Clients %s blocks are not all the same: %s"
                (file, line, client_idxs, client_idxs.fold!((s, i) =>
                    s ~ format!"\n\n========== Client #%s ==========%s"
                        (i, prettify(this.clients[i].getAllBlocks())))("")));
    }
}

/*******************************************************************************

    Adds additional networking capabilities for use in unittests

*******************************************************************************/

public class TestNetworkClient : NetworkClient
{
    /// See NetworkClient ctor
    public this (TaskManager taskman, BanManager banman, Address address,
        ValidatorAPI api, Duration retry, size_t max_retries)
    {
        super(taskman, banman, address, api, retry, max_retries);
    }

    /***************************************************************************

        Register the node's address to listen for gossiping messages.

        address = the adddress of the node

        Throws:
            `Exception` if the request failed.

    ***************************************************************************/

    public void registerListenerAddress (Address address)
    {
        return this.attemptRequest!(TestAPI.registerListenerAddress, Throw.Yes)(
            cast(TestAPI)this.api, address);
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
    import agora.api.handler.BlockExternalizedHandler;
    import agora.api.handler.PreImageReceivedHandler;
    import agora.api.handler.TransactionReceivedHandler;

    ///
    public Registry* registry;

    /// Constructor
    public this (Config config, Metadata metadata,
        TaskManager taskman, Clock clock, Registry* reg)
    {
        this.registry = reg;
        super(config, metadata, taskman, clock);
    }

    /// No "http://" in unittests, we just use the string as-is
    protected final override string getAddress ()
    {
        return this.node_config.address;
    }

    ///
    protected final override TestAPI getClient (Address address,
        Duration timeout)
    {
        auto tid = this.registry.locate(address);
        if (tid != typeof(tid).init)
            return new RemoteAPI!TestAPI(tid, timeout);
        assert(0, "Trying to access node at address '" ~ address ~
               "' without first creating it");
    }

    ///
    public override RemoteAPI!NameRegistryAPI getNameRegistryClient (Address address, Duration timeout)
    {
        auto tid = this.registry.locate(address);
        if (tid != typeof(tid).init)
            return new RemoteAPI!NameRegistryAPI(tid, timeout);
        assert(0, "Trying to access name registry at address '" ~ address ~
               "' without first creating it");
    }

    ///
    protected final override TestNetworkClient getNetworkClient (
        TaskManager taskman, BanManager banman, Address address,
        ValidatorAPI api, Duration retry, size_t max_retries)
    {
        return new TestNetworkClient(taskman, banman, address, api, retry,
            max_retries);
    }

    /***************************************************************************

        Params:
            conf = ban manager config
            clock = clock instance
            data_dir = path to the data directory

        Returns:
            an instance of a TestBanManager

    ***************************************************************************/

    protected override TestBanManager getBanManager (in BanManager.Config conf,
        Clock clock, cstring data_dir)
    {
        return new TestBanManager(conf, clock, data_dir);
    }

    ///
    protected final override BlockExternalizedHandler getBlockExternalizedHandler
        (Address address)
    {
        assert(0, "Not supported");
    }

    ///
    protected final override PreImageReceivedHandler getPreimageReceivedHandler
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

    /// Overridable for LocalRest which uses public keys
    protected final override void registerAsListener (NetworkClient client)
    {
        (cast(TestNetworkClient)client).registerListenerAddress(
            this.node_config.address);
    }
}

/*******************************************************************************

    API implemented by the test nodes runs by LocalRest

    This API inherits from ValidatorAPI, and simply adds a few functions that
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

public interface TestAPI : ValidatorAPI
{
    /***************************************************************************

        Start the node

        The `FullNode` have a `start` method that is scheduled by the `main`
        function to start discovery / catchup, etc...
        Since our node is not instantiated through `main`, the `APIManager`
        will call this function directly after instantiating a new node.

    ***************************************************************************/

    public abstract void start ();

    /***************************************************************************

        Print out the contents of the log

        Each node logs to their own buffer in their own Thread, which is written
        to a circular buffer to save on memory.
        Calling this function will dump the content of the node's log buffer
        to stderr. `TestAPIManager` provides a convenient way to call
        this method for every node, and most tests will do this on test failure.

    ***************************************************************************/

    public abstract void printLog ();

    /***************************************************************************

        TEMPORARY: Create a valid `Enrollment` for this node

        This method is a temporary workaround to create an Enrollment for a node
        in tests. In the future it will be replaced by a simple function call,
        once Enrollment catch-up is fixed and all node keypairs are well-known.

    ***************************************************************************/

    public abstract Enrollment createEnrollmentData();

    ///
    public QuorumConfig getQuorumConfig ();

    /// Get the active validator count for the current block height
    public ulong getValidatorCount ();

    /***************************************************************************

        Register the given address to listen for gossiping messages.

        This method is the API endpoint for LocalRest, which is corresponding to
        the `register_address` REST interface.

        Params:
            address = the address of node to register

        Throws:
            `Exception` if the request failed.

    ***************************************************************************/

    public void registerListenerAddress (Address address);

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

    public time_t getNetworkTime ();
}

/// Contains routines which are implemented by both TestFullNode and
/// TestValidator. Used because TestValidator inherits from Validator but
/// cannot inherit from TestFullNode, as it already inherits from Validator class
/// (multiple-inheritance is not supported in D)
private mixin template TestNodeMixin ()
{
    private Registry* registry;

    /// pointer to the unittests-adjusted clock time
    protected shared(time_t)* cur_time;

    /// test start time
    protected ulong test_start_time;

    /// Blocks to preload into the memory storage
    private immutable(Block)[] blocks;

    ///
    public override void start ()
    {
        super.start();
    }

    /// Prints out the log contents for this node
    public void printLog ()
    {
        auto output = stdout.lockingTextWriter();
        output.formattedWrite("Log for node: %s\n", this.config.node.address);
        output.put("======================================================================\n");
        CircularAppender!()().print(output);
        output.put("======================================================================\n\n");
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

    /// Return a LocalRest-backed task manager
    protected override TaskManager getTaskManager ()
    {
        return new LocalRestTaskManager();
    }

    /// Return an instance of the custom TestNetworkManager
    protected override NetworkManager getNetworkManager (
        in Config config, Metadata metadata, TaskManager taskman, Clock clock)
    {
        assert(taskman !is null);
        return new TestNetworkManager(config, metadata, taskman, clock, this.registry);
    }

    /// Return an enrollment manager backed by an in-memory SQLite db
    protected override EnrollmentManager getEnrollmentManager (
        string data_dir, in ValidatorConfig validator_config,
        immutable(ConsensusParams) params)
    {
        return new EnrollmentManager(":memory:", validator_config.key_pair, params);
    }

    /// Get the active validator count for the current block height
    public override ulong getValidatorCount ()
    {
        return this.enroll_man.validatorCount();
    }

    /// Localrest: the address (key) is provided directly to the network manager
    public override void registerListenerAddress (Address address)
    {
        this.network.registerListener(address);
    }

    /// Manually initiate a clock synchronization event
    public override void synchronizeClock ()
    {
        this.clock.synchronize();
    }

    /// Return the adjusted clock time
    public override time_t getNetworkTime ()
    {
        return this.clock.networkTime();
    }
}

///
public class TestClock : Clock
{
    ///
    private shared(time_t)* cur_time;

    ///
    public this (TaskManager taskman, GetNetTimeOffset getNetTimeOffset,
        shared(time_t)* cur_time)
    {
        super(getNetTimeOffset,
            (Duration duration, void delegate() cb) nothrow @trusted
                { taskman.setTimer(duration, cb, Periodic.Yes); });
        this.cur_time = cur_time;
    }

    ///
    public override time_t localTime ()
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
    /// txs to nominate in the TestNominator
    protected ulong txs_to_nominate;

    ///
    mixin TestNodeMixin!();


    ///
    public this (Config config, Registry* reg, immutable(Block)[] blocks,
        in TestConf test_conf, shared(time_t)* cur_time)
    {
        this.registry = reg;
        this.blocks = blocks;
        this.cur_time = cur_time;
        this.test_start_time = *cur_time;
        super(config);
    }

    /// Provides a unittest-adjusted clock source for the node
    protected override TestClock getClock (TaskManager taskman)
    {
        return new TestClock(this.taskman,
            (out long time_offset) { return true; }, this.cur_time);
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

    /// ditto
    public override void receiveBlockSignature (ValidatorBlockSig block_sig) @safe
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
    /// for TestNominator
    protected ulong txs_to_nominate;

    ///
    mixin TestNodeMixin!();

    ///
    public this (Config config, Registry* reg, immutable(Block)[] blocks,
        in TestConf test_conf, shared(time_t)* cur_time)
    {
        this.registry = reg;
        this.blocks = blocks;
        this.txs_to_nominate = test_conf.txs_to_nominate;
        this.cur_time = cur_time;
        this.test_start_time = *cur_time;
        super(config);
    }

    /// Create an enrollment data used as information for an validator
    public override Enrollment createEnrollmentData ()
    {
        Hash[] utxo_hashes;
        auto pubkey = this.getPublicKey();
        auto utxos = this.utxo_set.getUTXOs(pubkey);
        assert(utxos.length > 0, format!"No utxo for public key %s"(pubkey));
        foreach (key, utxo; utxos)
        {
            if (utxo.type == TxType.Freeze &&
                utxo.output.value.integral() >= Amount.MinFreezeAmount.integral())
            {
                utxo_hashes ~= key;
            }
        }
        assert(utxo_hashes.length > 0, format!"No frozen utxo for %s"(pubkey));

        const enroll_height = this.enroll_man.getEnrolledHeight(utxo_hashes[0]);
        // The first height at which the enrollment can be enrolled.
        const avail_height = enroll_height == ulong.max ?
                                this.ledger.getBlockHeight() + 1 :
                                enroll_height + this.params.ValidatorCycle;
        return this.enroll_man.createEnrollment(utxo_hashes[0],
                                                    Height(avail_height));
    }


    /// ditto
    public override QuorumConfig getQuorumConfig ()
    {
        return this.qc;
    }

    /// Returns an instance of a TestNominator with customizable behavior
    protected override TestNominator getNominator (
        immutable(ConsensusParams) params, Clock clock, NetworkManager network,
        KeyPair key_pair, Ledger ledger, EnrollmentManager enroll_man, TaskManager taskman, string data_dir)
    {
        return new TestNominator(params, clock, network, key_pair, ledger,
            enroll_man, taskman, data_dir, this.txs_to_nominate, this.test_start_time);
    }

    /// Provides a unittest-adjusted clock source for the node
    protected override TestClock getClock (TaskManager taskman)
    {
        return new TestClock(this.taskman,
            (out long time_offset)
            {
                // not enrolled - no need to synchronize clocks
                if (!this.enroll_man.isEnrolled(&this.utxo_set.peekUTXO))
                    return false;

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
        assert(this.enroll_man.getEnrolledUTXOs(utxos) && utxos.length > 0);
        const rand_seed = this.enroll_man.getRandomSeed(utxos, height);
        QuorumConfig[] quorums;
        foreach (pub_key; pub_keys)
            quorums ~= buildQuorumConfig(pub_key, utxos,
                this.utxo_set.getUTXOFinder(), rand_seed, this.quorum_params);
        return quorums;
    }
}

/// Convenience mixin for deriving classes
public mixin template ForwardCtor ()
{
    ///
    public this (Config config, Registry* reg, immutable(Block)[] blocks,
        in TestConf test_conf, shared(time_t)* cur_time)
    {
        super(config, reg, blocks, test_conf, cur_time);
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

/// Node / Network / Quorum configuration for use with makeTestNetwork
public struct TestConf
{
    /// Network topology to use
    NetworkTopology topology = NetworkTopology.FullyConnected;

    /// Extra blocks to generate in addition to the genesis block
    size_t extra_blocks = 0;

    /// Number of full nodes to instantiate
    size_t full_nodes = 0;

    /// Number of extra validators which are initially outside the network
    size_t outsider_validators = 0;

    /// Number of extra full nodes which are initially outside the network
    size_t outsider_full_nodes = 0;

    /// Maximum number of quorums in the autogenerated quorum sets
    uint max_quorum_nodes = 7;

    /// Overrides the default quorum threshold
    uint quorum_threshold = 80;

    /// Quorum shuffle cycle
    uint quorum_shuffle_interval = 30;

    /// whether to set up the peers in the config
    bool configure_network = true;

    /// the delay between request retries
    Duration retry_delay = 100.msecs;

    /// minimum clients to connect to (defaults to nodes.length - 1)
    size_t min_listeners;

    /// max retries before a request is considered failed
    size_t max_retries = 20;

    /// request timeout for each node
    Duration timeout = 5.seconds;

    /// max failed requests before a node is banned
    size_t max_failed_requests = 100;

    /// max listener nodes. If set to 0, set to this.nodes - 1
    size_t max_listeners;

    /// registry address
    string registry_address = "name.registry";

    /// Number of transactions nominated for each nomination slot.
    /// This is only used for the TestNominator - it's not part of Consensus rules.
    /// Many existing tests have been originally written with the assumption that
    /// a block contains 8 transactions.
    /// If set to 0 there will be no limits on the number of nominated transactions
    /// (unless Consensus rules dictate otherwise)
    ulong txs_to_nominate = 8;

    /// How often blocks should be created - in seconds
    uint block_interval_sec = 1;

    /// If the enrollments will be renewed or not at the end of the cycle
    bool recurring_enrollment = true;
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

    Returns:
        The set of public key added to the node

*******************************************************************************/

public APIManager makeTestNetwork (APIManager : TestAPIManager = TestAPIManager)
    (in TestConf test_conf, string file = __FILE__, int line = __LINE__)
{
    import agora.common.Serializer;
    import std.digest;
    import std.range;

    // We know we're in the main thread
    // Vibe.d messes with the scheduler - reset it
    static import std.concurrency;
    std.concurrency.scheduler = null;

    const TotalNodes = GenesisValidators + test_conf.full_nodes +
        test_conf.outsider_validators + test_conf.outsider_full_nodes;

    NodeConfig makeNodeConfig (Address address)
    {
        NodeConfig conf =
        {
            address : address,
            retry_delay : test_conf.retry_delay,
            max_retries : test_conf.max_retries,
            timeout : test_conf.timeout,
            validator_cycle : GenesisValidatorCycle,
            max_quorum_nodes : test_conf.max_quorum_nodes,
            quorum_threshold : test_conf.quorum_threshold,
            quorum_shuffle_interval : test_conf.quorum_shuffle_interval,
            preimage_reveal_interval : 1.seconds,  // check revealing frequently
            block_interval_sec : test_conf.block_interval_sec,
            min_listeners : test_conf.min_listeners == 0
                ? (GenesisValidators + test_conf.full_nodes) - 1
                : test_conf.min_listeners,
            max_listeners : (test_conf.max_listeners == 0)
                ? TotalNodes - 1 : test_conf.max_listeners,
        };

        return conf;
    }

    BanManager.Config ban_conf =
    {
        max_failed_requests : test_conf.max_failed_requests,
        ban_duration: 300
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
        const ValidatorConfig validator = {
            enabled : true,
            key_pair : key_pair,
            addresses_to_register : [self_address],
            registry_address : test_conf.registry_address,
            recurring_enrollment : test_conf.recurring_enrollment
        };

        Config conf =
        {
            banman : ban_conf,
            node : makeNodeConfig(self_address),
            validator : validator,
            network : makeNetworkConfig(idx, addresses),
        };

        return conf;
    }

    Config makeFullNodeConfig (size_t idx, Address self_address,
        Address[] addresses)
    {
        Config conf =
        {
            banman : ban_conf,
            node : makeNodeConfig(self_address),
            network : makeNetworkConfig(idx, addresses),
        };

        return conf;
    }

    string validatorAddress (size_t idx, KeyPair key)
    {
        return format("Validator #%s (%s)", idx, key.address);
    }

    string fullNodeAddress (size_t idx)
    {
        return format("FullNode #%s", idx);
    }

    auto genesis_validator_keys = [WK.Keys.NODE2, WK.Keys.NODE3, WK.Keys.NODE4,
        WK.Keys.NODE5, WK.Keys.NODE6, WK.Keys.NODE7];

    auto outsider_validators_keys = WK.Keys.byRange()
        .takeExactly(test_conf.outsider_validators);

    auto validator_keys = genesis_validator_keys ~ outsider_validators_keys.array;

    // all enrolled and un-enrolled validators
    auto validator_addresses = validator_keys.enumerate
        .map!(en => validatorAddress(en.index, en.value)).array;

    // only enrolled validators
    auto enrolled_addresses = genesis_validator_keys.enumerate
        .takeExactly(GenesisValidators)
        .map!(en => validatorAddress(en.index, en.value)).array;

    auto validator_configs = validator_keys.enumerate
        .map!(en => makeValidatorConfig(
            en.index,
            en.value,
            validator_addresses[en.index],
            enrolled_addresses.filter!(  // don't connect the validator to itself
                addr => addr != validator_addresses[en.index]).array));

    const num_full_nodes = test_conf.full_nodes + test_conf.outsider_full_nodes;
    auto full_node_addresses = num_full_nodes.iota.map!(
        idx => fullNodeAddress(idx)).array;

    // full nodes will connect to enrolled addresses + other full nodes
    // (but not to outsider nodes)
    auto connect_addresses = enrolled_addresses.chain(full_node_addresses);

    auto full_node_configs = num_full_nodes
        .iota
        .map!(index => makeFullNodeConfig(
            index,
            full_node_addresses[index],
            connect_addresses.filter!(  // don't connect the fullnode to itself
                addr => addr != full_node_addresses[index]).array));

    auto all_configs = validator_configs.chain(full_node_configs).array;

    immutable string gen_block_hex = GenesisBlock
        .serializeFull()
        .toHexString();

    const test_start_time = time(null);
    foreach (ref conf; all_configs)
        conf.node.testing = true;

    immutable(Block)[] blocks = generateExtraBlocks(GenesisBlock,
        test_conf.extra_blocks);

    auto net = new APIManager(blocks, test_conf, test_start_time);
    foreach (ref conf; all_configs)
        net.createNewNode(conf, file, line);

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
