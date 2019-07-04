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
import agora.common.Transaction;

import vibe.data.json;
import vibe.web.rest;
import vibe.http.common;

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

/*******************************************************************************

    Define the API a full node exposes to the world

    A full node:
    - Can connect to any node and request data about the blockchain & network
    - Accepts external connections and send them blockchain/network data
    - Store the data it receives on disk
    - Can catch up with the network when found lagging behind
    - Validates the data it receives
    - Receives, stores and forwards transactions (but drop them after a timeout)
    - Does not participate in consensus

   In essence, a full node provides much of the basic functionality needed
   to verify the blockchain while lacking the ability to create new blocks.

*******************************************************************************/
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

    public PublicConfig getPublicConfig ();

    /***************************************************************************

        Returns:
            Return true if the node has this transaction hash.

        API:
            GET /hasTransactionHash

    ***************************************************************************/

    @method(HTTPMethod.GET)
    public bool hasTransactionHash (Hash tx);

    /***************************************************************************

        API:
            PUT /transaction

    ***************************************************************************/

    public void putTransaction (Transaction tx);
}
