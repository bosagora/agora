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

class TestC1
{
public:
    virtual ~TestC1();
    virtual void vfunc1();
    virtual void vfunc2();
};

class TestC2
{
public:
    virtual void vfunc1();
    virtual void vfunc2();
    virtual ~TestC2();
};
