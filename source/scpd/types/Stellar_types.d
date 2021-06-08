/*******************************************************************************

    Porting of Stellar's `Stellar_types.h`, itself derived from
    `Stellar_types.x`

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
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

enum PublicKeyType : int32_t {
  PUBLIC_KEY_TYPE_ED25519 = 0,
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

alias Signature = opaque_array!64;
alias NodeID = PublicKey;
