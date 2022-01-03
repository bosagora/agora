/*******************************************************************************

    Contains test for multiple quorums

    Run via:
    $ dtest=agora.test.ManyQuorums dub test

    Copyright:
        Copyright (c) 2019-2022 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.ManyQuorums;

version (unittest):

import agora.test.Base;
import agora.test.Simple: simpleTest;

/// Simple test
unittest
{
    TestConf conf;
    conf.consensus.max_quorum_nodes = 3;
    conf.consensus.payout_period = 10;
    simpleTest(conf);
}
