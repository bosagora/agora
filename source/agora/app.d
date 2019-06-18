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

module agora.app;

import agora.common.Config;
import agora.node.Node;

import vibe.core.core;

import std.getopt;
import std.stdio;

/// Workaround for issue likely related to dub #225,
/// expects a main() function and invokes it after unittesting.
version (unittest) void main () { } else:

/// Application entry point
private int main (string[] args)
{
    CommandLine cmdln;
    auto help = parseCommandLine(cmdln, args);
    if (help.helpWanted)
    {
        defaultGetoptPrinter("The Agora node", help.options);
        return 0;
    }

    auto config = parseConfigFile(cmdln);
    if (cmdln.config_check)
    {
        writefln("Config file '%s' succesfully parsed.", cmdln.config_path);
        return 0;
    }

    auto node = new Node(config);
    return runEventLoop();
}
