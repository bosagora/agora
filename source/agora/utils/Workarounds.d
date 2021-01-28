/*******************************************************************************

    Workarounds for compiler / runtime / upstream issues

    Live in this module so they can be imported by code that imports other
    module in Agora, such as the system integration test.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.Workarounds;

version (CRuntime_Musl)
{
    import agora.utils.libunwind;
    shared static this ()
    {
        import core.runtime;
        Runtime.traceHandler = &libunwindDefaultTraceHandler;
    }
}

/**
 * Workaround for segfault similar (or identical) to https://github.com/dlang/dub/issues/1812
 * https://dlang.org/changelog/2.087.0.html#gc_parallel
 */
static if (__VERSION__ >= 2087)
    extern(C) __gshared string[] rt_options = [ "gcopt=parallel:0" ];
