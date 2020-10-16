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
        outsider_validators : 2 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.completeTestSetup();

    auto nodes = network.clients;
    auto set_a = nodes.take(genesis_validators);
    auto set_b = nodes.drop(genesis_validators).take(conf.outsider_validators);

    auto block = 18;
    // Get to height 18
    network.generateBlocks(Height(18));

    // Block 19 we add the freeze utxos for 2 outsider validators
    genesisSpendable().drop(1).takeExactly(1)
        .map!(txb => txb
            .split(WK.Keys.byRange.take(conf.outsider_validators).map!(k => k.address)).sign(TxType.Freeze))
        .each!(tx => nodes[0].putTransaction(tx));
    network.generateBlocks(Height(19));

    // wait for other nodes to get to same block height
    set_b.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == 19, 2.seconds,
            format!"[%s:%s] Expected block height %s but Outsider node %s has height %s."
                (__FILE__, __LINE__, 19, idx, node.getBlockHeight())));

    // Now we enroll set_b validators. In next cycle set_a will be expired.
    iota(genesis_validators, genesis_validators + conf.outsider_validators)
        .each!(idx => network.enroll(idx));

     // Block 20
    network.generateBlocks(Height(20));

    // wait for other nodes to get to same block height
    set_b.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == 20, 2.seconds,
            format!"[%s:%s] Expected block height %s but Outsider node %s has height %s."
                (__FILE__, __LINE__, 20, idx, node.getBlockHeight())));

    // Sanity check
    assert(network.blocks[20].header.enrollments.length == conf.outsider_validators, format!"Enrollments were not added to block 20"());
    assert(network.blocks[20].txs.length == 1, format!"There should be a transaction in block 20"());

    //// set_a are no longer enrolled now. We make them sleep to show they are not used.
    set_a.each!(node => node.sleep(10.minutes, true));

    // Block 21 with the new validators in set B
    network.generateBlocks(set_b, Height(21), Height(20));

    // force wake up
    nodes.take(genesis_validators).each!(node => node.sleep(0.seconds, false));

    // all nodes should have same block height now
    network.expectBlock(Height(21));
}
