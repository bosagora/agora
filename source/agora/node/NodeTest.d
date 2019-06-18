/*******************************************************************************

    Contains the Node unittests.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.NodeTest;

import agora.node.Network;
import agora.node.Node;
import agora.common.API;
import agora.common.Config;
import agora.common.crypto.Key;

import vibe.d;

import std.array;
import std.algorithm;
import std.exception;

/*******************************************************************************

    Node registry / set

    This interface exposes basic functions to add, remove, and contact nodes.

    Each node maintains and requires a registry of nodes they know about.
    Among those nodes, some might not be trusted, some might be disabled, etc...
    As the result, the set of nodes in this registry might not be a quorum,
    but a larger set. It might also be a quorum, or a slice of it.
    Modifications of a set might affect dependent sets.

*******************************************************************************/

public interface INodeSet
{
@safe:

    /// Add the key & address to the node set
    public void add (PublicKey key, string address);

    /// Remove the key from the set
    public void remove (PublicKey key);

    /// Get the API of the specified key (or null if it doesn't exist)
    public API getAPI (PublicKey key);

    /// Get the array of all APIs
    public API[] getAllAPIs ( );
}

///
public abstract class TestRegistry : INodeSet
{
@safe:

    /// Map of pubkey to nodes
    protected API[PublicKey] registry;


    /***************************************************************************

        Factory method, map node names to instances

        Should either `assert` or `throw` if the identifier can't be matched,
        it should never return `null`.

        Params:
            key  = The key to use for this node
            name = Identifier describind the node to instantiate

        Returns:
            An non-`null` instance of an `API`

    ***************************************************************************/

    protected abstract API factory (Config config, string name);

    ///
    public void register (Config config, string name)
    {
        this.registry[config.node.key_pair.address] = this.factory(config, name);
    }

    ///
    public override void add (PublicKey key, string address)
    {
        assert(key in this.registry);
    }

    ///
    public override void remove (PublicKey key)
    {
    }

    ///
    public override API getAPI (PublicKey key)
    {
        if (auto api = key in this.registry)
            return *api;

        return null;
    }

    ///
    public override API[] getAllAPIs ( )
    {
        return this.registry.byValue.array;
    }
}

///
class TestNodeRegistry : TestRegistry
{
    ///
    public override API factory (Config config, string name) @trusted
    {
        static import std.concurrency;
        import geod24.LocalRest;

        string id = config.node.key_pair.address.toString();
        auto tid = std.concurrency.locate(id);
        if (tid != tid.init)
            return new RemoteAPI!(API, Node)(tid);

        switch (name)
        {
        case "normal":
            auto api = new RemoteAPI!(API, Node)(config);
            std.concurrency.register(id, api.tid());
            return api;
        default:
            assert(0, name);
        }
    }

    /// Wait a certain time until the nodes have reached discovery
    /// If after 10 query attempts they still all haven't discovered => assert
    public void waitUntilConnected ( )
    {
        import core.thread;
        import std.stdio;

        const attempts = 10;

        bool[PublicKey] fully_discovered;

        foreach (_; 0 .. attempts)
        {
            foreach (key, api; this.registry)
            try
            {
                auto net_info = api.getNetworkInfo();
                if (net_info.state == NetworkState.Complete)
                    fully_discovered[key] = true;
            }
            catch (Exception ex)
            {
                // just continue
            }

            // we're done
            if (fully_discovered.length == this.registry.length)
                break;

            // try again
            auto sleep_time = 1.seconds;  // should be enough time
            writefln("Sleeping for %s. Discovered %s/%s nodes", sleep_time,
                fully_discovered.length,
                this.registry.length);
            Thread.sleep(sleep_time);
        }

        enforce(fully_discovered.length == this.registry.length,
            format("Got %s/%s discovered nodes. Missing nodes: %s",
                fully_discovered.length,
                this.registry.length,
                this.registry.byKey.filter!(a => !!(a in fully_discovered))));
    }
}

/// Describes a network topology for testing purpose
public enum NetworkTopology
{
    /// 4 nodes which all know about each other. Figure 9 in the SCP paper.
    Simple,

    /// 4 nodes, 3 required, correspond to Figure 2 in the SCP paper
    Balanced,

    /// 10 nodes, Figure 3 in the SCP paper
    Tiered,

    /// 6 nodes, Figure 4 in the SCP paper
    Cyclic,

    /// Single point of failure, Figure 7 in the SCP paper
    SinglePoF,
}

/*******************************************************************************

    Creates a test network with the desired topology

    This function's only usage is to create the network topology.
    The actual behavior of the nodes that are part of the network is decided
    by the `TestRegistry` implementation and the `nodes` present.

    Params:
        registry = The registry to populate.
        topology = Network topology to adopt
        nodes = "Name" of the nodes to instantiate.
                For example, to test basic liveness / safety guarantee,
                one might want to include an ill-behaved node in the registry.
                How such an ill-behaved node will behave is defined by
                `registry.factory(nodes[idx])`.
                The number of entry required is defined by the topology and must
                match exactly.

    Returns:
        The set of public key added to the node

*******************************************************************************/

public const(PublicKey)[] makeTestNetwork (
    TestRegistry registry, NetworkTopology topology, in string[] nodes)
{
    import std.algorithm;
    import std.array;

    assert(nodes.length >= 2, "Creating a network require at least 2 nodes");

    // each port must be unique
    __gshared ushort last_used_port = 0xB0A;

    final switch (topology)
    {
    case NetworkTopology.Simple:
        immutable(Config)[] configs;
        immutable(KeyPair)[] key_pairs;
        NodeConfig[] node_configs;

        foreach (idx; 0 .. nodes.length)
        {
            key_pairs ~= KeyPair.random;

            NodeConfig node_conf =
            {
                key_pair : key_pairs[idx],
                address : "127.0.0.1",
                port : last_used_port,
                is_validator : true,
                retry_delay : 100, // msecs
            };

            last_used_port += 2;  // safest to skip more than one
            node_configs ~= node_conf;
        }

        // Nodes will have self as validator, but it doesn't matter
        // since we just ignore it
        foreach (idx; 0 .. nodes.length)
        {
            // note: cannot add our own key as a validator (there is a safety check)
            // todo: add this check in the unittests
            auto other_pairs = key_pairs[0 .. idx] ~ key_pairs[idx + 1 .. $];

            QuorumConfig all_quorums =
            {
                nodes : other_pairs.map!(a => a.address).array
            };

            // connect to other node's IPs, not ourselves!
            auto other_configs = node_configs[0 .. idx] ~ node_configs[idx + 1 .. $];

            Config conf =
            {
                node : node_configs[idx],
                quorums : [all_quorums],
                network : assumeUnique(other_configs.map!(
                    a => format("http://%s:%s", a.address, a.port)).array),
                logging : LoggingConfig(LogLevel.none)
            };

            verifyConfigFile(conf);

            configs ~= conf;
        }

        foreach (idx, ref conf; configs)
        {
            registry.register(conf, nodes[idx]);
        }

        return key_pairs.map!(a => a.address).array;

    case NetworkTopology.Balanced:
    case NetworkTopology.Tiered:
    case NetworkTopology.Cyclic:
    case NetworkTopology.SinglePoF:
        assert(0, "Not implemented");
    }
}

///
unittest
{
    import core.thread;
    import std.stdio;

    scope registry = new TestNodeRegistry;
    auto keys = registry.makeTestNetwork(
        NetworkTopology.Simple,
        [ "normal", "normal", "normal", "normal" ]);

    registry.waitUntilConnected();
}
