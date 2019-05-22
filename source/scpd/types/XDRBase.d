/*******************************************************************************

    Binding to xdrpp types (the library)

    See_Also:
        https://github.com/xdrpp/xdrpp

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.types.XDRBase;

import core.stdc.config;
import core.stdc.inttypes;
import core.stdcpp.array;

import std.meta;

import vibe.data.json;

import scpd.Cpp;


extern(C++, xdr):

pragma(inline, true)
uint size32(size_t s)
{
    uint r = cast(uint)s;
    assert(s == r);
    return r;
}


////////////////////////////////////////////////////////////////
// Exception types
////////////////////////////////////////////////////////////////

//! Generic class of XDR unmarshaling errors.
class xdr_runtime_error : runtime_error
{
}

//! Attempt to exceed the bounds of a variable-length array or string.
class xdr_overflow : xdr_runtime_error
{
}

//! Attempt to exceed recursion limits.
class xdr_stack_overflow : xdr_runtime_error
{
}

//! Message not multiple of 4 bytes, or cannot fully be parsed.
class xdr_bad_message_size : xdr_runtime_error
{
}

//! Attempt to set invalid value for a union discriminant.
class xdr_bad_discriminant : xdr_runtime_error
{
}

//! Padding bytes that should have contained zero don't.
class xdr_should_be_zero : xdr_runtime_error
{
}

//! Exception for use by \c xdr::xdr_validate.
class xdr_invariant_failed : xdr_runtime_error
{
}

//! Attempt to access wrong field of a union.  Note that this is not
//! an \c xdr_runtime_error, because it cannot result from
//! unmarshalling garbage arguments.  Rather it is a logic error in
//! application code that neglected to check the union discriminant
//! before accessing the wrong field.
class xdr_wrong_union : logic_error
{
}

extern(D) static immutable XDR_MAX_LEN = 0xffff_fffc;

//struct xarray(T, uint32_t N) { public array!(T, N) data; alias data this; }
struct xarray(T, uint32_t N)
{
    array!(T, N) base;
    alias base this;

extern(D):
    string toString() const @trusted
    {
        string ret = "[ ";
        foreach (idx, ref entry; base)
        {
            ret ~= entry.serializeToJsonString();
            if ((idx + 1) != base.length)
                ret ~= ", ";
        }
        ret ~= " ]";
        return ret;
    }

    static typeof(this) fromString(string src) @safe
    {
        auto array = src.deserializeJson!(T[N]);
        return cast(typeof(this))(array);
    }
}
alias opaque_array(uint32_t N = XDR_MAX_LEN) = xarray!(uint8_t, N);
//class opaque_array(uint32_t N = XDR_MAX_LEN) : xarray!(uint8_t, N) {}

///alias xvector(T, uint32_t N = XDR_MAX_LEN) = vector!(T);
alias opaque_vec(uint32_t N = XDR_MAX_LEN) = xvector!(uint8_t, N);
struct xvector(T, uint32_t N = XDR_MAX_LEN)
{
    public vector!(T) base;
    alias base this;
}
//class opaque_vec(uint32_t N = XDR_MAX_LEN) : xvector!(uint8_t, N) {}

// xstring(uint32_t N = XDR_MAX_LEN) => std::string
// class pointer(T) : std::unique_ptr(T);
alias pointer(T) = T*;

// Probably only useful in C++ code:
// template<typename T, typename F, F T::*Ptr> struct field_ptr {
