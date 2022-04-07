/*******************************************************************************

    Contains tests for banning of unreachable nodes or in situations
    where timeouts fail or time-out.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.BanManager;

version (unittest):

import agora.test.Base;
import core.thread;

/// test node banning after postTransaction fails a number of times
unittest
{
    TestConf conf =
    {
        full_nodes : 1,
        max_failed_requests : 32,
    };
    conf.node.retry_delay = 10.msecs;
    conf.node.max_retries = 10;

    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // 6 validators and 1 full node
    auto nodes = network.clients.array;
    auto gen_key = WK.Keys.Genesis;
    auto full_node_idx = GenesisValidators;

    Transaction[] all_txs;
    Transaction[] last_txs;

    // generate enough transactions to form 'count' blocks
    Transaction[] genBlockTransactions (size_t count)
    {
        assert(count > 0);
        Transaction[] txes;

         if (!last_txs.length)
         {
             txes = genesisSpendable().map!(txb => txb.sign()).array();
             last_txs = txes[$ - 8 .. $];
             all_txs ~= last_txs;
             count--;
         }

         foreach (idx; 0 .. count)
         {
             txes = last_txs.map!(tx => new TxBuilder(tx).sign()).array();
             // keep track of last tx's to chain them to
             last_txs = txes[$ - 8 .. $];
             all_txs ~= txes;
         }
         return txes;
    }

    genBlockTransactions(1).each!(tx => nodes[0].postTransaction(tx));
    // wait until the transactions were gossiped
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    // wait till fullnode has received block 1
    retryFor(nodes[full_node_idx].getBlockHeight() == 1, 5.seconds,
            format!"Expected Full node height of exactly 1 not %s"(nodes[full_node_idx].getBlockHeight()));

    // full node will be banned if it cannot communicate
    // validators refuse to to send blocks
    nodes[0 .. GenesisValidators].each!(node => node.filter!(node.getBlocksFrom));
    nodes[full_node_idx].filter!(nodes[full_node_idx].postTransaction); // full node won't receive transactions

    // leftover txs which full node will reject due to its filter
    Transaction[] left_txs;

    foreach (block_idx; 0 .. 4)
    {
        auto new_tx = genBlockTransactions(1);
        left_txs ~= new_tx;
        new_tx.each!(tx => nodes[0].postTransaction(tx));
        network.expectHeightAndPreImg(iota(0, 4), Height(1 + block_idx + 1));
        retryFor(nodes[full_node_idx].getBlockHeight() == 1, 1.seconds,
            format!"Expected Full node height of exactly 1 not %s"(nodes[full_node_idx].getBlockHeight()));
    }

    // wait for full node to be banned and all postTransaction requests to time-out
    Thread.sleep(2.seconds);

    // sanity check: block height should not be updated, full node is not a validator and cannot make new blocks,
    // it may only add to its ledger through the getBlocksFrom() API.
    nodes[full_node_idx].clearFilter();
    left_txs.each!(tx => nodes[full_node_idx].postTransaction(tx));
    retryFor(nodes[full_node_idx].getBlockHeight() == 1, 1.seconds);

    // clear the filter
    nodes[0 .. GenesisValidators].each!(node => node.clearFilter());

    // Before setting the network time and adding transactions we need to ensure pre-images have been sent
    network.waitForPreimages(network.blocks[0].header.enrollments, Height(6));
    network.setTimeFor(Height(6));  // full node should be unbanned now

    auto new_tx = genBlockTransactions(1);
    left_txs ~= new_tx;
    new_tx.each!(tx => nodes[0].postTransaction(tx));
    network.expectHeight(Height(6));
}
