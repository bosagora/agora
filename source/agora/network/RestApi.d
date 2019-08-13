/*******************************************************************************

    Definitions of the nodes (full node & validator) REST APIs

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.RestApi;

import agora.node.API;
import agora.common.Data;

import vibe.web.rest;
import vibe.http.common;

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
public interface VibeRestAPI : API
{
// The REST generator requires @safe methods
@safe:
    /***************************************************************************

        Returns:
            Return true if the node has this transaction hash.

        API:
            GET /hasTransactionHash

    ***************************************************************************/

    @method(HTTPMethod.GET)
    override public bool hasTransactionHash (Hash tx);
}
