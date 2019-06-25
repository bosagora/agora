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

import vibe.core.log;
import vibe.data.json;
import vibe.web.rest;


/*******************************************************************************

    Implementation of the Node API

    This class implement the business code of the node.
    Communication with the other nodes is handled by the `Network` class.

    Params:
      Network = Type of the class handling network communication
                `agora.node.Network.Network` or a derivative is expected.

*******************************************************************************/
public class Node (Network) : API
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
        this.network = new Network(config.node, config.network);
        this.exception = new RestException(
            400, Json("The query was incorrect"), string.init, int.init);
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
}
