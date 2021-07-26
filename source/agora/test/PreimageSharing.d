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

import agora.common.Config;
import agora.common.Set;
import agora.consensus.data.PreImageInfo;
import agora.utils.Test;
import agora.test.Base;

import geod24.Registry;

/// doesn't reveal any preimages, except during nomination or when
/// reveal_preimage is set to true
public class NoPreImageExceptNominationVN : NoPreImageVN
{
    ///
    mixin ForwardCtor!();

    /// GET: /preimages_for_enroll_keys
    public override PreImageInfo[] getPreimagesForEnrollKeys (Set!Hash enroll_keys = Set!Hash.init) @safe nothrow
    {
        return TestValidatorNode.getPreimagesForEnrollKeys(enroll_keys);
    }
}

unittest
{
    TestConf conf = {
        preimage_catchup_interval : 1.seconds,
    };
    conf.consensus.quorum_threshold = 100;

    // set up nodes
    auto network = makeTestNetwork!(LazyAPIManager!NoPreImageExceptNominationVN)(conf);
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
