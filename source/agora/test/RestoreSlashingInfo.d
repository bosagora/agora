/*******************************************************************************

    Contains tests for re-routing part of the frozen UTXO of a slashed
    validater to `CommonsBudget` address.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.RestoreSlashingInfo;

version (unittest):

import agora.api.FullNode;
import agora.common.crypto.Key;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.test.Base;

/// Situation: There are six validators enrolled in Genesis block. Right before
///     the cycle ends, the new validators enrolls. After one more block
///     being made, the validators restart and lose their data.
/// Expectation: The validators catch up all the block with the right slashing
///     information.
unittest
{
    TestConf conf = {
        timeout : 10.seconds,
        outsider_validators : 3,
        txs_to_nominate : 0, // zero allows any number of txs for nomination
        recurring_enrollment : false
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

    // Now we enroll the set B validators.
    set_b.enumerate.each!((idx, _) => network.enroll(GenesisValidators + idx));

    // Block 20, After this the Genesis block enrolled validators will be expired.
    network.generateBlocks(iota(nodes.length), Height(GenesisValidatorCycle));

    // Sanity check
    auto b20 = set_a[0].getBlocksFrom(GenesisValidatorCycle, 1)[0];
    assert(b20.header.enrollments.length == conf.outsider_validators);

    // Block 21
    network.generateBlocks(iota(nodes.length), Height(GenesisValidatorCycle + 1));

    // Now restarting the validators in the set B, all the data of those
    // validators has been wiped out.
    set_b.each!(node => network.restart(node));
    network.expectBlock(Height(GenesisValidatorCycle + 1));
}
