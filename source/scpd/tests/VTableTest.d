/*******************************************************************************

    Contains checking if the virtual methods are in the same order
    using vtable.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.tests.VTableTest;

version (Windows) {} else:

/// In case the virtual methods are in the correct order.
unittest
{
    // abstract class, this is in the correct order.
    extern (C++) class TestA
    {
    public:
        ~this()
        {
        }
        abstract void vfunc1();
        abstract void vfunc2();
    }

    extern (C++) class BonTestA : TestA
    {
    public:
        override void vfunc1() {}
        override void vfunc2() {}
    }

    auto n = new BonTestA();
    // The point of the method is the same as the expected value.
    assert(n.__vptr[2] is &BonTestA.vfunc1);
    assert(n.__vptr[3] is &BonTestA.vfunc2);
}

/// In case the virtual methods are in the incorrect order.
unittest
{
    // abstract class, this is in the incorrect order.
    extern (C++) class TestB
    {
    public:
        ~this()
        {
        }
        // The order of the two methods has changed.
        abstract void vfunc2();
        abstract void vfunc1();
    }

    extern (C++) class BonTestB : TestB
    {
    public:
        override void vfunc1() {}
        override void vfunc2() {}
    }

    auto n = new BonTestB();
    // The method's point differs from the expected value.
    assert(n.__vptr[2] !is &BonTestB.vfunc1);
    assert(n.__vptr[3] !is &BonTestB.vfunc2);

    assert(n.__vptr[2] is &BonTestB.vfunc2);
    assert(n.__vptr[3] is &BonTestB.vfunc1);
}
