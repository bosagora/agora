/*******************************************************************************

    Lower level utility functions for networking

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.InetUtils;

import agora.common.Types;
import agora.utils.Log;

import myip;
import vibe.inet.url : URL;

import std.algorithm;
import std.algorithm.searching;
import std.array;
import std.ascii : isAlpha, isDigit;
import std.conv;
import std.range : zip, iota;
import std.regex : matchFirst, regex;
import std.socket : AddressFamily;
import std.string : indexOf, strip;
import std.typecons : tuple, Tuple;

import core.stdc.string;

mixin AddLogger!();

///
public enum HostType : ubyte
{
    Invalid,
    IPv4,
    IPv6,
    Domain,
}

struct InetUtils
{
    public static string[] getAllIPs() @trusted
    {
        string[] ips = getPrivateIPs(AddressFamily.UNSPEC);
        ips ~= getPublicIP(AddressFamily.INET6); // This also returns IPv4
        return ips;
    }

    /***************************************************************************

        Expand an IPv6 address to its canonical representation

        For example:
            ::5:6:7:8      => 0:0:0:0:5:6:7:8
            1:2:3::7:8     => 1:2:3:0:0:0:7:8
            ::             => 0:0:0:0:0:0:0:0

        Params:
            ip = compressed IPv6 address

        Returns:
            uncompressed representation of IPv6 address

    ***************************************************************************/

    public static string expandIPv6 (const(char)[] ip) @safe pure
    {
        auto parts = ip.split(":");
        const first_empty_ind = parts.countUntil("");

        // filter out all the empty parts, except the first one
        auto res = zip(iota(parts.length), parts).filter!((tup) => tup[0] == first_empty_ind || !tup[1].empty()).
                   map!(tup => tup[1]).array();

        // fill in the empty part with the needed zeros
        return () @trusted pure {
            return cast(string) res.map!(part => (part.empty() ? replicate(cast(const(char)[][])["0"], 8 - res.length + 1) : [part]))
                        .joiner.array.join(":");
        }();
    }

    unittest
    {
        assert(expandIPv6("1:2:3:4:5:6:7:8") == "1:2:3:4:5:6:7:8");
        assert(expandIPv6("::5:6:7:8") == "0:0:0:0:5:6:7:8");
        assert(expandIPv6("::8") == "0:0:0:0:0:0:0:8");
        assert(expandIPv6("::5:0:0:0") == "0:0:0:0:5:0:0:0");
        assert(expandIPv6("1:2:3:4:5:6:7::") == "1:2:3:4:5:6:7:0");
        assert(expandIPv6("1::") == "1:0:0:0:0:0:0:0");
        assert(expandIPv6("1:2:3::7:8") == "1:2:3:0:0:0:7:8");
        assert(expandIPv6("::") == "0:0:0:0:0:0:0:0");
    }

    ///
    public alias HostPortTup = Tuple!(string, "host", ushort, "port", HostType, "type", string, "schema");

    /***************************************************************************

        Extracts host and port from a URL and determine the host type

        Host can be DNS host name, IPv6 or IPv4 address.

        Example URLs are
            https://www.bosagora.io:1234/data
            http://[1:2::3]/data

        Params:
          url = the URL from which we would like to extract the host and port

        Returns: `HostPortTup` containing the extracted host, port and host type

    ****************************************************************************/

    public static HostPortTup extractHostAndPort (Address url) @safe
    {
        HostType host_type = HostType.Domain;
        if (url.host.canFind(':'))
            host_type = HostType.IPv6;
        else if (url.host.all!(c => c.isDigit() || c == '.'))
            host_type = HostType.IPv4;

        return HostPortTup(url.host, url.port, host_type, url.schema);
    }

    unittest
    {
        // IPv6 tests
        assert(extractHostAndPort(Address("https://[1:2:3:4:5:6]:12345/blabla/blabla/"))
                == HostPortTup("1:2:3:4:5:6", 12345, HostType.IPv6, "https"));

        assert(extractHostAndPort(Address("https://[1:2:3:4:5:6]/blabla"))
            == HostPortTup("1:2:3:4:5:6", 443, HostType.IPv6, "https"));

        assert(extractHostAndPort(Address("https://[3::1]/blabla"))
            == HostPortTup("3::1", 443, HostType.IPv6, "https"));

        assert(extractHostAndPort(Address("https://[::1]/blabla"))
            == HostPortTup("::1", 443, HostType.IPv6, "https"));

        assert(extractHostAndPort(Address("http://[::]:1234"))
            == HostPortTup("::", 1234, HostType.IPv6, "http"));

        // IPv4 tests
        assert(extractHostAndPort(Address("https://1.2.3.4:12345/blabla/blabla"))
                == HostPortTup("1.2.3.4", 12345, HostType.IPv4, "https"));

        assert(extractHostAndPort(Address("https://1.2.3.4/blabla"))
            == HostPortTup("1.2.3.4", 443, HostType.IPv4, "https"));

        assert(extractHostAndPort(Address("http://1.2.3.4"))
            == HostPortTup("1.2.3.4", 80, HostType.IPv4, "http"));

        // Domain tests
        assert(extractHostAndPort(Address("http://node-0:1826/blabla/blabla/"))
            == HostPortTup("node-0", 1826, HostType.Domain, "http"));

        assert(extractHostAndPort(Address("http://seed.bosagora.io/blabla"))
            == HostPortTup("seed.bosagora.io", 80, HostType.Domain, "http"));
    }

    public static string getPublicIP(AddressFamily addressFamily = AddressFamily.INET) @safe
    {
        return publicAddress(Service.ipify, addressFamily);
    }

    public static string[] getPrivateIPs(AddressFamily addressFamily = AddressFamily.INET)
    {
        uint flags = 0;

        if (addressFamily == AddressFamily.INET)
            flags |= Exclude.IPV6;
        else if (addressFamily == AddressFamily.INET6)
            flags |= Exclude.IPV4;

        return privateAddresses(flags);
    }
}
