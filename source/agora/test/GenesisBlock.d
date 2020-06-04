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
import agora.consensus.Genesis;
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

    // Enroll validators without enrollment data in genesis block.
    // If more than one is enrolled then two blocks are added,
    // otherwise, no blocks are added.
    auto enrolls = enrollValidators(iota(0, nodes.length)
        .filter!(idx => idx >= ValidateCountInGenesis)
        .map!(idx => nodes[idx])
        .array);
    ulong base_height = enrolls.length ? 2 : 0;
    containSameBlocks(nodes, base_height).retryFor(3.seconds);

    nodes.all!(node => node.getBlocksFrom(0, 1)[0] == network.blocks[0])
        .retryFor(2.seconds);

    auto txes = makeChainedTransactions(getGenesisKeyPair(), null, 1);
    txes.each!(tx => node_1.putTransaction(tx));

    nodes.all!(node => node.getBlockHeight() == base_height + 1)
        .retryFor(2.seconds);
}
