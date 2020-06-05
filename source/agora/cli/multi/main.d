/*******************************************************************************

    Entry point for running multiple agora nodes within the same binary

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.cli.multi.main;

import agora.common.Config;
import agora.node.FullNode;
import agora.node.Validator;
import agora.node.Runner;
import agora.utils.Log;

import vibe.core.core;
import vibe.web.rest;
import vibe.inet.url;

import std.exception;
import std.file;
import std.format;
import std.path;
import std.range;
import std.stdio;
import std.string;


/*******************************************************************************

    Application entry point

*******************************************************************************/

private int main (string[] args)
{
    // Validate parameters
    if (args.length < 2)
    {
        printDefaultHelp();
        return 1;
    }

    string[] files;
    // If the root path is not set,
    if (extension(args[1]).toLower == ".yaml")
        files = args[1..$];
    else
    // If the root path is set,
        foreach (arg; args[2 .. $])
            files ~= buildNormalizedPath(args[1], arg);

    // Reads all configurations from the file.
    Config[] configs;
    foreach (idx, file; files)
    {
        try
        {
            // Read
            auto config = readFromFile(file);

            // Make sure that where the configuration file is located is the root directory of the node.
            // The data directory on the node has been changed to an absolute path.
            config.node.data_dir = buildNormalizedPath(dirName(file), config.node.data_dir);

            // Multiple nodes simultaneously output logs to the console.
            // To reduce complexity, only errors are printed.
            // Other improvements are needed in the future.
            config.logging.log_level = LogLevel.Error;

            // Change the network address of the nodes.
            string[] converted_network;
            foreach (address; config.network)
            {
                auto node_url = URL(address);
                node_url.host = "127.0.0.1";
                converted_network ~= node_url.toString;
            }

            Config converted_config =
            {
                banman : config.banman,
                node : config.node,
                network : assumeUnique(converted_network),
                dns_seeds : config.dns_seeds,
                logging: config.logging,
                admin: config.admin,
            };

            // Add
            configs ~= converted_config;
        }
        catch (Exception ex)
        {
            writefln("Failed to parse config file '%s'. Error: %s",
                file, ex.message);
            return 1;
        }
    }

    FullNode[] nodes;
    foreach (const ref config; configs)
        nodes ~= runNode(config, new immutable(ConsensusParams)());

    scope (exit)
    {
        foreach (node; nodes)
            node.shutdown();
    }

    return runEventLoop();
}


/*******************************************************************************

    Print out help for this process.

*******************************************************************************/

private void printDefaultHelp ()
{
    writeln("usage: agora-multi [path] node0.yaml node1.yaml node2.yaml ...");
}


/*******************************************************************************

    Read config from file

    Params:
      filename = A file name of configurationn of the node

    Returns:
      The configuration objects that are used through the node

*******************************************************************************/

private Config readFromFile (string filename)
{
    CommandLine cmdln;
    cmdln.config_path = filename;
    return parseConfigFile(cmdln);
}
