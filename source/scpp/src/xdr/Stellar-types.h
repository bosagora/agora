// -*- C++ -*-
// Automatically generated from xdr/Stellar-types.x.
// DO NOT EDIT or your changes may be overwritten

#ifndef __XDR_XDR_STELLAR_TYPES_H_INCLUDED__
#define __XDR_XDR_STELLAR_TYPES_H_INCLUDED__ 1

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

#endif // !__XDR_XDR_STELLAR_TYPES_H_INCLUDED__
