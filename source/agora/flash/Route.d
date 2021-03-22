/*******************************************************************************

    Contains the routing path encoding structure.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.Route;

import agora.common.Amount;
import agora.crypto.ECC;
import agora.crypto.Hash;

import libsodium.randombytes;

import core.stdc.time;

/// Ditto
public struct Hop
{
    /// Public key of the destination node
    public Point pub_key;

    /// The channel ID to add the HTLC to
    public Hash chan_id;

    /// The fee of this channel (todo: should be node-specific, not chan-specific)
    public Amount fee;
}
