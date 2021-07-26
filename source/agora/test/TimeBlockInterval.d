/*******************************************************************************

    Tests behavior of `block_interval_sec`

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.TimeBlockInterval;

version (unittest):

import agora.api.Validator;
import agora.consensus.data.Transaction;
import agora.crypto.Hash;
import agora.test.Base;

import std.range;
import std.algorithm;

///
unittest
{
    TestConf conf;
    conf.consensus.block_interval_sec = 10;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto node_1 = network.clients.front;

    auto startTime = node_1.getNetworkTime();
    // create 8 txs enough for 4 blocks with 2 txs each
    genesisSpendable.map!(txb =>
        txb.sign())
        .chunks(2).enumerate.each!((en) {
            en.value.each!(tx => node_1.putTransaction(tx));
            network.expectHeightAndPreImg(Height(en.index + 1));
        });
    assert(node_1.getNetworkTime() >= startTime + (4 * conf.consensus.block_interval_sec));
}
