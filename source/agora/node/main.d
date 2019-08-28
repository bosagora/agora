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
import agora.network.FilteredURLRouter;
import agora.node.Node;

import vibe.core.core;
import vibe.core.log;
import vibe.http.router;
import vibe.http.server;
import vibe.web.rest;

import std.file;
import std.getopt;
import std.stdio;

/// Workaround for issue likely related to dub #225,
/// expects a main() function and invokes it after unittesting.
version (unittest) void main () { } else:

/// Required initialization
shared static this ()
{
    import agora.common.TransactionPool;
    TransactionPool.initialize();
}

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

        setLogLevel(config.logging.log_level);
        logTrace("Config is: %s", config);

        mkdirRecurse(config.node.data_dir);
        // Support code coverage being written to the data directory
        // This way we can collect data from docker containers
        // Note: This DOES NOT WORK WITH LDC (#221)
        version (D_Coverage)
        {
            import core.runtime;
            immutable coverPath = config.node.data_dir.buildPath("coverage");
            dmd_coverDestPath(coverPath);
        }

        auto node = new Node(config);
        scope(exit) node.shutdown();

        auto settings = new HTTPServerSettings(config.node.address);
        settings.port = config.node.port;
        auto router = new FilteredURLRouter(node.banman);

        router.registerRestInterface(node);
        runTask({ node.start(); });

        logInfo("About to listen to HTTP: %s", settings.port);
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
