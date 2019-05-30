/*******************************************************************************

    Contains runtime size checks for the structs.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.tests.SizeTest;

import scpd.tests.GlueTypes;

import std.string;

static foreach (Type; GlueTypes)
{
    extern(C++) ulong cppSizeOf (ref Type);
}

/// size checks
unittest
{
    foreach (Type; GlueTypes)
    {
        Type object;
        assert(Type.sizeof == cppSizeOf(object),
            format("Type '%s' size mismatch: %s (D) != %s (C++)",
                Type.stringof, Type.sizeof, cppSizeOf(object)));
    }
}
