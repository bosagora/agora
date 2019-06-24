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

    /// Caller's retry delay
    /// TODO: This should be done at the client object level,
    /// so whatever implements `API` should be handling this
    private const Duration retry_delay;

    /// API client to the node
    private API api;

    /// The public configuration as retrieved by getPublicConfig()
    public PublicConfig pub_conf;

    /// The key of the node as retrieved by getPublicKey()
    public PublicKey key;

    /// Current network info state as retrieved by getNetworkInfo()
    public NetworkInfo net_info;

    /// Constructor
    public this ( Address address, API api, Duration retry_delay )
    {
        this.address = address;
        this.api = api;
        this.retry_delay = retry_delay;
    }

    /// Try connecting to the node, call onReceivedNetworkInfoDg() whenever
    /// new network information is received, and call onClientConnectedDg()
    /// when we're ready to gossip / interact with the node.
    public void getReady ( void delegate(NetworkInfo) onReceivedNetworkInfoDg,
        void delegate(RemoteNode) onClientConnectedDg )
    {
        while (!this.getPublicKey())
        {
            logInfo("[%s] Couldn't retrieve public key. Will retry in %s..",
                this.address, this.retry_delay);
            sleep(this.retry_delay);
        }

        while (!this.getPublicConfig())
        {
            logInfo("[%s] (%s): Couldn't retrieve configuration. " ~
                "Will retry in %s..",
                this.address, this.key, this.retry_delay);
            sleep(this.retry_delay);
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

            logInfo("[%s] (%s): Peer info is incomplete. Retrying in %s..",
                this.address, this.key, this.retry_delay);
            sleep(this.retry_delay);
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
            logError(ex.message);
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
            logError(ex.message);
            return false;
        }
    }

    /// Returns: true if the getNetworkInfo call succeeded,
    /// however the net info may still be incomplete!
    private bool getNetworkInfo ()
    {
        try
        {
            this.net_info = this.api.getNetworkInfo();
            logInfo("[%s]: Received network info %s", this.address,
                net_info);
            return true;
        }
        catch (Exception ex)
        {
            logError(ex.message);
            return false;
        }
    }

    /***************************************************************************

        Send a message

        Params:
          msg = the message to send

    ***************************************************************************/

    public void sendMessage(Hash msg) @trusted
    {
        try
        {
            this.api.setMessage(msg);
        }
        catch (Exception ex)
        {
            logError(ex.message);
        }
    }
}
