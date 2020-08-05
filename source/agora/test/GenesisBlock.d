/*******************************************************************************

    Test whether genesis block has enrollment data and
    existing Genesis Transactions

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.GenesisBlock;

version (unittest):

import agora.api.Validator;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.test.Base;

/// ditto
unittest
{
    auto network = makeTestNetwork(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    nodes.all!(node => node.getBlocksFrom(0, 1)[0] == network.blocks[0])
        .retryFor(2.seconds);

    auto txes = makeChainedTransactions(WK.Keys.Genesis, null, 1);
    txes.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(1), 2.seconds);
}
