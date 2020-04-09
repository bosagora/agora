/*******************************************************************************

    Contains runtime field size & ABI object layout checks.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.tests.LayoutTest;

import scpd.tests.GlueTypes;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types;

import std.digest.sha;
import std.random;
import std.stdio;
import std.string;
import std.traits;

/// Contains the size and offset of a field within a struct
extern(C++) struct FieldInfo
{
    long size;
    long offset;
    //const(char)* mangleof;  // todo: could this work?
}

static foreach (Type; GlueTypes)
{
    extern(C++) FieldInfo cppFieldInfo (ref Type, const(char)*);
}

/// size & layout checks for C++ structs / objects
unittest
{
    foreach (Type; TypesWithLayout)
    {
        foreach (idx, field; Type.init.tupleof)
        {
            auto object = Type.init;
            auto field_info = cppFieldInfo(object,
                Type.tupleof[idx].stringof.toStringz);

            assert(typeof(field).sizeof == field_info.size,
                format("Field '%s' of '%s' size mismatch: %s (D) != %s (C++)",
                    Type.tupleof[idx].stringof, Type.stringof,
                    typeof(field).sizeof, field_info.size));

            assert(Type.tupleof[idx].offsetof == field_info.offset,
                format("Field '%s' of '%s' offset mismatch: %s (D) != %s (C++)",
                    Type.tupleof[idx].stringof, Type.stringof,
                    Type.tupleof[idx].offsetof, field_info.offset));
        }
    }
}
