/*******************************************************************************

    Command line utility to send the blockchain history to an HTTP endpoint

    This utility is intended to be used with a `stoa` node,
    the API node for Agora.
    It reads a block storage, parses it, and send the selected blocks to the
    provided address.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.cli.history.main;

import agora.common.Types;
import agora.consensus.data.Block;
import agora.node.BlockStorage;

import vibe.data.json;

static import std.file;
import std.getopt;
import std.net.curl;
import std.stdio;

/// Entry point
private int main (string[] args)
{
    BlockRange range = BlockRange(0, ulong.max);
    auto helpInfo = getopt(
        args,
        "from|f",  &range.from,
        "to|t",    &range.to,
    );

    if (args.length < 3)
    {
        stderr.writeln("Error: Expected 2 positional arguments, got ", args.length - 1);
        helpInfo.helpWanted = true;
    }
    if (range.from > range.to)
    {
        stderr.writeln("Error: --from (", range.from,
                       ") must be less than or equal to --to (", range.to, ")");
        helpInfo.helpWanted = true;
    }
    if (helpInfo.helpWanted)
    {
        defaultGetoptPrinter("Sends HTTP requests to a Stoa node.
SYNTAX:
\t./agora-history-push [Options] path/to/storage http://stoa.endpoint/push",
                             helpInfo.options);
        return 1;
    }

    immutable string storagePath = args[1];
    if (!std.file.exists(storagePath))
    {
        stderr.writeln("Error: Path does not exists: ", storagePath);
        return 1;
    }
    if (!std.file.isDir(storagePath))
    {
        stderr.writeln("Error: Path is not a directory: ", storagePath);
        return 1;
    }

    scope storage = new BlockStorage(args[1]);
    if (!storage.load())
    {
        stderr.writeln("Error: Failed to open storage: ", args[1]);
        return 1;
    }

    immutable string url = args[2];
    Height current = Height(range.from);
    Block block;
    // BlockStorage actually doesn't tell if the reading was unsuccessful
    // or the height isn't available
    while (current <= range.to)
    {
        if (!storage.tryReadBlock(block, current))
            break;

        stderr.write("\rSending block #", current.value);
        stderr.flush();

        auto jsonStr = block.serializeToJsonString();
        try
            post(url, [ "block": jsonStr ]);
        catch (Exception e)
        {
            stderr.writeln();
            stderr.writeln(
                "Error while sending block #", current.value - range.to,
                " (height: ", current.value, ") to \"", url, "\": ", e);
            return 1;
        }
        current.value++;
    }
    stdout.writeln("\rSent a total of ", current.value - range.to, " blocks");
    return 0;
}

/// A range of blocks to send
private struct BlockRange
{
    /// The block to send from (included)
    public ulong from;
    /// The last block to send (included)
    public ulong to;
}
