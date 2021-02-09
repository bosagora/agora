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

import agora.common.Types;
import agora.crypto.Hash;

import geod24.bitblob;
import libsodium;

import std.format;

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

    const Scalar Zero = (s3 + (-s3));
    assert(Zero == Scalar.init);

    const Scalar One = (s3 + (~s3));
    assert(One * One == One);

    // Identity addition for Scalar
    assert(Zero + One == One);
    assert(One + Zero == One);

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

    // Identity addition for Point
    const Point pZero = Point.init;

    assert(pZero + G == G);
    assert(G + pZero == G);
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

    /***************************************************************************

        Print the scalar

        By default, this function prints the hidden version of the scalar.
        Changing the mode to `Clear` makes it print the original value.
        This mode is intended for debugging.

        Params:
          sink = The sink to write the piecemeal string data to
          mode = The `PrintMode` to use for printing the content.
                 By default, the hidden value is printed.

    ***************************************************************************/

    public void toString (scope void delegate(in char[]) @safe sink,
                          PrintMode mode = PrintMode.Obfuscated) const @safe
    {
        final switch (mode)
        {
        case PrintMode.Obfuscated:
            formattedWrite(sink, "**SCALAR**");
            break;

        case PrintMode.Clear:
            formattedWrite(sink, "%s", this.data);
            break;
        }
    }

    /// Ditto
    public string toString (PrintMode mode = PrintMode.Obfuscated) const @safe
    {
        string result;
        this.toString((data) { result ~= data; }, mode);
        return result;
    }

    ///
    unittest
    {
        auto s = Scalar("0x0e00a8df701806cb4deac9bb09cc85b097ee713e055b9d2bf1daf668b3f63778");

        assert(s.toString(PrintMode.Obfuscated) == "**SCALAR**");
        assert(s.toString(PrintMode.Clear) ==
               "0x0e00a8df701806cb4deac9bb09cc85b097ee713e055b9d2bf1daf668b3f63778");

        // Test default formatting behavior with writeln, log, etc...
        import std.format : phobos_format = format;
        import ocean.text.convert.Formatter : ocean_format = format;
        assert(phobos_format("%s", s) == "**SCALAR**");
        assert(ocean_format("{}", s) == "**SCALAR**");

        import vibe.data.json;
        assert(s.serializeToJsonString() == "\"**SCALAR**\"",
            s.serializeToJsonString());
    }

    /// Vibe.d deserialization
    public static Scalar fromString (in char[] str) @safe
    {
        return Scalar(typeof(this.data).fromString(str));
    }

    /// Operator overloads for `+`, `-`, `*`
    public Scalar opBinary (string op)(const scope auto ref Scalar rhs)
        const nothrow @nogc @trusted
    {
        // Point.init is Identity for functional operations
        if (this == Scalar.init)
            return rhs;
        if (rhs == Scalar.init)
            return this;
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
            static assert(0, "Binary operator `" ~ op ~ "` not implemented");
        return result;
    }

    /// Get the complement of this scalar
    public Scalar opUnary (string s)()
        const nothrow @nogc @trusted
    {
        Scalar result = void;
        static if (s == "-")
            crypto_core_ed25519_scalar_negate(result.data[].ptr, this.data[].ptr);
        else static if (s == "~")
            crypto_core_ed25519_scalar_complement(result.data[].ptr, this.data[].ptr);
        else
            static assert(0, "Unary operator `" ~ op ~ "` not implemented");
        return result;
    }

    /***************************************************************************

        Returns:
            the inverted scalar.

        See_Also:
            https://libsodium.gitbook.io/doc/advanced/point-arithmetic
            https://tlu.tarilabs.com/cryptography/digital_signatures/introduction_schnorr_signatures.html#why-do-we-need-the-nonce

    ***************************************************************************/

    public Scalar invert () const @nogc @trusted
    {
        Scalar scalar = this;  // copy
        if (crypto_core_ed25519_scalar_invert(scalar.data[].ptr, this.data[].ptr) != 0)
            assert(0);
        return scalar;
    }

    /// Generate a random scalar
    public static Scalar random () nothrow @nogc @trusted
    {
        Scalar ret = void;
        crypto_core_ed25519_scalar_random(ret.data[].ptr);
        return ret;
    }

    /// Scalar should be greater than zero and less than L:2^252 + 27742317777372353535851937790883648493
    public bool isValid () nothrow @nogc @safe const
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
            assert(0, "Provided Scalar is not valid");
        if (!ret.isValid)
            assert(0, "libsodium generated invalid Point from valid Scalar!");
        return ret;
    }

    /// Convenience overload to allow this to be converted to a BitBlob
    public const(ubyte)[] opSlice () const @safe pure nothrow @nogc
    {
        return this.data[];
    }
}

// Test Scalar fromString / toString functions
@safe unittest
{
    static immutable string s = "0x1000000000000000000000000000000014def9dea2f79cd65812631a5cf5d3ec";
    assert(Scalar.fromString(s).toString(PrintMode.Clear) == s);
    // Make sure it's serialized as a value type (without length)
    import agora.common.Serializer;
    assert(Scalar.random().serializeFull().length == Scalar.sizeof);
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
    import agora.common.Serializer;
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

    private this (typeof(this.data) data) @safe @nogc pure nothrow
    {
        this.data = data;
    }

    /// Construct a point from its string representation or a `ubyte[]`
    public this (T) (T param) nothrow @nogc
        if (is(typeof(this.data = typeof(this.data)(param))))
    {
        this.data = typeof(this.data)(param);
    }

    /// Expose `toString`
    public void toString (scope void delegate(in char[]) @safe dg)
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
    public static Point fromString (in char[] str) @safe
    {
        return Point(typeof(this.data).fromString(str));
    }

    /// Operator overloads for points additions
    public Point opBinary (string op)(const scope auto ref Point rhs)
        const nothrow @nogc @trusted
        if (op == "+" || op == "-")
    {
        // Point.init is Identity for functional operations
        if (this == Point.init)
            return rhs;
        if (rhs == Point.init)
            return this;
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

    // Validation that it is a valid point using libsodium
    public bool isValid () nothrow @nogc @trusted const
    {
        return (crypto_core_ed25519_is_valid_point(this.data[].ptr) == 1);
    }
}

// Test serialization
unittest
{
    import agora.common.Serializer;
    testSymmetry!Point();
    testSymmetry(Scalar.random().toPoint());
    // Make sure it's serialized as a value type (without length)
    assert(Scalar.random().toPoint().serializeFull().length == Point.sizeof);
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

// Test validation
unittest
{
    auto valid = Point.fromString("0xab4f6f6e85b8d0d38f5d5798a4bdc4dd444c8909c8a5389d3bb209a18610511b");
    assert(valid.isValid());

    // Add 1 to last byte of valid serialized Point to make it invalid
    auto invalid = Point.fromString("0xab4f6f6e85b8d0d38f5d5798a4bdc4dd444c8909c8a5389d3bb209a18610511c");
    assert(!invalid.isValid());

    // Test initialized with no data is invalid
    auto invalid2 = Point.init;
    assert(!invalid2.isValid());
}
