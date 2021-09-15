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
public struct RegistryStats
{
    /// Number of records in the 'validators' zone
    public ulong registry_validator_record_count;
    /// Number of records in the 'flash' zone
    public ulong registry_flash_record_count;
}
