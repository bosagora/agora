/*******************************************************************************

    Holds primitive types for key operations

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.crypto.Key;

import agora.common.crypto.Crc16;
import agora.common.Data;
import agora.common.Deserializer;
import agora.common.Hash;
import agora.common.Serializer;

import geod24.bitblob;
import base32;
import libsodium;

import std.exception;


/// Simple signature example
unittest
{
    import std.string : representation;

    KeyPair kp = KeyPair.random();
    Signature sign = kp.secret.sign("Hello World".representation);
    assert(kp.address.verify(sign, "Hello World".representation));

    // Message can't be changed
    assert(!kp.address.verify(sign, "Hello World?".representation));

    // Another keypair won't verify it
    KeyPair other = KeyPair.random();
    assert(!other.address.verify(sign, "Hello World".representation));

    // Signature can't be changed
    sign[].ptr[0] = sign[].ptr[0] ? 0 : 1;
    assert(!kp.address.verify(sign, "Hello World".representation));
}

/// A structure to hold a secret key + public key + seed
/// Can be constructed from a seed
/// To construct addresses (PublicKey), see `fromString`
public struct KeyPair
{
    /// Public key
    public const PublicKey address;

    /// Secret key
    public const SecretKey secret;

    /// Seed
    public const Seed seed;


    /// Constructor accepting only 3 arguments
    private this (typeof(KeyPair.tupleof) args) pure nothrow @safe @nogc
    {
        this.tupleof = args;
    }

    /// Create a keypair from a `Seed`
    public static KeyPair fromSeed (Seed seed) nothrow @nogc
    {
        SecretKey sk;
        PublicKey pk;
        if (crypto_sign_seed_keypair(pk[].ptr, sk[].ptr, seed[].ptr) != 0)
            assert(0);
        return KeyPair(pk, sk, seed);
    }

    ///
    unittest
    {
        immutable seedStr = `SBBUWIMSX5VL4KVFKY44GF6Q6R5LS2Z5B7CTAZBNCNPLS4UKFVDXC7TQ`;
        KeyPair kp = KeyPair.fromSeed(Seed.fromString(seedStr));
    }

    /// Generate a new, random, keypair
    public static KeyPair random () @nogc
    {
        SecretKey sk;
        PublicKey pk;
        Seed seed;
        if (crypto_sign_keypair(pk[].ptr, sk[].ptr) != 0)
            assert(0);
        if (crypto_sign_ed25519_sk_to_seed(seed[].ptr, sk[].ptr) != 0)
            assert(0);
        return KeyPair(pk, sk, seed);
    }
}

/// Represent a public key / address
public struct PublicKey
{
    /*private*/ BitBlob!(crypto_sign_ed25519_PUBLICKEYBYTES * 8) data;
    alias data this;

    /// Construct an instance from the binary representation
    private this (typeof(PublicKey.tupleof) args) pure nothrow @safe @nogc
    {
        this.tupleof = args;
    }

    /// Ditto
    public this (const ubyte[] args) pure nothrow @safe @nogc
    {
        this.data = args;
    }

    /// Uses Stellar's representation instead of hex
    public string toString () const @trusted
    {
        ubyte[1 + PublicKey.Width + 2] bin;
        bin[0] = VersionByte.AccountID;
        bin[1 .. $ - 2] = this.data[];
        bin[$ - 2 .. $] = checksum(bin[0 .. $ - 2]);
        return Base32.encode(bin).assumeUnique;
    }

    /// Make sure the sink overload of BitBlob is not picked
    public void toString (scope void delegate(const(char)[]) sink) const @trusted
    {
        ubyte[1 + PublicKey.Width + 2] bin;
        bin[0] = VersionByte.AccountID;
        bin[1 .. $ - 2] = this.data[];
        bin[$ - 2 .. $] = checksum(bin[0 .. $ - 2]);
        Base32.encode(bin, sink);
    }

    ///
    unittest
    {
        immutable address = `GDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQFW`;
        PublicKey pubkey = PublicKey.fromString(address);

        import std.array : appender;
        import std.format : formattedWrite;
        auto writer = appender!string();
        writer.formattedWrite("%s", pubkey);
        assert(writer.data() == address);
    }

    /// Create a Public key from Stellar's string representation
    public static PublicKey fromString (scope const(char)[] str) @trusted
    {
        const bin = Base32.decode(str);
        assert(bin.length == 1 + PublicKey.Width + 2);
        assert(bin[0] == VersionByte.AccountID);
        assert(validate(bin[0 .. $ - 2], bin[$ - 2 .. $]));
        return PublicKey(typeof(this.data)(bin[1 .. $ - 2]));
    }

    ///
    unittest
    {
        immutable address = `GDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQFW`;
        PublicKey pubkey = PublicKey.fromString(address);
        assert(pubkey.toString() == address);
    }

    /***************************************************************************

        Implements hashing support

        Params:
            dg = hashing function

    ***************************************************************************/

    public void computeHash (scope HashDg dg) const nothrow @safe @nogc
    {
        dg(this.data[]);
    }

    /***************************************************************************

        Key Serialization

        Params:
            dg = Serialize function

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) const @safe
    {
        dg(this.data[]);
    }

    /***************************************************************************

        PublicKey fromBinary

        Params:
            dg = deserialize function

        Returns:
            `PublicKey` Public key address

    ***************************************************************************/

    public static PublicKey fromBinary (scope DeserializeDg dg) nothrow @safe
    {
        alias DType = typeof(this.data);
        return PublicKey(DType(dg(DType.sizeof)));
    }

    ///
    unittest
    {
        immutable address =
            `GDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQFW`;
        PublicKey pubkey = PublicKey.fromString(address);

        () nothrow @safe @nogc
        {
            auto hash = hashFull(pubkey);
            auto exp_hash = Hash("0xdb3b785e31c05c9383f498aa12a5c054fcb6f99b2" ~
                "0bf7ff25fdb24d5fe6d1bb5768f1821de9d5d31faa7ebafc79837ba32dc4" ~
                "774bffea9918411d0c4c8ac403c");
            assert(hash == exp_hash);
        }();
    }

    /***************************************************************************

        Verify that a signature matches a given message

        Params:
          signature = The signature of `msg` matching `this` public key.
          msg = The signed message. Should not include the signature.

        Returns:
          `true` iff the signature is valid

    ***************************************************************************/

    public bool verify (Signature signature, scope const(ubyte)[] msg)
        const nothrow @nogc @trusted
    {
        // The underlying function does not expose a safe interface,
        // but we know (thanks to tests and careful inspection)
        // that our data type match and they are unlikely to change
        return 0 ==
            crypto_sign_ed25519_verify_detached(
                signature[].ptr, msg.ptr, msg.length, this.data[].ptr);
    }
}

/// A secret key.
/// Since we mostly expose seed and public key to the user,
/// this does not expose any Stellar serialization shenanigans.
public struct SecretKey
{
    nothrow @nogc:

    /*private*/ BitBlob!(crypto_sign_ed25519_SECRETKEYBYTES * 8) data;
    alias data this;

    /// Constructor accepting only 1 argument
    private this (typeof(this.tupleof) args)
    {
        this.tupleof = args;
    }

    /***************************************************************************

        Signs a message with this private key

        Params:
          msg = The message to sign

        Returns:
          The signature of `msg` using `this`

    ***************************************************************************/

    public Signature sign (scope const(ubyte)[] msg) const
    {
        Signature result;
        // The second argument, `siglen_p`, a pointer to the length of the
        // signature, is always set to `64U` and supports `null`
        if (crypto_sign_ed25519_detached(result[].ptr, null, msg.ptr, msg.length, this.data[].ptr) != 0)
            assert(0);
        return result;
    }
}

/// A Stellar seed
public struct Seed
{
    /*private*/ BitBlob!(crypto_sign_ed25519_SEEDBYTES * 8) data;
    alias data this;

    /// Constructor accepting only 1 argument
    private this (typeof(Seed.tupleof) args)
    {
        this.tupleof = args;
    }

    /// Uses Stellar's representation instead of hex
    public string toString () const
    {
        ubyte[1 + Seed.Width + 2] bin;
        bin[0] = VersionByte.Seed;
        bin[1 .. $ - 2] = this.data[];
        bin[$ - 2 .. $] = checksum(bin[0 .. $ - 2]);
        return Base32.encode(bin).assumeUnique;
    }

    /// Make sure the sink overload of BitBlob is not picked
    public void toString (scope void delegate(const(char)[]) sink) const
    {
        ubyte[1 + Seed.Width + 2] bin;
        bin[0] = VersionByte.Seed;
        bin[1 .. $ - 2] = this.data[];
        bin[$ - 2 .. $] = checksum(bin[0 .. $ - 2]);
        Base32.encode(bin, sink);
    }

    /// Create a Seed from Stellar's string representation
    public static Seed fromString (scope const(char)[] str)
    {
        const bin = Base32.decode(str);
        assert(bin.length == 1 + Seed.Width + 2);
        assert(bin[0] == VersionByte.Seed);
        assert(validate(bin[0 .. $ - 2], bin[$ - 2 .. $]));
        return Seed(typeof(this.data)(bin[1 .. $ - 2]));
    }
}

///
public enum VersionByte : ubyte
{
	/// Used for encoded stellar addresses
    /// Base32-encodes to 'G...'
	AccountID = 6 << 3,

    /// Used for encoded stellar seed
    /// Base32-encodes to 'S...'
	Seed = 18 << 3,

    /// Used for encoded stellar hashTx signer keys.
    /// Base32-encodes to 'T...'
	HashTx = 19 << 3,

    /// Used for encoded stellar hashX signer keys.
    /// Base32-encodes to 'X...'
	HashX = 23 << 3,
}

// Test with a stable keypair
// We cannot actually test the content of the signature since it includes
// random data, so it changes every time
unittest
{
    immutable address = `GDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQFW`;
    immutable seed    = `SBBUWIMSX5VL4KVFKY44GF6Q6R5LS2Z5B7CTAZBNCNPLS4UKFVDXC7TQ`;

    KeyPair kp = KeyPair.fromSeed(Seed.fromString(seed));
    assert(kp.address.toString() == address);

    import std.string : representation;
    Signature sig = kp.secret.sign("Hello World".representation);
    assert(kp.address.verify(sig, "Hello World".representation));
}
