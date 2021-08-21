/*******************************************************************************

    Read a config from a config file, check it, and print the resulting content.

    This utility has verbose output to help debug the config filler.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.cli.configdump;

import agora.common.Config;
import agora.node.Config;

import std.getopt;
import std.stdio;

///
public int main (string[] args)
{
    CommandLine cmdln;
    string type;
    auto help = parseCommandLine(cmdln, type, args);
    if (help.helpWanted)
    {
        defaultGetoptPrinter("Config dumper", help.options);
        return 0;
    }

    switch (type)
    {
    case "agora":
        auto config = parseConfigFile!(Config)(cmdln);
        writeln("Configuration for ", type, " successfully parsed:");
        writeln(config);
        return 0;
    default:
        stderr.writeln("No such type: ", type);
        return 1;
    }
}

/// Parse the command-line arguments and return a GetoptResult
private GetoptResult parseCommandLine (
    ref CommandLine cmdline, ref string type, string[] args)
{
    return getopt(
        args,
        "config|c",
            "Path to the config file. Defaults to: " ~ CommandLine.init.config_path,
            &cmdline.config_path,

        "type|t",
            "Type of config to parse (agora, registry). Default to 'agora'",
            &type,
        );
}
