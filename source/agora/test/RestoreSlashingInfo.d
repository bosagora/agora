/*******************************************************************************

    Contains tests for re-routing part of the frozen UTXO of a slashed
    validater to `CommonsBudget` address.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.RestoreSlashingInfo;

version (unittest):

import agora.test.Base;

import core.thread;

/// Situation: There are six validators enrolled in Genesis block. Right before
///     the cycle ends, the new validators enrolls. After one more block
///     being made, the validators restart and lose their data.
/// Expectation: The validators catch up all the block with the right slashing
///     information.
unittest
{
    TestConf conf = {
        outsider_validators : 3,
        recurring_enrollment : false
    };
    conf.node.timeout = 10.seconds;
    conf.node.network_discovery_interval = 2.seconds;
    conf.node.retry_delay = 250.msecs;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.nodes;
    auto set_a = network.nodes[0 .. GenesisValidators];
    auto set_b = network.nodes[GenesisValidators .. $];

    // generate 18 blocks, 2 short of the enrollments expiring.
    network.generateBlocks(Height(GenesisValidatorCycle - 2));

    // Block 19 we add the freeze utxos for set_b validators
    // prepare frozen outputs for outsider validators to enroll
    network.postAndEnsureTxInPool(iota(GenesisValidators),
        network.freezeUTXO(iota(GenesisValidators, GenesisValidators + 3)));

    network.generateBlocks(Height(GenesisValidatorCycle - 1), true);

    // wait for other nodes to get to same block height
    set_b.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == GenesisValidatorCycle - 1, 5.seconds,
            format!"Expected block height %s but outsider %s has height %s."
                (GenesisValidatorCycle - 1, idx, node.getBlockHeight())));

    // Now we enroll the set B validators and one Validator from set A
    iota(GenesisValidators - 1, GenesisValidators + conf.outsider_validators)
        .each!(i => network.enroll(i));

    // Block 20, After this the Genesis block enrolled validators will be expired.
    network.generateBlocks(iota(GenesisValidators), Height(GenesisValidatorCycle), true);
    // Set B validators should catch up
    network.expectHeight(iota(GenesisValidators, GenesisValidators + conf.outsider_validators),
        Height(GenesisValidatorCycle));

    // Sanity check
    auto b20 = set_a[0].getBlocksFrom(GenesisValidatorCycle, 1)[0];
    assert(b20.header.enrollments.length == conf.outsider_validators + 1);

    // Check if the validators in the set B have all the addresses for
    // current validators and previous validators except themselves.
    set_b.each!(node =>
        retryFor(node.getNodeInfo().addresses.length ==
            GenesisValidators + conf.outsider_validators,
            5.seconds));

    // Wait for nodes to run a discovery task and update their required peers
    Thread.sleep(conf.node.network_discovery_interval);

    // Block 21
    network.generateBlocks(iota(GenesisValidators - 1, GenesisValidators + conf.outsider_validators),
        Height(GenesisValidatorCycle + 1), true);

    // Now restarting the validators in the set B, all the data of those
    // validators has been wiped out.
    set_b.each!(node => network.restart(node.client));

    network.expectHeight(Height(GenesisValidatorCycle + 1));
}
