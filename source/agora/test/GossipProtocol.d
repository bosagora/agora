/*******************************************************************************

    Contains tests for Gossip Protocol.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.GossipProtocol;

version (unittest):

import agora.common.Types;
import agora.crypto.Hash;
import agora.test.Base;

///
unittest
{
    TestConf conf = TestConf.init;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.nodes;
    auto node_1 = nodes[0];

    nodes.each!(node => assert(node.client.getBlockHeight() == 0));

    // create enough tx's for a single block
    auto txs = genesisSpendable().map!(txb => txb.sign()).array();

    auto send_txs = txs[0..$-1];
    // send it to tx to node
    send_txs.each!(tx => node_1.client.postTransaction(tx));
    // gossip was complete
    foreach (node; nodes)
       foreach (tx; send_txs)
            retryFor(node.client.hasAcceptedTxHash(hashFull(tx)), 2.seconds,
                format!"Node %s didn't accept TX hash %s"(node.address, hashFull(tx)));

    // When a block is created, the transaction is deleted from the transaction pool.
    node_1.client.postTransaction(txs[$-1]);
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    foreach (node; nodes)
        foreach (tx; txs)
            retryFor(!node.hasTransactionHash(hashFull(tx)), 2.seconds,
                format!"Node %s has TX hash %s"(node.address, hashFull(tx)));
}

/// test gossiping behavior for an outsider node
unittest
{
    // node #7 is the fullnode
    TestConf conf = { full_nodes : 1 };
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.nodes;
    auto node_1 = nodes[0];

    auto txs = genesisSpendable().map!(txb => txb.sign()).array();

    txs.each!(tx => node_1.client.postTransaction(tx));

    foreach (node; nodes)
        foreach (tx; txs)
           retryFor(node.client.hasTransactionHash(hashFull(tx)), 5.seconds,
               format!"Node %s doesn't have TX hash %s"(node.address, hashFull(tx)));
}
