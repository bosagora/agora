/*******************************************************************************

    Configuration definition for the registry's CLI arguments and config file

    See `doc/registry-config.example.yaml` for some documentation.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.registry.Config;

import std.conv;
import std.getopt;

///
struct CommandlineArgs
{
    string bind_address = "0.0.0.0";
    ushort bind_port = 3003;
    ushort stats_port = 0;
    bool verbose = false;
    bool nodns = false;
}

/// Parse the command-line arguments and return a GetoptResult
public GetoptResult parseCommandLine (ref CommandlineArgs cmdline_args, string[] args)
{
    return getopt(
        args,
        "bind-host|h",
            "Address where the name register server will bind to, defaults to: " ~ CommandlineArgs.init.bind_address,
            &cmdline_args.bind_address,
        "bind-port|p",
            "Port where the name register server will bind to, defaults to: " ~ to!string(CommandlineArgs.init.bind_port),
            &cmdline_args.bind_port,
        "stats-port",
            "Port where the stats server will bind to (0 to disable), defaults to: " ~ to!string(CommandlineArgs.init.stats_port),
            &cmdline_args.stats_port,
        "no-dns",
            "Disable the registry's DNS server",
            &cmdline_args.nodns,
        "verbose",
            &cmdline_args.verbose,
        );
}
