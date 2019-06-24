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
import agora.common.crypto.Key;
import agora.node.Node;
import agora.test.Base;

import std.algorithm.iteration;
import std.exception;
import std.format;


///
class TestNodeRegistry : TestRegistry
{
    ///
    public override API factory (Config config, string name) @trusted
    {
        static import std.concurrency;
        import geod24.LocalRest;

        string id = config.node.key_pair.address.toString();
        auto tid = std.concurrency.locate(id);
        if (tid != tid.init)
            return new RemoteAPI!(API)(tid);

        // First instantiation of the API object, spawns a thread
        auto api = RemoteAPI!API.spawn!Node(config);
        std.concurrency.register(id, api.tid());
        return api;
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
            foreach (key, api; this.registry)
            try
            {
                auto net_info = api.getNetworkInfo();
                if (net_info.state == NetworkState.Complete)
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
                   fully_discovered.length, count,
                   this.registry.byKey.filter!(a => !(a in fully_discovered))));
    }
}

///
unittest
{
    scope registry = new TestNodeRegistry;
    auto keys = registry.makeTestNetwork(NetworkTopology.Simple, 4);
    registry.waitUntilConnected(4);
}
