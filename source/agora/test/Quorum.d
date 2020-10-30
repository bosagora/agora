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
    TestConf conf = { outsider_validators : 2 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    const b0 = nodes[0].getBlocksFrom(0, 2)[0];

    // generate 18 blocks, 1 short of the enrollments expiring.
    network.generateBlocks(Height(GenesisValidatorCycle - 2));

    const keys = network.nodes.map!(node => node.client.getPublicKey()).array;
    
    // Freeze outputs for outsiders
    genesisSpendable().dropExactly(1).takeExactly(1)
        .map!(txb => txb.split(keys).sign(TxType.Freeze))
        .each!(tx => nodes[0].putTransaction(tx));

    // at block height 19 the freeze tx's are available
    network.generateBlocks(Height(GenesisValidatorCycle - 1));

    // wait for other nodes to get to same block height
    nodes.drop(GenesisValidators).enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == GenesisValidatorCycle - 1, 2.seconds,
            format!"Expected block height %s but outsider %s has height %s."
                (GenesisValidatorCycle - 1, idx, node.getBlockHeight())));

    iota(GenesisValidators, GenesisValidators + conf.outsider_validators)
        .each!(idx => network.enroll(idx));

    // at block height 20 the validator set will change
    network.generateBlocks(nodes, Height(GenesisValidatorCycle));

    //// these are no longer enrolled
    nodes[0 .. GenesisValidators].each!(node => node.sleep(10.minutes, true));

    // verify that consensus can still be reached by the leftover validators
    network.generateBlocks(nodes.drop(GenesisValidators),
        Height(GenesisValidatorCycle + 1), Height(GenesisValidatorCycle));

    // force wake up
    nodes.takeExactly(GenesisValidators).each!(node => node.sleep(0.seconds, false));

    // all nodes should have same block height now
    network.expectBlock(Height(GenesisValidatorCycle + 1),
        nodes[0].getAllBlocks()[GenesisValidatorCycle].header);
}
