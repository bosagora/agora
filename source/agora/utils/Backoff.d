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

/// Ditto
public class Backoff
{
@safe @nogc nothrow:

    /// sleep_ms = random(0, min(max_delay, base * (2 ^^ attempt))
    private immutable uint base;
    /// ditto
    private immutable uint max_delay;

    /***************************************************************************

        Initialize the base and max_delay.

        Params:
            base = the base multiplier
            max_delay = maximum possible delay returned from `getDelay`

    ***************************************************************************/

    public this (uint base, uint max_delay)
    {
        assert(base > 0);
        assert(max_delay > 0);
        this.base = base;
        this.max_delay = max_delay;
    }

    /***************************************************************************

        Params:
            attempt = the attempt number

        Returns:
            the delay in milliseconds which should be used given the attempt
            number and the preconfigured base multiplier.

    ***************************************************************************/

    public uint getDelay (uint attempt)
    {
        // must clamp to 2 ^^ 32 - 1 as this is the highest uint32 we can use.
        attempt = min(32, attempt);
        const uint delay = min(this.max_delay, this.base *
            cast(uint)((ulong(2) ^^ attempt) - 1));
        return this.getRandom(delay);
    }

    /***************************************************************************

        Params:
            value = the input value

        Returns:
            a random value between [0, value], inclusive

    ***************************************************************************/

    protected uint getRandom (uint value)
    {
        return () @trusted { return randombytes_uniform(value); }();
    }
}

///
unittest
{
    import std.algorithm;
    import std.range;

    /// adds a static Jitter (for testing)
    static class DetermensiticBackoff : Backoff
    {
    @safe @nogc nothrow:
        public this (uint base, uint max_delay)
        {
            super(base, max_delay);
        }

        protected override uint getRandom (uint value)
        {
            return value + 2;
        }
    }

    scope db_1 = new DetermensiticBackoff(5, 2000);
    const del_1 = iota(0, 100).map!(attempt => db_1.getDelay(attempt)).array;
    assert(del_1 == [2, 7, 17, 37, 77, 157, 317, 637, 1277, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002]);

    scope db_2 = new DetermensiticBackoff(5, 4000);
    const del_2 = iota(0, 100).map!(attempt => db_2.getDelay(attempt)).array;
    assert(del_2 == [2, 7, 17, 37, 77, 157, 317, 637, 1277, 2557, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002]);

    scope db_3 = new DetermensiticBackoff(20, 2000);
    const del_3 = iota(0, 100).map!(attempt => db_3.getDelay(attempt)).array;
    assert(del_3 == [2, 22, 62, 142, 302, 622, 1262, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002]);

    scope db_4 = new DetermensiticBackoff(20, 4000);
    const del_4 = iota(0, 100).map!(attempt => db_4.getDelay(attempt)).array;
    assert(del_4 == [2, 22, 62, 142, 302, 622, 1262, 2542, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002]);
}
