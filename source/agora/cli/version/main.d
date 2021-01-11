#!/usr/bin/env dub
/+
 dub.json:
 {
     "name": "version_build"
 }
 +/
/*******************************************************************************

    Determine the version number that will be used during building the Agora node.

    Version number is determined in the following order:
    1. The 'AGORA_VERSION' environment variable will be used, if it is set to
       a non-empty string.
    2. Otherwise, the output of the `git describe` command will be used.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.cli.ver.main;

import std.file : exists, mkdirRecurse, readText, write;
import std.format;
import std.path;
import std.process;
import std.stdio : writeln;
import std.string;

import core.stdc.stdlib : exit;

private immutable VersionFileName = "VERSION";
private immutable RootPath = __FILE_FULL_PATH__.dirName.dirName.dirName.dirName.dirName;
private immutable VersionFileDir = RootPath.buildPath("build");
private immutable VersionFilePath = VersionFileDir.buildPath(VersionFileName);
private immutable EnvVersionName = "AGORA_VERSION";
private immutable GitDescribe = ["git", "describe"];

/// Utility function to run a command and throw on error if the command fails
private string runCmd (const string[] cmd)
{
    writeln("Executing command: ", cmd);
    auto proc_res = execute(cmd);
    if (proc_res.status != 0)
        throw new Exception(format("Command failed: %s", cmd));
    return proc_res.output;
}

/// Determine the version number
private void writeVersion ()
{
    string version_res;

    // get the version from environment variables
    if (auto from_env = environment.get(EnvVersionName))
    {
        from_env = from_env.strip();
        if (!from_env.length)
            throw new Exception(format("Environment variable %s is empty, please remove it or set to non-empty value",
                                EnvVersionName));
        version_res = from_env;
    }
    else
        // Fall back to getting the version from git
        // This will throw if we are not in a git directory
        version_res = runCmd(GitDescribe).strip();

    // In the very unlikely case of being in a git directory with no labels
    if (!version_res.length)
        throw new Exception("Unable to determine agora version number");

    // Avoid re-writting the file unless it changed
    // This avoids unnecessary rebuils due to timestamp changes.
    if (VersionFilePath.exists)
    {
        auto from_file = VersionFilePath.readText().strip();
        if (from_file == version_res)
            return;
    }

    mkdirRecurse(VersionFileDir);
    write(VersionFilePath, version_res);
}

///
public void main(string[] args)
{
    try
    {
        writeVersion();
    }
    catch (Exception e)
    {
        writeln("Exception happened while trying to determine the version number: ", e,
                "\n\nPlease make sure you are building from a git repository or the environment variable ",
                 EnvVersionName, " is set to a non-empty string.");
        throw e;
    }
    return;
}
