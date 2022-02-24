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

static import agora.api.Validator;
import agora.common.Ensure;
import agora.common.Types;
import agora.crypto.Hash;
import agora.utils.Log;
import agora.serialization.Serializer;

import ocean.text.convert.Formatter;

import vibe.core.net;
import vibe.core.connectionpool;
import vibe.core.sync;
import vibe.http.server : RejectConnectionPredicate;

import std.conv : to;
import std.socket : Address, AddressFamily, parseAddress;
import std.traits;
import core.stdc.stdio;
import core.time;

mixin AddLogger!();

struct ProxyProtocol
{
    /// Protocol v2 signature
    private immutable ubyte[12] v2_signature = [
        13, 10, 13, 10, 0, 13, 10, 81, 85, 73, 84, 10
    ];

    /// Source address
    Address src;

    /// Destination address
    Address dst;

    ///
    public this (TCPConnection stream) @trusted
    {
        ubyte[108] buffer;

        stream.read(buffer[0 .. 12]); // Read signature

        ensure(buffer[0 .. 12] != v2_signature,
            "Proxy Protocol v2 is not yet supported");

        // Read into buffer starting from `last_ix` until `ch`
        uint readUntil (uint last_ix, char ch)
        {
            uint inner_ix = last_ix;
            ubyte[1] mb = ['\0'];

            while (cast(char) mb[0] != ch)
            {
                stream.read(mb);
                buffer[inner_ix] = mb[0];
                inner_ix++;
            }

            return inner_ix;
        }

        auto protocol = cast(char[])(buffer[0 .. 6]);
        ensure(protocol == "PROXY ",
            "Unexpected protocol identifier {}", protocol);

        auto inet = cast(char[])(buffer[6 .. 11]);

        uint last_ix = 11; // Signature was already read
        uint next_ix = 0;

        if (inet == "TCP4 " || inet == "TCP6 ")
        {
            next_ix = readUntil(12, ' '); // Starting from 12 due to signature
            auto srcaddr = cast(char[])(buffer[last_ix .. next_ix-1]);

            last_ix = next_ix;
            next_ix = readUntil(last_ix, ' ');
            auto dstaddr = cast(char[])(buffer[last_ix .. next_ix-1]);

            last_ix = next_ix;
            next_ix = readUntil(last_ix, ' ');
            auto srcport = cast(char[])(buffer[last_ix .. next_ix-1]);

            last_ix = next_ix;
            next_ix = readUntil(last_ix, '\n');
            ensure ('\r' == buffer[next_ix - 2], "Invalid protocol message");
            auto dstport = cast(char[])(buffer[last_ix .. next_ix-2]);

            this.src = parseAddress(srcaddr, to!ushort(srcport));
            this.dst = parseAddress(dstaddr, to!ushort(dstport));
        }
        else
        { // Consume protocol header for UNKNOWN
            next_ix = readUntil(12, '\n');
            ensure('\r' == buffer[next_ix - 2], "Invalid protocol message");
        }
    }
}

/// Ditto
public class RPCClient (API) : API
{
    /// Lookup table for the client, mapping an overload to a hash
    private static immutable Hash[string] lookup;

    /// Reverse lookup tables for the server, mapping a hash to an overload
    private static immutable string[Hash] rlookup;

    /// Initialize `lookup`
    shared static this ()
    {
        static foreach (member; __traits(allMembers, API))
            static foreach (ovrld; __traits(getOverloads, API, member))
            {
                RPCClient.lookup[ovrld.mangleof] = hashFull(ovrld.mangleof);
                RPCClient.rlookup[RPCClient.lookup[ovrld.mangleof]] = ovrld.mangleof;
            }
    }

    /// Config instance for this client
    private RPCConfig config;

    /// Pool of connections to the host
    private ConnectionPool!RPCConnection pool;

    /// Logger for this client
    private Logger log;

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
        const RPCConfig conf = {
            host:               host,
            port:               port,

            retry_delay:        retry_delay,
            max_retries:        max_retries,

            connection_timeout: ctimeout,
            read_timeout:       rtimeout,
            write_timeout:      wtimeout,
            concurrency:        concurrency,
        };
        this(conf, impl);
    }

    /// Ditto
    public this (ThisEndAPI) (const RPCConfig config, ThisEndAPI impl) @trusted
    {
        this.config = config;
        this.log = Log.lookup(
            format("{}.{}.{}", __MODULE__, this.config.host, this.config.port));
        this.pool = new ConnectionPool!RPCConnection(
            () => this.connect(impl), this.config.concurrency);
    }

    /// Returns: A new `RPCConnection` using `impl` as listener
    private RPCConnection connect (ThisAPIImpl) (ThisAPIImpl impl) @safe
    {
        ensure(this.config != RPCConfig.init, "Can not connect on unidentified client");
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
                        rpc_conn.rlock.lock();
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
    }

    /// Ditto
    public this (ThisEndAPI) (RPCConnection conn, ThisEndAPI impl) @trusted
    {
        this(RPCConfig.init, impl);
        assert(this.pool.add(conn));
    }

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
                        conn.write(serializeFull(p));
                    conn.flush();
                    conn.wlock.unlock();

                    scope DeserializeDg dg = (size_t size)
                        {
                            if (size >= tmp.length)
                            {
                                this.log.warn("{}: Read size {} is too large for buffer size {}, closing connection",
                                         __FUNCTION__, size, tmp.length);
                                ensure(0, "{}: Out of bound read: {} >= {}", __FUNCTION__, size, tmp.length);
                            }
                            conn.read(tmp[0 .. size]);
                            return tmp[0 .. size];
                        };

                    ensure(conn.rlock.lock(this.config.read_timeout), "Operation timed out");
                    scope (exit)
                    {
                        conn.rlock.unlock();
                        conn.rcond.notify();
                    }
                    ensure(conn.connected(), "Connection closed");
                    conn.readTimeout = this.config.read_timeout;
                    static if (!is(typeof(return) == void))
                    {
                        version (all)
                        {
                            auto retval = deserializeFull!(typeof(return))(dg);
                            this.log.trace("[CLIENT] {}: Returning {}", __FUNCTION__, retval);
                            return retval;
                        }
                        else
                            return deserializeFull!(typeof(return))(dg);
                    }
                }
            });
        }

    ///
    bool addConnection (RPCConnection conn) nothrow
    {
        return this.pool.add(conn);
    }

    ///
    void merge (RPCClient!API rhs)
    {
        if (this.config == RPCConfig.init)
            this.config = rhs.config;
        rhs.pool.removeUnused((RPCConnection conn) @trusted nothrow {
            this.addConnection(conn);
        });
    }
}

/// Aggregate configuration options for `RPCClient`
public struct RPCConfig
{
    /***************************************************************************

        Host to connect to

        See_Also: https://tools.ietf.org/html/rfc3986#section-3.2.2

    ***************************************************************************/

    public string host;

    /***************************************************************************

        Port to connect to

        See_Also: https://tools.ietf.org/html/rfc3986#section-3.2.3

    ***************************************************************************/

    public ushort port;

    /***************************************************************************

        Maximum number of retries before throwing an `Exception`

        Whenever connecting or sending a request to a remote host,
        this class will perform `max_retries` attempt at the operation
        before throwing an `Exception`. Each attempt will have a delay
        in between, and their own timeout, depending on the operation.

    ***************************************************************************/

    public uint max_retries;

    /***************************************************************************

        Timeout for a connection attempt

        Whenever connecting to a remote host, this value defines how long
        we are willing to wait before marking the connection attempt as
        failed. Note that the total wait time also depends on `max_retries`
        and `retry_delay`.

    ***************************************************************************/

    public Duration connection_timeout = 5.seconds;

    /***************************************************************************

        Timeout for a read operation

        Whenever reading from a remote host, this value defines how long
        we are willing to wait before marking the operation as failed.
        Note that the total wait time also depends on `max_retries` and
        `retry_delay`.

    ***************************************************************************/

    public Duration read_timeout = 5.seconds;

    /***************************************************************************

        Timeout for a write operation

        Whenever sending data toa remote host, this value defines how long
        we are willing to wait before marking the operation as failed.
        Note that the total wait time also depends on `max_retries` and
        `retry_delay`.

    ***************************************************************************/

    public Duration write_timeout = 5.seconds;

    /***************************************************************************

        Time to wait between two attempts at connecting / reading / writing

        Whenever an operation is marked as failed, this is the time to
        wait between each attempt.
        Note that a smarter client might want to set max_retries to 0,
        in which case this value has no effect, to implement smarter
        approaches to retry, e.g. exponential backoff.

    ***************************************************************************/

    public Duration retry_delay  = 1.seconds;

    ///
    public uint concurrency = 3;
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

    /// Assumes rlock is locked
    void startListening (ThisEndAPI) (ThisEndAPI impl) @safe
    {
        scope (exit) {
            this.conn.close();
            this.rlock.unlock();
        }
        // Try to reuse the connection, if no requests arrive within a certain
        // period then handleThrow() will throw and handle() will return false
        while (this.conn.connected() && handle(impl, this, this.conn.readTimeout)) {}
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
      proxy_protocol = The Proxy Protocol V1 is enabled
      isBannedDg = Delegate for checking if sending peer is banned

*******************************************************************************/

public TCPListener listenRPC (API) (API impl, string address, ushort port, bool proxy_protocol,
    Duration timeout, void delegate (agora.api.Validator.API api) @safe nothrow discoverFromClient,
    RejectConnectionPredicate isBannedDg)
{
    auto callback = (TCPConnection stream) @safe nothrow {
        NetworkAddress net_addr = stream.remoteAddress;
        if (proxy_protocol)
        {
            try
            {
                auto pp = ProxyProtocol(stream);
                log.trace("RPC connection through ProxyProtocol: {}", pp.src.toString());
                net_addr = NetworkAddress(pp.src);
            }
            catch (Exception e) {
                log.error("RPC through ProxyProtocol error: {}", e.msg);
                return; // Drop connection
            }
        }

        if (isBannedDg(net_addr))
        {
            try log.trace("RPC connection discarded, peer is banned {}",
                net_addr.toAddressString());
            catch (Exception e) {}
            return;
        }

        try stream.readTimeout = timeout;
        catch (Exception e) assert(0);
        auto conn = new RPCConnection(stream);
        conn.rlock.lock();
        try
            discoverFromClient(new RPCClient!(agora.api.Validator.API)(conn, impl));
        catch (Exception ex)
        {
            try log.trace("Exception caught while trying to create a client from incoming conn: {}", ex);
            catch (Exception e) {}
        }
        conn.startListening(impl);
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
    ubyte[1024] buffer = void;
    scope DeserializeDg reader = (size_t size) @safe
    {
        ensure(size < buffer.length, "Out of bound read");
        stream.read(buffer[0 .. size]);
        return buffer[0 .. size];
    };

    immutable(string)* method;
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
            method = methodbin in RPCClient!(API).rlookup;
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

    log.trace("[{} - {}] Handling a new request", stream.peerAddress, stream.localAddress);

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
                stream.write(serializeFull(foo));
                log.trace("[SERVER] Done writing...");
            }
            return;
        }
    default:
        assert(0);
    }
}
