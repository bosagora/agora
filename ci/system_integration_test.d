#!/usr/bin/env rdmd
module system_integration_test;

private:

import std.algorithm;
import std.algorithm.iteration;
import std.range;
import std.file;
import std.format;
import std.path;
import std.process;
import std.stdio;
import core.sys.posix.signal;

/// Root of the repository
immutable RootPath = __FILE_FULL_PATH__.dirName.dirName;
immutable IntegrationPath = RootPath.buildPath("tests").buildPath("system");
/// Configuration file for docker-compose
immutable ComposeFile = IntegrationPath.buildPath("docker-compose.yml");

/+ ***************************** Commands to run **************************** +/
/// A simple test to ensure that the container works correctly,
/// e.g. all dependencies are installed and the binary isn't corrupt.
immutable BuildImg = [ "docker", "build", "--build-arg", `DUB_OPTIONS=-b cov`,
                       "-t", "agora", RootPath, ];
immutable TestContainer = [ "docker", "run", "agora", "--help", ];
immutable DockerComposeUp = [ "docker-compose", "-f", ComposeFile, "up", "--abort-on-container-exit", ];
immutable DockerComposeDown = [ "docker-compose", "-f", ComposeFile, "down", ];
immutable DockerComposeLogs = [ "docker-compose", "-f", ComposeFile, "logs", "-t", ];
immutable RunIntegrationTests = [ "dub", "--root", IntegrationPath, "--", ];
immutable Cleanup = [ "rm", "-rf", ];

auto Nodes = iota(8);
private auto testNodes() {
    return Nodes.filter!(i => i != 1); // Until we get a vanity address for node 1
}

private int main (string[] args)
{
    // Use a recognizable value so that if an unexpected code path is taken,
    // we see it. Success sets this to 0, failure to 1.x
    int code = 42;

    // If the user pass `nobuild` as first argument, skip docker image build,
    // which is the most expensive operation this script performs
    if (args.length < 2 || args[1] != "nobuild")
        runCmd(BuildImg);

    // Simple sanity test
    runCmd(TestContainer);

    // First make sure that there we start from a clean slate,
    // as the docker-compose bind volumes and we write docker log files on failure
    runCmd(
        Cleanup ~ 
        testNodes.map!(i => IntegrationPath.buildPath(format("node/%s/.cache/",i))).array() ~
        testNodes.map!(i => IntegrationPath.buildPath(format("node/%s/docker.log",i))).array()
        );

    // We need to have a "foreground" process to use `--abort-on-container-exit`
    // This option allows us to detect when the node stops / crash even before
    // the test starts (or after it completes).
    // So we start this process with `spawnProcess` and kill it with SIGINT,
    // simulating a CTRL+C
    writeln(DockerComposeUp);
    auto upPid = spawnProcess(DockerComposeUp);

    try
    {
        // Now run the tests
        runCmd(
            RunIntegrationTests ~ 
            testNodes.map!(i => format("http://127.0.0.1:400%s", i)).array()
            );
        code = 0;
    }
    catch (Exception e)
    {
        testNodes.each!(
            i => runCmdOutputToFile(
                DockerComposeLogs ~ format("node-%s", i), 
                IntegrationPath.buildPath(format("node/%s/docker.log",i)))
                );
        code = 1;
    }

    upPid.kill(SIGINT);
    if (auto upCode = upPid.wait())
    {
        writeln("docker-compose up returned error code: ", upCode);
        code = 1;
    }
    runCmd(DockerComposeDown);

    return code;
}

/// Utility function to run a command and throw on error
private void runCmd (const string[] cmd)
{
    writeln(cmd);
    auto pid = spawnProcess(cmd);
    if (pid.wait() != 0)
        throw new Exception(format("Command failed: %s", cmd));
}

/// Utility function to run a command and throw on error
private void runCmdOutputToFile (const string[] cmd, const string outputFile)
{
    auto outFile = File(outputFile, "w");
    writeln(cmd);
    writeln("Output to logfile ", outFile);
    auto pid = spawnProcess(cmd, std.stdio.stdin, outFile, std.stdio.stderr);
    if (pid.wait() != 0)
        throw new Exception(format("Command failed: %s", cmd));
}

/// Utility function
private int errorOut (ProcessPipes pp)
{
    pp.stderr.byLine.each!(a => writeln("[fatal]\t", a));
    return 1;
}
