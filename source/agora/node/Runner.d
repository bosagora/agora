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
import agora.common.Config;
import agora.common.Task : Periodic;
import agora.flash.API;
import agora.node.admin.AdminInterface;
import agora.node.FlashFullNode;
import agora.node.FlashValidator;
import agora.node.FullNode;
import agora.node.Validator;
import agora.utils.Log;

import ocean.util.log.ILogger;

import vibe.core.core;
import vibe.http.server;
import vibe.http.router;
import vibe.web.rest;

import std.file;
import std.format;
import std.typecons : Tuple, tuple;

import core.time;

///
public alias Listeners = Tuple!(
    FullNode, "node",
    AdminInterface, "admin",
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
    setVibeLogLevel(config.logging.level);
    Log.root.level(config.logging.level, true);
    auto log = Logger(__MODULE__);
    log.trace("Config is: {}", config);

    auto settings = new HTTPServerSettings(config.node.address);
    settings.port = config.node.port;
    auto router = new URLRouter();

    mkdirRecurse(config.node.data_dir);

    Listeners result;
    if (config.flash.enabled && config.validator.enabled)
    {
        log.trace("Started FlashValidator...");
        auto inst = new FlashValidator(config);
        router.registerRestInterface!(FlashValidatorAPI)(inst);
        if (config.admin.enabled)
            result.admin = inst.makeAdminInterface();
        result.node = inst;
    }
    else if (config.validator.enabled)
    {
        log.trace("Started Validator...");
        auto inst = new Validator(config);
        router.registerRestInterface!(agora.api.Validator.API)(inst);
        if (config.admin.enabled)
            result.admin = inst.makeAdminInterface();
        result.node = inst;
    }
    else if (config.flash.enabled)
    {
        log.trace("Started FlashFullNode...");
        auto inst = new FlashFullNode(config);
        router.registerRestInterface!(FlashFullNodeAPI)(inst);
        result.node = inst;
    }
    else
    {
        log.trace("Started FullNode...");
        result.node = new FullNode(config);
        router.registerRestInterface!(agora.api.FullNode.API)(result.node);
    }
    settings.rejectConnectionPredicate =
        (in address) nothrow @safe
        {
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

    scope (exit)
    {
        log.info("Listening for blockchain data on {}:{}", config.node.address, settings.port);
        if (result.admin !is null)
            log.info("Admin interface listening on {}:{}", config.admin.address, settings.port);
    }

    result.http ~= listenHTTP(settings, router);
    if (result.admin !is null)
        result.http ~= result.admin.start();

    return result;
}

/*******************************************************************************

    Set Vibe.d log level according to the configuration's log level

    This is used to ensure we get the right amount of information from Vibe.d
    Since a log level is the "minimum accepted" level, some level values might
    not match. For example, if we want Vibe.d's "diagnostic" to be part of
    the output when we set the loglevel to info, then that's what we must pass
    to Vibe's `setLogLevel` (and since diagnostic < info, it will include the
    latter too).

    Params:
        level = The level at which we want to set the logger

*******************************************************************************/

private void setVibeLogLevel (ILogger.Level level) @safe
{
    import vibe.core.log;

    final switch (level)
    {
    case ILogger.Level.Trace:
        setLogLevel(LogLevel.trace);
        break;
    case ILogger.Level.Info:
        setLogLevel(LogLevel.diagnostic);
        break;
    case ILogger.Level.Warn:
        setLogLevel(LogLevel.warn);
        break;
    case ILogger.Level.Error:
        setLogLevel(LogLevel.error);
        break;
    case ILogger.Level.Fatal:
        setLogLevel(LogLevel.critical);
        break;
    case ILogger.Level.None:
        setLogLevel(LogLevel.none);
        break;
    }
}
