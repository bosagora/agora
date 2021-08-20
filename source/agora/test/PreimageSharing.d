/*******************************************************************************

    Contains tests for sharing preimages during SCP protocol run.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.PreimageSharing;

version (unittest):

import agora.common.Set;
import agora.consensus.data.PreImageInfo;
import agora.utils.Test;
import agora.test.Base;

/// doesn't reveal any preimages, except during nomination
public class NoPreImageExceptNominationVN : TestValidatorNode
{
    ///
    mixin ForwardCtor!();

    protected override void onPreImageRevealTimer ()
    {
        // Will not reveal preimages
    }
}

unittest
{
    TestConf conf;
    conf.preimage_catchup_interval = 100.msecs;
    conf.consensus.quorum_threshold = 100;

    // set up nodes
    auto network = makeTestNetwork!(TestNetwork!(NoPreImageExceptNominationVN))(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // create and send txs to nodes
    auto nodes = network.clients;
    auto txs = network.blocks[$ - 1].spendable().map!(txb => txb.sign()).array;
    txs.each!(tx => nodes[0].putTransaction(tx));

    // block should be created even though the validators didn't reveal their
    // preimages in advance, as preimage sharing is also done during SCP run
    network.expectHeight(Height(1));
}
