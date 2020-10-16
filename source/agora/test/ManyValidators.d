/*******************************************************************************

    Contains networking tests with a variety of different validator node counts.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.ManyValidators;

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
import agora.utils.PrettyPrinter;

import std.algorithm;
import std.format;
import std.range;

import core.thread;
import core.time;

/// 8 nodes (6 enrolled in Genesis and 2 more added)
unittest
{
    TestConf conf = { validators : 8 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.completeTestSetup();

    // Create another block
    network.generateBlocks(network.clients, Height(network.blocks[$ -1].header.height + 1),
        Height(network.validator_cycle));
    assert(network.clients[0].getValidatorCount() == conf.validators,
        format!"Expected %s enrolled validators not %s"
            (conf.validators, network.clients[0].getValidatorCount()));
}

/// 16 nodes
/// Disabled due to significant network overhead,
/// Block creation fails for 16 nodes.
version (none)
unittest
{
    TestConf conf = { validators : 16 };

    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.completeTestSetup();

    // Create another block
    network.generateBlocks(network.clients, Height(network.blocks[$ -1].header.height + 1),
        Height(network.validator_cycle));
    assert(network.clients[0].getValidatorCount() == conf.validators,
        format!"Expected %s enrolled validators not %s"
            (conf.validators, network.clients[0].getValidatorCount()));
}

/// 32 nodes
/// Disabled due to significant network overhead,
/// Block creation fails for 32 nodes.
version (none)
unittest
{
    TestConf conf = { validators : 32 };

    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.completeTestSetup();

    // Create another block
    network.generateBlocks(network.clients, Height(network.blocks[$ -1].header.height + 1),
        Height(network.validator_cycle));
    assert(network.clients[0].getValidatorCount() == conf.validators,
        format!"Expected %s enrolled validators not %s"
            (conf.validators, network.clients[0].getValidatorCount()));
}
