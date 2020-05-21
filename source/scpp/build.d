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

/// Include path for C++ dependency - libsodium must be in the include path
/// (INCLUDE on Windows, and /usr/include/ or similar on POSIX)
immutable Includes = [
    SourcePath,
    SourcePath.buildPath("src"),
    SourcePath.buildPath("lib"),
    SourcePath.buildPath("lib", "xdrpp"),
];

version (Posix)
{
    immutable ObjPattern = "*.o";
    immutable CompilerIncludeFlag = "-I ";
    immutable CppFlags = [
        "-c",
        "-g",
        "-W",
        "-Wall",
        "-Wno-comment",  // ignore warnings for multi-line "//" style comments
        "-Wno-unused-parameter",
        "-fPIC",
        "-D_GLIBCXX_USE_CXX11_ABI=0",
        "-std=c++14",
    ];
    immutable CppCmd = [ "gcc" ] ~ CppFlags;
}
else version (Windows)
{
    immutable ObjPattern = "*.obj";
    immutable CompilerIncludeFlag = "/I ";
    immutable CppFlags = [
        "/JMC",
        "/MP",
        "/GS",
        "/W4",
        // https://docs.microsoft.com/en/cpp/error-messages/tool-errors/linker-tools-warning-lnk4099?view=vs-2019
        // Remove warning : PDB file not found
        "/wd\"4099\"",
        // https://docs.microsoft.com/en/cpp/error-messages/compiler-warnings/compiler-warning-level-4-c4100?view=vs-2019
        // Remove warning 'identifier' : unreferenced formal parameter
        "/wd\"4100\"",
        // https://docs.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warning-level-4-c4127?view=vs-2019
        // Remove warning : conditional expression is constant
        "/wd\"4127\"",
        // https://docs.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warning-level-4-c4324?view=vs-2019
        // Remove warning 'struct_name' : structure was padded due to __declspec(align())
        "/wd\"4324\"",
        // https://docs.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warning-level-4-c4408?view=vs-2019
        // Remove warning : anonymous struct or union did not declare any data members
        "/wd\"4408\"",
        // https://docs.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warning-level-4-c4510?view=vs-2019
        // Remove warning 'class' : default constructor could not be generated
        "/wd\"4510\"",
        // https://docs.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warning-level-4-c4512?view=vs-2019
        // Remove warning 'class' : assignment operator could not be generated
        "/Zc:wchar_t",
        "/Zi",
        "/Gm-",
        "/Od",
        "/sdl",
        "/fp:precise",
        "/D \"BUILD_TESTS\"",
        "/D \"WIN32_LEAN_AND_MEAN\"",
        "/D \"NOMINMAX\"",
        "/D \"_WINSOCK_DEPRECATED_NO_WARNINGS\"",
        "/D \"SODIUM_STATIC\"",
        "/D \"_CRT_SECURE_NO_WARNINGS\"",
        "/D \"_WIN32_WINNT=0x0601\"",
        "/D \"WIN32\"",
        "/D \"_MBCS\"",
        "/D \"_CRT_NONSTDC_NO_DEPRECATE\"",
        "/errorReport:prompt",
        "/WX-",
        "/Zc:forScope",
        "/RTC1",
        "/Gd",
        "/std:c++14",
        "/FC",
        "/EHsc",
        "/c"
    ];
    immutable CppCmd = [ "cl" ] ~ CppFlags;
}
else
    static assert(0, "Unsupported platform");

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
        BuildPath, ObjPattern, std.file.SpanMode.depth).array;

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

    auto cmd = chain(CppCmd, Includes.map!((v) => CompilerIncludeFlag ~ v), sources);
    auto strCmd = cmd.join(" ");
    writeln(strCmd);
    auto pid = executeShell(strCmd);

    if (pid.status != 0)
    {
        stderr.writeln("Build failed: ", pid.output);
        return 1;
    }
    return 0;
}
