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
import agora.common.Block;
import agora.common.Data;
import agora.common.Hash;
import agora.common.Transaction;
import agora.consensus.Genesis;
import agora.test.Base;

/// test node banning after putTransaction fails a number of times
unittest
{
    import core.thread;
    import vibe.core.log;
    import std.algorithm;
    import std.range;

    setLogLevel(LogLevel.info);
    const NodeCount = 2;

    const long retry_delay = 10;
    const size_t max_retries = 10;
    const long timeout = 10;
    const size_t max_failed_requests = 32;

    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount,
        true, retry_delay, max_retries, timeout, max_failed_requests);
    setLogLevel(LogLevel.info);
    network.start();

    auto keys = network.apis.keys;
    auto node_1 = network.apis[keys[0]];
    auto node_2 = network.apis[keys[1]];
    auto nodes = [node_1, node_2];
    auto gen_key = getGenesisKeyPair();

    Transaction[] all_txs;
    Transaction[] last_txs;

    // generate enough transactions to form 'count' blocks
    Transaction[] genBlockTransactions (size_t count)
    {
        auto txes = makeChainedTransactions(gen_key, last_txs, count);
        // keep track of last tx's to chain them to
        last_txs = txes[$ - Block.TxsInBlock .. $];
        all_txs ~= txes;
        return txes;
    }

    genBlockTransactions(1).each!(tx => node_1.putTransaction(tx));

    // wait until the transactions were gossiped
    containSameBlocks(nodes, 1).retryFor(3.seconds);

    node_1.filter!(node_1.getBlocksFrom);  // node 2 can't retrieve blocks
    node_2.filter!(node_2.putTransaction); // node 1 can't gossip transactions

    // node 2 will reject gossipping
    Transaction[] left_txs;

    auto new_tx = genBlockTransactions(1);
    left_txs ~= new_tx;
    new_tx.each!(tx => node_1.putTransaction(tx));
    Thread.sleep(500.msecs);

    new_tx = genBlockTransactions(1);
    left_txs ~= new_tx;
    new_tx.each!(tx => node_1.putTransaction(tx));
    Thread.sleep(500.msecs);

    new_tx = genBlockTransactions(1);
    left_txs ~= new_tx;
    new_tx.each!(tx => node_1.putTransaction(tx));
    Thread.sleep(500.msecs);

    new_tx = genBlockTransactions(1);
    left_txs ~= new_tx;
    new_tx.each!(tx => node_1.putTransaction(tx));
    Thread.sleep(500.msecs);
    assert(node_1.getBlockHeight() == 5);
    assert(node_2.getBlockHeight() == 1);

    node_2.clearFilter();
    left_txs.each!(tx => node_2.putTransaction(tx));  // manually add them
    Thread.sleep(500.msecs);
    assert(node_1.getBlockHeight() == 5);
    assert(node_2.getBlockHeight() == 5);

    new_tx = genBlockTransactions(1);
    left_txs ~= new_tx;
    new_tx.each!(tx => node_1.putTransaction(tx));
    Thread.sleep(500.msecs);
    assert(node_1.getBlockHeight() == 6);
    assert(node_2.getBlockHeight() == 5);  // filter is active

    left_txs.each!(tx => node_2.putTransaction(tx));  // manually add them again
    Thread.sleep(500.msecs);
    assert(node_1.getBlockHeight() == 6);
    assert(node_2.getBlockHeight() == 6);

    // now test that node 1 banned outbound communication with node 2
    // first clear the filter
    node_2.clearFilter();

    new_tx = genBlockTransactions(1);
    left_txs ~= new_tx;
    new_tx.each!(tx => node_1.putTransaction(tx));
    Thread.sleep(500.msecs);
    assert(node_1.getBlockHeight() == 7);
    assert(node_2.getBlockHeight() == 6);  // node was banned

    left_txs.each!(tx => node_2.putTransaction(tx));  // manually add them again
    Thread.sleep(500.msecs);
    assert(node_1.getBlockHeight() == 7);
    assert(node_2.getBlockHeight() == 7);

    FakeClockBanManager.time += 500;  // nodes should be unbanned now

    new_tx = genBlockTransactions(1);
    left_txs ~= new_tx;
    new_tx.each!(tx => node_1.putTransaction(tx));
    Thread.sleep(500.msecs);
    assert(node_1.getBlockHeight() == 8);
    assert(node_2.getBlockHeight() == 8);  // node was un-banned
}
