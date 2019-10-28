/*******************************************************************************

    Contains magic code that auto-generates constructors,
    for use with subtyping via alias this.

    Code adapted from https://gist.github.com/AndrejMitrovic/72a08aa2c078767ea4c35eb1b0560c8d

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.Util;

import std.exception;
import std.string;
import std.traits;
import std.typecons;

/// Auto-implement constructors which forward to the provided symbol's constructors
public mixin template ForwardCtors (alias symbol)
{
    mixin(ForwardCtorsImpl!(typeof(symbol), symbol.stringof));
}

/// ditto
public string ForwardCtorsImpl (T, string name)()
{
    string result;

    foreach (Ctor; __traits(getOverloads, T, "__ctor"))
    {
        string[] attributes = [__traits(getFunctionAttributes, Ctor)];
        string[] clean;

        // for some reason this fails:
        // attributes.filter!(a => a == "ref")
        foreach (attr; attributes)
        {
            if (attr != "ref")
                clean ~= attr;
        }

        auto res = getParams!Ctor;
        result ~= format("extern(D) %s this(%s) { this.%s = typeof(this.%s)(%s); }\n",
            clean.join(" "),
            res[0], name, name, res[1]);
    }

    return result;
}

///
private string stcToString (uint stc)  // bug: can't use ParameterStorageClass type
{
    string[] result;

    if (stc & ParameterStorageClass.scope_)
        result ~= "scope";
    if (stc & ParameterStorageClass.out_)
        result ~= "out";
    if (stc & ParameterStorageClass.ref_)
        result ~= "ref";
    if (stc & ParameterStorageClass.lazy_)
        result ~= "lazy";
    if (stc & ParameterStorageClass.return_)
        result ~= "return";

    return result.join(" ");
}

///
private Tuple!(string, string) getParams (alias func)()
{
    string[] params;
    string[] args;

    alias ParameterStorageClassTuple!func STCFunc;

    foreach (idx, param; ParameterTypeTuple!func)
    {
        string default_value;
        static if (!is(ParameterDefaults!func[idx] == void))
            default_value = format(" = %s", ParameterDefaults!func[idx].stringof);

        string arg = format("_arg%s", idx);
        params ~= format("%s %s %s%s", stcToString(STCFunc[idx]), param.stringof, arg, default_value);
        args ~= arg;
    }

    return tuple(params.join(", "), args.join(", "));
}

/// Invoke an std::function pointer (note: must be void* due to mangling issues)
extern(C++) void callCPPDelegate (void* cb);
