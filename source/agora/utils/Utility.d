/*******************************************************************************

    Utility functions that cannot be put anywhere else

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.Utility;

import agora.utils.Log;

import std.format;
import std.typecons;
import std.traits;

import core.exception;
import core.time;

mixin AddLogger!();

/***************************************************************************

        Retry executing a given delegate at most X times and wait between
        the retries. As soon as the delegate is executed successfully,
        the function immediately returns.

        Params:
            dg = the delegate we want to execute X times
            max_retry = maximum number of times the delegate is executed
            duration = the time between retrying to execute the delegate

        Returns:
            returns Nullable() in case the delegate cannot be executed after X
            retries, otherwise it returns the original return value of
            the delegate wrapped into a Nullable object

***************************************************************************/

Nullable!(ReturnType!dg) retry (alias dg, T) (T waiter, long max_retry, Duration duration, string error_msg = "Operation timed out: ")
{
    alias RetType = Nullable!(ReturnType!dg);
    foreach (i; 0 .. max_retry)
        try
            if (auto res = dg())
                return RetType(res);
            else
                waiter.wait(duration);
        catch (Exception ex)
            log.error("{}{}", error_msg, ex.msg);

    return RetType();
}

/*******************************************************************************

    Keeps retrying the 'check' condition until it is true,
    or until the timeout expires. It will sleep the main
    thread for 100 msecs between each re-try.

    If the timeout expires, and the 'check' condition is still false,
    it throws an AssertError.

    Params:
        Exc = a custom exception type, in case we want to catch it
        check = the condition to check on
        timeout = time to wait for the check to succeed
        msg = optional AssertException message when the condition fails
              after the timeout expires
        file = file from the call site
        line = line from the call site

    Throws:
        AssertError if the timeout is reached and the condition still fails

*******************************************************************************/

public void retryFor (Exc : Throwable = AssertError) (lazy bool check,
    Duration timeout, lazy string msg = "",
    string file = __FILE__, size_t line = __LINE__)
{
    // wait 100 msecs between attempts
    const SleepTime = 100;
    auto attempts = timeout.total!"msecs" / SleepTime;
    const TotalAttempts = attempts;

    ThreadWaiter thread_waiter;
    if(!retry!(() => check)(thread_waiter, attempts, SleepTime.msecs).isNull)
        return;

    auto message = format("Check condition failed after timeout of %s " ~
        "and %s attempts", timeout, TotalAttempts);

    if (msg.length)
        message ~= ": " ~ msg;

    throw new Exc(message, file, line);
}

///
public struct ThreadWaiter
{
    public void wait (Duration duration) nothrow
    {
        import core.thread;
        Thread.sleep(duration);
    }
}

///
unittest
{
    import std.exception;

    static bool willSucceed () { static int x; return ++x == 2; }
    willSucceed().retryFor(1.seconds);

    static bool willFail () { return false; }
    assertThrown!AssertError(willFail().retryFor(300.msecs));
}
