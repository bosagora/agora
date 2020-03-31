/*******************************************************************************

    Contains checking if the virtual methods are in the same order
    using vtable.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

#include "DVTableChecks.h"
#include "string.h"

///  Returns the offset of virtual methods inside the class TestA.
long getVMOffsetTestA (const char* name)
{
    if (strcmp(name, "vfunc1") == 0)
    {
        auto pf = &TestA::vfunc1;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "vfunc2") == 0)
    {
        auto pf = &TestA::vfunc2;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else
    {
        return -1;
    }
}

///  Returns the offset of virtual methods inside the class TestB.
long getVMOffsetTestB (const char* name)
{
    if (strcmp(name, "vfunc1") == 0)
    {
        auto pf = &TestB::vfunc1;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "vfunc2") == 0)
    {
        auto pf = &TestB::vfunc2;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else
    {
        return -1;
    }
}
