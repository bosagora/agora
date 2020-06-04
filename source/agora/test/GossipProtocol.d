/*******************************************************************************

    Contains tests for Gossip Protocol.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.GossipProtocol;

version (unittest):

import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.common.Types;
import agora.common.Hash;
import agora.consensus.data.Transaction;
import agora.consensus.Genesis;
import agora.test.Base;

///
unittest
{
    auto network = makeTestNetwork(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // Enroll validators without enrollment data in genesis block.
    // If more than one is enrolled then two blocks are added,
    // otherwise, no blocks are added.
    auto enrolls = enrollValidators(iota(0, nodes.length)
        .filter!(idx => idx >= ValidateCountInGenesis)
        .map!(idx => nodes[idx])
        .array);
    ulong base_height = enrolls.length ? 2 : 0;
    containSameBlocks(nodes, base_height).retryFor(3.seconds);

    Transaction[] last_txs;
    // create enough tx's for a single block
    auto txs = makeChainedTransactions(getGenesisKeyPair(), last_txs, 1);

    auto send_txs = txs[0..$-1];
    // send it to tx to node
    send_txs.each!(tx => node_1.putTransaction(tx));
    // gossip was complete
    nodes.each!(node =>
       send_txs.each!(tx =>
           node.hasTransactionHash(hashFull(tx)).retryFor(2.seconds)
    ));
    // When a block is created, the transaction is deleted from the transaction pool.
    node_1.putTransaction(txs[$-1]);
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == base_height + 1,
        2.seconds,
        format("Node %s has block height %s. Expected: %s",
        idx,
        node.getBlockHeight(),
        base_height + 1)));

    nodes.each!(node =>
        txs.each!(tx =>
            (!node.hasTransactionHash(hashFull(tx))).retryFor(2.seconds)));
}

/// test gossiping behavior for an outsider node
unittest
{
    // node #5 is the outsider, so total foreign nodes may be 4
    TestConf conf = { nodes : 4, max_listeners : 4,
        topology : NetworkTopology.OneFullNodeOutsider };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    import core.thread;
    Thread.sleep(2.seconds);  // registerListener() can take a while..

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto txs = makeChainedTransactions(getGenesisKeyPair(), null, 1);

    auto send_txs = txs[0 .. $ - 1];  // 1 short of making a block (don't start consensus)
    send_txs.each!(tx => node_1.putTransaction(tx));
    nodes.each!(node =>
       send_txs.each!(tx =>
           node.hasTransactionHash(hashFull(tx)).retryFor(5.seconds)
    ));
}
