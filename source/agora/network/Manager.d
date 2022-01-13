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
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.Manager;

import agora.api.Handlers;
import agora.api.Registry;
import agora.api.Validator;
import agora.api.FullNode;
import agora.common.BanManager;
import agora.common.Types;
import agora.common.ManagedDatabase;
import agora.common.Set;
import agora.common.Task;
import agora.consensus.data.Block;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXO;
import agora.consensus.data.ValidatorBlockSig;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.network.Clock;
import agora.network.Client;
import agora.network.DNSResolver;
import agora.network.RPC;
import agora.node.Config;
import agora.node.Registry : NameRegistry;
import agora.consensus.Ledger;
import agora.utils.InetUtils;
import agora.utils.Log;
import agora.utils.Utility;

import vibe.http.client;
import vibe.http.common;
import vibe.web.rest;
import vibe.inet.url;

import std.algorithm;
import std.array;
import std.container : DList;
import std.datetime.stopwatch;
import std.exception;
import std.format;
import std.random;
import std.range;

import core.stdc.time;
import core.time;

/// Ditto
public class NetworkManager
{
    /// Node information
    public static struct NodeConnInfo
    {
        /// Hash of the output used as collateral, only set if the node is a Validator
        public Hash utxo () const scope @safe pure nothrow @nogc
        {
            return this.client.identity.utxo;
        }

        /// PublicKey of the node. TODO: Remove and just use utxo.
        public PublicKey key () const scope @safe pure nothrow @nogc
        {
            return this.client.identity.key;
        }

        /// Client
        NetworkClient client;

        ///
        public bool isAuthenticated () const scope @safe pure nothrow @nogc
        {
            return this.key != PublicKey.init;
        }
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
        public alias OnHandshakeComplete = void delegate (
            in Address, agora.api.Validator.API, in Hash, in PublicKey);
        /// Ditto
        private OnHandshakeComplete onHandshakeComplete;

        /// Called when a request to a node fails.
        /// The delegate should return true if we should continue trying
        /// to send requests to this node, or false (e.g. if the node is banned)
        private bool delegate (in Address) onFailedRequest;

        ///
        private agora.api.Validator.API api;

        /***********************************************************************

            Ctor

            Params:
                address = the adddress of the node
                onHandshakeComplete = called when we've successfully connected
                                      and determined the type of the Node
                onFailedRequest = called when a request fails, returns true
                                  if we should keep trying to send requests

        ***********************************************************************/

        public this (Address address,
            OnHandshakeComplete onHandshakeComplete,
            bool delegate (in Address address) onFailedRequest)
            @safe pure nothrow @nogc
        {
            this(address, null, onHandshakeComplete, onFailedRequest);
        }

        public this (Address address, agora.api.Validator.API api,
            OnHandshakeComplete onHandshakeComplete,
            bool delegate (in Address address) onFailedRequest)
            @safe pure nothrow @nogc
        {
            this.address = address;
            this.api = api;
            this.onHandshakeComplete = onHandshakeComplete;
            this.onFailedRequest = onFailedRequest;
        }

        /***********************************************************************

            Start the connection task

        ***********************************************************************/

        public void start () nothrow
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

        private void connect () nothrow
        {
            try
                this.connect_canthrow();
            catch (Exception exc)
                log.error("Unexpected exception while contacting {}: {}",
                          this.address, exc);
        }

        /// Ditto, just behind a trampoline to avoid function-wide try/catch
        private void connect_canthrow ()
        {
            if (this.api is null)
                this.api = this.outer.getClient(this.address);

            PublicKey key;
            Hash utxo;
            while (1)
            {
                try
                {
                    import agora.flash.OnionPacket : generateSharedSecret;
                    import libsodium.crypto_auth;

                    const ephemeral_kp = KeyPair.random();
                    auto id = this.api.handshake(ephemeral_kp.address);

                    // No identity, either a full node or not enrolled
                    if (id.key == PublicKey.init)
                        break;

                    Hash shared_sec = generateSharedSecret(true,
                        ephemeral_kp.secret, id.key).hashFull();
                    static assert(shared_sec.sizeof >= crypto_auth_KEYBYTES);

                    if (id.mac.length != crypto_auth_KEYBYTES ||
                        crypto_auth_verify(id.mac.ptr, id.key[].ptr,
                            id.key[].length, shared_sec[].ptr) != 0)
                    {
                        this.outer.banman.ban(this.address);
                        return;
                    }

                    utxo = id.utxo;
                    key = id.key;
                    break;
                }
                catch (Exception ex)
                {
                    if (!this.onFailedRequest(this.address))
                        return;

                    // else try again
                    this.outer.taskman.wait(this.outer.config.node.retry_delay);
                }
            }

            if (key != PublicKey.init)
            {
                if (this.address !is Address.init
                    && key == this.outer.config.validator.key_pair.address)
                {
                    // either we connected to ourself, or someone else is pretending
                    // to be us
                    this.outer.connection_tasks.remove(address);
                    this.outer.banman.ban(address);
                    return;
                }
            }

            this.onHandshakeComplete(this.address, this.api, utxo, key);
        }
    }

    /// Logger instance
    protected Logger log;

    /// Config instance
    protected const Config config = Config.init;

    /// Task manager
    private ITaskManager taskman;

    /// Connection tasks for the nodes we're trying to connect to
    protected ConnectionTask[Address] connection_tasks;

    /// All connected nodes (Validators & FullNodes)
    public DList!NodeConnInfo peers;

    /// All known addresses so far (used for getNodeInfo())
    protected Set!Address known_addresses;

    /// The list of addresses we have not yet tried to connect to
    protected Set!Address todo_addresses;

    /// For a Validator, NodeInfo.state will be Complete only
    /// if it has connected to all of its quorum peers.
    /// See 'minPeersConnected'
    private Set!Hash required_peers;

    /// Current quorum set
    private Set!Hash quorum_set_keys;

    /// Address ban manager
    protected BanManager banman;

    /// Clock instance
    protected Clock clock;

    /// Registry client
    private NameRegistryAPI registry_client;

    /// Maximum connection tasks to run in parallel
    private enum MaxConnectionTasks = 10;

    protected agora.api.FullNode.API owner_node;

    /// Ctor
    public this (in Config config, ManagedDatabase cache, ITaskManager taskman, Clock clock, agora.api.FullNode.API owner_node)
    {
        this.log = Logger(__MODULE__);
        this.taskman = taskman;
        this.config = config;
        this.banman = this.makeBanManager(config.banman, clock, cache);
        this.clock = clock;
        this.owner_node = owner_node;

        // add the IP seeds
        this.addAddresses(Set!Address.from(config.network));

        // add the DNS seeds
        if (config.dns_seeds.length > 0)
            this.addAddresses(resolveDNSSeeds(config.dns_seeds, this.log));
    }

    /// Returns an already instantiated version of the BanManager
    /// (please also see `NetworkManager.getBanMananger()`)
    public BanManager getBanManager () @safe @nogc nothrow pure
    {
        return this.banman;
    }

    /// Called after a node's handshake is complete
    private void onHandshakeComplete (
        in Address address, agora.api.Validator.API api,
        in Hash utxo, in PublicKey key)
    {
        auto client = new NetworkClient(this.taskman, this.banman,
            this.config.node.retry_delay, this.config.node.max_retries);
        if (!client.merge(address, api))
            assert(0);

        NodeConnInfo node = {
            client : client
        };

        log.dbg("onHandshakeComplete: addresses: {}", client.addresses());
        client.connections.each!(conn => this.connection_tasks.remove(address));
        if (this.tryMerge(node))
        {
            this.required_peers.remove(utxo);
            return;
        }
        if (this.peerLimitReached())
            return;

        if (!client.connections.any!(conn => address == Address.init))
        {
            this.peers.insertBack(node);

            if (key !is PublicKey.init)
            {
                log.info("Found new Validator: {} (UTXO: {}, key: {})",
                         client.addresses(), utxo, key);
                this.required_peers.remove(utxo);
                client.setIdentity(utxo, key);
            }
            else
                log.info("Found new FullNode: {}", client.addresses());
        }
        else // unidentified connection that we can not merge, just use it for a single shot of address discovery
        {
            log.dbg("onHandshakeComplete: an unidentified connection was included");
            auto node_info = client.getNodeInfo();
            this.addAddresses(node_info.addresses);
        }
    }

    ///
    private bool tryMerge (scope ref NodeConnInfo node)
    {
        auto existing_peers = this.peers[].find!(p => p.key == node.key);
        if (!node.isAuthenticated() || existing_peers.empty())
            return false;

        assert(node.client.connections.length == 1);
        existing_peers.front().client.setIdentity(node.utxo, node.key);
        existing_peers.front().client.merge(node.client.connections[0].tupleof);
        return true;
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
            threshold = The threshold of responses to expect (see `Returns`)
            time_offest = will contain the offset that should be applied to the
                          clock's local time to get the median clock time of the
                          node's quorum nodes (zero if return value is false)

        Returns:
            true if at least `threshold` nodes in our quorum set have
            sent us their clock time information

    ***************************************************************************/

    public bool getNetTimeOffset (uint threshold, out Duration time_offset)
        @safe nothrow
    {
        // contains a node's clock time and the calculated drift time
        static struct TimeInfo
        {
            PublicKey key;
            TimePoint node_time;
            long req_delay;
            Duration offset;
        }

        static TimeInfo[] offsets;
        offsets.length = 0;
        () @trusted { assumeSafeAppend(offsets); }();
        // must include our own assumed clock drift (zero)
        offsets ~= TimeInfo(this.config.validator.key_pair.address,
            this.clock.localTime());

        foreach (node; this.validators())
        {
            if (node.utxo !in this.quorum_set_keys)
                continue;

            const req_start = this.clock.localTime();
            const node_time = node.client.getLocalTime();
            if (node_time == 0)
                continue;  // request failed

            const req_delay = this.clock.localTime() - req_start;
            const dist_delay = req_delay / 2;  // divide evently
            const offset = (node_time - dist_delay) - req_start;
            offsets ~= TimeInfo(node.key, node_time, req_delay, offset.seconds);
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
    public ITimer startPeriodicNameRegistration ()
    {
        // No configured registry, nothing to do
        if (this.config.node.registry_address.length == 0)
            return null;

        this.registry_client = this.getRegistryClient(
            this.config.node.registry_address);

        this.onRegisterName();  // avoid delay
        // We re-register at regular interval in order to cope with the situation below
        // 1. network registry server is restarted
        // 2. client running agora node acquired some new IPs
        return this.taskman.setTimer(
            this.config.validator.name_registration_interval,
            &this.onRegisterName, Periodic.Yes);
    }

    /// Discover the network, connect to all required peers
    /// Some nodes may want to connect to specific peers before
    /// discovery() is considered complete
    public void discover (NameRegistry registry, UTXO[Hash] last_known_validator_utxos,
        UTXO[Hash] required_peer_utxos = null) nothrow
    {
        this.quorum_set_keys.from(Set!Hash.init);
        this.required_peers.from(Set!Hash.init);

        foreach (peer; required_peer_utxos.byKeyValue)
        {
            this.quorum_set_keys.put(peer.key);
            if (!this.peers[].map!(ni => ni.utxo).canFind(peer.key))
                this.required_peers.put(peer.key);
        }

        log.info(
            "Doing periodic network discovery: {} required peers requested, {} missing, known {}",
            required_peer_utxos.length, this.required_peers.length, last_known_validator_utxos.length);

        if (this.registry_client !is null)
        {
            foreach (utxo; last_known_validator_utxos.byKeyValue)
            if (!this.peers[].map!(ni => ni.utxo).canFind(utxo.key))
            {
                auto key = utxo.value.output.address;
                // Do not query the registry about ourself
                if (key == this.config.validator.key_pair.address)
                    continue;

                taskman.runTask
                ({
                    // https://github.com/bosagora/agora/issues/2197
                    const ckey = key;
                    retry!
                    ({
                        auto payload = this.registry_client.getValidator(ckey);
                        if (payload == RegistryPayload.init)
                        {
                            log.warn("Could not find mapping in registry for key {}", ckey);
                            return false;
                        }

                        if (payload.data.public_key != ckey)
                        {
                            log.error("Registry answered with the wrong key: {} => {}",
                                      ckey, payload);
                            return false;
                        }

                        foreach (addr; payload.data.addresses)
                            this.addAddress(addr);
                        return true;
                    },
                    )(taskman, 3, 2.seconds, "Exception happened while trying to get validator addresses");
                });
            }
        }

        /// Returns: true if we should keep trying to connect to an address,
        /// else false if the address was banned
        bool onFailedRequest (in Address address) nothrow
        {
            if (this.banman.isBanned(address))
            {
                this.connection_tasks.remove(address);
                return false;
            }

            return true;
        }

        try
        {
            foreach (addr; registry.validatorsAddresses())
                this.addAddress(addr);
        }
        catch (Exception ex)
            log.info("Cannot fetch validator addresses from our registry {}",
                ex);

        while (this.todo_addresses.length)
        {
            if (this.connection_tasks.length >= MaxConnectionTasks)
            {
                log.info("Connection task limit reached. Will trying again in {}..",
                    this.config.node.network_discovery_interval);
                break;
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

        Check if we should connect with the given address.
        If the address is banned, already connected, or already queued
        for a connection then return false.

        Params:
            address = the address to check

        Returns:
            true if we should establish connection to this address

    ***************************************************************************/

    private bool shouldEstablishConnection (Address address) @safe
    {
        auto existing_peer = this.peers[].find!(p => p.client.addresses.canFind(address));
        return !this.banman.isBanned(address) &&
            address !in this.connection_tasks &&
            address !in this.todo_addresses &&
            (existing_peer.empty || // either does not exist or a validator with no stake
                (existing_peer.front.isAuthenticated() && existing_peer.front.utxo == Hash.init));
    }

    /// Received new set of addresses, put them in the todo address list
    private void addAddresses (Set!Address addresses) @safe
    {
        foreach (address; addresses)
            this.addAddress(address);
    }

    /// Ditto
    private void addAddress (Address address) @safe
    {
        if (this.shouldEstablishConnection(address))
            this.todo_addresses.put(address);

        // We include banned addresses in known address,
        // because while *we* cannot establish a connection with
        // a node it's possible other nodes in the network might be able to.
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

    protected BanManager makeBanManager (in BanManager.Config banman_conf,
        Clock clock, ManagedDatabase cache)
    {
        return new BanManager(banman_conf, clock, cache);
    }

    /***************************************************************************

        Returns an instance of a DNSResolver

        Params:
            peers = Addresses of DNS servers that Resolver will send queries to
                    If none / `null` is provided, default to the list of
                    configured registries.

        Returns:
            A newly instantiated `DNSResolver` with the provided `peers`

    ***************************************************************************/

    public DNSResolver makeDNSResolver (Address[] peers = null)
    {
        if (peers.length == 0)
            peers = [ Address(this.config.node.registry_address) ];
        return new VibeDNSResolver(peers);
    }

    /// register network addresses into the name registry
    public void onRegisterName () @safe
    {
        const(Address)[] addresses = this.config.validator.addresses_to_register;
        if (!addresses.length)
            addresses = InetUtils.getPublicIPs().map!(
                ip => Address("agora://"~ip)
            ).array;
        this.addAddresses(Set!Address.from(addresses));

        if (this.registry_client is null)
            return;

        RegistryPayload payload =
        {
            data:
            {
                public_key : this.config.validator.key_pair.address,
                addresses : addresses,
                seq : time(null)
            }
        };

        payload.signPayload(this.config.validator.key_pair);

        try
        {
            this.registry_client.postValidator(payload);
        }
        catch (Exception ex)
        {
            log.info("Couldn't register our address: {}. Trying again later..",
                ex);
        }
    }

    /***************************************************************************

        Returns:
          A range of peers which are validators. Each element of the range
          contains a `PublicKey key` and a `NetworkClient client` member.

    ***************************************************************************/

    public auto validators () return @safe nothrow pure
    {
        return this.peers[].filter!(p => p.isAuthenticated());
    }

    /***************************************************************************

        Retrieve blocks starting from height up to the highest block
        that's available from the connected nodes.

        As requests may fail, this function should be called with a timer
        to ensure consistency of the node's ledger with other nodes.

        Params:
            height = the starting block height to begin retrieval from
            onReceivedBlocks = delegate to call with the received blocks
                               if it returns false, further processing of blocks
                               from the same node is rejected due to invalid
                               block data.

    ***************************************************************************/

    public void getBlocksFrom (Height height,
        scope Height delegate(const(Block)[]) @safe onReceivedBlocks) nothrow
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

        this.peers[]
            .map!(node => Pair(getHeight(node.client), node.client))
            .filter!(pair => pair.height != ulong.max)  // request failed
            .each!(pair => node_pairs ~= pair);

        node_pairs.sort!((a, b) => a.height > b.height);

        foreach (pair; node_pairs)
        {
            if (height > pair.height)
                continue;  // this node does not have newer blocks than us

            log.info("Retrieving blocks [{}..{}] from {}..",
                height, pair.height, pair.client.addresses);
            const MaxBlocks = 1024;
            auto blocks = pair.client.getBlocksFrom(height, MaxBlocks);
            if (blocks.length == 0)
                continue;

            log.info("Received blocks [{}..{}]",
                blocks[0].header.height, blocks[$ - 1].header.height);

            try
            {
                // update the height with the latest accepted height
                const new_height = onReceivedBlocks(blocks);
                if (new_height >= height)
                    height = new_height + 1;
            }
            catch (Exception ex)
            {
                // @BUG: Ledger routines should be marked nothrow,
                // or else storage issues should be handled differently.
                log.error("Error in onReceivedBlocks(): {}", ex);
            }
        }
    }

    /***************************************************************************

        Try to retrieve TXs that this node does not have in its pool but
        have seen the hash in nominations

        Params:
            ledger = Ledger instance

    ***************************************************************************/

    public void getUnknownTXs (NodeLedger ledger) @safe nothrow
    {
        auto unknown_txs = ledger.getUnknownTXHashes();
        log.trace("getUnknownTXs: detected {} unknown txs", unknown_txs.length);

        foreach (peer; this.peers[])
        {
            if (unknown_txs.length == 0)
                break;

            // Fetch transactions in chunks
            auto hashes = unknown_txs[].map!((Hash h) => h).array; // can not be lazy so use array
            auto added = hashes.chunks(8)
                .map!(chunk => Set!Hash.from(chunk))
                .map!(hash_chunk => peer.client.getTransactions(hash_chunk))
                .map!(txs => addTxs(ledger, txs))
                .sum();
            log.trace("getUnknownTXs: Added {} txs to tx pool", added);
            unknown_txs = ledger.getUnknownTXHashes();
        }
    }

    // Add the chunk of txs fetched from the other node
    private size_t addTxs (NodeLedger ledger, Transaction[] txs) @safe nothrow
    {
        auto accepted = 0;
        txs.each!((tx)
        {
            try
            {
                ledger.acceptTransaction(tx); // This will also remove it from unknown_txs
                log.trace("getUnknownTXs: Found unknown tx with hash {}", tx.hashFull());
            }
            catch (Exception e)
            {
                log.warn("getUnknownTXs: Unknown TX {} threw {}", tx, e.msg);
            }
            accepted++;
        });
        return accepted;
    }

    /***************************************************************************

        Retrieve any missing block signatures from the connected nodes for
        blocks since the last fee payment block.

    ***************************************************************************/

    public void getMissingBlockSigs (Ledger ledger,
        scope void delegate(const(BlockHeader)) @safe acceptHeader) @safe nothrow
    {
        import std.algorithm;
        import std.conv;
        import std.range;
        import std.typecons;

        size_t[Height] signed_validators;

        try
        {
            auto start_height = ledger.getLastPaidHeight();
            auto headers = ledger.getBlocksFrom(start_height).map!(block => block.header);
            size_t[Height] enrolled_validators = headers.map!(header =>
                tuple(header.height, header.validators.count)).assocArray;

            Set!ulong heightsMissingSigs ()
            {
                signed_validators =
                    headers.map!(header =>
                        tuple(header.height,
                            iota(0, enrolled_validators[header.height]).filter!(i =>
                                header.validators[i] || header.preimages[i] is Hash.init).count() // Take into account the slashed validators
                        )
                    ).assocArray;

                return Set!ulong.from(headers.map!(h => h.height).filter!(height => signed_validators[height] < enrolled_validators[height]));
            }

            void doCatchUp ()
            {
                auto missing_heights = heightsMissingSigs();
                if (!missing_heights.empty)
                {
                    log.trace("getMissingBlockSigs: detected missing signatures at heights {}", missing_heights);
                    foreach (peer; this.peers[])
                    {
                        foreach (header; peer.client.getBlockHeaders(missing_heights))
                        {
                            auto sig_signed_validators = iota(enrolled_validators[header.height]).filter!(i =>
                                header.validators[i] || header.preimages[i] is Hash.init).count();
                            if (sig_signed_validators > signed_validators[header.height])
                            {
                                try
                                {
                                    log.trace("getMissingBlockSigs: updating header signature: {} validators: {}", header.signature, header.validators);
                                    acceptHeader(header);
                                }
                                catch (Exception e)
                                {
                                    log.error("getMissingBlockSigs: Exception thrown updating block signature at height {}: {}", header.height, e.msg);
                                }
                            }
                        }
                        missing_heights = heightsMissingSigs();
                        if (missing_heights.empty)
                            break;
                    }
                }
            }

            // Check last and recent_block_count blocks before last
            doCatchUp();

        }
        catch (Exception e)
        {
            log.error("getMissingBlockSigs: Exception thrown : {}", e.msg);
        }
    }

    /// Shut down timers & dump the metadata
    public void shutdown () @trusted
    {
        foreach (peer; this.peers)
            peer.client.shutdown();
    }

    ///
    private bool minPeersConnected () nothrow @safe
    {
        log.dbg("minPeersConnected: missing = {}, peers = {}, min = {}",
            this.required_peers.length, this.peers[].walkLength, this.config.node.min_listeners);

        // We need to establish connections to all peers we were explicitly asked for
        if (this.required_peers.length)
            return false;

        // We need to establish a minimum number of connections
        if (this.peers[].walkLength < this.config.node.min_listeners)
            return false;

        // We don't have an authenticated peer where all the addresses are banned
        return this.validators().filter!(
            node => !node.client.addresses.all!(addr => this.banman.isBanned(addr)))
            .count != 0;
    }

    private bool peerLimitReached ()  nothrow @safe
    {
        return this.required_peers.length == 0 &&
            this.peers[].filter!(node =>
                !node.client.addresses.all!(addr => this.banman.isBanned(addr))).count >= this.config.node.max_listeners &&
            this.validators().filter!(node =>
                !node.client.addresses.all!(addr => this.banman.isBanned(addr))).count != 0;
    }

    /// Returns: the list of node IPs this node is connected to
    public NodeInfo getNetworkInfo () nothrow @safe
    {
        return NodeInfo(
            this.minPeersConnected()
                ? NetworkState.Complete : NetworkState.Incomplete,
            this.known_addresses);
    }

    /***************************************************************************

        Instantiates a client object implementing `API`

        This function simply returns a client object implementing `API`.
        In the default implementation, this returns either an `RPCClient`
        or a `RestInterfaceClient` according to the address schema.
        However, it can be overriden in test code to return an in-memory client.

        Params:
          address = The address (IPv4, IPv6, hostname) of this node

        Returns:
          An object to communicate with the node at `address`

    ***************************************************************************/

    protected agora.api.Validator.API getClient (Address url)
    {
        import std.algorithm.searching;

        const timeout = this.config.node.timeout;
        if (url.schema == "agora")
        {
            auto owner_validator = cast (agora.api.Validator.API) this.owner_node;

            return owner_validator ?
                new RPCClient!(agora.api.Validator.API)(
                url.host, url.port,
                /* Disabled, we have our own method: */ 0.seconds, 1,
                timeout, timeout, timeout, 3 /* Hard coded max tcp connections*/,
                owner_validator)
                :
                new RPCClient!(agora.api.Validator.API)(
                url.host, url.port,
                /* Disabled, we have our own method: */ 0.seconds, 1,
                timeout, timeout, timeout, 3 /* Hard coded max tcp connections*/,
                this.owner_node);
        }

        if (url.schema.startsWith("http"))
        {
            auto settings = new RestInterfaceSettings;
            settings.baseURL = url;
            settings.httpClientSettings = new HTTPClientSettings;
            settings.httpClientSettings.connectTimeout = timeout;
            settings.httpClientSettings.readTimeout = timeout;
            settings.httpClientSettings.proxyURL = this.config.proxy.url;
            return new RestInterfaceClient!(agora.api.Validator.API)(settings);
        }
        assert(0, "Unknown agora schema");
    }

    /***************************************************************************

        Instantiates a client object implementing `NameRegistryAPI`

        This function simply returns a name registry object implementing
        `NameRegistryAPI`. In the default implementation, this returns a
        `RestInterfaceClient`. However, it can be overriden in test code to
        return an in-memory client.

        Params:
          address = The address of the name registry server

        Returns:
          An object to communicate with the name registry server

    ***************************************************************************/

    public NameRegistryAPI getRegistryClient (string address)
    {
        auto settings = new RestInterfaceSettings();
        settings.baseURL = Address(address);
        settings.httpClientSettings = new HTTPClientSettings();
        settings.httpClientSettings.connectTimeout = this.config.node.timeout;
        settings.httpClientSettings.readTimeout = this.config.node.timeout;
        settings.httpClientSettings.proxyURL = this.config.proxy.url;

        return new RestInterfaceClient!NameRegistryAPI(settings);
    }

    /***************************************************************************

        Gossips the ValidatorBlockSig to the network of connected validators.

        Params:
            block_sig = the Validator Block Signature to gossip to the network.

    ***************************************************************************/

    public void gossipBlockSignature (ValidatorBlockSig block_sig) @safe nothrow
    {
        log.trace("Gossip block signature {} for height #{} node {}",
            block_sig.signature, block_sig.height , block_sig.utxo);
        this.validators().each!(v => v.client.sendBlockSignature(block_sig));
    }

    /***************************************************************************

        Instantiates a client object implementing the `BlockExternalizedHandler`

        Params:
            address = The address (IPv4, IPv6, hostname) of target Server
        Returns:
            A Handler to communicate with the server at `address`

    ***************************************************************************/

    public BlockExternalizedHandler getBlockExternalizedHandler (Address address)
    {
        return new RestInterfaceClient!BlockExternalizedHandler(getRestInterfaceSettings(address));
    }

    /***************************************************************************

        Instantiates a client object implementing the `BlockHeaderUpdatedHandler`

        Params:
            address = The address (IPv4, IPv6, hostname) of target Server
        Returns:
            A Handler to communicate with the server at `address`

    ***************************************************************************/

    public BlockHeaderUpdatedHandler getBlockHeaderUpdatedHandler (Address address)
    {
        return new RestInterfaceClient!BlockHeaderUpdatedHandler(getRestInterfaceSettings(address));
    }

    /***************************************************************************

        Instantiates a client object implementing the `PreImageReceivedHandler`

        Params:
            address = The address (IPv4, IPv6, hostname) of target Server
        Returns:
            A Handler to communicate with the server at `address`

    ***************************************************************************/

    public PreImageReceivedHandler getPreImageReceivedHandler(Address address)
    {
        return new RestInterfaceClient!PreImageReceivedHandler(getRestInterfaceSettings(address));
    }

    /***************************************************************************

        Instantiates a client object implementing the `TransactionReceivedHandler`

        Params:
            address = The address (IPv4, IPv6, hostname) of target Server
        Returns:
            A Handler to communicate with the server at `address`

    ***************************************************************************/

    public TransactionReceivedHandler getTransactionReceivedHandler (Address address)
    {
        return new RestInterfaceClient!TransactionReceivedHandler(getRestInterfaceSettings(address));
    }

    private RestInterfaceSettings getRestInterfaceSettings (Address address)
    {
        auto settings = new RestInterfaceSettings;
        settings.baseURL = address;
        settings.httpClientSettings = new HTTPClientSettings;
        settings.httpClientSettings.connectTimeout = this.config.node.timeout;
        settings.httpClientSettings.readTimeout = this.config.node.timeout;
        settings.httpClientSettings.proxyURL = this.config.proxy.url;
        return settings;
    }

    /***************************************************************************

        Whitelist a Hash of a UTXO to avoid banning it

        Params:
            hash = the Hash of the UTXO to whitelist

    ***************************************************************************/

    public void whitelist (Hash utxo)
    {
        this.peers[].filter!(p => p.utxo == utxo)
            .each!(p => p.client.addresses.each!(addr => this.banman.whitelist(addr)));
    }

    /***************************************************************************

        Unwhitelist a Hash of a UTXO to allow banning it

        Params:
            key = hash = the Hash of the UTXO to unwhitelist

    ***************************************************************************/

    public void unwhitelist (Hash utxo)
    {
        this.peers[].filter!(p => p.utxo == utxo)
            .each!(p => p.client.addresses.each!(addr => this.banman.unwhitelist(addr)));
    }

    ///
    public void discoverFromClient (agora.api.Validator.API api) @trusted nothrow
    {
        new ConnectionTask(Address.init, api, &onHandshakeComplete,
                           (in Address _) { return false; }).start();
    }
}

/*******************************************************************************

    Resolves IPs out of a list of DNS seeds

    Params:
        addresses = the set of DNS seeds

    Returns:
        The resolved set of IPs

*******************************************************************************/

private Set!Address resolveDNSSeeds (in string[] dns_seeds, ref Logger log)
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

            // if the port is set to zero, assume default Boa schema
            auto ip = "agora://" ~ addr_info.address.to!string;
            log.info("DNS: accepted IP {}", ip);
            resolved_ips.put(Address(ip));
        }
    }
    catch (Exception ex)
    {
        log.error("Error contacting DNS seed: {}", ex.message);
    }

    return resolved_ips;
}
