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
    TestConf conf = { outsider_validators : 2,
        txs_to_nominate : 0 };  // zero allows any number of txs for nomination
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    auto validators = GenesisValidators + conf.outsider_validators;

    // generate 18 blocks, 1 short of the enrollments expiring.
    network.generateBlocks(Height(GenesisValidatorCycle - 2));

    const keys = nodes.map!(node => node.getPublicKey())
        .dropExactly(GenesisValidators)
        .takeExactly(conf.outsider_validators)
        .array;

    // Freeze outputs for outsiders
    genesisSpendable.drop(2).takeExactly(1)
        .map!(txb => txb.split(keys).sign(TxType.Freeze))
        .each!(tx => nodes[0].putTransaction(tx));

    // at block height 19 the freeze tx's are available
    network.generateBlocks(Height(GenesisValidatorCycle - 1));

    // make sure outsiders are up to date
    network.expectBlock(iota(GenesisValidators, validators),
        Height(GenesisValidatorCycle - 1));

    // re-enroll Genesis validators and enroll outsider validators
    iota(GenesisValidators, validators).each!(idx => network.enroll(idx));

    // generate block at height 20
    network.generateBlocks(iota(GenesisValidators),
        Height(GenesisValidatorCycle));

    // make sure outsiders are up to date
    network.expectBlock(iota(GenesisValidators, validators),
        Height(GenesisValidatorCycle));

    // these are no longer enrolled
    nodes[0 .. GenesisValidators].each!(node => node.sleep(10.minutes, true));

    // verify that consensus can still be reached by the leftover validators
    network.generateBlocks(iota(GenesisValidators, nodes.length),
        Height(GenesisValidatorCycle + 1), Height(GenesisValidatorCycle));

    // force wake up
    nodes.takeExactly(GenesisValidators).each!(node =>
        node.sleep(0.seconds, false));

    // all nodes should have same block height now
    network.expectBlock(iota(nodes.length), Height(GenesisValidatorCycle + 1),
        nodes[0].getAllBlocks()[GenesisValidatorCycle].header);
}
