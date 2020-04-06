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
public VectorT duplicate(VectorT)(ref const VectorT this_) @safe pure nothrow @nogc;
public opaque_vec!() XDRToOpaque (const ref xvector!ubyte arg);
public opaque_vec!() XDRToOpaque (const ref SCPQuorumSet arg);
public opaque_vec!() XDRToOpaque (const ref SCPStatement arg);

// Does not work, DMD bug
//extern(C++, `xdr`)
//public opaque_vec!() xdr_to_opaque(T...)(const ref T arg);

extern(C++, `stellar`)
{

    public extern(C++, class) struct ByteSlice
    {
        const void* mData;
        const size_t mSize;

        extern(D) public static ByteSlice make(T)(const T[] arg) pure nothrow @nogc @safe
        {
            static assert(is(const T : T), "Type is not simple value type");
            return ByteSlice(&arg[0], arg.length * T.sizeof);
        }

        public static ByteSlice make()(vector!ubyte arg) pure nothrow @nogc @safe
        {
            return ByteSlice(arg._start, arg.length());
        }

        extern(D) public const(T)[] slice(T)() pure nothrow @nogc
        {
            return (cast(T*)this.mData)[0 .. this.mSize / T.sizeof];
        }
    }

    // Note: This needs to be after `ByteSlice` because the frontend doesn't take
    // `extern(C++, class)` into account otherwise
    // https://issues.dlang.org/show_bug.cgi?id=20700
    public uint512 sha512(const ref ByteSlice bin);

}
