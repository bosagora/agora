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
    const b0 = nodes[0].getBlocksFrom(0, 2)[0];
    network.expectBlock(Height(8), b0.header,  5.seconds);

    // create block with 6 payment and 2 freeze tx's
    auto txs = network.blocks[$ - 1].spendable().map!(txb => txb.sign()).array();

    // rewrite 3rd to last tx to multiple outputs so we can create 8 spend tx's
    // in next block
    txs[$ - 3] = TxBuilder(network.blocks[$ - 1].txs[$ - 3])
        .split(WK.Keys.Genesis.address.repeat(3)).sign();

    // rewrite the last two tx's to be freeze tx's for our outsider validator nodes
    txs[$ - 2] = TxBuilder(network.blocks[$ - 1].txs[$ - 2])
        .draw(txs[$ - 2].outputs[0].value,
            iota(txs[$ - 2].outputs.length).map!(k => nodes[$ - 2].getPublicKey()))
        .sign(TxType.Freeze);
    txs[$ - 1] = TxBuilder(network.blocks[$ - 1].txs[$ - 1])
        .draw(txs[$ - 1].outputs[0].value,
            iota(txs[$ - 1].outputs.length).map!(k => nodes[$ - 1].getPublicKey()))
        .sign(TxType.Freeze);
    txs.each!(tx => nodes[0].putTransaction(tx));

    // at block height 9 the freeze tx's are available
    network.expectBlock(Height(9), b0.header, 5.seconds);

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

    auto new_txs = txs.map!(tx => TxBuilder(tx).sign()).array();
    // the last 3 tx's must refer to the outputs in txs[$ - 3] before
    new_txs[$ - 3] = TxBuilder(txs[$ - 3], 0)
        .split(WK.Keys.Genesis.address.only()).sign();
    new_txs[$ - 2] = TxBuilder(txs[$ - 3], 1)
        .split(WK.Keys.Genesis.address.only()).sign();
    new_txs[$ - 1] = TxBuilder(txs[$ - 3], 2)
        .split(WK.Keys.Genesis.address.only()).sign();
    new_txs.each!(tx => nodes[0].putTransaction(tx));

    // at block height 10 the validator set has changed
    network.expectBlock(Height(10), b0.header, 3.seconds);

    //// these are un-enrolled now
    nodes[0 .. $ - 2].each!(node => node.sleep(10.minutes, true));

    // verify that consensus can still be reached by the leftover validators
    txs = new_txs.map!(tx => TxBuilder(tx).sign()).array();
    txs.each!(tx => nodes[$ - 2].putTransaction(tx));

    const b10 = nodes[$ - 2].getBlocksFrom(10, 2)[0];
    network.expectBlock(nodes[$ - 2 .. $], Height(11), b10.header, 3.seconds);

    // force wake up
    nodes[0 .. $ - 2].each!(node => node.sleep(0.seconds, false));

    // all nodes should have same block height now
    network.expectBlock(Height(11), b10.header, 10.seconds);
}
