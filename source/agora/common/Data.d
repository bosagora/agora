/*******************************************************************************

    Defines common data types used by the node

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Data;

import geod24.bitblob;


/// An array of const characters
public alias cstring = const(char)[];

/// 512 bits hash type computed via `BLAKE2b`
public alias Hash = BitBlob!512;

/// A network address
public alias Address = string;

/// The type of a signature
public alias Signature = BitBlob!512;

unittest
{
    // Check that our type match libsodium's definition
    import libsodium;

    static assert(Signature.sizeof == crypto_sign_ed25519_BYTES);
    static assert(Hash.sizeof == crypto_generichash_BYTES_MAX);
}
