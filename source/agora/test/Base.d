/*******************************************************************************

    Contains utilities to be used by tests to easily set up test environments

    Since our business code is decoupled from our network code,
    thanks to the `vibe.web.rest` generator, we can fairly naturally make
    unittests for network behavior.
    By using the `localrest` library, we assign each node to a thread and use
    an RPC-style approach to call functions.
    This is non-deterministic, but models a real-life behaviour better.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Base;

version (unittest):

import agora.common.API;
import agora.common.Config;
import agora.common.Data;
import agora.common.crypto.Key;
import agora.node.Network;
import agora.node.Node;

import std.array;
import std.algorithm.iteration;
import std.exception;
import std.format;


/*******************************************************************************

    Base class for `Network` used in unittests

    The `Network` class is the mean used to communicate with other nodes.
    In regular build, it does network communication, but in unittests it should
    not do IO (or appear not to).

    In the current design, all nodes should be instantiated upfront,
    registered via `std.concurrency.register`, and located by `getClient`.

*******************************************************************************/

public class TestNetwork : Network
{
    static import std.concurrency;
    import geod24.LocalRest;

    /// 'Owning' reference to the nodes returned by `createNewNode` to avoid
    /// eager garbage collection
    private TestAPI[] apis;

    /// Ctor
    public this (NodeConfig config, in string[] peers)
    {
        super(config, peers);
    }

    ///
    protected final override API getClient (Address address)
    {
        auto tid = std.concurrency.locate(address);
        if (tid == tid.init)
        {
            assert(0, "Trying to access node at address '" ~ address ~
                   "' without first creating it");
        }
        return new RemoteAPI!API(tid);
    }

    /// Initialize a new node
    protected TestAPI createNewNode (Address address, Config conf)
    {
        auto api = RemoteAPI!TestAPI.spawn!(TestNode!TestNetwork)(conf);
        std.concurrency.register(address, api.tid());
        return api;
    }
}

/// Temporary hack to work around the inability to do 'start' from main
public interface TestAPI : API
{
    ///
    public abstract void start();
}

/// Ditto
public final class TestNode (Net) : Node!(Net), TestAPI
{
    ///
    public this (const Config config)
    {
        super(config);
    }

    ///
    public override void start ()
    {
        super.start();
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
    by the `TestNetwork` implementation.

    Params:
        NetworkT = Type of `Network` to instantiate
        topology = Network topology to adopt
        nodes    = Number of nodes to instantiated

    Returns:
        The set of public key added to the node

*******************************************************************************/

public NetworkT makeTestNetwork (NetworkT : TestNetwork)
    (NetworkTopology topology, size_t nodes)
{
    import std.algorithm;
    import std.array;

    assert(nodes >= 2, "Creating a network require at least 2 nodes");

    final switch (topology)
    {
    case NetworkTopology.Simple:
        immutable(Config)[] configs;
        immutable(KeyPair)[] key_pairs;
        NodeConfig[] node_configs;

        foreach (idx; 0 .. nodes)
        {
            key_pairs ~= KeyPair.random;

            NodeConfig node_conf =
            {
                key_pair : key_pairs[idx],
                retry_delay : 100, // msecs
            };

            node_configs ~= node_conf;
        }

        // Nodes will have self as validator, but it doesn't matter
        // since we just ignore it
        foreach (idx; 0 .. nodes)
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
                network : assumeUnique(other_pairs.map!(k => k.address.toString()).array),
            };

            configs ~= conf;
        }


        auto net = new NetworkT(NodeConfig.init, node_configs.map!(
            c => c.key_pair.address.toString()).array);
        foreach (idx, ref conf; configs)
        {
            net.apis ~= net.createNewNode(node_configs[idx].key_pair.address.toString(), conf);
        }

        net.apis.each!(a => a.start());
        return net;

    case NetworkTopology.Balanced:
    case NetworkTopology.Tiered:
    case NetworkTopology.Cyclic:
    case NetworkTopology.SinglePoF:
        assert(0, "Not implemented");
    }
}
