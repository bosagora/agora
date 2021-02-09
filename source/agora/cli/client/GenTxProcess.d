/*******************************************************************************

    A tool which periodically generates a set of valid transactions
    and sends them to one node. The interval at which the transactions
    are sent and the number of transactions can be specified.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.client.GenTxProcess;

import agora.api.FullNode;
import agora.client.Result;
import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.consensus.data.genesis.Test;
import agora.crypto.Hash;
import agora.utils.Log;
import agora.utils.PrettyPrinter;
import agora.utils.Test;

import std.algorithm;
import std.conv;
import std.format;
import std.getopt;
import std.range;
import std.stdio;

import core.time;

import vibe.core.core;

mixin AddLogger!();

/// Option required to generate and send transactions
private struct GenTxOption
{
    /// IP address of node
    public string host;

    /// Port of node
    public ushort port;

    /// Interval of sending transactions
    public Duration interval = 5.seconds;

    /// Number of transactions sent at once (1 to 8)
    public uint count = 8;

    /// dump output option
    public bool dump;
}

/// Parse the command-line arguments of gentx
public GetoptResult parseGenTxOption (ref GenTxOption op, string[] args)
{
    return getopt(
        args,
        "ip|i",
            "IP address of node",
            &op.host,

        "port|p",
            "Port of node",
            &op.port,

        "interval|t",
            "Interval of sending transactions (default: 5 seconds)",
            (string option, string value) { op.interval = value.to!int.seconds; },

        "count|c",
            "Number of transactions sent at once (default: 8)",
            &op.count,

        "dump|o",
            "Dump output option",
            &op.dump
            );
}

/// Print help
public void printGenTxHelp (ref string[] outputs)
{
    outputs ~= "usage: agora-client gentx [--dump] [--interval <interval>]";
    outputs ~= "                          [--count <count>] --ip <host>";
    outputs ~= "                          --port <port>";
    outputs ~= "";
    outputs ~= "   gentx      Generate and send a transaction to node";
    outputs ~= "";
    outputs ~= "        -o --dump       Dump output option";
    outputs ~= "        -i --ip         IP address of node";
    outputs ~= "        -p --port       Port of node";
    outputs ~= "        -t --interval   Interval of sending transactions";
    outputs ~= "        -c --count      Number of transactions sent at once";
    outputs ~= "";
}

/*******************************************************************************

    Input arguments, generate the transaction and send it to the node

    Params:
        args = client command line arguments

*******************************************************************************/

public int genTxProcess (string[] args, ref string[] outputs,
                         API delegate (string address) api_maker)
{
    GenTxOption op;
    GetoptResult res;

    try
    {
        res = parseGenTxOption(op, args);
        if (res.helpWanted)
        {
            printGenTxHelp(outputs);
            return CLIENT_SUCCESS;
        }
    }
    catch (Exception ex)
    {
        log.info("Exception while generating transactions");
        printGenTxHelp(outputs);
        return CLIENT_EXCEPTION;
    }

    if (op.count > 8 || op.count <= 0)
    {
        printGenTxHelp(outputs);
        outputs ~= format("Cannot send more than 8 transactions. %d requested."
                          , op.count);
        return CLIENT_INVALID_ARGUMENTS;
    }

    // connect to the node
    string ip_address = format("http://%s:%s", op.host, op.port);
    auto node = api_maker(ip_address);
    auto taskman = new TaskManager;
    auto last_block = node.getBlocksFrom(node.getBlockHeight(), 1)[0];
    auto txs = last_block.spendable().take(op.count)
                         .map!(txb => txb.split(
                             WK.Keys.A.address.only()).sign())
                         .array();

    // function to generate and send transactions
    void genTxs ()
    {
        txs.each!(tx => node.putTransaction(tx));
        writefln("%s transactions sent to %s.\nTransactions:",
            op.count, ip_address);
        txs.each!(tx => writeln(prettify(tx)));
        txs = txs.map!(txb => TxBuilder(txb).sign()).array();
    }

    if (op.dump)
    {
        outputs ~= format("IP = %s", op.host);
        outputs ~= format("Port = %s", op.port);
        outputs ~= format("Interval = %s", op.interval);
        outputs ~= format("Count = %s", op.count);
        outputs ~= format("Transactions =");
        txs.each!(tx => outputs ~= format("%s", prettify(tx)));
        outputs ~= format("Hash =");
        txs.each!(tx => outputs ~= format("%s", hashFull(tx)));
        return CLIENT_SUCCESS;
    }

    genTxs();
    taskman.setTimer(op.interval, &genTxs, Periodic.Yes);

    return runEventLoop();
}
