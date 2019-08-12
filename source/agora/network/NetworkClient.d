/*******************************************************************************

    Contains code used to communicate with another remote node

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.NetworkClient;

import agora.common.BanManager;
import agora.consensus.data.Block;
import agora.common.Config;
import agora.common.crypto.Key;
import agora.common.Data;
import agora.common.Set;
import agora.common.Task;
import agora.consensus.data.Transaction;
import agora.node.API;

import vibe.core.log;

import std.algorithm;
import std.array;
import std.format;
import std.random;

import core.time;

/// Used for communicating with a remote node
class NetworkClient
{
    /// Address of the node we're interacting with (for logging)
    public const Address address;

    /// Caller's retry delay
    /// TODO: This should be done at the client object level,
    /// so whatever implements `API` should be handling this
    private const Duration retry_delay;

    /// Max request retries before a request is considered failed
    private const size_t max_retries;

    /// Task manager
    private TaskManager taskman;

    /// Ban manager
    private BanManager banman;

    /// API client to the node
    private API api;

    /// The key of the node as retrieved by getPublicKey()
    public PublicKey key;

    /// Reusable exception
    private Exception exception;


    /***************************************************************************

        Constructor.

        Params:
            taskman = used for creating new tasks
            banman = ban manager
            address = used for logging and querying by external code
            api = the API to issue the requests with
            retry = the amout to wait between retrying failed requests
            max_retries = max number of times a failed request should be retried

    ***************************************************************************/

    public this (TaskManager taskman, BanManager banman, Address address,
        API api, Duration retry, size_t max_retries)
    {
        this.taskman = taskman;
        this.banman = banman;
        this.address = address;
        this.api = api;
        this.retry_delay = retry;
        this.max_retries = max_retries;
        this.exception = new Exception(
            format("Request failure after %s attempts", max_retries));
    }

    /***************************************************************************

        Handshake with the node.

        Currently only the node's public key is retrieved,
        later version checks should be added here.

        Note that it is currently blocking until handshake is considered complete.

        Throws:
            Exception if the handshake did not complete.

    ***************************************************************************/

    public void handshake ()
    {
        this.key = this.attemptRequest(this.api.getPublicKey(), this.exception);
    }

    /***************************************************************************

        Get the network info of the node, stored in the
        `net_info` parameter if the request succeeded.

        Params:
            net_info = will contain the network info if successful

        Returns:
            NetworkInfo if successful

        Throws:
            Exception if the request failed.

    ***************************************************************************/

    public NetworkInfo getNetworkInfo ()
    {
        return this.attemptRequest(this.api.getNetworkInfo(), this.exception);
    }

    /***************************************************************************

        Send a transaction asynchronously to the node.
        Any errors are reported to the debugging log.

        The request is retried up to 'this.max_retries',
        any failures are logged and ignored.

        Params:
            tx = the transaction to send

    ***************************************************************************/

    public void sendTransaction (Transaction tx) @trusted
    {
        this.taskman.runTask(
        {
            this.attemptRequest!(LogLevel.debug_)(this.api.putTransaction(tx),
                null);
        });
    }

    /***************************************************************************

        Returns:
            the height of the node's ledger,
            or ulong.max if the request failed

        Throws:
            Exception if the request failed.

    ***************************************************************************/

    public ulong getBlockHeight ()
    {
        return this.attemptRequest(this.api.getBlockHeight(), this.exception);
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

        Throws:
            Exception if the request failed.

    ***************************************************************************/

    public const(Block)[] getBlocksFrom (ulong block_height, size_t max_blocks)
    {
        return this.attemptRequest(
            this.api.getBlocksFrom(block_height, max_blocks), this.exception);
    }

    /***************************************************************************

        Attempt a request up to 'this.max_retries' attempts, and make the task
        wait this.retry_delay between each attempt.

        If all requests fail and 'ex' is not null, throw the exception.

        Params:
            log_level = the logging level to use for logging failed requests
            T = the type of delegate
            dg = the delegate to call
            ex = the exception to throw if all attempts fail (if not null)

        Returns:
            the return value of dg(), which may be void

    ***************************************************************************/

    private T attemptRequest (LogLevel log_level = LogLevel.error, T)(
        lazy T dg, Exception ex)
    {
        foreach (idx; 0 .. this.max_retries)
        {
            try
            {
                return dg();
            }
            catch (Exception ex)
            {
                log!log_level(ex.message);
                if (idx + 1 < this.max_retries) // wait after each failure except last
                    this.taskman.wait(this.retry_delay);
            }
        }

        // request considered failed after max retries reached
        this.banman.onFailedRequest(this.address);

        if (ex !is null)
            throw ex;

        // ex is null, failure is ignored
        static if (!is(T == void))
            return T.init;
    }
}
