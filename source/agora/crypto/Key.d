/*******************************************************************************

    Holds primitive types for key operations

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.crypto.Key;

import agora.common.Types;
import agora.crypto.Bech32;
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
    Signature sign2 = kp.secret.sign("Hello".representation);
    assert(!kp.address.verify(sign2, "Hello World".representation));
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
        assert(seed.data.isValid(), "SecretKey should always be valid Scalar!");
        return KeyPair(PublicKey(seed.toPoint()), SecretKey(seed));
    }

    ///
    unittest
    {
        immutable seedStr = `SDV3GLVZ6W7R7UFB2EMMY4BBFJWNCQB5FTCXUMD5ZCFTDEVZZ3RQ2BZI`;
        KeyPair kp = KeyPair.fromSeed(SecretKey.fromString(seedStr));
        assert(kp.secret.toString(PrintMode.Clear) == seedStr,
            kp.secret.toString(PrintMode.Clear));
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
private immutable char[3] HumanReadablePart = "boa";

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
        ubyte[VersionWidth + PublicKey.sizeof] bin;
        bin[0] = VersionByte.AccountID;
        bin[VersionWidth .. $] = this.data[];
        return encodeBech32(HumanReadablePart, bin, Encoding.Bech32m, true).
            assumeUnique;
    }

    /// Make sure the sink overload of BitBlob is not picked
    public void toString (scope void delegate(const(char)[]) sink) const @trusted
    {
        ubyte[VersionWidth + PublicKey.sizeof] bin;
        bin[0] = VersionByte.AccountID;
        bin[VersionWidth .. $] = this.data[];
        string encoded = encodeBech32(HumanReadablePart, bin,
            Encoding.Bech32m, true).assumeUnique;
        sink(encoded);
    }

    ///
    unittest
    {
        immutable address = `boa1xrra39xpg5q9zwhsq6u7pw508z2let6dj8r5lr4q0d0nff240fvd27yme3h`;
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
        auto dec = decodeBech32(str, true);
        enforce(dec.hrp == HumanReadablePart);
        enforce(dec.data.length == VersionWidth + PublicKey.sizeof);
        enforce(dec.data[0] == VersionByte.AccountID);
        return PublicKey(typeof(this.data)(dec.data[VersionWidth .. $]));
    }

    ///
    unittest
    {
        immutable address = `boa1xrv266cegdthdc87uche9zvj8842shz3sdyvw0qecpgeykyv4ynssuz4lg0`;
        PublicKey pubkey = PublicKey.fromString(address);
        assert(pubkey.toString() == address);
        assertThrown(PublicKey.fromString(  // bad length
            "boa1xrv266cegdthdc87uche9zvj8842shz3sdyvw0qecpgeykyv4ynssuz4lg"));
        assertThrown(PublicKey.fromString(  // bad version byte
            "boa1crv266cegdthdc87uche9zvj8842shz3sdyvw0qecpgeykyv4ynssuz4lg0"));
    }

    ///
    unittest
    {
        import agora.crypto.Hash;

        immutable address =
            `boa1xrra39xpg5q9zwhsq6u7pw508z2let6dj8r5lr4q0d0nff240fvd27yme3h`;
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

    public bool verify (T) (Signature signature, in T msg)
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
    immutable address = `boa1xrdwry6fpk7a57k4gwyj3mwnf59w808nygtuxsgdrpmv4p7ua2hqx78z5en`;
    immutable seed    = `SDV3GLVZ6W7R7UFB2EMMY4BBFJWNCQB5FTCXUMD5ZCFTDEVZZ3RQ2BZI`;

    KeyPair kp = KeyPair.fromSeed(SecretKey.fromString(seed));
    assert(kp.address.toString() == address, kp.address.toString());

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
