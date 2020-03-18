#!/usr/bin/env dub
/+
 dub.json:
 {
     "name": "cpp_build"
 }
 +/
/*******************************************************************************

    Build the SCP library

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module build;

private:

import std.algorithm;
import std.datetime;
static import std.file;
import std.path;
import std.process;
import std.range;
import std.stdio;

immutable RootPath    = __FILE_FULL_PATH__.dirName();
immutable SourcePath  = RootPath;
immutable BuildPath   = RootPath.buildPath("build");
immutable BuildTarget = BuildPath.buildPath("libscp.o");

/// Path passed to `-I`
immutable Includes = [
    SourcePath,
    SourcePath.buildPath("src"),
    SourcePath.buildPath("lib"),
    SourcePath.buildPath("lib", "xdrpp"),
];

immutable CppFlags = [
    "-c",
    "-g",
    "-W",
    "-Wall",
    "-Wno-unused-parameter",
    "-fPIC",
    "-D_GLIBCXX_USE_CXX11_ABI=0",
    "-std=c++14",
];

immutable CppCmd = ["gcc" ] ~ CppFlags;

struct FileInfo
{
    string path;
    SysTime lastModified;
}

int main(string[] args)
{
    // Make sure we're in the right directory
    if (!std.file.exists(BuildPath) || !std.file.isDir(BuildPath))
        std.file.mkdir(BuildPath);
    std.file.chdir(BuildPath);

    auto xdrfiles = std.file.dirEntries(
        SourcePath, "*.x", std.file.SpanMode.depth);
    auto headers = std.file.dirEntries(
        SourcePath, "*.h*", std.file.SpanMode.depth);
    // Need to array this because we might reuse it
    auto sources = std.file.dirEntries(
        SourcePath, "*.c*", std.file.SpanMode.depth).array;
    auto objs = std.file.dirEntries(
        BuildPath, "*.o", std.file.SpanMode.depth).array;

    // If one of the obj file is older than one of the source file, rebuild
    // That's a lesser approach than the dependency tracking Makefile do,
    // but we don't expect those files to change very often.
    // If the build script has changed, we also rebuild.
    if (objs.length > sources.length)
    {
        writeln(objs.length - sources.length,
                " sources files were deleted, cleaning up build directory and doing a full rebuild...");
        std.file.chdir("../");
        std.file.rmdirRecurse(BuildPath);
        std.file.mkdir(BuildPath);
        std.file.chdir(BuildPath);
    }
    else if (objs.length == sources.length)
    {
        auto buildTs = objs.map!((v) => FileInfo(v, std.file.timeLastModified(v)))
            .minElement!((a) => a.lastModified);
        auto lastModif = chain([__FILE_FULL_PATH__], xdrfiles, headers, sources.save)
            .map!((v) => FileInfo(v, std.file.timeLastModified(v)))
            .maxElement!((a) => a.lastModified);

        if (lastModif.lastModified > buildTs.lastModified)
        {
            writeln("File ", lastModif.path, " is newer than ", buildTs.path,
                    " (", lastModif.lastModified, " > ", buildTs.lastModified,
                    "), doing a full rebuild...");
        }
        else
        {
            writeln("Target ", BuildTarget, " is up to date, nothing to do");
            return 0;
        }
    }
    else
        writeln("First build / new source files added: Doing a full build...");

    auto cmd = chain(CppCmd, Includes.map!((v) => "-I " ~ v), sources);
    auto strCmd = cmd.join(" ");
    // writeln(strCmd);
    auto pid = executeShell(strCmd);

    if (pid.status != 0)
    {
        stderr.writeln("Build failed: ", pid.output);
        return 1;
    }
    return 0;
}
