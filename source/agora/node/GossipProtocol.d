/*******************************************************************************

    Contains the code used for receiving, caching, and propagating transactions.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.GossipProtocol;

import agora.common.Types;
import agora.common.Hash;
import agora.common.Set;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreimageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXOSet;
import agora.consensus.EnrollmentManager;
import agora.network.NetworkManager;
import agora.node.Ledger;

import agora.utils.Log;
mixin AddLogger!();

/// Ditto
public class GossipProtocol
{
    /// Network manager for propagating received transactions
    private NetworkManager network;

    /// Blockchain ledger
    private Ledger ledger;

    /// Enrollment manager
    private EnrollmentManager enroll_man;


    /***************************************************************************

        Constructor

        Params:
            network = the network manager used for transaction propagation
            ledger = the blockchain ledger
            enroll_man = the enrollment manager

    ***************************************************************************/

    public this (NetworkManager network, Ledger ledger,
        EnrollmentManager enroll_man)
    {
        this.network = network;
        this.ledger = ledger;
        this.enroll_man = enroll_man;
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
            this.network.sendTransaction(tx);
            this.ledger.tryNominateTXSet();
        }
    }

    /***************************************************************************

        Check if this transaction is in the transaction pool.

        Params:
            hash = hash of a transaction

        Returns:
            Return true if this transaction was a transaction already received.

    ***************************************************************************/

    public bool hasTransactionHash (Hash hash) @safe
    {
        return this.ledger.hasTransactionHash(hash);
    }

    /***************************************************************************

        If this is the first time this enrollment was received,
        propagate it to the network.

        Params:
            enroll = the received data for the enrollment
            finder = the UTXO finder delegate

    ***************************************************************************/

    public void receiveEnrollment (Enrollment enroll, scope UTXOFinder finder) @safe
    {
        if (this.enroll_man.add(this.ledger.getBlockHeight(), finder,
            enroll))
        {
            this.network.sendEnrollment(enroll);
        }
    }

    /***************************************************************************

        If this is new pre-image, add it to the enrollment manager,
        propagate it to the network.

        Params:
            enroll = the pre-image information to add & propagate

    ***************************************************************************/

    public void receivePreimage (PreimageInfo preimage) @safe
    {
        if (this.enroll_man.addPreimage(preimage))
        {
            this.network.sendPreimage(preimage);
        }
    }
}
