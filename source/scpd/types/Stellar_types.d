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
alias uint256 = opaque_array!32;
alias uint512 = opaque_array!64;


alias Hash      = uint512;
alias NodeID    = uint256;
alias Signature = uint512;

unittest
{
    static import agora.crypto.Hash;
    static import agora.crypto.Key;
    static import agora.crypto.Schnorr;

    static assert(agora.crypto.Hash.Hash.sizeof == Hash.sizeof);
    static assert(agora.crypto.Key.PublicKey.sizeof == NodeID.sizeof);
    static assert(agora.crypto.Schnorr.Signature.sizeof == Signature.sizeof);
}
