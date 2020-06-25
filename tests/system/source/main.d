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
import agora.consensus.data.Transaction;
import agora.consensus.Genesis;
import agora.common.crypto.Key;
import agora.common.Hash;
import agora.common.Set;
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

// keep polling the nodes for a complete network discovery, until a timeout
private void waitForDiscovery (API[] clients, Duration timeout)
{
    clients.enumerate.each!((idx, api) =>
        retryFor(api.getNodeInfo().ifThrown(NodeInfo.init)
            .state == NetworkState.Complete,
            timeout,
            format("Node %s has not completed discovery after %s.",
                idx, timeout)));
}

int main (string[] args)
{
    if (args.length < 2)
    {
        writeln("You must enter addresses of the nodes to connect to.");
        writeln("   ex) http://127.0.0.1:4000 http://127.0.0.1:4001 http://127.0.0.1:4002 ...");
        return 1;
    }

    /// Address array of nodes
    const addresses = args[1..$];

    {
        API[] clients;
        foreach (const ref addr; addresses)
            clients ~= new RestInterfaceClient!API(addr);

        waitForDiscovery(clients, 5.seconds);

        foreach (idx, ref client; clients)
        {
            writefln("[%s] getNodeInfo: %s", idx, client.getNodeInfo());
            const height = client.getBlockHeight();
            writefln("[%s] getBlockHeight: %s", idx, height);
            writeln("----------------------------------------");
            assert(height == 0);
        }

        auto kp = WK.Keys.Genesis;

        iota(Block.TxsInBlock)
            .map!(idx => TxBuilder(GenesisBlock.txs[0], idx).refund(kp.address).sign())
            .each!(tx => clients[0].putTransaction(tx));

        checkBlockHeight(addresses, 1);
    }

    return 0;
}

/// Check block generation
private void checkBlockHeight (const string[] addresses, ulong height)
{
    // TODO: This is a hack because of issue #312
    // https://github.com/bpfkorea/agora/issues/312
    API[] clients;
    foreach (const ref addr; addresses)
        clients ~= new RestInterfaceClient!API(addr);

    Hash blockHash;
    size_t times; // Number of times we slept for 50 msecs
    foreach (idx, ref client; clients)
    {
        ulong getHeight;
        do
        {
            Thread.sleep(50.msecs);
            getHeight = client.getBlockHeight();
        }
        while (getHeight < height && times++ < 100); // Retry if we're too early
        const blocks = client.getBlocksFrom(0, 42);
        writefln("[%s] getBlockHeight: %s", idx, getHeight);
        writefln("[%s] getBlocksFrom: %s", idx, blocks.map!prettify);
        writeln("----------------------------------------");
        assert(getHeight == height);
        assert(blocks.length == height+1);
        if (idx != 0)
            assert(blockHash == hashFull(blocks[height].header));
        else
            blockHash = hashFull(blocks[height].header);
        times = 0;
    }
}
