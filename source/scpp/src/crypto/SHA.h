#pragma once

// Copyright 2014 Stellar Development Foundation and contributors. Licensed
// under the Apache License, Version 2.0. See the COPYING file at the root
// of this distribution or at http://www.apache.org/licenses/LICENSE-2.0

#include "crypto/ByteSlice.h"
#include "xdr/Stellar-types.h"
#include <memory>

namespace stellar
{

// Plain SHA512
uint512 sha512(ByteSlice const& bin);

// SHA512 in incremental mode, for large inputs.
class SHA512
{
  public:
    static std::unique_ptr<SHA512> create();
    virtual ~SHA512(){};
    virtual void reset() = 0;
    virtual void add(ByteSlice const& bin) = 0;
    virtual uint512 finish() = 0;
};

// HMAC-SHA256 (keyed)
HmacSha256Mac hmacSha256(HmacSha256Key const& key, ByteSlice const& bin);

// Use this rather than HMAC-output ==, to avoid timing leaks.
bool hmacSha256Verify(HmacSha256Mac const& hmac, HmacSha256Key const& key,
                      ByteSlice const& bin);

// Unsalted HKDF-extract(bytes) == HMAC(<zero>,bytes)
HmacSha256Key hkdfExtract(ByteSlice const& bin);

// Single-step HKDF-expand(key,bytes) == HMAC(key,bytes|0x1)
HmacSha256Key hkdfExpand(HmacSha256Key const& key, ByteSlice const& bin);
}
