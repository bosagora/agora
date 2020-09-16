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
    TestConf conf = { txs_to_nominate : 2, block_interval_sec : 2 };
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
           node.hasTransactionHash(hashFull(tx)).retryFor(2.seconds)
    ));

    // time updated, block height 1
    const b0 = nodes[0].getBlocksFrom(0, 2)[0];
    network.setTimeFor(Height(1));
    network.waitForPreimages(b0.header.enrollments, 1, 2.seconds);
    ensureConsistency(nodes, 1);

    network.setTimeFor(Height(2));
    network.waitForPreimages(b0.header.enrollments, 2, 2.seconds);
    ensureConsistency(nodes, 2);

    network.setTimeFor(Height(3));
    network.waitForPreimages(b0.header.enrollments, 3, 2.seconds);
    ensureConsistency(nodes, 3);

    network.setTimeFor(Height(4));
    network.waitForPreimages(b0.header.enrollments, 4, 2.seconds);
    ensureConsistency(nodes, 4);
}
