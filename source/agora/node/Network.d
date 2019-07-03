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

module agora.node.Network;

import agora.common.API;
import agora.common.crypto.Key;
import agora.common.Config;
import agora.common.Data;
import agora.common.Set;
import agora.node.RemoteNode;

import vibe.core.log;
import vibe.web.rest;

import core.time;

import std.algorithm;
import std.array;
import std.exception;
import std.format;
import std.random;


/// Ditto
public class NetworkManager
{
    /// Config instance
    private const NodeConfig node_config;

    /// The connected nodes
    protected RemoteNode[PublicKey] peers;

    /// The addresses currently establishing connections to.
    /// Used to prevent connecting to the same address twice.
    protected Set!Address connecting_addresses;

    /// Addresses we won't connect to anymore
    protected Set!Address banned_addresses;

    /// All known addresses so far
    protected Set!Address known_addresses;

    /// Addresses are added and removed here,
    /// but never added again if they're already in known_addresses
    protected Set!Address todo_addresses;

    /// DNS seeds
    private const(string)[] dns_seeds;


    /// Ctor
    public this (in NodeConfig node_config, in string[] peers, in string[] dns_seeds)
    in { assert(peers.length > 0, "No network option found"); }
    do {
        this.node_config = node_config;
        this.addAddresses(Set!Address.from(peers));

        // add our own IP to the list of banned IPs to avoid
        // the node communicating with itself
        this.banned_addresses.put(
            format("http://%s:%s", this.node_config.address, this.node_config.port));

        this.dns_seeds = dns_seeds;
    }

    /// try to discover the network until we found
    /// all the validator nodes from our quorum set.
    public void discover ()
    {
        if (this.dns_seeds.length > 0)
        {
            logInfo("Resolving DNS from %s", this.dns_seeds);
            this.addAddresses(resolveDNSSeeds(this.dns_seeds));
        }

        logInfo("Discovering from %s", this.todo_addresses.byKey());

        while (!this.allPeersConnected())
        {
            this.connectNextAddresses();
            this.wait(this.node_config.retry_delay.msecs);
        }

        logInfo("Discovery reached. %s peers connected.", this.peers.length);

        // the rest can be done asynchronously as we can already
        // start validating and voting on the blockchain
        this.runTask(()
        {
            while (!this.peerLimitReached())
            {
                this.connectNextAddresses();
                this.wait(this.node_config.retry_delay.msecs);
            }
        });
    }

    /// Attempt connecting with the given address
    private void tryConnecting ( Address address )
    {
        // banned address
        if (this.isAddressBanned(address))
            return;

        logInfo("Establishing connection with %s...", address);
        auto node = new RemoteNode(address, this.getClient(address),
            this.node_config.retry_delay.msecs);

        node.getReady(
            (net_info) { this.addAddresses(net_info.addresses); },
            &this.onNodeConnected);
    }

    private void onNodeConnected ( RemoteNode node )
    {
        if (this.peerLimitReached())
            return;
        logInfo("Established new connection with peer: %s", node.key);
        this.peers[node.key] = node;
    }

    /// Received new set of addresses, put them in the todo & known IP list
    private void addAddresses ( Set!Address addresses )
    {
        foreach (address; addresses)
        {
            // go away
            if (this.isAddressBanned(address))
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

            if (!this.isAddressBanned(address) &&
                address !in this.connecting_addresses)
            {
                this.connecting_addresses.put(address);
                this.runTask(() { this.tryConnecting(address); });
            }
        }
    }

    ///
    private void banAddress ( Address address )
    {
        logInfo("Banned address: %s", address);
        this.banned_addresses.put(address);
    }

    /// Return true if this address was already visited
    private bool isAddressBanned ( Address address )
    {
        return !!(address in this.banned_addresses);
    }

    ///
    private bool allPeersConnected ( )
    {
        return this.todo_addresses.length == 0;
    }

    private bool peerLimitReached ( )
    {
        return this.peers.length >= this.node_config.max_listeners;
    }

    /// Returns: the list of node IPs this node is connected to
    public NetworkInfo getNetworkInfo ()
    {
        return NetworkInfo(
            this.allPeersConnected()
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

        Returns:
          An object to communicate with the node at `address`

    ***************************************************************************/

    protected API getClient (Address address)
    {
        return new RestInterfaceClient!API(address);
    }

    /***************************************************************************

        Run an asynchronous task

        This is needed to support testing via `LocalRest`.
        It should not be in `NetworkManager`.
        However this is currently the place that uses it.
        When we build a good enough abstraction, this can be removed.

    ***************************************************************************/

    protected void runTask ( void delegate() dg)
    {
        static import vibe.core.core;
        vibe.core.core.runTask(dg);
    }

    /// Ditto
    protected void wait (Duration dur)
    {
        static import vibe.core.core;
        vibe.core.core.sleep(dur);
    }

    /***************************************************************************

        Sends the message to all the listeners.

        Params:
            msg = the message to send

    ***************************************************************************/

    public void sendMessage (Hash msg) @safe
    {
        foreach (ref node; this.peers)
        {
            node.sendMessage(msg);
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
