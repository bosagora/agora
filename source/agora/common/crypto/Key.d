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
import agora.common.crypto.ECC;
import agora.common.Types;
import agora.common.Serializer;

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

    /// Seed
    public const Seed seed;

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

// Test (de)serialization
unittest
{
    testSymmetry!KeyPair();
    testSymmetry(KeyPair.random());
}

/// Represent a public key / address
public struct PublicKey
{
    /// Alias to the BitBlob type
    private alias DataType = BitBlob!(crypto_sign_ed25519_PUBLICKEYBYTES * 8);

    /*private*/ DataType data;
    alias data this;

    /// Construct an instance from binary data
    public this (const DataType args) pure nothrow @safe @nogc
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
        enforce(bin.length == 1 + PublicKey.Width + 2);
        enforce(bin[0] == VersionByte.AccountID);
        enforce(validate(bin[0 .. $ - 2], bin[$ - 2 .. $]));
        return PublicKey(typeof(this.data)(bin[1 .. $ - 2]));
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
    /// Alias to the BitBlob type
    private alias DataType = BitBlob!(crypto_sign_ed25519_SECRETKEYBYTES * 8);

    /*private*/ DataType data;
    alias data this;

    /// Construct an instance from binary data
    public this (const DataType args) pure nothrow @safe @nogc
    {
        this.data = args;
    }

    /// Ditto
    public this (const ubyte[] args) pure nothrow @safe @nogc
    {
        this.data = args;
    }

    /***************************************************************************

        Print the secret key

        By default, this function prints the hidden version of the secret key.
        Changing the mode to `Clear` makes it print the original value.
        This mode is intended for debugging.

        Params:
          sink = The sink to write the piecemeal string data to
          mode = The `PrintMode` to use for printing the content.
                 By default, the hidden value is printed.

    ***************************************************************************/

    public void toString (scope void delegate(const(char)[]) @safe sink,
                          PrintMode mode = PrintMode.Obfuscated) const @safe
    {
        final switch (mode)
        {
        case PrintMode.Obfuscated:
            formattedWrite(sink, "**SECRET**");
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
        auto sk = KeyPair.fromSeed(Seed.fromString(
                  "SDQJFVGII75JPFVRDNFJ55L7DE4H7V3RHXLRKW55NDPBRBYUZLTW4TJS"))
                  .secret;

        assert(sk.toString(PrintMode.Obfuscated) == "**SECRET**");
        assert(sk.toString(PrintMode.Clear) ==
               "0xbca6b465149f8d3f4bc1794c246b2df64dcab0e65beb1862c5a0843d3e06e2f5" ~
               "6ee7ca148718de68bd5b15d73d71d77f38197ff59e4a1bb19697fa47c8d492e0");

        // Test default formatting behavior with writeln, log, etc...
        import std.format : phobos_format = format;
        import ocean.text.convert.Formatter : ocean_format = format;
        assert(phobos_format("%s", sk) == "**SECRET**");
        assert(ocean_format("{}", sk) == "**SECRET**");
    }

    /***************************************************************************

        Signs a message with this private key

        Params:
          msg = The message to sign

        Returns:
          The signature of `msg` using `this`

    ***************************************************************************/

    public Signature sign (scope const(ubyte)[] msg) const nothrow @nogc
    {
        Signature result;
        // The second argument, `siglen_p`, a pointer to the length of the
        // signature, is always set to `64U` and supports `null`
        if (crypto_sign_ed25519_detached(result[].ptr, null, msg.ptr, msg.length, this.data[].ptr) != 0)
            assert(0);
        return result;
    }
}


// Test (de)serialization
unittest
{
    testSymmetry!SecretKey();
    testSymmetry(KeyPair.random().secret);
}

/// A Stellar seed
public struct Seed
{
    /// Alias to the BitBlob type
    private alias DataType = BitBlob!(crypto_sign_ed25519_SEEDBYTES * 8);

    /*private*/ DataType data;
    alias data this;

    /// Construct an instance from binary data
    public this (const DataType args) pure nothrow @safe @nogc
    {
        this.data = args;
    }

    /// Ditto
    public this (const ubyte[] args) pure nothrow @safe @nogc
    {
        this.data = args;
    }

    /***************************************************************************

        Print the seed

        By default, this function prints the hidden version of the seed.
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
            formattedWrite(sink, "**SEED**");
            break;

        case PrintMode.Clear:
            ubyte[1 + Seed.Width + 2] bin;
            bin[0] = VersionByte.Seed;
            bin[1 .. $ - 2] = this.data[];
            bin[$ - 2 .. $] = checksum(bin[0 .. $ - 2]);
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
        auto sd = Seed.fromString("SDQJFVGII75JPFVRDNFJ55L7DE4H7V3RHXLRKW55NDPBRBYUZLTW4TJS");

        assert(sd.toString(PrintMode.Obfuscated) == "**SEED**");
        assert(sd.toString(PrintMode.Clear) ==
               "SDQJFVGII75JPFVRDNFJ55L7DE4H7V3RHXLRKW55NDPBRBYUZLTW4TJS");

        // Test default formatting behavior with writeln, log, etc...
        import std.format : phobos_format = format;
        import ocean.text.convert.Formatter : ocean_format = format;
        assert(phobos_format("%s", sd) == "**SEED**");
        assert(ocean_format("{}", sd) == "**SEED**");
    }

    /***************************************************************************

        Params:
            str = the string which should contain the seed

        Returns:
            a Seed from from Stellar's string representation

        Throws:
            an Exception if the input string is not well-formed

    ***************************************************************************/

    public static Seed fromString (scope const(char)[] str)
    {
        const bin = Base32.decode(str);
        enforce(bin.length == 1 + Seed.Width + 2);
        enforce(bin[0] == VersionByte.Seed);
        enforce(validate(bin[0 .. $ - 2], bin[$ - 2 .. $]));
        return Seed(typeof(this.data)(bin[1 .. $ - 2]));
    }

    ///
    unittest
    {
        immutable seed_str = `SBBUWIMSX5VL4KVFKY44GF6Q6R5LS2Z5B7CTAZBNCNPLS4UKFVDXC7TQ`;
        Seed seed = Seed.fromString(seed_str);
        assert(seed.toString(PrintMode.Clear) == seed_str);
        assertThrown(Seed.fromString(  // bad length
            "SBBUWIMSX5VL4KVFKY44GF6Q6R5LS2Z5B7CTAZBNCNPLS4UKFVDXC7T"));
        assertThrown(Seed.fromString(  // bad version byte
            "XBBUWIMSX5VL4KVFKY44GF6Q6R5LS2Z5B7CTAZBNCNPLS4UKFVDXC7TQ"));
        assertThrown(Seed.fromString(  // bad checksum
            "SBBUWIMSX5VL4KVFKY44GF6Q6R5LS2Z5B7CTAZBNCNPLS4UKFVDXC7TT"));
    }
}

// Test (de)serialization
unittest
{
    testSymmetry!Seed();
    testSymmetry(KeyPair.random().seed);
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

    KeyPair kp = KeyPair.fromSeed(Seed.fromString(seed));
    assert(kp.address.toString() == address);

    import std.string : representation;
    Signature sig = kp.secret.sign("Hello World".representation);
    assert(kp.address.verify(sig, "Hello World".representation));
}

/*******************************************************************************

    Util to convert SecretKey(Ed25519) to Scalar(X25519)
    The secretKeyToCurveScalar() function converts an SecretKey(Ed25519)
    to a Scalar(X25519) secret key and stores it into x25519_sk.

    Params:
      secret = Secretkey in Ed25519 format

    Returns:
      Converted X25519 secret key

*******************************************************************************/

public static Scalar secretKeyToCurveScalar (SecretKey secret) nothrow @nogc
{
    Scalar x25519_sk;
    if (crypto_sign_ed25519_sk_to_curve25519(x25519_sk.data[].ptr, secret[].ptr) != 0)
        assert(0);
    return x25519_sk;
}

// Test signing using Stellar seed
unittest
{
    import agora.common.crypto.Schnorr;

    KeyPair kp = KeyPair.fromSeed(
        Seed.fromString(
            "SCT4KKJNYLTQO4TVDPVJQZEONTVVW66YLRWAINWI3FZDY7U4JS4JJEI4"));

    Scalar scalar = secretKeyToCurveScalar(kp.secret);
    assert(scalar ==
        Scalar(`0x44245dd23bd7453bf5fe07ec27a29be3dfe8e18d35bba28c7b222b71a4802db8`));

    Pair pair = Pair.fromScalar(scalar);

    assert(pair.V.data == kp.address.data);
    Signature enroll_sig = sign(pair, "BOSAGORA");

    Point point_Address = Point(kp.address);
    assert(verify(point_Address, enroll_sig, "BOSAGORA"));
}

// Test for converting from `Point` to `PublicKey`
unittest
{
    import agora.common.crypto.Schnorr;

    Pair pair = Pair.random();
    auto pubkey = PublicKey(pair.V[]);
    assert(pubkey.data == pair.V.data);
}
