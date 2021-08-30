/*******************************************************************************

    Standalone server to implement a name registry

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.registry.main;

import agora.common.Config;
import agora.common.DNS;
import agora.registry.API;
import agora.registry.Config;
import agora.registry.Server;
import agora.serialization.Serializer;
import agora.stats.Server;
import agora.utils.Log;

import vibe.core.core;
import vibe.core.net;
import vibe.http.router;
import vibe.http.server;
import vibe.web.rest;

import std.getopt;
import std.stdio;
import std.typecons : Nullable;

///
private int main (string[] strargs)
{
    RegistryCLIArgs args;
    try
    {
        auto help = args.parseCommandLine(strargs);
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

    Nullable!Config configN = () {
        try
            return Nullable!Config(parseConfigFile!Config(args.base));
        catch (Exception ex)
        {
            writefln("Failed to parse configuration file '%s'", args.base.config_path);
            writeln(ex);
            return Nullable!Config();
        }
    }();
    if (configN.isNull)
        return 1;

    auto config = configN.get();
    // Also in `agora.node.Runner`
    foreach (const ref settings; config.logging)
    {
        if (settings.name.length == 0 || settings.name == "vibe")
            setVibeLogLevel(settings.level);
        configureLogger(settings, true);
    }

    StatsServer stats_server;
    if (config.http.stats_port != 0)
        stats_server = new StatsServer(config.http.stats_port);

    auto router = new URLRouter();
    auto registry = new NameRegistry();
    router.registerRestInterface(registry);

    auto settings = new HTTPServerSettings;
    settings.port = config.http.port;
    settings.bindAddresses = [config.http.address];
    listenHTTP(settings, router);

    if (!config.dns.enabled)
        return runEventLoop();

    runTask(() => runDNSServer(config, registry));
    auto listener = listenTCP(config.dns.port, (conn) => conn.runTCPDNSServer(registry), config.dns.address);
    scope (exit) listener.stopListening();
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
      config = Registry configuration
      registry = The name registry to forward the queries to.

*******************************************************************************/

private void runDNSServer_canThrow (in Config config, NameRegistry registry)
{
    // The `listenUDP` needs to be in the `runTask` otherwise we get
    // a fatal error due to a bug in vibe-core (see comment #2):
    /// https://github.com/vibe-d/vibe-core/issues/289
    auto udp = listenUDP(config.dns.port, config.dns.address);
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
private void runDNSServer (in Config config, NameRegistry registry) nothrow
{
    try
        runDNSServer_canThrow(config, registry);
    catch (Exception exc)
    {
        try
            stderr.writeln("Fatal error while running the DNS server: ", exc);
        catch (Exception exc2)
            printf("Couldn't print message following fatal error in DNS!\n");
        assert(0);
    }
}

/*******************************************************************************

    Run the DNS server on TCP port 53

    While regular requests are sent over UDP, some actions,
    such as zone transfer, or retry when truncation is encountered,
    are done of TCP.

    For the `canThrow` function, see `runDNSServer`'s documentation.

    Params:
      conn = TCP connection for this request.
      registry = The name registry to forward the queries to.

*******************************************************************************/

private void runTCPDNSServer (TCPConnection conn, NameRegistry registry) @trusted nothrow
{
    try
        runTCPDNSServer_canThrow(conn, registry);
    catch (Exception exc)
    {
        try
            stderr.writeln("Fatal error while running the DNS server (TCP): ", exc);
        catch (Exception exc2)
            printf("Couldn't print message following fatal error in (TCP) DNS!\n");
        assert(0);
    }
}

/// Ditto
private void runTCPDNSServer_canThrow (TCPConnection conn, NameRegistry registry) @trusted
{
    ubyte[2048] buffer;
    scope reader = (size_t size) @safe {
        assert(size <= buffer.length);
        conn.read(buffer[0 .. size]);
        return buffer[0 .. size];
    };

    try
    {
        auto query = deserializeFull!Message(reader);
        auto resp = registry.answerQuestions(query);
        resp.serializePart(&conn.write);
    }
    catch (Exception exc)
    {
        stderr.writeln("Exception happened while handling TCP request: {}", exc);
    }
}
