#!/usr/bin/env rdmd
module unittest_runner;

private:

import std.algorithm;
import std.conv;
import std.file;
import std.format;
import std.path;
import std.process;
import std.stdio;

import core.sys.posix.signal;
import core.thread;
import core.time;

private int main (string[] args)
{
    // start tests
    auto binary_pid = spawnProcess(["./build/agora-unittests"], std.stdio.stdin, std.stdio.stdout, std.stdio.stderr,
        ["dchatty" : "1"]);

    import std.datetime.stopwatch : StopWatch;

    StopWatch sw;
    sw.start();

    while (1)
    {
        if (tryWait(binary_pid).terminated)
        {
            writeln("Unittests passed.");
            return 0;  // nothing to do
        }

        Thread.sleep(30.seconds);
        writefln("Slept for %s", sw.peek);

        if (sw.peek > 6.minutes)
            break;
    }

    //writefln("-- Attaching to process");
    //stdout.flush();

    //version (OSX)
    //    auto dbg = runCmdNoBlock(["/usr/bin/lldb", "-p", binary_pid.processID.to!string, "process save-core"]);

    //version (linux)
    //    auto dbg = runCmdNoBlock(["/usr/bin/gdb", "-p", binary_pid.processID.to!string, "-ex", "generate-core-file"]);

    //// wait for debugger to finish printing
    //Thread.sleep(1.minutes);

    //kill(dbg, SIGKILL);
    writefln("-- Sending SIGSEGV");
    kill(binary_pid, SIGSEGV);
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
private Pid runCmdNoBlock (Args...)(Args args)
{
    writeln(args);
    return spawnProcess(args);
}
