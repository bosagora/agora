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

    uint base = 2;
    auto n = new BonTestA();
    // The point of the method is the same as the expected value.
    assert(n.__vptr[base + 0] == &BonTestA.vfunc1);
    assert(n.__vptr[base + 1] == &BonTestA.vfunc2);
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
        abstract void vfunc2();
        abstract void vfunc1();
    }

    extern (C++) class BonTestB : TestB
    {
    public:
        override void vfunc1() {}
        override void vfunc2() {}
    }

    uint base = 2;
    auto n = new BonTestB();
    // The method's point differs from the expected value.
    assert(n.__vptr[base + 0] != &BonTestB.vfunc1);
    assert(n.__vptr[base + 1] != &BonTestB.vfunc2);
}

/// Test the `SCPDriver`; Check that the virtual method of C++ and D are in the same order.
unittest
{
    import scpd.Cpp;
    import scpd.scp.SCPDriver;
    import scpd.types.Stellar_types;
    import scpd.types.Stellar_SCP;

    import std.algorithm;
    import std.range;
    import std.traits;

    import core.stdc.stdint;
    import core.time;

    string[] methods;

    foreach (member; __traits(allMembers, SCPDriver))
    {
        if ((member == "__dtor") || (member == "__xdtor")) continue;
        static foreach (idx, ovrld; __traits(getOverloads, SCPDriver, member))
        {
            if (idx == 0)
                methods ~= member;
        }
    }

    extern (C++) class TestNominator : SCPDriver
    {
        public override void signEnvelope (ref SCPEnvelope envelope)
        {
        }

        public override SCPQuorumSetPtr getQSet(ref const(Hash) qSetHash)
        {
            return SCPQuorumSetPtr();
        }

        public override void emitEnvelope(ref const(SCPEnvelope) envelope)
        {
        }

        public override Value combineCandidates(uint64_t slotIndex,
                                ref const(set!Value) candidates)
        {
            return Value();
        }

        public override void setupTimer(ulong slotIndex, int timerID,
                                milliseconds timeout,
                                CPPDelegate!(void function())*)
        {
        }
    }

    int findMethod (string name)
    {
        foreach(int idx, ref n; methods)
            if (n == name)
                return idx;
        return -1;
    }

    assert (findMethod("signEnvelope") == 0);

    uint base = 2;
    auto n = new TestNominator();
    assert(n.__vptr[base + findMethod("signEnvelope")] == &TestNominator.signEnvelope);
    assert(n.__vptr[base + findMethod("getQSet")] == &TestNominator.getQSet);
    assert(n.__vptr[base + findMethod("emitEnvelope")] == &TestNominator.emitEnvelope);
    assert(n.__vptr[base + findMethod("validateValue")] == &TestNominator.validateValue);
    assert(n.__vptr[base + findMethod("extractValidValue")] == &TestNominator.extractValidValue);
    assert(n.__vptr[base + findMethod("getValueString")] == &TestNominator.getValueString);
    assert(n.__vptr[base + findMethod("toStrKey")] == &TestNominator.toStrKey);
    assert(n.__vptr[base + findMethod("toShortString")] == &TestNominator.toShortString);
    assert(n.__vptr[base + findMethod("computeValueHash")] == &TestNominator.computeValueHash);
    assert(n.__vptr[base + findMethod("setupTimer")] == &TestNominator.setupTimer);
    assert(n.__vptr[base + findMethod("computeTimeout")] == &TestNominator.computeTimeout);
    assert(n.__vptr[base + findMethod("valueExternalized")] == &TestNominator.valueExternalized);
    assert(n.__vptr[base + findMethod("nominatingValue")] == &TestNominator.nominatingValue);
    assert(n.__vptr[base + findMethod("updatedCandidateValue")] == &TestNominator.updatedCandidateValue);
    assert(n.__vptr[base + findMethod("startedBallotProtocol")] == &TestNominator.startedBallotProtocol);
    assert(n.__vptr[base + findMethod("acceptedBallotPrepared")] == &TestNominator.acceptedBallotPrepared);
    assert(n.__vptr[base + findMethod("confirmedBallotPrepared")] == &TestNominator.confirmedBallotPrepared);
    assert(n.__vptr[base + findMethod("ballotDidHearFromQuorum")] == &TestNominator.ballotDidHearFromQuorum);
}
