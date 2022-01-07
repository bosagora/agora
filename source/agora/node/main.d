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
import agora.config.Config;
import agora.config.Exceptions;
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

    Nullable!Config config = ()
    {
        try
            return Nullable!Config(parseConfigFile!Config(cmdln));
        catch (ConfigException ex)
        {
            writefln("Failed to parse configuration file '%s'", cmdln.config_path);
            writefln("%S", ex);
            return Nullable!Config();
        }
        catch (Exception ex)
        {
            writefln("Failed to read configuration file '%s'", cmdln.config_path);
            writeln(ex.message());
            return Nullable!Config();
        }
    }();
    if (config.isNull)
        return 1;

    if (cmdln.config_check)
    {
        if (!cmdln.quiet)
            writefln("Config file '%s' successfully parsed.", cmdln.config_path);
        return 0;
    }

    if (config.get().admin.enabled && !config.get().validator.enabled)
    {
        writeln("Cannot have admin interface enabled for non-validator node");
        return 1;
    }

    auto file_based_lock = FileBasedLock("agoraNode.lock", config.get().node.data_dir, true);
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
                listeners = runNode(config.get());
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
