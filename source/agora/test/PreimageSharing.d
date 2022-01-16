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

/// Doesn't actively reveal any preimages, but can be queried for it
public class NoActivePINode : TestValidatorNode
{
    ///
    mixin ForwardCtor!();

    ///
    public override void onPreImageRevealTimer () @safe {}

    /// To be extra sure, we also disable receiving a pre-image
    /// so that the node may gossip them
    public override Height postPreimage (in PreImageInfo preimage) @safe
    {
        return preimage.height;
    }
}

unittest
{
    TestConf conf = {
        preimage_catchup_interval : 1.seconds,
    };
    conf.consensus.quorum_threshold = 100;

    // set up nodes
    auto network = makeTestNetwork!(TestNetwork!NoActivePINode)(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // create and send txs to nodes
    auto nodes = network.clients;
    auto txs = network.blocks[$ - 1].spendable().map!(txb => txb.sign()).array;
    txs.each!(tx => nodes[0].postTransaction(tx));

    // block should be created even though the validators didn't reveal their
    // preimages in advance, as preimage sharing is also done during SCP run
    network.expectHeight(Height(1));
}
