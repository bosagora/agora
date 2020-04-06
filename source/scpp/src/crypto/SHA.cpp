// Copyright 2014 Stellar Development Foundation and contributors. Licensed
// under the Apache License, Version 2.0. See the COPYING file at the root
// of this distribution or at http://www.apache.org/licenses/LICENSE-2.0

#include "crypto/SHA.h"
#include "crypto/ByteSlice.h"
#include "util/NonCopyable.h"
#include <sodium.h>

namespace stellar
{

// Plain SHA512
uint512
sha512(ByteSlice const& bin)
{
    uint512 out;
    if (crypto_hash_sha512(out.data(), bin.data(), bin.size()) != 0)
    {
        throw std::runtime_error("error from crypto_hash_sha512");
    }
    return out;
}

class SHA512Impl : public SHA512, NonCopyable
{
    crypto_hash_sha512_state mState;
    bool mFinished;

  public:
    SHA512Impl();
    void reset() override;
    void add(ByteSlice const& bin) override;
    uint512 finish() override;
};

std::unique_ptr<SHA512>
SHA512::create()
{
    return std::make_unique<SHA512Impl>();
}

SHA512Impl::SHA512Impl() : mFinished(false)
{
    reset();
}

void
SHA512Impl::reset()
{
    if (crypto_hash_sha512_init(&mState) != 0)
    {
        throw std::runtime_error("error from crypto_hash_sha512_init");
    }
    mFinished = false;
}

void
SHA512Impl::add(ByteSlice const& bin)
{
    if (mFinished)
    {
        throw std::runtime_error("adding bytes to finished SHA512");
    }
    if (crypto_hash_sha512_update(&mState, bin.data(), bin.size()) != 0)
    {
        throw std::runtime_error("error from crypto_hash_sha512_update");
    }
}

uint512
SHA512Impl::finish()
{
    uint512 out;
    assert(out.size() == crypto_hash_sha512_BYTES);
    if (mFinished)
    {
        throw std::runtime_error("finishing already-finished SHA512");
    }
    if (crypto_hash_sha512_final(&mState, out.data()) != 0)
    {
        throw std::runtime_error("error from crypto_hash_sha512_final");
    }
    return out;
}

// HMAC-SHA256
HmacSha256Mac
hmacSha256(HmacSha256Key const& key, ByteSlice const& bin)
{
    HmacSha256Mac out;
    if (crypto_auth_hmacsha256(out.mac.data(), bin.data(), bin.size(),
                               key.key.data()) != 0)
    {
        throw std::runtime_error("error from crypto_auto_hmacsha256");
    }
    return out;
}

bool
hmacSha256Verify(HmacSha256Mac const& hmac, HmacSha256Key const& key,
                 ByteSlice const& bin)
{
    return 0 == crypto_auth_hmacsha256_verify(hmac.mac.data(), bin.data(),
                                              bin.size(), key.key.data());
}

// Unsalted HKDF-extract(bytes) == HMAC(<zero>,bytes)
HmacSha256Key
hkdfExtract(ByteSlice const& bin)
{
    HmacSha256Key zerosalt;
    auto mac = hmacSha256(zerosalt, bin);
    HmacSha256Key key;
    key.key = mac.mac;
    return key;
}

// Single-step HKDF-expand(key,bytes) == HMAC(key,bytes|0x1)
HmacSha256Key
hkdfExpand(HmacSha256Key const& key, ByteSlice const& bin)
{
    std::vector<uint8_t> bytes(bin.begin(), bin.end());
    bytes.push_back(1);
    auto mac = hmacSha256(key, bytes);
    HmacSha256Key out;
    out.key = mac.mac;
    return out;
}
}
