/*******************************************************************************

    Standalone server to implement a name registry

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.registry.main;

import agora.registry.API;
import agora.registry.Server;

import vibe.core.core;
import vibe.http.router;
import vibe.http.server;
import vibe.web.rest;

import std.conv;
import std.getopt;
import std.stdio;

///
struct CommandlineArgs
{
    string bind_address = "0.0.0.0";
    ushort bind_port = 3003;
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
        );
}

///
private int main (string[] args)
{
    CommandlineArgs cmdline_args;
    try
    {
        auto help = parseCommandLine(cmdline_args, args);
        if (help.helpWanted)
        {
            defaultGetoptPrinter("Name Registry Server", help.options);
            return 0;
        }
    }
    catch (Exception ex)
    {
        writefln("Error parsing command-line arguments '%(%s %)': %s", args, ex.message);
        return -1;
    }

    auto router = new URLRouter();
    router.registerRestInterface(new NameRegistry());

    auto settings = new HTTPServerSettings;
    settings.port = cmdline_args.bind_port;
    settings.bindAddresses = [cmdline_args.bind_address];
    listenHTTP(settings, router);
    return runEventLoop();
}
