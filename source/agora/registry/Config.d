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
public struct CLIArgs
{
    /// Network interface to bind to
    public string bind_address = "0.0.0.0";

    /// TCP port to bind to
    public ushort bind_port = 3003;

    /// Port on which to offer the stats interface - disabled by default
    public ushort stats_port = 0;

    /// Be extra verbose (enable `Trace` level and Vibe.d debug)
    public bool verbose = false;

    /// Disable the DNS server
    public bool nodns = false;
}

/// Parse the command-line arguments and return a GetoptResult
public GetoptResult parseCommandLine (ref CLIArgs args, string[] strargs)
{
    return getopt(
        strargs,
        "bind-host|h",
            "Address to bind the HTTP server to, defaults to: " ~ CLIArgs.init.bind_address,
            &args.bind_address,
        "bind-port|p",
            "Port to bind the HTTP server to, defaults to: " ~ CLIArgs.init.bind_port.to!string,
            &args.bind_port,
        "stats-port",
            "Port to bind the stats server to (0 to disable), defaults to: " ~ CLIArgs.init.stats_port.to!string,
            &args.stats_port,
        "no-dns",
            "Disable the registry's DNS server",
            &args.nodns,
        "verbose",
            &args.verbose,
        );
}
