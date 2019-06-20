/*******************************************************************************

    Implementation of the Node's API.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.Node;

import agora.common.API;
import agora.common.Config;
import agora.common.crypto.Key;
import agora.common.Data;
import agora.node.Network;


import vibe.d;

/// Ditto
public class Node : API
{
@trusted:

    /// Config instance
    private const Config config;

    /// Network of connected nodes
    private Network network;

    /// Reusable exception object
    private RestException exception;


    /// Ctor
    public this (const Config config)
    {
        this.config = config;
        enforce(this.config.network.length > 0, "No network option found");
        this.network = new Network(config);
        this.exception = new RestException(
            400, Json("The query was incorrect"), string.init, int.init);

        setLogLevel(config.logging.log_level);
        logTrace("Config is: %s", config);

        auto router = new URLRouter();
        router.registerRestInterface(this);

        // initial task
        runTask( { this.start(); });

        auto settings = new HTTPServerSettings(config.node.address);
        settings.port = config.node.port;

        logInfo("About to listen to HTTP: %s", settings.port);
        listenHTTP(settings, router);
    }

    /// The first task method, loading from disk, node discovery, etc
    public void start ()
    {
        logInfo("Doing network discovery..");
        this.network.discover();
    }

    /// GET /public_key
    public override PublicKey getPublicKey ()
    {
        return this.config.node.key_pair.address;
    }

    /// GET: /network_info
    public override NetworkInfo getNetworkInfo ()
    {
        return this.network.getNetworkInfo();
    }

    /// GET: /public_config
    public override PublicConfig getPublicConfig()
    {
        PublicConfig config =
        {
            is_validator : this.config.node.is_validator
        };

        return config;
    }

    /// PUT: /message
    public void setMessage(Hash hash)
    {
        // message process
    } 
}
