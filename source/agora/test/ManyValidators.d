/*******************************************************************************

    Contains networking tests with a variety of different validator node counts.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.ManyValidators;

version (unittest):

void manyValidators (size_t validators)
{
    import agora.test.Base : TestConf, GenesisValidators, GenesisValidatorCycle,
        makeTestNetwork, TestAPIManager;
    import agora.common.Types : Height;
    import agora.consensus.data.Transaction : TxType;
    import agora.utils.Test : genesisSpendable, retryFor;
    import std.algorithm;
    import std.format;
    import std.range;
    import core.time : seconds;
    import agora.crypto.Key;

    TestConf conf = { outsider_validators : validators - GenesisValidators,
        txs_to_nominate : 0 };

    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // generate 18 blocks, 2 short of the enrollments expiring.
    network.generateBlocks(Height(GenesisValidatorCycle - 2));

    const keys = network.nodes.map!(node => node.client.getPublicKey(PublicKey.init).key)
        .dropExactly(GenesisValidators).takeExactly(conf.outsider_validators)
        .array;

    if (keys.length > 0)
    {
        // prepare frozen outputs for outsider validators to enroll
        genesisSpendable().dropExactly(1).takeExactly(1)
            .map!(txb => txb.split(keys).sign(TxType.Freeze))
            .each!(tx => network.clients[0].putTransaction(tx));
    }

    // block 19
    network.generateBlocks(Height(GenesisValidatorCycle - 1));

    // make sure outsiders are up to date
    network.expectHeight(iota(GenesisValidators, validators),
        Height(GenesisValidatorCycle - 1));

    // Now we enroll new validators and re-enroll the original validators
    iota(validators).each!(idx => network.enroll(idx));

    // Generate the last block of cycle with Genesis validators
    network.generateBlocks(iota(GenesisValidators),
        Height(GenesisValidatorCycle));

    // make sure outsiders are up to date
    network.expectHeight(iota(GenesisValidators, validators),
        Height(GenesisValidatorCycle));

    // check all validators are enrolled at block 20 by counting active in next block height
    network.clients.enumerate.each!((idx, node) =>
        retryFor(node.countActive(Height(GenesisValidatorCycle + 1)) == validators, 5.seconds,
            format("Node %s has validator count %s. Expected: %s",
                idx, node.countActive(Height(GenesisValidatorCycle + 1)), validators)));

    // first validated block using all nodes
    network.generateBlocks(iota(validators), Height(GenesisValidatorCycle + 1));
    network.assertSameBlocks(Height(GenesisValidatorCycle + 1));
}

/// 10 nodes
unittest
{
    manyValidators(10);
}

// temporarily disabled until failures are resolved
// see #1145
version (none):
/// 16 nodes
unittest
{
    manyValidators(16);
}

/// 32 nodes
unittest
{
    manyValidators(32);
}
