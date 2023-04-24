/*******************************************************************************

    Each block send double the txs

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

import agora.consensus.data.genesis.Test;
import agora.test.Base;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

mixin AddLogger!();

unittest
{
    TestConf conf;
    conf.node.test_validators = 4;
    conf.node.retry_delay = 1.msecs;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];
    const txsInBlockTarget = 100;
    Block last_block = cast(Block) node_1.getAllBlocks()[0];
    ulong txs_last_block = 8; // From Genesis
    while (txs_last_block  < txsInBlockTarget)
    {
        auto txs = last_block.spendable().map!(txb => txb.split(WK.Keys.byRange.take(2).map!(kp => kp.address)).sign());
        txs.each!(tx => node_1.postTransaction(tx));
        network.expectHeight(Height(node_1.getBlockHeight() + 1), 10.seconds);
        last_block = cast(Block) node_1.getBlock(node_1.getBlockHeight());
        txs_last_block = last_block.txs.walkLength;
        log.info("{} TXs in block {}", txs_last_block, last_block.header.height);
    }
}
