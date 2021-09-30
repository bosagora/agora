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
import vibe.core.sync;

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

    public this (ThisEndAPI) (string host, ushort port,
                 Duration retry_delay, uint max_retries,
                 Duration ctimeout, Duration rtimeout, Duration wtimeout,
                 uint concurrency, ThisEndAPI impl)
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
        this(config, impl);
    }

    /// Ditto
    public this (ThisEndAPI) (const Config config, ThisEndAPI impl) @trusted
    {
        this.config = config;
        this.log = Log.lookup(
            format("{}.{}.{}", __MODULE__, this.config.host, this.config.port));
        this.pool = new ConnectionPool!RPCConnection(() @safe {
            uint attempts;
            do
            {
                // If it's not the first time we loop, sleep before retry
                if (attempts > 0)
                {
                    import vibe.core.core : sleep;
                    sleep(this.config.retry_delay);
                }

                try
                {
                    auto conn = connectTCP(
                        this.config.host, this.config.port,
                        null, 0, // Bind interface / port, unused
                        this.config.connection_timeout);
                    conn.keepAlive = true;
                    conn.readTimeout = this.config.read_timeout;

                    if (conn.connected())
                    {
                        static import vibe.core.core;
                        auto rpc_conn = new RPCConnection(conn);
                        vibe.core.core.runTask({
                            rpc_conn.startListening(impl);
                        });
                        return rpc_conn;
                    }
                }
                catch (Exception e) {}
                attempts++;

            } while (attempts < this.config.max_retries);

            ensure(false, "Failed to connect to host");
            assert(0);
        });
        this.pool.maxConcurrency = this.config.concurrency;

        static foreach (member; __traits(allMembers, API))
            static foreach (ovrld; __traits(getOverloads, API, member))
                this.lookup[ovrld.mangleof] = hashFull(ovrld.mangleof);
    }

    private struct Pack (T...) { T args; }

    /// Implementation of the API's functions
    static foreach (member; __traits(allMembers, API))
        static foreach (ovrld; __traits(getOverloads, API, member))
        {
            mixin(q{
                override ReturnType!(ovrld) } ~ member ~ q{ (Parameters!ovrld params)
                {
                    scope conn = this.pool.lockConnection();
                    scope (failure)
                    {
                        conn.close();
                        this.pool.remove(conn);
                    }
                    ubyte[512] tmp = void;
                    Hash method = this.lookup[ovrld.mangleof];
                    // Send the method type

                    conn.wlock.lock();
                    conn.write(serializeFull(method));
                    // List of parameters
                    foreach (ref p; params)
                        serializePart(p, (in ubyte[] v) => conn.write(v));
                    conn.flush();
                    conn.wlock.unlock();

                    scope DeserializeDg dg = (size_t size)
                        {
                            ensure(size < tmp.length, "Out of bound read");
                            conn.read(tmp[0 .. size]);
                            return tmp[0 .. size];
                        };

                    conn.rlock.lock(); // todo: timeout
                    scope (exit)
                    {
                        conn.rlock.unlock();
                        conn.rcond.notify();
                    }
                    static if (!is(typeof(return) == void))
                    {
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
    public TaskMutex rlock;
    public TaskMutex wlock;

    ///
    public TaskCondition rcond;

    ///
    alias conn this;

    ///
    this () @safe nothrow
    {
        this.rlock = new TaskMutex();
        this.wlock = new TaskMutex();
        this.rcond = new TaskCondition(this.rlock);
    }

    ///
    this (TCPConnection conn) @safe nothrow
    {
        this.conn = conn;
        this();
    }

    ///
    void startListening (ThisEndAPI) (ThisEndAPI impl) @safe
    {
        this.rlock.lock();
        scope (exit) {
            this.conn.close();
            this.rlock.unlock();
        }
        // Try to reuse the connection, if no requests arrive within a certain
        // period then handleThrow() will throw and handle() will return false
        while (handle(impl, this, this.conn.readTimeout)) {}
    }
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
        new RPCConnection(stream).startListening(impl);
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

private bool handle (API) (API api, RPCConnection stream, Duration timeout) @trusted nothrow
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

private void handleThrow (API) (scope API api, RPCConnection stream, Duration timeout)
    @trusted
{
    static string[Hash] lookup;
    if (lookup.length == 0)
    {
        static foreach (member; __traits(allMembers, API))
            static foreach (ovrld; __traits(getOverloads, API, member))
                lookup[hashFull(ovrld.mangleof)] = ovrld.mangleof;
    }

    ubyte[1024] buffer = void;
    scope DeserializeDg reader = (size_t size) @safe
    {
        ensure(size < buffer.length, "Out of bound read");
        stream.read(buffer[0 .. size]);
        return buffer[0 .. size];
    };

    string* method;
    Hash methodbin;
    while (true)
    {
        ensure(stream.connected(), "Connection closed");
        stream.readTimeout = 10.minutes;
        methodbin = deserializeFull!Hash(reader);
        // after the initial data arrives, reduce the timeout to the configured amount
        stream.readTimeout = timeout;
        if (methodbin == hashFull("response")) // a response
        {
            stream.wlock.lock(); // acquire the write lock so no new request can be sent while we are waiting to get the rlock back
            stream.rcond.wait(); // wait for reader Fiber to signal us its completion
            stream.wlock.unlock();
        }
        else
        {
            method = methodbin in lookup;
            ensure(method !is null, format("[{}] Calling out of range method: {}",
                    stream.peerAddress, methodbin));
            break;
        }
    }

    // Helper template for staticMap
    Target convert (Target) ()
    {
        return deserializeFull!Target(reader);
    }

    log.trace("[{}] Handling a new request", stream.peerAddress);

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
            stream.wlock.lock();
            scope (exit) stream.wlock.unlock();
            stream.write(serializeFull(hashFull("response")));
            static if (is(ReturnType!ovrld == void))
            {
                mixin(CallMixin);
                log.trace("[SERVER] Goodbye {}", methodbin);
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
