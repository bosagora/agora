/*******************************************************************************

    Entry point for the Agora client

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.client.main;

import agora.api.FullNode;
import agora.client.GenTxProcess;
import agora.client.SendTxProcess;
import agora.common.Types : Address;
import agora.network.RPC;

import vibe.core.core;
import vibe.web.rest;

import configy.Read;

import std.algorithm;
import std.getopt;
import std.stdio;
import core.time;

/// Application entry point
private int main (string[] args)
{
    string[] outputs;
    auto res = runProcess(args[1 .. $], outputs);
    foreach (ref line; outputs)
        writeln(line);

    return res;
}

///
int runProcess (string[] args, ref string[] outputs)
{
    if (args.length == 0)
    {
        outputs ~= "Error: Missing '<command>' argument";
        outputs ~= "";
        printDefaultHelp(outputs);
        return 1;
    }

    API makeClient (Address address)
    {
        if (address.schema == "agora")
            return new RPCClient!(API)(
                address.host, address.port,
                0.seconds, 1, 5.seconds, 5.seconds, 5.seconds);

        if (address.schema.startsWith("http"))
            return new RestInterfaceClient!(API)(address);

        assert(0, "Unsupported address schema");
    }

    switch (args[0])
    {
        case "sendtx":
            return sendTxProcess(args, outputs, (address) {
                return makeClient(address);
            });
        case "gentx":
            return genTxProcess(args, outputs, (address) {
                return makeClient(address);
            });
        default:
            outputs ~= "Invalid command: '" ~ args[0] ~ "'";
            outputs ~= "";
            goto case;
    case "-h":
    case "--help":
            outputs.printDefaultHelp();
            return 1;
    }
}

/// Print help
public void printDefaultHelp (ref string[] outputs)
{
    outputs ~= "usage: agora-client [--help]";
    outputs ~= "                  <command> [<args>]";
    outputs ~= "";
    outputs ~= "Where command is one of:";
    outputs ~= "   sendtx      Send a transaction to node";
    outputs ~= "   gentx       Generate transactions and";
    outputs ~= "               send to node";
    outputs ~= "";
}
