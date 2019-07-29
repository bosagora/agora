/*******************************************************************************

    Implementation of the Node's API.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.Node;

import agora.common.API;
import agora.common.Block;
import agora.common.Config;
import agora.common.Metadata;
import agora.common.crypto.Key;
import agora.common.Data;
import agora.common.Transaction;
import agora.network.NetworkManager;
import agora.node.Ledger;

import agora.node.GossipProtocol;

import vibe.core.log;
import vibe.data.json;
import vibe.web.rest;

import std.algorithm;
import std.exception;

/// Maximum number of blocks that will be sent in a call to getBlocksFrom()
private enum MaxBatchBlocksSent = 1000;

/*******************************************************************************

    Implementation of the Node API

    This class implement the business code of the node.
    Communication with the other nodes is handled by the `Network` class.

    Params:
      Network = Type of the class handling network communication
                `agora.network.NetworkManager.NetworkManager` or a
                derivative is expected.

*******************************************************************************/
public class Node (Network) : API
{
    /// Metadata instance
    protected Metadata metadata;

    /// Config instance
    private const Config config;

    /// Network of connected nodes
    private Network network;

    /// Reusable exception object
    private RestException exception;

    /// Procedure of peer-to-peer communication
    private GossipProtocol gossip;

    ///
    private Ledger ledger;


    /// Ctor
    public this (const Config config)
    {
        this.metadata = this.getMetadata(config.node.data_dir);

        this.config = config;
        this.network = new Network(config.node, config.banman, config.network,
            config.dns_seeds,
            this.metadata);
        this.ledger = new Ledger();
        this.gossip = new GossipProtocol(this.network, this.ledger);
        this.exception = new RestException(
            400, Json("The query was incorrect"), string.init, int.init);
    }

    /// The first task method, loading from disk, node discovery, etc
    public void start ()
    {
        logInfo("Doing network discovery..");
        this.network.discover();

        this.network.retrieveLatestBlocks(this.ledger);

        logInfo("Dumping metadata..");
        this.network.dumpMetadata();
    }

    /// GET /public_key
    public override PublicKey getPublicKey () pure nothrow @safe @nogc
    {
        return this.config.node.key_pair.address;
    }

    /// GET: /network_info
    public override NetworkInfo getNetworkInfo () pure nothrow @safe @nogc
    {
        return this.network.getNetworkInfo();
    }

    /***************************************************************************

        Receive a transaction.

        API:
            PUT /transaction

        Params:
            tx = the received transaction

    ***************************************************************************/

    public override void putTransaction (Transaction tx) @safe
    {
        this.gossip.receiveTransaction(tx);
    }

    /// GET: /hasTransactionHash
    public override bool hasTransactionHash (Hash tx) @safe
    {
        return this.gossip.hasTransactionHash(tx);
    }

    /// GET: /block_height
    public ulong getBlockHeight ()
    {
        return this.ledger.getLastBlock().header.height;
    }

    /// GET: /blocks_from
    public const(Block)[] getBlocksFrom (ulong block_height, size_t max_blocks)
        @safe
    {
        return this.ledger.getBlocksFrom(block_height,
            min(max_blocks, MaxBatchBlocksSent));
    }

    /***************************************************************************

        Reads the metadata from the provided disk path.

        Subclasses can override this method and return
        a Metadata object which loads/dumps data in memory
        rather than on disk, to avoid I/O (e.g. for unittesting)

        Note: not exposed in the API.

        Params:
            data_dir = path to the data directory

        Returns:
            the metadata loaded from disk

    ***************************************************************************/

    protected Metadata getMetadata (string data_dir) @system
    {
        return new DiskMetadata(data_dir);
    }


    /// GET: /merkle_path
    public Hash[] getMerklePath (ulong block_height, Hash hash) @safe
    {
        return this.ledger.getMerklePath(block_height, hash);
    }
}
