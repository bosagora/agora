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

import std.getopt;
import std.stdio;

///
private struct AppCLIArgs
{
    ///
    public CLIArgs base;

    ///
    public alias base this;

    /// Type of configuration to parse
    public string type = "agora";

    /// Parse the command-line arguments and return a GetoptResult
    public GetoptResult parse (ref string[] args)
    {
        auto r = this.base.parse(args);
        if (r.helpWanted) return r;
        return getopt(
            args,
            "type|t",
               "Type of config to parse. Default to: " ~ this.type,
                &this.type,
        );
    }
}

///
public int main (string[] args)
{
    AppCLIArgs cmdln;
    auto help = cmdln.parse(args);
    if (help.helpWanted)
    {
        defaultGetoptPrinter("Config dumper", help.options);
        return 0;
    }

    switch (cmdln.type)
    {
    case "agora":
        import agora.node.Config;
        auto config = parseConfigFile!(Config)(cmdln);
        writeln("Configuration for ", cmdln.type, " successfully parsed:");
        writeln(config);
        return 0;
    default:
        stderr.writeln("No such type: ", cmdln.type);
        return 1;
    }
}
