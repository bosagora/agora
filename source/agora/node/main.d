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
import agora.consensus.data.ConsensusParams;
import agora.node.FullNode;
import agora.node.Validator;
import agora.node.Runner;
import agora.utils.Log;

import vibe.core.core;

import std.getopt;
import std.stdio;

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

    FullNode node;
    try
    {
        auto config = parseConfigFile(cmdln);
        if (cmdln.config_check)
        {
            writefln("Config file '%s' succesfully parsed.", cmdln.config_path);
            return 0;
        }

        runTask(() => node = runNode(config, new immutable(ConsensusParams)()));
    }
    catch (Exception ex)
    {
        writefln("Failed to parse config file '%s'. Error: %s",
            cmdln.config_path, ex.message);
        return 1;
    }

    scope(exit) if (node !is null) node.shutdown();
    return runEventLoop();
}
