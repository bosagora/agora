/*******************************************************************************

    Definitions of the nodes (full node & validator) APIs

    Two kinds of nodes exist: full nodes, and validators.
    A full node follows the network as a passive actor, but does validation
    on the data it receives, and can forward that data to other nodes.
    A validator is a full node which participates in consensus.

    An `API` is used as an interface to communicate with a node.
    As such, a class that implements `API` exists (in `agora.node.Node`),
    and in order to communicate with other nodes, it holds an `API` for
    each of those nodes.

    `API` are defined as D interfaces, following what is done in Vibe.d.
    Those interfaces can be read by a generator to build a client or a server.
    One such generator is Vibe.d's `vibe.web.rest`. `RestInterfaceClient`
    allows to query a REST API, while `registerRestInterface` will route queries
    and deserialize parameters according to the interface's definition.

    Another generator which we use for unittests is "LocalRest".
    It allows to start a node per thread, and uses `std.concurrency`
    to do message passing between nodes.

    Lastly, we plan to implement a generator which works directly on TCP/IP.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.API;

import agora.common.crypto.Key;
import agora.common.Block;
import agora.common.Data;
import agora.common.Set;
import agora.consensus.data.Transaction;

import vibe.data.json;
import vibe.web.rest;
import vibe.http.common;

/// The network state (completed when sufficient validators are connected to)
public enum NetworkState
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

    /***************************************************************************

        Returns:
            the highest block height in this node's ledger

    ***************************************************************************/

    public ulong getBlockHeight ();


    /***************************************************************************

        Get the array of blocks starting from the provided block height.

        The block at `block_height` is included in the array.
        Note that a node is free to return less blocks than asked for.
        However it must never return more blocks than asked for.

        API:
            GET /blocks_from

        Params:
            block_height = the starting block height to begin retrieval from
            max_blocks   = the maximum blocks to return at once

        Returns:
            the array of blocks starting from block_height,
            up to `max_blocks`

    ***************************************************************************/

    public const(Block)[] getBlocksFrom (ulong block_height, size_t max_blocks);


    /***************************************************************************

        Get the array of hashes which form the merkle path

        API:
            GET /merkle_path

        Params:
            block_height = Height of the block that contains the transaction hash
            hash         = transaction hash

        Returns:
            the array of hashes which form the merkle path

    ***************************************************************************/

    public Hash[] getMerklePath (ulong block_height, Hash hash);
}
