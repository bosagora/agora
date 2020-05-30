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

import std.typecons: Tuple;

version(unittest)
Tuple!(Transaction[], Enrollment[]) enrollValidators (T : TestAPIManager = TestAPIManager)(T network, bool[] not_enrolled_validators)
{
    assert(network.nodes.length == not_enrolled_validators.length);
    auto nodes = network.clients;
    auto node_1 = nodes[0];
    auto gen_key_pair = getGenesisKeyPair();

    Transaction[] txs;
    int tx_idx = 0;
    foreach (idx; 0 .. not_enrolled_validators.length)
    {
        if (!not_enrolled_validators[idx])
            continue;

        auto pubkey = nodes[idx].getPublicKey();
        auto input = Input(hashFull(GenesisTransaction), tx_idx.to!uint);

        Transaction tx =
        {
            TxType.Freeze,
            [input],
            [
                Output(Amount.MinFreezeAmount, pubkey),
                Output(Amount.MinFreezeAmount, gen_key_pair.address)
            ]
        };

        auto signature = gen_key_pair.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        txs ~= tx;

        tx_idx++;
    }

    foreach (idx; tx_idx .. Block.TxsInBlock)
    {
        auto input = Input(hashFull(GenesisTransaction), idx.to!uint);

        Transaction tx =
        {
            TxType.Freeze,
            [input],
            [
                Output(Amount.MinFreezeAmount, gen_key_pair.address),
                Output(Amount.MinFreezeAmount, gen_key_pair.address)
            ]
        };

        auto signature = gen_key_pair.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        txs ~= tx;
    }

    txs.each!(tx => node_1.putTransaction(tx));
    containSameBlocks(nodes, 1).retryFor(8.seconds);

    Enrollment[] enrolls;

    foreach (idx; 0 .. not_enrolled_validators.length)
    {
        if (!not_enrolled_validators[idx])
            continue;

        // create enrollment data
        Enrollment enroll = nodes[idx].createEnrollmentData();

        // send a request to enroll as a Validator
        node_1.enrollValidator(enroll);

        enrolls ~= enroll;
    }

    // make a block with height of 2
    Transaction[] txs2;
    foreach (idx; 0 .. Block.TxsInBlock)
    {
        auto input = Input(hashFull(txs[idx]), 1);

        Transaction tx =
        {
            TxType.Payment,
            [input],
            [
                Output(Amount.MinFreezeAmount, gen_key_pair.address)
            ]
        };

        auto signature = gen_key_pair.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        txs2 ~= tx;
    }
    txs2.each!(tx => node_1.putTransaction(tx));
    containSameBlocks(nodes, 2).retryFor(8.seconds);

    return Tuple!(Transaction[], Enrollment[])(txs2, enrolls);
}

/// test for  enrollment process & revealing a pre-image periodically
unittest
{
    TestConf conf =
    {
        topology : NetworkTopology.Simple,
        nodes : ValidateCountInGenesis + 1
    };

    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    bool[] not_enrolled_validators;
    foreach (idx; 0..ValidateCountInGenesis)
        not_enrolled_validators ~= false;
    not_enrolled_validators ~= true;

    auto res = enrollValidators(network, not_enrolled_validators);

    // Check if nodes have a pre-image newly sent
    // While the timer is running on the taskmanager
    foreach (enroll; res[1])
        nodes.each!(node =>
            retryFor(node.getPreimage(enroll.utxo_key) != PreImageInfo.init,
                10.seconds));
}
