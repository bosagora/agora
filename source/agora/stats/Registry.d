/*******************************************************************************

    Stats corresponding to validators

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.stats.Registry;

import agora.stats.Stats;

///
public struct RegistryStatsValue
{
    public ulong registry_record_count;
}

///
public alias RegistryStats = Stats!(RegistryStatsValue, NoLabel);
