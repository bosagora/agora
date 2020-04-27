/*******************************************************************************

    Contains tests for the creation of an enrollment data, enrolling as a
    validator and propagating the information through the network

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.EnrollmentManager;

version (unittest):

import agora.common.Amount;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.Genesis;
import agora.test.Base;

import std.algorithm;
import std.conv;
import core.time;

/// test enrollment process
unittest
{
    auto network = makeTestNetwork(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];
    auto node_2 = nodes[1];

    // make transactions which have UTXOs for the node.
    auto gen_key_pair = getGenesisKeyPair();
    auto pubkey_1 = node_1.getPublicKey();

    Transaction[] txs;
    foreach (idx; 0 .. Block.TxsInBlock)
    {
        auto input = Input(hashFull(GenesisTransaction), idx.to!uint);

        Transaction tx =
        {
            TxType.Freeze,
            [input],
            [Output(Amount.MinFreezeAmount, pubkey_1)]
        };

        auto signature = gen_key_pair.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        txs ~= tx;
    }
    txs.each!(tx => node_1.putTransaction(tx));
    containSameBlocks(nodes, 1).retryFor(8.seconds);

    // create enrollment data
    Enrollment enroll = node_1.createEnrollmentData();

    // send a request to enroll as a Validator
    node_1.enrollValidator(enroll);

    // check if nodes contains enrollment data previously sent.
    nodes.each!(node =>
        retryFor(node.hasEnrollment(enroll.utxo_key) == true, 5.seconds));

    // check if nodes don't have a pre-image yet
    nodes.each!(node =>
        retryFor(node.getPreimage(enroll.utxo_key) == PreImageInfo.init,
            5.seconds));

    // tests for revealing a pre-image
    node_1.broadcastPreimage(1000);

    // check if nodes have a pre-image previously sent
    nodes.each!(node =>
        retryFor(node.getPreimage(enroll.utxo_key) != PreImageInfo.init,
            5.seconds));
}

/// test for revealing a pre-image periodically
unittest
{
    auto network = makeTestNetwork(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];
    auto node_2 = nodes[1];

    // make transactions which have UTXOs for the node.
    auto gen_key_pair = getGenesisKeyPair();
    auto pubkey_1 = node_1.getPublicKey();

    Transaction[] txs;
    foreach (idx; 0 .. Block.TxsInBlock)
    {
        auto input = Input(hashFull(GenesisTransaction), idx.to!uint);

        Transaction tx =
        {
            TxType.Freeze,
            [input],
            [Output(Amount.MinFreezeAmount, pubkey_1),
                Output(Amount(100), gen_key_pair.address)]
        };

        auto signature = gen_key_pair.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        txs ~= tx;
    }
    txs.each!(tx => node_1.putTransaction(tx));
    containSameBlocks(nodes, 1).retryFor(8.seconds);

    // create enrollment data
    Enrollment enroll = node_1.createEnrollmentData();

    // send a request to enroll as a Validator
    node_1.enrollValidator(enroll);

    // check if nodes contains enrollment data previously sent.
    nodes.each!(node =>
        retryFor(node.hasEnrollment(enroll.utxo_key) == true, 5.seconds));

    // set enrolled height to all nodes
    // the addValidator function is actually called in the middle of
    // making block but now the code is not merged so calling it is needed.
    nodes.each!(node => node.addValidator(enroll, 1));

    // check if nodes don't have a validator's pre-image yet
    nodes.each!(node =>
        retryFor(node.getPreimage(enroll.utxo_key) == PreImageInfo.init,
            5.seconds));

    // make a block with height of 2
    Transaction[] txs2;
    foreach (idx; 0 .. Block.TxsInBlock)
    {
        auto input = Input(hashFull(txs[idx]), 1);

        Transaction tx =
        {
            TxType.Payment,
            [input],
            [Output(Amount(100), pubkey_1)]
        };

        auto signature = gen_key_pair.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        txs2 ~= tx;
    }
    txs2.each!(tx => node_1.putTransaction(tx));
    containSameBlocks(nodes, 2).retryFor(8.seconds);

    // check if nodes have a pre-image newly sent
    // during creating transactions for the new block
    nodes.each!(node =>
        retryFor(node.getPreimage(enroll.utxo_key) != PreImageInfo.init,
            5.seconds));
}
