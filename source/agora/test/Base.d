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
import agora.common.Block;
import agora.common.Config;
import agora.common.Data;
import agora.common.Hash;
import agora.common.Metadata;
import agora.common.Set;
import agora.common.Transaction;
import agora.common.crypto.Key;
import agora.node.Ledger;
import agora.node.Network;
import agora.node.Node;

import std.array;
import std.algorithm.iteration;
import std.exception;
import std.format;

/*******************************************************************************

    Create a set of chained transactions, where each transaction spends the
    entire sum of the previous transaction.

    Useful for quickly generating transactions for use with unittests.

    Params:
        root = the first transaction in the chain will spend the output of
               this transaction
        count = the number of transactions to create
        key_pair = the key pair used to sign transactions and to send
                   the output to

*******************************************************************************/

public Transaction[] getChainedTransactions (Transaction root, size_t count,
    KeyPair key_pair)
{
    Transaction[] transactions;
    Hash last_tx_hash = hashFull(root);

    foreach (idx; 0 .. count)
    {
        Transaction tx =
        {
            [Input(last_tx_hash, 0)],
            [Output(40_000_000, key_pair.address)]  // send to the same address
        };

        auto signature = key_pair.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        last_tx_hash = hashFull(tx);
        transactions ~= tx;
    }

    return transactions;
}

/*******************************************************************************

    Create a set of chained blocks, containing the provided transactions,
    and linking back to the provided root block.
    Note that the root block is not contained in the array,
    as it's already available at the call site.

    Params:
        root = the first block in the chain
        txes = the list of transactions to create the blocks for

*******************************************************************************/

public Block[] getChainedBlocks (Block root, Transaction[] txes)
{
    Block[] blocks;
    Block last_block = root;
    foreach (tx; txes)
    {
        // chain last block to previous last block
        last_block = makeNewBlock(last_block, tx);
        blocks ~= last_block;
    }

    return blocks;
}

/*******************************************************************************

    Base class for `NetworkManager` used in unittests

    The `NetworkManager` class is the mean used to communicate with other nodes.
    In regular build, it does network communication, but in unittests it should
    not do IO (or appear not to).

    In the current design, all nodes should be instantiated upfront,
    registered via `std.concurrency.register`, and located by `getClient`.

*******************************************************************************/

public class TestNetworkManager : NetworkManager
{
    static import std.concurrency;
    import geod24.LocalRest;
    import core.time;

    /// Used by the unittests in order to directly interact with the nodes,
    /// without trying to handshake or do any automatic network discovery.
    /// Also kept here to avoid any eager garbage collection.
    public RemoteAPI!TestAPI[PublicKey] apis;

    /// Workaround compiler bug that triggers in `std.concurrency`
    protected __gshared std.concurrency.Tid[string] tbn;

    /// Ctor
    public this () { super(); }

    /// ditto
    public this (NodeConfig config, in string[] peers, in string[] dns_seeds, Metadata metadata)
    {
        super(config, peers, dns_seeds, metadata);
        // NetworkManager assumes IP are used but we use pubkey
        this.banned_addresses.put(config.key_pair.address.toString());
    }

    ///
    protected final override API getClient (Address address)
    {
        if (auto ptr = address in tbn)
            return new RemoteAPI!API(*ptr);
        assert(0, "Trying to access node at address '" ~ address ~
               "' without first creating it");
    }

    /// Initialize a new node
    protected void createNewNode (PublicKey address, Config conf)
    {
        auto api = RemoteAPI!TestAPI.spawn!(TestNode!TestNetworkManager)(conf);
        tbn[address.toString()] = api.tid();
        this.apis[address] = api;
    }

    /***************************************************************************

        Start each of the nodes

        Params:
            count = Expected number of nodes

    ***************************************************************************/

    public void start ()
    {
        this.apis.each!(a => a.start());
    }

    /***************************************************************************

        Keep polling and waiting for nodes to all reach discovery,
        up to 10 attempts and a sleep time between each attempt;

        Returns:
            the public keys of the nodes which reached discovery

    ***************************************************************************/

    public PublicKey[] getDiscoveredNodes ()
    {
        import core.thread;
        import std.stdio;

        const attempts = 10;

        bool[PublicKey] fully_discovered;

        foreach (_; 0 .. attempts)
        {
            foreach (key, api; this.apis)
            try
            {
                if (api.getNetworkInfo().state == NetworkState.Complete)
                    fully_discovered[key] = true;
            }
            catch (Exception ex)
            {
                // just continue
            }

            // we're done
            if (fully_discovered.length == this.apis.length)
                break;

            // try again
            auto sleep_time = 1.seconds;  // should be enough time
            writefln("Sleeping for %s. Discovered %s/%s nodes", sleep_time,
                fully_discovered.length, this.apis.length);
            Thread.sleep(sleep_time);
        }

        return fully_discovered.byKey.array;
    }

    /// This is a hack
    protected override void runTask ( void delegate() dg)
    {
        static import geod24.LocalRest;
        geod24.LocalRest.runTask(dg);
    }

    /// Ditto
    protected override void wait (Duration dur)
    {
        static import geod24.LocalRest;
        geod24.LocalRest.sleep(dur);
    }
}

/// Temporary hack to work around the inability to do 'start' from main
public interface TestAPI : API
{
    ///
    public abstract void start();

    ///
    public abstract void metaAddPeer(string peer);
}

/// Ditto
public final class TestNode (Net) : Node!Net, TestAPI
{
    ///
    public this (Config config)
    {
        super(config);
    }

    ///
    public override void start ()
    {
        super.start();
    }

    /// Used by the node
    public override Metadata getMetadata (string _unused) @system
    {
        return new MemMetadata();
    }

    /// Used by unittests
    public override void metaAddPeer (Address peer)
    {
        this.metadata.peers.put(peer);
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
    by the `TestNetworkManager` implementation.

    Params:
        NetworkT = Type of `NetworkManager` to instantiate
        topology = Network topology to adopt
        nodes    = Number of nodes to instantiated
        configure_network = whether to set up the peers in the config

    Returns:
        The set of public key added to the node

*******************************************************************************/

public NetworkT makeTestNetwork (NetworkT : TestNetworkManager)
    (NetworkTopology topology, size_t nodes, bool configure_network = true)
{
    import std.algorithm;
    import std.array;
    import vibe.core.log;

    // by default emit only errors during unittests.
    // can be re-set by calling code.
    setLogLevel(LogLevel.error);

    // We know we're in the main thread
    // Vibe.d messes with the scheduler - reset it
    static import std.concurrency;
    std.concurrency.scheduler = null;

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

        foreach (idx; 0 .. nodes)
        {
            // note: cannot add our own key as a validator (there is a safety check)
            // todo: add this check in the unittests
            auto other_pairs = key_pairs[0 .. idx] ~ key_pairs[idx + 1 .. $];

            Config conf =
            {
                node : node_configs[idx],
                network : configure_network
                    ? assumeUnique(other_pairs.map!(k => k.address.toString()).array)
                    : null,
            };

            configs ~= conf;
        }

        auto net = new NetworkT();

        // Workaround https://issues.dlang.org/show_bug.cgi?id=20002
        TestNetworkManager base_net = net;

        foreach (idx, ref conf; configs)
        {
            const address = node_configs[idx].key_pair.address;
            base_net.createNewNode(address, conf);
        }

        return net;

    case NetworkTopology.Balanced:
    case NetworkTopology.Tiered:
    case NetworkTopology.Cyclic:
    case NetworkTopology.SinglePoF:
        assert(0, "Not implemented");
    }
}
