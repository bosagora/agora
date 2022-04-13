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

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    nodes.each!(node => assert(node.getBlockHeight() == 0));

    // create enough tx's for a single block
    auto txs = genesisSpendable().map!(txb => txb.sign()).array();

    auto send_txs = txs[0..$-1];
    // send it to tx to node
    send_txs.each!(tx => node_1.postTransaction(tx));
    // gossip was complete
    nodes.each!(node =>
       send_txs.each!(tx =>
           node.hasAcceptedTxHash(hashFull(tx)).retryFor(2.seconds)
    ));
    // When a block is created, the transaction is deleted from the transaction pool.
    node_1.postTransaction(txs[$-1]);
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    nodes.each!(node =>
        txs.each!(tx =>
            (!node.hasTransactionHash(hashFull(tx))).retryFor(2.seconds)));
}

/// test gossiping behavior for an outsider node
unittest
{
    // node #7 is the fullnode

    // A Validator can only initiate connection, thus gossip TXs, to a FullNode
    // when FullNode address is expilicitly configured.
    TestConf conf = { full_nodes : 1, configure_network : true };
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto txs = genesisSpendable().map!(txb => txb.sign()).array();

    txs.each!(tx => node_1.postTransaction(tx));
    nodes.each!(node =>
       txs.each!(tx =>
           node.hasTransactionHash(hashFull(tx)).retryFor(5.seconds)
    ));
}
