/*******************************************************************************

    Contains code used to communicate with another remote node

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.NetworkClient;

import agora.api.Validator;
import agora.common.BanManager;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.common.crypto.Key;
import agora.common.Types;
import agora.common.Set;
import agora.common.Task;
import agora.consensus.data.Transaction;
import scpd.types.Stellar_SCP;

import agora.utils.Log;

import vibe.http.client;

import std.algorithm;
import std.array;
import std.format;
import std.random;

import core.time;

mixin AddLogger!();

/// Used for communicating with a remote node
class NetworkClient
{
    /// Whether to throw an exception when attemptRequest() fails
    protected enum Throw
    {
        ///
        No,

        ///
        Yes
    }

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
    protected API api;

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
            format("Request failure to %s after %s attempts", address,
                max_retries));
    }

    /***************************************************************************

        Returns:
            the node's public key.

        Throws:
            `Exception` if the request failed.

    ***************************************************************************/

    public PublicKey getPublicKey ()
    {
        return this.attemptRequest!(API.getPublicKey, Throw.Yes)(this.api);
    }

    /***************************************************************************

        Register the node's address to listen for gossiping messages.

        This method is to call the API endpoint, or 'register_listener` which
        is not declared as one of the `FullNode` API in `FullNode.d` because
        we must use the `HTTPServerRequest` object to retrieve the address of
        a client. The `register_address` REST path is registered in the `runNode`
        function of `Runner.d`.

        Throws:
            `Exception` if the request failed.

    ***************************************************************************/

    public void registerListener ()
    {
        foreach (idx; 0 .. this.max_retries)
        {
            try
            {
                int statusCode;
                requestHTTP(format("%s/register_listener", this.address),
                    (scope req) {
                        req.method = HTTPMethod.POST;
                    },
                    (scope res) {
                        statusCode = res.statusCode;
                        if (res.statusCode != 200)
                            log.info("Response of {}/register_listener : {}",
                                this.address, res);

                    }
                );
                if (statusCode == 200)
                    return;
           }
           catch (Exception ex)
           {
               log.format(LogLevel.Trace, "Request '{}' to {} failed: {}",
                   "registerListener", this.address, ex.message);
               if (idx + 1 < this.max_retries) // wait after each failure except last
                   this.taskman.wait(this.retry_delay);
           }
       }
    }

    /***************************************************************************

        Get the network info of the node, stored in the
        `node_info` parameter if the request succeeded.

        Returns:
            `NodeInfo` if successful

        Throws:
            `Exception` if the request failed.

    ***************************************************************************/

    public NodeInfo getNodeInfo ()
    {
        return this.attemptRequest!(API.getNodeInfo, Throw.Yes)(this.api);
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
        import agora.common.Hash;
        const tx_hash = tx.hashFull();

        this.taskman.runTask(
        {
            // if the node already has this tx, don't send it
            if (this.attemptRequest!(API.hasTransactionHash, Throw.Yes,
                LogLevel.Trace)(this.api, tx_hash))
                return;

            this.attemptRequest!(API.putTransaction, Throw.No)(this.api, tx);
        });
    }


    /***************************************************************************

        Sends an SCP envelope to another node.

        Params:
            envelope = the envelope to send

    ***************************************************************************/

    public void sendEnvelope (SCPEnvelope envelope) nothrow
    {
        try
        {
            this.taskman.runTask(
            {
                this.attemptRequest!(API.receiveEnvelope, Throw.No)(this.api,
                    envelope);
            });
        }
        catch (Exception ex)
        {
            assert(0, "attemptRequest should have caught it");
        }
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
        return this.attemptRequest!(API.getBlockHeight, Throw.Yes)(this.api);
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

    public const(Block)[] getBlocksFrom (ulong block_height, uint max_blocks)
    {
        return this.attemptRequest!(API.getBlocksFrom, Throw.Yes)(this.api,
            block_height, max_blocks);
    }

    /***************************************************************************

        Send a enrollment request asynchronously to the node.
        Any errors are reported to the debugging log.

        The request is retried up to 'this.max_retries',
        any failures are logged and ignored.

        Params:
            enroll = the enrollment data to send

    ***************************************************************************/

    public void sendEnrollment (Enrollment enroll) @trusted
    {
        this.taskman.runTask(
        {
            this.attemptRequest!(API.enrollValidator, Throw.No)(this.api,
                enroll);
        });
    }

    /***************************************************************************

        Send a preimage asynchronously to the node.
        Any errors are reported to the debugging log.

        The request is retried up to 'this.max_retries',
        any failures are logged and ignored.

        Params:
            preimage = the pre-image information to send

    ***************************************************************************/

    public void sendPreimage (PreImageInfo preimage) @trusted
    {
        this.taskman.runTask(
        {
            this.attemptRequest!(API.receivePreimage, Throw.No)(this.api,
                preimage);
        });
    }

    /***************************************************************************

        Attempt a request up to 'this.max_retries' attempts, and make the task
        wait this.retry_delay between each attempt.

        If all requests fail and 'ex' is not null, throw the exception.

        Params:
            endpoint = the API endpoint (e.g. `API.putTransaction`)
            DT = whether to throw an exception if the request failed after
                 all attempted retries
            log_level = the logging level to use for logging failed requests
            API = deduced
            Args = deduced
            api = the interface to communicate with a node
            args = the arguments to the API endpoint

        Returns:
            the return value of of the API call, which may be void

    ***************************************************************************/

    protected auto attemptRequest (alias endpoint, Throw DT,
        LogLevel log_level = LogLevel.Trace, API, Args...)
        (API api, auto ref Args args, string file = __FILE__, uint line = __LINE__)
    {
        import std.traits;
        enum name = __traits(identifier, endpoint);
        alias T = ReturnType!(__traits(getMember, api, name));

        foreach (idx; 0 .. this.max_retries)
        {
            try
            {
                return __traits(getMember, api, name)(args);
            }
            catch (Exception ex)
            {
                import vibe.http.common : HTTPStatusException;
                if (auto http = cast(HTTPStatusException)ex)
                    throw http;  // e.g. getPublicKey() might not be implemented

                try
                {
                    log.format(log_level, "Request '{}' to {} failed: {}",
                        name, this.address, ex.message);
                }
                catch (Exception ex)
                {
                    // nothing we can do
                }

                if (idx + 1 < this.max_retries) // wait after each failure except last
                    this.taskman.wait(this.retry_delay);
            }
        }

        // request considered failed after max retries reached
        this.banman.onFailedRequest(this.address);

        static if (DT == Throw.Yes)
        {
            this.exception.file = file;
            this.exception.line = line;
            throw this.exception;
        }
        else static if (!is(T == void))
            return T.init;
    }
}
