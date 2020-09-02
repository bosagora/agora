/*******************************************************************************

    Low level utilities to perform Schnorr signatures on Curve25519.

    Through this module, lowercase letters represent scalars and uppercase
    letters represent points. Multiplication of a scalar by a point,
    which is adding a point to itself multiple times, is represented with '*',
    e.g. `a * G`. Uppercase letters are point representations of scalars,
    that is, the scalar multipled by the generator, e.g. `r == r * G`.
    `x` is the private key, `X` is the public key, and `H()` is the Blake2b
    512 bits hash reduced to a scalar in the field.

    Following the Schnorr BIP (see links), signatures are of the form
    `(R,s)` and satisfy `s * G = R + H(X || R || m) * X`.
    `r` is refered to as the nonce and is a cryptographically randomly
    generated number that should neither be reused nor leaked.

    Signature_Aggregation:
    Since Schnorr signatures use a linear equation, they can be simply
    combined with addition, enabling `O(1)` signature verification
    time and `O(1)` and `O(1)` signature size.
    Additionally, since the `c` factor does not depend on EC operation,
    we can do batch verification, enabling us to speed up verification
    when verifying large amount of data (e.g. a block).

    See_Also:
      - https://en.wikipedia.org/wiki/Curve25519
      - https://en.wikipedia.org/wiki/Schnorr_signature
      - https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki
      - https://www.secg.org/sec1-v2.pdf

    TODO:
      - Compress signature according to SEC1 v2 (Section 2.3) (#304)
      - Audit GDC and LDC generated code
      - Proper audit

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.crypto.Schnorr;

import agora.common.Types;
import agora.common.Hash;
import agora.common.crypto.ECC;

import std.algorithm;
import std.range;


/// Single signature example
nothrow @nogc @safe unittest
{
    Pair kp = Pair.random();
    auto signature = sign(kp, "Hello world");
    assert(verify(kp.V, signature, "Hello world"));
}

/// Complex API, allow multisig
public Signature mySign (T) (
    const ref Scalar k, const ref Scalar r, auto ref T data)
    nothrow @nogc @trusted
{
    Scalar c = hashFull(data);
    Scalar s = r + (k * c);
    return Sig(r.toPoint(), s).toBlob();
}

public bool myVerify (T) (
    const ref Signature sig, Point[] K, Point[] R, auto ref T data)
    nothrow @nogc @trusted
{
    Scalar c0 = hashMulti(data);
    auto bigS = R[0] + K[0] * c0;

    foreach (idx; 1 .. R.length)
    {
        Scalar c = hashFull(data);
        bigS = bigS + R[idx] + K[idx] * c;
    }

    Sig s = Sig.fromBlob(sig);
    return s.s.toPoint() == bigS;
}

/// Multi-signature example
nothrow /*@nogc*/ @safe unittest
{
    static immutable string message = "BOSAGORA for the win";
    Pair kp1 = Pair.random();
    Pair kp2 = Pair.random();
    Pair kp3 = Pair.random();
    Pair R1 = Pair.random();
    Pair R2 = Pair.random();
    Pair R3 = Pair.random();

    const sig1 = mySign(kp1.v, R1.v, message);
    const sig2 = mySign(kp2.v, R2.v, message);
    const sig3 = mySign(kp3.v, R3.v, message);

    const comb = Sig(R1.V + R2.V + R3.V,
        Sig.fromBlob(sig1).s + Sig.fromBlob(sig2).s + Sig.fromBlob(sig3).s).toBlob();

    assert(myVerify(comb, [kp1.V, kp2.V, kp3.V], [R1.V, R2.V, R3.V], message));
}

/// Multi-signature example
nothrow @nogc @safe unittest
{
    // Setup
    static immutable string secret = "BOSAGORA for the win";
    Pair kp1 = Pair.random();
    Pair kp2 = Pair.random();
    Pair R1 = Pair.random();
    Pair R2 = Pair.random();
    Point R = R1.V + R2.V;
    Point X = kp1.V + kp2.V;

    const sig1 = sign(kp1.v, X, R, R1.v, secret);
    const sig2 = sign(kp2.v, X, R, R2.v, secret);
    const sig3 = Sig(R, Sig.fromBlob(sig1).s + Sig.fromBlob(sig2).s).toBlob();

    // No one can verify any of those individually
    assert(!verify(kp1.V, sig1, secret));
    assert(!verify(kp1.V, sig2, secret));
    assert(!verify(kp2.V, sig2, secret));
    assert(!verify(kp2.V, sig1, secret));
    assert(!verify(kp1.V, sig3, secret));
    assert(!verify(kp2.V, sig3, secret));

    // But multisig works
    assert(verify(X, sig3, secret));
}

/*******************************************************************************

    Represent a signature (R, s)

    Note that signatures get passed around as binary blobs
    (see `agora.common.Types`), so this type is named `Sig` to avoid ambiguity.

*******************************************************************************/

package struct Sig
{
    /// Commitment
    public Point R;
    /// Proof
    public Scalar s;

    static assert(Signature.sizeof == typeof(this).sizeof);

    /// Converts this signature to a BitBlob matching `agora.common.Types`
    public Signature toBlob () const pure nothrow @nogc @safe
    {
        typeof(return) ret;
        ret[0 .. Point.sizeof][] = this.R.data[];
        ret[Point.sizeof .. $][] = this.s.data[];
        return ret;
    }

    /// Deserialize a binary blob into a signature
    public static Sig fromBlob (const ref Signature s) pure nothrow @nogc @safe
    {
        return Sig(Point(s[0 .. Point.sizeof]), Scalar(s[Point.sizeof .. $]));
    }
}

///
unittest
{
    import agora.common.Serializer;

    const KP = Pair.random();
    auto signature = Sig(KP.V, KP.v).toBlob();
    auto bytes = signature.serializeFull();
    assert(bytes.deserializeFull!Signature == signature);
}

/// Represent the message to hash (part of `c`)
private struct Message (T)
{
    public Point X;
    public Point R;
    public T     message;
}


/// Contains a scalar and its projection on the elliptic curve (`v` and `v.G`)
public struct Pair
{
    /// A PRNGenerated number
    public Scalar v;
    /// v.G
    public Point V;

    /// Generate a random value `v` and a point on the curve `V` where `V = v.G`
    public static Pair random () nothrow @nogc @safe
    {
        Scalar sc = Scalar.random();
        return Pair(sc, sc.toPoint());
    }
}

/// Single-signer trivial API
public Signature sign (T) (const ref Pair kp, auto ref T data)
    nothrow @nogc @safe
{
    const R = Pair.random();
    return sign!T(kp.v, kp.V, R.V, R.v, data);
}

/// Single-signer privkey API
public Signature sign (T) (const ref Scalar privateKey, T data)
    nothrow @nogc @safe
{
    const R = Pair.random();
    return sign!T(privateKey, privateKey.toPoint(), R.V, R.v, data);
}

/// Sign with a given `r` (warning: `r` should never be reused with `x`)
public Signature sign (T) (const ref Pair kp, const ref Pair r, auto ref T data)
{
    return sign!T(kp.v, kp.V, r.V, r.v, data);
}

/// Complex API, allow multisig
public Signature sign (T) (
    const ref Scalar x, const ref Point X,
    const ref Point R, const ref Scalar r,
    auto ref T data)
    nothrow @nogc @trusted
{
    /*
      G := Generator point:
      15112221349535400772501151409588531511454012693041857206046113283949847762202,
      46316835694926478169428394003475163141307993866256225615783033603165251855960
      x := private key
      X := public key (x.G)
      r := random number
      R := commitment (r.G)
      c := Hash(X || R || message)

      Proof = (R, s)
      Signature/Verify: R + c*X == s.G
      Multisig:
      R = (r0 + r1 + rn).G == (R0 + R1 + Rn)
      X = (X0 + X1 + Xn)
      To get `c`, need to precommit `R`
     */
    // Compute the challenge and reduce the hash to a scalar
    Scalar c = hashFull(Message!T(X, R, data));
    // Compute `s` part of the proof
    Scalar s = r + (c * x);
    return Sig(R, s).toBlob();
}

/*******************************************************************************

    Verify that a signature matches the provided data

    Params:
      T = Type of data being signed
      X = The point corresponding to the public key
      sig = Signature to verify
      data = Data to sign (the hash will be signed)

    Returns:
      Whether or not the signature is valid for (X, s, data).

*******************************************************************************/

public bool verify (T) (const ref Point X, const ref Signature sig, auto ref T data)
    nothrow @nogc @trusted
{
    Sig s = Sig.fromBlob(sig);
    // Compute the challenge and reduce the hash to a scalar
    Scalar c = hashFull(Message!T(X, s.R, data));
    // Compute `R + c*X`
    Point RcX = s.R + (c * X);
    /// Compute `s.G`
    auto S = s.s.toPoint();
    return S == RcX;
}

///
nothrow @nogc @safe unittest
{
    Scalar key = Scalar(`0x074360d5eab8e888df07d862c4fc845ebd10b6a6c530919d66221219bba50216`);
    Pair kp = Pair(key, key.toPoint());
    auto signature = sign(kp, "Hello world");
    assert(verify(kp.V, signature, "Hello world"));
}

nothrow @nogc @safe unittest
{
    Scalar key = Scalar(`0x074360d5eab8e888df07d862c4fc845ebd10b6a6c530919d66221219bba50216`);
    Pair kp = Pair(key, key.toPoint());
    auto signature = sign(kp, "Hello world.");
    assert(!verify(kp.V, signature, "Hello world"));
}

nothrow @nogc @safe unittest
{
    static immutable string secret = "BOSAGORA for the win";
    Pair kp1 = Pair.random();
    Pair kp2 = Pair.random();
    auto sig1 = sign(kp1, secret);
    auto sig2 = sign(kp2, secret);
    assert(verify(kp1.V, sig1, secret));
    assert(!verify(kp1.V, sig2, secret));
    assert(verify(kp2.V, sig2, secret));
    assert(!verify(kp2.V, sig1, secret));
}
