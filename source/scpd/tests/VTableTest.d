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

import scpd.scp.SCPDriver;

import std.format;
import std.traits;

version (unittest)
{
    extern (C++) long getVMOffsetSCPDriver(const char* name);
    extern (C++) long getVMOffsetTestA(const char* name);
    extern (C++) long getVMOffsetTestB(const char* name);
}

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

    assert (getVMOffsetTestA("vfunc1") == 2);
    assert (getVMOffsetTestA("vfunc2") == 3);

    auto n = new BonTestA();
    // The point of the method is the same as the expected value.
    assert(n.__vptr[getVMOffsetTestA("vfunc1")] == &BonTestA.vfunc1);
    assert(n.__vptr[getVMOffsetTestA("vfunc2")] == &BonTestA.vfunc2);
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

    assert (getVMOffsetTestB("vfunc1") == 2);
    assert (getVMOffsetTestB("vfunc2") == 3);

    auto n = new BonTestB();
    // The method's point differs from the expected value.
    assert(n.__vptr[getVMOffsetTestB("vfunc1")] != &BonTestB.vfunc1);
    assert(n.__vptr[getVMOffsetTestB("vfunc2")] != &BonTestB.vfunc2);

    assert(n.__vptr[getVMOffsetTestB("vfunc1")] == &BonTestB.vfunc2);
    assert(n.__vptr[getVMOffsetTestB("vfunc2")] == &BonTestB.vfunc1);
}

// The destructor has two addresses.
// The offset within `vtable` of the destructor is determined
// by the declaration of the C++ side.
unittest
{
    extern (C++) class TestC1
    {
    public:
        ~this()
        {
        }
        abstract void vfunc1();
        abstract void vfunc2();
    }

    extern (C++) class BonTestC1 : TestC1
    {
    public:
        override void vfunc1() {}
        override void vfunc2() {}
    }

    // abstract class, this is in the correct order.
    extern (C++) class TestC2
    {
    public:
        abstract void vfunc1();
        abstract void vfunc2();
        ~this()
        {
        }
    }

    extern (C++) class BonTestC2 : TestC2
    {
    public:
        override void vfunc1() {}
        override void vfunc2() {}
    }

    auto n = new BonTestC1();
    assert(n.__vptr[1] == &TestC1.__dtor);
    assert(n.__vptr[1] == &BonTestC1.__dtor);
    assert(n.__vptr[2] == &BonTestC1.vfunc1);
    assert(n.__vptr[3] == &BonTestC1.vfunc2);
    assert(n.__vptr[0] == n.__vptr[1]);

    auto m = new BonTestC2();
    assert(m.__vptr[0] == &BonTestC2.vfunc1);
    assert(m.__vptr[1] == &BonTestC2.vfunc2);
    assert(m.__vptr[3] == &TestC2.__dtor);
    assert(m.__vptr[3] == &BonTestC2.__dtor);
    assert(m.__vptr[2] == m.__vptr[3]);
}

extern (C++) class TestA
{
public:
    ~this()
    {
    }
    abstract void vfunc1();
    abstract void vfunc2();
}

/// Finds offset of virtual destructor on C++ side
unittest
{
    long[string] expected;
    long[string] offset_cpp;
    bool[long] values;
    long val_cpp;
    bool dtor_virtual;
    long dtor_pos;

    values.clear();
    offset_cpp.clear();
    val_cpp = 0;
    dtor_virtual = false;

    static foreach (member; __traits(allMembers, TestA))
    {
        mixin(
        q{
            static if (__traits(isVirtualMethod, TestA.%1$s) && (`%1$s` != `__xdtor`))
            {
                static if (`%1$s` == `__dtor`)
                {
                    dtor_virtual = true;
                }
                else
                {
                    val_cpp = getVMOffsetTestA(`%1$s`);
                    offset_cpp[`%1$s`] = val_cpp;
                    values[val_cpp] = true;
                }
            }
        }.format(member));
    }

    //  If the destructor is a virtual method,
    //  Finds two consecutive empty indexes.
    if (dtor_virtual)
    {
        dtor_pos = -1;
        foreach (idx; 0..values.length+2-1)
        {
            if (((idx in values) is null) && (((idx+1) in values) is null))
            {
                dtor_pos = idx;
                break;
            }
        }
        assert (dtor_pos >= 0);
        offset_cpp[`__dtor`] = dtor_pos;
    }
    expected = ["__dtor" : 0, "vfunc1" : 2, "vfunc2" : 3];
    assert(offset_cpp == expected, format(`%s : %s`, offset_cpp, expected));
}

/// Check that the virtual method of C++ and D for any class.
unittest
{
    // Class name
    const string[] entries = ["TestA", "SCPDriver"];

    //  Offset of D side
    long[string] offset_d;
    //  Offset of  C++ side
    long[string] offset_cpp;

    bool[long] values;
    long val_d;
    long val_cpp;
    bool dtor_virtual;
    long dtor_pos;

    static foreach (e; entries)
    {
        values.clear();
        offset_cpp.clear();
        offset_d.clear();
        val_cpp = 0;
        val_d = 0;
        dtor_virtual = false;

        mixin(
        q{
            static foreach (member; __traits(allMembers, %1$s))
            {
                mixin(
                q{
                    static if (__traits(isVirtualMethod, %1$s.%2$s) && (`%2$s` != `__xdtor`))
                    {
                        static if (`%2$s` == `__dtor`)
                        {
                            offset_d[`%2$s`] = val_d;
                            val_d += 2;
                            dtor_virtual = true;
                        }
                        else
                        {
                            offset_d[`%2$s`] = val_d;
                            val_d ++;
                            val_cpp = getVMOffset%1$s(`%2$s`);
                            offset_cpp[`%2$s`] = val_cpp;
                            values[val_cpp] = true;
                        }
                    }
                }.format(`%1$s`, member));
            }

            //  If the destructor is a virtual method,
            //  Finds two consecutive empty indexes.
            if (dtor_virtual)
            {
                dtor_pos = -1;
                foreach (idx; 0..values.length+2-1)
                {
                    if (((idx in values) is null) && (((idx+1) in values) is null))
                    {
                        dtor_pos = idx;
                        break;
                    }
                }
                assert (dtor_pos >= 0);
                offset_cpp[`__dtor`] = dtor_pos;
            }

            assert(offset_d == offset_cpp, format(`%%s : %%s`, offset_d, offset_cpp));

        }.format(e, `%2$s`));
    }
}
