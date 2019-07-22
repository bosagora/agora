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
import agora.common.Data;
import agora.common.Metadata;
import agora.common.Set;
import agora.test.Base;

import std.array;
import std.algorithm;

///
class MetaNetworkManager : TestNetworkManager
{
    static import std.concurrency;
    import geod24.LocalRest;

    /// Ctor
    public this () { super(); }

    /// Ditto
    public this (NodeConfig config, BanManager.Config ban_conf, in string[] peers, in string[] dns_seeds,
        Metadata metadata)
    {
        super(config, ban_conf, peers, dns_seeds, metadata);
    }

    /// before we start the nodes, we want to simulate metadata configuration
    public override void start ()
    {
        auto keys = this.apis.keys.array;

        foreach (key_x; keys)
        foreach (key_y; keys)
        {
            if (key_x == key_y)
                continue;

            this.apis[key_x].metaAddPeer(key_y.toString());
            this.apis[key_y].metaAddPeer(key_x.toString());
        }

        super.start();
    }
}

///
unittest
{
    const NodeCount = 4;
    auto network = makeTestNetwork!MetaNetworkManager(NetworkTopology.Simple, NodeCount, false);
    network.start();
    assert(network.getDiscoveredNodes().length == NodeCount);
}
