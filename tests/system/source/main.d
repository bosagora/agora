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

// Lets make it easy to find our log lines
immutable string PREFIX = ">>CI:";

// keep polling the nodes for a complete network discovery, until a timeout
private void waitForDiscovery (API[] clients, Duration timeout)
{
    clients.enumerate.each!((idx, api) =>
        retryFor(api.getNodeInfo().ifThrown(NodeInfo.init)
            .state == NetworkState.Complete,
            timeout,
            format("%s Client #%s has not completed discovery after %s.",
                PREFIX, idx, timeout)));
}

int main (string[] args)
{
    writefln("%s START SYSTEM TEST", PREFIX);
    if (args.length < 2)
    {
        writeln("%s You must enter addresses of the nodes to connect to.", PREFIX);
        writeln("%s   ex) http://127.0.0.1:4000 http://127.0.0.1:4001 http://127.0.0.1:4002 ...", PREFIX);
        return 1;
    }

    /// Address array of nodes
    const addresses = args[1..$];

    {
        API[] clients;
        foreach (const ref addr; addresses)
            clients ~= new RestInterfaceClient!API(addr);

        waitForDiscovery(clients, 5.seconds);
        const GenesisBlock = clients[0].getBlocksFrom(0, 1)[0];

        foreach (idx, ref client; clients)
        {
            writefln("%s Client #%s node info: %s", PREFIX, idx, client.getNodeInfo());
            const height = client.getBlockHeight();
            writefln("%s Client #%s has block height %s", PREFIX, idx, height);
            writefln("%s ----------------------------------------", PREFIX);
            assert(height == 0);
        }

        // Make sure the nodes use the test genesis block
        const blocks = clients[0].getBlocksFrom(0, 1);
        assert(blocks.length == 1);
        assert(blocks[0] == TestGenesis.GenesisBlock);

        auto kp = WK.Keys.Genesis;

        writefln("%s Put 1 transaction to client[0]", PREFIX);
        genesisSpendable().takeExactly(1)
            .map!(txb => txb.sign()).each!(tx => clients[0].putTransaction(tx));

        writefln("%s Wait 5 seconds", PREFIX);
        Thread.sleep(5.seconds); // Give time for block to be externalized

        writefln("%s Check height is 1", PREFIX);
        assertBlockHeight(addresses, 1);

        // wait for distance 1 to be revealed before block 2 is proposed
        waitForPreimages(addresses, 1, 5.seconds);
        writefln("%s Put 8 transactions to client[0]", PREFIX);
        genesisSpendable().dropExactly(1).takeExactly(1)
            .map!(txb =>
                txb.split(WK.Keys.byRange.map!(k => k.address)
                    .take(8)).sign())
            .each!(tx => clients[0].putTransaction(tx));

        writefln("%s Wait 5 seconds", PREFIX);
        Thread.sleep(5.seconds); // Give time for block to be externalized

        writefln("%s Check height is 2", PREFIX);
        assertBlockHeight(addresses, 2);
    }

    return 0;
}

/// wait for preimages for the given distance to be revealed
private void waitForPreimages (in string[] addresses, in uint distance,
    Duration timeout)
{
    // TODO: This is a hack because of issue #312
    // https://github.com/bpfkorea/agora/issues/312
    API[] clients;
    foreach (const ref addr; addresses)
        clients ~= new RestInterfaceClient!API(addr);

    clients.each!(client =>
        TestGenesis.GenesisBlock.header.enrollments.each!(enroll =>
            retryFor(client.getPreimage(enroll.utxo_key)
                .distance >= distance, timeout)));
}

/// Check block generation
private void assertBlockHeight (const string[] addresses, ulong height)
{
    // TODO: This is a hack because of issue #312
    // https://github.com/bpfkorea/agora/issues/312
    API[] clients;
    foreach (const ref addr; addresses)
        clients ~= new RestInterfaceClient!API(addr);

    Hash blockHash;
    size_t times; // Number of times we slept for 500 msecs
    foreach (idx, ref client; clients)
    {
        writefln("%s Check block height is %s for Client #%s ", PREFIX, height, idx);
        ulong getHeight;
        do
        {
            getHeight = client.getBlockHeight();
            if (getHeight < height) // Only sleep when we need to
            {
                writefln("%s Client #%s not yet correct height: wait 500 ms", PREFIX, idx);
                Thread.sleep(500.msecs);
            }
            else
            {
                writefln("%s Client #%s is at block height %s", PREFIX, idx, getHeight);
                const blocks = client.getBlocksFrom(0, 42);
                writefln("%s Client #%s has blocks:\n%s", PREFIX, idx, prettify(blocks));
                writefln("%s ----------------------------------------", PREFIX);
                assert(blocks.length == height + 1);
                if (idx != 0)
                    assert(blockHash == hashFull(blocks[height].header));
                else
                    blockHash = hashFull(blocks[height].header);
            }
        }
        while (getHeight < height && times++ < 50); // Retry if we're too early
        assert(getHeight == height,
            format!"%s Client #%s still has block height %s not %s"
                (PREFIX, idx, getHeight, height));
        times = 0;
    }
}
