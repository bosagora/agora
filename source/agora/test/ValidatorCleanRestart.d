/*******************************************************************************

    Contains tests for general situations where validators participate in
    nominating a block and reaching consensus.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.ValidatorCleanRestart;

version (unittest):

import agora.api.FullNode;
import agora.common.crypto.Key;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.test.Base;

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
        timeout : 10.seconds,
        outsider_validators : 2,
        txs_to_nominate : 0, // zero allows any number of txs for nomination
        recurring_enrollment : false,
    };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto set_a = network.clients[0 .. GenesisValidators];
    auto set_b = network.clients[GenesisValidators .. $];

    // generate 18 blocks, 2 short of the enrollments expiring.
    network.generateBlocks(Height(GenesisValidatorCycle - 2));

    const keys = network.nodes.map!(node => node.client.getPublicKey())
        .dropExactly(GenesisValidators).takeExactly(conf.outsider_validators)
        .array;

    auto blocks = nodes[0].getAllBlocks();

    // Block 19 we add the freeze utxos for set_b validators
    // prepare frozen outputs for outsider validators to enroll
    blocks[0].spendable().drop(1)
        .map!(txb => txb
            .split(keys).sign(TxType.Freeze))
        .each!(tx => set_a[0].putTransaction(tx));

    network.generateBlocks(Height(GenesisValidatorCycle - 1));

    // wait for other nodes to get to same block height
    set_b.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == GenesisValidatorCycle - 1, 2.seconds,
            format!"Expected block height %s but outsider %s has height %s."
                (GenesisValidatorCycle - 1, idx, node.getBlockHeight())));

    // Now we enroll four new validators.
    set_b.enumerate.each!((idx, _) => network.enroll(GenesisValidators + idx));

    // Block 20, After this the Genesis block enrolled validators will be expired.
    network.generateBlocks(Height(GenesisValidatorCycle));

    // Sanity check
    auto b20 = set_a[0].getBlocksFrom(GenesisValidatorCycle, 1)[0];
    assert(b20.header.enrollments.length == conf.outsider_validators);

    // Now restarting the validators in the set B, all the data of those
    // validators has been wiped out.
    set_b.each!(node => network.restart(node));
    network.expectBlock(Height(GenesisValidatorCycle));

    // Sanity check
    nodes.enumerate.each!((idx, node) =>
        retryFor(node.getValidatorCount == conf.outsider_validators, 3.seconds,
            format("Node %s has validator count %s. Expected: %s",
                idx, node.getValidatorCount(), conf.outsider_validators)));

    // Check the connection states are complete for the set B
    set_b.each!(node =>
        retryFor(node.getNodeInfo().state == NetworkState.Complete,
            5.seconds));

    // Check if the validators in the set B have all the addresses for
    // current validators and previous validators except themselves.
    set_b.each!(node =>
        retryFor(node.getNodeInfo().addresses.length ==
            GenesisValidators + conf.outsider_validators - 1,
            5.seconds));

    // Make all the validators of the set A disable to respond
    set_a.each!(node => node.ctrl.sleep(6.seconds, true));

    // Block 21 with the new validators in the set B
    network.generateBlocks(iota(GenesisValidators, cast(size_t) nodes.length),
        Height(GenesisValidatorCycle + 1));
}

/// Situation: A validator is stopped and wiped clean after the block height
///     is 1, and then, two blocks are inserted into the ledger. After the
///     validator restarts, another new block is in the middle of a consensus.
/// Expectation: The new block is inserted into the ledger because the validator
///     has started to validate immediately.
unittest
{
    TestConf conf = { full_nodes : 1,
        quorum_threshold : 75 };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // node_1 and node_2 are the validators
    auto nodes = network.clients;
    auto node_1 = nodes[0];
    auto node_2 = nodes[1];
    auto on_nodes = nodes[1 .. $-1];    // full node

    // Create a block from the Genesis block
    auto txs = genesisSpendable().map!(txb => txb.sign()).array();
    txs.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(1));

    // node_1 restarts and becomes unresponsive
    network.restart(node_1);
    node_1.ctrl.sleep(5.seconds);

    // Make 2 blocks
    txs = txs.map!(tx => TxBuilder(tx).sign()).array();
    txs.each!(tx => node_2.putTransaction(tx));
    network.expectBlock(iota(1,nodes.length), Height(2));

    txs = txs.map!(tx => TxBuilder(tx).sign()).array();
    txs.each!(tx => node_2.putTransaction(tx));
    network.expectBlock(iota(1,nodes.length), Height(3));

    // Wait for node_1 to wake up
    node_1.ctrl.withTimeout(10.seconds,
        (scope TestAPI api) {
            api.getPublicKey();
        }
    );

    network.expectBlock(Height(3));

    // The node_2 restart and is disabled to respond, which means that
    // the node_2 will be slashed soon.
    network.restart(node_2);
    node_2.ctrl.sleep(5.seconds);

    // A new block is in the middle of a consensus.
    txs = txs.map!(tx => TxBuilder(tx).sign()).array();
    txs.each!(tx => node_1.putTransaction(tx));

    // The new block has been inserted to the ledger with the approval
    // of the node_1, although node_2 was shutdown.
    network.expectBlock(Height(4));
}
