/*******************************************************************************

    Contains types to check if the virtual methods are in the same order
    using vtable.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.tests.VTableTypes;

public import scpd.scp.SCPDriver;

import std.meta;

extern (C++) public class TestA
{
public:
    ~this()
    {
    }
    abstract void vfunc1();
    abstract void vfunc2();
}

public immutable VTableCheckClasses =
[
    "TestA",
    "SCPDriver"
];
