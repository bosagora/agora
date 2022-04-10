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

import dtext.format.Formatter;

import vibe.core.net;
import vibe.core.connectionpool;
import vibe.core.core : runTask;
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

/// A RPC packet
private struct Packet
{
    /// Sequence id
    public ulong seq_id;

    /// response bit
    public bool is_response;

    /// requested method
    public Hash method;
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

    /// Connection to the host
    private TCPConnection conn;

    /// Write lock on connection
    private TaskMutex wlock;

    /// Read lock on connection
    private TaskMutex rlock;

    /// Local sequence id
    private uint seq_id;

    /// Control structure for Fibers blocked on this connection
    private class Waiting
    {
        /// The event that the blocked fiber will be waiting on
        public LocalManualEvent event;

        /// Response packet that we get
        public Packet res;

        /// Callback to invoke when response packet is received
        public void delegate () @safe on_packet_received;

        public this (LocalManualEvent event,
            void delegate () @safe on_packet_received)
        {
            this.event = event;
            this.on_packet_received = on_packet_received;
        }
    }

    /// List of Fibers waiting for a Response from this Connection
    private Waiting[size_t] waiting_list;

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

    public this (string host, ushort port, Duration retry_delay, uint max_retries,
                 Duration ctimeout, Duration rtimeout, Duration wtimeout) @trusted
    {
        this.config = RPCConfig(host, port, max_retries,
            ctimeout, rtimeout, wtimeout, retry_delay);
        this.wlock = new TaskMutex();
        this.rlock = new TaskMutex();
        this.log = Log.lookup(
            format("{}.{}.{}", __MODULE__, this.config.host, this.config.port));
    }

    /// Returns: A new `TCPConnection`
    private TCPConnection connect () @safe
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
                    return conn;
            }
            catch (Exception e) {}
            attempts++;
        } while (attempts < this.config.max_retries);

        ensure(false, "Failed to connect to host");
        assert(0);
    }

    /// Implementation of the API's functions
    static foreach (member; __traits(allMembers, API))
        static foreach (ovrld; __traits(getOverloads, API, member))
        {
            mixin(q{
                override ReturnType!(ovrld) } ~ member ~ q{ (Parameters!ovrld params)
                {
                    ubyte[1024] buffer = void;
                    scope DeserializeDg reader = (size_t size) @safe
                    {
                        ensure(size < buffer.length, "Out of bound read");
                        this.conn.read(buffer[0 .. size]);
                        return buffer[0 .. size];
                    };

                    Packet packet;
                    packet.seq_id = this.seq_id++;
                    packet.method = this.lookup[ovrld.mangleof];

                    // Acquire the write lock and send the packet
                    {
                        this.wlock.lock();
                        scope (exit) this.wlock.unlock();
                        if (!this.conn.connected())
                            this.conn = this.connect();

                        this.conn.write(serializeFull(packet));
                        // List of parameters
                        foreach (ref p; params)
                            this.conn.write(serializeFull(p));
                        this.conn.flush();
                    }

                    static if (!is(typeof(return) == void))
                    {
                        scope (exit) this.waiting_list.remove(packet.seq_id);
                        ReturnType!(ovrld)[] response;
                        auto woke_up = 0;
                        auto start = MonoTime.currTime;
                        Waiting waiting;
                        // Attempt to acquire the read lock, if we cant; register ourself
                        // as a `waiter` and wait for the Fiber that has the read lock to signal
                        // us when it receives the response we are waiting for
                        while (!this.rlock.tryLock())
                        {
                            if (waiting is null)
                            {
                                waiting = new Waiting(createManualEvent(), () {
                                    auto val = deserializeFull!(ReturnType!(ovrld))(reader);
                                    response ~= val;
                                });
                                this.waiting_list[packet.seq_id] = waiting;
                            }

                            ensure(waiting.event.wait(start + this.config.read_timeout
                                - MonoTime.currTime, woke_up) > woke_up++, "Request timed out");

                            // reader fiber read the response and stored it for us
                            if (waiting.res.is_response)
                            {
                                ensure(waiting.res.method == packet.method, "Method mismatch");
                                ensure(response.length == 1, "Error while reading response");
                                return response[0];
                            }
                        }

                        // got the rlock
                        // keep reading response packets and waking up the fibers waiting for them
                        {
                            scope (success)
                                // wake up one of the waiters to get the rlock and start reading
                                if (this.waiting_list.length > 0)
                                     this.waiting_list.byValue.front.event.emit();
                            scope (exit) this.rlock.unlock();
                            scope (failure) this.conn.close();

                            ensure(this.conn.connected(), "Connection dropped");

                            while (true)
                            {
                                auto any_response = deserializeFull!Packet(reader);
                                ensure(any_response.is_response, "Unexpected request on client socket");

                                if (any_response.seq_id == packet.seq_id)
                                {
                                    ensure(any_response.method == packet.method, "Method mismatch");
                                    return deserializeFull!(ReturnType!(ovrld))(reader);
                                }
                                else if (auto waiter = any_response.seq_id in this.waiting_list)
                                {
                                    (*waiter).res = any_response;
                                    (*waiter).on_packet_received();
                                    (*waiter).event.emit();
                                }
                            }
                        }
                    }
                }
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
}

/// A TCPConnection that can be shared across Tasks
private class SharedTCPConnection
{
    private TCPConnection stream;
    alias stream this;
    private TaskMutex wmutex;

    this (TCPConnection stream) @safe nothrow
    {
        this.stream = stream;
        this.wmutex = new TaskMutex();
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
      timeout = timeout for reading a response
      isBannedDg = Delegate for checking if sending peer is banned

*******************************************************************************/

public TCPListener listenRPC (API) (API impl, string address, ushort port, bool proxy_protocol,
    Duration timeout, RejectConnectionPredicate isBannedDg)
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
        auto shared_conn = new SharedTCPConnection(stream);
        while (shared_conn.connected() && handle(impl, shared_conn, shared_conn.readTimeout)) {}
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
      timeout = timeout for reading a response

*******************************************************************************/

private bool handle (API) (API api, SharedTCPConnection stream, Duration timeout) @trusted nothrow
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
      timeout = timeout for reading a response

*******************************************************************************/

private void handleThrow (API) (scope API api, SharedTCPConnection stream, Duration timeout) @trusted
{
    ubyte[1024] buffer = void;
    scope DeserializeDg reader = (size_t size) @safe
    {
        ensure(size < buffer.length, "Out of bound read");
        stream.read(buffer[0 .. size]);
        return buffer[0 .. size];
    };

    stream.readTimeout = 10.minutes;
    auto packet = deserializeFull!Packet(reader);
    ensure(!packet.is_response, "Response on server socket");
    log.trace("[{} - {}] Handling a new request", stream.peerAddress, stream.localAddress);

    auto method = packet.method in RPCClient!(API).rlookup;
    ensure(method !is null, format("[{}] Calling out of range method: {}",
            stream.peerAddress, packet.method));

    switch (*method)
    {
    static foreach (member; __traits(allMembers, API))
        static foreach (ovrld; __traits(getOverloads, API, member))
        {
        case ovrld.mangleof:
            alias ArgTypes = staticMap!(Unqual, Parameters!ovrld);

            // so that we can heap allocate the arguments explicitly
            // and use them in the worker fiber
            static class ArgsWrapper
            {
                ArgTypes args;
            }

            auto args_wrapper = new ArgsWrapper();
            stream.readTimeout = timeout;
            foreach (i, PT; ArgTypes)
                args_wrapper.args[i] = deserializeFull!PT(reader);
            enum CallMixin = "api." ~ member ~ "(args_wrapper.args);";

            log.trace("[SERVER] {} requested {}({})",
                      stream.peerAddress, member, (Parameters!ovrld).stringof);

            runTask(() @safe nothrow {
                try
                {
                    static if (is(ReturnType!ovrld == void))
                        mixin(CallMixin);
                    else
                    {
                        mixin("auto foo = ", CallMixin);
                        packet.is_response = true;
                        stream.write(serializeFull(packet) ~ serializeFull(foo));
                    }
                } catch (Exception e) {}
            });
            return;
        }
    default:
        assert(0);
    }
}
