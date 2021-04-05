/*******************************************************************************

    Contains tests for the functionality of the NetworkClient.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.NetworkClient;

version (unittest):

import agora.consensus.data.Block;
import agora.common.Types;
import agora.consensus.data.Transaction;
import agora.test.Base;

import core.thread;

/// test retrying requests after failure
unittest
{
    TestConf conf = TestConf.init;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // block periodic getBlocksFrom
    node_1.filter!(node_1.getBlocksFrom);

    // reject inbound requests
    nodes[1 .. $].each!(node => node.filter!(node.putTransaction));

    auto txes = genesisSpendable().map!(txb => txb.sign()).array();

    // node 1 will keep trying to send transactions up to
    // (max_retries * retry_delay) seconds (see Base.d)
    txes.each!(tx => node_1.putTransaction(tx));

    // clear filter after 100 msecs, the above requests will eventually be gossiped
    Thread.sleep(100.msecs);
    nodes[1 .. $].each!(node => node.clearFilter());
    network.expectHeight(Height(1));
}

/// test request timeouts
unittest
{
    TestConf conf = TestConf.init;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // block periodic getBlocksFrom
    node_1.filter!(node_1.getBlocksFrom);

    // reject inbound requests
    const DropRequests = true;
    nodes[1 .. $].each!(node => node.sleep(100.msecs, DropRequests));

    auto txes = genesisSpendable().map!(txb => txb.sign()).array();

    txes.each!(tx => node_1.putTransaction(tx));

    // node 1 will keep trying to send transactions up to
    // max_retries * (retry_delay + timeout) seconds (see Base.d),
    const delay = conf.max_retries * (conf.retry_delay + conf.timeout);
    network.expectHeight(Height(1), delay);
}
