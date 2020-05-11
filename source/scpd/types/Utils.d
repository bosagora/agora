/*******************************************************************************

    C++-side utilities for D code, such as wrapper for vector.push_back

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.types.Utils;

import scpd.Cpp;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types;
import scpd.types.XDRBase;

extern(C++) public shared_ptr!SCPQuorumSet makeSharedSCPQuorumSet (
    ref const(SCPQuorumSet));


/// Utility function for SCP
public inout(opaque_vec!()) toVec (scope ref inout(Hash) data) nothrow @nogc
{
    return (cast(inout(ubyte[]))data[]).toVec();
}

/// Ditto
public inout(opaque_vec!()) toVec (scope inout ubyte[] data) nothrow @nogc
{
    inout opaque_vec!() ret =
    {
        base: {
            _start: data.ptr,
            _end: data.ptr + data.length,
            _end_of_storage: data.ptr + data.length,
        },
    };
    return ret;
}

public SCPQuorumSet dup (ref const(SCPQuorumSet) orig)
{
    SCPQuorumSet ret;
    ret.threshold = orig.threshold;
    foreach (entry; orig.validators.constIterator)
        push_back(ret.validators, entry);
    assert(orig.innerSets.length == 0);
    return ret;
}

// This triggers a DMD bug :(
//extern(C++, `stellar`):
extern(C++):

public void push_back(T, VectorT) (ref VectorT this_, ref T value) @safe pure nothrow @nogc;
// Workaround for Dlang issue #20805
public void push_back_vec (void*, const(void)*) @safe pure nothrow @nogc;
public VectorT duplicate(VectorT)(ref const VectorT this_) @safe pure nothrow @nogc;
