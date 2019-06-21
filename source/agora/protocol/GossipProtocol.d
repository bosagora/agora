/*******************************************************************************

    Contains the code used for peer-to-peer communication.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.protocol.GossipProtocol;
import agora.node.Network;
import agora.common.Data;
import agora.common.Cache;

alias MessageCache = Cache!(Hash, bool);

/// Procedure of peer-to-peer communication
class GossipProtocol {
    private Network network;
    private Cache!(Address, MessageCache) sendMsgCache;
    private MessageCache receivedMsgCache;

    /// Ctor
    public this (Network network) {
        this.network = network;
    }

    /// Call this message when receive message.
    public bool receiveMessage(Hash msg) {
        if (this.receivedMsgCache.exists(msg)) return false;
        this.receivedMsgCache.put(msg, true);

        this.sendMessage(msg);
        return true;
    }

    /// Send a message only to the node passed by the filter delegate
    public void sendMessage(Hash msg) {
        this.network.sendMessage(msg, (Address address) {
            if (this.sendMsgCache.exists(address) && this.sendMsgCache.get(address).exists(msg)) {
                return false; 
            }
            if (this.sendMsgCache.exists(address)) {
                this.sendMsgCache.get(address).put(msg, true);
            } else {
                MessageCache newCache;
                newCache.put(msg, true);
                this.sendMsgCache.put(address, newCache);
            }
            return true;
        });
    }
}
