/*******************************************************************************
    Contains crawling related data types.

    These types are used in the FullNode API, hence are separated from types
    in Crawler.d to reduce compilation dependencies.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.CrawlerTypes;

import agora.common.Types : Address, Height, TimePoint;
import agora.serialization.Serializer;

import std.algorithm : each;
import std.range : iota;
import std.traits : KeyType, ValueType;

/// Result obtained by crawling a particular node
public struct CrawlResult
{
    ///
    public string continent;

    ///
    public string country;

    ///
    public string city;

    /// Latitude coordinates of the node
    public string latitude;

    /// Longitude coordinates of the node
    public string longitude;

    /// The time the crawling result
    public TimePoint crawl_time;

    /// Operating system the node is running on
    public string os;

    /// Name of the client
    public string client_name;

    /// Version of the client
    public string client_ver;

    /// Blockchain height known to the client
    public Height height;

    /// true if the network protocol is IPv4
    public bool is_ipv4;
}

/// Crawling results for all the nodes that are directly or indirectly reachable
/// from this node. Special serialize/fromBinary methods are provided, because
/// the current binary serializer cannot deal with associative arrays.
public struct CrawlResultHolder
{
    /// Results for all the nodes that are directly or indirectly reachable
    /// from this node
    public CrawlResult[Address] crawl_results;

    ///
    alias crawl_results this;

    ///
    public void serialize (scope SerializeDg dg) const @safe
    {
        serializePart!ulong(crawl_results.length, dg);
        foreach (const ref key, const ref value; crawl_results)
        {
            serializePart(key, dg);
            serializePart(value, dg);
        }
    }

    ///
    public static CrawlResultHolder fromBinary (CrawlResultHolder)
        (scope DeserializeDg dg, in DeserializerOptions opts) @safe
    {
        alias CRT = typeof(CrawlResultHolder.crawl_results);
        CRT crawl_results;

        iota(deserializeFull!(ulong)(dg, opts)).each!( _ =>
            crawl_results[deserializeFull!(KeyType!CRT)(dg, opts)] =
                deserializeFull!(ValueType!CRT)(dg, opts)
        );
        return CrawlResultHolder(crawl_results);
    }

    unittest
    {
        CrawlResultHolder crawl_result_holder;
        CrawlResult crawl_result;
        crawl_result.continent = "Asia";
        crawl_result_holder["a"] = crawl_result;
        crawl_result.continent = "Europe";
        crawl_result_holder["z"] = crawl_result;

        testSymmetry(crawl_result_holder);
    }
}
