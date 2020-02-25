/*******************************************************************************

    The Agora client sub-function for default command

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.client.DefaultProcess;

import agora.client.Result;

import std.getopt;

/// Basic Option
private struct DefaultOption
{
    /// Help of this CLI
    public bool help;

    /// Version of this CLI
    public bool ver;
}

/// Parse the ommand-line arguments of basic (--version, --help)
public GetoptResult parseDefaultOption (ref DefaultOption basic, string[] args)
{
    return getopt(
        args,
        "version|v",
            "Version of this application",
            &basic.ver,

        "help|h",
            "Help of this application",
            &basic.help
    );
}

/// Print help
public void printDefaultHelp (ref string[] outputs)
{
    outputs ~= "usage: agora-client [--help]";
    outputs ~= "                  <command> [<args>]";
    outputs ~= "";
    outputs ~= "These are commands:";
    outputs ~= "   sendtx      Send a transaction to node";
    outputs ~= "";
}

/// process --version / --help
public int defaultProcess (string[] args, ref string[] outputs)
{
    DefaultOption basic;

    try
    {
        parseDefaultOption(basic, args);
        if (basic.help)
        {
            printDefaultHelp(outputs);
            return CLIENT_SUCCESS;
        }

        if (basic.ver)
        {
            outputs ~= "agora-client version 1.00.0";
            return CLIENT_SUCCESS;
        }
        return CLIENT_INVALID_ARGUMENTS;
    }
    catch (Exception ex)
    {
        printDefaultHelp(outputs);
        return CLIENT_EXCEPTION;
    }
}
