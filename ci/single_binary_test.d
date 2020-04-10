#!/usr/bin/env rdmd
module system_binary_test;

private:

import std.algorithm;
import std.file;
import std.format;
import std.path;
import std.process;
import std.stdio;
import core.sys.posix.signal;

/// Root of the repository
immutable RootPath = __FILE_FULL_PATH__.dirName.dirName;
immutable IntegrationPath = RootPath.buildPath("tests").buildPath("system");

/+ ***************************** Commands to run **************************** +/
/// A simple test to ensure that the container works correctly,
/// e.g. all dependencies are installed and the binary isn't corrupt.
immutable BuildBinary = [ "dub", "build", "-c", "multi", ];
immutable StartNodes = [ "build/agora-multi", IntegrationPath, "node/0/config.yaml",
    "node/1/config.yaml", "node/2/config.yaml", "node/3/config.yaml"];
immutable RunIntegrationTests = [ "dub", "--root", IntegrationPath, "--",
                                    "http://127.0.0.1:2826",
                                    "http://127.0.0.1:3826",
                                    "http://127.0.0.1:4826",
                                    "http://127.0.0.1:5826"];
immutable Cleanup = [ "rm", "-rf", IntegrationPath.buildPath("node/0/.cache/"),
                      IntegrationPath.buildPath("node/1/.cache/"),
                      IntegrationPath.buildPath("node/2/.cache/"),
                      IntegrationPath.buildPath("node/3/.cache/")];

private int main (string[] args)
{
    // If the user pass `nobuild` as first argument, skip build,
    // Build `agora-multi`
    if (args.length < 2 || args[1] != "nobuild")
        runCmd(BuildBinary);

    // First make sure that there we start from a clean slate,
    runCmd(Cleanup);

    // Start Nodes
    auto binary_pid = runCmdNoBlock(StartNodes);

    // Run tests
    runCmd(RunIntegrationTests);

    // Shut down network cleanly
    kill(binary_pid, SIGTERM);
    if (auto retval = binary_pid.wait())
        assert(retval == -SIGTERM, format("Shutting down nodes failed  with code %d!", retval));
    return 0;
}

/// Utility function to run a command and throw on error
private void runCmd (const string[] cmd)
{
    writeln(cmd);
    auto pid = spawnProcess(cmd);
    if (pid.wait() != 0)
        throw new Exception(format("Command failed: %s", cmd));
}

/// Utility function to run a command
private Pid runCmdNoBlock (const string[] cmd)
{
    writeln(cmd);
    return spawnProcess(cmd);
}

/// Utility function
private int errorOut (ProcessPipes pp)
{
    pp.stderr.byLine.each!(a => writeln("[fatal]\t", a));
    return 1;
}
