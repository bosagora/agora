/*******************************************************************************

    Tests the transaction replacement logic for double spend transactions.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.TransactionReplacement;

version (unittest):

import agora.api.Validator;
import agora.consensus.data.genesis.Test;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.test.Base;
import agora.utils.Test;

import core.thread.osthread : Thread;

///
unittest
{
    auto network = makeTestNetwork!TestAPIManager(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node0 = nodes[0];
    auto node1 = nodes[1];

    auto input_tx = GenesisBlock.txs.filter!(tx => tx.isPayment).front();
    Amount input_tx_amount = input_tx.outputs[0].value;
    auto output_addr = WK.Keys.AA.address;

    // create double spend transactions with fees 10000, 10100 .. 13000
    auto txs = [Amount(10000), Amount(10100), Amount(10200), Amount(11000), Amount(13000)]
        .map!(f => new TxBuilder(input_tx, 0).feeRate(f).draw(Amount(100_000), [output_addr])
        .sign()).array();

    // send the transaction with 10000 fee to node0
    nodes[0].postTransaction(txs[0]);

    // wait until the transaction propages to all nodes
    nodes.each!(node => node.hasTransactionHash(hashFull(txs[0])).retryFor(2.seconds));

    // send transactions with fee 10100, 10200, 11000 to node0
    txs[1 .. 4].each!(tx => node0.postTransaction(tx));

    // wait 2 seconds and make sure none of the nodes have those transactions
    Thread.sleep(2.seconds);
    txs[1 .. 4].each!(tx => nodes.each!(node => !node.hasTransactionHash(tx.hashFull())));

    // send a transaction with 13000s fee to node0
    nodes[0].postTransaction(txs[4]);

    // wait until the transaction propages to all nodes
    nodes.each!(node => node.hasTransactionHash(hashFull(txs[4])).retryFor(2.seconds));

    // wait until the first block is created and return it
    network.expectHeight(Height(1));
    const block = node1.getBlock(Height(1));

    // verify that the transaction with fee 13000 is the only one included in the block
    assert(block.txs.length == 1); // our transaction
    assert(block.txs.filter!(tx => tx.isPayment).front() == txs[4]);
}
