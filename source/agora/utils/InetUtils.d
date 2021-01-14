/*******************************************************************************

    Lower level utility functions for networking

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.InetUtils;

import agora.utils.Log;

import vibe.inet.url : URL;

import std.algorithm;
import std.algorithm.searching;
import std.array;
import std.ascii : isAlpha, isDigit;
import std.conv;
import std.range : zip, iota;
import std.regex : matchFirst, regex;
import std.string : indexOf, strip;
import std.socket;
import std.typecons : tuple, Tuple;

import core.stdc.string;

mixin AddLogger!();

///
public enum HostType : ubyte
{
    IPv4,
    IPv6,
    Domain,
    Invalid,
}

///
mixin template AddGetAllIPs()
{
    public static string[] getAllIPs()
    {
        string[] ips;

        ifaddrs* if_address_head_poi;
        ifaddrs* if_address_poi;

        getifaddrs(&if_address_head_poi);
        scope(exit) freeifaddrs(if_address_head_poi);

        for (if_address_poi = if_address_head_poi; if_address_poi; if_address_poi = if_address_poi.ifa_next)
        {
            if (if_address_poi.ifa_addr &&
                (if_address_poi.ifa_addr.sa_family == AF_INET || if_address_poi.ifa_addr.sa_family == AF_INET6))
            {
                const ipv6 = if_address_poi.ifa_addr.sa_family == AF_INET6;
                const sockaddr_len  = ipv6? sockaddr_in6.sizeof : sockaddr_in.sizeof;

                char[NI_MAXHOST] buffer;
                int name_info_res = getnameinfo(if_address_poi.ifa_addr, sockaddr_len, buffer.ptr, buffer.length,
                                                null, 0, NI_NUMERICHOST);
                if (name_info_res)
                {
                    log.error("error happened during a call to getnameinfo, name_info_res code: {}", name_info_res);
                    continue;
                }
                string ip = buffer[0 .. strlen(buffer.ptr)].idup();
                ips ~= ip;
            }
        }

        return ips;
    }
}

version (OSX)
{
    static if (__VERSION__ < 2095)
    {
        extern (C):
        nothrow:
        @nogc:

        struct ifaddrs
        {
            /// Next item in the list
            ifaddrs* ifa_next;
            /// Name of the interface
            char* ifa_name;
            /// Flags from SIOCGIFFLAGS
            uint ifa_flags;
            /// Address of interface
            sockaddr* ifa_addr;
            /// Netmask of interface
            sockaddr* ifa_netmask;
            /// Point-to-point destination addresss
            sockaddr* if_dstaddr;
            /// Address specific data
            void* ifa_data;
        }

        /// Returns: linked list of ifaddrs structures describing interfaces
        int getifaddrs(ifaddrs** );
        /// Frees the linked list returned by getifaddrs
        void freeifaddrs(ifaddrs* );
    }
    else
    {
        import core.sys.darwin.ifaddrs;
    }
}

struct InetUtils
{
version (OSX)
{
    import core.sys.posix.netdb;
    import core.sys.posix.netinet.in_;
    import core.sys.posix.sys.socket;

    mixin AddGetAllIPs;
}
version (linux)
{
    import core.sys.linux.ifaddrs;
    import core.sys.posix.netdb;

    mixin AddGetAllIPs;
}
version (Windows)
{
    import std.socket;

    import core.sys.windows.iphlpapi;
    import core.sys.windows.iptypes;
    import core.sys.windows.windef;
    import core.sys.windows.winsock2;
    import core.stdc.stdlib: malloc, free;
    import core.stdc.string: strlen;

    public static string[] getAllIPs()
    {
        string[] ips;
        PIP_ADAPTER_INFO adapter_info_head = cast(IP_ADAPTER_INFO *) malloc(IP_ADAPTER_INFO.sizeof);
        PIP_ADAPTER_INFO adapter_info;
        DWORD ret_adapters_info;
        ULONG buff_length = IP_ADAPTER_INFO.sizeof;
        if (adapter_info_head == NULL)
        {
            log.error("Error allocating memory needed to call GetAdaptersinfo");
            return null;
        }
        scope(exit) free(adapter_info_head);
        // find out the real size we need to allocate
        if (GetAdaptersInfo(adapter_info_head, &buff_length) == ERROR_BUFFER_OVERFLOW)
        {
            free(adapter_info_head);
            adapter_info_head = cast(IP_ADAPTER_INFO *) malloc(buff_length);
            if (adapter_info_head == NULL)
            {
                log.error("Error reallocating memory needed to call GetAdaptersinfo");
                return null;
            }
        }
        if ((ret_adapters_info = GetAdaptersInfo(adapter_info_head, &buff_length)) == NO_ERROR) {
            adapter_info = adapter_info_head;
            while (adapter_info)
            {
                auto ip_tmp = cast(char *) adapter_info.IpAddressList.IpAddress.String;
                string ip = ip_tmp[0 .. strlen(ip_tmp)].idup;
                if (ip.length > 0 && ip != "0.0.0.0")
                    ips ~= ip;

                adapter_info = adapter_info.Next;
            }
            return ips;
        }
        else
        {
            log.error("GetAdaptersInfo failed with error: {}", ret_adapters_info);
            return null;
        }
        return null;
    }
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
    public alias HostPortTup = Tuple!(string, "host", ushort, "port", HostType, "type");

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

    public static HostPortTup extractHostAndPort (string url) @safe
    {
        url = url.strip();
        // detect wether url has valid schema and append 'http' if not
        auto idx = url.indexOf(':');
        if (idx < 1 || (url.length && !url[0].isAlpha()))
            url = "http://" ~ url;

        // parse url
        URL parsed_url;
        try
        {
            parsed_url = URL.parse(url);
        }
        catch(Exception e)
        {
            return HostPortTup("",0, HostType.Invalid);
        }

        HostType host_type = HostType.Domain;
        if (parsed_url.host.canFind(':'))
            host_type = HostType.IPv6;
        else if (parsed_url.host.all!(c => c.isDigit() || c == '.'))
            host_type = HostType.IPv4;

        return HostPortTup(parsed_url.host, parsed_url.port, host_type);
    }

    unittest
    {
        // IPv6 tests
        assert(extractHostAndPort("https://[1:2:3:4:5:6]:12345/blabla/blabla/")
                == HostPortTup("1:2:3:4:5:6", 12345, HostType.IPv6));

        assert(extractHostAndPort("https://[1:2:3:4:5:6]/blabla")
            == HostPortTup("1:2:3:4:5:6", 443, HostType.IPv6));

        assert(extractHostAndPort("https://[3::1]/blabla")
            == HostPortTup("3::1", 443, HostType.IPv6));

        assert(extractHostAndPort("https://[::1]/blabla")
            == HostPortTup("::1", 443, HostType.IPv6));

        assert(extractHostAndPort("http://[::]:1234")
            == HostPortTup("::", 1234, HostType.IPv6));

        assert(extractHostAndPort("[::]")
            == HostPortTup("::", 80, HostType.IPv6));

        // IPv4 tests
        assert(extractHostAndPort("https://1.2.3.4:12345/blabla/blabla")
                == HostPortTup("1.2.3.4", 12345, HostType.IPv4));

        assert(extractHostAndPort("https://1.2.3.4/blabla")
            == HostPortTup("1.2.3.4", 443, HostType.IPv4));

        assert(extractHostAndPort("http://1.2.3.4")
            == HostPortTup("1.2.3.4", 80, HostType.IPv4));

        assert(extractHostAndPort("1.2.3.4")
            == HostPortTup("1.2.3.4", 80, HostType.IPv4));

        // Domain tests
        assert(extractHostAndPort("http://node-0:1826/blabla/blabla/")
            == HostPortTup("node-0", 1826, HostType.Domain));

        assert(extractHostAndPort("seed.bosagora.io/blabla")
            == HostPortTup("seed.bosagora.io", 80, HostType.Domain));
    }

    public static string[] getPublicIPs()
    {
        return filterIPs(ip => !isPrivateIP(ip));
    }

    public static string[] getPrivateIPs()
    {
        return filterIPs(&isPrivateIP);
    }

    private static bool isPrivateIP(string ip)
    {
        if (ip.canFind(':'))
        {
            if(ip == "" || ip == "::" || "::1") // Loopback
                return true;
            ushort[] ip_parts = ip.split("::").map!(ip_part => to!ushort(ip_part,16)).array();
            if(ip_parts.length >= 1)
            {
                if(ip_parts[0] >= to!ushort("fe80",16) && ip_parts[0] <= to!ushort("febf",16)) // Link
                    return true;
                if(ip_parts[0] >= to!ushort("fc00",16) && ip_parts[0] <= to!ushort("fdff",16)) // Private network
                    return true;
                if(ip_parts[0] == to!ushort("100",16)) // Discard prefix
                    return true;
            }
            return false;
        }
        else
        {
            // private and loopback addresses are the followings
            // 10.0.0.0    - 10.255.255.255
            // 172.16.0.0  - 172.31.255.255
            // 192.168.0.0 - 192.168.255.255
            // 169.254.0.0 - 169.254.255.255
            // 127.0.0.0   - 127.255.255.255

            ubyte[] ip_parts = ip.split(".").map!(ip_part => to!ubyte(ip_part)).array();
            return
                (ip_parts[0]==10) ||
                ((ip_parts[0]==172) && (ip_parts[1]>=16 && ip_parts[1]<=31)) ||
                (ip_parts[0]==192 && ip_parts[1]==168) ||
                (ip_parts[0]==169 && ip_parts[1]==254) ||
                (ip_parts[0]==127);
        }
    }

    private static string[] filterIPs(bool function(string ip) filter_func)
    {
        return filter!(ip => filter_func(ip))(getAllIPs()).array();
    }
}
