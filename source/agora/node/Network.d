/*******************************************************************************

    Contains the code used for peer-to-peer network discovery.

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

import vibe.core.core;
import vibe.core.log;
import vibe.web.rest;

import core.time;

import std.algorithm;
import std.array;
import std.exception;
import std.format;
import std.random;

// check up to 10 addresses at once
private immutable MaxConnectingAddresses = 10;

/// Note: cases which need to be handled:
/// - node disconnnects during discovery => we should re-try it later (if we need more IPs)
/// - new node connects at a random time during discovery => we should ask for its peers
class Network
{
    /// Config instance
    private const NodeConfig node_config;

    /// The connected nodes
    private RemoteNode[PublicKey] peers;

    /// The addresses currently establishing connections to.
    /// The number of connecting addresses should not
    /// exceed MaxConnectingAddresses too much.
    private Set!Address connecting_addresses;

    /// Addresses we won't connect to anymore
    private Set!Address banned_addresses;

    /// All known addresses so far
    private Set!Address known_addresses;

    /// Addresses are added and removed here,
    /// but never added again if they're already in known_addresses
    private Set!Address todo_addresses;


    /// Ctor
    public this (in NodeConfig node_config, in string[] peers)
    in { assert(peers.length > 0, "No network option found"); }
    do {
        this.node_config = node_config;
        this.addAddresses(Set!Address.from(peers));

        // add our own IP to the list of banned IPs to avoid
        // the node communicating with itself
        this.banned_addresses.put(
            format("http://%s:%s", this.node_config.address, this.node_config.port));
    }

    /// try to discover the network until we found
    /// all the validator nodes from our quorum set.
    public void discover ()
    {
        logInfo("Discovering from %s", this.known_addresses.byKey());

        while (!this.allPeersConnected())
        {
            this.connectNextAddresses();
            sleep(this.node_config.retry_delay.msecs);
        }

        logInfo("Discovery reached. %s peers connected.", this.peers.length);

        // the rest can be done asynchronously as we can already
        // start validating and voting on the blockchain
        runTask(()
        {
            while (!this.peerLimitReached())
            {
                this.connectNextAddresses();
                sleep(this.node_config.retry_delay.msecs);
            }
        });
    }

    /// Attempt connecting with the given address
    private void tryConnecting ( Address address )
    {
        // banned address
        if (this.isAddressBanned(address))
            return;

        if (address in this.connecting_addresses)
            return;

        this.connecting_addresses.put(address);

        logInfo("IP %s: Establishing connection..", address);
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

        // connection limit reached
        if (this.connecting_addresses.length >= MaxConnectingAddresses)
            return;

        // this should never assert, unless vibe.d starts another thread..
        assert(this.connecting_addresses.length < MaxConnectingAddresses);

        // max new addresses to connect to
        size_t free_connections = MaxConnectingAddresses -
            this.connecting_addresses.length;

        auto random_addresses = this.todo_addresses.pickRandom(
            free_connections);

        logInfo("Connecting to next set of addresses: %s",
            random_addresses);

        foreach (address; random_addresses)
        {
            this.todo_addresses.remove(address);

            if (!this.isAddressBanned(address) &&
                address !in this.connecting_addresses)
            {
                runTask(() { this.tryConnecting(address); });
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
}
