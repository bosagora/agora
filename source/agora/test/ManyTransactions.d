/*******************************************************************************

    Run via:
    $ dtest=agora.test.ManyTransactions dub test

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.ManyTransactions;

version (unittest):

import agora.test.Base;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

mixin AddLogger!();

unittest
{
    TestConf conf;
    conf.consensus.quorum_threshold = 100;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    foreach (idx; 0 .. 2)
    {
        auto last_block = node_1.getBlock(node_1.getBlockHeight());
        log.trace("\nExternalized {} TXs at height {}", last_block.txs.length, last_block.header.height);
        auto txs = last_block.spendable().map!(txb => txb.split(WK.Keys.byRange.take(3).map!(kp => kp.address)).sign());
        txs.each!(tx => node_1.postTransaction(tx));
        log.trace("Sending {} TXs", txs.walkLength);
        network.expectHeight(Height(node_1.getBlockHeight() + 1), 10.seconds);
    }
    node_1.getBlocksFrom(1, 5).each!(b => log.trace("Block: {}", b.prettify));
}
