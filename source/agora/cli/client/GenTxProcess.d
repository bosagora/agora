/*******************************************************************************

    A tool which periodically generates a set of valid transactions
    and sends them to one node. The interval at which the transactions
    are sent and the number of transactions can be specified.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.client.GenTxProcess;

import agora.api.FullNode;
import agora.client.Common;
import agora.common.Amount;
import agora.common.VibeTask;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.consensus.data.genesis.Test;
import agora.crypto.Hash;
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

/// Option required to generate and send transactions
private struct GenTxOption
{
    /// Common arguments
    public ClientCLIArgs base;

    /// For convenience
    public alias base this;

    /// Interval of sending transactions
    public Duration interval = 5.seconds;

    /// Number of transactions sent at once (1 to 8)
    public uint count = 8;

    /// dump output option
    public bool dump;

    /// Parse the command-line arguments of gentx
    public GetoptResult parse (string[] args)
    {
        auto intermediate = this.base.parse(args);
        if (intermediate.helpWanted)
            return intermediate;

        return getopt(
            args,
            "interval|t",
              "Interval of sending transactions (default: 5 seconds)",
              (string _, string value) { this.interval = value.to!int.seconds; },

            "count|c",
              "Number of transactions sent at once (default: 8)",
              &this.count,

            "dump|o",
              "Dump output option",
              &this.dump,
        );
    }
}

/// Print help
public void printGenTxHelp (ref string[] outputs)
{
    outputs ~= "usage: agora-client gentx [--dump] [--interval <interval>]";
    outputs ~= "                          [--count <count>] --address <addr>";
    outputs ~= "";
    outputs ~= "   gentx      Generate and send a transaction to node";
    outputs ~= "";
    outputs ~= "        -o --dump       Dump output option";
    outputs ~= "        -i --address    Address of a node (e.g. http://agora.example.com)";
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
                         APIMaker api_maker)
{
    GenTxOption op;

    try
    {
        auto res = op.parse(args);
        if (res.helpWanted)
        {
            printGenTxHelp(outputs);
            return 0;
        }
    }
    catch (Exception ex)
    {
        writeln("Error: ", ex.msg);
        printGenTxHelp(outputs);
        return 1;
    }

    if (op.count > 8 || op.count <= 0)
    {
        printGenTxHelp(outputs);
        outputs ~= format("Cannot send more than 8 transactions. %d requested."
                          , op.count);
        return 1;
    }

    // connect to the node
    auto node = api_maker(op.address);
    auto taskman = new VibeTaskManager;
    auto last_block = node.getBlocksFrom(node.getBlockHeight(), 1)[0];
    auto txs = last_block.spendable().take(op.count)
                         .map!(txb => txb.split(
                             WK.Keys.A.address.only()).sign())
                         .array();

    // function to generate and send transactions
    void genTxs ()
    {
        txs.each!(tx => node.postTransaction(tx));
        writefln("%s transactions sent to %s.\nTransactions:",
            op.count, op.address);
        txs.each!(tx => writeln(prettify(tx)));
        txs = txs.map!(txb => TxBuilder(txb).sign()).array();
    }

    if (op.dump)
    {
        outputs ~= format("Address = %s", op.address);
        outputs ~= format("Interval = %s", op.interval);
        outputs ~= format("Count = %s", op.count);
        outputs ~= format("Transactions =");
        txs.each!(tx => outputs ~= format("%s", prettify(tx)));
        outputs ~= format("Hash =");
        txs.each!(tx => outputs ~= format("%s", hashFull(tx)));
        return 0;
    }

    genTxs();
    taskman.setTimer(op.interval, &genTxs, Periodic.Yes);

    return runEventLoop();
}
