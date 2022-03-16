/*******************************************************************************

    Stats corresponding to slots

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.stats.Slot;

import agora.stats.Stats;

/// Statistics of a consensus slot
public struct SlotStatsValue
{
    /// Number of unique values seen
    public ulong num_values;

    /// Time it takes to start ballot protocol
    public long time_to_ballot;

    /// Time to externalization
    public long time_to_ext;

    /// Time to reach signature majority
    public long time_to_sig_majority;
}

///
public struct SlotStatsLabel
{
    public string slot_idx;
}

///
public alias SlotStats = Stats!(SlotStatsValue, SlotStatsLabel);
