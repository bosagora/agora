/*******************************************************************************

    Contains various quorum tests, adding and expiring enrollments,
    making a network with many validators, etc.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Quorum;

version (unittest):

import agora.api.Validator;
import agora.common.Amount;
import agora.common.Config;
import agora.consensus.data.ConsensusParams;
import agora.common.crypto.Key;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.node.FullNode;
import agora.test.Base;

import std.algorithm;
import std.format;
import std.range;

import core.thread;
import core.time;

///
unittest
{
    TestConf conf = {
        validators : 4,
        outsider_validators : 2,
        max_listeners : 5,
        validator_cycle : 10,
        extra_blocks: 10 - 2,
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    network.expectBlock(Height(8), 5.seconds);

    Transaction makePayTx (in Transaction prev, PublicKey[] addresses, uint index = 0)
    {
        auto input = Input(hashFull(prev), index);

        Transaction tx =
        {
            TxType.Payment,
            [input],
            addresses.map!(addr => Output(Amount.MinFreezeAmount, addr)).array
        };

        auto signature = WK.Keys.Genesis.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        return tx;
    }

    Transaction makeFreezeTransaction (in Transaction prev, PublicKey address)
    {
        auto input = Input(hashFull(prev), 0);

        Transaction tx =
        {
            TxType.Freeze,
            [input],
            [Output(Amount.MinFreezeAmount, address)]
        };

        auto signature = WK.Keys.Genesis.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        return tx;
    }

    // create block with 6 payment and 2 freeze tx's
    auto txs = makeChainedTransactions(WK.Keys.Genesis,
        network.blocks[$ - 1].txs, 1);

    // rewrite 3rd to last tx to multiple outputs so we can create 8 spend tx's
    // in next block
    txs[$ - 3] = makePayTx(network.blocks[$ - 1].txs[$ - 3],
        [WK.Keys.Genesis.address, WK.Keys.Genesis.address,
        WK.Keys.Genesis.address]);

    // rewrite the last two tx's to be freeze tx's for our outsider validator nodes
    txs[$ - 2] = makeFreezeTransaction(network.blocks[$ - 1].txs[$ - 2],
        nodes[$ - 2].getPublicKey());
    txs[$ - 1] = makeFreezeTransaction(network.blocks[$ - 1].txs[$ - 1],
        nodes[$ - 1].getPublicKey());
    txs.each!(tx => nodes[0].putTransaction(tx));

    // at block height 9 the freeze tx's are available
    network.expectBlock(Height(9), 5.seconds);

    // now we can create enrollments
    Enrollment enroll_0 = nodes[$ - 2].createEnrollmentData();
    Enrollment enroll_1 = nodes[$ - 1].createEnrollmentData();
    nodes[2].enrollValidator(enroll_0);
    nodes[3].enrollValidator(enroll_1);

    // check enrollments
    nodes.each!(node =>
        retryFor(node.getEnrollment(enroll_0.utxo_key) == enroll_0 &&
                 node.getEnrollment(enroll_1.utxo_key) == enroll_1,
            5.seconds));

    auto new_txs = makeChainedTransactions(WK.Keys.Genesis, txs, 1);
    // the last 3 tx's must refer to the outputs in txs[$ - 3] before
    new_txs[$ - 3] = makePayTx(txs[$ - 3], [WK.Keys.Genesis.address], 0);
    new_txs[$ - 2] = makePayTx(txs[$ - 3], [WK.Keys.Genesis.address], 1);
    new_txs[$ - 1] = makePayTx(txs[$ - 3], [WK.Keys.Genesis.address], 2);
    new_txs.each!(tx => nodes[0].putTransaction(tx));

    // at block height 10 the validator set has changed
    network.expectBlock(Height(10), 3.seconds);

    //// these are un-enrolled now
    nodes[0 .. $ - 2].each!(node => node.sleep(10.minutes, true));

    // verify that consensus can still be reached by the leftover validators
    txs = makeChainedTransactions(WK.Keys.Genesis, new_txs, 1);
    txs.each!(tx => nodes[$ - 2].putTransaction(tx));

    network.expectBlock(nodes[$ - 2 .. $], Height(11), 3.seconds);

    // force wake up
    nodes[0 .. $ - 2].each!(node => node.sleep(0.seconds, false));

    // all nodes should have same block height now
    network.expectBlock(Height(11), 10.seconds);
}
