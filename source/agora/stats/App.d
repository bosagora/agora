/*******************************************************************************

    Expose stats specific to the application, such as GC stats, or version.

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.stats.App;

import agora.stats.Stats;

/*******************************************************************************

    Expose non-dimensional data, such as version and build date

    Those labels are actually not following the usual time-series pattern,
    instead exposing data based on labels.

    See_Also:
    https://www.robustperception.io/exposing-the-software-version-to-prometheus

*******************************************************************************/

public immutable VersionFileName = "VERSION";

public struct ApplicationStatsLabels
{
    /// Version of Agora being run (git commit / tag)
    public string version_;
    /// Build date of this node
    public string build_timestamp;
    /// Compiler used for building
    public string frontend_version;
    /// Expose this node's public key, if any
    public string public_key;
}

/// Dummy stats with a single variable
public struct ApplicationStatsValue
{
    /// This is not actually needed, only the labels are
    public ulong agora_application_info = 1;
}

///
public alias ApplicationStats = Stats!(ApplicationStatsValue, ApplicationStatsLabels);
