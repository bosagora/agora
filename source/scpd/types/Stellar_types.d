/*******************************************************************************

    Porting of Stellar's `Stellar_types.h`, itself derived from
    `Stellar_types.x`

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.types.Stellar_types;

import core.stdc.config;
import core.stdc.inttypes;

import scpd.types.XDRBase;

import geod24.bitblob;

enum CryptoKeyType : int32_t {
  KEY_TYPE_ED25519 = 0,
  KEY_TYPE_PRE_AUTH_TX = 1,
  KEY_TYPE_HASH_X = 2,
}

enum PublicKeyType : int32_t {
  PUBLIC_KEY_TYPE_ED25519 = CryptoKeyType.KEY_TYPE_ED25519,
}

enum SignerKeyType : int32_t {
  SIGNER_KEY_TYPE_ED25519 = CryptoKeyType.KEY_TYPE_ED25519,
  SIGNER_KEY_TYPE_PRE_AUTH_TX = CryptoKeyType.KEY_TYPE_PRE_AUTH_TX,
  SIGNER_KEY_TYPE_HASH_X = CryptoKeyType.KEY_TYPE_HASH_X,
}

extern(C++, `stellar`):

// While the following two declaration were originally done
// using opaque_array, it is much easier to use BitBlob.
// Since BitBlob has the same memory layout,
// we can just swap it, and get a much more D-friendly interface.

alias Hash = opaque_array!32;
/// alias uint256 = opaque_array!32;
alias uint256 = Hash;

/// Modified to suits scpd's needs
/// Note: should only be used within this package
package(scpd)
struct PublicKey {
    extern(D) this(const(char)[] str) @safe pure nothrow @nogc
    {
        this.ed25519_ = Hash(str);
    }

    extern(D) this(Hash key) @safe pure nothrow @nogc
    {
        this.ed25519_ = key;
    }

    int32_t type_;
    Hash ed25519_;
    alias ed25519_ this;
}

alias Signature = opaque_vec!64;
alias SignatureHint = opaque_array!4;
alias NodeID = PublicKey;
