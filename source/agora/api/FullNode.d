/*******************************************************************************

    Definitions of the full node API

    See agora.node.api.Validator for a full explanation on this API.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.api.FullNode;

import agora.common.Types;
import agora.common.Set;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.data.ValidatorInfo;
import agora.crypto.Key;

import vibe.data.serialization;
import vibe.http.common;
import vibe.web.rest;

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
    public Set!Address addresses;
}

/// Identity of a Validator node
public struct Identity
{
    /// Public Key of the node
    PublicKey key;

    /// UTXO that is used as collateral
    Hash utxo;

    /// MAC
    ubyte[] mac;
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
@serializationPolicy!(Base64ArrayPolicy)
public interface API
{
// The REST generator requires @safe methods
@safe:

    /***************************************************************************

        Endpoint used by other FullNodes or Validator to establish a long
        connection to this node.

        Note that this is done in the FullNode API, as a node doesn't know if
        another node is a full node or validator just from the address (but can
        expect a validator, e.g. when contacting a registry-provided address).

        Params:
          peer = `PublicKey` of the node initiating the connection.
                 This is used for establishing a shared secret and doesn't
                 need to be an enrolled key.

    ***************************************************************************/

    public Identity handshake (in PublicKey peer);

    /***************************************************************************

        Returns:
            The peer information on this node

        API:
            GET /node_info

    ***************************************************************************/

    public NodeInfo getNodeInfo ();

    /***************************************************************************

        Returns:
            The local clock time of this node (not network-adjusted)

        API:
            GET /local_time

        Warning: this request should be protected via node-to-node encryption,
        or else be signed with a unique challenge/response. Otherwise a
        byzantine node can cache a node's older response and feed it to a
        victim node (replay attack).

    ***************************************************************************/

    public TimePoint getLocalTime ();

    /***************************************************************************

        Returns:
            the highest block height in this node's ledger

        API:
            GET /block_height

    ***************************************************************************/

    public ulong getBlockHeight ();

    /***************************************************************************

        Expose blocks as a REST collection

        API:
            GET /blocks/:height

        Params:
            _height = The height of the block to return

        Returns:
            The block at height `_height`, or throw an `Exception` (404).

    ***************************************************************************/

    @path("/blocks/:height")
    public const(Block) getBlock (ulong _height);

    /***************************************************************************

        Get the array of blocks starting from the provided block height.

        The block at `height` is included in the array.
        Note that a node is free to return less blocks than asked for.
        However it must never return more blocks than asked for.

        API:
            GET /blocks_from

        Params:
            height = the starting block height to begin retrieval from
            max_blocks   = the maximum blocks to return at once

        Returns:
            the array of blocks starting from height,
            up to `max_blocks`

    ***************************************************************************/

    public const(Block)[] getBlocksFrom (ulong height, uint max_blocks);

    /***************************************************************************

        Get the array of hashes which form the merkle path

        API:
            GET /merkle_path

        Params:
            height = Height of the block that contains the transaction hash
            hash         = transaction hash

        Returns:
            the array of hashes which form the merkle path

    ***************************************************************************/

    public Hash[] getMerklePath (ulong height, in Hash hash);

    /***************************************************************************

        API:
            GET /block_headers

        Params:
            heights = A set of block heights to fetch headers for

        Returns:
            Block headers for requested heights

    ***************************************************************************/

    public BlockHeader[] getBlockHeaders (Set!ulong heights);

    /***************************************************************************

        Returns the preimages for the specified enroll keys.

        Params:
            enroll_keys = Set of enrollment keys. If the set of enroll_keys is
            null or empty, then all preimages known to the node are returned.

        Returns:
            The preimages for the specified enroll keys. If the requested node
            doesn't know the preimage for a specific enroll key, then it will
            not be included in the result.

        API:
            GET /preimages

    ***************************************************************************/

    public PreImageInfo[] getPreimages (Set!Hash enroll_keys = Set!Hash.init);

    /***************************************************************************

        Get validators' pre-image information spanning a certain period

        This is most useful when catching up, as it allows to get the last
        preimage for validators active between `start_height` and `end_height`.
        The returned value will include only one `PreImageInfo` per UTXO
        (the latest one). A conforming implementation might return values
        that are above `end_height`.

        In other words, the parameters define the bound of the enrolled
        validator, not the bound of the pre-images.

        API:
            GET /preimages_from

        Params:
            start_height = the starting enrolled height to begin retrieval from

        Returns:
            preimages' information of the validators

    ***************************************************************************/

    public PreImageInfo[] getPreimagesFrom (ulong start_height);

    /***************************************************************************

        API:
            GET /validators

        Params:
            height = Height at which the information is desired
                     (default: current)

    ***************************************************************************/

    public ValidatorInfo[] getValidators (ulong height);

    /// Ditto
    public ValidatorInfo[] getValidators ();

    /***************************************************************************

        API:
            POST /transaction

    ***************************************************************************/

    public void postTransaction (in Transaction tx);

    /***************************************************************************

        Reveals a pre-image

        API:
            POST /preimage

        Params:
            preimage = a PreImageInfo object which contains a hash and a height

    ***************************************************************************/

    public void postPreimage (in PreImageInfo preimage);

    /***************************************************************************

        Enroll as a validator

        API:
            POST /enrollment

        Params:
            enroll = the Enrollment object, the information about an validator

    ***************************************************************************/

    public void postEnrollment (in Enrollment enroll);

    /***************************************************************************

        Returns:
            Return true if the node has this transaction hash.

        API:
            GET /has_transaction_hash

    ***************************************************************************/

    @method(HTTPMethod.GET)
    public bool hasTransactionHash (in Hash tx);

    /***************************************************************************

        API:
            GET /transactions

        Params:
            tx_hashes = A Set of Transaction hashes

        Returns:
            Transactions corresponding to the requested hashes or
            Transaction.init for hashes that can't be found in the pool

    ***************************************************************************/

    @method(HTTPMethod.GET)
    public Transaction[] getTransactions (Hash[] tx_hashes);

    /***************************************************************************

        Get an enrollment data if the data exists in the enrollment pool

        API:
            GET /enrollment

        Params:
            enroll_hash = key for an enrollment data which is hash of frozen UTXO

        Returns:
            the enrollment data if exists, otherwise Enrollment.init

    ***************************************************************************/

    @method(HTTPMethod.GET)
    public Enrollment getEnrollment (in Hash enroll_hash);
}
