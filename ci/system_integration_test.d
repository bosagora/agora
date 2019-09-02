#!/usr/bin/env rdmd
module system_integration_test;

private:

import std.algorithm;
import std.file;
import std.format;
import std.path;
import std.process;
import std.stdio;

/// Root of the repository
immutable RootPath = __FILE_FULL_PATH__.dirName.dirName;

/+ ***************************** Commands to run **************************** +/
/// A simple test to ensure that the container works correctly,
/// e.g. all dependencies are installed and the binary isn't corrupt.
immutable BuildImg = [ "docker", "build", "--build-arg", `DUB_OPTIONS=-b cov`,
                       "-t", "agora", RootPath, ];
immutable TestContainer = [ "docker", "run", "agora", "--help", ];

private int main ()
{
    runCmd(BuildImg);
    runCmd(TestContainer);

    return 0;
}

/// Utility function to run a command and throw on error
private void runCmd (const string[] cmd)
{
    auto pid = spawnProcess(cmd);
    if (pid.wait() != 0)
        throw new Exception(format("Command failed: %s", cmd));
}

/// Utility function
private int errorOut (ProcessPipes pp)
{
    pp.stderr.byLine.each!(a => writeln("[fatal]\t", a));
    return 1;
}
