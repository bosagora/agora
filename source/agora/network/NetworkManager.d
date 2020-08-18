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

import agora.api.Validator;
import agora.api.handler.BlockExternalizedHandler;
import agora.api.handler.PreImageReceivedHandler;
import agora.common.BanManager;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.common.crypto.Key;
import agora.common.Config;
import agora.common.Types;
import agora.common.Metadata;
import agora.common.Set;
import agora.common.Task;
import agora.consensus.data.Transaction;
import agora.network.NetworkClient;
import agora.node.Ledger;
import agora.utils.Log;

import scpd.types.Stellar_SCP;

import vibe.http.common;
import vibe.web.rest;

import std.algorithm;
import std.array;
import std.container : DList;
import std.exception;
import std.format;
import std.random;
import std.range : walkLength;

import core.stdc.time;
import core.time;

mixin AddLogger!();

/// Ditto
public class NetworkManager
{
    /// Node information
    private static struct NodeConnInfo
    {
        /// Address of the node
        Address address;

        /// Is this node a Validator
        bool is_validator;

        /// Public key of the node, only set if the node is a Validator
        PublicKey key;

        /// Client
        NetworkClient client;
    }

    /***************************************************************************

        Establishes a connection with a Node address in a new task.

    ***************************************************************************/

    private class ConnectionTask
    {
        /// Address to connect to
        private const Address address;

        /// Called when we've connected and determined if this is
        /// a FullNode / Validator
        private void delegate (scope ref NodeConnInfo) onHandshakeComplete;

        /// Called when a request to a node fails.
        /// The delegate should return true if we should continue trying
        /// to send requests to this node, or false (e.g. if the node is banned)
        private bool delegate (in Address) onFailedRequest;


        /***********************************************************************

            Ctor

            Params:
                address = the adddress of the node
                onHandshakeComplete = called when we've successfully connected
                                      and determined the type of the Node
                onFailedRequest = called when a request fails, returns true
                                  if we should keep trying to send requests

        ***********************************************************************/

        public this (in Address address,
            void delegate (scope ref NodeConnInfo node) onHandshakeComplete,
            bool delegate (in Address address) onFailedRequest)
        {
            this.address = address;
            this.onHandshakeComplete = onHandshakeComplete;
            this.onFailedRequest = onFailedRequest;
        }

        /***********************************************************************

            Start the connection task

        ***********************************************************************/

        public void start ()
        {
            this.outer.taskman.runTask(&this.connect);
        }

        /***********************************************************************

            Repeatedly attempt connecting to an address, and try to determine
            if this is a FullNode or a Validator.

            After each connection failure / request failure the ban manager is
            queried, and if this address was banned then 'onFailedRequest()'
            will be called and the task will be killed.

            If we've successfully connected and determined the Node type,
            'onHandshakeComplete' is called and the task is killed.

        ***********************************************************************/

        private void connect ()
        {
            auto client = this.outer.getNetworkClient(this.outer.taskman,
                this.outer.banman, this.address,
                this.outer.getClient(this.address,
                    this.outer.node_config.timeout),
                this.outer.node_config.retry_delay,
                this.outer.node_config.max_retries);

            PublicKey key;
            while (1)
            {
                try
                {
                    // LocalRest will return PublicKey.init,
                    // vibe.d will throw HTTPStatusException with status == 404
                    key = client.getPublicKey();
                    break;
                }
                catch (Exception ex)
                {
                    if (auto http = cast(HTTPStatusException)ex)
                    {
                        // 404 => API not implemented, it's a FullNode
                        if (http.status == 404)
                            break;
                    }

                    if (!this.onFailedRequest(this.address))
                        return;

                    // else try again
                    this.outer.taskman.wait(this.outer.node_config.retry_delay);
                }
            }

            const is_validator = key != PublicKey.init;
            if (is_validator)
                log.info("Found new Validator: {} (key: {})", address, key);
            else
                log.info("Found new FullNode: {}", address);

            NodeConnInfo node = {
                address : this.address,
                is_validator : is_validator,
                key : key,
                client : client
            };

            this.onHandshakeComplete(node);
        }
    }

    /***************************************************************************

        Queries a Node's getNodeInfo() API endpoint to discover new sets
        of addresses we may want to connect to.

        The provided delegate will be called each time a Node's known
        addresses were retrieved via the getNodeInfo() API endpoint.

        Note that this is a never-ending task. A node's NodeInfo may signal
        that it's complete, however the list of its peers may grow as new
        incoming connections are established as well as when any quorum
        reshuffling happens.

    ***************************************************************************/

    private class AddressDiscoveryTask
    {
        import std.container : DList;

        /// A queue of clients. Each client is contacted, and pushed back to the
        /// queue (unless they were banned)
        private DList!NetworkClient clients;

        /// Convenience alias
        public alias Callback = void delegate (Set!Address addresses);

        /// Called when we have retrieved a set of addresses from a client
        private Callback onNewAddresses;


        /***********************************************************************

            Constructor

            Params:
                onNewAddresses = called when a set of addresses were retrieved
                                 from a node

        ***********************************************************************/

        public this (Callback onNewAddresses) @safe pure nothrow @nogc
        {
            this.onNewAddresses = onNewAddresses;
        }

        /***********************************************************************

            Start the asynchronous address discovery task.

        ***********************************************************************/

        public void run ()
        {
            // workaround to only run this task once
            // (cannot run it in the ctor as the scheduler may not be running yet)
            // todo: move it to the ctor once we have `schedule` implemented.
            static bool is_running;
            if (!is_running)
            {
                is_running = true;
                this.outer.taskman.runTask(&this.getNewAddresses);
            }
        }

        /***********************************************************************

            Add a new client to the list of clients to query addresses from.

        ***********************************************************************/

        public void add (NetworkClient client)
        {
            this.clients.insertBack(client);
        }

        /***********************************************************************

            Neverending function that retrieves the network state out of
            all the clients it knows about. The clients are kept in a queue,
            and each client is queried in sequence.

            If the client's address is banned, it will be removed from the
            clients list.

        ***********************************************************************/

        private void getNewAddresses ()
        {
            while (1)
            {
                scope (success)
                    this.outer.taskman.wait(1.seconds);

                if (this.clients.empty())
                    continue;

                NetworkClient client = this.clients.front;
                this.clients.removeFront();

                try
                {
                    auto node_info = client.getNodeInfo();
                    this.onNewAddresses(node_info.addresses);
                }
                catch (Exception ex)
                {
                    // request failures are already logged
                }
                finally
                {
                    if (!this.outer.banman.isBanned(client.address))
                        this.clients.insertBack(client);
                }
            }
        }
    }

    /// Config instance
    protected const NodeConfig node_config = NodeConfig.init;

    /// Task manager
    private TaskManager taskman;

    /// Never-ending address discovery task
    protected AddressDiscoveryTask discovery_task;

    /// Connection tasks for the nodes we're trying to connect to
    protected ConnectionTask[Address] connection_tasks;

    /// List of validator clients
    protected DList!NetworkClient validators;

    /// All connected nodes (Validators & FullNodes)
    protected DList!NetworkClient peers;

    /// Easy lookup of currently connected peers
    protected Set!Address connected_peers;

    /// All known addresses so far (used for getNodeInfo())
    protected Set!Address known_addresses;

    /// The list of addresses we have not yet tried to connect to
    protected Set!Address todo_addresses;

    /// For a Validator, NodeInfo.state will be Complete only
    /// if it has connected to all of its quorum peers.
    /// See 'minPeersConnected'
    private Set!PublicKey required_peer_keys;

    /// Address ban manager
    protected BanManager banman;

    ///
    private Metadata metadata;

    /// Maximum connection tasks to run in parallel
    private enum MaxConnectionTasks = 10;

    /// Ctor
    public this (in NodeConfig node_config, in BanManager.Config banman_conf,
        in string[] seed_peers, in string[] dns_seeds, Metadata metadata,
        TaskManager taskman)
    {
        this.taskman = taskman;
        this.node_config = node_config;
        this.metadata = metadata;
        this.banman = this.getBanManager(banman_conf, node_config.data_dir);
        this.discovery_task = new AddressDiscoveryTask(&this.addAddresses);

        this.banman.load();

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
            this.addAddresses(Set!Address.from(seed_peers));

            // add the DNS seeds
            if (dns_seeds.length > 0)
                this.addAddresses(resolveDNSSeeds(dns_seeds));
        }
    }

    /// Called after a node's handshake is complete
    private void onHandshakeComplete (scope ref NodeConnInfo node)
    {
        this.connected_peers.put(node.address);
        this.peers.insertBack(node.client);

        if (node.is_validator)
        {
            this.validators.insertBack(node.client);
            this.required_peer_keys.remove(node.key);
        }

        this.discovery_task.add(node.client);
        this.metadata.peers.put(node.address);
        this.connection_tasks.remove(node.address);

        this.registerAsListener(node.client);
    }

    /// Overridable for LocalRest which uses public keys
    protected void registerAsListener (NetworkClient client)
    {
        client.registerListener();
    }

    /// Discover the network, connect to all required peers
    /// Some nodes may want to connect to specific peers before
    /// discovery() is considered complete
    public void discover (Set!PublicKey required_peer_keys = Set!PublicKey.init)
    {
        log.info("Doing network discovery..");

        this.required_peer_keys = required_peer_keys;

        // actually just runs it once, but we need the scheduler to run first
        // and it doesn't run in the constructor yet (LocalRest)
        this.discovery_task.run();

        /// Returns: true if we should keep trying to connect to an address,
        /// else false if the address was banned
        bool onFailedRequest (in Address address)
        {
            if (this.banman.isBanned(address))
            {
                this.connection_tasks.remove(address);
                return false;
            }

            return true;
        }

        while (!this.peerLimitReached())
        {
            scope (success)
                this.taskman.wait(this.node_config.retry_delay);

            if (this.connection_tasks.length >= MaxConnectionTasks)
            {
                log.info("Connection task limit reached. Trying again in {}..",
                    this.node_config.retry_delay);
                continue;
            }

            const num_addresses = MaxConnectionTasks -
                this.connection_tasks.length;

            foreach (address; this.todo_addresses.pickRandom(num_addresses))
            {
                this.todo_addresses.remove(address);
                this.connection_tasks[address] = new ConnectionTask(
                    address, &onHandshakeComplete, &onFailedRequest);
                this.connection_tasks[address].start();
            }
        }
    }

    /***************************************************************************

        Register the given address as a listener for gossip / consensus messages.

        This adds the given address to the connecting queue, but does not
        immediately connect to it. Addresses are currently handled in the
        start() loop, which will exit as soon as 'min_listeners' are reached.

        Params:
            address = the address of node to register

    ***************************************************************************/

    public void registerListener (Address address)
    {
        if (this.shouldEstablishConnection(address))
            this.addAddress(address);
    }

    /***************************************************************************

        Check if we should connect with the given address.
        If the address is banned, already connected, or already queued
        for a connection then return false.

        Params:
            address = the address to check

        Returns:
            true if we should establish connection to this address

    ***************************************************************************/

    private bool shouldEstablishConnection (Address address)
    {
        return !this.isOurOwnAddress(address) &&
            !this.banman.isBanned(address) &&
            address !in this.connected_peers &&
            address !in this.connection_tasks &&
            address !in this.todo_addresses;
    }

    /// Received new set of addresses, put them in the todo address list
    private void addAddresses (Set!Address addresses)
    {
        foreach (address; addresses)
            this.addAddress(address);
    }

    /// Ditto
    private void addAddress (Address address)
    {
        if (this.shouldEstablishConnection(address))
            this.todo_addresses.put(address);

        // we do not include our own address in list of known,
        // however we do included banned addresses.
        // reasoning: while *we* cannot establish a connection with
        // a node it's possible other nodes in the network might be able to.
        if (!this.isOurOwnAddress(address))
            this.known_addresses.put(address);
    }

    /***************************************************************************

        Periodically retrieve the latest blocks and apply them to the
        provided ledger.

        Params:
            ledger = the Ledger to apply received blocks to
            isNominating = if not null, returns true if we're a Validator
                that is currently in the process of nominating blocks.
                In this case we do not want to alter the state of the Ledger
                until the nomination process finishes (isNominating() => false)

    ***************************************************************************/

    public void startPeriodicCatchup (Ledger ledger,
        bool delegate() @safe isNominating = null)
    {
        this.taskman.runTask(
        ()
        {
            void catchup ()
            {
                if (this.peers.empty())  // no clients yet (discovery)
                    return;

                this.getBlocksFrom(
                    Height(ledger.getBlockHeight() + 1),
                    blocks => blocks.all!(block =>
                        // do not alter the state of the ledger if
                        // we're currently nominating (Validator)
                        (isNominating is null || !isNominating())
                         && ledger.acceptBlock(block)));
            }
            catchup(); // avoid delay
            this.taskman.setTimer(2.seconds, &catchup, Periodic.Yes);
        });
    }

    /***************************************************************************

        Get a BanManager instance.

        Can be overriden in unittests to test ban management
        without relying on a clock.

        Params:
            banman_conf = ban manager config
            data_dir = path to the data directory

        Returns:
            an instance of a BanManager

    ***************************************************************************/

    protected BanManager getBanManager (in BanManager.Config banman_conf,
        cstring data_dir)
    {
        return new BanManager(banman_conf, data_dir);
    }

    /***************************************************************************

        Retrieve blocks starting from block_height up to the highest block
        that's available from the connected nodes.

        As requests may fail, this function should be called with a timer
        to ensure consistency of the node's ledger with other nodes.

        Params:
            block_height = the starting block height to begin retrieval from
            onReceivedBlocks = delegate to call with the received blocks
                               if it returns false, further processing of blocks
                               from the same node is rejected due to invalid
                               block data.

    ***************************************************************************/

    private void getBlocksFrom (Height block_height,
        scope bool delegate(const(Block)[]) @safe onReceivedBlocks) nothrow
    {
        struct Pair { Height height; NetworkClient client; }

        static Pair[] node_pairs;
        node_pairs.length = 0;
        assumeSafeAppend(node_pairs);

        // return ulong.max if getBlockHeight() fails
        Height getHeight (NetworkClient node)
        {
            try
                return Height(node.getBlockHeight());
            catch (Exception ex)
                return Height(ulong.max);
        }

        auto node_pair = this.peers[]
            .map!(node => Pair(getHeight(node), node))
            .filter!(pair => pair.height != ulong.max)  // request failed
            .each!(pair => node_pairs ~= pair);

        node_pairs.sort!((a, b) => a.height > b.height);

        LNextNode: foreach (pair; node_pairs) try
        {
            if (block_height > pair.height)
                continue;  // this node does not have newer blocks than us

            log.info("Retrieving blocks [{}..{}] from {}..",
                block_height, pair.height, pair.client.address);
            const MaxBlocks = 1024;

            do
            {
                auto blocks = pair.client.getBlocksFrom(block_height, MaxBlocks);
                if (blocks.length == 0)
                    continue LNextNode;

                log.info("Received blocks [{}..{}]",
                    blocks[0].header.height, blocks[$ - 1].header.height);

                // one or more blocks were rejected, stop retrieval from node
                if (!onReceivedBlocks(blocks))
                    continue LNextNode;

                block_height += blocks.length;
            }
            while (block_height < pair.height);
        }
        catch (Exception ex)
        {
            log.error("Couldn't retrieve blocks: {}. Will try again later..",
                ex.msg);
        }
    }

    /// Dump the metadata
    public void dumpMetadata ()
    {
        this.banman.dump();
        this.metadata.dump();
    }

    ///
    private bool minPeersConnected ()  pure nothrow @safe
    {
        return this.required_peer_keys.length == 0 &&
            this.peers[].walkLength >= this.node_config.min_listeners;
    }

    private bool peerLimitReached ()  nothrow @safe
    {
        return this.required_peer_keys.length == 0 &&
            this.peers[].filter!(node =>
                !this.banman.isBanned(node.address)).count >= this.node_config.max_listeners;
    }

    /// Returns: the list of node IPs this node is connected to
    public NodeInfo getNetworkInfo () pure nothrow @safe
    {
        return NodeInfo(
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

        Instantiates a networking client to be used with the given API instance.

        Overridable in unittests.

        Returns:
            a NetworkClient

    ***************************************************************************/

    public NetworkClient getNetworkClient (TaskManager taskman,
        BanManager banman, Address address, API api, Duration retry,
        size_t max_retries)
    {
        return new NetworkClient(taskman, banman, address, api, retry,
            max_retries);
    }

    /***************************************************************************

        Gossips the transaction to all the listeners.

        Params:
            tx = the transaction to gossip

    ***************************************************************************/

    public void gossipTransaction (Transaction tx) @safe
    {
        foreach (ref node; this.peers[])
        {
            if (this.banman.isBanned(node.address))
            {
                log.trace("Not sending to {} as it's banned", node.address);
                continue;
            }

            node.sendTransaction(tx);
        }
    }

    /***************************************************************************

        Gossips the SCPEnvelope to the network of connected validators.

        Params:
            envelope = the SCPEnvelope to gossip to the network.

    ***************************************************************************/

    public void gossipEnvelope (SCPEnvelope envelope)
    {
        foreach (client; this.validators[])
        {
            if (this.banman.isBanned(client.address))
            {
                log.trace("Not sending to {} as it's banned", client.address);
                continue;
            }

            client.sendEnvelope(envelope);
        }
    }

    /***************************************************************************

        Sends the enrollment request to all the listeners.

        Params:
            enroll = the enrollment data to send

    ***************************************************************************/

    public void sendEnrollment (Enrollment enroll) @safe
    {
        foreach (ref node; this.peers[])
        {
            if (this.banman.isBanned(node.address))
            {
                log.trace("Not sending to {} as it's banned", node.address);
                continue;
            }

            node.sendEnrollment(enroll);
        }
    }

    /***************************************************************************

        Sends the pre-image to all the listeners.

        Params:
            preimage = the pre-image information to send

    ***************************************************************************/

    public void sendPreimage (PreImageInfo preimage) @safe
    {
        foreach (ref node; this.peers[])
        {
            if (this.banman.isBanned(node.address))
            {
                log.trace("Not sending to {} as it's banned", node.address);
                continue;
            }

            node.sendPreimage(preimage);
        }
    }

    /***************************************************************************

        Params:
            address = the address to check against ours

        Returns:
            true if the given address matches our own

    ***************************************************************************/

    private bool isOurOwnAddress (Address address)
    {
        return address == this.getAddress();
    }

    /***************************************************************************

        Returns:
            the address of this node (can be overriden in unittests)

    ***************************************************************************/

    protected string getAddress ()
    {
        // allocates, called infrequently though
        return format("http://%s:%s", this.node_config.address,
            this.node_config.port);
    }

    /***************************************************************************

        Instantiates a client object implementing `BlockExternalizedHandler`

        In the default implementation, this returns a `BlockExternalizedHandler`

        Params:
            address = The address (IPv4, IPv6, hostname) of target Server
        Returns:
            A BlockExternalizedHandler to communicate with the server
            at `address`

    ***************************************************************************/

    public BlockExternalizedHandler getBlockExternalizedHandler
        (Address address)
    {
        import vibe.http.client;

        auto settings = new RestInterfaceSettings;
        settings.baseURL = URL(address);
        settings.httpClientSettings = new HTTPClientSettings;
        settings.httpClientSettings.connectTimeout = this.node_config.timeout;
        settings.httpClientSettings.readTimeout = this.node_config.timeout;

        return new RestInterfaceClient!BlockExternalizedHandler(settings);
    }

    /***************************************************************************

        Instantiates a client object implementing `PreImageReceivedHandler`

        In the default implementation, this returns a `PreImageReceivedHandler`

        Params:
            address = The address (IPv4, IPv6, hostname) of target Server
        Returns:
            A PreImageReceivedHandler to communicate with the server
            at `address`

    ***************************************************************************/

    public PreImageReceivedHandler getPreimageReceivedHandler
        (Address address)
    {
        import vibe.http.client;

        auto settings = new RestInterfaceSettings;
        settings.baseURL = URL(address);
        settings.httpClientSettings = new HTTPClientSettings;
        settings.httpClientSettings.connectTimeout = this.node_config.timeout;
        settings.httpClientSettings.readTimeout = this.node_config.timeout;

        return new RestInterfaceClient!PreImageReceivedHandler(settings);
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
        log.info("DNS: contacting seed '{}'..", host);
        foreach (addr_info; getAddressInfo(host))
        {
            log.trace("DNS: checking address {}", addr_info);
            if (addr_info.family != AddressFamily.INET &&
                addr_info.family != AddressFamily.INET6)
            {
                log.trace("DNS: rejected non-IP family {}", addr_info.family);
                continue;
            }

            // we only support TCP for now
            if (addr_info.protocol != ProtocolType.TCP)
            {
                log.trace("DNS: rejected non-TCP node {}", addr_info);
                continue;
            }

            // if the port is set to zero, assume default Boa port
            auto ip = addr_info.address.to!string.replace(":0", ":2826");
            log.info("DNS: accepted IP {}", ip);
            resolved_ips.put(ip);
        }
    }
    catch (Exception ex)
    {
        log.error("Error contacting DNS seed: {}", ex.message);
    }

    return resolved_ips;
}
