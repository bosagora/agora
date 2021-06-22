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
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module update;

import std.algorithm : among;
static import std.file;
import std.format;
import std.path;
import std.range;
import std.process;
import std.stdio;

private:

immutable ScriptPath = __FILE_FULL_PATH__.dirName();

struct Mapping
{
    // Path inside stellar-core
    string source;
    // Path inside Agora's repo
    string target;
}

immutable Mapping[] Mappings = [
    { source: "lib/util/cbitset.c", target: "lib/util/cbitset.cpp" },
    { source: "src/herder/QuorumIntersectionChecker.h", target: "src/quorum/QuorumIntersectionChecker.h" },
    { source: "src/herder/QuorumIntersectionCheckerImpl.cpp", target: "src/quorum/QuorumIntersectionCheckerImpl.cpp" },
    { source: "src/herder/QuorumIntersectionCheckerImpl.h", target: "src/quorum/QuorumIntersectionCheckerImpl.h" },
    { source: "src/herder/QuorumTracker.cpp", target: "src/quorum/QuorumTracker.cpp" },
    { source: "src/herder/QuorumTracker.h", target: "src/quorum/QuorumTracker.h" },
];

/// The list of target files that should be ignored by this script
/// The main reason to ignore a file is that a large diff is to be expected,
/// but the file still needs to keep the same name for include purpose,
/// or the file does not exists in SCP.
immutable string[] Excluded = [
    // We want to get rid of those two files, but dependencies still exist
    "src/crypto/SecretKey.cpp",
    "src/crypto/SecretKey.h",
    // We replace upstream's logging with our own, so we have a large diff
    "src/util/Logging.cpp",
    "src/util/Logging.h",
    // We define our own types
    "src/xdr/Stellar-types.h",
];

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
    string[string] maps;
    bool[string] excludedSet;

    if (!std.file.exists(stellarPath))
        return fail("Error: %s does not exists", stellarPath);
    if (!std.file.isDir(stellarPath))
        return fail("Error: %s is not a directory", stellarPath);

    // Populate mappings using absolute path
    // Since the update is driven by the files in agora,
    // use the target as the key to the AA.
    foreach (const ref m; Mappings)
        maps[cast(string)rootPath.buildPath(m.target).asNormalizedPath.array]
            = stellarPath.buildPath(m.source);
    foreach (const ref e; Excluded)
        excludedSet[cast(string)rootPath.buildPath(e).asNormalizedPath.array] = true;

    bool updateDirectory (const(char)[] directory)
    {
        immutable path = rootPath.buildPath(directory);
        auto files = std.file.dirEntries(path, "*.{x,h*,c*}",
                                         std.file.SpanMode.depth);
        foreach (target; files)
        {
            const relTarget = target.asRelativePath(path).array;
            const absTarget = buildPath(rootPath, directory, relTarget).asNormalizedPath().array;

            if (absTarget in excludedSet)
            {
                stdout.writeln("Skipping excluded file ", absTarget);
                continue;
            }

            const char[] source = () {
                // Make the compiler infer the correct return type...
                if (42 == 84) return (const(char)[]).init;
                // Check if there's a mapping overriding the default behavior
                if (auto t = absTarget in maps)
                    return *t;
                // Otherwise assume the file name is the same
                return only(stellarPath, directory, relTarget)
                    .buildPath().asNormalizedPath.array;
            }();

            if (!updateFile(source, absTarget))
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
bool updateFile (const(char)[] source, const(char)[] target)
{
    if (!std.file.exists(target) || !std.file.isFile(target))
        return ask(format("Target file '%s' does not exists or is not a file, skip it and continue", target))
            == Action.Yes;
    if (!std.file.exists(source) || !std.file.isFile(source))
        return ask(format("Origin file '%s' does not exists or is not a file, skip it and continue", target))
            == Action.Yes;

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
