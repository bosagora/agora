/*******************************************************************************

    Extra bindings for scp for D usage, and other SCP-specific symbols

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.scp.Utils;

import scpd.scp.SCP;
import scpd.scp.SCPDriver;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types;

extern (C++):

/// SCP constructor wrapper
SCP* createSCP (SCPDriver driver, ref const(NodeID) nodeID, bool isValidator,
    ref const(SCPQuorumSet) qSetLocal);
