/*******************************************************************************

    Contains tests for general situations where validators participate in
    nominating a block and reaching consensus.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.ValidatorCleanRestart;

version (unittest):

import agora.api.FullNode;
import agora.crypto.Key;
import agora.test.Base;

import core.thread : Thread;

/// Situation: One set of Validators(set A) which enrolled in the Genesis
///     block are all expired at the latest block height. And the other
///     set of Validators(set B) are already enrolled and all validators.
///     But all the set B has been shutdown and lost their data, which
///     means that they have to have a catch-up process. After the catch-up
///     process of set B have finished, a new block is being nominated,
///     and a consensus round for the new block is being made.
/// Expectation: The new block is approved and inserted into the ledger.
unittest
{
    TestConf conf = {
        outsider_validators : 3,
        recurring_enrollment : false
    };
    conf.node.block_catchup_interval = 100.msecs; // speed up block catchup
    conf.node.network_discovery_interval = 200.msecs; // speed up discovery
    conf.node.retry_delay = 250.msecs;
    conf.node.max_retries = 2; // We shutdown some nodes so let's try less times
    const allValidators = GenesisValidators + conf.outsider_validators;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto set_a = network.clients[0 .. GenesisValidators];
    auto set_b = network.clients[GenesisValidators .. $];

    // generate 18 blocks, 2 short of the enrollments expiring.
    network.generateBlocks(Height(GenesisValidatorCycle - 2));

    // Block 19 we add the freeze utxos for set_b validators
    network.postAndEnsureTxInPool(iota(GenesisValidators),
        network.freezeUTXO(iota(GenesisValidators, allValidators)));

    network.generateBlocks(Height(GenesisValidatorCycle - 1), true);

    // make sure outsiders are up to date
    network.expectHeight(iota(GenesisValidators, allValidators),
        Height(GenesisValidatorCycle - 1));

    // Now we enroll the set B validators.
    iota(GenesisValidators, allValidators).each!(i => network.enroll(i));

    // Block 20, After this the Genesis block enrolled validators will be expired.
    network.generateBlocks(Height(GenesisValidatorCycle));

    // Sanity check
    auto b20 = set_a[0].getBlocksFrom(GenesisValidatorCycle, 1)[0];
    assert(b20.header.enrollments.length == conf.outsider_validators);

    // Now restarting the validators in the set B, all the data of those
    // validators has been wiped out.
    set_b.each!(node => network.restart(node));

    network.expectHeight(iota(GenesisValidators, allValidators), Height(GenesisValidatorCycle));

    // Sanity check
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.countActive(Height(GenesisValidatorCycle + 1)) == conf.outsider_validators, 5.seconds,
            format("Node %s has validator count %s. Expected: %s",
                idx, node.countActive(Height(GenesisValidatorCycle + 1)), conf.outsider_validators)));

    // Check the connection states are complete for the set B
    set_b.each!(node =>
        retryFor(node.getNodeInfo().state == NetworkState.Complete,
            5.seconds));

    // Check if the validators in the set B have all the addresses for
    // current validators and previous validators.
    set_b.enumerate.each!((idx, node) =>
        retryFor(node.getNodeInfo().addresses.length == allValidators,
            10.seconds,
            format("Node %s has addresses %s which is not expected count of %s",
            idx + 5, node.getNodeInfo().addresses, allValidators)));

    // Make all the validators of the set A disable to respond
    set_a.each!(node => node.ctrl.shutdown);

    // give time for the outsiders to be added as validators before sending tx for next block
    // as catchup for missing txs only occurs after nomination has started
    Thread.sleep(conf.node.network_discovery_interval);

    // Block 21 with the new validators in the set B
    network.generateBlocks(iota(GenesisValidators, allValidators),
        Height(GenesisValidatorCycle + 1));
}

/// Situation: A validator is stopped and wiped clean after the block height
///     is 1, and then, two blocks are inserted into the ledger. After the
///     validator restarts, another new block is added but node_1 is sleeping.
/// Expectation: The new block is inserted into the ledger because the validator
///     has started to validate immediately.
unittest
{
    TestConf conf;
    conf.node.test_validators = 4;
    conf.consensus.max_quorum_nodes = 3; // Can be removed after dynamic quorums is merged
    conf.consensus.quorum_threshold = 66;
    conf.node.block_catchup_interval = 100.msecs; // speed up catchup
    conf.node.network_discovery_interval = 200.msecs; // speed up discovery
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // node_1 and node_2 are validators
    auto nodes = network.clients;
    auto node_1 = nodes[1];
    auto node_2 = nodes[2];

    // 4 nodes has quorums of 3 nodes so quorum slice is 2 if threshold is 66%
    assert(node_1.getQuorumConfig().threshold == 2);

    // Create a block after the Genesis block
    network.generateBlocks(Height(1));

    // node_2 restarts and becomes unresponsive
    network.restart(node_2);
    {
        node_2.ctrl.sleep(1.hours, true);
        // Wake up node_2
        scope (exit) node_2.ctrl.sleep(0.seconds);

        // Make 2 blocks
        network.generateBlocks(only(0, 1, 3), Height(3));
    }

    {
        node_1.ctrl.sleep(1.hours, true);
        // Make sure we can print the logs
        scope (failure) node_1.ctrl.sleep(0.seconds);

        // wait till node_2 catches up
        network.assertSameBlocks(only(0, 2, 3), Height(3));

        // give time for node_2 to be discovered again
        // as catchup for missing txs only occurs after nomination has started
        Thread.sleep(conf.node.network_discovery_interval);

        // A new block is still inserted into the ledger with the approval
        // of node_2, although node_1 was sleeping.
        network.generateBlocks(only(0, 2, 3), Height(4));
    }
}
