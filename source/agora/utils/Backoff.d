/*******************************************************************************

    Contains a truncated exponential backoff algorithm for use with
    retrying code. Based on Amazon's FullJitter algorithm description on:
    https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/

    Copyright:
        Copyright (c) 2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.Backoff;

import libsodium.randombytes;

import std.algorithm : min;

/*******************************************************************************

    Get the delay to apply before retrying

    The unit is purposely left unspecified: Calling code can use `.seconds`,
    `.msecs`, or whichever unit is deemed appropriate.

    The algorithm is simply:
    ```
    sleep_time = random(0, min(max_delay, base * (2 ^^ attempt));
    ```

    Params:
        RandomFunc = A function that takes a `uint` as an input and returns a
                     value between `0` and the provided value, uniformly
        attempt = the attempt number (can be 0, which will result in 0)
        base    = The base multiplier
        max_delay = Maximum possible delay this function may return

    Returns:
        the delay which should be used given the attempt number and the provided
        base multiplier.

*******************************************************************************/

public uint getDelay (alias RandomFunc = getRandom)
    (uint attempt, uint base, uint max_delay)
{
    // must clamp to 2 ^^ 32 - 1 as this is the highest uint32 we can use.
    attempt = min(32, attempt);
    const uint delay = min(max_delay,
                           base * cast(uint)((ulong(2) ^^ attempt) - 1));
    return RandomFunc(delay);
}

/*******************************************************************************

    Call libsodium's `randombytes_uniform`

    Params:
      value = the input value

    Returns:
      A random value between [0, value], inclusive

*******************************************************************************/

public uint getRandom (uint value) @safe nothrow @nogc
{
    return () @trusted { return randombytes_uniform(value); }();
}

///
unittest
{
    import std.algorithm;
    import std.range;

    /// Uses a static Jitter (for testing)
    static uint deterministicRandom (uint value)
    {
        return value + 2;
    }
    alias testDelay = getDelay!deterministicRandom;

    const del_1 = iota(0, 100).map!(attempt => testDelay(attempt, 5, 2000)).array;
    assert(del_1 == [2, 7, 17, 37, 77, 157, 317, 637, 1277, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002]);

    const del_2 = iota(0, 100).map!(attempt => testDelay(attempt, 5, 4000)).array;
    assert(del_2 == [2, 7, 17, 37, 77, 157, 317, 637, 1277, 2557, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002]);

    const del_3 = iota(0, 100).map!(attempt => testDelay(attempt, 20, 2000)).array;
    assert(del_3 == [2, 22, 62, 142, 302, 622, 1262, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002]);

    const del_4 = iota(0, 100).map!(attempt => testDelay(attempt, 20, 4000)).array;
    assert(del_4 == [2, 22, 62, 142, 302, 622, 1262, 2542, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002]);
}
