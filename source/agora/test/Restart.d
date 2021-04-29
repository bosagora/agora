/*******************************************************************************

    Test node restarting behavior

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Restart;

version (unittest):

import agora.api.Validator;
import agora.common.Config;
import agora.consensus.data.Block;
import agora.consensus.data.Params;
import agora.test.Base;

import geod24.Registry;

/// A test that stops and restarts a node
unittest
{
    TestConf conf = TestConf.init;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => node_1.putTransaction(tx));
    network.expectHeight(Height(1));

    // Now shut down & restart one node
    auto restartMe = nodes[$-1];
    network.restart(restartMe);
    network.waitForDiscovery();
    network.expectHeight(Height(1));
}

/// Node which has a persistent Ledger (restart always clear the local state)
private class PersistentNode : TestValidatorNode
{
    import agora.consensus.EnrollmentManager;
    import agora.consensus.Fee;
    import agora.consensus.state.UTXOSet;
    import agora.node.BlockStorage;

    mixin ForwardCtor!();

    ///
    private static UTXOSet utxo_set_saved;
    ///
    private static EnrollmentManager em_saved;
    ///
    private static IBlockStorage blockstorage_saved;
    ///
    private static FeeManager fee_man;

    ///
    protected override IBlockStorage makeBlockStorage () @system
    {
        if (blockstorage_saved is null)
            blockstorage_saved = super.makeBlockStorage();
        return blockstorage_saved;
    }

    ///
    protected override UTXOSet makeUTXOSet ()
    {
        if (utxo_set_saved is null)
            utxo_set_saved = super.makeUTXOSet();
        return utxo_set_saved;
    }

    ///
    protected override EnrollmentManager makeEnrollmentManager ()
    {
        if (em_saved is null)
            em_saved = super.makeEnrollmentManager();
        return em_saved;
    }

    ///
    protected override FeeManager makeFeeManager ()
    {
        if (fee_man is null)
            fee_man = super.makeFeeManager();
        return fee_man;
    }

}

private class WithPersistentNodeAPIManager : TestAPIManager
{
    ///
    public this (immutable(Block)[] blocks, TestConf test_conf, TimePoint test_start_time)
    {
        super(blocks, test_conf, test_start_time);
    }

    public override void createNewNode (Config conf,
        string file = __FILE__, int line = __LINE__)
    {
        if (conf.validator.enabled)
            this.addNewNode!PersistentNode(conf, file, line);
        else
            super.createNewNode(conf, file, line);
    }
}

/// Stops and restarts a node with a pre-existing state
unittest
{
    TestConf conf = TestConf.init;
    auto network = makeTestNetwork!WithPersistentNodeAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => node_1.putTransaction(tx));
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);

    // Now shut down & restart one node
    auto restartMe = nodes[$-1];
    scope(failure) restartMe.printLog();
    network.restart(restartMe);
    network.waitForDiscovery();
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);
}
