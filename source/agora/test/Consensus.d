/*******************************************************************************

    Contains consensus tests for various types of quorum configurations.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Consensus;

version (unittest):

import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Hash;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXOSet;
import agora.consensus.Genesis;
import agora.test.Base;

/// test cyclic quorum config
unittest
{
    import std.algorithm;
    import std.range;
    import core.time;

    const NodeCount = 6;
    auto network = makeTestNetwork(NetworkTopology.Cyclic, NodeCount, true,
        100, 20, 100);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    assert(network.getDiscoveredNodes().length == NodeCount);

    auto nodes = network.apis.values;
    auto node_1 = nodes[0];

    auto txs = makeChainedTransactions(getGenesisKeyPair(), null, 1);
    txs.each!(tx => node_1.putTransaction(tx));
    containSameBlocks(nodes, 1).retryFor(5.seconds);
}
