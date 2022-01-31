/*******************************************************************************

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.DNS;

version (unittest):

import agora.test.Base;
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

    FiberScheduler scheduler = new FiberScheduler;
    scheduler.start(
        () {
            auto addr = network.dns_resolver.resolve(Address("agora://boa1xzval2a3cdxv28n6slr62wlczslk3juvk7cu05qt3z55ty2rlfqfc6egsh2.validators.unittest.bosagora.io"));
            assert(addr.host.startsWith("10.0.0."));
        }
    );
}
