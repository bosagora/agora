#pragma once

// Copyright 2014 Stellar Development Foundation and contributors. Licensed
// under the Apache License, Version 2.0. See the COPYING file at the root
// of this distribution or at http://www.apache.org/licenses/LICENSE-2.0

#include "crypto/ByteSlice.h"
#include "xdr/Stellar-types.h"
#include "scp/SCP.h"
#include <memory>

namespace stellar
{
/*******************************************************************************

    Prototypes of the hashing routines which should be implemented
    by the client code of SCP.

    Params:
        qset = the SCP quorum set to hash

    Returns:
        the 64-byte hash

*******************************************************************************/

uint512 getHashOf (SCPQuorumSet const&);

/// Ditto
uint512 getHashOf (Value const&);

/// Ditto
uint512 getHashOf (uint64_t, Value const&, uint32_t, int32_t, NodeID const&);

/// Ditto
uint512 getHashOf (uint64_t, Value const&, uint32_t, int32_t, Value const&);
}
