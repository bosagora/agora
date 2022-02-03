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
import geod24.LocalRest;
import geod24.concurrency;

/// DNS test
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

    Message query;

    // Query for SOA record
    auto name = Domain.fromSafeString("validators.unittest.bosagora.io.");
    query.questions ~= Question(name, QTYPE.SOA, QCLASS.IN);
    query.fill(query.header);
    auto result = resolver.query(query);
    assert(result.length == 1);
    assert(result[0].name == name);
    assert(result[0].type == TYPE.SOA);
    assert(result[0].rdata.soa.mname == Domain.fromSafeString("name.registry."));
    assert(result[0].rdata.soa.rname == Domain.fromSafeString("test.testnet."));

    // Query for NS record
    query.questions[0].qtype = QTYPE.NS;
    result = resolver.query(query);
    assert(result.length == 1);
    assert(result[0].type == TYPE.NS);
    assert(result[0].rdata.name == Domain.fromSafeString("name.registry."));

    // A record
    auto node_name = Domain.fromString(node_addr ~ ".validators.unittest.bosagora.io.");
    query.questions[0] = Question(node_name, QTYPE.A, QCLASS.IN);
    result = resolver.query(query);
    assert(result.length == 1);
    assert(result[0].type == TYPE.A);

    // CNAME record
    query.questions[0].qtype = QTYPE.CNAME;
    result = resolver.query(query);
    assert(result.length == 0);

    // AXFR zone transfer
    query.questions[0] = Question(name, QTYPE.AXFR, QCLASS.IN);
    result = resolver.query(query);
    // + 2 for starting and ending SOA records
    assert(result.length == conf.node.test_validators + 2);
    assert(result[0].type == TYPE.SOA);
    assert(result[$-1].type == TYPE.SOA);
}
