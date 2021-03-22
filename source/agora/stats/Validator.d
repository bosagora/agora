/*******************************************************************************

    Stats corresponding to validators

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.stats.Validator;

import agora.stats.Stats;

///
///
public struct ValidatorCountStatsValue
{
    public ulong agora_validators_gauge;
}

///
public struct ValidatorPreimagesStatsLabel
{
    public string key;
}

///
public struct ValidatorPreimagesStatsValue
{
    public ulong agora_preimages_gauge;
}

///
public alias ValidatorCountStats = Stats!(ValidatorCountStatsValue, NoLabel);

///
public alias ValidatorPreimagesStats = Stats!(ValidatorPreimagesStatsValue, ValidatorPreimagesStatsLabel);
