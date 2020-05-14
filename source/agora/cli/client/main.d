/*******************************************************************************

    Entry point for the Agora client

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.client.main;

import agora.api.FullNode;
import agora.client.Result;
import agora.client.DefaultProcess;
import agora.client.SendTxProcess;

import vibe.core.core;
import vibe.web.rest;

import std.stdio;

/// Workaround for issue likely related to dub #225,
/// expects a main() function and invokes it after unittesting.
version (unittest) void main () { } else:

/// Application entry point
private int main (string[] args)
{
    string[] outputs;
    auto res = runProcess(args, outputs);

    foreach (ref line; outputs)
        writeln(line);

    return res;
}

///
int runProcess (string[] args, ref string[] outputs)
{
    if (args.length < 2)
    {
        printDefaultHelp(outputs);
        return CLIENT_SUCCESS;
    }

    const string command = args[1];
    switch (command)
    {
        case "sendtx":
            return sendTxProcess(args, outputs, (address) {
                return new RestInterfaceClient!API(address);
            });
        default :
            return defaultProcess(args, outputs);
    }
}
