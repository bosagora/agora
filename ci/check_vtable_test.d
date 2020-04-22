#!/usr/bin/env rdmd
module check_vtable_test;

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

/+ ***************************** Commands to run **************************** +/
immutable BuildBinaryGenerate = [ "dub", "build", "-c", "checkvtable-gen", ];
immutable BuildBinaryCheck = [ "dub", "build", "-c", "checkvtable-run", ];
immutable GenerateCode = [ "build/agora-checkvtable-gen", "source/scpp/extra/DVMChecks.cpp"];
immutable CheckVTable = [ "build/agora-checkvtable-run"];

private int main ()
{
    // Build `agora-checkvtable-gen`
    runCmd(BuildBinaryGenerate);

    // Generates C++ source code
    runCmd(GenerateCode);

    // Build `agora-checkvtable-run`
    runCmd(BuildBinaryCheck);

    // Checks virtual method offset
    runCmd(CheckVTable);

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

/// Utility function
private int errorOut (ProcessPipes pp)
{
    pp.stderr.byLine.each!(a => writeln("[fatal]\t", a));
    return 1;
}
