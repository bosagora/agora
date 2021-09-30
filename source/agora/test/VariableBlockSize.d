/*******************************************************************************

    Tests creating blocks of arbitrary transaction counts.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.VariableBlockSize;

version (unittest):

import agora.api.Validator;
import agora.consensus.data.genesis.Test: GenesisBlock;
import agora.test.Base;

///
unittest
{
    auto network = makeTestNetwork!TestAPIManager(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // create 8 txs
    auto txs = genesisSpendable.map!(txb =>
        txb.refund(WK.Keys.Genesis.address).sign());

    auto height = Height(0);
    // variable number of txs for each block
    only(1, 3, 4).each!((i) {
        txs.takeExactly(i).each!(tx => network.postAndEnsureTxInPool(tx));
        txs = txs.drop(i);
        height++;
        network.expectHeightAndPreImg(height, GenesisBlock.header, 5.seconds);
        assert(network.clients.front.getBlocksFrom(height, 1)[0].txs.length == i);
    });
    network.assertSameBlocks(height);
}
