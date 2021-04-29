/*******************************************************************************

    Contains the flash Channel definition

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
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
import agora.crypto.Key;
import agora.crypto.Schnorr;

import core.time;

/// Flash configuration
public struct FlashConfig
{
    /// Whether or not this node should support the Flash API
    public bool enabled;

    /// Flash name registry address
    public string registry_address;

    // Network addresses that will be registered with the associated managed
    // public keys
    public immutable string[] addresses_to_register;

    /// Timeout for requests
    public Duration timeout = 10.seconds;

    /// The address to listen to for the control interface
    public string control_address = "127.0.0.1";

    /// The port to listen to for the control interface
    public ushort control_port = 0xB0C;

    /// Address to the listener which will receive payment / update notifications
    public string listener_address;

    /// Minimum funding allowed for a channel
    public Amount min_funding = Amount(0);

    /// Maximum funding allowed for a channel
    public Amount max_funding = Amount(100_000);

    /// Minimum number of blocks before settling can begin after trigger published
    public uint min_settle_time = 10;

    /// Maximum number of blocks before settling can begin after trigger published
    public uint max_settle_time = 100;

    /// Maximum time spent retrying requests before they're considered failed
    public Duration max_retry_time = 60.seconds;

    /// The maximum retry delay between retrying failed requests. Should be lower
    /// than `max_retry_time`
    public Duration max_retry_delay = 2000.msecs;

    /// Multiplier for the truncating exponential backoff retrying algorithm
    public uint retry_multiplier = 10;
}

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

    /// Indicates which peer is updating it's end
    public PaymentDirection direction;

    /// Fixed fee that should be paid for each payment
    public Amount fixed_fee;

    /// Proportional fee that should be paid for each BOA
    public Amount proportional_fee;

    /// the minimum number of blocks a node requires to be
    /// added to the expiry of HTLCs
    public uint htlc_delta;

    /// The linearly increasing update index of this update. Only channel
    /// updates with a greater update index will be accepted by a node.
    public uint update_idx;

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

    /***************************************************************************

        Compares everything except the signature

        Params:
            other = the other value

    ***************************************************************************/

    public bool opEquals (in ChannelUpdate other)
        const pure nothrow @safe @nogc
    {
        return this.chan_id == other.chan_id
            && this.direction == other.direction
            && this.fixed_fee == other.fixed_fee
            && this.proportional_fee == other.proportional_fee;
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

    ChannelUpdate update_1;
    ChannelUpdate update_2;
    assert(update_1 == update_2);
    update_2.sig = sign(kp, update_2);
    assert(update_1 == update_2);  // still equal
}

/***************************************************************************

    Calculate total fee from the given update and payment total

    Params:
        update = latest update for the channel
        total = payment total

    Returns:
        Total Amount of required fee

***************************************************************************/

public Amount getTotalFee (ChannelUpdate update, Amount total) @safe nothrow
{
    Amount fee = update.fixed_fee;
    Amount proportional_fee = total.proportionalFee(update.proportional_fee);
    if (!proportional_fee.isValid())
        return proportional_fee;
    fee.add(proportional_fee);
    return fee;
}

unittest
{
    auto update = ChannelUpdate(Hash.init, PaymentDirection.TowardsOwner, 1.coins, 1.coins);
    assert(update.getTotalFee(10.coins) == 11.coins);
    assert(!update.getTotalFee(Amount.MaxUnitSupply).isValid());
}
