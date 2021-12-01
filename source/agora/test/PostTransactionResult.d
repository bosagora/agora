/*******************************************************************************

    Contains tests for the result of posting transactions which can be one
    of these status: `Accepted``, `Duplicated`, and `Rejected`.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.PostTransactionResult;

version (unittest):

import agora.api.Validator;
import agora.consensus.data.genesis.Test;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.test.Base;
import agora.utils.Test;

import core.thread.osthread : Thread;
import std.algorithm.searching;

/// test for posting transactions, waiting for the various results
unittest
{
    TestConf conf = TestConf.init;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto input_txs = GenesisBlock.txs.filter!(tx => tx.isPayment).array;
    auto output_addr = WK.Keys.AA.address;

    // create a transaction with the fee rate of 10000
    auto tx = TxBuilder(input_txs[0], 0).feeRate(Amount(10_000))
        .draw(Amount(100_000), [output_addr])
        .sign();

    // post the transaction, expect `Accepted`
    auto result = nodes[0].postTransaction(tx);
    assert(result == TransactionResult(TransactionResult.Status.Accepted));

    // post the same transaction again, expect `Duplicated`
    result = nodes[0].postTransaction(tx);
    assert(result == TransactionResult(TransactionResult.Status.Duplicated));

    // post a transaction with no fee, expect `Rejected`
    tx = TxBuilder(input_txs[0], 1).feeRate(Amount(0))
        .draw(Amount(100_000), [output_addr])
        .sign();
    result = nodes[0].postTransaction(tx);
    assert(result.status == TransactionResult.status.Rejected);
    assert(!result.reason.find("Fee rate is less than minimum").empty);
}
