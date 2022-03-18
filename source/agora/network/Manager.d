/*******************************************************************************

    Expose facilities used by the `Node` to communicate with the network

    The `NetworkManager` is responsible for managing the view of the network
    that a `Node` has.
    Things such as peer blacklisting, prioritization (which peer is contacted
    first when a message has to be sent), etc... are handled here.

    In unittests, one can replace a `NetworkManager` with a `TestNetworkManager`
    which provides a different client type (see `makeClient`) in order to enable
    in-memory network communication.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.Manager;

import agora.api.FullNode;
import agora.api.Handlers;
import agora.api.Registry;
import agora.api.Validator;
import agora.common.BanManager;
import agora.common.ManagedDatabase;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
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
import agora.node.Config;
import agora.node.Registry : NameRegistry;
import agora.consensus.Ledger;
import agora.utils.InetUtils;
import agora.utils.Log;
import agora.utils.Utility;

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
            this.outer.connection_tasks.remove(this.address);
        }

        /// Ditto, just behind a trampoline to avoid function-wide try/catch
        private void connect_canthrow ()
        {
            if (this.api is null)
                this.api = this.outer.makeClient(this.address);

            foreach (_; 0 .. this.outer.config.node.max_retries)
            {
                try
                {
                    import agora.flash.OnionPacket : generateSharedSecret;
                    import libsodium.crypto_auth;

                    const ephemeral_kp = KeyPair.random();
                    auto id = this.api.handshake(ephemeral_kp.address);

                    if (id.key != PublicKey.init)
                    {
                        Hash shared_sec = generateSharedSecret(true,
                            ephemeral_kp.secret, id.key).hashFull();
                        static assert(shared_sec.sizeof >= crypto_auth_KEYBYTES);

                        if (this.address !is Address.init
                            && id.key == this.outer.config.validator.key_pair.address)
                        {
                            // either we connected to ourself, or someone else is pretending
                            // to be us
                            break;
                        }

                        if (id.mac.length != crypto_auth_KEYBYTES ||
                            crypto_auth_verify(id.mac.ptr, id.key[].ptr,
                                id.key[].length, shared_sec[].ptr) != 0)
                        {
                            break;
                        }

                        if (id.utxo != Hash.init)
                        {
                            UTXO stake;
                            // check if stake is valid and belongs to id.key
                            if (!this.outer.ledger.peekUTXO(id.utxo, stake) ||
                                stake.output.address != id.key ||
                                !this.outer.ledger.isStake(id.utxo, stake.output))
                                break;
                        }
                    }

                    this.onHandshakeComplete(this.address, this.api, id.utxo, id.key);
                    return;
                }
                catch (Exception ex)
                {
                    if (!this.onFailedRequest(this.address))
                        return;

                    // else try again
                    this.outer.taskman.wait(this.outer.config.node.retry_delay);
                }
            }
            // failed to connect, try to ban (if not whitelisted)
            this.outer.banman.ban(address);
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
    private DList!NetworkClient peer_list;

    /// Version of peer_list
    /// incremented to signal PeerRanges that they are invalidated
    private uint peer_list_version;

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

    /// Our local caching (or more) registry
    private NameRegistry registry;

    /// Registry client to send registrations to
    private NameRegistryAPI registry_client;

    /// Maximum connection tasks to run in parallel
    private enum MaxConnectionTasks = 10;

    protected agora.api.FullNode.API owner_node;

    /// Most recent validator set
    protected UTXO[Hash] last_known_validator_utxos;

    /// Ledger
    protected Ledger ledger;

    /// Ctor
    public this (in Config config, ManagedDatabase cache, ITaskManager taskman,
        Clock clock, agora.api.FullNode.API owner_node, Ledger ledger)
    {
        this.log = Logger(__MODULE__);
        this.taskman = taskman;
        this.config = config;
        this.banman = this.makeBanManager(config.banman, clock, cache);
        this.clock = clock;
        this.owner_node = owner_node;
        this.ledger = ledger;

        // add the IP seeds
        this.addAddresses(Set!Address.from(config.network));

        // add the DNS seeds
        if (config.dns_seeds.length > 0)
            this.addAddresses(resolveDNSSeeds(config.dns_seeds, this.log));
    }

    ///
    public auto peers () @safe nothrow pure
    {
        return PeerRange(&this.peer_list_version, &this.peer_list);
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
        log.dbg("onHandshakeComplete: {} - (k: {}, utxo: {})", address, key, utxo);

        // We have an authenticated client, maybe we already have a client for it
        if (key !is PublicKey.init)
        {
            auto existing_peers = this.peers.find!(p => p.identity.key == key);
            if (!existing_peers.empty())
            {
                auto prev = existing_peers.front();
                // There's three possibilities:
                // a) We don't have an UTXO for this peer and we just got one,
                //    so record it.
                // b) We have an UTXO for this peer and got one, don't do anything
                // c) We have an UTXO for this peer and didn't get one (or got a different one),
                //    drop the new connection, as it could be another node
                //    (e.g. backup) not wanting to be known as validator
                //
                // Case (c) shows that using keys for identification is tricky,
                // but we had to do so due to DNS limitations
                if (prev.identity.utxo !is Hash.init)
                {
                    if (utxo != prev.identity.utxo)
                        return; // Drop it
                }
                else if (utxo !is Hash.init)
                {
                    prev.setIdentity(utxo, key);
                    this.required_peers.remove(utxo);
                }
                prev.merge(address, api);
                return; // All done
            }
        }

        if (utxo !is Hash.init)
            this.required_peers.remove(utxo);
        else if (this.peerLimitReached())
            return;

        auto client = new NetworkClient(this.taskman, this.banman,
            this.config.node.retry_delay, this.config.node.max_retries);
        if (!client.merge(address, api))
            assert(0);

        if (!client.connections.any!(conn => address == Address.init))
        {
            this.peer_list.insertBack(client);

            if (key !is PublicKey.init)
            {
                log.info("Found new Validator: {} (UTXO: {}, key: {})",
                         client.addresses(), utxo, key);
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
            Duration req_delay;
            Duration offset;
        }

        static TimeInfo[] offsets;
        offsets.length = 0;
        () @trusted { assumeSafeAppend(offsets); }();
        // must include our own assumed clock drift (zero)
        offsets ~= TimeInfo(this.config.validator.key_pair.address,
            this.clock.utcTime());

        foreach (node; this.validators())
        {
            if (node.identity.utxo !in this.quorum_set_keys)
                continue;

            const req_start = this.clock.utcTime();
            const node_time = node.getLocalTime();
            if (node_time == 0)
                continue;  // request failed

            const req_delay = (this.clock.utcTime() - req_start);
            const dist_delay = req_delay / 2;  // divide evently
            const offset = (node_time - req_start) - dist_delay;
            offsets ~= TimeInfo(node.identity.key, node_time, req_delay, offset);
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

    /// Set the instance of the `NameRegistry` to use
    public void setRegistry (NameRegistry registry)
        scope @safe pure nothrow @nogc
    {
        assert(this.registry is null);
        assert(registry !is null);

        this.registry = registry;
    }

    /// Periodically registers network addresses
    public ITimer startPeriodicNameRegistration ()
    {
        enforce(this.config.node.registry_address.set,
                "A validator should have a name registry configured");

        this.registry_client = this.makeRegistryClient();

        this.onRegisterName();  // avoid delay
        // We re-register at regular interval in order to cope with the situation below
        // 1. network registry server is restarted
        // 2. client running agora node acquired some new IPs
        return this.taskman.setTimer(
            this.config.validator.name_registration_interval,
            &this.onRegisterName, Periodic.Yes);
    }

    /// Called when validator set is changed
    public void onValidatorSetChanged (UTXO[Hash] validator_utxos) @trusted
    {
        this.last_known_validator_utxos = validator_utxos;

        foreach (val; this.validators())
            if (val.identity.utxo !in this.last_known_validator_utxos)
                if (this.peer_list.linearRemoveElement(val))
                {
                    this.peer_list_version++;
                    val.shutdown();
                }
    }

    /// Discover the network, connect to all required peers
    /// Some nodes may want to connect to specific peers before
    /// discovery() is considered complete
    public void discover (UTXO[Hash] required_peer_utxos = null) nothrow
    {
        this.quorum_set_keys.from(Set!Hash.init);
        this.required_peers.from(Set!Hash.init);

        foreach (peer; this.peers)
            if (!peer.isConnected() &&
                assumeWontThrow(this.peer_list.linearRemoveElement(peer)))
            {
                this.peer_list_version++;
                peer.shutdown();
            }

        foreach (peer; required_peer_utxos.byKeyValue)
        {
            this.quorum_set_keys.put(peer.key);
            if (!this.peers.map!(c => c.identity.utxo).canFind(peer.key))
                this.required_peers.put(peer.key);
        }

        log.trace(
            "Doing periodic network discovery: {} required peers requested, {} missing, known {}",
            required_peer_utxos.length, this.required_peers.length, this.last_known_validator_utxos.length);

        foreach (utxo; this.last_known_validator_utxos.byKeyValue)
        {
            if (!this.peers.map!(ni => ni.identity.utxo).canFind(utxo.key))
            {
                auto key = utxo.value.output.address;
                // Do not query the registry about ourself
                if (key == this.config.validator.key_pair.address)
                    continue;

                taskman.runTask(
                () nothrow {
                    // https://github.com/bosagora/agora/issues/2197
                    const ckey = key;
                    try
                    {
                        auto payload = this.registry.getValidatorInternal(ckey);
                        if (payload == RegistryPayloadData.init)
                        {
                            log.warn("Could not find mapping in registry for key {}", ckey);
                            return;
                        }

                        if (payload.public_key != ckey)
                        {
                            log.error("Registry answered with the wrong key: {} => {}",
                                      ckey, payload);
                            return;
                        }

                        foreach (addr; payload.addresses)
                            this.addAddress(addr);
                    }
                    catch (Exception exc)
                        log.error("Exception happened while looking up address for {}: {}",
                                  ckey, exc);
                });
            }
        }

        /// Returns: true if we should keep trying to connect to an address,
        /// else false if the address was banned
        bool onFailedRequest (in Address address) nothrow
        {
            return !this.banman.isBanned(address);
        }

        try
        {
            foreach (addr; this.registry.validatorsAddresses())
                this.addAddress(addr);
        }
        catch (Exception ex)
            log.info("Cannot fetch validator addresses from our registry {}",
                ex);

        while (this.todo_addresses.length)
        {
            if (this.connection_tasks.length >= MaxConnectionTasks)
            {
                log.info("Connection task limit reached ({}/{}). Will try again in {}. {} addresses in queue.",
                         this.connection_tasks.length, MaxConnectionTasks,
                         this.config.node.network_discovery_interval,
                         this.todo_addresses.length);
                log.info("Pending connections: {} - Waiting: {}",
                         this.connection_tasks.byKey(), this.todo_addresses);
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

    private bool shouldEstablishConnection (Address address) @safe nothrow
    {
        auto existing_peer = this.peers.find!(p => p.addresses.canFind(address));
        return !this.banman.isBanned(address) &&
            address !in this.connection_tasks &&
            address !in this.todo_addresses &&
            (existing_peer.empty || // either does not exist or a validator with no stake
                (existing_peer.front.isAuthenticated() && existing_peer.front.identity.utxo == Hash.init));
    }

    /// Received new set of addresses, put them in the todo address list
    private void addAddresses (AddressSet) (AddressSet addresses) @safe nothrow
    {
        foreach (address; addresses)
            this.addAddress(address);
    }

    /// Ditto
    private void addAddress (Address address) @safe nothrow
    {
        if (this.shouldEstablishConnection(address))
            this.todo_addresses.put(address);
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

    public abstract DNSResolver makeDNSResolver (Address[] peers = null);

    /// register network addresses into the name registry
    public void onRegisterName () @safe
    {
        assert(this.registry_client !is null);

        const(Address)[] addresses = this.config.validator.addresses_to_register;
        if (!addresses.length)
            addresses = InetUtils.getPublicIPs().map!(
                ip => Address("agora://"~ip)
            ).array;
        this.addAddresses(Set!Address.from(addresses));

        RegistryPayloadData data =
        {
            public_key : this.config.validator.key_pair.address,
            addresses : addresses,
            seq : time(null),
        };

        auto sig = data.sign(this.config.validator.key_pair);

        try
        {
            this.registry_client.postValidator(data, sig);
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
        return this.peers.filter!(p => p.isAuthenticated());
    }

    /***************************************************************************

        Params:
            a Validator stake hash

        Returns:
            Network client to the peer identified with `utxo`

    ***************************************************************************/

    public auto getPeerByStake (in Hash utxo) return @safe nothrow
    {
        auto found = this.validators.find!(peer => peer.identity.utxo == utxo);
        if (!found.empty())
            return found.front();
        return null;
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
        import std.typecons : tuple;

        // return ulong.max if getBlockHeight() fails
        Height getHeight (NetworkClient node)
        {
            try
                return Height(node.getBlockHeight());
            catch (Exception ex)
                return Height(ulong.max);
        }

        foreach (node, peer_height; this.peers.map!(node => tuple(node, getHeight(node))))
        {
            if (peer_height == ulong.max || height > peer_height)
                continue;  // this node does not have newer blocks than us

            log.info("Retrieving blocks [{}..{}] from {}..",
                height, peer_height, node.addresses);
            const MaxBlocks = 1024;
            auto blocks = node.getBlocksFrom(height, MaxBlocks);
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

        foreach (peer; this.peers)
        {
            if (unknown_txs.length == 0)
                break;

            // Fetch transactions in chunks
            auto hashes = unknown_txs[].map!((Hash h) => h).array; // can not be lazy so use array
            auto added = hashes.chunks(8)
                .map!(chunk => Set!Hash.from(chunk))
                .map!(hash_chunk => peer.getTransactions(hash_chunk))
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
                // This will also remove it from unknown_txs
                if (ledger.acceptTransaction(tx) is null)
                    accepted++;

                log.trace("getUnknownTXs: Found unknown tx with hash {}", tx.hashFull());
            }
            catch (Exception e)
            {
                log.warn("getUnknownTXs: Unknown TX {} threw {}", tx, e.msg);
            }
        });
        return accepted;
    }

    /***************************************************************************

        Retrieve any missing block signatures from the connected nodes for
        blocks since the last fee payment block.

    ***************************************************************************/

    public void getMissingBlockSigs (Ledger ledger,
        scope ulong delegate(BlockHeader) @safe potentialExtraSigs,
        scope string delegate(BlockHeader) @safe acceptHeader) @safe nothrow
    {
        import std.algorithm;
        import std.conv;
        import std.range;
        import std.typecons;

        size_t[Height] signed_validators;

        try
        {
            auto start_height = ledger.getLastPaidHeight();
            auto headers = ledger.getBlocksFrom(start_height)
                .map!(block => block.header).array;

            size_t enrolledValidators (Height height)
            {
                return headers.find!(
                    (b, h) => b.height == h
                )(height)[0].validators.count;
            }

            Set!ulong heightsMissingSigs ()
            {
                signed_validators =
                    headers.map!(header =>
                        tuple(header.height,
                            iota(0, enrolledValidators(header.height)).filter!(i =>
                                header.validators[i] || header.preimages[i] is Hash.init).count() // Take into account the slashed validators
                        )
                    ).assocArray;

                return Set!ulong.from(headers.map!(h => h.height).filter!(height => signed_validators[height] < enrolledValidators(height)));
            }

            void doCatchUp ()
            {
                auto missing_heights = heightsMissingSigs();
                if (missing_heights.empty)
                    return; // Nothing to do

                log.trace("getMissingBlockSigs: detected missing signatures at heights {}", missing_heights);
                foreach (peer; this.peers)
                {
                    foreach (header; peer.getBlockHeaders(missing_heights))
                    {
                        auto potential_sig_count = iota(enrolledValidators(header.height)).filter!(i =>
                            header.validators[i] || header.preimages[i] is Hash.init).count()
                            + potentialExtraSigs(header);
                        if (potential_sig_count > signed_validators[header.height])
                        {
                            try
                            {
                                if (auto res = acceptHeader(header))
                                    log.dbg("getMissingBlockSigs: couldn't update header ({})", header.height);
                                else
                                {
                                    log.trace("getMissingBlockSigs: updated header ({}) signature: {} validators: {}",
                                        header.height, header.signature, header.validators);
                                    missing_heights.remove(header.height);
                                }
                            }
                            catch (Exception e)
                            {
                                log.error("getMissingBlockSigs: Exception thrown updating block signature at height {}: {}", header.height, e.msg);
                            }
                        }
                    }
                    if (missing_heights.empty)
                        break;
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
            peer.shutdown();
    }

    ///
    private bool minPeersConnected () nothrow @safe
    {
        log.dbg("minPeersConnected: missing = {}, peers = {}, min = {}",
            this.required_peers.length, this.peers.walkLength, this.config.node.min_listeners);

        // We need to establish connections to all peers we were explicitly asked for
        if (this.required_peers.length)
            return false;

        // We need to establish a minimum number of connections
        if (this.peers.walkLength < this.config.node.min_listeners)
            return false;

        // We don't have an authenticated peer where all the addresses are banned
        return this.validators().filter!(
            client => !client.addresses.all!(addr => this.banman.isBanned(addr)))
            .count != 0;
    }

    private bool peerLimitReached ()  nothrow @safe
    {
        return this.required_peers.length == 0 &&
            this.peers.filter!(client =>
                !client.addresses.all!(addr => this.banman.isBanned(addr))).count >= this.config.node.max_listeners &&
            this.validators().filter!(client =>
                !client.addresses.all!(addr => this.banman.isBanned(addr))).count != 0;
    }

    /// Returns: the list of node IPs this node is connected to
    public NodeInfo getNetworkInfo () @safe
    {
        return NodeInfo(
            this.minPeersConnected()
                ? NetworkState.Complete : NetworkState.Incomplete,
            this.peers.map!(peer => NodeInfo.PeerInfo(peer.identity.key,
                peer.identity.utxo, peer.addresses.array)).array);
    }

    /***************************************************************************

        Instantiates a client object implementing `API`

        This function simply returns a client object implementing `API`,
        using the underlying I/O framework. The type of object might differ
        based on the schema (e.g. `agora://` versus `http[s]://`).

        Params:
          address = The full address of this node

        Returns:
          An object to communicate with the node at `address`

    ***************************************************************************/

    protected abstract agora.api.Validator.API makeClient (Address url);

    /***************************************************************************

        Instantiates a client object implementing `NameRegistryAPI`

        The parameter-less overload uses the address configured in the
        configuration file, or `null` if there is none, while the overload
        taking an `Address` will connect to an arbitrary registry and will
        always return a non-`null` value.

        Params:
          address = The address of the name registry server

        Returns:
          An object to communicate with the name registry server

    ***************************************************************************/

    public abstract NameRegistryAPI makeRegistryClient (Address address);

    /// Ditto
    public final NameRegistryAPI makeRegistryClient ()
    {
        if (!this.config.node.registry_address.set)
            return null;
        return this.makeRegistryClient(this.config.node.registry_address);
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
        this.validators().each!(v => v.sendBlockSignature(block_sig));
    }

    /***************************************************************************

        Instantiates a client object implementing the `BlockExternalizedHandler`

        Params:
            address = The address of the target handler

        Returns:
            A Handler to communicate with the server at `address`

    ***************************************************************************/

    public abstract BlockExternalizedHandler makeBlockExternalizedHandler (Address address);

    /***************************************************************************

        Instantiates a client object implementing the `BlockHeaderUpdatedHandler`

        Params:
            address = The address of the target handler

        Returns:
            A Handler to communicate with the server at `address`

    ***************************************************************************/

    public abstract BlockHeaderUpdatedHandler makeBlockHeaderUpdatedHandler (Address address);

    /***************************************************************************

        Instantiates a client object implementing the `PreImageReceivedHandler`

        Params:
            address = The address of the target handler

        Returns:
            A Handler to communicate with the server at `address`

    ***************************************************************************/

    public abstract PreImageReceivedHandler makePreImageReceivedHandler(Address address);

    /***************************************************************************

        Instantiates a client object implementing the `TransactionReceivedHandler`

        Params:
            address = The full address of the target handler

        Returns:
            A Handler to communicate with the server at `address`

    ***************************************************************************/

    public abstract TransactionReceivedHandler makeTransactionReceivedHandler (Address address);

    /***************************************************************************

        Whitelist a Hash of a UTXO to avoid banning it

        Params:
            hash = the Hash of the UTXO to whitelist

    ***************************************************************************/

    public void whitelist (Hash utxo)
    {
        this.peers.filter!(p => p.identity.utxo == utxo)
            .each!(p => p.addresses.each!(addr => this.banman.whitelist(addr)));
    }

    /***************************************************************************

        Unwhitelist a Hash of a UTXO to allow banning it

        Params:
            key = hash = the Hash of the UTXO to unwhitelist

    ***************************************************************************/

    public void unwhitelist (Hash utxo)
    {
        this.peers.filter!(p => p.identity.utxo == utxo)
            .each!(p => p.addresses.each!(addr => this.banman.unwhitelist(addr)));
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

/// A range over the list of peers that can be invalidated
public struct PeerRange
{
    // Pointer to the `peers` version
    private uint* manager_version;

    // Pointer to the peers list NetworkManager maintains
    private DList!NetworkClient* peers;

    // version of `peers` that we sliced
    private uint range_version;

    // Range over the `peers` with version `range_version`
    private DList!NetworkClient.Range range;

    this (uint* manager_version, DList!NetworkClient* peers) nothrow @safe pure
    {
        this.manager_version = manager_version;
        this.peers = peers;
        this.range_version = *this.manager_version;
        this.range = (*this.peers)[];
    }

    public void popFront () nothrow @safe
    {
        if (!this.empty())
            this.range.popFront();
    }

    public bool empty () nothrow @safe
    {
        this.checkIfInvalidated();
        return this.range.empty();
    }

    public auto front () nothrow @safe
    {
        this.checkIfInvalidated();
        return this.range.front();
    }

    public auto save () nothrow @safe
    {
        return this;
    }

    private bool checkIfInvalidated () nothrow @safe
    {
        if (*this.manager_version > this.range_version)
        {
            this.range_version = *this.manager_version;
            this.range = (*this.peers)[];
            return true;
        }
        return false;
    }
}
static assert (isForwardRange!PeerRange);
