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

import scpd.Cpp;

import vibe.data.json;

import std.meta;

import core.stdc.config;
import core.stdc.inttypes;
import core.stdcpp.array;

import geod24.bitblob;


extern(C++, `xdr`):

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

///
struct opaque_array(uint32_t N = XDR_MAX_LEN)
{
    BitBlob!(N * 8) base;
    alias base this;

    public this (BitBlob!(N * 8) val)
    {
        this.base = val;
    }
}


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
