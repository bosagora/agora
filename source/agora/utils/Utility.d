/*******************************************************************************

    Utility functions that cannot be put anywhere else

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.Utility;

import agora.utils.Log;

import std.algorithm : each, map;
import std.array : join, split;
import std.conv;
import std.format;
import std.typecons;
import std.traits;
import std.uni : asCapitalized;

import core.exception;
import core.time;

mixin AddLogger!();

public static assumeNothrow (T)(lazy T exp) nothrow
{
    try return exp();
    catch (Exception ex) assert(0, ex.msg);
}

/***************************************************************************

    Retry executing a given delegate at most X times and wait between
    the retries. As soon as the delegate is executed successfully,
    the function immediately returns.

    Params:
        dg = the delegate we want to execute X times
        waiter = object implementing the wait() primitive
        max_retries = maximum number of times the delegate is executed
        duration = the time between retrying to execute the delegate
        error_msg = optional error message

    Returns:
        returns Nullable() in case the delegate cannot be executed after X
        retries or when the delegate returns false,
        otherwise it returns the original return value of
        the delegate wrapped into a Nullable object

***************************************************************************/

Nullable!(ReturnType!dg) retry (alias dg, T)(T waiter, long max_retries,
    Duration duration, string error_msg = "Operation timed out: ")
{
    alias RetType = typeof(return);
    foreach (_; 0 .. max_retries)
    {
        try
        {
            if (auto res = dg())
                return RetType(res);
        }
        catch (Exception ex)
            log.error("{}: {}", error_msg, ex.msg);
        waiter.wait(duration);
    }

    return RetType();
}

/// returns the function attributues as a string
public template FuncAttributes (alias Func)
{
    import std.array : join;
    enum FuncAttributes = [__traits(getFunctionAttributes, Func)].join(" ");
}

/***************************************************************************

    This template wraps the function's body inside a 'synchronized' statement,
    so it can be called from multiple threads.

    Params:
        Func = alias to the function symbol
        identifier = name of the function

***************************************************************************/

public mixin template SyncFunction (alias Func, string identifier = __traits(identifier, Func))
{
    import std.format : format;
    import std.meta : AliasSeq;
    import std.traits : ReturnType, Parameters;

    alias UDA = AliasSeq!(__traits(getAttributes, Func));
    mixin(q{
            override @(UDA) ReturnType!Func %1$s(Parameters!Func params) %2$s {
                synchronized
                {
                    return super.%1$s(params);
                }
            }
         }.format(identifier, FuncAttributes!Func));
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
    const TotalAttempts = timeout.total!"msecs" / SleepTime;

    ThreadWaiter thread_waiter;
    if (!retry!check(thread_waiter, TotalAttempts, SleepTime.msecs).isNull)
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

/*******************************************************************************

    Converts a string with underscore separator to upper camel case, for example
    converts "this_is_me" to "ThisIsMe"

    Params:
        original = string that we want to convert to upper camel case

*******************************************************************************/

public string snakeCaseToUpperCamelCase (string original)
{
    return to!string(original.split("_").map!(part => part.asCapitalized).join(""));
}

///
unittest
{
    // base case
    assert(snakeCaseToUpperCamelCase("this_is_me") == "ThisIsMe");
    // extra underscore in the middle
    assert(snakeCaseToUpperCamelCase("this__is_me") == "ThisIsMe");
    // unnecessary underscores in the beginning and at the end
    assert(snakeCaseToUpperCamelCase("_this_is_me_") == "ThisIsMe");
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

/*******************************************************************************

    Writes an `ubyte[]` as an hexadecimal string to a sink

    Does not allocate nor throw of its own.

    Params:
      bin = Binary data to string serialize
      sink = Sink delegate, such as those passed to `toString`

*******************************************************************************/

public struct UbyteHexString
{
    const(ubyte)[] bin;

    void toString (scope void delegate (in char[]) @safe sink)
        const @safe
    {
        // Copied this code from BitBlob
        static immutable HexDigits = `0123456789abcdef`;

        char[2] result;
        this.bin.each!((sb) {
                result[0] = HexDigits[sb >> 4];
                result[1] = HexDigits[(sb & 0b0000_1111)];
                sink(result[]);
        });
    }
}

/// Utility class to implement vibe.d ResultSerializer.serialize and
/// ResultSerializer.deserialize templates
public class RawStringSerializer
{
    /***************************************************************************

        Serialize the string as it is without any modifications
        like JSON escaping

        Params:
            Policy = serialization policy type
            InputT = input data type (string)
            OutputRangeT = output range type
            output_range = output range to serialize the string into
            input_string = string to serialize

    ***************************************************************************/

    public static void serialize (alias Policy, InputT, OutputRangeT)(OutputRangeT output_range, InputT input_string)
    {
        import std.string;
        output_range.put(input_string.representation);
    }

    /***************************************************************************

        Deserialize the string that was previouly serialized by
        raw_string_serialize

        Params:
            Policy = serialization policy type
            ReturnT = return type (string)
            InputRangeT = input range type
            input_range = input range

    ***************************************************************************/

    public static ReturnT deserialize (alias Policy, ReturnT, InputRangeT)(InputRangeT input_range)
    {
        import std.string;
        return std.string.toUTF8(input_range);
    }
}
