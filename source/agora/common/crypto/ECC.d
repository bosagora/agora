/*******************************************************************************

    Elliptic-curve primitives

    Those primitives are used for Schnorr signatures.

    See_Also: https://en.wikipedia.org/wiki/EdDSA#Ed25519

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.crypto.ECC;

import agora.common.Hash;
import geod24.bitblob;
import libsodium;

///
nothrow @nogc unittest
{
    const Scalar s1 = Scalar.random();
    const Scalar s2 = Scalar.random();
    const Scalar s3 = s1 + s2;

    assert(s3 - s1 == s2);
    assert(s3 - s2 == s1);
    assert(s3 - s3 == Scalar.init);
    assert(-s3 == -s1 - s2);
    assert(-s3 == -s2 - s1);

    const Scalar One = (s3 + (-s3));
    assert(One * One == One);
    // Get the generator
    const Point G = One.toPoint();
    assert(G + G == (One + One).toPoint());

    const Point p1 = s1.toPoint();
    const Point p2 = s2.toPoint();
    const Point p3 = s3.toPoint();

    assert(s1.toPoint() == p1);
    assert(p3 - p1 == p2);
    assert(p3 - p2 == p1);

    assert(s1 * p2 + s2 * p2 == s3 * p2);
}

/*******************************************************************************

    A field element in the finite field of order 2^255-19

    Scalar are used as private key and source of noise for signatures.

*******************************************************************************/

public struct Scalar
{
    /// Internal state
    package BitBlob!(crypto_core_ed25519_SCALARBYTES * 8) data;

    private this (typeof(this.data) data) @safe
    {
        this.data = data;
    }

    /// Construct a scalar from its string representation or a `ubyte[]`
    public this (T) (T param)
        if (is(typeof(this.data = typeof(this.data)(param))))
    {
        this.data = typeof(this.data)(param);
    }

    /// Reduce the hash to a scalar
    public this (Hash param) nothrow @nogc
    {
        crypto_core_ed25519_scalar_reduce(this.data[].ptr, param[].ptr);
    }

    /// Expose `toString`
    public void toString (scope void delegate(const(char)[]) @safe dg)
        const @safe
    {
        this.data.toString(dg);
    }

    /// Ditto
    public string toString () const @safe
    {
        return this.data.toString();
    }

    /// Vibe.d deserialization
    public static Scalar fromString (scope const(char)[] str) @safe
    {
        return Scalar(typeof(this.data).fromString(str));
    }

    /// Operator overloads for `+`, `-`, `*`
    public Scalar opBinary (string op)(const scope auto ref Scalar rhs)
        const nothrow @nogc
    {
        Scalar result = void;
        static if (op == "+")
            crypto_core_ed25519_scalar_add(
                result.data[].ptr, this.data[].ptr, rhs.data[].ptr);
        else static if (op == "-")
            crypto_core_ed25519_scalar_sub(
                result.data[].ptr, this.data[].ptr, rhs.data[].ptr);
        else static if (op == "*")
            crypto_core_ed25519_scalar_mul(
                result.data[].ptr, this.data[].ptr, rhs.data[].ptr);
        else
            static assert(0, "Operator " ~ op ~ " not implemented");
        return result;
    }

    /// Get the complement of this scalar
    public Scalar opUnary (string s)()
        const nothrow @nogc
        if (s == "-")
    {
        Scalar result = void;
        crypto_core_ed25519_scalar_complement(result.data[].ptr, this.data[].ptr);
        return result;
    }

    /// Generate a random scalar
    public static Scalar random () nothrow @nogc
    {
        Scalar ret = void;
        crypto_core_ed25519_scalar_random(ret.data[].ptr);
        return ret;
    }

    /// Return the point corresponding to this scalar multiplied by the generator
    public Point toPoint () const nothrow @nogc
    out (val) { assert(crypto_core_ed25519_is_valid_point(val.data[].ptr)); }
    do {
        Point ret = void;
        if (crypto_scalarmult_ed25519_base_noclamp(ret.data[].ptr, this.data[].ptr))
            assert(0);
        return ret;
    }
}

/*******************************************************************************

    Represent a point on Curve25519

    A point is an element of the cyclic subgroup formed from the elliptic curve:
    x^2 + y^2 = 1 - (121665 / 1216666) * x^2 * y^2
    And the base point `B` where By=4/5 and Bx > 0.

*******************************************************************************/

public struct Point
{
    /// Internal state
    package BitBlob!(crypto_core_ed25519_BYTES * 8) data;

    private this (typeof(this.data) data) @safe
    {
        this.data = data;
    }

    /// Construct a point from its string representation or a `ubyte[]`
    public this (T) (T param)
        nothrow @nogc
        if (is(typeof(this.data = typeof(this.data)(param))))
    {
        this.data = typeof(this.data)(param);
    }

    /// Expose `toString`
    public void toString (scope void delegate(const(char)[]) @safe dg)
        const @safe
    {
        this.data.toString(dg);
    }

    /// Ditto
    public string toString () const @safe
    {
        return this.data.toString();
    }

    /// Vibe.d deserialization
    public static Point fromString (scope const(char)[] str) @safe
    {
        return Point(typeof(this.data).fromString(str));
    }

    /// Operator overloads for points additions
    public Point opBinary (string op)(const scope auto ref Point rhs)
        const nothrow @nogc
        if (op == "+" || op == "-")
    {
        Point result = void;
        static if (op == "+")
        {
            if (crypto_core_ed25519_add(
                    result.data[].ptr, this.data[].ptr, rhs.data[].ptr))
                assert(0);
        }
        else static if (op == "-")
        {
            if (crypto_core_ed25519_sub(
                    result.data[].ptr, this.data[].ptr, rhs.data[].ptr))
                assert(0);
        }
        else static assert(0, "Unhandled `" ~ op ~ "` operator for Point");
        return result;
    }

    /// Operator overloads for scalar multiplication
    public Point opBinary (string op)(const scope auto ref Scalar rhs)
        const nothrow @nogc
        if (op == "*")
    {
        Point result = void;
        if (crypto_scalarmult_ed25519_noclamp(
                result.data[].ptr, rhs.data[].ptr, this.data[].ptr))
            assert(0);
        return result;
    }

    /// Ditto
    public Point opBinaryRight (string op)(const scope auto ref Scalar lhs)
        const nothrow @nogc
        if (op == "*")
    {
        Point result = void;
        if (crypto_scalarmult_ed25519_noclamp(
                result.data[].ptr, lhs.data[].ptr, this.data[].ptr))
            assert(0);
        return result;
    }
}
