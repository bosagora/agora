/*******************************************************************************

    Bindings for scp/QuorumSetUtils.h

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.scp.QuorumSetUtils;

import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types;

extern(C++, `stellar`):

// level = 0 when there is no nesting.
enum MAXIMUM_QUORUM_NESTING_LEVEL = 4;

bool isQuorumSetSane(ref const SCPQuorumSet qSet, bool extraChecks,
    ref const(char)* reason);

// normalize the quorum set, optionally removing idToRemove
void normalizeQSet(ref SCPQuorumSet qSet, const(NodeID)* idToRemove = null)
    nothrow @nogc;
