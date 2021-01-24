#!/usr/bin/env dub
/+
 dub.json:
 {
     "name": "tracy_build"
 }
 +/
/*******************************************************************************

    Build the single object `TracyClient.cpp`

    Copyright:
        Copyright (c) 2021 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module build_tracy;

import std.file;
import std.path;
import std.process;
import std.range;
import std.stdio;

immutable RootPath    = __FILE_FULL_PATH__.dirName().dirName();
immutable TracySourcePath  = RootPath
    .buildPath("submodules", "tracy", "TracyClient.cpp");


version (Windows)
{
    immutable ObjExt = `.obj`;
    immutable CppCmd = [
        `cl`, `/std:c++14`, `/DEBUG`, `/c`, `/D "TRACY_ENABLE"`,
        `/Fo"` ~ OutputFile ~ `"`, TracySourcePath,
    ];
}
else
{
    immutable ObjExt = `.o`;
    immutable CppCmd = [
        `gcc`, `-std=c++14`, `-g`, `-c`, `-DTRACY_ENABLE`,
        `-o`, OutputFile, TracySourcePath,
    ];
}

immutable OutputFile = RootPath.buildPath("build", "TracyClient" ~ ObjExt);

int main (string[] args)
{
    if (OutputFile.exists)
    {
        const objModif = timeLastModified(OutputFile);
        const srcModif = timeLastModified(TracySourcePath);
        const selfModif = timeLastModified(__FILE_FULL_PATH__);
        if (objModif >= srcModif && objModif >= selfModif)
        {
            writeln("Target ", OutputFile, " is up to date, nothing to do");
            return 0;
        }
        if (srcModif > objModif)
            writeln("Tracy server source has changed, rebuilding...");
        else if (selfModif > objModif)
            writeln("Build script for Tracy server has changed, rebuilding...");
    }
    else
        writeln("Performing first build of ", OutputFile);

    immutable strCmd = CppCmd.join(" ");
    auto pid = executeShell(strCmd);

    if (pid.status != 0)
    {
        stderr.writeln("Tracy build failed: ", pid.output);
        return 1;
    }
    return 0;
}
