/*******************************************************************************

    Expose facilities used by the `Node` to communicate with the network

    The `NetworkManager` is responsible for managing the view of the network
    that a `Node` has.
    Things such as peer blacklisting, prioritization (which peer is contacted
    first when a message has to be sent), etc... are handled here.

    In unittests, one can replace a `NetworkManager` with a `TestNetworkManager`
    which provides a different client type (see `getClient`) in order to enable
    in-memory network communication.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.NetworkManager;

import agora.common.BanManager;
import agora.consensus.data.Block;
import agora.common.crypto.Key;
import agora.common.Config;
import agora.common.Data;
import agora.common.Metadata;
import agora.common.Set;
import agora.common.Task;
import agora.consensus.data.Transaction;
import agora.network.NetworkClient;
import agora.node.API;
import agora.node.Ledger;

import vibe.core.log;
import vibe.web.rest;

import std.algorithm;
import std.array;
import std.exception;
import std.format;
import std.random;
import std.typecons;

import core.stdc.time;
import core.time;


/// Ditto
public class NetworkManager
{
    /// Config instance
    private const NodeConfig node_config = NodeConfig.init;

    /// Task manager
    private TaskManager taskman;

    /// The connected nodes
    protected NetworkClient[PublicKey] peers;

    /// The addresses currently establishing connections to.
    /// Used to prevent connecting to the same address twice.
    protected Set!Address connecting_addresses;

    /// All known addresses so far
    protected Set!Address known_addresses;

    /// Addresses are added and removed here,
    /// but never added again if they're already in known_addresses
    protected Set!Address todo_addresses;

    /// Address ban manager
    protected BanManager banman;

    ///
    private Metadata metadata;

    /// Initial seed peers
    const(string)[] seed_peers;

    /// DNS seeds
    private const(string)[] dns_seeds;

    /// Ctor
    public this (in NodeConfig node_config, in BanManager.Config banman_conf,
        in string[] peers, in string[] dns_seeds, Metadata metadata)
    {
        this.taskman = this.getTaskManager();
        this.node_config = node_config;
        this.metadata = metadata;
        this.seed_peers = peers;
        this.dns_seeds = dns_seeds;
        this.banman = this.getBanManager(banman_conf);
    }

    /// try to discover the network until we found
    /// all the validator nodes from our quorum set.
    public void discover ()
    {
        // add our own IP to the list of banned IPs to avoid
        // the node communicating with itself
        this.banman.banUntil(format("http://%s:%s", this.node_config.address,
            this.node_config.port), time_t.max);

        assert(this.metadata !is null, "Metadata is null");
        this.metadata.load();

        // if we have peers in the metadata, use them
        if (this.metadata.peers.length > 0)
        {
            this.addAddresses(this.metadata.peers);
        }
        else
        {
            // add the IP seeds
            this.addAddresses(Set!Address.from(this.seed_peers));

            // add the DNS seeds
            if (this.dns_seeds.length > 0)
                this.addAddresses(resolveDNSSeeds(this.dns_seeds));
        }

        logInfo("Discovering from %s", this.todo_addresses.byKey());

        while (!this.minPeersConnected())
        {
            this.connectNextAddresses();
            this.taskman.wait(this.node_config.retry_delay.msecs);
        }

        logInfo("Discovery reached. %s peers connected.", this.peers.length);

        // the rest can be done asynchronously as we can already
        // start validating and voting on the blockchain
        this.taskman.runTask(()
        {
            while (1)
            {
                if (!this.peerLimitReached())
                    this.connectNextAddresses();

                this.taskman.wait(this.node_config.retry_delay.msecs);
            }
        });
    }

    /***************************************************************************

        Periodically retrieve the latest blocks and apply them to the
        provided ledger.

        Params:
            ledger = the Ledger to apply received blocks to

    ***************************************************************************/

    public void retrieveLatestBlocks (Ledger ledger)
    {
        this.taskman.runTask(
        ()
        {
            // periodic task
            while (1)
            {
                this.getBlocksFrom(
                    ledger.getLastBlock().header.height + 1,
                    (blocks) { blocks.each!(block => ledger.acceptBlock(block)); });

                this.taskman.wait(2.seconds);
            }
        });
    }

    /***************************************************************************

        Returns:
            an instance of a vibe.d-backed task manager

    ***************************************************************************/

    protected TaskManager getTaskManager ()
    {
        return new TaskManager();
    }

    /***************************************************************************

        Get a BanManager instance.

        Can be overriden in unittests to test ban management
        without relying on a clock.

        Params:
            banman_conf = ban manager config

        Returns:
            an instance of a BanManager

    ***************************************************************************/

    protected BanManager getBanManager (in BanManager.Config banman_conf)
    {
        return new BanManager(banman_conf);
    }

    /***************************************************************************

        Retrieve blocks starting from block_height up to the highest block
        that's available from the connected nodes.

        As requests may fail, this function should be called with a timer
        to ensure consistency of the node's ledger with other nodes.

        Params:
            block_height = the starting block height to begin retrieval from
            onReceivedBlocks = delegate to call with the received blocks

    ***************************************************************************/

    private void getBlocksFrom (ulong block_height,
        scope void delegate(const(Block)[]) @safe onReceivedBlocks) nothrow
    {
        // return size_t.max if getBlockHeight() fails
        size_t getHeight (NetworkClient node)
        {
            try
                return node.getBlockHeight();
            catch (Exception ex)
                return size_t.max;
        }

        try
        {
            auto node_pair = this.peers.byValue
                .map!(node => tuple(getHeight(node), node))
                .filter!(pair => pair[0] != ulong.max)  // request failed
                .reduce!((a, b) => a[0] > b[0] ? a : b);

            const highest_block = node_pair[0];
            if (highest_block < block_height)
                return;  // we're up to date

            logInfo("Retrieving latest blocks..");
            auto node = node_pair[1];
            const MaxBlocks = 1024;

            do
            {
                // todo: if any block fails verification, we have to try another node
                auto blocks = node.getBlocksFrom(block_height, MaxBlocks);
                logInfo("Received blocks [%s..%s] out of %s..", block_height,
                    block_height + blocks.length, highest_block + 1);  // genesis block

                onReceivedBlocks(blocks);
                block_height += blocks.length;
            }
            while (block_height < highest_block);
        }
        catch (Exception ex)
        {
            logError("Couldn't retrieve blocks: %s. Will try again later..",
                ex.message);
        }
    }

    /// Dump the metadata
    public void dumpMetadata ()
    {
        this.metadata.dump();
    }

    /// Attempt connecting with the given address
    private void tryConnecting (Address address)
    {
        // banned address, try later
        if (this.banman.isBanned(address))
        {
            this.connecting_addresses.remove(address);
            this.todo_addresses.put(address);
            return;
        }

        logInfo("Establishing connection with %s...", address);
        auto node = new NetworkClient(this.taskman, this.banman, address,
            this.getClient(address, this.node_config.timeout.msecs),
            this.node_config.retry_delay.msecs,
            this.node_config.max_retries);

        while (1)
        {
            try
            {
                node.handshake();
                this.onNodeConnected(node);
                break;
            }
            catch (Exception ex)
            {
                // try again, unless banned
                if (this.banman.isBanned(node.address))
                {
                    this.connecting_addresses.remove(node.address);
                    this.todo_addresses.put(node.address);  // try later
                    logInfo("Handshake with node %s failed: %s. Node banned until %s",
                        node.address, ex.message, this.banman.getUnbanTime(node.address));
                    return;
                }
            }
        }

        // keep asynchronously polling for complete network info,
        // until complete peer info is returned, or we've
        // established all necessary connections,
        // or the node was banned
        while (!this.minPeersConnected())
        {
            try
            {
                auto net_info = node.getNetworkInfo();
                if (net_info.state == NetworkState.Complete)
                    return;  // done

                // if it's incomplete give the client some time to connect
                // with other peers and try again later
                logInfo("[%s] (%s): Peer info is incomplete. Retrying in %s..",
                    node.address, node.key, this.node_config.retry_delay);
                this.taskman.wait(this.node_config.retry_delay.msecs);
            }
            catch (Exception ex)
            {
                // try again, unless banned
                if (this.banman.isBanned(node.address))
                {
                    this.connecting_addresses.remove(node.address);
                    this.todo_addresses.put(node.address);  // try later
                    logInfo("Retrieval of peers from node %s failed: %s. " ~
                        "Node banned until %s", node.address, ex.message,
                        this.banman.getUnbanTime(node.address));
                    return;
                }
            }
        }
    }

    private void onNodeConnected (NetworkClient node)
    {
        this.connecting_addresses.remove(node.address);

        if (this.peerLimitReached())
            return;

        logInfo("Established new connection with peer: %s", node.key);
        this.peers[node.key] = node;
        this.metadata.peers.put(node.address);
    }

    /// Received new set of addresses, put them in the todo & known IP list
    private void addAddresses (Set!Address addresses)
    {
        foreach (address; addresses)
        {
            // go away
            if (this.banman.isBanned(address))
                continue;

            // make a note of it
            this.known_addresses.put(address);

            // not connecting? connect later
            if (address !in this.connecting_addresses)
                this.todo_addresses.put(address);
        }
    }

    /// start tasks for each new and valid address
    private void connectNextAddresses ()
    {
        // nothing to check this round
        if (this.todo_addresses.length == 0)
            return;

        auto random_addresses = this.todo_addresses.pickRandom();

        logInfo("Connecting to next set of addresses: %s",
            random_addresses);

        foreach (address; random_addresses)
        {
            this.todo_addresses.remove(address);

            if (!this.banman.isBanned(address) &&
                address !in this.connecting_addresses)
            {
                this.connecting_addresses.put(address);
                this.taskman.runTask(() { this.tryConnecting(address); });
            }
        }
    }

    ///
    private bool minPeersConnected ()  pure nothrow @safe @nogc
    {
        return this.peers.length >= this.node_config.min_listeners;
    }

    private bool peerLimitReached ()  nothrow @safe
    {
        return this.peers.byValue.filter!(node =>
            !this.banman.isBanned(node.address)).count >= this.node_config.max_listeners;
    }

    /// Returns: the list of node IPs this node is connected to
    public NetworkInfo getNetworkInfo () pure nothrow @safe @nogc
    {
        return NetworkInfo(
            this.minPeersConnected()
                ? NetworkState.Complete : NetworkState.Incomplete,
            this.known_addresses);
    }

    /***************************************************************************

        Instantiates a client object implementing `API`

        This function simply returns a client object implementing `API`.
        In the default implementation, this returns a `RestInterfaceClient`.
        However, it can be overriden in test code to return an in-memory client.

        Params:
          address = The address (IPv4, IPv6, hostname) of this node
          timeout = the timeout duration to use for requests

        Returns:
          An object to communicate with the node at `address`

    ***************************************************************************/

    protected API getClient (Address address, Duration timeout)
    {
        import vibe.http.client;

        auto settings = new RestInterfaceSettings;
        settings.baseURL = URL(address);
        settings.httpClientSettings = new HTTPClientSettings;
        settings.httpClientSettings.connectTimeout = timeout;
        settings.httpClientSettings.readTimeout = timeout;

        return new RestInterfaceClient!API(settings);
    }

    /***************************************************************************

        Sends the transaction to all the listeners.

        Params:
            tx = the transaction to send

    ***************************************************************************/

    public void sendTransaction (Transaction tx) @safe
    {
        foreach (ref node; this.peers)
        {
            if (this.banman.isBanned(node.address))
            {
                logTrace("Not sending to %s as it's banned", node.address);
                continue;
            }

            node.sendTransaction(tx);
        }
    }
}

/*******************************************************************************

    Resolves IPs out of a list of DNS seeds

    Params:
        addresses = the set of DNS seeds

    Returns:
        The resolved set of IPs

*******************************************************************************/

private Set!Address resolveDNSSeeds (in string[] dns_seeds)
{
    import std.conv;
    import std.string;
    import std.socket : getAddressInfo, AddressFamily, ProtocolType;

    Set!Address resolved_ips;

    foreach (host; dns_seeds)
    try
    {
        logInfo("DNS: contacting seed '%s'..", host);
        foreach (addr_info; getAddressInfo(host))
        {
            logTrace("DNS: checking address %s", addr_info);
            if (addr_info.family != AddressFamily.INET &&
                addr_info.family != AddressFamily.INET6)
            {
                logTrace("DNS: rejected non-IP family %s", addr_info.family);
                continue;
            }

            // we only support TCP for now
            if (addr_info.protocol != ProtocolType.TCP)
            {
                logTrace("DNS: rejected non-TCP node %s", addr_info);
                continue;
            }

            // if the port is set to zero, assume default Boa port
            auto ip = addr_info.address.to!string.replace(":0", ":2826");
            logInfo("DNS: accepted IP %s", ip);
            resolved_ips.put(ip);
        }
    }
    catch (Exception ex)
    {
        logError("Error contacting DNS seed: %s", ex.message);
    }

    return resolved_ips;
}
