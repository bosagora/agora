/*******************************************************************************

    Tests the consensus algorithm on block timestamp creation

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.BlockTimeConsensus;

version (unittest):

import agora.api.Validator;
import agora.consensus.data.Transaction;
import agora.crypto.Hash;
import agora.test.Base;

///
unittest
{
    TestConf conf = { txs_to_nominate : 2, block_interval_sec : 2 };
    auto network = makeTestNetwork(conf);
    network.setTimeFor(Height(0));
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto txs = genesisSpendable().map!(txb => txb.sign()).take(8).array;

    // 8 transactions is enough for 4 blocks with 2 txs each
    txs.each!(tx => nodes[0].putTransaction(tx));

    // wait for propagation
    nodes.each!(node =>
       txs.each!(tx =>
           node.hasTransactionHash(hashFull(tx)).retryFor(2.seconds)
    ));

    const b0 = nodes[0].getBlocksFrom(0, 1)[0];
    auto start_time = network.nodes[0].time();

    void checkHeight(Height height)
    {
        network.waitForPreimages(b0.header.enrollments,
            cast(ushort) (height - 1));
        network.setTimeFor(height);
        network.assertSameBlocks(height);
        auto timestamp = nodes[0].getBlocksFrom(height, 1)[0].header.timestamp;
        assert( timestamp == start_time + (conf.block_interval_sec)*height, "actual time: " ~ to!string(timestamp));
    }

    // Check for adding blocks 1 to 4
    [1, 2, 3, 4].each!(h => checkHeight(Height(h)));
}
