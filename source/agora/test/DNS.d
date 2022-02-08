/*******************************************************************************

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.DNS;

version (unittest):

import agora.common.DNS;
import agora.test.Base;
import agora.utils.WellKnownKeys;

import core.thread;

import geod24.LocalRest;
import geod24.concurrency;

/// Primary registry test
unittest
{
    TestConf conf;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    const node_addr = NODE2.address.toString;

    auto resolver = network.makeDNSResolver([ Address("dns://10.8.8.8") ]);
    auto addr = resolver.resolve(
        Address("agora://" ~ node_addr ~ ".validators.unittest.bosagora.io"));
    assert(addr.host.startsWith("10.0.0."));

    // Query for SOA record
    auto result = resolver.query("validators.unittest.bosagora.io.", QTYPE.SOA);
    assert(result.length == 1);
    assert(result[0].name == Domain.fromSafeString("validators.unittest.bosagora.io."));
    assert(result[0].type == TYPE.SOA);
    assert(result[0].rdata.soa.mname == Domain.fromSafeString("name.registry."));
    assert(result[0].rdata.soa.rname == Domain.fromSafeString("test.testnet."));

    // Query for NS record
    result = resolver.query("validators.unittest.bosagora.io.", QTYPE.NS);
    assert(result.length == 1);
    assert(result[0].type == TYPE.NS);
    assert(result[0].rdata.name == Domain.fromSafeString("name.registry."));

    // A record
    result = resolver.query(node_addr ~ ".validators.unittest.bosagora.io.", QTYPE.A);
    assert(result.length == 1);
    assert(result[0].type == TYPE.A);

    // URI record
    result = resolver.query("_agora._tcp." ~ node_addr ~ ".validators.unittest.bosagora.io.", QTYPE.URI);
    assert(result.length == 1);
    assert(result[0].type == TYPE.URI);

    // CNAME record
    result = resolver.query(node_addr ~ ".validators.unittest.bosagora.io.", QTYPE.CNAME);
    assert(result.length == 0);

    // AXFR zone transfer
    result = resolver.query("validators.unittest.bosagora.io.", QTYPE.AXFR);
    // * 2 for URI records and + 2 for starting and ending SOA records
    assert(result.length == (conf.node.test_validators * 2) + 2);
    assert(result[0].type == TYPE.SOA);
    assert(result[$-1].type == TYPE.SOA);
}

// Secondary registry test
unittest
{
    import std.stdio : writeln;
    TestConf conf = {
        create_secondary_registry: true,
    };
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    const node_addr = NODE2.address.toString;

    // Allow some nodes to register and secondary to zone transfer
    Thread.sleep(2.seconds);

    auto resolver = network.makeDNSResolver([ Address("dns://10.8.8.9") ]);
    auto addr = resolver.resolve(
        Address("agora://" ~ node_addr ~ ".validators.unittest.bosagora.io"));
    assert(addr.host.startsWith("10.0.0."));

    // Query for SOA record
    auto result = resolver.query("validators.unittest.bosagora.io.", QTYPE.SOA);
    assert(result.length == 1);
    assert(result[0].name == Domain.fromSafeString("validators.unittest.bosagora.io."));
    assert(result[0].type == TYPE.SOA);
    assert(result[0].rdata.soa.mname == Domain.fromSafeString("name.registry."));
    assert(result[0].rdata.soa.rname == Domain.fromSafeString("test.testnet."));

    // A record
    result = resolver.query(node_addr ~ ".validators.unittest.bosagora.io.", QTYPE.A);
    assert(result.length == 1);
    assert(result[0].type == TYPE.A);

    // URI record
    result = resolver.query("_agora._tcp." ~ node_addr ~ ".validators.unittest.bosagora.io.", QTYPE.URI);
    assert(result.length == 1);
    assert(result[0].type == TYPE.URI);

    // CNAME record
    result = resolver.query(node_addr ~ ".validators.unittest.bosagora.io.", QTYPE.CNAME);
    assert(result.length == 0);

    // AXFR zone transfer
    result = resolver.query("validators.unittest.bosagora.io.", QTYPE.AXFR);
    // * 2 for URI records and + 2 for starting and ending SOA records
    assert(result.length == (conf.node.test_validators * 2) + 2);
    assert(result[0].type == TYPE.SOA);
    assert(result[$-1].type == TYPE.SOA);
}

// Caching registry test
unittest
{
    import std.stdio : writeln;
    TestConf conf = {
        create_caching_registry: true,
    };
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    const node_addr = NODE2.address.toString;

    // Allow some nodes to register
    Thread.sleep(2.seconds);

    auto resolver = network.makeDNSResolver([ Address("dns://10.8.8.10") ]);
    auto addr = resolver.resolve(
        Address("agora://" ~ node_addr ~ ".validators.unittest.bosagora.io"));
    assert(addr.host.startsWith("10.0.0."));

    // Query for SOA record
    auto result = resolver.query("validators.unittest.bosagora.io.", QTYPE.SOA);
    assert(result.length == 1);
    assert(result[0].name == Domain.fromSafeString("validators.unittest.bosagora.io."));
    assert(result[0].type == TYPE.SOA);
    assert(result[0].rdata.soa.mname == Domain.fromSafeString("name.registry."));
    assert(result[0].rdata.soa.rname == Domain.fromSafeString("test.testnet."));

    // A record
    result = resolver.query(node_addr ~ ".validators.unittest.bosagora.io.", QTYPE.A);
    assert(result.length == 1);
    assert(result[0].type == TYPE.A);

    // URI record
    result = resolver.query("_agora._tcp." ~ node_addr ~ ".validators.unittest.bosagora.io.", QTYPE.URI);
    assert(result.length == 1);
    assert(result[0].type == TYPE.URI);

    // CNAME record
    result = resolver.query(node_addr ~ ".validators.unittest.bosagora.io.", QTYPE.CNAME);
    assert(result.length == 0);

    // AXFR zone transfer
    result = resolver.query("validators.unittest.bosagora.io.", QTYPE.AXFR);
    // Only authoritative zones are capable to do AXFR zone transfer, thus
    // caching zone returns error, `query` return null when zone errors
    assert(result is null);
}
