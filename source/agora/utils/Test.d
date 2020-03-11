/*******************************************************************************

    Various utilities for testing purpose

    Utilities in this module can be used in test code.
    There are currently multiple testing approaches:
    - Unittests in the various `agora` module, the most common, cheapest,
      and a way to do white box testing;
    - Unittests under `agora.test`: Those unittests rely on the LocalRest
      library to simulate a network where nodes are thread who communicate
      via message passing.
    - Unit integration tests in `${ROOT}/tests/unit/` which are similar to
      unittests but provide a way to test IO-using code.
    - System integration tests: those are fully fledged tests that spawns
      unmodified, real nodes within Docker containers and act as a client.

    Any symbol in this module can be used by any of those method,
    which is why this module is neither restricted by `package(agora):`
    nor `version(unittest):`.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.Test;

import std.file;
import std.path;

import core.time;

/*******************************************************************************

    Get a temporary directory for unit integration tests

    Tests that do IO usually write or read files from disk.
    We want our tests to be reliable, reproducible, and re-runnable.
    For this reason, this function returns a path which has been `mkdir`ed
    after having been cleaned, which is located in the temporary directory.
    Consistent usage of this allows unit integration tests to be run in parallel
    (however the same test cannot be run multiple times in parallel,
    unless a different postfix is specified each time).

    Params:
      postfix = A unique postfix for the calling test

    Returns:
      The path of a clean, empty directory

*******************************************************************************/

public string makeCleanTempDir (string postfix = __MODULE__)
{
    string path = tempDir().buildPath("agora_testing_framework", postfix);
    // Note: The following path is only triggered when rebuilding locally,
    // code coverage is run from a clean slate so the `rmdirRecurse`
    // is never tested, hence the single-line statement helps with code coverage.
    if (path.exists) rmdirRecurse(path);
    mkdirRecurse(path);
    return path;
}

/*******************************************************************************

    Keeps retrying the 'check' condition until it is true,
    or until the timeout expires. It will sleep the main
    thread for 100 msecs between each re-try.

    If the timeout expires, and the 'check' condition is still false,
    it throws an AssertError.

    Params:
        check = the condition to check on
        timeout = time to wait for the check to succeed
        msg = optional AssertException message when the condition fails
              after the timeout expires
        file = file from the call site
        line = line from the call site

    Throws:
        AssertError if the timeout is reached and the condition still fails

*******************************************************************************/

public void retryFor (lazy bool check, Duration timeout,
    lazy string msg = "", string file = __FILE__, size_t line = __LINE__)
{
    import core.exception;
    import core.thread;
    import std.format;

    // wait 100 msecs between attempts
    const SleepTime = 100;
    auto attempts = timeout.total!"msecs" / SleepTime;
    const TotalAttempts = attempts;

    while (attempts--)
    {
        if (check)
            return;

        Thread.sleep(SleepTime.msecs);
    }

    auto assert_msg = format("Check condition failed after timeout of %s " ~
        "and %s attempts", timeout, TotalAttempts);

    if (msg.length)
        assert_msg ~= ": " ~ msg;

    throw new AssertError(assert_msg, file, line);
}

///
unittest
{
    import core.exception;
    import std.exception;

    static bool willSucceed () { static int x; return ++x == 2; }
    willSucceed().retryFor(1.seconds);

    static bool willFail () { return false; }
    assertThrown!AssertError(willFail().retryFor(300.msecs));
}
