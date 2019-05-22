#!/usr/bin/env rdmd
/*******************************************************************************

    Helper script to update scp code based on Stellar

    Note:
      Install `colordiff` for a much better experience

    TODO:
      - Add support for patch files
      - Checkout `stellar-core` in code
      - Remove dependency on compilation step

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module update;

import std.algorithm : among;
static import std.file;
import std.path;
import std.process;
import std.stdio;

private:

immutable ScriptPath = __FILE_FULL_PATH__.dirName();

immutable string ColorDiff;
shared static this ()
{
    ColorDiff = getColorDiff();
}

/// Entry point
int main (string[] args)
{
    if (args.length < 2)
        return fail("Error: Expected first argument to be the path to "
                    ~ "`stellar-core`");

    immutable rootPath = ScriptPath.absolutePath();
    immutable stellarPath = args[1].absolutePath();

    if (!std.file.exists(stellarPath))
        return fail("Error: %s does not exists", stellarPath);
    if (!std.file.isDir(stellarPath))
        return fail("Error: %s is not a directory", stellarPath);

    bool updateDirectory (const(char)[] directory)
    {
        immutable path = rootPath.buildPath(directory);
        auto files = std.file.dirEntries(path, "*.{x,h*,c*}",
                                         std.file.SpanMode.depth);
        foreach (target; files)
        {
            import std.range;
            auto source = stellarPath.buildPath(directory, target.asRelativePath(path).array);
            if (!updateFile(source, target))
                return false;
        }
        return true;
    }


    if (!updateDirectory("lib"))
        return 1;
    if (!updateDirectory("src"))
        return 1;
    return 0;
}

/// Returns:
///   The path to `colordiff`, or `cat` if `colordiff` is not in the $PATH
string getColorDiff ()
{
    auto res = executeShell("which colordiff");
    if (res.status != 0)
        return "cat";
    return "colordiff";
}

/// Handy function to terminate
int fail (Args...)(const(char)[] msg, Args args)
{
    stderr.writefln(msg, args);
    return 1;
}

/// Simple enum to ask a question
enum Action
{
    Repeat = 0,
    Yes,
    No,
    Quit,
}

/// Ask a question until the answer is understood
Action ask (const(char)[] question)
{
    Action response;
    do {
        response = askSingle(question);
    } while (response == Action.Repeat);
    return response;
}

/// Ask a question a single time
///
/// Returns:
/// An `Action` according to the user's input.
/// If the answer is not understood (e.g. 't'), returns `Action.Repeat`
Action askSingle (const(char)[] question)
{
    stdout.write(question, ": y(es) / (n)o / (q)uit: ");
    stdout.flush();
    auto answer = readln()[0 .. $ - 1];
    if (!answer.length)
        return Action.Repeat;
    if (answer.among("y", "Y", "yes", "Yes", "YES"))
        return Action.Yes;
    if (answer.among("n", "N", "no", "No", "NO"))
        return Action.No;
    if (answer.among("q", "Q", "quit", "Quit", "QUIT"))
        return Action.Quit;
    return Action.Repeat;
}

/// Update a single file
///
/// Returns:
/// `true` => Keep updating, `false` => Exit
bool updateFile (string source, string target)
{
    if (!std.file.exists(target) || !std.file.isFile(target))
        return !fail("Error: %s does not exists or is not a file", target);
    if (!std.file.exists(source) || !std.file.isFile(source))
        return !fail("Error: %s does not exists or is not a file", source);

    auto pid = executeShell("diff " ~ target ~ " " ~ source ~ " | " ~ ColorDiff);
    if (pid.status != 0)
        return !fail("Error: %s", pid.output);
    else if (!pid.output.length)
    {
        stdout.writeln("File ", target, " does not need an update");
        return true;
    }

    writeln("********** Diff for ", target, " **********");
    stdout.writeln(pid.output);

    switch (ask("Update"))
    {
    case Action.Yes:
        writeln(source, " ==> ", target);
        std.file.copy(source, target);
        return true;
    case Action.No:
        return true;
    case Action.Quit:
        return false;
    default:
        assert(0);
    }
}
