/*******************************************************************************

    Contains networking tests with increased validator node counts.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.ManyValidators;

version (unittest):

import agora.test.Base;

import core.thread;

void manyValidators (size_t validators)
{
    TestConf conf = { outsider_validators : validators - GenesisValidators };
    conf.node.network_discovery_interval = 2.seconds;
    conf.node.retry_delay = 250.msecs;

    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // prepare frozen outputs for the outsider validator to enroll
    network.postAndEnsureTxInPool(
        network.freezeUTXO(iota(GenesisValidators, GenesisValidators + conf.outsider_validators)));

    // generate 1 block.
    network.generateBlocks(Height(1));

    // make sure outsiders are up to date
    network.expectHeight(iota(GenesisValidators, validators), Height(1));

    // Now we enroll new validators
    iota(GenesisValidators, validators).each!(idx => network.enroll(idx));

    // generate next 2 blocks
    network.generateBlocks(Height(3));
    network.assertSameBlocks(iota(GenesisValidators, validators), Height(3));

    const block_3 = network.clients[0].getBlock(3);
    assert(block_3.header.validators.count() == validators);
}

/// 10 nodes
unittest
{
    manyValidators(10);
}

/// 16 nodes
unittest
{
    manyValidators(16);
}
