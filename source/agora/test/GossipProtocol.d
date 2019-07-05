/*******************************************************************************

    Contains tests for Gossip Protocol.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.GossipProtocol;

version (unittest):

import agora.common.Data;
import agora.test.Base;

///
unittest
{
    import std.digest.sha;
    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();
    assert(network.getDiscoveredNodes().length == NodeCount);

    Hash h1 = sha512Of("Message No. 1");
    auto n1 = network.apis.values[0];

    // Return true if this message was first received at this node.
    assert(n1.setMessage(h1));

    // Return false if this message was a message already received.
    assert(!n1.setMessage(h1));

    // Check hasMessage
    foreach (key, ref node; network.apis)
    {
        assert(node.hasMessage(h1));
    }
}
