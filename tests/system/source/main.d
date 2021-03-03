/*******************************************************************************

    Stand alone client to test basic functionalities of the node

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module main;

import agora.api.FullNode;
import agora.consensus.data.Block;
import agora.consensus.data.genesis;
import TestGenesis = agora.consensus.data.genesis.Test;
import agora.consensus.data.genesis.Test;
import agora.consensus.data.Transaction;
import agora.common.crypto.Key;
import agora.common.Set;
import agora.crypto.Hash;
import agora.utils.PrettyPrinter;
import agora.utils.Test;

import vibe.web.rest;

import std.algorithm;
import std.exception;
import std.format;
import std.range;
import std.stdio;
import core.thread;
import core.time;

// Lets make it easy to find our log lines
immutable string PREFIX = ">>CI:";

int main (string[] args)
{
    writefln("%s START SYSTEM TEST", PREFIX);
    if (args.length < 2)
    {
        writefln("%s You must enter addresses of the nodes to connect to.", PREFIX);
        writefln("%s   eg.) http://127.0.0.1:4000 http://127.0.0.1:4001 http://127.0.0.1:4002 ...", PREFIX);
        return 1;
    }
    /// Address array of nodes
    const addresses = args[1..$];

    API[] clients;
    foreach (const ref addr; addresses)
        clients ~= new RestInterfaceClient!API(addr);

    // Get node name from address for logging
    string nodeFromClientIndex(size_t index)
    {
        return format!"node-%s"(addresses[index][$-1 .. $]);
    }

    // keep polling the nodes for a complete network discovery, until a timeout
    writefln("%s waitForDiscovery", PREFIX);
    const discovery_duration = 20.seconds;
    clients.enumerate.each!((idx, client) =>
    {
        retryFor(client.getNodeInfo().ifThrown(NodeInfo.init)
            .state == NetworkState.Complete,
            discovery_duration,
            format("%s %s has not completed discovery after %s.",
                PREFIX, nodeFromClientIndex(idx), discovery_duration * (idx + 1)));
    }());

    /// Check block generation
    void assertBlockHeightAtleast (ulong height)
    {
        Hash block_hash;
        const Duration retry_delay = 500.msecs;
        const Duration max_duration = 30.seconds;
        foreach (idx, ref client; clients)
        {
            writefln("%s Check block height is %s for %s", PREFIX, height, nodeFromClientIndex(idx));
            ulong node_height;
            Duration duration = 0.seconds;
            do
            {
                node_height = client.getBlockHeight();
                if (node_height < height) // Only sleep when we need to
                {
                    writefln("%s %s has height %s not yet height %s: sleep %s (so far %s out of %s max) ",
                        PREFIX, nodeFromClientIndex(idx), node_height, height, retry_delay,
                        duration == 0.seconds ? "0 secs" : duration.toString(), max_duration);
                    Thread.sleep(retry_delay);
                }
                else
                {
                    writefln("%s %s is at block height %s", PREFIX, nodeFromClientIndex(idx), node_height);
                    const blocks = client.getBlocksFrom(height, 10);
                    writefln("%s %s has blocks:\n%s", PREFIX, nodeFromClientIndex(idx), prettify(blocks));
                    writefln("%s ----------------------------------------", PREFIX);
                }
                duration += retry_delay;
            }
            while (node_height < height && duration < max_duration); // Retry if we're too early
            assert(node_height >= height,
                format!"%s %s still has block height %s less than expected height %s after more than %s"
                    (PREFIX, nodeFromClientIndex(idx), node_height, height, duration));
        }
    }

    clients.enumerate.each!((idx, client) =>
    {
        writefln("%s %s info: %s", PREFIX, nodeFromClientIndex(idx), client.getNodeInfo());
        const height = client.getBlockHeight();
        writefln("%s %s has block height %s", PREFIX, nodeFromClientIndex(idx), height);
        writefln("%s ----------------------------------------", PREFIX);
    }());

    // Make sure the nodes use the test genesis block
    const blocks = clients[0].getBlocksFrom(0, 1);
    assert(blocks.length == 1);
    assert(blocks[0] == TestGenesis.GenesisBlock, format!"%s Not using expected TestGenesis.GenesisBlock"(PREFIX));

    auto target_height = 2;
    iota(target_height).each!(h => assertBlockHeightAtleast(h));
    writefln("%s All nodes reached target height %s", PREFIX, target_height);

    return 0;
}
