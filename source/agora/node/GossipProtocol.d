/*******************************************************************************

    Contains the code used for receiving, caching, and propagating messages.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.GossipProtocol;

import agora.common.Data;
import agora.common.Set;
import agora.node.Network;

/// Ditto
public class GossipProtocol
{
    /// Network manager for propagating the received message
    private NetworkManager network;

    /// Contains the message cache
    private Set!Hash msg_cache;


    /***************************************************************************

        Constructor

        Params:
            network = the network manager used for message propagation

    ***************************************************************************/

    public this (NetworkManager network)
    {
        this.network = network;
    }

    /***************************************************************************

        If this is the first time this message was received,
        propagate it to the network.

        Params:
            msg = the received message

    ***************************************************************************/

    public void receiveMessage (Hash msg) @safe
    {
        if (this.hasMessage(msg))
            return;

        this.msg_cache.put(msg);
        this.network.sendMessage(msg);
    }

    /***************************************************************************

        Check if this message is in the message cache.

        Params:
            msg = the received message

        Returns:
            Return true if this message was a message already received.

    ***************************************************************************/

    public bool hasMessage (Hash msg) @safe
    {
        return (msg in this.msg_cache) !is null;
    }
}
