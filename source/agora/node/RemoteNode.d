/*******************************************************************************

    Contains code used to communicate with another remote node

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.RemoteNode;

import agora.common.API;
import agora.common.Config;
import agora.common.crypto.Key;
import agora.common.Data;
import agora.common.Set;

import vibe.core.core;
import vibe.core.log;
import vibe.web.rest;

import core.time;

import std.algorithm;
import std.array;
import std.format;
import std.random;

/// Used for communicating with a remote node
class RemoteNode
{
    /// Address of the node we're interacting with (for logging)
    private const Address address;

    /// Config instance
    private const Config config;

    /// API client to the node
    private RestInterfaceClient!API api;

    /// The public configuration as retrieved by getPublicConfig()
    public PublicConfig pub_conf;

    /// The key of the node as retrieved by getPublicKey()
    public PublicKey key;

    /// Current network info state as retrieved by getNetworkInfo()
    public NetworkInfo net_info;


    /// Constructor
    public this ( Address address, RestInterfaceClient!API api,
        const Config config )
    {
        this.address = address;
        this.api = api;
        this.config = config;
    }

    /// Try connecting to the node, call onReceivedNetworkInfoDg() whenever
    /// new network information is received, and call onClientConnectedDg()
    /// when we're ready to gossip / interact with the node.
    public void getReady ( void delegate(NetworkInfo) onReceivedNetworkInfoDg,
        void delegate(RemoteNode) onClientConnectedDg )
    {
        while (!this.getPublicKey())
        {
            logInfo("IP %s: Couldn't retrieve public key. Will retry in %s..",
                this.address,
                this.config.node.retry_delay.msecs);
            sleep(this.config.node.retry_delay.msecs);
        }

        while (!this.getPublicConfig())
        {
            logInfo("IP %s (Key: %s): Couldn't retrieve configuration. " ~
                "Will retry in %s..",
                this.address,
                this.key,
                this.config.node.retry_delay.msecs);
            sleep(this.config.node.retry_delay.msecs);
        }

        onClientConnectedDg(this);

        // keep asynchronously polling for complete network info.
        // net info is complete when the client established
        // a connection with all the nodes in its quorum set
        while (1)
        {
            // received some network info (may still be incomplete)
            if (this.getNetworkInfo())
                onReceivedNetworkInfoDg(this.net_info);

            if (this.net_info.state == NetworkState.Complete)
                break;

            logInfo("IP %s (Key: %s): Peer info is incomplete. Retrying in %s..",
                this.address,
                this.key,
                this.config.node.retry_delay.msecs);
            sleep(this.config.node.retry_delay.msecs);
        }
    }

    /// Get the publicly exposed config of this node
    private bool getPublicConfig ()
    {
        try
        {
            this.pub_conf = this.api.getPublicConfig();
            return true;
        }
        catch (Exception ex)
        {
            logError(ex.msg);
            return false;
        }
    }

    /// Get the public key of this node
    private bool getPublicKey ( )
    {
        try
        {
            this.key = this.api.getPublicKey();
            return true;
        }
        catch (Exception ex)
        {
            logError(ex.msg);
            return false;
        }
    }

    /// Returns: true if the getNetworkInfo call succeeded,
    /// however the net info may still be incomplete!
    private bool getNetworkInfo ()
    {
        try
        {
            logInfo("IP %s: Received network info %s", this.address,
                net_info);
            this.net_info = this.api.getNetworkInfo();
            return true;
        }
        catch (Exception ex)
        {
            logError(ex.msg);
            return false;
        }
    }
}
