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

import scpd.types.XDRBase;

import geod24.bitblob;

import core.stdc.config;
import core.stdc.inttypes;

extern(C++, `stellar`):

// While the following two declaration were originally done
// using opaque_array, it is much easier to use BitBlob.
// Since BitBlob has the same memory layout,
// we can just swap it, and get a much more D-friendly interface.

// todo: replace with BitBlob and use pragma(mangle) to force it to link
alias Hash = opaque_array!64;
alias uint256 = opaque_array!32;
alias uint512 = opaque_array!64;

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

/// Modified to suits scpd's needs
/// Note: should only be used within this package
package(scpd)
struct PublicKey {
    extern(D) this(uint256 key) @safe pure nothrow @nogc
    {
        this.ed25519_ = key;
    }

    extern(D) this(typeof(this.tupleof) args) @safe pure nothrow @nogc
    {
        this.tupleof = args;
    }

    int32_t type_;
    uint256 ed25519_;
    alias ed25519_ this;
}

alias Signature = opaque_vec!64;
alias SignatureHint = opaque_array!4;
alias NodeID = PublicKey;
