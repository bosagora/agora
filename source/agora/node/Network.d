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

import libsodium.crypto_sign_ed25519;
import libsodium.randombytes;

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
const MaxConnectingAddresses = 10;

/// Note: cases which need to be handled:
/// - node disconnnects during discovery => we should re-try it later (if we need more IPs)
/// - new node connects at a random time during discovery => we should ask for its peers
class Network
{
    /// Config instance
    private const Config config;

    /// The configured quorum set validators
    private Set!PublicKey expected_validators;

    /// The connected validator nodes
    private RemoteNode[PublicKey] validators;

    /// The connected listener nodes
    private RemoteNode[PublicKey] listeners;

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
    public this ( Config config )
    {
        this.config = config;

        // add our own IP to the list of banned IPs to avoid
        // the node communicating with itself
        this.banned_addresses.put(
            format("http://%s:%s", this.config.node.address, this.config.node.port));

        getAllValidators(this.config.quorums, this.expected_validators);
        enforce(this.expected_validators.length != 0);
    }

    /// try to discover the network until we found
    /// all the validator nodes from our quorum set.
    public void discover ()
    {
        logInfo("Discovering from %s", this.config.network);
        this.addAddresses(Set!Address.from(this.config.network));

        while (!this.allQuorumNodesFound())
        {
            this.connectNextAddresses();
            sleep(this.config.node.retry_delay.msecs);
        }

        logInfo("Discovery reached. %s quorum validators connected out of %s.",
            this.validators.length, this.expected_validators.length);

        // the rest can be done asynchronously as we can already
        // start validating and voting on the blockchain
        runTask(()
        {
            while (!this.listenerLimitReached())
            {
                this.connectNextAddresses();
                sleep(this.config.node.retry_delay.msecs);
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
        auto node = new RemoteNode(address, new RestInterfaceClient!API(address),
            this.config);

        node.getReady(
            (net_info) { this.addAddresses(net_info.addresses); },
            &this.onNodeConnected);
    }

    private void onNodeConnected ( RemoteNode node )
    {
        // known validator
        if (node.key in this.expected_validators)
        {
            // sanity check: must be a validator node
            enforce(node.pub_conf.is_validator,
                format("Node '%s' is part of our quorum slice, but it is " ~
                       "not a validator node!", node.key));

            logInfo("Established connection with a quorum validator: %s",
                node.key);
            this.validators[node.key] = node;
        }
        else if (!this.listenerLimitReached())
        {
            logInfo("Established connection with listener: %s", node.key);
            this.listeners[node.key] = node;
        }
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
    private bool allQuorumNodesFound ( )
    {
        return this.validators.length >= this.expected_validators.length;
    }

    private bool listenerLimitReached ( )
    {
        return this.listeners.length >= this.config.node.max_listeners;
    }

    /// Returns: the list of node IPs this node is connected to
    public NetworkInfo getNetworkInfo ()
    {
        return NetworkInfo(
            this.allQuorumNodesFound()
                ? NetworkState.Complete : NetworkState.Incomplete,
            this.known_addresses);
    }
}
