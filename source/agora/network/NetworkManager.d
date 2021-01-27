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
import agora.api.handler.TransactionReceivedHandler;
import agora.common.BanManager;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.ValidatorBlockSig;
import agora.common.crypto.Key;
import agora.common.Config;
import agora.common.Types;
import agora.common.Metadata;
import agora.common.Set;
import agora.common.Task;
import agora.common.Hash;
import agora.consensus.data.Transaction;
import agora.network.Clock;
import agora.network.NetworkClient;
import agora.node.Ledger;
import agora.registry.NameRegistryAPI;
import agora.utils.InetUtils;
import agora.utils.Log;
import agora.utils.Utility;

import scpd.types.Stellar_SCP;

import vibe.http.common;
import vibe.web.rest;

import std.algorithm;
import std.array;
import std.container : DList;
import std.datetime.stopwatch;
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
        /// A queue of clients. Each client is contacted, and pushed back to the
        /// queue (unless they were banned)
        private DList!NetworkClient clients;

        /// Convenience alias
        public alias Callback = void delegate (Set!Address addresses);

        /// Called when we have retrieved a set of addresses from a client
        private Callback onNewAddresses;

        // workaround to only run this task once
        // (cannot run it in the ctor as the scheduler may not be running yet)
        // todo: move it to the ctor once we have `schedule` implemented.
        private bool is_running;

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
            if (!this.is_running)
            {
                this.is_running = true;
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
                    this.outer.taskman.wait(this.outer.node_config.retry_delay);

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
    public const NodeConfig node_config = NodeConfig.init;

    /// Validator instance
    protected const ValidatorConfig validator_config = ValidatorConfig.init;

    /// Task manager
    private TaskManager taskman;

    /// Never-ending address discovery task
    protected AddressDiscoveryTask discovery_task;

    /// Connection tasks for the nodes we're trying to connect to
    protected ConnectionTask[Address] connection_tasks;

    /// List of validator clients
    protected DList!NetworkClient validators;

    /// All connected nodes (Validators & FullNodes)
    public DList!NodeConnInfo peers;

    /// Easy lookup of currently connected peers
    protected Set!Address connected_peers;

    /// Keeps track of Validator keys we're already connected to
    private Set!PublicKey connected_validator_keys;

    /// All known addresses so far (used for getNodeInfo())
    protected Set!Address known_addresses;

    /// The list of addresses we have not yet tried to connect to
    protected Set!Address todo_addresses;

    /// For a Validator, NodeInfo.state will be Complete only
    /// if it has connected to all of its quorum peers.
    /// See 'minPeersConnected'
    private Set!PublicKey required_peer_keys;

    /// Current quorum set
    private Set!PublicKey quorum_set_keys;

    /// Address ban manager
    protected BanManager banman;

    ///
    private Metadata metadata;

    /// Clock instance
    protected Clock clock;

    /// Registry client
    private NameRegistryAPI registry_client;

    /// Maximum connection tasks to run in parallel
    private enum MaxConnectionTasks = 10;

    /// Ctor
    public this (in Config config, Metadata metadata, TaskManager taskman, Clock clock)
    {
        this.taskman = taskman;
        this.node_config = config.node;
        this.validator_config = config.validator;
        this.metadata = metadata;
        this.banman = this.getBanManager(config.banman, clock,
            node_config.data_dir);
        this.discovery_task = new AddressDiscoveryTask(&this.addAddresses);
        this.clock = clock;
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
            this.addAddresses(Set!Address.from(config.network));

            // add the DNS seeds
            if (config.dns_seeds.length > 0)
                this.addAddresses(resolveDNSSeeds(config.dns_seeds));
        }
    }

    /// Returns an already instantiated version of the BanManager
    /// (please also see `NetworkManager.getBanMananger()`)
    public BanManager getAlreadyCreatedBanManager () @safe @nogc nothrow pure
    {
        return this.banman;
    }

    /// Called after a node's handshake is complete
    private void onHandshakeComplete (scope ref NodeConnInfo node)
    {
        this.connected_peers.put(node.address);
        this.peers.insertBack(node);

        if (node.is_validator)
        {
            this.validators.insertBack(node.client);
            this.required_peer_keys.remove(node.key);
            this.connected_validator_keys.put(node.key);
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

    /***************************************************************************

        Retrieve the clock time of each node in the given quorum set,
        and return the median time.

        The threshold is taken into account.

        Taking request / response delays into account:
        ==============================================

        We cannot assume why a getLocalTime() request response was late.
        Assume N1 and N2 are two nodes and the time is 10:00:00 at both nodes.
        An 'upstream' delay means a request delay from N1 -> N2,
        and a 'downstream' response is the delay from N2 -> N1:

        1 second delay:

        10:00:00 N1 -> N2.getLocalTime() (10:00:01)
        10:00:01 N1 <- 10:00:01
        A: Received 10:00:01 at 10:00:01 with a 1 second delay

        15-second delay upstream, no delay downstream:
        10:00:00 N1 -> N2.getLocalTime()  (10:00:15)
        10:00:15 N1 <- 10:00:15
        B: Received 10:00:15 at 10:00:15 with a 15 second delay

        No delay upstream, 15-second delay downstream:
        10:00:00 N1 -> N2.getLocalTime() (10:00:00)
        10:00:15 N1 <- 10:00:00
        C: Received 10:00:00 at 10:00:15 with a 15 second delay

        If we were to just take the total request time into account then the
        calculated time would be:

        A: Received 10:00:01 - 1s delay  => It was 10:00:00 at the start.
        B: Received 10:00:15 - 15s delay => It was 10:00:00 at the start.
        C: Received 10:00:00 - 15s delay => It was 10:59:45 at the start.

        The C calculation is wrong. We assumed N2 received the request late,
        but it was the response to N1 that was delayed.

        To compensate:

        - We set the request timeout to a low value. Limiting it to a small
          value allows for more accurate drift time calculations.

        - We divide the resulting time drift by 2. This essentially splits the
          time drift evenly between upstream and downstream and assumes
          that there is an equal delay between sending a request and receiving a
          response. Most of the time this will be a correct assumption.

        Examples:

        2-second delay upstream, no delay downstream:
        10:00:00 N1 -> N2.getLocalTime()  (10:00:02)
        10:00:02 N1 <- 10:00:02
        B: Received 10:00:02 at 10:00:02 with a 2 second delay

        No delay upstream, 2-second delay downstream:
        10:00:00 N1 -> N2.getLocalTime() (10:00:00)
        10:00:02 N1 <- 10:00:00
        C: Received 10:00:00 at 10:00:02 with a 2 second delay

        1-second delay upstream, 1-second delay downstream:
        10:00:00 N1 -> N2.getLocalTime() (10:00:01)
        10:00:02 N1 <- 10:00:01
        C: Received 10:00:01 at 10:00:02 with a 2 second delay

        Then the calculation is:

        A: Received 10:00:02 - (2s delay / 2) => It was 10:00:01 at the start.
        B: Received 10:00:00 - (2s delay / 2) => It was 10:00:01 at the start.
        C: Received 10:00:01 - (2s delay / 2) => It was 10:00:00 at the start.

        The actual times then only drift by up to `timeout / 2`, and in most
        cases where there is roughly equal delay upstream and downstream this
        time offset will be correct.

        Params:
            time_offest = will contain the offset that should be applied to the
                          clock's local time to get the median clock time of the
                          node's quorum nodes (zero if return value is false)

        Returns:
            true if at least `threshold` nodes in our quorum set have
            sent us their clock time information

    ***************************************************************************/

    public bool getNetTimeOffset (uint threshold, out long time_offset)
        @safe nothrow
    {
        // contains a node's clock time and the calculated drift time
        static struct TimeInfo
        {
            PublicKey key;
            time_t node_time;
            long req_delay;
            long offset;
        }

        static TimeInfo[] offsets;
        offsets.length = 0;
        () @trusted { assumeSafeAppend(offsets); }();
        // must include our own assumed clock drift (zero)
        offsets ~= TimeInfo(this.validator_config.key_pair.address,
            this.clock.localTime(), 0, 0);

        foreach (node; this.validators[])
        {
            // todo: cache getPublicKey()
            PublicKey pk;
            if (collectException(node.getPublicKey(), pk))
                continue;  // request failed

            if (pk !in this.quorum_set_keys)
                continue;

            const req_start = this.clock.localTime();
            const node_time = node.getLocalTime();
            if (node_time == 0)
                continue;  // request failed

            const req_delay = this.clock.localTime() - req_start;
            const dist_delay = req_delay / 2;  // divide evently
            const offset = (node_time - dist_delay) - req_start;
            offsets ~= TimeInfo(pk, node_time, req_delay, offset);
        }

        // we heard from at least one quorum slice
        if (offsets.length >= threshold)
        {
            offsets.sort!((a, b) => a.offset < b.offset);
            log.info("Net time offsets: {}", offsets);
            time_offset = offsets[$ / 2].offset;  // pick median
            return true;
        }

        // not enough time data
        return false;
    }

    /// Periodically registers network addresses
    public void startPeriodicNameRegistration ()
    {
        this.registry_client = this.getNameRegistryClient(
            this.validator_config.registry_address, 2.seconds);
        if (this.registry_client is null)
            return;

        this.onRegisterName();  // avoid delay
        // we re-register in every 2 minutes, in order to cope with the situation below
        // 1. network registry server is restarted
        // 2. client running agora node acquired some new IPs
        this.taskman.setTimer(2.minutes, &this.onRegisterName, Periodic.Yes);
    }

    /// Discover the network, connect to all required peers
    /// Some nodes may want to connect to specific peers before
    /// discovery() is considered complete
    public void discover (Set!PublicKey required_peer_keys = Set!PublicKey.init)
    {
        log.info("Doing network discovery..");

        this.quorum_set_keys = required_peer_keys;
        this.required_peer_keys = Set!PublicKey.from(
            required_peer_keys.byKey()
            .filter!(key => key !in this.connected_validator_keys));

        if (this.registry_client !is null)
        {
            foreach (key; this.required_peer_keys)
                taskman.runTask
                ({
                    retry!
                    ({
                        auto payload = this.registry_client.getValidator(key);
                        if (payload == RegistryPayload.init)
                        {
                            log.warn("Could not find mapping in registry for key {}", key);
                            return false;
                        }

                        if (!payload.verifySignature(key))
                        {
                            log.warn("RegistryPayload signature is incorrect for {}", key);
                            return false;
                        }
                        foreach (addr; payload.data.addresses)
                            this.addAddress(addr);
                        return true;
                    },
                    )(taskman, 3, 2.seconds, "Exception happened while trying to get validator addresses");
                });
        }

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

        Get a BanManager instance.

        Can be overriden in unittests to test ban management
        without relying on a clock.

        Params:
            banman_conf = ban manager config
            clock = clock instance
            data_dir = path to the data directory

        Returns:
            an instance of a BanManager

    ***************************************************************************/

    protected BanManager getBanManager (in BanManager.Config banman_conf,
        Clock clock, cstring data_dir)
    {
        return new BanManager(banman_conf, clock, data_dir);
    }

    /// register network addresses into the name registry
    private void onRegisterName ()
    {
        const(Address)[] addresses = this.validator_config.addresses_to_register;
        if (!addresses.length)
            addresses = InetUtils.getPublicIPs();

        RegistryPayload payload =
        {
            data:
            {
                public_key : this.validator_config.key_pair.address,
                addresses : addresses,
                seq : time(null)
            }
        };

        payload.signPayload(this.validator_config.key_pair.secret);

        try
        {
            this.registry_client.putValidator(payload);
        }
        catch (Exception ex)
        {
            log.info("Couldn't register our address: {}. Trying again later..",
                ex);
        }
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

    public void getBlocksFrom (Height block_height,
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
            .map!(node => Pair(getHeight(node.client), node.client))
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

    /***************************************************************************

        Retrieve blocks starting from block_height up to the highest block
        that's available from the connected nodes.

    ***************************************************************************/

    public void getUnknownTXs (Ledger ledger) @safe nothrow
    {
        auto unknown_txs = ledger.getUnknownTXHashes();

        foreach (peer; this.peers[])
        {
            if (unknown_txs.length == 0)
                break;

            foreach (tx; peer.client.getTransactions(unknown_txs))
            {
                try
                {
                    ledger.acceptTransaction(tx);
                    unknown_txs.remove(tx.hashFull());
                }
                catch (Exception e)
                {
                    log.info("Unknown TX {} threw {}", tx, e.msg);
                }
            }
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

        Instantiates a client object implementing `NameRegistryAPI`

        This function simply returns a name registry object implementing
        `NameRegistryAPI`. In the default implementation, this returns a
        `RestInterfaceClient`. However, it can be overriden in test code to
        return an in-memory client.

        Params:
          address = The address of the name registry server
          timeout = the timeout duration to use for requests

        Returns:
          An object to communicate with the name registry server

    ***************************************************************************/

    public NameRegistryAPI getNameRegistryClient (Address address, Duration timeout)
    {
        import vibe.http.client;
        if (address == "disabled")
            return null;
        auto settings = new RestInterfaceSettings();
        settings.baseURL = URL(address);
        settings.httpClientSettings = new HTTPClientSettings();
        settings.httpClientSettings.connectTimeout = timeout;
        settings.httpClientSettings.readTimeout = timeout;

        return new RestInterfaceClient!NameRegistryAPI(settings);
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

            node.client.sendTransaction(tx);
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
            client.sendEnvelope(envelope);
    }

    /***************************************************************************

        Gossips the ValidatorBlockSig to the network of connected validators.

        Params:
            block_sig = the Validator Block Signature to gossip to the network.

    ***************************************************************************/

    public void gossipBlockSignature (ValidatorBlockSig block_sig) nothrow
    {
        log.trace("Gossip block signature {} for height #{} node {}",
            block_sig.signature, block_sig.height , block_sig.public_key);
        foreach (client; this.validators[])
            client.sendBlockSignature(block_sig);
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

            node.client.sendEnrollment(enroll);
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

            node.client.sendPreimage(preimage);
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

    /***************************************************************************

        Instantiates a client object implementing `TransactionReceivedHandler`

        In the default implementation, this returns a `TransactionReceivedHandler`

        Params:
            address = The address (IPv4, IPv6, hostname) of target Server
        Returns:
            A TransactionReceivedHandler to communicate with the server
            at `address`

    ***************************************************************************/

    public TransactionReceivedHandler getTransactionReceivedHandler
        (Address address)
    {
        import vibe.http.client;

        auto settings = new RestInterfaceSettings;
        settings.baseURL = URL(address);
        settings.httpClientSettings = new HTTPClientSettings;
        settings.httpClientSettings.connectTimeout = this.node_config.timeout;
        settings.httpClientSettings.readTimeout = this.node_config.timeout;

        return new RestInterfaceClient!TransactionReceivedHandler(settings);
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
