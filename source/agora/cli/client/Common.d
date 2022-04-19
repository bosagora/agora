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
import agora.common.Types : Address;

import configy.Read;

import std.getopt;

/// Delegate used to create a client
public alias APIMaker = API delegate (Address address);

/// Shared command line arguments
public struct ClientCLIArgs
{
    /// Common arguments, e.g. `--help`
    public CLIArgs base;

    /// For convenience
    public alias base this;

    /// Address of node, including protocol and port, if necessary
    public Address address;

    ///
    public GetoptResult parse (ref string[] args, bool passThrough = true)
    {
        auto intermediate = this.base.parse(args);
        if (intermediate.helpWanted)
            return intermediate;

        void parseUrlAddress (string option, string value)
        {
            assert(option == "address");
            this.address = Address(value);
        }

        return getopt(
            args,

            // See 'this.base.parse' method
            passThrough ? config.keepEndOfOptions : config.caseInsensitive,
            passThrough ? config.passThrough : config.noPassThrough,

            config.required, "address",
              "Address of a node to send to (including protocol and optionally the port if non-standard)",
              &parseUrlAddress,
        );
    }
}
