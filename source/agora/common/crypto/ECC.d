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
import agora.common.Serializer;
import agora.common.Types;

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
    public this (Hash param) @trusted nothrow @nogc
    {
        static assert(typeof(data).sizeof == 32);
        static assert(Hash.sizeof == 64);
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
        const nothrow @nogc @trusted
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
        const nothrow @nogc @trusted
        if (s == "-")
    {
        Scalar result = void;
        crypto_core_ed25519_scalar_complement(result.data[].ptr, this.data[].ptr);
        return result;
    }

    /// Generate a random scalar
    public static Scalar random () nothrow @nogc @trusted
    {
        Scalar ret = void;
        crypto_core_ed25519_scalar_random(ret.data[].ptr);
        return ret;
    }

    /// Scalar should be greater than zero and less than L:2^252 + 27742317777372353535851937790883648493
    public bool isValid() () nothrow @nogc @safe
    {
        const auto ED25519_L =  BitBlob!256("0x1000000000000000000000000000000014def9dea2f79cd65812631a5cf5d3ed");
        const auto ZERO =       BitBlob!256("0x0000000000000000000000000000000000000000000000000000000000000000");
        return this.data > ZERO && this.data < ED25519_L;
    }

    /// Return the point corresponding to this scalar multiplied by the generator
    public Point toPoint () const nothrow @nogc @trusted 
    {
        Point ret = void;
        if (crypto_scalarmult_ed25519_base_noclamp(ret.data[].ptr, this.data[].ptr) != 0)
            assert(0, "Scalar is not valid");
        if (crypto_core_ed25519_is_valid_point(ret.data[].ptr) != 1)
            assert(0, "Point is not valid");
        return ret;
    }

    /***************************************************************************

        Serialization

        Params:
            dg = serialize function accumulator

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) const @safe
    {
        dg(this.data[]);
    }

    /***************************************************************************

        Returns:
            the inverted scalar.

        See_Also:
            https://libsodium.gitbook.io/doc/advanced/point-arithmetic
            https://tlu.tarilabs.com/cryptography/digital_signatures/introduction_schnorr_signatures.html#why-do-we-need-the-nonce

    ***************************************************************************/

    public Scalar invert () @trusted
    {
        Scalar scalar = this;  // copy
        assert(crypto_core_ed25519_scalar_invert(scalar.data[].ptr,
            this.data[].ptr) == 0);
        return scalar;
    }
}

// Test Scalar fromString / toString functions
@safe unittest
{
    static immutable string s = "0x1000000000000000000000000000000014def9dea2f79cd65812631a5cf5d3ec";
    assert(Scalar.fromString(s).toString == s);
}

// Test valid Scalars
nothrow @nogc @safe unittest
{
    assert(Scalar(`0x1000000000000000000000000000000014def9dea2f79cd65812631a5cf5d3ec`).isValid);
    assert(Scalar(`0x0eadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef`).isValid);
    assert(Scalar(`0x0000000000000000000000000000000000000000000000000000000000000001`).isValid);
}

// Test invalid Scalars
nothrow @nogc @safe unittest
{
    assert(!Scalar().isValid);
    assert(!Scalar(`0x0000000000000000000000000000000000000000000000000000000000000000`).isValid);
    assert(!Scalar(`0x1000000000000000000000000000000014def9dea2f79cd65812631a5cf5d3ed`).isValid);
    assert(!Scalar(`0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef`).isValid);
    assert(!Scalar(`0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff`).isValid);
}

//
unittest
{
    testSymmetry!Scalar();
    testSymmetry(Scalar.random());
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
        const nothrow @nogc @trusted
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
        const nothrow @nogc @trusted
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
        const nothrow @nogc @trusted
        if (op == "*")
    {
        Point result = void;
        if (crypto_scalarmult_ed25519_noclamp(
                result.data[].ptr, lhs.data[].ptr, this.data[].ptr))
            assert(0);
        return result;
    }

    /// Convenience overload to allow this to be converted to a `PublicKey`
    public const(ubyte)[] opSlice () const @safe pure nothrow @nogc
    {
        return this.data[];
    }

    /// Support for comparison
    public int opCmp (ref const typeof(this) s) const
    {
        return this.data.opCmp(s.data);
    }

    /// Support for comparison (rvalue overload)
    public int opCmp (const typeof(this) s) const
    {
        return this.data.opCmp(s.data);
    }

    /***************************************************************************

        Serialization

        Params:
            dg = serialize function accumulator

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) const @safe
    {
        dg(this.data[]);
    }
}

// Test serialization
unittest
{
    testSymmetry!Point();
    testSymmetry(Scalar.random().toPoint());
}

// Test sorting (`opCmp`)
unittest
{
    Point[] points = [
        Point.fromString(
            "0x44404b654d6ddf71e2446eada6acd1f462348b1b17272ff8f36dda3248e08c81"),
        Point.fromString(
            "0x37e8a197247dd01cc27c178dc0465ce826b4f6e312f3ee4c1df0623ef38c51c5")];

    import std.algorithm : sort;
    points.sort;
    assert(points[0] == Point.fromString(
            "0x37e8a197247dd01cc27c178dc0465ce826b4f6e312f3ee4c1df0623ef38c51c5"));
}
