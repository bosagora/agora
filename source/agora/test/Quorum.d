/*******************************************************************************

    Contains various quorum tests, adding and expiring enrollments,
    making a network with many validators, etc.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Quorum;

version (unittest):

import agora.node.FullNode;
import agora.test.Base;

import core.thread;
import core.time;

///
unittest
{
    TestConf conf = { outsider_validators : 3,
        recurring_enrollment : false,
    };
    conf.node.network_discovery_interval = 2.seconds;
    conf.node.retry_delay = 250.msecs;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.nodes;

    auto validators = GenesisValidators + conf.outsider_validators;

    // generate 18 blocks, 1 short of the enrollments expiring.
    network.generateBlocks(Height(GenesisValidatorCycle - 2));

    // prepare frozen outputs for the outsider validator to enroll
    network.postAndEnsureTxInPool(network.freezeUTXO(iota(GenesisValidators, validators)));

    // at block height 19 the freeze tx's are available
    network.generateBlocks(Height(GenesisValidatorCycle - 1));

    // make sure outsiders are up to date
    network.expectHeight(iota(GenesisValidators, validators),
        Height(GenesisValidatorCycle - 1));

    // re-enroll Genesis validators and enroll outsider validators
    iota(GenesisValidators - 1, validators).each!(idx => network.enroll(idx));

    // generate block at height 20
    network.generateBlocks(iota(GenesisValidators),
        Height(GenesisValidatorCycle));

    // make sure outsiders are up to date
    network.expectHeight(iota(GenesisValidators, validators),
        Height(GenesisValidatorCycle));

    // Wait for nodes to run a discovery task and update their required peers
    Thread.sleep(3.seconds);
    network.waitForDiscovery();

    // these are no longer enrolled
    nodes[0 .. GenesisValidators - 1].each!(node => node.client.sleep(10.minutes, true));

    // verify that consensus can still be reached by the leftover validators
    network.generateBlocks(iota(GenesisValidators - 1, nodes.length),
        Height(GenesisValidatorCycle + 1));

    // force wake up
    nodes.takeExactly(GenesisValidators - 1).each!(node =>
        node.client.sleep(0.seconds, false));

    // all nodes should have same block height now
    network.expectHeightAndPreImg(iota(nodes.length), Height(GenesisValidatorCycle + 1),
        nodes[0].getAllBlocks()[GenesisValidatorCycle].header);
}
