/*******************************************************************************

    Contains a function which instantiates either a FullNode or a Validator.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.Runner;

import agora.api.FullNode;
import agora.api.Validator;
import agora.common.DNS;
import agora.common.Task : Periodic;
import agora.flash.api.FlashAPI;
import agora.flash.Node;
import agora.node.admin.AdminInterface;
import agora.node.Config;
import agora.node.FullNode;
import agora.node.Validator;
import agora.serialization.Serializer;
import agora.utils.Log;

import agora.registry.Config;
import agora.registry.Server;

import ocean.util.log.ILogger;

import vibe.core.core;
import vibe.http.auth.basic_auth;
import vibe.http.server;
import vibe.http.router;
import vibe.web.rest;
import vibe.stream.tls;

import std.algorithm : filter;
import std.file;
import std.format;
import std.typecons : Tuple, tuple;
import std.stdio;

import core.time;

///
public alias Listeners = Tuple!(
    FullNode, "node",
    AdminInterface, "admin",
    AgoraFlashNode, "flash",
    NameRegistry, "registry",
    HTTPListener[], "http"
 );

/*******************************************************************************

    Boots up a FullNode or Validator that listens for network requests and
    blockchain data.

    This is called from the main or CLI.
    The initialization process of the node is then completed.

    Params:
      config = A parsed and validated config file

*******************************************************************************/

public Listeners runNode (Config config)
{
    foreach (const ref settings; config.logging)
    {
        if (settings.name.length == 0 || settings.name == "vibe")
            setVibeLogLevel(settings.level);
        configureLogger(settings, true);
    }

    auto log = Logger(__MODULE__);
    log.trace("Config is: {}", config);

    auto router = new URLRouter();

    mkdirRecurse(config.node.data_dir);

    Listeners result;
    if (config.validator.enabled)
    {
        log.trace("Started Validator...");
        auto inst = new Validator(config);
        router.registerRestInterface!(agora.api.Validator.API)(inst);
        if (config.admin.enabled)
            result.admin = inst.makeAdminInterface();
        result.node = inst;
    }
    else
    {
        log.trace("Started FullNode...");
        result.node = new FullNode(config);
        router.registerRestInterface!(agora.api.FullNode.API)(result.node);
    }

    if (config.flash.enabled)
    {
        import agora.crypto.Hash;

        log.trace("Started Flash node...");
        const params = FullNode.makeConsensusParams(config);
        auto flash = new AgoraFlashNode(config.flash,
            config.node.data_dir, params.Genesis.hashFull(),
            result.node.getEngine(),
            result.node.getTaskManager(), &result.node.postTransaction,
            &result.node.getBlock, result.node.getNetworkManager());
        router.registerRestInterface!FlashAPI(flash);
        result.flash = flash;
    }

    TCPListener dnstcplistener;
    scope (exit)
        if (config.registry.enabled && config.registry.dns.enabled)
        {
            // Here, we might need to interrupt the task to correctly shut down,
            // however this throws an exception in the task that needs to be explicitly
            // handled. And it doesn't help with the error messages printed by Vibe.d.
            //dnstask.interrupt();
            dnstcplistener.stopListening();
        }

    if (config.registry.enabled)
    {
        import agora.registry.API;
        result.registry = new NameRegistry(config.registry, result.node);
        router.registerRestInterface!(NameRegistryAPI)(result.registry);
        if (config.registry.dns.enabled)
        {
            /* auto dnstask = */ runTask(() => runDNSServer(config.registry, result.registry));
            dnstcplistener = listenTCP(config.registry.dns.port, (conn) => conn.runTCPDNSServer(result.registry),
                config.registry.dns.address);
        }
    }

    bool delegate (in NetworkAddress address) @safe nothrow isBannedDg = (in address) @safe nothrow {
        return result.node.getBanManager().isBanned(address.toAddressString());
    };

    // Register a path for `register_listener` adding client's address.
    router.route("/register_listener")
        .post((scope HTTPServerRequest req, scope HTTPServerResponse res)
        {
            string addr = format("http://%s:%d",
                req.clientAddress.toAddressString(), req.clientAddress.port());

            // TODO: disabled as this code is wrong. The client port here is not
            // the listening port of the node which tried to establish a connection.
            version (none)
                result.node.registerListener(addr);
            res.statusCode = 200;
            res.writeVoidBody();
        });

    setTimer(0.seconds, &result.node.start, Periodic.No);  // asynchronous

    string tls_user_help;
    auto tls_ctx = getTLSContext(tls_user_help);
    if (result.admin !is null)
    {

        bool checkPassword (string user, string password) @safe
        {
            return user == config.admin.username && password == config.admin.pwd;
        }
        auto adminrouter = new URLRouter();
        adminrouter.any("*", performBasicAuth("Agora Admin", &checkPassword));
        adminrouter.registerRestInterface(result.admin);
        auto settings = new HTTPServerSettings(config.admin.address);
        settings.port = config.admin.port;
        if (config.admin.tls)
        {
            if (!tls_ctx)
                throw new Exception(tls_user_help ~
                    "Otherwise disable tls by setting `admin.tls` to `false` in the config file " ~
                    "or use `-O admin.tls=false` as command line argument.");
            settings.tlsContext = tls_ctx;
        }
        log.info("Admin interface is listening on http{}://{}:{}",
            config.admin.tls ? "s" : "", config.admin.address, config.admin.port);
        result.http ~= listenHTTP(settings, adminrouter);
    }

    // HTTP interfaces for the node
    foreach (interface_; config.interfaces.filter!(i => i.type <= InterfaceConfig.Type.https))
    {
        auto settings = new HTTPServerSettings(interface_.address);
        settings.port = interface_.port;
        settings.rejectConnectionPredicate = isBannedDg;
        if (interface_.type == InterfaceConfig.Type.https)
        {
            if (!tls_ctx)
                throw new Exception(tls_user_help ~
                    format!"Otherwise set type to `http` for interface `%s:%s` in the config file."(interface_.address, settings.port));
            settings.tlsContext = tls_ctx;
        }
        log.info("Node is listening on interface: http{}://{}:{}",
            interface_.type == InterfaceConfig.Type.https ? "s" : "" , interface_.address, settings.port);
        result.http ~= listenHTTP(settings, router);
    }

    // also register the FlashControlAPI
    if (result.flash !is null)
    {
        log.info("Flash control interface is listening on {}:{}",
            config.flash.control_address, config.flash.control_port);
        result.http ~= result.flash.startControlInterface();
    }

    return result;
}

/*******************************************************************************

    Search multiple paths for SSL certificate and create the TLS context

    Returns:
        TLS context

*******************************************************************************/

private TLSContext getTLSContext (out string user_help_message)
{
    const cert_file = "agora-cert.pem";
    const cert_search_paths = [
        "./",
        "/etc/ssl/certs/",
        "/etc/pki/tls/certs/",
    ];

    const key_file = "agora-key.pem";
    const key_search_paths = [
        "./",
        "/etc/ssl/private/",
        "/etc/pki/tls/private/",
    ];

    TLSContext ctx;
    foreach (idx; 0 .. cert_search_paths.length)
    {
        const cert_path = cert_search_paths[idx] ~ cert_file;
        const key_path = key_search_paths[idx] ~ key_file;

        // Enable TLS
        if (exists(cert_path) && exists(key_path))
        {
            ctx = createTLSContext(TLSContextKind.server);
            ctx.useCertificateChainFile(cert_path);
            ctx.usePrivateKeyFile(key_path);
            break;
        }
        else
        {
            user_help_message = format("To enable tls add a key file named `%s` to one of `%s` " ~
                "and a certificate file named `%s` to corresponding path of `%s`. ",
                key_file, key_search_paths, cert_file, cert_search_paths);
        }
    }

    return ctx;
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

private void runDNSServer_canThrow (in RegistryConfig config, NameRegistry registry)
{
    // The `listenUDP` needs to be in the `runTask` otherwise we get
    // a fatal error due to a bug in vibe-core (see comment #2):
    /// https://github.com/vibe-d/vibe-core/issues/289
    auto udp = listenUDP(config.dns.port, config.dns.address);
    scope (exit) udp.close();
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
private void runDNSServer (in RegistryConfig config, NameRegistry registry) nothrow
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
