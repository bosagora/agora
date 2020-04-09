/*******************************************************************************

    Contains definition of hashing routines which SCP uses.
    These just call the hashing routines from agora.common.Hash

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.SCPHash;

import agora.common.Hash;

import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types;
import scpd.types.Utils;

import core.stdc.inttypes;

extern(C++, `stellar`):

/*******************************************************************************

    Implementation of the hashing routines as used by SCP

    Params:
        qset = the SCP quorum set to hash

    Returns:
        the 64-byte hash

*******************************************************************************/

public uint512 getHashOf (ref const(SCPQuorumSet) qset)
{
    return uint512(hashFull(qset));
}

/// Ditto
public uint512 getHashOf (ref const(Value) value)
{
    return uint512(hashFull(value));
}

/// Ditto
public uint512 getHashOf (uint64_t slot_idx, ref const(Value) prev, uint32_t hash,
    int32_t round_num, ref const(NodeID) node_id)
{
    return uint512(hashMulti(slot_idx, prev[], hash, round_num, node_id));
}

/// Ditto
public uint512 getHashOf (uint64_t slot_idx, ref const(Value) prev, uint32_t hash,
    int32_t round_num, ref const(Value) value)
{
    return uint512(hashMulti(slot_idx, prev[], hash, round_num, value[]));
}
