/*******************************************************************************

    Tests connection timeouts

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
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
    TestConf conf = { retry_delay : 1.msecs,
        max_retries : 2,
        timeout : 500.msecs,
        max_failed_requests : 1000 };  // never ban
    auto network = makeTestNetwork(conf);
    auto nodes = network.clients;

    nodes[$-1].ctrl.sleep(2.seconds, false);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
}
