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
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.Genesis;
import agora.test.Base;

/// test enrollment process
unittest
{
    import std.algorithm;
    import std.conv;
    import core.time;

    auto network = makeTestNetwork(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.apis.values;
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
}
