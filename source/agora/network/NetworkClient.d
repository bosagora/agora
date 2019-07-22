/*******************************************************************************

    Contains code used to communicate with another remote node

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.NetworkClient;

import agora.common.API;
import agora.common.Block;
import agora.common.Config;
import agora.common.crypto.Key;
import agora.common.Data;
import agora.common.Set;
import agora.common.Task;
import agora.common.Transaction;

import vibe.core.log;

import core.time;

import std.algorithm;
import std.array;
import std.format;
import std.random;

/// Used for communicating with a remote node
class NetworkClient
{
    /// Address of the node we're interacting with (for logging)
    public const Address address;

    /// Caller's retry delay
    /// TODO: This should be done at the client object level,
    /// so whatever implements `API` should be handling this
    private const Duration retry_delay;

    /// Task manager
    private TaskManager taskman;

    /// API client to the node
    private API api;

    /// The public configuration as retrieved by getPublicConfig()
    public PublicConfig pub_conf;

    /// The key of the node as retrieved by getPublicKey()
    public PublicKey key;

    /// Current network info state as retrieved by getNetworkInfo()
    public NetworkInfo net_info;


    /***************************************************************************

        Constructor.

        Params:
            taskman = used for creating new tasks
            address = used for logging and querying by external code
            api = the API to issue the requests with
            retry_delay = the amout to wait between retrying failed requests

    ***************************************************************************/

    public this ( TaskManager taskman, Address address, API api,
        Duration retry_delay )
    {
        this.taskman = taskman;
        this.address = address;
        this.api = api;
        this.retry_delay = retry_delay;
    }

    /***************************************************************************

        Try connecting to the node, call receiveNetInfo() whenever
        new network information is received, and call onNodeConnected()
        when we're ready to gossip / interact with the node.
        minPeersConnected() is periodically called to determine if it's
        necessary to continuously query a node for more network info.

        Params:
            receiveNetInfo = delegate to call with any new network info
            onNodeConnected = delegate to call when the handshake is complete
            minPeersConnected = will be periodically called by this method to
                                determine if we should keep polling the node
                                for more network info (to connect to more nodes).

    ***************************************************************************/

    public void getReady ( void delegate(NetworkInfo) receiveNetInfo,
        void delegate(NetworkClient) onNodeConnected,
        bool delegate() minPeersConnected )
    {
        while (!this.getPublicKey())
        {
            logInfo("[%s] Couldn't retrieve public key. Will retry in %s..",
                this.address, this.retry_delay);
            this.taskman.wait(this.retry_delay);
        }

        while (!this.getPublicConfig())
        {
            logInfo("[%s] (%s): Couldn't retrieve configuration. " ~
                "Will retry in %s..",
                this.address, this.key, this.retry_delay);
            this.taskman.wait(this.retry_delay);
        }

        onNodeConnected(this);

        // keep asynchronously polling for complete network info,
        // until complete peer info is returned or the parent
        // node has established all necessary connections
        while (!minPeersConnected())
        {
            // received some network info (may still be incomplete)
            if (this.getNetworkInfo())
                receiveNetInfo(this.net_info);

            if (this.net_info.state == NetworkState.Complete)
                break;

            logInfo("[%s] (%s): Peer info is incomplete. Retrying in %s..",
                this.address, this.key, this.retry_delay);
            this.taskman.wait(this.retry_delay);
        }
    }

    /***************************************************************************

        Get the public config of this node, stored in the
        `pub_conf` field if the request succeeded.

        Returns:
            true if the request succeeded

    ***************************************************************************/

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

    /***************************************************************************

        Get the public key of this node, stored in the
        `key` field if the request succeeded.

        Returns:
            true if the request succeeded

    ***************************************************************************/

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

    /***************************************************************************

        Get the network info of the node, stored in the
        `net_info` field if the request succeeded.

        Returns:
            true if the request succeeded

    ***************************************************************************/

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

        Send a transaction asynchronously to the node.
        Any errors are reported to the debugging log.
        Note that failed requests will not be automatically retried.

        Params:
            tx = the transaction to send

    ***************************************************************************/

    public void sendTransaction (Transaction tx) @trusted
    {
        this.taskman.runTask(()
        {
            try
            {
                this.api.putTransaction(tx);
            }
            catch (Exception ex)
            {
                logDebug(ex.message);
            }
        });
    }

    /***************************************************************************

        Returns:
            the height of the node's ledger,
            or ulong.max if the request failed

    ***************************************************************************/

    public ulong getBlockHeight ()
    {
        try
        {
            return this.api.getBlockHeight();
        }
        catch (Exception ex)
        {
            logError(ex.message);
            return ulong.max;
        }
    }

    /***************************************************************************

        Get the array of blocks starting from the provided block height.
        The block at block_height is included in the array.

        Params:
            block_height = the starting block height to begin retrieval from
            max_blocks   = the maximum blocks to return at once

        Returns:
            the array of blocks starting from block_height,
            up to `max_blocks`.

            If the request failed, returns an empty array

    ***************************************************************************/

    public Block[] getBlocksFrom (ulong block_height, size_t max_blocks)
    {
        try
        {
            return this.api.getBlocksFrom(block_height, max_blocks);
        }
        catch (Exception ex)
        {
            logError(ex.message);
            return null;
        }
    }
}
