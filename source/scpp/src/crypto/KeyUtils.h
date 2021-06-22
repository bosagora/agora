#pragma once

// Copyright 2016 Stellar Development Foundation and contributors. Licensed
// under the Apache License, Version 2.0. See the COPYING file at the root
// of this distribution or at http://www.apache.org/licenses/LICENSE-2.0

#include "crypto/StrKey.h"
#include "util/SecretValue.h"
#include "xdr/Stellar-types.h"

#include <sodium.h>

#include <string>

namespace stellar
{

// signer key utility functions
namespace KeyUtils
{

template <typename T>
std::string toStrKey(T const& key)
{
    return strKey::toStrKey(0, key).value;
}

template <typename T>
std::string toShortString(T const& key)
{
    return toStrKey(key).substr(0, 5);
}
}
}
