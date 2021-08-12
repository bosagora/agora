// -*- C++ -*-
// Defines the base types used in SCP / Agora. Replacement for `Stellar-types.h`

#pragma once

#include <xdrpp/types.h>

namespace stellar
{
    // Base types used in Stellar and Agora alike
    using uint32 = std::uint32_t;
    using int32  = std::int32_t;
    using uint64 = std::uint64_t;
    using int64  = std::int64_t;

    // Opaque value types (BitBlob!{32,64} on the Agora side, ABI compatible)
    using uint256 = xdr::opaque_array<32>;
    using uint512 = xdr::opaque_array<64>;

    // Logical types used by SCP / Agora
    using Hash =      uint512;
    using NodeID =    uint64;   // Currently index of `utxo` staked for validator
    using Signature = uint512; // `(R,s)`, could be reduced to `(s)`
}
