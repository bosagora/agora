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

import agora.common.Config;
import agora.utils.Log;

import std.conv;
import std.getopt;

///
public struct RegistryCLIArgs
{
    /// Base command line arguments
    public CLIArgs base;

    ///
    public alias base this;
}

/// Parse the command-line arguments and return a GetoptResult
public GetoptResult parseCommandLine (ref RegistryCLIArgs args, string[] strargs)
{
    return args.base.parse(strargs, false);
}

/// Configuration for the name registry
public struct Config
{
    /// DNS server configuration
    public DNSConfig dns;

    /// HTTP server configuration
    public HTTPConfig http;

    /// Logging configuration
    @Key("name")
    public LoggerConfig[] logging = [ {
        name: null,
        level: LogLevel.Info,
        propagate: true,
        console: true,
        additive: true,
    } ];
}

///
public struct DNSConfig
{
    /// Whether the DNS server is enabled at all
    public bool enabled = true;

    /***************************************************************************

        The address to bind to - All interfaces by default

        You might want to set this to your public IP address so it doesn't bind
        to the local interface, which might be already used by systemd-resolvd.

    ***************************************************************************/

    public string address = "0.0.0.0";

    /// The port to bind to - Default to the standard DNS port (53)
    public ushort port = 53;
}

///
public struct HTTPConfig
{
    /// Network interface to bind to
    public string address = "0.0.0.0";

    /// TCP port to bind to
    public ushort port = 3003;

    /// Port on which to offer the stats interface - disabled by default
    public @Optional ushort stats_port = 0;
}
