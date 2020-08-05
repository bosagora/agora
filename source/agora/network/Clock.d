/*******************************************************************************

    Contains a Clock implementation.

    Lives in this package as it will later be enhanced with
    network-synchronization support.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.Clock;

import agora.utils.Log;

import core.stdc.time;

mixin AddLogger!();

/// The current implementation uses NTP
public class Clock
{
    /***************************************************************************

        Returns:
            the current local clock time

    ***************************************************************************/

    public time_t time () @safe nothrow
    {
        return .time(null);
    }
}
