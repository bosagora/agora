/*******************************************************************************

    Contains a network crawler implementation, that tries to determine
    the geographical location and OS for other reachable network nodes.

    The implementation uses a never ending BFS search, where certain nodes
    can temporarily be banned. Nodes can get temporarily banned, if they become
    unreachable for a certain period of time, or if they recommend too many
    unreachable nodes. This banning doesn't affect the normal operation of the
    network as a separate instance of BanManager is used.

    The implementation contains some performance optimizations:

    1. Multiple fibers can crawl the network at the same time.
    2. Additional supporting data structures are added for fast lookups of
       already discovered nodes.

    The implementation tries to minimize the impact of ill-behaved nodes:

    1. Nodes that are unreachable for a certain period of time, or nodes that
       recommend too many unreachable nodes are temporarily banned.
    2. Nodes only take a limited number of node recommendation from other nodes.
    3. Nodes do simple address sanity checks on the recommendations, before even
       trying to contact them.
    4. Nodes ignore the port of other nodes during crawling, so an attacker
       can not start up multiple nodes on the same machine on different ports
       to distort crawling results.
    5. Nodes translate domain names to IP addresses during crawling, so an attacker
       can not start up multiple nodes on multiple subdomains like sub1.attacker.com,
       sub2.attacker.com with the same IP address to distort crawling results.

    The implementation tries to recover from network failures:

    Whenever a particular node experiences a local network failure, all other nodes
    would appear as offline, and all of them would eventually be temporarily banned.
    Every temporarily banned node is immediately removed from the BFS candidate
    nodes, and as a result of that implementation would end up with no nodes to
    continue the never ending BFS search. In order to avoid this situations, certain (seed)
    nodes can never be removed from the BFS candidate search list, even if the seed
    node gets temporarily banned. Although the crawling results for those
    temprorarily banned seed nodes is removed from the overall crawling results.

    The implementaion handles some special cases

    1. Multiple crawling fibers will share the same instance of NodeLocator,
       so the shutdown of the fibers need to be coordinated to make sure during
       the shutdown no fibers will try to use an already stopped shared NodeLocator.
    2. The default behavior of TestNetworkManager.getClient is to asserts with 0.
       whenever a node would like to create a NetworkClient to an already shut down node.
       As nodes (and crawlers) stop at different times, the above assert could trigger.
       In order to avoid this a new config parameter called
       `TestConf.use_non_assert_get_client` was added.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.Crawler;

import agora.api.FullNode : NodeInfo;
import agora.common.BanManager;
import agora.common.Config;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
import agora.network.Client;
import agora.network.Clock;
public import agora.network.CrawlerTypes;
import agora.network.Manager;
import agora.network.NodeLocator;
import agora.serialization.Serializer;
import agora.utils.InetUtils;
import agora.utils.Log;

import std.algorithm;
import std.container.dlist;
import std.conv : to;
import std.range : iota;
import std.socket : AddressFamily, getAddressInfo;
import std.traits : KeyType, ValueType;

import core.time;

/// Crawler implementation, using the GEOIP2 MMDB database to retrieve
/// node's geographical location
public class Crawler
{

    /// Struct to hold information about a particular network client
    private struct NetworkClientHolder
    {
        /// The network address of the node, that recommended the node
        /// stored in `this.network_client`.
        public Address recommender_address;

        /// The node that was recommended by `this.recommender_address`
        public NetworkClient network_client;
    }

    /// Task manager
    private ITaskManager taskman;

    /// Ban manager
    private BanManager banman;

    /// Config
    private Config config;

    /// Network manager
    private NetworkManager network_manager;

    /// Node locator
    private INodeLocator node_locator;

    /// Logger
    private Logger log;

    /// Clock
    private Clock clock;

    /// 1. Crawler fibers pop an already dicovered node from the front of the list.
    /// 2. Crawler fibers try to get node recommendations from the popped node.
    /// 3. If the popped node answers with a list of node recommendations,
    ///    then all those new recommendations and the popped node are pushed to
    ///    the back of the list.
    private DList!NetworkClientHolder discovered_node_list;

    /// Lookup map to decide, whether the current node has already discovered
    /// a particular node. This maps supplements `discovered_node_list` and
    /// was added because:
    ///
    /// 1. Iterating over `discovered_node_list` is slow.
    /// 2. Iterating over `discovered_node_list` cannot reliably answer, whether
    ///    a node has been discovered, as crawling fibers pop elements off of it.
    private NetworkClientHolder[Address] discovered_node_map;

    /// Contains the crawling results. A particular node is removed from this
    /// data structure, after it is temporarily banned.
    private CrawlResultHolder crawl_result_holder;

    /// Indicating whether the crawler is in the process of shutting down.
    private bool is_shutting_down;

    /// Number of crawler fibers that already shut down.
    private ubyte already_shutdown_cnt;

    public this (ITaskManager taskman, Clock clock, Config config, NetworkManager network_manager)
    {
        import std.path : buildPath;

        this.taskman = taskman;
        this.clock = clock;
        this.config = config;
        this.network_manager = network_manager;
        this.node_locator = this.makeNodeLocator();
        this.log = Logger(__MODULE__);

        BanManager.Config ban_config =
        {
            max_failed_requests : 25,
            ban_duration : 30.minutes
        };
        this.banman = new BanManager(ban_config, clock, buildPath(config.node.data_dir,"banned_crawler.dat"));
    }

    /// Entry point for the crawling fibers
    private void crawl () nothrow
    {
        try
        {
            // Fiber shutdown have to be coordinated among all fibers
            while (!this.is_shutting_down)
            {
                if (discovered_node_list.empty)
                {
                    this.taskman.wait(this.config.node.crawling_interval);
                    continue;
                }

                // Pop a node from the front of the list
                auto network_client_holder = this.discovered_node_list.front;
                auto client_address = network_client_holder.network_client.address;
                this.discovered_node_list.removeFront();

                auto handle_network_error = delegate()
                {
                    // Penalize the recommender with weight of 1
                    this.banman.onFailedRequest(InetUtils.extractHostAndPort(
                        network_client_holder.recommender_address).host, 1);
                    // Penalize the unreachable node with weight of 5
                    this.banman.onFailedRequest(InetUtils.extractHostAndPort(
                        client_address).host, 5);

                    // Node might be banned by being unreachable for too long
                    if (this.banman.isBanned(client_address))
                    {
                        // Seed nodes are never entirely banned, and need to be put
                        // back into the queue. However the crawling results of the
                        // seed nodes need to be removed.
                        if (client_address in this.network_manager.seed_addresses)
                        {
                            this.taskman.wait(this.config.node.crawling_interval);
                            this.discovered_node_list.insertBack(network_client_holder);
                        }
                        else
                            discovered_node_map.remove(client_address);

                        crawl_result_holder.crawl_results.remove(client_address);
                    }
                    else
                        this.discovered_node_list.insertBack(network_client_holder);
                };

                NodeInfo node_info;
                try
                    // Node might be banned because of too many wrong recommendation,
                    // despite the fact the node is constantly available
                    if (this.banman.isBanned(client_address))
                    {
                        handle_network_error();

                        // Crawling failed for this node, and should be continued immediately
                        // without waiting
                        continue;
                    }
                    else
                        node_info = network_client_holder.network_client.getNodeInfo();
                catch (Exception e)
                {
                    handle_network_error();

                    // Crawling failed for this node, and should be continued immediately
                    // without waiting
                    continue;
                }

                // Do simple checks on the recommended nodes, and if checks pass,
                // then add them to the data structures
                this.processNetworkAddresses(client_address, node_info.addresses.pickRandom(10));

                if (node_info.include_in_network_statistics)
                {
                    // Node proved that, it implements getNodeInfo method, and it is still
                    // running, so it's statistics should be added to the crawling results
                    if (auto it = client_address in this.crawl_result_holder)
                        it.crawl_time = this.clock.networkTime();
                    else
                        this.crawl_result_holder[client_address] =
                            this.populateCrawlResult(
                                this.node_locator.extractValues(client_address,
                                    [
                                        "continent->names->en",
                                        "country->names->en",
                                        "city->names->en",
                                        "location->latitude",
                                        "location->longitude",
                                    ]),
                                    node_info,
                                    InetUtils.extractHostAndPort(client_address).type == HostType.IPv4);
                }
                // After a succesfull crawl, wait before starting a new one
                this.taskman.wait(this.config.node.crawling_interval);
                this.discovered_node_list.insertBack(network_client_holder);
            }

            // After all the fibers exited the for loop, and there is no fiber
            // trying to use the NodeLocator, resources can be freed
            if (this.already_shutdown_cnt++ == this.config.node.num_of_crawlers)
                this.node_locator.stop();
        }
        catch(Exception e)
        {
            log.error("Crawler stopped with exception {}", e);
        }
    }

    /***************************************************************************

        Populates a `CrawlResult` based on the string values passed in and
        based on current time.

        Params:
            extracted_values = the values that will be used to populate the
            `CrawlResult` object

        Returns:
            a `CrawlResult` object populated from `extracted_values`

    ***************************************************************************/

    private CrawlResult populateCrawlResult (string[] extracted_values,
        ref NodeInfo node_info, bool is_ipv4) @safe nothrow
    {
        CrawlResult crawl_result;
        foreach (i, ref field; crawl_result.tupleof)
            static if (i >= 6)
                break;
            else static if (is(typeof(field) == string))
                field = extracted_values[i];
            else static if (is(typeof(field) == TimePoint))
                field = this.clock.networkTime();
            else static assert(0);

        crawl_result.os = node_info.os;
        crawl_result.client_name = node_info.client_name;
        crawl_result.client_ver = node_info.client_ver;
        crawl_result.height = node_info.height;
        crawl_result.is_ipv4 = is_ipv4;

        return crawl_result;
    }

    unittest
    {
        import std.algorithm : map;
        import std.array : array;
        import std.conv : to;

        auto mock_clock = new MockClock(5);
        auto crawler = new Crawler(null, mock_clock, Config(), null);
        NodeInfo node_info;
        node_info.os = "6";
        node_info.client_name = "7";
        node_info.client_ver = "8";
        node_info.height = Height(9);

        CrawlResult expected;
        expected.continent = "0";
        expected.country = "1";
        expected.city = "2";
        expected.latitude = "3";
        expected.longitude = "4";
        expected.crawl_time = 5;
        expected.os = "6";
        expected.client_name = "7";
        expected.client_ver = "8";
        expected.height = Height(9);
        expected.is_ipv4 = true;

        assert(crawler.populateCrawlResult(iota(5).map!(i => i.to!string()).array(), node_info, true) == expected);
    }

/***************************************************************************

        Gets the information about the network and it's reachable nodes.

        The information includes the network address and the geograpical location
        of the nodes including the continent/country/city/latitude/longitude.

        API:
            GET /network_info

        Returns:
            information about the network and about it's nodes


    ***************************************************************************/


    public CrawlResultHolder getNetworkInfo () @safe @nogc nothrow pure
    {
        return crawl_result_holder;
    }

    /***************************************************************************

        Creates and returns a newly created NodeLocator object.

        Returns:
            a newly created NodeLocator object

    ***************************************************************************/

    protected INodeLocator makeNodeLocator ()
    {
        return new NodeLocatorGeoIP(this.config.node.ipdb_path);
    }

    // Start the Crawler
    public void start ()
    {
        import std.array : array;

        // at least 1 seed node needs to be provided
        this.network_manager.seed_addresses.length || assert(0);

        // node locator object should start successfully
        this.node_locator.start() || assert(0);

        this.processNetworkAddresses("seed", this.network_manager.seed_addresses[].array());

        // start the crawling fibers
        iota(config.node.num_of_crawlers).each!(_ =>
            this.taskman.runTask(&this.crawl)
        );
    }

    // Initiate stopping the Crawler
    public void stop () @safe @nogc nothrow pure
    {
        this.is_shutting_down = true;
    }

    /***************************************************************************

        Processes network addresses by checking the addresses and updating the
        internal data structures.

        Params:
            recommender_address = the node address which recommended `addresses`
            addresses = the recommended addresses

        Returns:
            network clients that were created while processing the addresses

    ***************************************************************************/

    protected NetworkClientHolder[] processNetworkAddresses (Address recommender_address, Address[] addresses)
    {
        NetworkClientHolder[] network_client_holders;
        network_client_holders.reserve(addresses.length);
        foreach (address; addresses)
            if (auto transformed_address = this.transformAddress(address))
            {
                auto network_client = this.getNetworkClient(transformed_address);
                // Getting the client of an already shut down/never started node
                // returns null in unittests if `use_non_assert_get_client` is
                // set to `true`.
                version (unittest)
                    if (network_client is null)
                        break;
                auto network_client_holder = NetworkClientHolder(recommender_address, network_client);
                this.discovered_node_list.insertBack(network_client_holder);
                this.discovered_node_map[network_client.address] = network_client_holder;
                network_client_holders ~= network_client_holder;
            }
        return network_client_holders;
    }

    /***************************************************************************

        Checks and transforms an address to the canonical representation of
        [schema]://[IP address]:[port]. If any of the checks fail, then the
        returned value is null, otherwise the canonical representation is
        returned.

        Params:
            address = the address to check and transform

        Returns:
            null, if any of the checks fail, the canonical representation of
            the address

    ***************************************************************************/

    protected Address transformAddress (Address address) @safe
    {
        // Break up the address into host, port and determining the host type
        auto host_port = InetUtils.extractHostAndPort(address);

        if (host_port == InetUtils.HostPortTup.init || this.banman.isBanned(host_port.host))
            return null;

        // Domain names needs to be resolved before proceeding, as subdomains
        // can be created at no cost by an attacker, while obtaining multiple
        // IP addresses comes at a cost
        string resolved_host;
        if (host_port.type == HostType.Domain)
            try
                foreach (ref addr_info; getAddressInfo(host_port.host))
                {
                    string resolved_address_candidate = addr_info.address.toAddrString();
                    if (addr_info.address.addressFamily == AddressFamily.INET6)
                       resolved_address_candidate = InetUtils.expandIPv6(resolved_address_candidate);

                    if (addr_info.address.addressFamily == AddressFamily.INET ||
                        addr_info.address.addressFamily == AddressFamily.INET6 )
                    {
                        resolved_host = resolved_address_candidate;
                        break;
                    }
                }
            catch (Exception e)
            {
                log.trace("Error happened while trying to resolve DNS name {}", host_port.host);
                return null;
            }
        else
            resolved_host = host_port.host;

        if (resolved_host in this.discovered_node_map || this.banman.isBanned(resolved_host))
            return null;

        return host_port.schema ~ "://" ~ resolved_host ~ ":" ~ host_port.port.to!string;
    }

    unittest
    {
        import std.algorithm : count;
        import std.path : buildPath;
        import core.time;

        auto mock_clock = new MockClock(0);
        BanManager.Config banman_config = {ban_duration : 10.seconds};
        auto banman = new BanManager(banman_config, mock_clock, buildPath("garbageDir", "banned_crawler.dat"));
        auto crawler = new Crawler(null, mock_clock, Config(), null);
        crawler.banman = banman;

        // Returned string has to have a format of <schema>://<ip address>:<port>
        assert(crawler.transformAddress("8.8.8.8") == "http://8.8.8.8:80");
        assert(crawler.transformAddress("http://8.8.8.8")  == "http://8.8.8.8:80");
        assert(crawler.transformAddress("http://8.8.8.8:1234") == "http://8.8.8.8:1234");
        assert(crawler.transformAddress("https://8.8.8.8") == "https://8.8.8.8:443");

        // DNS domains must be resolved
        assert(crawler.transformAddress("bosagora.io").count('.') == 3);

        // Banned hosts should return null
        banman.ban("8.8.8.8");
        assert(crawler.transformAddress("http://8.8.8.8") == null);
        // Unban node by advancing time
        mock_clock.setTime(11);
        assert(crawler.transformAddress("http://8.8.8.8") == "http://8.8.8.8:80");

        // Already discovered hosts should return null
        crawler.discovered_node_map["8.8.8.8"] = NetworkClientHolder();
        assert(crawler.transformAddress("8.8.8.8") == null);
    }

    protected NetworkClient getNetworkClient (Address address)
    {
        return this.network_manager.getNetworkClient(this.taskman, this.banman,
                    address, network_manager.getClient(address, this.config.node.timeout),
                    this.config.node.retry_delay, this.config.node.max_retries);
    }
}

/// Test crawler used in network tests. This crawler uses the NodeLocatorMock.
public class TestCrawler : Crawler
{
    this (ITaskManager taskman, Clock clock, Config config, NetworkManager network_manager)
    {
        super(taskman, clock, config, network_manager);
    }

    protected override INodeLocator makeNodeLocator () const @safe pure nothrow
    {
        return new NodeLocatorMock();
    }

    protected override Address transformAddress (Address address) const @safe @nogc pure nothrow
    {
        return address;
    }
}
