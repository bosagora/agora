/*******************************************************************************

    Contains tests for banning of unreachable nodes or in situations
    where timeouts fail or time-out.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.BanManager;

version (unittest):

import agora.common.crypto.Key;
import agora.common.Types;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.test.Base;
import core.thread;

/// test node banning after putTransaction fails a number of times
unittest
{
    const txs_to_nominate = 8;
    TestConf conf =
    {
        full_nodes : 1,
        retry_delay : 10.msecs,
        max_retries : 10,
        txs_to_nominate : txs_to_nominate,
        max_failed_requests : 4 * txs_to_nominate
    };

    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // 6 validators and 1 full node
    auto nodes = network.clients.array;
    auto gen_key = WK.Keys.Genesis;

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
             txes = last_txs.map!(tx => TxBuilder(tx).sign()).array();
             // keep track of last tx's to chain them to
             last_txs = txes[$ - 8 .. $];
             all_txs ~= txes;
         }
         return txes;
    }

    genBlockTransactions(1).each!(tx => nodes[0].putTransaction(tx));
    // wait until the transactions were gossiped
    network.expectBlock(Height(1));


    // full node will be banned if it cannot communicate
    // validators refuse to to send blocks
    nodes[0 .. GenesisValidators].each!(node => node.filter!(node.getBlocksFrom));
    auto full_node_idx = GenesisValidators;
    nodes[full_node_idx].filter!(nodes[full_node_idx].putTransaction); // full node won't receive transactions

    // leftover txs which full node will reject due to its filter
    Transaction[] left_txs;

    foreach (block_idx; 0 .. 4)
    {
        auto new_tx = genBlockTransactions(1);
        left_txs ~= new_tx;
        new_tx.each!(tx => nodes[0].putTransaction(tx));
        network.expectBlock(nodes[0 .. 4], Height(1 + block_idx + 1));
        retryFor(nodes[full_node_idx].getBlockHeight() == 1, 1.seconds,
            format!"Expected Full node height of exactly 1 not %s"(nodes[full_node_idx].getBlockHeight()));
    }

    // wait for full node to be banned and all putTransaction requests to time-out
    Thread.sleep(2.seconds);

    // sanity check: block height should not be updated, full node is not a validator and cannot make new blocks,
    // it may only add to its ledger through the getBlocksFrom() API.
    nodes[full_node_idx].clearFilter();
    left_txs.each!(tx => nodes[full_node_idx].putTransaction(tx));
    retryFor(nodes[full_node_idx].getBlockHeight() == 1, 1.seconds);

    // clear the filter
    nodes[0 .. GenesisValidators].each!(node => node.clearFilter());

    network.setTimeFor(Height(6));  // full node should be unbanned now

    auto new_tx = genBlockTransactions(1);
    left_txs ~= new_tx;
    new_tx.each!(tx => nodes[0].putTransaction(tx));
    network.expectBlock(Height(6));
}
