/*******************************************************************************

    Stand alone client to test basic functionalities of the node

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module main;

import agora.consensus.data.Transaction;
import agora.consensus.Genesis;
import agora.common.crypto.Key;
import agora.common.Data;
import agora.common.Hash;
import agora.node.API;
import agora.utils.PrettyPrinter;

import vibe.web.rest;

import std.algorithm;
import std.stdio;
import core.thread;
import core.time;

private immutable Addrs = [
    "http://127.0.0.1:4000",
    "http://127.0.0.1:4001",
    "http://127.0.0.1:4002"
];

void main ()
{
    {
        API[3] clients;
        foreach (idx, addr; Addrs)
            clients[idx] = new RestInterfaceClient!API(addr);

        foreach (idx, ref client; clients)
        {
            writefln("[%s] getPublicKey: %s", idx, client.getPublicKey());
            writefln("[%s] getNetworkInfo: %s", idx, client.getNetworkInfo());
            const height = client.getBlockHeight();
            writefln("[%s] getBlockHeight: %s", idx, height);
            writeln("----------------------------------------");
            assert(height == 0);
        }

        auto kp = getGenesisKeyPair();

        foreach (idx; 0 .. 8)
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
    }

    {
        // TODO: This is a hack because of issue #312
        // https://github.com/bpfkorea/agora/issues/312
        API[3] clients;
        foreach (idx, addr; Addrs)
            clients[idx] = new RestInterfaceClient!API(addr);

        Hash blockHash;
        size_t times; // Number of times we slept for 50 msecs
        foreach (idx, ref client; clients)
        {
        Start:
            Thread.sleep(50.msecs);
            const height = client.getBlockHeight();
            // Retry if we're too early
            if (height < 1 && times++ < 100) goto Start;
            const blocks = client.getBlocksFrom(0, 42);
            writefln("[%s] getBlockHeight: %s", idx, height);
            writefln("[%s] getBlocksFrom: %s", idx, blocks.map!prettify);
            writeln("----------------------------------------");
            assert(height == 1);
            assert(blocks.length == 2);
            if (idx != 0)
                assert(blockHash == hashFull(blocks[1].header));
            else
                blockHash = hashFull(blocks[1].header);
            times = 0;
        }
    }
}

/// Copied from Agora
public KeyPair getGenesisKeyPair ()
{
    return KeyPair.fromSeed(
        Seed.fromString(
            "SCT4KKJNYLTQO4TVDPVJQZEONTVVW66YLRWAINWI3FZDY7U4JS4JJEI4"));
}
