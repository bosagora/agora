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

import agora.common.Config;
import agora.common.FileBasedLock;
import agora.node.admin.Setup;
import agora.node.FullNode;
import agora.node.Validator;
import agora.node.Runner;
import agora.utils.Workarounds;

import vibe.core.core;
import vibe.inet.url;
import vibe.http.server;

import std.getopt;
import std.path : absolutePath;
import std.stdio;
import std.typecons : Nullable;

/// Application entry point
private int main (string[] args)
{
    CommandLine cmdln;

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
        if (auto ret = runEventLoop())
            return ret;
    }

    Nullable!Config config = ()
    {
        try
            return Nullable!Config(parseConfigFile(cmdln));
        catch (Exception ex)
        {
            writefln("Failed to parse config file '%s'. Error: %s",
                     cmdln.config_path, ex.message);
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

    Listeners listeners;
    runTask(() => listeners = runNode(config.get()));
    scope (exit)
    {
        // Note: Listener could be default-initialized, in which case all checks
        // will be false and the foreach will not loop.
        foreach (ref l; listeners.http)
            l.stopListening();
        if (listeners.node !is null)
            listeners.node.shutdown();
    }
    return runEventLoop();
}
