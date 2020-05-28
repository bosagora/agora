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

/// test for  enrollment process & revealing a pre-image periodically
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

    // make a block with height of 2
    Transaction[] txs2;
    foreach (idx; 0 .. Block.TxsInBlock)
    {
        auto input = Input(hashFull(txs[idx]), 1);

        Transaction tx =
        {
            TxType.Payment,
            [input],
            [Output(Amount(100), gen_key_pair.address)]
        };

        auto signature = gen_key_pair.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        txs2 ~= tx;
    }
    txs2.each!(tx => node_1.putTransaction(tx));
    containSameBlocks(nodes, 2).retryFor(8.seconds);

    // Check if nodes have a pre-image newly sent
    // While the timer is running on the taskmanager
    nodes.each!(node =>
        retryFor(node.getPreimage(enroll.utxo_key) != PreImageInfo.init,
            10.seconds));
}

/// Situation: A node in the network crashes after enrolling as an validator.
///     And the node restarts before a new block containing the enrollment
///     information is created. And the block is created, and the enrollment
///     information of the new block is adding to the validator set.
/// Expectation: The node restores its own enrollment data when the block
///     containing the enrollment information arrives.
unittest
{
    import agora.consensus.validation.PreImage;
    import core.thread;
    import std.conv;

writeln("############################## start ##############################");
    auto network = makeTestNetwork(TestConf.init);
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.start();
    network.waitForDiscovery();

    // Boilerplate
    auto nodes = network.clients;
    auto gen_key_pair = getGenesisKeyPair();
    auto node_1 = nodes[0];
    auto pubkey_1 = node_1.getPublicKey();

    // Create a new block with frozen transactions so we can Enroll
    Transaction[] txs;
    {
        foreach (idx; 0 .. Block.TxsInBlock)
        {
            auto input = Input(hashFull(GenesisTransaction), idx.to!uint);
            Transaction tx =
                {
                    TxType.Freeze,
                    [input],
                    [Output(Amount.MinFreezeAmount, pubkey_1),
                        Output(Amount(10000), gen_key_pair.address)]
                };
            auto signature = gen_key_pair.secret.sign(hashFull(tx)[]);
            tx.inputs[0].signature = signature;
            txs ~= tx;
        }
        // Send all transactions to node 1 and rely on gossip
        txs.each!(tx => node_1.putTransaction(tx));
        // Make sure the block is created
        containSameBlocks(nodes, 1).retryFor(5.seconds);
    }

    // The nodes[0] register as validator
    auto enroll = node_1.createEnrollmentData();
    node_1.enrollValidator(enroll);
    nodes.each!(node =>
        retryFor(node.getEnrollment(enroll.utxo_key) == enroll, 5.seconds));

    // The `enroll` hasn't been validator yet so there must not be a pre-image
    assert(node_1.getPreimage(enroll.utxo_key) == PreImageInfo.init);

    // Check if the `node_1` restores block from the chain after restarting
    network.restart(node_1);
    network.waitForDiscovery();
    containSameBlocks(nodes, 1).retryFor(5.seconds);

    // Now make a second block, and check what's inside
    Transaction[] txs2;
    {
        foreach (idx; 0 .. Block.TxsInBlock)
        {
            auto input = Input(hashFull(txs[idx]), 1);

            Transaction tx =
            {
                TxType.Payment,
                [input],
                [Output(Amount(1000), gen_key_pair.address)]
            };

            auto signature = gen_key_pair.secret.sign(hashFull(tx)[]);
            tx.inputs[0].signature = signature;
            txs2 ~= tx;
        }
        txs2.each!(tx => node_1.putTransaction(tx));
        containSameBlocks(nodes, 2).retryFor(20.seconds);
    }

    // Check if the node had restored enrollment information
    // from the last `restart` of `node_1`
    const b2 = node_1.getBlocksFrom(2, 2)[0];
    assert(b2.header.enrollments.length == 1);
    assert(enroll == b2.header.enrollments[0]);

    // Check if the validator information had been stored from the second block.
    PreImageInfo org_preimage = PreImageInfo(enroll.utxo_key, enroll.random_seed, 0);
    PreImageInfo preimage_1 = node_1.getPreimage(enroll.utxo_key);
    assert(preimage_1 == org_preimage);

    // Wait for the timer for revelation of a pre-image to elaspe
    Thread.sleep(20.seconds);

    // Check if a new pre-image has been revealed from
    // the restarted node, or 'node_1'
    import agora.utils.PrettyPrinter;
    PreImageInfo preimage_2 = node_1.getPreimage(enroll.utxo_key);
    writeln(org_preimage.prettify());
    writeln(preimage_2.prettify());

    writeln("############################## end ##############################");
    assert(preimage_2 != org_preimage);
}
