/*******************************************************************************

    An RPC generator, similar to `vibe.web.rest`, but for efficient node-to-node
    communication.

    The aim of this module is to provide a low-overhead way to interface nodes.
    This module uses TCP for communication and binary data serialization.
    It should also be fairly simple to chain generator, e.g. writing a server
    that receives `vibe.web.rest` queries and forwards them is trivial.

    Copyright:
        Copyright (c) 2019-2021 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.RPC;

import agora.common.Ensure;
import agora.crypto.Hash;
import agora.utils.Log;
import agora.serialization.Serializer;

import ocean.text.convert.Formatter;

import vibe.core.net;
import vibe.core.connectionpool;

import std.traits;
import core.stdc.stdio;
import core.time;

mixin AddLogger!();

/// Ditto
public class RPCClient (API) : API
{
    /// Aggregate configuration options for `RPCClient`
    public struct Config
    {
        /***********************************************************************

            Host to connect to

            See_Also: https://tools.ietf.org/html/rfc3986#section-3.2.2

        ***********************************************************************/

        public string host;

        /***********************************************************************

            Port to connect to

            See_Also: https://tools.ietf.org/html/rfc3986#section-3.2.3

        ***********************************************************************/

        public ushort port;

        /***********************************************************************

            Maximum number of retries before throwing an `Exception`

            Whenever connecting or sending a request to a remote host,
            this class will perform `max_retries` attempt at the operation
            before throwing an `Exception`. Each attempt will have a delay
            in between, and their own timeout, depending on the operation.

        ***********************************************************************/

        public uint max_retries;

        /***********************************************************************

            Timeout for a connection attempt

            Whenever connecting to a remote host, this value defines how long
            we are willing to wait before marking the connection attempt as
            failed. Note that the total wait time also depends on `max_retries`
            and `retry_delay`.

        ***********************************************************************/

        public Duration connection_timeout;

        /***********************************************************************

            Timeout for a read operation

            Whenever reading from a remote host, this value defines how long
            we are willing to wait before marking the operation as failed.
            Note that the total wait time also depends on `max_retries` and
            `retry_delay`.

        ***********************************************************************/

        public Duration read_timeout;

        /***********************************************************************

            Timeout for a write operation

            Whenever sending data toa remote host, this value defines how long
            we are willing to wait before marking the operation as failed.
            Note that the total wait time also depends on `max_retries` and
            `retry_delay`.

        ***********************************************************************/

        public Duration write_timeout;

        /***********************************************************************

            Time to wait between two attempts at connecting / reading / writing

            Whenever an operation is marked as failed, this is the time to
            wait between each attempt.
            Note that a smarter client might want to set max_retries to 0,
            in which case this value has no effect, to implement smarter
            approaches to retry, e.g. exponential backoff.

        ***********************************************************************/

        public Duration retry_delay;

        ///
        public uint concurrency;
    }

    /// Config instance for this client
    private Config config;

    /// Pool of connections to the host
    private ConnectionPool!RPCConnection pool;

    /// Logger for this client
    private Logger log;

    /// Lookup table for hashes (they can't be computed at CT)
    private Hash[string] lookup;

    /***************************************************************************

        Initialize an instance of an `RPCClient`

        This does not actually perform any IO, except for looking up a `Logger`
        instance. Connection is done lazily (on method usage).

        The total amount of time this class can wait is:
        `(ctimeout + retry_delay) * max_retries`.

        Params:
          host = IP address / host name of the remote node
          port = Port of the remote node
          retry_delay = Time to wait between retries
          max_retries = Number of times communication should be tried before
                        an `Exception` will be thrown.
          ctimeout = Connection timeout
          rtimeout = Read timeout
          wtimeout = Write timeout

    ***************************************************************************/

    public this (string host, ushort port,
                 Duration retry_delay, uint max_retries,
                 Duration ctimeout, Duration rtimeout, Duration wtimeout,
                 uint concurrency)
        @trusted
    {
        const Config config = {
            host:               host,
            port:               port,

            retry_delay:        retry_delay,
            max_retries:        max_retries,

            connection_timeout: ctimeout,
            read_timeout:       rtimeout,
            write_timeout:      wtimeout,
            concurrency:        concurrency,
        };
        this(config);
    }

    /// Ditto
    public this (const Config config) @trusted
    {
        this.config = config;
        this.log = Log.lookup(
            format("{}.{}.{}", __MODULE__, this.config.host, this.config.port));
        this.pool = new ConnectionPool!RPCConnection({
            return new RPCConnection();
        });
        this.pool.maxConcurrency = this.config.concurrency;

        static foreach (member; __traits(allMembers, API))
            static foreach (ovrld; __traits(getOverloads, API, member))
                this.lookup[ovrld.mangleof] = hashFull(ovrld.mangleof);
    }

    /// Ensure that we are still connected, and implement retry logic
    private void ensureConnected (RPCConnection rpc_conn) @trusted
    {
        uint attempts;
        do
        {
            if (rpc_conn.conn.connected())
                return;

            // If it's not the first time we loop, sleep before retry
            if (attempts > 0)
            {
                import vibe.core.core : sleep;
                sleep(this.config.retry_delay);
            }

            try
            {
                rpc_conn.conn = connectTCP(
                    this.config.host, this.config.port,
                    null, 0, // Bind interface / port, unused
                    this.config.connection_timeout);
                rpc_conn.conn.keepAlive = true;
                rpc_conn.conn.readTimeout = this.config.read_timeout;
            }
            catch (Exception e) {}
            attempts++;

        } while (attempts < this.config.max_retries);

        ensure(rpc_conn.conn.connected(),
            format("Failed to connect to {}:{} after {} attempts ({}:{})",
                this.config.host, this.config.port, this.config.max_retries,
                this.config.connection_timeout, this.config.retry_delay));
    }

    private struct Pack (T...) { T args; }

    /// Implementation of the API's functions
    static foreach (member; __traits(allMembers, API))
        static foreach (ovrld; __traits(getOverloads, API, member))
        {
            mixin(q{
                override ReturnType!(ovrld) } ~ member ~ q{ (Parameters!ovrld params)
                {
                    this.log.trace("[CLIENT]: {}: {}", __PRETTY_FUNCTION__,
                                   Pack!(Parameters!ovrld)(params));
                    scope conn = this.pool.lockConnection();
                    this.ensureConnected(conn);
                    scope (failure) conn.close();

                    ubyte[512] tmp = void;
                    Hash method = this.lookup[ovrld.mangleof];
                    // Send the method type
                    conn.write(method[0 .. $]);
                    // List of parameters
                    foreach (ref p; params)
                        serializePart(p, (in ubyte[] v) => conn.write(v));
                    conn.flush();
                    static if (is(typeof(return) == void))
                    {
                        // Wait for the remote to write back the same method type
                        conn.read(method[0 .. $]);
                        this.log.trace("[CLIENT] Returning from {} : {}",
                                       __PRETTY_FUNCTION__, method);
                    }
                    else
                    {
                        scope DeserializeDg dg = (size_t size)
                            {
                                ensure(size < tmp.length, "Out of bound read");
                                conn.read(tmp[0 .. size]);
                                return tmp[0 .. size];
                            };
                        version (all)
                        {
                            auto retval = deserializeFull!(typeof(return))(dg);
                            this.log.trace("[CLIENT] {}: Returning {}", __PRETTY_FUNCTION__, retval);
                            return retval;
                        }
                        else
                            return deserializeFull!(typeof(return))(dg);
                    }
                }
            });
        }
}

///
private class RPCConnection
{
    ///
    private TCPConnection conn;

    ///
    alias conn this;
}

/*******************************************************************************

    Entry point for the server-side functionality of this module

    This function register an implementation (`impl`) to listen to an RPC port
    and will deserialize its parameters and call it when a new request is
    received. It is the RPC equivalent of `registerRestInterface`.

    Params:
      API = The type of API that will handle the call
      impl = The object that will handle the call
      address = The address to bind to (netmask, e.g. `0.0.0.0` for all)
      port = The port to bind to

*******************************************************************************/

public TCPListener listenRPC (API) (API impl, string address, ushort port,
    Duration timeout)
{
    auto callback = (TCPConnection stream) @safe nothrow {
        try stream.readTimeout = timeout;
        catch (Exception e) assert(0);
        // Try to reuse the connection, if no requests arrive within a certain
        // period then handleThrow() will throw and handle() will return false
        while (handle(impl, stream, timeout)) {}
    };
    return listenTCP(port, callback, address);
}

/*******************************************************************************

    Top-level function for handling incoming (server) requests

    This is called by `listenTCP` whenever new data on the `stream` is received.
    It simply wraps `handleThrow` as the callback needs to be `@safe nothrow`.

    Params:
      API = The type of API that will handle the call
      api = The object that will handle the call
      stream = The TCP stream to read data from

*******************************************************************************/

private bool handle (API) (API api, ref TCPConnection stream, Duration timeout) @trusted nothrow
{
    try
        handleThrow(api, stream, timeout);
    catch (Exception ex)
    {
        try log.trace("Exception caught in handle: {}", ex);
        // This should never happen, but if it does, at least let the user know
        catch (Exception e)
        {
            printf("[%s:%d] Error while logging an error: %.*s\n",
                   __FILE__.ptr, __LINE__, cast(int) ex.msg.length, ex.msg.ptr);
        }
        return false;
    }
    return true;
}

/*******************************************************************************

    Handle incoming (server) requests

    This function will read from `stream`, find which function of `api` to call,
    deserialize the parameters accordingly, then call `api`.
    If anything goes wrong (deserialization failed, wrong method, etc...),
    a trace message will be logged and `api` won't be called.

    Params:
      API = The type of API that will handle the call
      api = The object that will handle the call
      stream = The TCP stream to read data from

*******************************************************************************/

private void handleThrow (API) (scope API api, ref TCPConnection stream, Duration timeout)
    @trusted
{
    static string[Hash] lookup;
    if (lookup.length == 0)
    {
        static foreach (member; __traits(allMembers, API))
            static foreach (ovrld; __traits(getOverloads, API, member))
                lookup[hashFull(ovrld.mangleof)] = ovrld.mangleof;
    }

    // use the existing readTimeout in leastSize()
    // if this is a new connection, handle() will have set it to the configuration value
    // if it is a reused connection it will be set to the keep alive period.
    log.trace("[{}] Handling a new request: {}", stream.peerAddress, stream.leastSize());
    // after the initial data arrives, reduce the timeout to the configured amount
    stream.readTimeout = timeout;
    // We will reuse this connection, keep the connection alive for 10 minutes after handling a request
    scope (exit) stream.readTimeout = 10.minutes;
    Hash methodbin;
    stream.read(methodbin[]);
    const method = methodbin in lookup;
    if (method is null)
    {
        log.trace("[{}] Calling out of range method: {}",
                  stream.peerAddress, methodbin);
        return;
    }

    ubyte[1024] buffer = void;
    scope DeserializeDg reader = (size_t size) @safe
    {
        ensure(size < buffer.length, "Out of bound read");
        scope (failure) assert(0);
        stream.read(buffer[0 .. size]);
        return buffer[0 .. size];
    };

    // Helper template for staticMap
    Target convert (Target) ()
    {
        return deserializeFull!Target(reader);
    }

    switch (*method)
    {
    static foreach (member; __traits(allMembers, API))
        static foreach (ovrld; __traits(getOverloads, API, member))
        {
        case ovrld.mangleof:
            enum CallMixin = "api." ~ member ~ "(staticMap!(convert, Parameters!ovrld));";

            log.trace("[SERVER] {} requested {}({})",
                      stream.peerAddress, member, (Parameters!ovrld).stringof);

            // Call functions + return
            static if (is(ReturnType!ovrld == void))
            {
                mixin(CallMixin);
                log.trace("[SERVER] Goodbye {}", methodbin);
                stream.write(methodbin[]);
            }
            else
            {
                mixin("auto foo = ", CallMixin);
                log.trace("[SERVER] Returning {}", foo);
                serializePart(foo, (in ubyte[] v) { stream.write(v); });
                log.trace("[SERVER] Done writing...");
            }
            return;
        }
    default:
        assert(0);
    }
}
