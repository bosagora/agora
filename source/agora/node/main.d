/*******************************************************************************

    Entry point for the Agora node

    Each node is a Vibe.d server application.

    On startup, it tries to connect with a range of known hosts to join the
    quorum. It then starts to listen for requests, using a REST interface.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
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
import agora.node.FullNode;
import agora.node.Validator;
import agora.node.Runner;
import agora.utils.Log;
import agora.utils.Workarounds;

import vibe.core.core;
import vibe.http.server;

import std.getopt;
import std.stdio;
import std.typecons : Nullable;

mixin AddLogger!();

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

    auto file_based_lock = FileBasedLock("agoraNode.lock", config.get().node.data_dir, true);
    try
        file_based_lock.lockThrow();
    catch (Exception ex)
    {
        writefln("Unable to lock '%s' file. Error: %s", file_based_lock.file_path, ex);
        return 2;
    }
    scope(exit) file_based_lock.unlock();

    NodeListenerTuple node_listener_tuple;
    runTask(() => node_listener_tuple = runNode(config.get()));
    scope(exit)
    {
        if (node_listener_tuple != NodeListenerTuple.init) with (node_listener_tuple)
        {
            node.shutdown();
            http_listener.stopListening();
        }
    }
    return runEventLoop();
}
