/*******************************************************************************

    Defines common types used by Agora

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Types;

import geod24.bitblob;


/// An array of const characters
public alias cstring = const(char)[];

/// 512 bits hash type computed via `BLAKE2b`
public alias Hash = BitBlob!512;

/// A network address
public alias Address = string;

/// The type of a signature
public alias Signature = BitBlob!512;

/// Whether integers are serialized in variable-length form
public enum CompactMode : bool
{
    No,
    Yes
}

unittest
{
    // Check that our type match libsodium's definition
    import libsodium;

    static assert(Signature.sizeof == crypto_sign_ed25519_BYTES);
    static assert(Hash.sizeof == crypto_generichash_BYTES_MAX);
}

version(unittest):

/*******************************************************************************

    Test the symmetry of a type

    The provided type will be serialized, then deserialized, and tested for
    equality. If a mismatch happens, a verbose error message will be issued.

    If no argument is provided, the `init` value will be tested.

    This function also tests that a `struct` containing `T`, an array of `T`,
    and a struct containing an array of `T` can be properly serialized.

*******************************************************************************/

public void testSymmetry (T) (auto ref T value = T.init)
{
    testSymmetryImpl(value, T.stringof);

    T[] arr = [ value, T.init, value, T.init ];
    testSymmetryImpl(arr, "array of " ~ T.stringof);

    static struct Container { T val; }
    testSymmetryImpl(Container(value), "struct containing a " ~ T.stringof);

    static struct ContainerArray { T[] val; }
    testSymmetryImpl(ContainerArray(arr), "struct containing an array of " ~ T.stringof);
}

private void testSymmetryImpl (T) (const auto ref T value, string typename)
{
    import agora.common.Serializer;
    import std.format;
    import std.stdio;

    ubyte[] serialized;
    {
        scope(failure) stderr.writeln("Serialization of ", typename, " failed!");
        serialized = value.serializeFull();
    }
    assert(serialized.length, T.stringof ~ " did not serialize to anything?");
    {
        bool testing = false;
        scope(failure)
            if (!testing)
            {
                stderr.writeln("Deserialization of ", typename, " failed. Binary data:");
                stderr.writeln(serialized);
            }
        const deserialized = serialized.deserializeFull!(T)();
        testing = true;
        assert(deserialized == value,
               format("Serialization mismatch for %s! Expected:\n%s\n\ngot:\n%s\n\nBinary data:\n%s",
                      typename, value, deserialized, serialized));
    }
}
