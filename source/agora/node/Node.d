/*******************************************************************************

    Implementation of the Node's API.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.Node;

import agora.consensus.data.Block;
import agora.common.BanManager;
import agora.common.Config;
import agora.common.Metadata;
import agora.common.crypto.Key;
import agora.common.Data;
import agora.common.TransactionPool;
import agora.consensus.data.Transaction;
import agora.network.NetworkManager;
import agora.node.API;
import agora.node.BlockStorage;
import agora.node.Ledger;

import agora.node.GossipProtocol;

import vibe.core.log;
import vibe.data.json;
import vibe.web.rest : RestException;

import std.algorithm;
import std.exception;
import std.path : buildPath;

/// Maximum number of blocks that will be sent in a call to getBlocksFrom()
private enum MaxBatchBlocksSent = 1000;

/*******************************************************************************

    Implementation of the Node API

    This class implement the business code of the node.
    Communication with the other nodes is handled by the `Network` class.

*******************************************************************************/
public class Node : API
{
    /// Metadata instance
    protected Metadata metadata;

    /// Config instance
    private const Config config;

    /// Network of connected nodes
    private NetworkManager network;

    /// Reusable exception object
    private RestException exception;

    /// Procedure of peer-to-peer communication
    private GossipProtocol gossip;

    /// Transaction pool
    private TransactionPool pool;

    ///
    private Ledger ledger;

    /// Blockstorage
    private IBlockStorage storage;

    /// Ctor
    public this (const Config config)
    {
        this.metadata = this.getMetadata(config.node.data_dir);

        this.config = config;
        this.network = this.getNetworkManager(config.node, config.banman,
            config.network, config.dns_seeds, this.metadata);
        this.storage = this.getBlockStorage(config.node.data_dir);
        this.pool = this.getPool(config.node.data_dir);
        this.ledger = new Ledger(this.pool, this.storage);
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
    }

    /***************************************************************************

        Called on node shutdown.

        Note that this is called explicitly before any destructors,
        to allow clean shutdown of e.g. databases, which may require
        GC allocations during the shutdown phase.

    ***************************************************************************/

    public void shutdown ()
    {
        logInfo("Shutting down..");
        this.network.dumpMetadata();
        this.pool.shutdown();
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
        return this.ledger.getBlockHeight();
    }

    /// GET: /blocks_from
    public const(Block)[] getBlocksFrom (ulong block_height, size_t max_blocks)
        @safe
    {
        return this.ledger.getBlocksFrom(block_height,
            min(max_blocks, MaxBatchBlocksSent));
    }

    /***************************************************************************

        Returns an instance of a NetworkManager

        Unittests can override this method and return a custom NetworkManager.

        Params:
            node_config = the node config
            banman_conf = the ban manager config
            peers = the peers to connect to
            dns_seeds = the DNS seeds to retrieve peers from
            metadata = metadata containing known peers and other meta info

        Returns:
            an instance of a NetworkManager

    ***************************************************************************/

    protected NetworkManager getNetworkManager (in NodeConfig node_config,
        in BanManager.Config banman_conf, in string[] peers,
        in string[] dns_seeds, Metadata metadata)
    {
        return new NetworkManager(node_config, banman_conf, peers, dns_seeds,
            metadata);
    }

    /***************************************************************************

        Returns an instance of a TransactionPool

        Subclasses can override this method and return
        a TransactionPool backed by an in-memory SQLite database.

        Params:
            data_dir = path to the data directory

        Returns:
            the transaction pool

    ***************************************************************************/

    protected TransactionPool getPool (string data_dir)
    {
        return new TransactionPool(buildPath(
            config.node.data_dir, "tx_pool.dat"));
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

    /***************************************************************************

        Returns an instance of a BlockStorage or MemoryStorage

        Note: not exposed in the API.

        Params:
            data_dir = path to the blockdata directory

        Returns:
            Returns instance of `MemoryStorage` if data_dir is empty,
            otherwise returns instance of `BlockStorage`

    ***************************************************************************/

    protected IBlockStorage getBlockStorage (string data_dir) @system
    {
        version (unittest)
        {
            return new MemBlockStorage();
        }
        else
        {
            return new BlockStorage(data_dir);
        }
    }

    /// GET: /merkle_path
    public Hash[] getMerklePath (ulong block_height, Hash hash) @safe
    {
        return this.ledger.getMerklePath(block_height, hash);
    }
}
