/*******************************************************************************

    Stats corresponding to validators

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.stats.Validator;

import agora.stats.Stats;

///
public struct ValidatorCountStatsLabel
{
}

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
public alias ValidatorCountStats = Stats!(ValidatorCountStatsValue, ValidatorCountStatsLabel);

///
public alias ValidatorPreimagesStats = Stats!(ValidatorPreimagesStatsValue, ValidatorPreimagesStatsLabel);
