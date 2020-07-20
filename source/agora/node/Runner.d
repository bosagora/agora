/*******************************************************************************

    Contains a function which instantiates either a FullNode or a Validator.

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.Runner;

import agora.api.FullNode;
import agora.api.Validator;
import agora.common.Config;
import agora.node.FullNode;
import agora.node.Validator;
import agora.utils.Log;

import vibe.http.server;
import vibe.http.router;
import vibe.web.rest;

import std.file;

mixin AddLogger!();

/*******************************************************************************

    Boots up a FullNode or Validator that listens for network requests and
    blockchain data.

    This is called from the main or CLI.
    The initialization process of the node is then completed.

    Params:
      config = A parsed and validated config file

*******************************************************************************/

public FullNode runNode (Config config)
{
    Log.root.level(config.logging.level, true);
    log.trace("Config is: {}", config);

    auto settings = new HTTPServerSettings(config.node.address);
    settings.port = config.node.port;
    auto router = new URLRouter();

    mkdirRecurse(config.node.data_dir);

    FullNode node;
    if (config.node.is_validator)
    {
        log.trace("Started Validator...");
        auto inst = new Validator(config);
        router.registerRestInterface!(agora.api.Validator.API)(inst);
        node = inst;
    }
    else
    {
        log.trace("Started FullNode...");
        node = new FullNode(config);
        router.registerRestInterface!(agora.api.FullNode.API)(node);
    }

    node.start();  // asynchronous

    log.info("About to listen to HTTP: {}", settings.port);
    listenHTTP(settings, router);
    return node;
}
