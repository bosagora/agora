/*******************************************************************************

    Contains the routing path encoding structure.

    An origin node which wishes to make a payment to a destination node needs
    to find a route to the destination node. Once it does, it needs to
    be able to encode this in a single structure so it may forward it to the
    first hop in the payment route, which in turn forwards it to the next hop,
    and so on..

    Consider payment of A to D via A -> B -> C -> D:

    The origin node must encode the payment route for each hop (B, C, D).
    It must do it in a way that each hop node only knows where to forward
    the packet to next, but may not know the entire route path.

    TODO: Encryption not yet implemented
    NOTE: See https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md
    NOTE: See https://medium.com/softblocks/lightning-network-in-depth-part-2-htlc-and-payment-routing-db46aea445a8

    Copyright:
        Copyright (c) 2021 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.Route;

import agora.common.Amount;
import agora.common.crypto.ECC;
import agora.common.Hash;

import libsodium.randombytes;

import core.stdc.time;

public struct Hop
{
    Point pub_key;
    Hash chan_id;
    Amount fee;
}
