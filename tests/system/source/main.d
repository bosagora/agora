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

import vibe.web.rest;

import std.algorithm;
import std.stdio;
import core.thread;
import core.time;

/// Helper struct
private struct Address
{
    ///
    string host;
    ///
    ushort port;

    /// Helper function to call make the address vibe.inet.URL friendly
    public string withSchema () const @safe
    {
        import std.format;
        return format("http://%s:%d", this.host, this.port);
    }
}

/// Node addresses
private immutable Address[] Addrs = [
    { host: "127.0.0.1", port: 4000, },
    { host: "127.0.0.1", port: 4001, },
    { host: "127.0.0.1", port: 4002, },
];

/// Test node count
private immutable uint NodeCnt = 3;

void main ()
{
    {
        API[NodeCnt] clients;
        foreach (idx, const ref addr; Addrs)
            clients[idx] = new RestInterfaceClient!API(addr.withSchema());

        foreach (idx, ref client; clients)
        {
            writefln("[%s] getNetworkInfo: %s", idx, client.getNetworkInfo());
            const height = client.getBlockHeight();
            writefln("[%s] getBlockHeight: %s", idx, height);
            writeln("----------------------------------------");
            assert(height == 0);
        }

        auto kp = getGenesisKeyPair();

        foreach (idx; 0 .. Block.TxsInBlock)
        {
            Transaction tx = {
                type: TxType.Payment,
                inputs: [Input(GenesisBlock.header.merkle_root, idx)],
                outputs: [Output(GenesisTransaction.outputs[idx].value, kp.address)]
            };

            auto signature = kp.secret.sign(hashFull(tx)[]);
            tx.inputs[0].signature = signature;
            clients[0].putTransaction(tx);
        }

        checkBlockHeight(1);
    }

}

/// Check block generation
private void checkBlockHeight (ulong height)
{
    // TODO: This is a hack because of issue #312
    // https://github.com/bpfkorea/agora/issues/312
    API[NodeCnt] clients;
    foreach (idx, const ref addr; Addrs)
        clients[idx] = new RestInterfaceClient!API(addr.withSchema());

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

/// Copied from Agora
public KeyPair getGenesisKeyPair ()
{
    return KeyPair.fromSeed(
        Seed.fromString(
            "SCT4KKJNYLTQO4TVDPVJQZEONTVVW66YLRWAINWI3FZDY7U4JS4JJEI4"));
}
