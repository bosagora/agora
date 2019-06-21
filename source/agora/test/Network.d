/*******************************************************************************

    Contains tests for the node network (P2P) behavior

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Network;

version (unittest):

import agora.common.API;
import agora.common.Config;
import agora.common.Data;
import agora.common.crypto.Key;
import agora.node.Network;
import agora.node.Node;
import agora.test.Base;

import std.algorithm.iteration;
import std.exception;
import std.format;


///
private final class Network : TestNetwork
{
    /// Ctor
    public this (NodeConfig config, in string[] peers)
    {
        super(config, peers);
    }

    /// Wait a certain time until the nodes have reached discovery
    /// If after 10 query attempts they still all haven't discovered => assert
    /// Params:
    ///   count = Expected number of nodes
    public void waitUntilConnected (size_t count)
    {
        import core.thread;
        import std.stdio;

        const attempts = 10;

        bool[PublicKey] fully_discovered;

        foreach (_; 0 .. attempts)
        {
            foreach (key, api; this.peers)
            try
            {
                if (api.net_info.state == NetworkState.Complete)
                    fully_discovered[key] = true;
            }
            catch (Exception ex)
            {
                // just continue
            }

            // we're done
            if (fully_discovered.length == count)
                return;

            // try again
            auto sleep_time = 1.seconds;  // should be enough time
            writefln("Sleeping for %s. Discovered %s/%s nodes", sleep_time,
                fully_discovered.length, count);
            Thread.sleep(sleep_time);
        }

        assert(fully_discovered.length == count,
               format("Got %s/%s discovered nodes. Missing nodes: %s",
                   fully_discovered.length, count, this.todo_addresses));
    }
}

///
unittest
{
    auto network = makeTestNetwork!Network(NetworkTopology.Simple, 4);
    network.discover();
    network.waitUntilConnected(4);
}
