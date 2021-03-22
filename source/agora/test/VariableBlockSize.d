/*******************************************************************************

    Tests creating blocks of arbitrary transaction counts.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.VariableBlockSize;

version (unittest):

import agora.api.Validator;
import agora.consensus.data.Transaction;
import agora.test.Base;

///
unittest
{
    const txs_to_nominate = 2;
    TestConf conf = { txs_to_nominate : txs_to_nominate };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto spendable = network.blocks[0].txs
        .filter!(tx => tx.type == TxType.Payment)
        .map!(tx => iota(tx.outputs.length)
            .map!(idx => TxBuilder(tx, cast(uint)idx)))
        .joiner().take(8).array;

    auto txs = spendable
        .map!(txb => txb.refund(WK.Keys.Genesis.address).sign())
        .array;

    foreach (block_idx, block_txs; txs.chunks(txs_to_nominate).enumerate)
    {
        block_txs.each!(tx => network.clients[0].putTransaction(tx));
        network.expectHeightAndPreImg(Height(block_idx + 1), network.blocks[0].header,
            5.seconds);
    }

    // 8 txs will create 4 blocks if we nominate 2 per block
    network.assertSameBlocks(Height(4));
}
