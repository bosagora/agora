/*******************************************************************************

    Contains in-memory representation of Lightning Network topology

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.Network;

import agora.flash.Config;
import agora.flash.Channel;
import agora.flash.Route;

import agora.common.Set;
import agora.common.Amount;
import agora.crypto.ECC;
import agora.crypto.Hash;

private struct NetworkNode
{
    /// Channels that this NetworkNode is a part of
    private Set!Hash[Point] channels;
}

public class Network
{
    /// Nodes
    private NetworkNode[Point] nodes;

    /// Delegate to lookup Channels by their ID
    private Channel delegate (Hash chan_id) @safe nothrow lookupChannel;

    /// Ctor
    this (Channel delegate (Hash chan_id) @safe nothrow lookupChannel)
    {
        this.lookupChannel = lookupChannel;
    }

    /***************************************************************************

        Add a Channel to the network

        Params:
            chan_conf = ChannelConfig of the Channel to be added

    ***************************************************************************/

    public void addChannel (const ref ChannelConfig chan_conf) @safe nothrow
    {
        const funder_pk = chan_conf.funder_pk;
        const peer_pk = chan_conf.peer_pk;

        this.addChannel(funder_pk, peer_pk, chan_conf);
        this.addChannel(peer_pk, funder_pk, chan_conf);
    }

    private void addChannel (Point peer1_pk, Point peer2_pk,
        const ref ChannelConfig chan_conf) @safe nothrow
    {
        const chan_id = chan_conf.chan_id;

        if (peer1_pk !in this.nodes)
            this.nodes[peer1_pk] = NetworkNode.init;

        if (auto chns = (peer2_pk in this.nodes[peer1_pk].channels))
            chns.put(chan_id);
        else
            this.nodes[peer1_pk].channels[peer2_pk] = Set!Hash.from([chan_id]);
    }

    /***************************************************************************

        Add multiple Channels to the network

        Params:
            chns = List of ChannelConfig

    ***************************************************************************/

    public void addChannels (const ref ChannelConfig[] chns) @safe nothrow
    {
        foreach (chn; chns)
            this.addChannel(chn);
    }

    /***************************************************************************

        Remove a Channel from the network

        Params:
            chan_conf = ChannelConfig of the Channel to be removed

    ***************************************************************************/

    public void removeChannel (const ref ChannelConfig chan_conf) @safe nothrow
    {
        const funder_pk = chan_conf.funder_pk;
        const peer_pk = chan_conf.peer_pk;

        this.removeChannel(funder_pk, peer_pk, chan_conf);
        this.removeChannel(peer_pk, funder_pk, chan_conf);
    }

    private void removeChannel (Point peer1_pk, Point peer2_pk,
        const ref ChannelConfig chan_conf) @safe nothrow
    {
        const chan_id = chan_conf.chan_id;

        // Remove channels
        this.nodes[peer1_pk].channels[peer2_pk].remove(chan_id);

        // If no channels remain, remove the peer
        if (this.nodes[peer1_pk].channels[peer2_pk].length == 0)
            this.nodes[peer1_pk].channels.remove(peer2_pk);

        // If no peers remain, remove the node
        if (this.nodes[peer1_pk].channels.length == 0)
            this.nodes.remove(peer1_pk);
    }

    /***************************************************************************

        Remove multiple Channels from the network

        Params:
            chns = List of ChannelConfig

    ***************************************************************************/

    public void removeChannels (const ref ChannelConfig[] chns) @safe nothrow
    {
        foreach (chn; chns)
            this.removeChannel(chn);
    }

    /***************************************************************************

        Build a path between two nodes in the network

        Params:
            from_pk = Source node public key
            to_pk = Destination node public key
            amount = Amount of the payment
            ignore_chans = Channels to ignore

        Returns:
            If found, path from source to destination

    ***************************************************************************/

    public Hop[] getPaymentPath (Point from_pk, Point to_pk, Amount amount,
        Set!Hash ignore_chans = Set!Hash.init) @safe nothrow
    {
        import std.typecons;
        import std.algorithm.mutation : reverse;

        // Unknown nodes
        if (from_pk !in this.nodes || to_pk !in this.nodes)
            return null;

        Amount[Point] fees;
        Hop[Point] prev;
        Set!Point unvisited;

        foreach (pk; this.nodes.byKey())
        {
            fees[pk] = pk == from_pk ? Amount(0) : Amount.MaxUnitSupply;
            unvisited.put(pk);
        }

        while (unvisited.length > 0)
        {
            import std.algorithm;
            import std.array;

            // Pick the node with the smallest fee
            Point min_pk = unvisited[].map!(node => tuple(node, fees[node]))
                .minElement!"a[1]"[0];

            // Rest of the nodes are unreachable, terminate
            if (fees[min_pk] == Amount.MaxUnitSupply)
                break;

            auto min_node = this.nodes[min_pk];

            foreach (peer_pk; min_node.channels.byKey())
                if (peer_pk in unvisited)
                {
                    auto chans = min_node.channels[peer_pk][]
                        .filter!(chan => chan !in ignore_chans).array;

                    if (chans.length == 0)
                        continue;

                    // TODO: Pick the channel with the lowest fee from the list
                    // TODO: Verify that the channel is open
                    auto chan = chans[0];
                    auto chan_fee = Amount(1);

                    auto total_fee = fees[min_pk];
                    total_fee.mustAdd(chan_fee);
                    if (total_fee < fees[peer_pk])
                    {
                        fees[peer_pk] = total_fee;
                        prev[peer_pk] = Hop(min_pk, chan, chan_fee);
                    }
                }

            unvisited.remove(min_pk);
            if (min_pk == to_pk)
                break;
        }
        // No path found
        if (to_pk !in prev)
            return null;

        Hop[] path;
        // Trace the path from destination to source
        do
        {
            auto hop = prev[to_pk];
            path ~= Hop(to_pk, hop.chan_id, hop.fee);
            to_pk = hop.pub_key;
        } while(to_pk != from_pk);

        return path.reverse();
    }

    version (unittest) this () { }

    unittest
    {
        auto ln = new Network();
        ChannelConfig conf;
        conf.funder_pk = Scalar.random().toPoint();
        conf.peer_pk = Scalar.random().toPoint();
        conf.chan_id = hashFull(1);
        ln.addChannel(conf);

        conf.funder_pk = conf.peer_pk;
        conf.peer_pk = Scalar.random().toPoint();
        conf.chan_id = hashFull(2);
        ln.addChannel(conf);

        assert(ln.nodes.length == 3);
        ln.removeChannel(conf);
        assert(ln.nodes.length == 2);
        assert(conf.peer_pk !in ln.nodes);
    }
}

unittest
{
    import std.range;
    import std.algorithm;

    auto ln = new Network();
    Point[] pks;
    iota(5).each!(idx => pks ~= Scalar.random().toPoint());

    ChannelConfig conf;
    conf.funder_pk = pks[0];
    conf.peer_pk = pks[1];
    conf.chan_id = hashFull(1);
    ln.addChannel(conf);
    // #0 -- #1

    conf.funder_pk = pks[0];
    conf.peer_pk = pks[2];
    conf.chan_id = hashFull(2);
    ln.addChannel(conf);
    // #0 -- #1
    //    \__ #2

    auto path = ln.getPaymentPath(pks[0], pks[1], Amount(1));
    assert(path.length == 1);
    assert(path[0].pub_key == pks[1]);
    assert(path[0].chan_id == hashFull(1));

    path = ln.getPaymentPath(pks[0], pks[2], Amount(1));
    assert(path.length == 1);
    assert(path[0].pub_key == pks[2]);
    assert(path[0].chan_id == hashFull(2));

    path = ln.getPaymentPath(pks[1], pks[2], Amount(1));
    assert(path.length == 2);
    assert(path[0].pub_key == pks[0]);
    assert(path[0].chan_id == hashFull(1));
    assert(path[1].pub_key == pks[2]);
    assert(path[1].chan_id == hashFull(2));

    conf.funder_pk = pks[3];
    conf.peer_pk = pks[4];
    conf.chan_id = hashFull(3);
    ln.addChannel(conf);
    // #0 -- #1
    //    \__ #2    #3 -- #4

    foreach (node1; 0 .. 3)
        foreach (node2; 3 .. 5)
            assert(ln.getPaymentPath(pks[node1], pks[node2], Amount(1)) == null);

    path = ln.getPaymentPath(pks[3], pks[4], Amount(1));
    assert(path.length == 1);
    assert(path[0].pub_key == pks[4]);
    assert(path[0].chan_id == hashFull(3));

    conf.funder_pk = pks[1];
    conf.peer_pk = pks[2];
    conf.chan_id = hashFull(4);
    ln.addChannel(conf);
    // #0 -- #1
    //   \    |
    //    \__ #2    #3 -- #4

    path = ln.getPaymentPath(pks[1], pks[2], Amount(1));
    assert(path.length == 1);
    assert(path[0].pub_key == pks[2]);
    assert(path[0].chan_id == hashFull(4));

    // Ignore the direct channel between #0 and #2
    path = ln.getPaymentPath(pks[0], pks[2], Amount(1), Set!Hash.from([hashFull(2)]));
    assert(path.length == 2);
    assert(path[0].pub_key == pks[1]);
    assert(path[0].chan_id == hashFull(1));
    assert(path[1].pub_key == pks[2]);
    assert(path[1].chan_id == hashFull(4));
}
