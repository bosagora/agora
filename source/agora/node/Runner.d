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
import agora.common.Ensure;
import agora.common.Task : Periodic;
import agora.common.Types : Address;
import agora.flash.api.FlashAPI;
import agora.flash.Node;
import agora.network.RPC;
import agora.node.admin.AdminInterface;
import agora.node.Config;
import agora.node.FullNode;
import agora.node.Registry;
import agora.node.Validator;
import agora.serialization.Serializer;
import agora.script.Engine;
import agora.utils.Log;

import ocean.util.log.ILogger;

import vibe.core.core;
import vibe.http.auth.basic_auth;
import vibe.http.server;
import vibe.http.router;
import vibe.web.rest;
import vibe.stream.tls;

import std.algorithm : among, any, filter;
import std.file;
import std.format;
import std.functional : toDelegate;
import std.typecons : Tuple, tuple;
import std.stdio;

import core.atomic;
import core.time;

///
public alias Listeners = Tuple!(
    FullNode, "node",
    AdminInterface, "admin",
    FlashNode, "flash",
    HTTPListener[], "http",
    TCPListener[], "tcp",
 );

/// The return code used by the main function
/// See: https://github.com/vibe-d/vibe-core/issues/302
package __gshared int exitCode;

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

    mkdirRecurse(config.node.data_dir);

    Listeners result;
    const bool hasHTTPInterface = config.interfaces.any!(
        i => i.type.among(InterfaceConfig.Type.http, InterfaceConfig.Type.https));
    URLRouter router;
    RestInterfaceSettings settings;
    if (hasHTTPInterface)
    {
        router = new URLRouter();
        settings = new RestInterfaceSettings;
        settings.errorHandler = toDelegate(&restErrorHandler);
    }

    if (config.validator.enabled)
    {
        log.trace("Started Validator...");
        auto inst = new Validator(config);
        if (config.admin.enabled)
            result.admin = inst.makeAdminInterface();
        result.node = inst;
        if (hasHTTPInterface)
            router.registerRestInterface!(agora.api.Validator.API)(inst, settings);
    }
    else
    {
        log.trace("Started FullNode...");
        result.node = new FullNode(config);
        if (hasHTTPInterface)
            router.registerRestInterface!(agora.api.FullNode.API)(result.node, settings);
    }

    if (config.flash.enabled)
    {
        import agora.crypto.Hash;

        log.trace("Started Flash node...");
        const params = FullNode.makeConsensusParams(config);
        auto flash = new FlashNode(config.flash,
            config.node.data_dir, params.Genesis.hashFull(), new Engine(),
            result.node.getTaskManager(), &result.node.postTransaction,
            &result.node.getBlock, &result.node.getNetworkManager().getRegistryClient);
        router.registerRestInterface!FlashAPI(flash, settings);
        result.flash = flash;
    }

    scope (exit)
        if (config.registry.enabled)
        {
            // Here, we might need to interrupt the task to correctly shut down,
            // however this throws an exception in the task that needs to be explicitly
            // handled. And it doesn't help with the error messages printed by Vibe.d.
            //dnstask.interrupt();
        }

    bool delegate (in NetworkAddress address) @safe nothrow isBannedDg = (in address) @safe nothrow {
        try
            return result.node.getBanManager().isBanned(Address("agora://" ~ address.toAddressString()));
        catch (Exception e)
            assert(false, e.msg);
    };

    result.node.start();

    if (config.registry.enabled)
    {
        auto reg = result.node.getRegistry();
        assert(reg !is null);
        if (hasHTTPInterface)
            router.registerRestInterface(reg, settings);
        /* auto dnstask = */ runTask(() => runDNSServer(config.registry, reg));
        result.tcp ~= listenTCP(config.registry.port, (conn) => conn.runTCPDNSServer(reg),
                config.registry.address);
    }

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
        auto adminsettings = new HTTPServerSettings(config.admin.address);
        adminsettings.port = config.admin.port;
        if (config.admin.tls)
        {
            if (!tls_ctx)
                throw new Exception(tls_user_help ~
                    ". Otherwise disable tls by setting `admin.tls` to `false` in the config file " ~
                    "or use `-O admin.tls=false` as command line argument.");
            adminsettings.tlsContext = tls_ctx;
        }
        log.info("Admin interface is listening on http{}://{}:{}",
            config.admin.tls ? "s" : "", config.admin.address, config.admin.port);
        result.http ~= listenHTTP(adminsettings, adminrouter);
    }

    // HTTP interfaces for the node
    foreach (interface_; config.interfaces.filter!(i => i.type <= InterfaceConfig.Type.https))
    {
        auto httpsettings = new HTTPServerSettings(interface_.address);
        httpsettings.port = interface_.port;
        httpsettings.rejectConnectionPredicate = isBannedDg;
        if (interface_.type == InterfaceConfig.Type.https)
        {
            if (!tls_ctx)
                throw new Exception(
                    format!"%s. Otherwise set type to `http` for interface `%s:%s` in the config file."
                    (tls_user_help, interface_.address, httpsettings.port));
            httpsettings.tlsContext = tls_ctx;
        }
        log.info("Node is listening on interface: http{}://{}:{}",
            interface_.type == InterfaceConfig.Type.https ? "s" : "" , interface_.address, interface_.port);
        result.http ~= listenHTTP(httpsettings, router);
    }

    // also register the FlashControlAPI
    if (result.flash !is null)
    {
        log.info("Flash control interface is listening on {}:{}",
            config.flash.control_address, config.flash.control_port);
        result.http ~= result.flash.startControlInterface();
    }

    // TCP interfaces for the node
    foreach (interface_; config.interfaces.filter!(i => i.type == InterfaceConfig.Type.tcp))
    {
        log.info("Node will be listening on TCP interface: {}:{}", interface_.address, interface_.port);
        if (auto fl = cast(agora.api.Validator.API) result.node)
            result.tcp ~= listenRPC!(agora.api.Validator.API)(fl, interface_.address, interface_.port, interface_.proxy_proto,
                config.node.timeout, &result.node.getNetworkManager().discoverFromClient, isBannedDg);
        else
            result.tcp ~= listenRPC!(agora.api.FullNode.API)(result.node, interface_.address, interface_.port, interface_.proxy_proto,
                config.node.timeout, &result.node.getNetworkManager().discoverFromClient, isBannedDg);
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
                "and a certificate file named `%s` to corresponding path of `%s`",
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
    auto udp = listenUDP(config.port, config.address,
        UDPListenOptions.reuseAddress | UDPListenOptions.reusePort);
    scope (exit) udp.close();
    // Otherwise `recv` allocates 65k per call (!!!)
    ubyte[2048] buffer;
    // `recv` will store the peer address here so we can respond
    NetworkAddress peer;
    scope ppeer = &peer;
    while (true)
    {
        try
        {
            auto pack = udp.recv(buffer, ppeer);
            auto query = deserializeFull!Message(pack);
            registry.answerQuestions(
                query, peer.toAddressString,
                (in Message msg) @safe => udp.send(msg.serializeFull(), ppeer));

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
        {
            stderr.writeln("Couldn't start the UDP listener for the registry: ", exc.msg);
            if (config.port == 53)
                stderr.writeln("On most system, port 53 is also used by a local resolver. " ~
                    "Use the node's public IP explicitly to avoid binding to the loopback interface");
            else if (config.port <= 1024)
                stderr.writeln("The chosen port (", config.port, ") is priviledged. " ~
                               "Try using a port > 1024 or make sure the port isn't already used");
            else
                stderr.writeln("Hint: Port ", config.port, " might already be used");
        }
        catch (Exception exc2)
            printf("Couldn't print message following fatal error in DNS!\n");

        atomicStore(exitCode, 1);
        exitEventLoop();
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
    ubyte[4096] buffer;

    try
    {
        // RFC1035 - 4.2.2. TCP usage
        // The message is prefixed with a two byte length field which gives the
        // message length, excluding the two byte length field.
        // This length field allows the low-level processing to assemble
        // a complete message before beginning to parse it.
        conn.read(buffer[0 .. 2]);
        const ushort size = deserializeFull!ushort(
            buffer[0 .. 2], DeserializerOptions(DefaultMaxLength, CompactMode.No));
        ensure(size <= buffer.length, "Received a message of size {} (> {})",
               size, buffer.length);

        // Read everything directly since it's going to be faster
        // than performing context switches
        conn.read(buffer[0 .. size]);

        auto query = deserializeFull!Message(buffer[0 .. size]);
        registry.answerQuestions(
            query, conn.remoteAddress.toAddressString(),
            (in Message msg) @trusted
            {
                auto s_msg = msg.serializeFull(CompactMode.No);
                ushort length = cast(ushort) s_msg.length;
                auto s_length = length.serializeFull(CompactMode.No);
                conn.write(s_length ~ s_msg);
            },
            true);
    }
    catch (Exception exc)
    {
        stderr.writeln("Exception happened while handling TCP request: ", exc);
    }
}

/*******************************************************************************

    Correctly forward an error message to the caller without allocating

    The default error handling code in Vibe.d will allocate an associative
    array, and uses `Exception.msg` instead of `Exception.message()`,
    leading to our clients receiving an unhelpful "An Exception was thrown".

    Params:
      req = The request that triggered this error
      res = The response to write
      info = Information about the error

    See_Also:
      https://github.com/vibe-d/vibe.d/blob/fb8b246623/web/vibe/web/rest.d#L1474-L1512

*******************************************************************************/

private void restErrorHandler (
    HTTPServerRequest req, HTTPServerResponse res, RestErrorInformation info)
    @trusted
{
    // We don't use any info from the caller
    cast(void) req;

    static struct ErrorInfo
    {
        /// The error message itself
        const(char)[] statusMessage;
        debug
        {
            /// The stack trace
            const(char)[] statusDebugMessage;
        }
    }

    // If we are using a reusable exception, then we might need to save the
    // error message in a buffer to avoid it being rewritten during a context
    // switch to another fiber.
    // `agora.common.Ensure : FormattedException` uses a 2kb buffer but we
    // limit ourselves to much less in order to not consume half a page for this
    char[512] buffer;
    scope const msg = info.exception.message();
    scope slice = buffer[0 .. msg.length > $ ? $ : msg.length];
    slice[] = msg[];

    // Send the full stack trace in debug mode (allocates quite a bit)
    // We also always assume user error instead of internal server error
    debug res.writeJsonBody(ErrorInfo(slice, info.exception.toString()), HTTPStatus.badRequest);
    else  res.writeJsonBody(ErrorInfo(slice), HTTPStatus.badRequest);
}
