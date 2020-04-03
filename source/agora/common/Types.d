/*******************************************************************************

    Defines common types used by Agora

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Types;

import agora.common.crypto.Key;

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

/// The definition of a Quorum
public struct QuorumConfig
{
    /// Threshold of this quorum set
    public size_t threshold = 1;

    /// List of nodes in this quorum
    public PublicKey[] nodes;

    /// List of any sub-quorums
    public QuorumConfig[] quorums;
}
