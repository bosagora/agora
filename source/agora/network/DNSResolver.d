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
import agora.utils.Log;

import std.array;
import std.algorithm;
import std.random;
static import std.socket;
import core.time;

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
        auto answer = !tcp ? this.queryUDP(msg) : this.queryTCP(msg);

        if (answer == Message.init)
            return null;

        // Message is truncated over UDP, retry over TCP
        if (!tcp && answer.header.TC)
            answer = this.queryTCP(msg);

        if (answer.header.RCODE != Header.RCode.NoError)
            return null;

        return answer.answers;
    }

    /***************************************************************************

        Query the server over UDP with given `msg` and return the response

        Params:
            msg = DNS message

    ***************************************************************************/

    protected abstract Message queryUDP (Message msg) @trusted;

    /***************************************************************************

        Query the server over TCP with given `msg` and return the response

        Params:
            msg = DNS message

    ***************************************************************************/

    protected abstract Message queryTCP (Message msg) @trusted;

    /// Ditto
    public ResourceRecord[] query (const(char)[] name, QTYPE type = QTYPE.ALL) @safe
    {
        // RFC 5936 recommends AXFR over TCP
        return this.query(this.buildQuery(name, type), type == QTYPE.AXFR);
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
                // TODO: What is expected when there's more than one record ?
                // Should we use it as a fall back, round robin, something else?
                const straddr = IPv4(res.rdata.a).toString();
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
