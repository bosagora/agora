/*******************************************************************************

    Tests for the transaction-level absolute time lock.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.LockHeight;

version (unittest):

import agora.api.Validator;
import agora.consensus.data.Transaction;
import agora.test.Base;

/// Ditto
unittest
{
    TestConf conf = TestConf.init;
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // height 1
    auto txs = genesisSpendable().map!(txb => txb.sign()).array();
    txs.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(1), network.blocks[0].header);

    const Height UnlockHeight_2 = Height(2);
    auto unlock_2_txs = txs.map!(tx => TxBuilder(tx).sign(TxType.Payment,
        null, UnlockHeight_2)).array();

    const Height UnlockHeight_3 = Height(3);
    auto unlock_3_txs = txs.map!(tx => TxBuilder(tx).sign(TxType.Payment,
        null, UnlockHeight_3)).array();

    assert(unlock_2_txs != unlock_3_txs);

    // these should all be rejected, or alternatively accepted by the pool but
    // not added to the block at height 2
    unlock_3_txs.each!(tx => node_1.putTransaction(tx));

    // should be accepted
    unlock_2_txs.each!(tx => node_1.putTransaction(tx));

    network.expectBlock(Height(2), network.blocks[0].header);

    auto blocks = node_1.getBlocksFrom(2, 1);
    assert(blocks.length == 1);

    sort(unlock_2_txs);
    assert(blocks[0].txs == unlock_2_txs);
}
