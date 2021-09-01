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

import std.algorithm.iteration : splitter;
import std.conv;
import std.exception;
import std.format;
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

    /// Validate the semantic of the user-provided configuration
    public void validate () const
    {
        if (this.dns.enabled)
        {
            enforce(this.dns.address.length, "DNS is enabled but no `address` is provided");
            enforce(this.dns.port > 0, "dns.port: 0 is not a valid value");
            enforce(this.dns.authoritative.length, "No authoritative zones provided");

            foreach (idx, domain; this.dns.authoritative)
            {
                auto rng = domain.splitter('.');
                enforce(!rng.empty, format!"dns.authoritative: Empty array entry at index %d"(idx));
                enforce(rng.front.length > 0,
                       format!"dns.authoritative: Value '%s' at index '%s' starts with a dot ('.'), which is not allowed. Remove it."
                       (domain, idx)
                    );

                do {
                    // It might be the empty label, in which case it needs to be last
                    if (rng.front.length == 0)
                    {
                        rng.popFront();
                        enforce(rng.empty,
                                format!"dns.authoritative: Value '%s' at index '%s' contains an empty label, which is not allowed. Remove the double dot."
                                (domain, idx));
                        break;
                    }
                    enforce(rng.front.length <= 63,
                            format!("dns.authoritative: Value '%s' at index '%s' contains a label ('%s') " ~
                                    "which is longer than 63 characters (%s characters), which is not allowed.")
                            (domain, idx, rng.front, rng.front.length)
                        );
                    rng.popFront();
                } while (!rng.empty);
            }
        }

        enforce(this.http.address.length, "Missing http.address field");
        enforce(this.http.port > 0, "http.port: 0 is not a valid value");
    }
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

    /// Which zones this server is authoritative for
    public string[] authoritative;
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
