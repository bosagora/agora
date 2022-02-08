/*******************************************************************************

    Defines common types used by Agora

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Types;

import agora.common.Amount;
import agora.common.Ensure : ensure;
import agora.crypto.ECC;
import agora.crypto.Key;
import agora.crypto.Schnorr;
public import agora.crypto.Types;
import agora.serialization.Serializer;

import vibe.inet.url;

import geod24.bitblob;

import std.algorithm.comparison : among;

/// Clone any type via the serializer
public T clone (T)(in T input)
{
    import agora.serialization.Serializer;
    return input.serializeFull.deserializeFull!T;
}

shared static this ()
{
    registerCommonInternetSchema("agora", 2826);
    registerCommonInternetSchema("dns", 53);
}

/// Represents a specific point in time, it should be changed to time_t
/// after time_t became platform independent
public alias TimePoint = ulong;

/// An array of const characters
public alias cstring = const(char)[];

/// A normalized network address, extended version of Vibe.d's URL with serialization
public struct Address
{
@safe:
    URL inner;

    public this (URL url)
    {
        ensure(url.schema.among("agora", "http", "https", "dns") != 0,
            "Address schema '{}' is not supported", url.schema);

        this.inner = url;
        this.inner.normalize(true);
    }

    public this (string url)
    {
        this(URL(url));
    }

    /// Serialization hook
    public void serialize (scope SerializeDg dg) const @safe
    {
        serializePart(inner.toString(), dg);
    }

    /// Deserialization hook
    public static T fromBinary (T) (
        scope DeserializeDg dg, in DeserializerOptions opts) @safe
    {
        return () @trusted {
            return T(deserializeFull!string(dg, opts));
        }();
    }

    /// Forward to `URL.fromString` but is recognized by the config parser
    public static Address fromString (string str) @safe
    {
        auto url = URL(str);
        return Address(url);
    }

    public alias inner this;
}

/// A simple wrapper struct to string-represent IPv4 without allocating
public struct IPv4
{
    import std.format;

    public uint value;

    /// Returns: An IPv4 in network byte order
    public static IPv4 fromHost (uint v) @safe pure nothrow @nogc
    {
        import core.sys.posix.arpa.inet : htonl;
        return IPv4(htonl(v));
    }

    /// Provides a string representation of this IP
    public void toString (scope void delegate(in char[]) @safe sink)
        const scope @safe
    {
        formattedWrite!"%s.%s.%s.%s"(sink,
            this.value >> 24 & 0xFF, this.value >> 16 & 0xFF,
            this.value >>  8 & 0xFF, this.value >>  0 & 0xFF);
    }

    public string toString () const scope @safe
    {
        char["255.255.255.255".length] buffer;
        size_t offset;
        scope sink = (in char[] data) {
            assert(offset + data.length <= buffer.length);
            buffer[offset .. offset + data.length] = data[];
            offset += data.length;
        };
        this.toString(sink);
        return buffer[0 .. offset].idup;
    }
}

///
unittest
{
    IPv4 all = IPv4(0);
    assert(all.toString() == "0.0.0.0");
    IPv4 bc = IPv4(uint.max);
    assert(bc.toString() == "255.255.255.255");

    version (LittleEndian)
        IPv4 home = IPv4.fromHost(0x0100_007F);
    else
        IPv4 home = IPv4.fromHost(0x7F00_0001);
    assert(home.toString() == "127.0.0.1");
}

/// The definition of a Quorum
public struct QuorumConfig
{
    /// Threshold of this quorum set
    public uint threshold = 1;

    /// List of nodes in this quorum
    public ulong[] nodes;

    /// List of any sub-quorums
    public QuorumConfig[] quorums;
}

/// A type to ensure that height and other integer values aren't mixed
public struct Height
{
    ///
    public ulong value;

    /// Provides implicit conversion to `ulong`
    public alias value this;

    /// Support for Vibe.d serialization to JSON
    public string toString () const @safe
    {
        import std.conv : to;
        return this.value.to!string;
    }

    /// Support for Vibe.d deserialization
    public static Height fromString (scope const(char)[] str) pure @safe
    {
        import std.conv : to;
        immutable ul = str.to!ulong;
        return Height(ul);
    }

    /// Prevent needing to cast when using unary post plus operator
    public Height opUnary (string op) () if (op == "++")
    {
        return Height(this.value++);
    }

    /// Allow to offset an height by a fixed number
    public Height opBinary (string op : "+") (ulong offset) const
    {
        return Height(this.value + offset);
    }

    /// Allow to offset an height by a fixed number
    public ref Height opBinaryAssign (string op : "+=") (ulong offset) return
    {
        this.value += offset;
        return this;
    }
}

///
unittest
{
    import vibe.data.json;

    const h = Height(1000);
    const(char)[] str_h = "1000";

    assert(h.toString() == str_h);
    assert(h.fromString(str_h) == h);
    assert(h.serializeToJsonString() == "\"1000\"");
    auto x = Height(10);
    assert(x++ == 10);
    assert(x == 11);

    auto y = x + 1;
    assert(y == 12);

    y += 5;
    assert(y == 17);
}

/// Converts a signature to a BitBlob
public BitBlob!(Signature.sizeof) toBlob (in Signature signature) pure nothrow @nogc @safe
{
    typeof(return) ret;
    ret[Scalar.sizeof .. $][] = signature.R[];
    ret[0 .. Scalar.sizeof][] = signature.s[];
    return ret;
}

/// Deserialize a binary blob into a signature
public static Signature toSignature (in BitBlob!(Signature.sizeof) bytes) pure nothrow @nogc @safe
{
    return Signature(Point(bytes[Scalar.sizeof .. $]), Scalar(bytes[0 .. Scalar.sizeof]));
}

/// Deserialize a ubyte array into a signature
public static Signature toSignature (in ubyte[] bytes) pure nothrow @nogc @safe
{
    return BitBlob!(Signature.sizeof)(bytes).toSignature();
}

///
unittest
{
    auto kp = KeyPair.random();
    static immutable string message = "Well Hello!";
    auto sig = kp.secret.sign(message);
    auto blob = sig.toBlob();
    assert(sig == blob.toSignature());
}

/// Delegate type to query the penalty deposit of a utxo
public alias GetPenaltyDeposit = Amount delegate (Hash utxo) @safe nothrow;
