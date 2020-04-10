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
import agora.utils.Log;

import ocean.util.log.Logger;

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
      Node = Type of node to spawn (`FullNode` or `Validator`)
      config = A parsed and validated config file

*******************************************************************************/

public Node runNode (Node) (Config config)
{
    Log.root.level(config.logging.log_level, true);
    log.trace("Config is: {}", config);

    auto settings = new HTTPServerSettings(config.node.address);
    settings.port = config.node.port;
    auto router = new URLRouter();

    mkdirRecurse(config.node.data_dir);

    auto node = new Node(config);

    // note: check most specialized interface first, otherwise
    // a Validator : FullNode will be true and a FullNode will be instantiated.
    static if (is(Node : agora.api.Validator.API))
    {
        assert(config.node.is_validator);
        log.trace("Started Validator...");
        router.registerRestInterface!(agora.api.Validator.API)(node);
    }
    else static if (is(Node : agora.api.FullNode.API))
    {
        assert(!config.node.is_validator);
        log.trace("Started FullNode...");
        router.registerRestInterface!(agora.api.FullNode.API)(node);
    }
    else static assert(0);

    node.start();  // asynchronous

    log.info("About to listen to HTTP: {}", settings.port);
    listenHTTP(settings, router);
    return node;
}
