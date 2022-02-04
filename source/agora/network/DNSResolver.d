/*******************************************************************************

    A client-side DNS resolver

    This client is a caching, recursive DNS resolver, written in Dlang.

    Copyright:
        Copyright (c) 2019-2022 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.DNSResolver;

import agora.common.DNS;
import agora.common.Ensure;
import agora.common.Types;
import agora.serialization.Serializer;
import agora.utils.Log;

import vibe.core.net;

import std.array;
import std.algorithm;
import std.format;
import std.random;
static import std.socket;
import std.stdio;
import core.time;

shared static this ()
{
    // Cannot be a manifest constant as `Address` will read the common schema
    // when instantiated.
    DefaultDNS = [
        // Cloudflare
        Address("dns://1.1.1.1"), Address("dns://1.0.0.1"),
        // Google public DNS
        Address("dns://8.8.8.8"), Address("dns://8.8.4.4"),
        // CISCO OpenDNS
        Address("dns://208.67.222.222"), Address("dns://208.67.220.220"),
        // Quad9
        Address("dns://9.9.9.9"), Address("dns://149.112.112.112"),
    ];
}

///
public final class VibeDNSResolver : DNSResolver
{
    /// The list of base DNS resolver (e.g. read from resolv.conf)
    private PeerInfo[] resolvers;

    /***************************************************************************

        Instantiate a new object of this type

        Params:
          peers = The 'seed' peers, which are the first point of contact
                  of the resolver.

    ***************************************************************************/

    public this (const Address[] peers = DefaultDNS)
    {
        this.resolvers.length = peers.length;
        // "Connect" to each of the resolvers
        // UDP is not connection-oriented, but this binds the socket to the
        // underlying address.
        foreach (idx, ref res; this.resolvers)
        {
            res.address = resolveHost(peers[idx].host);
            res.address.port = peers[idx].port;
        }
    }

    /***************************************************************************

        Query the server over UDP with given `msg` and return the response

        Params:
            msg = DNS message

    ***************************************************************************/

    public override ResourceRecord[] queryUDP (Message msg) @trusted
    {
        ubyte[16384] buffer;
        foreach (ref peer; this.resolvers)
        {
            auto conn = listenUDP(0, "0.0.0.0",
                UDPListenOptions.reuseAddress | UDPListenOptions.reusePort);
            conn.connect(peer.address);

            try
            {
                conn.send(msg.serializeFull);
                auto response = conn.recv(5.seconds, buffer);
                auto answer = response.deserializeFull!Message();
                log.trace("Got response from '{}' for '{}' : {}",
                          peer.address, msg, answer);
                if (answer.header.RCODE == Header.RCode.NoError)
                    return answer.answers;
            }
            catch (Exception exc)
            {
                log.warn("Network error while resolving '{}' using '{}': {}",
                         msg, peer.address, exc);
                continue;
            }
        }
        return null;
    }

    /***************************************************************************

        Query the server over TCP with given `msg` and return the response

        Params:
            msg = DNS message

    ***************************************************************************/

    public override ResourceRecord[] queryTCP (Message msg) @trusted
    {
        ubyte[16384] buffer;

        ushort length = 2;
        scope writer = (in ubyte[] data) @safe {
            ensure(data.length <= (buffer.length - length),
                "Buffer overflow: Trying to write {} bytes in a {} buffer ({} used)",
                data.length, buffer.length, length);
            buffer[length .. length + data.length] = data[];
            length += data.length;
        };

        foreach (ref peer; this.resolvers)
        {
            auto conn = connectTCP(peer.address, anyAddress, 5.seconds);
            if (conn.connected)
            {
                try
                {
                    // Write length ~ serialized msg
                    msg.serializePart(writer, CompactMode.No);
                    assert(length >= 2);
                    ushort copy = cast(ushort) (length - 2);
                    length = 0;
                    copy.serializePart(writer, CompactMode.No);
                    conn.write(buffer[0 .. copy + 2]);

                    conn.read(buffer[0 .. 2]);
                    const ushort size = deserializeFull!ushort(
                        buffer[0 .. 2], DeserializerOptions(DefaultMaxLength, CompactMode.No));

                    // DNS TCP message size is not limited from Agora registry while sending
                    // but here received message size is not in our control,
                    // limited to a buffer for preventing DOS attack
                    conn.read(buffer[0 .. size]);
                    conn.close();

                    auto answer = deserializeFull!Message(buffer[0 .. size]);
                    if (answer.header.RCODE == Header.RCode.NoError)
                        return answer.answers;

                }
                catch (Exception exc)
                {
                    log.warn("Network error while resolving '{}' using '{}': {}",
                            msg, peer.address, exc);
                    conn.close();
                }
                break;
            }
        }

        return null;
    }
}

///
public abstract class DNSResolver
{
    /// Logger instance
    protected Logger log;

    /***************************************************************************

        Instantiate a new object of this type

    ***************************************************************************/

    public this ()
    {
        this.log = Log.lookup(__MODULE__);
    }

    /***************************************************************************

        Query the server with given `msg` and return the response

        Params:
            msg = DNS message
            tcp = Use TCP for query, default is UDP

    ***************************************************************************/

    public final ResourceRecord[] query (Message msg, bool tcp = false) @safe
    {
        return !tcp ? this.queryUDP(msg) : this.queryTCP(msg);
    }

    /***************************************************************************

        Query the server over UDP with given `msg` and return the response

        Params:
            msg = DNS message

    ***************************************************************************/

    protected abstract ResourceRecord[] queryUDP (Message msg) @trusted;

    /***************************************************************************

        Query the server over TCP with given `msg` and return the response

        Params:
            msg = DNS message

    ***************************************************************************/

    protected abstract ResourceRecord[] queryTCP (Message msg) @trusted;

    /// Ditto
    public ResourceRecord[] query (const(char)[] name, QTYPE type = QTYPE.ALL) @safe
    {
        return this.query(this.buildQuery(name, type));
    }

    /// Returns: DNS message for querying a record of `type` for `name'
    protected Message buildQuery (const(char)[] name, QTYPE type = QTYPE.ALL) @safe
    {
        Message msg;
        msg.questions ~= Question(Domain.fromString(name), type, QCLASS.IN);

        msg.header.ID = uniform!short;
        // Don't do the whole recursion dance, assume our resolvers are recursive.
        msg.header.RD = true;
        // Default:
        // QR set to 0 (query), OPCODE set to 0 (Query), AA set to false,
        // TC set to false, RA set to false, Z set to 0, RCODE set to 0 (NoError)
        msg.header.QDCOUNT = 1;
        // Rest is set to 0
        msg.additionals ~= OPTRR.init.record;
        msg.header.ARCOUNT = 1;

        return msg;
    }

    /// Resolves an address
    public Address resolve (Address address)
    {
        // Fast path: If the address is already resolved,
        // do not do network communication
        try
        {
            scope res = std.socket.parseAddress(address.host);
            return address;
        }
        catch (std.socket.SocketException) {}

        // We need to execute a query, and parse the resulting DNS record
        auto results = this.query(this.buildQuery(address.host));
        ensure(results.length > 0, "Could not resolve host name '{}' (address: '{}')",
               address.host, address);

        // Our DNS record will primarily be of 3 types: A, CNAME, AAAA
        // CNAME just means we have to recurse, while the other ones are the end result.
        size_t ipv6_index = results.length;
        foreach (index, const ref res; results)
        {
            // If it's a CNAME we need to recurse, although the server should
            // have done that for us.
            if (res.type == TYPE.CNAME)
            {
                ensure(res.name.value.length > 0,
                       "Found a CNAME to the root domain (empty) while resolving '{}'", address);
                log.trace("Address '{}': Found CNAME '{}'", address, res.name);
                address.host = cast(string) res.name.value;
                return this.resolve(address);
            }

            // Prefer IPv4 as it's faster and less surprising to users
            if (res.type == TYPE.A)
            {
                // Ignore broken record
                if (res.rdata.a.length < 1) continue;
                // Just pick the first record.
                // TODO: What is expected when there's more than one record ?
                // Should we use it as a fall back, round robin, something else?
                const straddr = format("%d.%d.%d.%d",
                    res.rdata.a[0] >> 24 & 0xFF, res.rdata.a[0] >> 16 & 0xFF,
                    res.rdata.a[0] >>  8 & 0xFF, res.rdata.a[0] >>  0 & 0xFF);
                log.trace("Address '{}' resolved to A record '{}'", address, straddr);
                address.host = straddr;
                return address;
            }
            // Save the IPv6 address if encountered
            else if (res.type == TYPE.AAAA && ipv6_index == results.length)
                 ipv6_index = index;
        }
        ensure(false, "Could not resolve host name '{}': No address in result",
               address.host);
        assert(0);
    }

    public Domain[] getNameServers (const(char)[] name) @safe
    {
        if (auto answers = this.query(this.buildQuery(name, QTYPE.NS)))
            return answers.map!(answ => answ.rdata.name).array;
        return null;
    }
}

/*******************************************************************************

    An `Address` where the `hostname` part has been resolved

*******************************************************************************/

/// Hold information about DNS resolvers
private struct PeerInfo
{
    /// Address of the peer (IP)
    public NetworkAddress address;

    /// Number of messages sent to this peer
    public size_t queries;
}

/// The 'default' DNS resolver if none is provided
public immutable Address[] DefaultDNS;

version (AgoraStandaloneDNSResolver)
{
    import vibe.core.core;

    import std.stdio;

    private int main (string[] args)
    {
        assert(args.length > 1, "Need at least one argument");

        runTask(() @trusted nothrow {
            scope (failure) assert(0);
            DNSResolver resolver = new VibeDNSResolver();
            resolver.log.enableConsole();

            foreach (host; args[1 .. $])
            {
                try
                    writeln(resolver.query(host, QTYPE.NS));
                catch (Exception exc)
                    writeln("Exception caught while try to resolve addresses: ", exc);
            }
        });

        return runEventLoop();
    }
}
