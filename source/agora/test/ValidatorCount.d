/*******************************************************************************

    The creation of a block must stop immediately just before all the
    active validators is expired.
    This is to allow additional enrollment of validators.
    Enrollment's cycle is `ConsensusParams.validator_cycle`,
    If none of the active validators exist at height `validator_cycle`,
    block generation must stop at height `validator_cycle`-1.

    This code tests these.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.ValidatorCount;

version (unittest):

import agora.consensus.data.ConsensusParams;
import agora.consensus.data.Transaction;
import agora.consensus.Genesis;
import agora.test.Base;

import core.thread;

/// ditto
unittest
{
    auto validator_cycle = 20;
    auto params = new immutable(ConsensusParams)(validator_cycle);

    auto network = makeTestNetwork(TestConf.init, params);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto gen_key_pair = WK.Keys.Genesis;

    Transaction[] txs;

    // create validator_cycle - 1 blocks
    foreach (block_idx; 1 .. validator_cycle)
    {
        // create enough tx's for a single block
        txs = makeChainedTransactions(gen_key_pair, txs, 1);

        // send it to one node
        txs.each!(tx => node_1.putTransaction(tx));

        containSameBlocks(nodes, block_idx).retryFor(5.seconds);
    }

    // Block will not be created because otherwise there would be no active validators
    {
        txs = makeChainedTransactions(gen_key_pair, txs, 1);
        txs.each!(tx => node_1.putTransaction(tx));
    }

    Thread.sleep(2.seconds);  // wait for propagation

    // New block was not created because all validators would expire
    containSameBlocks(nodes, validator_cycle - 1).retryFor(5.seconds);
}
