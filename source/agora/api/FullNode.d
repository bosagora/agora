/*******************************************************************************

    Definitions of the full node API

    See agora.node.api.Validator for a full explanation on this API.

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.api.FullNode;

import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.common.Types;
import agora.common.Set;
import agora.common.Serializer;
import agora.consensus.data.Transaction;

import vibe.web.rest;
import vibe.http.common;

/// The network state (completed when sufficient validators are connected to)
public enum NetworkState : ubyte
{
    Incomplete,
    Complete
}

/// Contains the node info (state & addresses & isValidator)
public struct NodeInfo
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

     Non `Transaction` data that are part of consensus are also accepted by
     full nodes, which simply relays them if they are valid (e.g. `Enrollment`).

*******************************************************************************/

@path("/")
public interface API
{
// The REST generator requires @safe methods
@safe:

    /***************************************************************************

        Register the given address to listen for gossiping messages.

        Params:
            address = the address of the node to register

        API:
            PUT /register_listener

    ***************************************************************************/

    @method(HTTPMethod.PUT)
    public void registerListener (Address address);

    /***************************************************************************

        Returns:
            The peer information on this node

        API:
            GET /node_info

    ***************************************************************************/

    public NodeInfo getNodeInfo ();

    /***************************************************************************

        Returns:
            Return true if the node has this transaction hash.

        API:
            GET /has_transaction_hash

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

        API:
            GET /block_height

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

    public const(Block)[] getBlocksFrom (ulong block_height, uint max_blocks);


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

    /***************************************************************************

        Enroll as a validator

        API:
            PUT /enroll_validator

        Params:
            enroll = the Enrollment object, the information about an validator

    ***************************************************************************/

    public void enrollValidator (Enrollment enroll);

    /***************************************************************************

        Check if an enrollment data exists in the validator set

        API:
            GET /has_enrollment

        Params:
            enroll_hash = key for an enrollment data which is hash of frozen UTXO

        Returns:
            true if the validator set has the enrollment data

    ***************************************************************************/

    @method(HTTPMethod.GET)
    public bool hasEnrollment (Hash enroll_hash);

    /***************************************************************************

        Get validator's pre-image inforamtion

        API:
            GET /get_preimage

        Params:
            enroll_key = The key for the enrollment in which the pre-image is
                contained.

        Returns:
            preimage information of the validator if exists, otherwise
                PreImageInfo.init

    ***************************************************************************/

    public PreImageInfo getPreimage (Hash enroll_key);
}
