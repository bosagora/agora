/*******************************************************************************

    Common code between client modules

    Modules in this package cannot import 'main' directly, hence there needs
    to be a common module where shared types and functions reside.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.client.Common;

import agora.api.FullNode;
import agora.config.Config;

import std.getopt;

/// Delegate used to create a client
public alias APIMaker = API delegate (string address);

/// Shared command line arguments
public struct ClientCLIArgs
{
    /// Common arguments, e.g. `--help`
    public CLIArgs base;

    /// For convenience
    public alias base this;

    /// Address of node (IP address or domain, not including the protocol)
    public string host;

    /// TCP port
    public ushort port = 2826;

    ///
    public GetoptResult parse (ref string[] args, bool passThrough = true)
    {
        auto intermediate = this.base.parse(args);
        if (intermediate.helpWanted)
            return intermediate;

        return getopt(
            args,

            // See 'this.base.parse' method
            passThrough ? config.keepEndOfOptions : config.caseInsensitive,
            passThrough ? config.passThrough : config.noPassThrough,

            "host",
              "Address of node (IP address or domain, not including the protocol)",
              &this.host,

            "port",
              "Port on host to connect to (default:2826)",
              &this.port,
        );
    }
}
