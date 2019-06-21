/*******************************************************************************

    Contains the REST API interface.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.API;

import agora.common.crypto.Key;
import agora.common.Data;
import agora.common.Set;

import vibe.data.json;
import vibe.web.rest;

/// The network state (completed when sufficient validators are connected to)
enum NetworkState
{
    Incomplete,
    Complete
}

/// Contains the network info (state & addresses)
public struct NetworkInfo
{
    /// Whether the node knows about the IPs of all its quorum set nodes
    public NetworkState state;

    /// Partial or full view of the addresses of the node's quorum (based on is_complete)
    public Set!string addresses;
}

/// Contains the public part of node's configuration (e.g. lacking the private keys)
public struct PublicConfig
{
    /// whether this is a validator node1
    public bool is_validator;
}

/// API
@path("/")
public interface API
{
// The REST generator requires @safe methods
@safe:

    /***************************************************************************

        Returns:
            The public key of this node

        API:
            GET /public_key

    ***************************************************************************/

    public PublicKey getPublicKey ();

    /***************************************************************************

        Returns:
            The peer network of this node

        API:
            GET /network_info

    ***************************************************************************/

    public NetworkInfo getNetworkInfo ();

    /***************************************************************************

        Returns:
            The publicly exposed configuration of this node.
            (e.g.: is it a validator, etc)

        API:
            GET /public_config

    ***************************************************************************/

    public PublicConfig getPublicConfig();


    /***************************************************************************

        API:
            PUT /hash_message

    ***************************************************************************/

    public void setHashMessage(Hash msg);
}
