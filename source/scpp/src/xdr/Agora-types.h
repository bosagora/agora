// -*- C++ -*-
// Defines the base types used in SCP / Agora. Replacement for `Stellar-types.h`

#pragma once

#include <xdrpp/types.h>

namespace stellar {

using Hash = xdr::opaque_array<64>;
using uint256 = xdr::opaque_array<32>;
using uint512 = xdr::opaque_array<64>;
using uint32 = std::uint32_t;
using int32 = std::int32_t;
using uint64 = std::uint64_t;
using int64 = std::int64_t;

using PublicKey = uint256;
using Signature = xdr::opaque_array<64>;
}
