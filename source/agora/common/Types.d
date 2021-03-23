/*******************************************************************************

    Defines common types used by Agora

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Types;

import agora.crypto.ECC;
import agora.crypto.Key;
import agora.crypto.Schnorr;
public import agora.crypto.Types;

import geod24.bitblob;

/// Represents a specific point in time, it should be changed to time_t
/// after time_t became platform independent
public alias TimePoint = ulong;

/// An array of const characters
public alias cstring = const(char)[];

/// A network address
public alias Address = string;

/// The definition of a Quorum
public struct QuorumConfig
{
    /// Threshold of this quorum set
    public uint threshold = 1;

    /// List of nodes in this quorum
    public PublicKey[] nodes;

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

    /// Allow to offset height by an addition of a fixed number
    public Height opBinary (string op : "+") (ulong offset) const
    {
        return Height(this.value + offset);
    }

    /// Allow to offset height by a subtraction of a fixed number
    public Height opBinary (string op : "-") (ulong offset) const
    {
        import std.conv : to;
        assert(this.value - offset >= 0, "Attempt to subtract" ~ offset.to!string ~ " from height " ~ this.value.to!string);
        return Height(this.value - offset);
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
