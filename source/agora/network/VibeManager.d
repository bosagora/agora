/*******************************************************************************

    A `NetworkManager` implementation based on Vibe.d

    See `agora.network.Manager` for a complete description of the
    `NetworkManager` role and responsibilities.

    Copyright:
        Copyright (c) 2019-2022 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.VibeManager;

static import agora.api.FullNode;
import agora.api.Handlers;
import agora.api.Registry;
static import agora.api.Validator;
import agora.common.Task;
import agora.common.Types;
import agora.common.ManagedDatabase;
import agora.network.Clock;
import agora.network.DNSResolver;
public import agora.network.Manager;
import agora.network.RPC;
import agora.node.Config;

import vibe.http.client;
import vibe.web.rest;

import core.time;

/// And implementation of `agora.network.Manager : NetworkManager` using Vibe.d
public final class VibeNetworkManager : NetworkManager
{
    /// Construct an instance of this object
    public this (in Config config, ManagedDatabase cache, ITaskManager taskman,
                 Clock clock, agora.api.FullNode.API owner_node)
    {
        super(config, cache, taskman, clock, owner_node);
    }

    /// See `NetworkManager.makeDNSResolver`
    public override DNSResolver makeDNSResolver (Address[] peers = null)
    {
        if (peers.length == 0)
            peers = [ Address(this.config.node.registry_address) ];
        return new VibeDNSResolver(peers);
    }

    /// See `NetworkManager.getClient`
    protected override agora.api.Validator.API getClient (Address url)
    {
        import std.algorithm.searching;

        const timeout = this.config.node.timeout;
        if (url.schema == "agora")
        {
            auto owner_validator = cast (agora.api.Validator.API) this.owner_node;

            return owner_validator ?
                new RPCClient!(agora.api.Validator.API)(
                url.host, url.port,
                /* Disabled, we have our own method: */ 0.seconds, 1,
                timeout, timeout, timeout, 3 /* Hard coded max tcp connections*/,
                owner_validator)
                :
                new RPCClient!(agora.api.Validator.API)(
                url.host, url.port,
                /* Disabled, we have our own method: */ 0.seconds, 1,
                timeout, timeout, timeout, 3 /* Hard coded max tcp connections*/,
                this.owner_node);
        }

        if (url.schema.startsWith("http"))
        {
            auto settings = new RestInterfaceSettings;
            settings.baseURL = url;
            settings.httpClientSettings = new HTTPClientSettings;
            settings.httpClientSettings.connectTimeout = timeout;
            settings.httpClientSettings.readTimeout = timeout;
            settings.httpClientSettings.proxyURL = this.config.proxy.url;
            return new RestInterfaceClient!(agora.api.Validator.API)(settings);
        }
        assert(0, "Unknown agora schema");
    }

    /// See `NetworkManager.getRegistryClient`
    public override NameRegistryAPI getRegistryClient (string address)
    {
        auto settings = new RestInterfaceSettings();
        settings.baseURL = Address(address);
        settings.httpClientSettings = new HTTPClientSettings();
        settings.httpClientSettings.connectTimeout = this.config.node.timeout;
        settings.httpClientSettings.readTimeout = this.config.node.timeout;
        settings.httpClientSettings.proxyURL = this.config.proxy.url;

        return new RestInterfaceClient!NameRegistryAPI(settings);
    }

    /// See `NetworkManager.getBlockExternalizedHandler`
    public override BlockExternalizedHandler getBlockExternalizedHandler (Address address)
    {
        return new RestInterfaceClient!BlockExternalizedHandler(
            this.getRestInterfaceSettings(address));
    }

    /// See `NetworkManager.getBlockHeaderUpdatedHandler`
    public override BlockHeaderUpdatedHandler getBlockHeaderUpdatedHandler (Address address)
    {
        return new RestInterfaceClient!BlockHeaderUpdatedHandler(
            this.getRestInterfaceSettings(address));
    }

    /// See `NetworkManager.getPreImageReceivedHandler`
    public override PreImageReceivedHandler getPreImageReceivedHandler(Address address)
    {
        return new RestInterfaceClient!PreImageReceivedHandler(
            this.getRestInterfaceSettings(address));
    }

    /// See `NetworkManager.getTransactionReceivedHandler`
    public override TransactionReceivedHandler getTransactionReceivedHandler (Address address)
    {
        return new RestInterfaceClient!TransactionReceivedHandler(
            this.getRestInterfaceSettings(address));
    }

    /// Returns: A `RestInterfaceSettings` with the content of the `config`
    ///          pointing to `address`
    private RestInterfaceSettings getRestInterfaceSettings (Address address)
    {
        auto settings = new RestInterfaceSettings;
        settings.baseURL = address;
        settings.httpClientSettings = new HTTPClientSettings;
        settings.httpClientSettings.connectTimeout = this.config.node.timeout;
        settings.httpClientSettings.readTimeout = this.config.node.timeout;
        settings.httpClientSettings.proxyURL = this.config.proxy.url;
        return settings;
    }
}
