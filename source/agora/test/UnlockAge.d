/*******************************************************************************

    Tests for the input-level relative time lock.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.UnlockAge;

version (unittest):

import agora.api.Validator;
import agora.consensus.data.Transaction;
import agora.test.Base;

import std.functional;

/// Ditto
unittest
{
    import std.conv;
    TestConf conf = TestConf.init;
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto txs = genesisSpendable().map!(txb => txb.split(
        WK.Keys.Genesis.address.repeat.take(8)).sign()).array;

    // height 1, many Outputs
    txs.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(1), network.blocks[0].header);

    auto split_up = txs
        .map!(tx => iota(tx.outputs.length)
            .map!(idx => TxBuilder(tx, cast(uint)idx))).array;

    // if `unlock_age` is 3 then UTXO at height `1` which unlocks at height `2`
    // will be spendable by this input at height `2 + 3 = 5`.
    auto txs_0 = split_up[0].map!(txb => txb.sign()).array;
    auto txs_1 = split_up[1].map!(txb => txb.sign()).array;
    auto txs_2 = split_up[2].map!(txb => txb.sign()).array;
    const uint UnlockAge_3 = 3;
    auto age_3_txs = split_up[3].map!(txb => txb.sign(TxType.Payment,
        null, toDelegate(&WK.Keys.opIndex), Height(0), UnlockAge_3)).array();

    age_3_txs.each!(tx => node_1.putTransaction(tx));  // rejected, wrong age
    txs_0.each!(tx => node_1.putTransaction(tx));      // accepted
    network.expectBlock(Height(2), network.blocks[0].header);
    auto blocks = node_1.getBlocksFrom(2, 1);
    assert(blocks.length == 1);
    sort(txs_0);
    assert(blocks[0].txs == txs_0);

    age_3_txs.each!(tx => node_1.putTransaction(tx));  // rejected again
    txs_1.each!(tx => node_1.putTransaction(tx));      // accepted
    network.expectBlock(Height(3), network.blocks[0].header);
    blocks = node_1.getBlocksFrom(3, 1);
    assert(blocks.length == 1);
    sort(txs_1);
    assert(blocks[0].txs == txs_1);

    age_3_txs.each!(tx => node_1.putTransaction(tx));  // rejected again
    txs_2.each!(tx => node_1.putTransaction(tx));      // accepted
    network.expectBlock(Height(4), network.blocks[0].header);
    blocks = node_1.getBlocksFrom(4, 1);
    assert(blocks.length == 1);
    sort(txs_2);
    assert(blocks[0].txs == txs_2);

    age_3_txs.each!(tx => node_1.putTransaction(tx));  // finally accepted
    network.expectBlock(Height(5), network.blocks[0].header);
    blocks = node_1.getBlocksFrom(5, 1);
    assert(blocks.length == 1);
    sort(age_3_txs);
    assert(blocks[0].txs == age_3_txs);
}
