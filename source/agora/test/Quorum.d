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
import agora.consensus.data.Params;
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
        outsider_validators : 2,
        extra_blocks: GenesisValidatorCycle - 2 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    const b0 = nodes[0].getBlocksFrom(0, 2)[0];

    Height expected_block = Height(conf.extra_blocks);
    network.expectBlock(expected_block++, b0.header);

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

    // at block height 19 the freeze tx's are available
    network.expectBlock(expected_block++, b0.header);

    // now we can create enrollments
    Enrollment enroll_0 = nodes[$ - 2].createEnrollmentData();
    Enrollment enroll_1 = nodes[$ - 1].createEnrollmentData();
    nodes[$ - 2].enrollValidator(enroll_0);
    nodes[$ - 1].enrollValidator(enroll_1);

    // check enrollments
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getEnrollment(enroll_0.utxo_key) == enroll_0, 5.seconds,
            format!"Node #%s: failed to getEnrollment for enroll_0"(idx)));

    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getEnrollment(enroll_1.utxo_key) == enroll_1, 5.seconds,
            format!"Node #%s: failed to getEnrollment for enroll_1"(idx)));

    auto new_txs = txs.map!(tx => TxBuilder(tx).sign()).array();
    // the last 3 tx's must refer to the outputs in txs[$ - 3] before
    new_txs[$ - 3] = TxBuilder(txs[$ - 3], 0)
        .split(WK.Keys.Genesis.address.only()).sign();
    new_txs[$ - 2] = TxBuilder(txs[$ - 3], 1)
        .split(WK.Keys.Genesis.address.only()).sign();
    new_txs[$ - 1] = TxBuilder(txs[$ - 3], 2)
        .split(WK.Keys.Genesis.address.only()).sign();
    new_txs.each!(tx => nodes[0].putTransaction(tx));

    // at block height 20 the validator set has changed
    network.expectBlock(expected_block++, b0.header);

    //// these are un-enrolled now
    nodes[0 .. $ - 2].each!(node => node.sleep(10.minutes, true));

    // verify that consensus can still be reached by the leftover validators
    txs = new_txs.map!(tx => TxBuilder(tx).sign()).array();
    txs.each!(tx => nodes[$ - 2].putTransaction(tx));

    const b10 = nodes[$ - 2].getBlocksFrom(10, 2)[0];
    network.expectBlock(nodes[$ - 2 .. $], expected_block, b10.header);

    // force wake up
    nodes[0 .. $ - 2].each!(node => node.sleep(0.seconds, false));

    // all nodes should have same block height now
    network.expectBlock(expected_block, b10.header);
}
