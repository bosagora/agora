/*******************************************************************************

    Contains runtime vtable checks for the class.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.tests.VTableTest;

import scpd.scp.BallotProtocol;
import scpd.scp.LocalNode;
import scpd.scp.NominationProtocol;
import scpd.scp.SCP;
import scpd.scp.SCPDriver;
import scpd.scp.Slot;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types;

import agora.consensus.protocol.Nominator;

import std.traits;

version (unittest)
extern(C++) ulong getVirtualMethodCountSCPDriver ();
extern(C++) ulong doCheckMethodPoint ();
/*
/// vtable checks
unittest
{
    const auto nvm = getVirtualMethodCountSCPDriver();
    //assert (nvm == 22);

    //version (none)
    {
        import std.stdio;
        writefln("%s in C++", nvm);
    }
}

unittest
{
    import std.stdio;
    string[] methods;
    string[] types;
    string[] returnTypes;
    string[] params;
    foreach (member; __traits(allMembers, scpd.scp.SCPDriver.SCPDriver))
    {
        foreach (ovrld; __traits(getOverloads, scpd.scp.SCPDriver.SCPDriver, member))
        {
            methods ~= member;
            types ~= typeof(ovrld).stringof;
            returnTypes ~= ReturnType!(ovrld).stringof;
            params ~= Parameters!(ovrld).stringof;
        }
    }

    writefln("class SCPDriver");
    writefln("{");
    foreach (idx, name; methods)
    {
        if ((name == "__dtor") || (name == "__xdtor")) continue;
        writefln("  virtual %s %s %s = 0;", returnTypes[idx], name, params[idx]);
    }
    writefln("}");
}
*/

unittest
{
    assert(doCheckMethodPoint() == 0);
}
