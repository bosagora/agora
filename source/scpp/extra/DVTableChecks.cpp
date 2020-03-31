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
#include "scp/SCPDriver.h"
#include "string.h"

using namespace stellar;

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

///  Returns the offset of virtual methods inside the class TestC1.
long getVMOffsetTestC1 (const char* name)
{
    if (strcmp(name, "vfunc1") == 0)
    {
        auto pf = &TestC1::vfunc1;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "vfunc2") == 0)
    {
        auto pf = &TestC1::vfunc2;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else
    {
        return -1;
    }
}

///  Returns the offset of virtual methods inside the class TestC2.
long getVMOffsetTestC2 (const char* name)
{
    if (strcmp(name, "vfunc1") == 0)
    {
        auto pf = &TestC2::vfunc1;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "vfunc2") == 0)
    {
        auto pf = &TestC2::vfunc2;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else
    {
        return -1;
    }
}

///  Returns the offset of virtual methods inside the class SCPDriver.
long getVMOffsetSCPDriver(const char* name)
{
    if (strcmp(name, "signEnvelope") == 0)
    {
        auto pf = &SCPDriver::signEnvelope;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "getQSet") == 0)
    {
        auto pf = &SCPDriver::getQSet;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "emitEnvelope") == 0)
    {
        auto pf = &SCPDriver::emitEnvelope;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "validateValue") == 0)
    {
        auto pf = &SCPDriver::validateValue;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "extractValidValue") == 0)
    {
        auto pf = &SCPDriver::extractValidValue;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "getValueString") == 0)
    {
        auto pf = &SCPDriver::getValueString;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "toStrKey") == 0)
    {
        auto pf = &SCPDriver::toStrKey;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "toShortString") == 0)
    {
        auto pf = &SCPDriver::toShortString;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "computeHashNode") == 0)
    {
        auto pf = &SCPDriver::computeHashNode;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "computeValueHash") == 0)
    {
        auto pf = &SCPDriver::computeValueHash;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "combineCandidates") == 0)
    {
        auto pf = &SCPDriver::combineCandidates;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "setupTimer") == 0)
    {
        auto pf = &SCPDriver::setupTimer;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "computeTimeout") == 0)
    {
        auto pf = &SCPDriver::computeTimeout;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "valueExternalized") == 0)
    {
        auto pf = &SCPDriver::valueExternalized;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "nominatingValue") == 0)
    {
        auto pf = &SCPDriver::nominatingValue;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "updatedCandidateValue") == 0)
    {
        auto pf = &SCPDriver::updatedCandidateValue;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "startedBallotProtocol") == 0)
    {
        auto pf = &SCPDriver::startedBallotProtocol;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "acceptedBallotPrepared") == 0)
    {
        auto pf = &SCPDriver::acceptedBallotPrepared;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "confirmedBallotPrepared") == 0)
    {
        auto pf = &SCPDriver::confirmedBallotPrepared;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "acceptedCommit") == 0)
    {
        auto pf = &SCPDriver::acceptedCommit;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else if (strcmp(name, "ballotDidHearFromQuorum") == 0)
    {
        auto pf = &SCPDriver::ballotDidHearFromQuorum;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }
    else
    {
        return -1;
    }
}
