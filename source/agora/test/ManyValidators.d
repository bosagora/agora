/*******************************************************************************

    Contains networking tests with a variety of different validator node counts.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.ManyValidators;

// temporarily disabled until failures are resolved
// see #1145
// version (none):

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

/// 16 nodes
unittest
{
    TestConf conf = { outsider_validators : 10 };

    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    // generate 18 blocks, 2 short of the enrollments expiring.
    network.generateBlocks(Height(GenesisValidatorCycle - 2));

    const keys = network.nodes.map!(node => node.client.getPublicKey())
        .drop(GenesisValidators).array;

    // prepare frozen outputs for outsider validators to enroll
    genesisSpendable().drop(1).takeExactly(1)
        .map!(txb => txb.split(keys).sign(TxType.Freeze))
        .each!(tx => nodes[0].putTransaction(tx));

    // block 19
    network.generateBlocks(Height(GenesisValidatorCycle - 1));

    // wait for other nodes to get to same block height
    nodes.drop(GenesisValidators).enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == GenesisValidatorCycle - 1, 2.seconds,
            format!"Expected block height %s but outsider %s has height %s."
                (GenesisValidatorCycle - 1, idx, node.getBlockHeight())));

    auto validators = GenesisValidators + conf.outsider_validators;

    // Now we enroll new validators and re-enroll the original validators
    iota(0, validators).each!(idx => network.enroll(idx));

    network.generateBlocks(nodes, Height(GenesisValidatorCycle));

    // check 16 validators are enrolled
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getValidatorCount() == validators, 5.seconds,
            format("Node %s has validator count %s. Expected: %s",
                idx, node.getValidatorCount(), validators)));

    // first validated block using 16 nodes
    network.generateBlocks(nodes, Height(GenesisValidatorCycle + 1),
        Height(GenesisValidatorCycle));
}

/// 32 nodes
/// Disabled due to significant network overhead,
/// Block creation fails for 32 nodes.
// temporarily disabled until failures are resolved
version (none)
unittest
{
    TestConf conf = { outsider_validators : 26 };

    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    // generate 18 blocks, 2 short of the enrollments expiring.
    network.generateBlocks(Height(GenesisValidatorCycle - 2));

    const keys = network.nodes.map!(node => node.client.getPublicKey()).array;

    // prepare frozen outputs for outsider validators to enroll
    genesisSpendable().drop(1).takeExactly(1)
        .map!(txb => txb.split(keys).sign(TxType.Freeze))
        .each!(tx => nodes[0].putTransaction(tx));

    // block 19
    network.generateBlocks(Height(GenesisValidatorCycle - 1));

    // wait for other nodes to get to same block height
    nodes.drop(GenesisValidators).enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == GenesisValidatorCycle - 1, 2.seconds,
            format!"Expected block height %s but outsider %s has height %s."
                (GenesisValidatorCycle - 1, idx, node.getBlockHeight())));

    auto validators = GenesisValidators + conf.outsider_validators;

    // Now we enroll new validators and re-enroll the original validators
    iota(0, validators).each!(idx => network.enroll(idx));

    network.generateBlocks(nodes, Height(GenesisValidatorCycle));

    // check 16 validators are enrolled
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getValidatorCount() == validators, 5.seconds,
            format("Node %s has validator count %s. Expected: %s",
                idx, node.getValidatorCount(), validators)));

    // first validated block using 32 nodes
    network.generateBlocks(nodes, Height(GenesisValidatorCycle + 1),
        Height(GenesisValidatorCycle));
}
