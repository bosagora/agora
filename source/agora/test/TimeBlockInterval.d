/*******************************************************************************

    Tests behavior of `block_interval_sec`

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.TimeBlockInterval;

version (unittest):

import agora.api.Validator;
import agora.common.Hash;
import agora.consensus.data.Transaction;
import agora.test.Base;

///
unittest
{
    TestConf conf = { txs_to_nominate : 2, block_interval_sec : 10 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto spendable = network.blocks[0].txs
        .filter!(tx => tx.type == TxType.Payment)
        .map!(tx => iota(tx.outputs.length)
            .map!(idx => TxBuilder(tx, cast(uint)idx)))
        .joiner().take(8).array;

    auto txs = spendable
        .map!(txb => txb.refund(WK.Keys.Genesis.address).sign())
        .array;

    // 8 transactions is enough for 4 blocks with 2 txs each
    txs.each!(tx => nodes[0].putTransaction(tx));

    // wait for propagation
    nodes.each!(node =>
       txs.each!(tx =>
           node.hasTransactionHash(hashFull(tx)).retryFor(4.seconds)
    ));

    // time updated, block height 1
    const b0 = nodes[0].getBlocksFrom(0, 2)[0];

    void checkHeight(Height height)
    {
        network.waitForPreimages(b0.header.enrollments,
            cast(ushort) (height - 1), 30.seconds);
        network.setTimeFor(height);
        network.assertSameBlocks(height);
    }

    // Check for adding blocks 1 to 4
    [1, 2, 3, 4].each!(h => checkHeight(Height(h)));
}
