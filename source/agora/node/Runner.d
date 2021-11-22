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
            config.node.data_dir, params.Genesis.hashFull(),
            result.node.getEngine(),
            result.node.getTaskManager(), &result.node.postTransaction,
            &result.node.getBlock, &result.node.getNetworkManager().getNameRegistryClient);
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

    void startNode ()
    {
        result.node.start();

        if (config.registry.enabled)
        {
            auto reg = result.node.getRegistry();
            assert(reg !is null);
            if (hasHTTPInterface)
                router.registerRestInterface(reg, settings);
        }
    }

    setTimer(0.seconds, &startNode, Periodic.No);  // asynchronous

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
            result.tcp ~= listenRPC!(agora.api.Validator.API)(fl, interface_.address, interface_.port, config.node.timeout,
                &result.node.getNetworkManager().discoverFromClient);
        else
            result.tcp ~= listenRPC!(agora.api.FullNode.API)(result.node, interface_.address, interface_.port, config.node.timeout,
                &result.node.getNetworkManager().discoverFromClient);
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
