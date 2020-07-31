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
        validators : 2,
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

    // three nodes, two validators, and 1 non-validator
    auto node_1 = network.nodes[0].client;
    auto node_2 = network.nodes[1].client;
    auto node_3 = network.nodes[2].client;  // non-validator
    auto nodes = [node_1, node_2, node_3];
    auto gen_key = WK.Keys.Genesis;

    Transaction[] all_txs;
    Transaction[] last_txs;

    // generate enough transactions to form 'count' blocks
    Transaction[] genBlockTransactions (size_t count)
    {
        auto txes = makeChainedTransactions(gen_key, last_txs, count);
        // keep track of last tx's to chain them to
        last_txs = txes[$ - 8 .. $];
        all_txs ~= txes;
        return txes;
    }

    genBlockTransactions(1).each!(tx => node_1.putTransaction(tx));
    // wait until the transactions were gossiped
    network.expectBlock(Height(1), 3.seconds);


    // node 3 will be banned if it cannot communicate
    node_1.filter!(node_1.getBlocksFrom);  // node 1 refuses to send blocks
    node_2.filter!(node_2.getBlocksFrom);  // node 2 refuses to send blocks
    node_3.filter!(node_3.putTransaction); // node 3 won't receive transactions

    // leftover txs which node 3 will reject due to its filter
    Transaction[] left_txs;

    foreach (block_idx; 0 .. 4)
    {
        auto new_tx = genBlockTransactions(1);
        left_txs ~= new_tx;
        new_tx.each!(tx => node_1.putTransaction(tx));
        network.expectBlock([node_1, node_2], Height(1 + block_idx + 1), 4.seconds);
        retryFor(node_3.getBlockHeight() == 1, 1.seconds, node_3.getBlockHeight().to!string);
    }

    // wait for node 3 to be banned and all putTransaction requests to time-out
    Thread.sleep(2.seconds);

    // sanity check: block height should not be updated, node 3 is not a validator and cannot make new blocks,
    // it may only add to its ledger through the getBlocksFrom() API.
    node_3.clearFilter();
    left_txs.each!(tx => node_3.putTransaction(tx));
    retryFor(node_3.getBlockHeight() == 1, 1.seconds);

    // clear the filter
    node_1.clearFilter();
    node_2.clearFilter();

    FakeClockBanManager.time += 500;  // node 3 should be unbanned now

    auto new_tx = genBlockTransactions(1);
    left_txs ~= new_tx;
    new_tx.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(6), 4.seconds);
}
