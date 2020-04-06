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

import scpd.tests.VTableTypes;

version (unittest)
extern(C++) int checkVMOffset (const char* classname, const char* offsets);

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

/// It checks the offset of virtual on C++ and D for any class.
unittest
{
    import std.format;
    import std.string;

    long[string] offset_d;
    long val_d;
    string offsets;

    static foreach (e; VTableCheckClasses)
    {
        offset_d.clear();
        val_d = 0;
        offsets = "";

        mixin(
        q{
            static foreach (member; __traits(allMembers, %1$s))
            {
                mixin(
                q{
                    static if (__traits(isVirtualMethod, %1$s.%2$s) && (`%2$s` != `__xdtor`))
                    {
                        static if (`%2$s` == `__dtor`)
                            val_d += 2;
                        else
                            offset_d[`%2$s`] = val_d++;
                    }
                }.format(`%1$s`, member));
            }

            foreach (k,v; offset_d)
                offsets ~= format(`%%s=%%d:`, k,v);

            assert(checkVMOffset(`%1$s`, toStringz(offsets)) == 0, "The virtual method offset of %1$s does not match.");

        }.format(e, `%2$s`));
    }
}
