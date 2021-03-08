/*******************************************************************************

    Contains the flash Channel definition

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.Config;

import agora.flash.Types;

import agora.common.Amount;
import agora.common.Types;
import agora.consensus.data.Transaction;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Schnorr;

import core.time;

/// Channel configuration. These fields remain static throughout the
/// lifetime of the channel. All of these fields are public and known
/// by all participants in the channel.
public struct ChannelConfig
{
    /// Hash of the genesis block, used to determine which blockchain this
    /// channel belongs to.
    public Hash gen_hash;

    /// Public key of the funder of the channel.
    public Point funder_pk;

    /// Public key of the counter-party to the channel.
    public Point peer_pk;

    /// Sum of `funder_pk + peer_pk`.
    public Point pair_pk;

    /// Total number of co-signers needed to make update/settlement transactions
    /// in this channel.
    public /*const*/ uint num_peers;

    /// The public key sum used for validating Update transactions.
    /// This key is derived and remains static throughout the
    /// lifetime of the channel.
    public /*const*/ Point update_pair_pk;

    /// The funding transaction from which the trigger transaction may spend.
    /// This transaction is unsigned - only the funder may sign & send it
    /// to the agora network for externalization. The peer can retrieve
    /// the signature when it detects this transaction is in the blockchain.
    public Transaction funding_tx;

    /// Hash of the funding transaction above.
    public Hash funding_tx_hash;

    /// The utxo that will actually be spent from the funding tx (just index 0)
    public Hash funding_utxo;

    /// The total amount funded in this channel. This information is
    /// derived from the Outputs of the funding transaction.
    public Amount capacity;

    /// The settle time to use for the settlement transactions. This time is
    /// verified by the `OP.VERIFY_UNLOCK_AGE` opcode in the lock script
    /// of the trigger / update transactions.
    public uint settle_time;

    /// How long a node will wait for a response after some calls to
    /// `closeChannel` before the node decides to unilaterally close the channel.
    /// This is only an informative value and cannot be guaranteed by the
    /// protocol, but it gives well-behaved nodes an ability to mutually agree
    /// on a sufficiently long delay before a unilateral close is attempted.
    /// note: using `ulong` due to Serializer errors with Duration
    public ulong cooperative_close_timeout;

    /// The channel's ID is derived from the hash of the funding transaction.
    public alias chan_id = funding_tx_hash;
}

/// Channel update. Peers can update some channel attributes on the fly.
public struct ChannelUpdate
{
    /// The channel ID
    public Hash chan_id;

    /// Indicated which peer is updating it's end
    public PaymentDirection direction;

    /// Fixed fee that should paid for each payment
    public Amount fixed_fee;

    /// Proportional fee that should paid for each BOA
    public Amount proportional_fee;

    /// Signature of the channel peer
    public Signature sig;

    /***************************************************************************

        Implements hashing support

        Params:
            dg = hashing function

    ***************************************************************************/

    public void computeHash (scope HashDg dg) const nothrow @safe @nogc
    {
        hashPart(this.chan_id, dg);
        hashPart(this.direction, dg);
        hashPart(this.fixed_fee, dg);
        hashPart(this.proportional_fee, dg);
    }
}

unittest
{
    Pair kp = Pair.random();
    auto update = ChannelUpdate(Hash.init,
        PaymentDirection.TowardsOwner,
        Amount(44), Amount(37));
    update.sig = sign(kp, update);
    assert(verify(kp.V, update.sig, update));
}
