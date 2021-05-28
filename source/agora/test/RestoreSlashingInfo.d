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

import agora.api.FullNode;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.crypto.Key;
import agora.test.Base;
import agora.utils.PrettyPrinter;

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
        recurring_enrollment : false
    };
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

    const keys = set_b.map!(node => node.getPublicKey().key).array;

    auto blocks = nodes[0].getAllBlocks();

    // Block 19 we add the freeze utxos for set_b validators
    // prepare frozen outputs for outsider validators to enroll
    blocks[0].spendable().drop(1).takeExactly(1)
        .map!(txb => txb
            .split(keys).sign(OutputType.Freeze))
            .each!(tx => set_a[0].putTransaction(tx));

    network.generateBlocks(Height(GenesisValidatorCycle - 1));

    // wait for other nodes to get to same block height
    set_b.enumerate.each!((idx, node) =>
        retryFor(node.getBlockHeight() == GenesisValidatorCycle - 1, 5.seconds,
            format!"Expected block height %s but outsider %s has height %s."
                (GenesisValidatorCycle - 1, idx, node.getBlockHeight())));

    // Now we enroll the set B validators.
    iota(GenesisValidators, GenesisValidators + conf.outsider_validators)
        .each!(i => network.enroll(i));

    // Block 20, After this the Genesis block enrolled validators will be expired.
    network.generateBlocks(iota(nodes.length), Height(GenesisValidatorCycle));

    // Sanity check
    auto b20 = set_a[0].getBlocksFrom(GenesisValidatorCycle, 1)[0];
    assert(b20.header.enrollments.length == conf.outsider_validators);

    // Block 21
    network.generateBlocks(iota(nodes.length), Height(GenesisValidatorCycle + 1));

    // Now restarting the validators in the set B, all the data of those
    // validators has been wiped out.
    set_b.each!(node => network.restart(node.client));
    network.expectHeight(Height(GenesisValidatorCycle + 1));
}
