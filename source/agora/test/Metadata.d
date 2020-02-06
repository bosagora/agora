/*******************************************************************************

    Contains tests for the node network (P2P) behavior

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Metadata;

version (unittest):

import agora.common.BanManager;
import agora.common.Config;
import agora.common.crypto.Key;
import agora.common.Types;
import agora.common.Metadata;
import agora.common.Set;
import agora.test.Base;

import std.array;
import std.algorithm;

///
unittest
{
    auto network = makeTestNetwork(TestConf.init);
    network.addMetadata();
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
}
