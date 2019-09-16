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
import agora.consensus.Genesis;
import agora.test.Base;

/// test node banning after putTransaction fails a number of times
unittest
{
    import core.thread;
    import std.algorithm;
    import std.conv;
    import std.range;
    const NodeCount = 3;

    const long retry_delay = 10;
    const size_t max_retries = 10;
    const long timeout = 10;
    const size_t max_failed_requests = 4 * Block.TxsInBlock;

    auto network = makeTestNetwork(NetworkTopology.OneNonValidator, NodeCount, true,
        retry_delay, max_retries, timeout, max_failed_requests);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    assert(network.getDiscoveredNodes().length == NodeCount);

    // three nodes, two validators, and 1 non-validator
    auto keys = network.keys;
    auto node_1 = network.apis[keys[0]];
    auto node_2 = network.apis[keys[1]];
    auto node_3 = network.apis[keys[2]];  // non-validator
    auto nodes = [node_1, node_2, node_3];
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

    // node 3 will be banned if it cannot communicate
    node_1.filter!(node_1.getBlocksFrom);  // node 1 refuses to send blocks
    node_2.filter!(node_2.getBlocksFrom);  // node 2 refuses to send blocks
    node_3.filter!(node_3.putTransaction); // node 3 won't receive transactions

    // leftover txs which node 3 will reject due to its filter
    Transaction[] left_txs;

    auto new_tx = genBlockTransactions(4);
    left_txs ~= new_tx;
    new_tx.each!(tx => node_1.putTransaction(tx));

    // wait for node 3 to be banned and all putTransaction requests to time-out
    Thread.sleep(2.seconds);

    import std.conv;
    retryFor(node_1.getBlockHeight() == 5, 1.seconds, node_1.getBlockHeight().to!string);
    retryFor(node_2.getBlockHeight() == 5, 1.seconds, node_2.getBlockHeight().to!string);
    retryFor(node_3.getBlockHeight() == 1, 1.seconds, node_3.getBlockHeight().to!string);

    // clear putTransaction filter
    node_3.clearFilter();
    left_txs.each!(tx => node_3.putTransaction(tx));  // add leftover txs manually
    retryFor(node_3.getBlockHeight() == 5, 1.seconds);

    // node 3 should be banned by this point, now we test if it is really banned
    new_tx = genBlockTransactions(1);
    left_txs ~= new_tx;
    new_tx.each!(tx => node_1.putTransaction(tx));
    retryFor(node_1.getBlockHeight() == 6, 1.seconds);
    retryFor(node_2.getBlockHeight() == 6, 1.seconds);
    retryFor(node_3.getBlockHeight() == 5, 1.seconds);  // node was banned

    left_txs.each!(tx => node_3.putTransaction(tx));  // add leftover txs manually
    retryFor(node_1.getBlockHeight() == 6, 1.seconds);
    retryFor(node_2.getBlockHeight() == 6, 1.seconds);
    retryFor(node_3.getBlockHeight() == 6, 1.seconds);

    FakeClockBanManager.time += 500;  // node 3 should be unbanned now

    new_tx = genBlockTransactions(1);
    left_txs ~= new_tx;
    new_tx.each!(tx => node_1.putTransaction(tx));
    retryFor(node_1.getBlockHeight() == 7, 1.seconds);
    retryFor(node_2.getBlockHeight() == 7, 1.seconds);
    retryFor(node_3.getBlockHeight() == 7, 1.seconds);  // node was un-banned
}
