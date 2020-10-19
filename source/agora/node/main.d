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

import agora.common.Config;
import agora.common.FileBasedLock;
import agora.node.FullNode;
import agora.node.Validator;
import agora.node.Runner;
import agora.utils.Log;

import vibe.core.core;
import vibe.http.server;

import std.getopt;
import std.stdio;
import std.typecons : Nullable;

/**
 * Workaround for segfault similar (or identical) to https://github.com/dlang/dub/issues/1812
 * https://dlang.org/changelog/2.087.0.html#gc_parallel
 */
static if (__VERSION__ >= 2087)
    extern(C) __gshared string[] rt_options = [ "gcopt=parallel:0" ];

/// Workaround for issue likely related to dub #225,
/// expects a main() function and invokes it after unittesting.
version (unittest) void main () { } else:

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
    }
    catch (Exception ex)
    {
        writefln("Error parsing command-line arguments '%(%s %)': %s", args,
            ex.message);
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
