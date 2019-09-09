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
import agora.network.NetworkManager;
import agora.node.Node;
import agora.utils.Log;

import vibe.core.core;
import vibe.http.router;
import vibe.http.server;
import vibe.web.rest;

import ocean.util.log.Logger;

import std.file;
import std.getopt;
import std.stdio;

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

    try
    {
        auto config = parseConfigFile(cmdln);
        if (cmdln.config_check)
        {
            writefln("Config file '%s' succesfully parsed.", cmdln.config_path);
            return 0;
        }

        Log.root.level(config.logging.log_level, true);
        log.trace("Config is: {}", config);

        auto settings = new HTTPServerSettings(config.node.address);
        settings.port = config.node.port;
        auto router = new URLRouter();

        mkdirRecurse(config.node.data_dir);

        auto node = new Node(config);
        scope(exit) node.shutdown();

        router.registerRestInterface(node);
        runTask({ node.start(); });

        log.info("About to listen to HTTP: {}", settings.port);
        listenHTTP(settings, router);

        return runEventLoop();
    }
    catch (ConfigException ex)
    {
        writefln("Failed to parse config file '%s'. Error: %s",
            cmdln.config_path, ex.message);
        return 1;
    }
}
