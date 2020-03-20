/*******************************************************************************

    Contains checking if the virtual methods are in the same order
    using vtable.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

class TestA
{
public:
    virtual ~TestA() {}
    virtual void vfunc1() = 0;
    virtual void vfunc2() = 0;
};

class TestB
{
public:
    virtual ~TestB() {}
    virtual void vfunc1() = 0;
    virtual void vfunc2() = 0;
};
