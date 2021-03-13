/*******************************************************************************

    Holds primitive types for key operations

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.crypto.Key;

import agora.common.Types;
import agora.crypto.Crc16;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Schnorr;
import agora.serialization.Serializer;

import geod24.bitblob;
import base32;
import libsodium;

import std.exception;
import std.format;


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

    /// Create a keypair from a `SecretKey`
    public static KeyPair fromSeed (const SecretKey seed) nothrow @nogc
    {
        BitBlob!(crypto_sign_ed25519_SECRETKEYBYTES) sk_data;
        BitBlob!(crypto_core_ed25519_BYTES) pk;
        if (crypto_sign_seed_keypair(pk[].ptr, sk_data[].ptr, seed[].ptr) != 0)
            assert(0);

        Scalar x25519_sk;
        if (crypto_sign_ed25519_sk_to_curve25519(cast(ubyte*)(x25519_sk[].ptr), sk_data[].ptr) != 0)
            assert(0);
        SecretKey sk = SecretKey(x25519_sk[]);
        return KeyPair(PublicKey(pk[]), sk);
    }

    ///
    unittest
    {
        immutable seedStr = `SBBUWIMSX5VL4KVFKY44GF6Q6R5LS2Z5B7CTAZBNCNPLS4UKFVDXC7TQ`;
        KeyPair kp = KeyPair.fromSeed(SecretKey.fromString(seedStr));
    }

    /***************************************************************************

        Signs a message with this keypair's private key

        Params:
          msg = The message to sign

        Returns:
          The signature of `msg` using `this`

    ***************************************************************************/

    public Signature sign (T) (in T msg) const nothrow @nogc
    {
        return agora.crypto.Schnorr.sign(
            Pair(this.secret.data, this.address.data), msg);
    }

    /// Generate a new, random, keypair
    public static KeyPair random () @nogc
    {
        Pair p = Pair.random();
        assert(p.v.isValid());
        return KeyPair(PublicKey(p.V), SecretKey(p.v));
    }
}

// Test (de)serialization
unittest
{
    testSymmetry!KeyPair();
    testSymmetry(KeyPair.random());
}

private immutable int VersionWidth = 1;
private immutable int ChecksumWidth = 2;

/// Represent a public key / address
public struct PublicKey
{
    /*private*/ Point data;
    alias data this;

    /// Construct an instance from binary data
    public this (const Point args) pure nothrow @safe @nogc
    {
        this.data = args;
    }

    /// Ditto
    public this (const ubyte[] args) pure nothrow @safe @nogc
    {
        this.data = args;
    }

    /// Uses Stellar's representation instead of hex
    public string toString () const @trusted nothrow
    {
        ubyte[VersionWidth + PublicKey.sizeof + ChecksumWidth] bin;
        bin[0] = VersionByte.AccountID;
        bin[VersionWidth .. $ - ChecksumWidth] = this.data[];
        bin[$ - ChecksumWidth .. $] = checksum(bin[0 .. $ - ChecksumWidth]);
        return Base32.encode(bin).assumeUnique;
    }

    /// Make sure the sink overload of BitBlob is not picked
    public void toString (scope void delegate(const(char)[]) sink) const @trusted
    {
        ubyte[VersionWidth + PublicKey.sizeof + ChecksumWidth] bin;
        bin[0] = VersionByte.AccountID;
        bin[VersionWidth .. $ - ChecksumWidth] = this.data[];
        bin[$ - ChecksumWidth .. $] = checksum(bin[0 .. $ - ChecksumWidth]);
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

    /***************************************************************************

        Params:
            str = the string which should contain a public key

        Returns:
            a Public key from Stellar's string representation

        Throws:
            an Exception if the input string is not well-formed

    ***************************************************************************/

    public static PublicKey fromString (scope const(char)[] str) @trusted
    {
        const bin = Base32.decode(str);
        enforce(bin.length == VersionWidth + PublicKey.sizeof + ChecksumWidth);
        enforce(bin[0] == VersionByte.AccountID);
        enforce(validate(bin[0 .. $ - ChecksumWidth], bin[$ - ChecksumWidth .. $]));
        return PublicKey(typeof(this.data)(bin[VersionWidth .. $ - ChecksumWidth]));
    }

    ///
    unittest
    {
        immutable address = `GDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQFW`;
        PublicKey pubkey = PublicKey.fromString(address);
        assert(pubkey.toString() == address);
        assertThrown(PublicKey.fromString(  // bad length
            "GDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQF"));
        assertThrown(PublicKey.fromString(  // bad version byte
            "XDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQFW"));
        assertThrown(PublicKey.fromString(  // bad checksum
            "GDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQFF"));
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

    ///
    unittest
    {
        import agora.crypto.Hash;

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

    /// PublicKey serialize & deserialize
    unittest
    {
        testSymmetry!PublicKey();
        testSymmetry(KeyPair.random().address);
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
        return agora.crypto.Schnorr.verify(this.data, signature, msg);
    }
}

/// A secret key.
/// Since we mostly expose seed and public key to the user,
/// this does not expose any Stellar serialization shenanigans.
public struct SecretKey
{
    /*private*/ Scalar data;
    alias data this;

    /// Construct an instance from binary data
    public this (const Scalar args) pure nothrow @safe @nogc
    {
        this.data = args;
    }

    /// Ditto
    public this (const ubyte[] args) pure nothrow @safe @nogc
    {
        this.data = args;
    }

    /***************************************************************************

        Print the private key

        By default, this function does not prints it, using `**SECRET** instead.
        Changing the mode to `Clear` makes it print the original value.
        This mode is intended for debugging.

        Params:
          sink = The sink to write the piecemeal string data to
          mode = The `PrintMode` to use for printing the content.
                 By default, the hidden value is printed.

    ***************************************************************************/

    public void toString (scope void delegate(const(char)[]) sink,
                          PrintMode mode = PrintMode.Obfuscated) const
    {
        final switch (mode)
        {
        case PrintMode.Obfuscated:
            formattedWrite(sink, "**SECRET**");
            break;

        case PrintMode.Clear:
            ubyte[VersionWidth + SecretKey.sizeof + ChecksumWidth] bin;
            bin[0] = VersionByte.Seed;
            bin[VersionWidth .. $ - ChecksumWidth] = this.data[];
            bin[$ - ChecksumWidth .. $] = checksum(bin[0 .. $ - ChecksumWidth]);
            formattedWrite(sink, "%s", Base32.encode(bin));
            break;
        }
    }

    /// Uses Stellar's representation instead of hex
    public string toString (PrintMode mode = PrintMode.Obfuscated) const
    {
        string result;
        this.toString((data) { result ~= data; }, mode);
        return result;
    }

    ///
    unittest
    {
        auto sd = SecretKey.fromString("SDQJFVGII75JPFVRDNFJ55L7DE4H7V3RHXLRKW55NDPBRBYUZLTW4TJS");

        assert(sd.toString(PrintMode.Obfuscated) == "**SECRET**");
        assert(sd.toString(PrintMode.Clear) ==
               "SDQJFVGII75JPFVRDNFJ55L7DE4H7V3RHXLRKW55NDPBRBYUZLTW4TJS");

        // Test default formatting behavior with writeln, log, etc...
        import std.format : phobos_format = format;
        import ocean.text.convert.Formatter : ocean_format = format;
        assert(phobos_format("%s", sd) == "**SECRET**");
        assert(ocean_format("{}", sd) == "**SECRET**");
    }

    /***************************************************************************

        Params:
            str = the string which should contain the seed

        Returns:
            a SecretKey from from Stellar's string representation

        Throws:
            an Exception if the input string is not well-formed

    ***************************************************************************/

    public static SecretKey fromString (scope const(char)[] str)
    {
        const bin = Base32.decode(str);
        enforce(bin.length == VersionWidth + SecretKey.sizeof + ChecksumWidth);
        enforce(bin[0] == VersionByte.Seed);
        enforce(validate(bin[0 .. $ - ChecksumWidth], bin[$ - ChecksumWidth .. $]));
        return SecretKey(typeof(this.data)(bin[VersionWidth .. $ - ChecksumWidth]));
    }

    ///
    unittest
    {
        immutable seed_str = `SBBUWIMSX5VL4KVFKY44GF6Q6R5LS2Z5B7CTAZBNCNPLS4UKFVDXC7TQ`;
        SecretKey seed = SecretKey.fromString(seed_str);
        assert(seed.toString(PrintMode.Clear) == seed_str);
        assertThrown(SecretKey.fromString(  // bad length
            "SBBUWIMSX5VL4KVFKY44GF6Q6R5LS2Z5B7CTAZBNCNPLS4UKFVDXC7T"));
        assertThrown(SecretKey.fromString(  // bad version byte
            "XBBUWIMSX5VL4KVFKY44GF6Q6R5LS2Z5B7CTAZBNCNPLS4UKFVDXC7TQ"));
        assertThrown(SecretKey.fromString(  // bad checksum
            "SBBUWIMSX5VL4KVFKY44GF6Q6R5LS2Z5B7CTAZBNCNPLS4UKFVDXC7TT"));
    }
}

// Test (de)serialization
unittest
{
    testSymmetry!SecretKey();
    testSymmetry(KeyPair.random().secret);
}

/// Discriminant for Stellar binary-encoded user-facing data
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

    KeyPair kp = KeyPair.fromSeed(SecretKey.fromString(seed));
    assert(kp.address.toString() == address);

    import std.string : representation;
    Signature sig = kp.secret.sign("Hello World".representation);
    assert(kp.address.verify(sig, "Hello World".representation));
}

// Test for converting from `Point` to `PublicKey`
unittest
{
    import agora.crypto.Schnorr;

    Pair pair = Pair.random();
    auto pubkey = PublicKey(pair.V[]);
    assert(pubkey[] == pair.V[]);
}
