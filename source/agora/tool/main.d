/+
 dub.sdl:
 name "sometest"
 dependency "vibe-d" version="~>0.8"
+/

import agora.common.Types;
import agora.api.FullNode;
import agora.common.crypto.Key;
import agora.common.Serializer;
import agora.consensus.data.genesis.Test;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXOSetValue;
import agora.consensus.UTXOSet;
import agora.utils.Test;

import std.algorithm;
import std.random;
import std.range;
import std.stdio;

import core.time;

import vibe.core.core;
import vibe.core.log;
import vibe.web.rest;

final class MyUTXOSet : UTXOSet
{
    public this ()
    {
        super(":memory:");
    }

    public int opApply (scope int delegate (const Hash, const UTXOSetValue) dg)
    {
        auto results = this.utxo_db.db.execute("SELECT key, val FROM utxo_map");
        foreach (row; results)
        {
            const key = deserializeFull!Hash(row.peek!(ubyte[])(0));
            const value = deserializeFull!UTXOSetValue(row.peek!(ubyte[])(1));
            if (auto ret = dg(key, value))
                return ret;
        }
        return 0;
    }
}

public int sendTransaction (string address, uint take)
{
    auto node = new RestInterfaceClient!API(address);
    logInfo("The address of node is %s", address);
    const height = node.getBlockHeight();
    logInfo("The initial block height is: %s", height);
    const blocks = node.getBlocksFrom(0, cast(uint) (height + 1));
    scope utxos = new MyUTXOSet();

    foreach (ref b; blocks)
        foreach (ref tx; b.txs)
            if (tx.type == TxType.Payment)
                utxos.updateUTXOCache(tx, Height(0));

    const utxo_len = utxos.length();
    logInfo("Populated %s UTXOs", utxo_len);

    // If there are less than 50 UTXOs
    // then print the current UTXO set
    if (utxo_len < 50)
        foreach (key, utxo; utxos)
            logInfo("UTXO: [%s] %s", key, utxo);

    immutable size_t WKKeysCount = 1378;

    auto txs = blocks[$ - 1].spendable().map!(txb => txb.split(
                    WK.Keys.byRange().drop(uniform(0, WKKeysCount - take, rndGen))
                    .take(take).map!(k => k.address)).sign()).array();

    void send ()
    {
        foreach (tx; txs)
        {
            node.putTransaction(tx);
            logInfo("Transaction sent: %s", tx);
        }

        txs = txs.map!(txb => TxBuilder(txb).split(
                 WK.Keys.byRange().drop(uniform(0, 1378 - take, rndGen))
                 .take(take).map!(k => k.address))
                 .sign()).array();
    }

    setTimer(15.seconds, &send, true);

    return runEventLoop();
}

/// Print help
public void printDefaultHelp ()
{
    writeln("usage: tool <node number>");
    writeln("There are 6 nodes, from Node 2 to Node 7.");
}

int main (string[] args)
{
    if (args.length < 2 || args.length > 2)
    {
        logInfo("Please enter one value");
        printDefaultHelp();
        return 0;
    }

    const string command = args[1];
    auto take = 5;

    switch (command)
    {
    case "2":
        sendTransaction("http://eu-002.bosagora.io:2826", take);
        break;

    case "3":
        sendTransaction("http://eu-002.bosagora.io:3826", take);
        break;

    case "4":
        sendTransaction("http://na-001.bosagora.io:4826", take);
        break;

    case "5":
        sendTransaction("http://na-001.bosagora.io:5826", take);
        break;

    case "6":
        sendTransaction("http://na-002.bosagora.io:6826", take);
        break;

    case "7":
         sendTransaction("http://na-002.bosagora.io:7826", take);
         break;

    default:
        logInfo("%s is an invalid node number.", command);
        logInfo("Please enter valid number from 2 to 7.");
        break;
    }

    return 0;
}
