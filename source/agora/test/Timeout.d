/*******************************************************************************

    Tests connection timeouts

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Timeout;

version (unittest):

import agora.api.Validator;
import agora.consensus.data.Transaction;
import agora.test.Base;

///
unittest
{
    TestConf conf = {
        max_failed_requests : 1000, // never ban
    };
    conf.node.max_retries = 2;
    conf.node.retry_delay = 1.msecs;
    conf.node.timeout = 500.msecs;

    auto network = makeTestNetwork!TestAPIManager(conf);
    auto nodes = network.clients;

    nodes[$-1].ctrl.sleep(2.seconds, false);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
}
