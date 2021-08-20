/*******************************************************************************

    Standalone server to implement a name registry

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.registry.main;

import agora.common.DNS;
import agora.registry.API;
import agora.registry.Config;
import agora.registry.Server;
import agora.serialization.Serializer;
import agora.stats.Server;

import vibe.core.core;
import vibe.core.net;
import vibe.http.router;
import vibe.http.server;
import vibe.web.rest;

import std.getopt;
import std.stdio;

///
private int main (string[] args)
{
    import vibe.core.log;
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

    if (cmdline_args.verbose)
        setLogLevel(LogLevel.verbose3);

    StatsServer stats_server;
    if (cmdline_args.stats_port != 0)
        stats_server = new StatsServer(cmdline_args.stats_port);

    auto router = new URLRouter();
    auto registry = new NameRegistry();
    router.registerRestInterface(registry);

    auto settings = new HTTPServerSettings;
    settings.port = cmdline_args.bind_port;
    settings.bindAddresses = [cmdline_args.bind_address];
    listenHTTP(settings, router);

    if (!cmdline_args.nodns)
        runTask(() => runDNSServer(registry));

    return runEventLoop();
}

/*******************************************************************************

    Starts the DNS server using the provided registry

    This listens to UDP port 53 for DNS queries, which are then forwarded
    to the registry to be answered.

    The `canThrow` function is wrapped by a higher level `nothrow` one,
    which handles the `try` / `catch` in case of fatal error.
    Throwing from the `canThrow`function is a fatal error,
    so client connections should not lead to `Exception` escaping this function.

    Params:
      registry = The name registry to forward the queries to.

*******************************************************************************/

private void runDNSServer_canThrow (NameRegistry registry)
{
    // The `listenUDP` needs to be in the `runTask` otherwise we get
    // a fatal error due to a bug in vibe-core (see comment #2):
    /// https://github.com/vibe-d/vibe-core/issues/289
    auto udp = listenUDP(53);
    // Otherwise `recv` allocates 65k per call (!!!)
    ubyte[2048] buffer;
    // `recv` will store the peer address here so we can respond
    NetworkAddress peer;
    while (true)
    {
        try
        {
            auto pack = udp.recv(buffer, &peer);
            auto query = deserializeFull!Message(pack);
            auto resp = registry.answerQuestions(query);
            udp.send(serializeFull(resp), &peer);
        }
        catch (Exception exc)
        {
            scope (failure) assert(0);
            stderr.writeln("Exception thrown while handling query: ", exc);
        }
    }
}

/// Ditto
private void runDNSServer (NameRegistry registry) nothrow
{
    try
        runDNSServer_canThrow(registry);
    catch (Exception exc)
    {
        try
            stderr.writeln("Fatal error while running the DNS server: ", exc);
        catch (Exception exc2)
            printf("Couldn't print message following fatal error in DNS!\n");
        assert(0);
    }
}
