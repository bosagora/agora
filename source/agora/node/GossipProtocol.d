/*******************************************************************************

    Contains the code used for receiving, caching, and propagating transactions.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.GossipProtocol;

import agora.common.Data;
import agora.common.Hash;
import agora.common.Set;
import agora.common.Transaction;
import agora.node.Ledger;
import agora.node.Network;

/// Ditto
public class GossipProtocol
{
    /// Network manager for propagating received transactions
    private NetworkManager network;

    /// Blockchain ledger
    private Ledger ledger;

    /// Contains the transaction cache
    private Transaction[Hash] tx_cache;


    /***************************************************************************

        Constructor

        Params:
            network = the network manager used for transaction propagation
            ledger = the blockchain ledger

    ***************************************************************************/

    public this (NetworkManager network, Ledger ledger)
    {
        this.network = network;
        this.ledger = ledger;
    }

    /***************************************************************************

        If this is the first time this transaction was received,
        propagate it to the network.

        Params:
            tx = the received transaction

    ***************************************************************************/

    public void receiveTransaction (Transaction tx) @safe
    {
        auto tx_hash = hashFull(tx);
        if (this.hasTransactionHash(tx_hash))
            return;

        if (this.ledger.acceptTransaction(tx))
        {
            this.tx_cache[tx_hash] = tx;
            this.network.sendTransaction(tx);
        }
    }

    /***************************************************************************

        Check if this transaction is in the transaction cache.

        Params:
            tx = the received transaction

        Returns:
            Return true if this transaction was a transaction already received.

    ***************************************************************************/

    public bool hasTransactionHash (Hash hash) @safe
    {
        return (hash in this.tx_cache) !is null;
    }
}
