/*******************************************************************************

    Entry point for the Agora node

    Each node is a Vibe.d server application.

    On startup, it tries to connect with a range of known hosts to join the
    quorum. It then starts to listen for requests, using a REST interface.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.main;

// TODO: Remove those two lines when compatibility for dub < v1.24 is dropped
version (unittest) {}
else:

import agora.common.FileBasedLock;
import agora.common.Types;
import agora.node.admin.Setup;
import agora.node.Config;
import agora.node.FullNode;
import agora.node.Validator;
import agora.node.Runner;
import agora.utils.Workarounds;
import agora.utils.TracyAPI;

import vibe.core.core;
import vibe.inet.url;
import vibe.http.server;

import configy.Read;

import std.getopt;
import std.path : absolutePath;
import std.stdio;
import std.typecons : Nullable;

import core.atomic;
import core.exception;

/// Application entry point
private int main (string[] args)
{
    AgoraCLIArgs cmdln;

    stAssertError = new AssertError("You should not see this");
    assertHandler = &handleAssertion;

    try
    {
        auto help = parseCommandLine(cmdln, args);
        if (help.helpWanted)
        {
            defaultGetoptPrinter("The Agora node", help.options);
            return 0;
        }
        if (cmdln.version_)
        {
            enum build_version = import(VersionFileName);
            writeln("Agora ", build_version, ", build on ", __TIMESTAMP__);
            writeln("Built with the LDC compiler, frontend version: ", __VERSION__);
            return 0;
        }
    }
    catch (Exception ex)
    {
        writefln("Error parsing command-line arguments '%(%s %)': %s", args,
            ex.message);
        return 1;
    }

    // Do not use Vibe.d default signal handler, instead set up our own as we
    // need to properly shut down our node.
    disableDefaultSignalHandlers();

    version (Posix)
    {
        import core.sys.posix.signal;

        sigset_t sigset;
        sigemptyset(&sigset);

        sigaction_t siginfo;
        siginfo.sa_handler = getSignalHandler();
        siginfo.sa_mask = sigset;
        siginfo.sa_flags = SA_RESTART;
        sigaction(SIGINT, &siginfo, null);
        sigaction(SIGTERM, &siginfo, null);
    }

    // Run setup interface if needed
    if (cmdln.initialize.length)
    {
        if (cmdln.config_check)
        {
            writeln("Error: Cannot have both `--initialize` and `--config-check` switch");
            return 1;
        }

        URL url = (string s) {
            // Will work if the user entered e.g. `http://127.0.0.1`
            try return URL(s);
            // Maybe the user entered `127.0.0.1`, so try this
            // See: https://github.com/vibe-d/vibe.d/pull/2311
            catch (Exception e)
            {
                try return URL("http://" ~ s);
                catch (Exception e2) {}
                return URL.init;
            }
        }(cmdln.initialize);

        if (url == URL.init)
        {
            stderr.writeln("Could not initialize setup interface at address: ",
                           cmdln.initialize);
            stderr.writeln("Make sure it's a valid address, such as 'http://127.0.0.1:2827', " ~
                           "or '0.0.0.0:2827'");
            return 1;
        }

        writeln("Setup interface listening to ", url, " and will write to: ",
                cmdln.config_path.absolutePath());
        scope setup = new SetupInterface(cmdln.config_path);
        setup.start(url);
        return runEventLoop();
    }

    Nullable!Config configN = ()
    {
        if (cmdln.testnet)
            return makeTestNetConfig(cmdln);

        if (cmdln.config_path == "/dev/null")
            return Nullable!Config(Config.init);
        return cmdln.parseConfigFileSimple!Config();
    }();
    if (configN.isNull)
        return 1;

    if (cmdln.config_check)
    {
        if (!cmdln.quiet)
            writefln("Config file '%s' successfully parsed.", cmdln.config_path);
        return 0;
    }

    auto config = configN.get();
    if (config.admin.enabled && !config.validator.enabled)
    {
        writeln("Cannot have admin interface enabled for non-validator node");
        return 1;
    }

    auto file_based_lock = FileBasedLock("agoraNode.lock", config.node.data_dir, true);
    try
        file_based_lock.lockThrow();
    catch (Exception ex)
    {
        writefln("Unable to lock '%s' file. Error: %s", file_based_lock.file_path, ex);
        return 2;
    }
    scope(exit) file_based_lock.unlock();

    runTask(
        () nothrow {
            try
                listeners = runNode(config);
            catch (Exception exc)
            {
                try
                    writeln("Agora initialization failed! The following Exception might help: ", exc);
                catch (Exception nexc)
                {
                    printf("FATAL ERROR: Agora initialization failed: %.*s\n",
                           cast(int) exc.msg.length, exc.msg.ptr);
                    printf("This error was followed by: %*.s\n",
                           cast(int) nexc.msg.length, nexc.msg.ptr);
                }
                printf("Terminating event loop...\n");
                exitEventLoop();
            }
        });
    scope (exit)
    {
        // Note: Listener could be default-initialized, in which case all checks
        // will be false and the foreach will not loop.
        foreach (ref l; listeners.http)
            l.stopListening();
        foreach (ref l; listeners.tcp)
            l.stopListening();
        if (listeners.node !is null)
            listeners.node.shutdown();
    }

    if (auto ret = runEventLoop())
        return ret;
    return atomicLoad(exitCode);
}

/// Global references to the listeners / node, as they need to be accessed
/// from the signal handler
private __gshared Listeners listeners;

/// Type of the handler that is called when a signal is received
alias SigHandlerT = extern(C) void function (int sig) nothrow;

/// Returns a signal handler
/// This routine is there solely to ensure the function has a mangled name,
/// and doesn't accidentally conflict with other code.
private SigHandlerT getSignalHandler () @safe pure nothrow @nogc
{
    extern(C) void signalHandler (int signal) nothrow
    {
        // Calling `printf` because `writeln` is not `@nogc`
        printf("Received signal %d, shutting down listeners...\n", signal);
        foreach (ref l; listeners.http)
        {
            try
            {
                l.stopListening();
                l = typeof(l).init;
            }
            catch (Exception exc)
            {
                printf("Exception thrown while stopping an HTTP listener: %.*s\n",
                       cast(int) exc.msg.length, exc.msg.ptr);
                debug {
                    scope (failure) assert(0);
                    writeln("========================================");
                    writeln("Full stack trace: ", exc);
                }
            }
        }

        printf("Calling node shutdown procedure...\n");
        if (listeners.node !is null)
        {
            try listeners.node.shutdown();
            catch (Exception exc)
            {
                printf("Exception thrown while calling `shutdown` on the node: %.*s\n",
                       cast(int) exc.msg.length, exc.msg.ptr);
                debug {
                    scope (failure) assert(0);
                    writeln("========================================");
                    writeln("Full stack trace: ", exc);
                }
            }
            listeners.node = null;
        }

        printf("Terminating event loop...\n");
        exitEventLoop();
    }

    return &signalHandler;
}

/*******************************************************************************

    Print a message, then throw a statically allocated assert error

    Because one can't use `assert` in destructor:
    https://github.com/dlang/druntime/blob/20679d4ee80ce6df994d9b1bdfad64484fee46f0/src/core/exception.d#L429

*******************************************************************************/

private void handleAssertion (string file, size_t line, string msg) nothrow
{
    import core.stdc.stdio;

    printf("Assert triggered at '%.*s:%zu': %.*s\n",
           cast(int) file.length, file.ptr, line, cast(int) msg.length, msg.ptr);
    stAssertError.msg = msg;
    stAssertError.file = file;
    stAssertError.line = line;
    throw stAssertError;
}

/// A statically allocated instance to avoid invalid memory errors in destructors
private AssertError stAssertError;

/// Work around issue #3030 and allow internal testing
private immutable Address[] TestNetNodes;

shared static this ()
{
    TestNetNodes = [
        Address("http://boa1xzval2a3cdxv28n6slr62wlczslk3juvk7cu05qt3z55ty2rlfqfc6egsh2.validators.testnet.bosagora.io/"),
        Address("http://boa1xzval3ah8z7ewhuzx6mywveyr79f24w49rdypwgurhjkr8z2ke2mycftv9n.validators.testnet.bosagora.io/"),
        Address("http://boa1xzval4nvru2ej9m0rptq7hatukkavemryvct4f8smyy3ky9ct5u0s8w6gfy.validators.testnet.bosagora.io/"),
        Address("http://boa1xrval5rzmma29zh4aqgv3mvcarhwa0w8rgthy3l9vaj3fywf9894ycmjkm8.validators.testnet.bosagora.io/"),
        Address("http://boa1xrval6hd8szdektyz69fnqjwqfejhu4rvrpwlahh9rhaazzpvs5g6lh34l5.validators.testnet.bosagora.io/"),
        Address("http://boa1xrval7gwhjz4k9raqukcnv2n4rl4fxt74m2y9eay6l5mqdf4gntnzhhscrh.validators.testnet.bosagora.io/"),
    ];
}

/// Helper function for TestNet configuration
private Nullable!Config makeTestNetConfig (AgoraCLIArgs cmdln)
{
    import agora.api.FullNode;
    import agora.common.DNS;
    import vibe.web.rest;
    static import std.file;
    import core.time;

    // If the user provided a configuration, they likely want to run
    // a validator, or have some special config (e.g. interfaces, logging...).
    // In this case, we just override the `consensus` part, and set `network`
    // if it is not.
    if (std.file.exists(cmdln.config_path))
    {
        auto configN = cmdln.parseConfigFileSimple!Config();
        // If an error happened while parsing the file, just stop
        if (configN.isNull())
            return configN;

        auto config = configN.get();
        scope client = new RestInterfaceClient!API(config.node.registry_address.toString());
        auto params = client.getConsensusParams();

        Config defaultConfig = {
            banman: config.banman,
            node: config.node,
            interfaces: config.interfaces,
            proxy: config.proxy,
            consensus: params.data.config,
            validator: config.validator,
            flash: config.flash,
            admin: config.admin,
            registry: config.registry,
            network: config.network.length ? config.network : TestNetNodes,
            dns_seeds: config.dns_seeds,
            logging: config.logging,
            event_handlers: config.event_handlers,
        };
        return Nullable!Config(defaultConfig);
    }

    // Otherwise, this is the default config for TestNet when
    // no config file is provided.
    scope client = new RestInterfaceClient!API("http://ns1.bosagora.io");
    auto params = client.getConsensusParams();
    Config defaultConfig = {
        node: {
            testing: true,
            realm: Domain.fromSafeString("testnet.bosagora.io."),
            registry_address: Address("http://ns1.bosagora.io"),
        },
        network: TestNetNodes,
        consensus: params.data.config,
    };
    return Nullable!Config(defaultConfig);
}
