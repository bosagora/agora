#!/usr/bin/env rdmd
module system_integration_test;

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
/// Configuration file for docker-compose
immutable ComposeFile = IntegrationPath.buildPath("docker-compose.yml");

/+ ***************************** Commands to run **************************** +/
/// A simple test to ensure that the container works correctly,
/// e.g. all dependencies are installed and the binary isn't corrupt.
immutable BuildImg = [ "docker", "build", "--build-arg", `DUB_OPTIONS=-b cov`,
                       "-t", "agora", RootPath, ];
immutable DockerComposeUp = [ "docker-compose", "-f", ComposeFile, "up", ];
immutable DockerComposeDown = [ "docker-compose", "-f", ComposeFile, "down", ];
immutable DockerComposeLogs = [ "docker-compose", "-f", ComposeFile, "logs", "-t", ];
immutable RunIntegrationTests = [ "dub", "--root", IntegrationPath, "--",
                                    "http://127.0.0.1:4000",
                                    "http://127.0.0.1:4002",
                                    "http://127.0.0.1:4003",
                                    "http://127.0.0.1:4004",
                                    "http://127.0.0.1:4005",
                                    "http://127.0.0.1:4006",
                                    "http://127.0.0.1:4007",
];
immutable Cleanup = [ "rm", "-rf", IntegrationPath.buildPath("node/0/.cache/"),
                      IntegrationPath.buildPath("node/2/.cache/"),
                      IntegrationPath.buildPath("node/3/.cache/"),
                      IntegrationPath.buildPath("node/4/.cache/"),
                      IntegrationPath.buildPath("node/5/.cache/"),
                      IntegrationPath.buildPath("node/6/.cache/"),
                      IntegrationPath.buildPath("node/7/.cache/"),
];

private int main (string[] args)
{
    // Use a recognizable value so that if an unexpected code path is taken,
    // we see it. Success sets this to 0, failure to 1.x
    int code = 42;

    // If the user pass `nobuild` as first argument, skip docker image build,
    // which is the most expensive operation this script performs
    if (args.length < 2 || args[1] != "nobuild")
        runCmd(BuildImg);

    // First make sure that there we start from a clean slate,
    // as the docker-compose bind volumes
    runCmd(Cleanup);

    writeln(DockerComposeUp);
    auto upPid = spawnProcess(DockerComposeUp);

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

/// Utility function
private int errorOut (ProcessPipes pp)
{
    pp.stderr.byLine.each!(a => writeln("[fatal]\t", a));
    return 1;
}
