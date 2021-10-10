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
import agora.config.Config;

import vibe.core.core;
import vibe.web.rest;

import std.getopt;
import std.stdio;

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

    switch (args[0])
    {
        case "sendtx":
            return sendTxProcess(args, outputs, (address) {
                return new RestInterfaceClient!API(address);
            });
        case "gentx":
            return genTxProcess(args, outputs, (address) {
                return new RestInterfaceClient!API(address);
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
