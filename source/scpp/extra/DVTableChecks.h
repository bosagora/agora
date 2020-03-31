#pragma once

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

