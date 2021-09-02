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

/// Configuration for the name registry
public struct RegistryConfig
{
    /// If this node should also act as a registry
    public bool enabled;

    /// DNS server configuration
    public DNSConfig dns;

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
    public immutable(string[]) authoritative;
}
