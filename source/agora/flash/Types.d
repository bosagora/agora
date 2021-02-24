/*******************************************************************************

    Contains the common types used by the Flash node and the API,
    as well as some helper types.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.Types;

import agora.common.Amount;
import agora.common.Types;
import agora.consensus.data.Transaction;
import agora.crypto.ECC;
import agora.crypto.Schnorr;
import agora.flash.ErrorCode;

import std.conv;
import std.format;

/// Tracks the current state of the channel.
/// States can only move forwards, and never back.
/// Once a channel is closed, it may never be re-opened again.
public enum ChannelState
{
    /// Channel is not being set up yet
    None,

    /// Cooperating on the initial trigger and settlement txs.
    SettingUp,

    /// Waiting for the funding tx to appear in the blockchain.
    WaitingForFunding,

    /// The channel is open and ready for new balance update requests.
    Open,

    /// A channel closure was requested. New balance update requests will
    /// be rejected. For safety reasons, the channel's metadata should be kept
    /// around until the channel's state becomes `Closed`.
    PendingClose,

    /// The funding transaction has been spent and externalized.
    /// This marks the channel as closed.
    /// New channels cannot use the same funding UTXO since it was spent,
    /// therefore it's safe to delete this channel's data when it reaches this
    /// closed state.
    Closed,
}

/// The settle & update pair for a given sequence ID
public struct UpdatePair
{
    /// The sequence ID of this slot
    public uint seq_id;

    /// Settle tx which spends from `update_tx` below
    public Transaction settle_tx;

    /// Update tx which spends the trigger tx's outputs and can replace
    /// any previous update containing a lower sequence ID than this one's.
    public Transaction update_tx;
}

/// A pair of settlement and update public nonces used for signing
public struct PublicNonce
{
    /// The public nonce for the settlement transaction
    public Point settle;

    /// The public nonce for the update transaction
    public Point update;
}

/// A pair of settlement and update private nonces used for signing.
/// This must be kept secret.
public struct PrivateNonce
{
    /// The private nonce for the settlement transaction
    public Pair settle;

    /// The private nonce for the update transaction
    public Pair update;
}

/// Contains the minimum amount of information that needs to be shared with
/// the counter-party in order to make it possible for them to regenerate
/// the HTLC on their side
public struct HTLC
{
    /// Lock height
    public Height lock_height;

    /// Amount
    public Amount amount;
}

/// Contains the balance towards each channel participant
public struct Balance
{
    /// Refund back to channel funder
    public Amount refund_amount;

    /// Payment to counter-party
    public Amount payment_amount;

    /// HTLCs we're offering to the counter-party in return for a secret
    public HTLC[Hash] outgoing_htlcs;
}

/*******************************************************************************

    Embeds a return value for an API as well as any error code and
    an optional message.

    Params:
        T = the type stored as the `value` field

*******************************************************************************/

public struct Result (T)
{
    /// The error code, if any
    public ErrorCode error;

    /// The error message, if any
    public string message;

    /// The result, only valid if `error != ErrorCode.None`
    public T value;

    /***************************************************************************

        Ctor when there was no error

        Params:
            value = value to store

    ***************************************************************************/

    public this (T value)
    {
        this.value = value;
    }

    /***************************************************************************

        Ctor when there was an error, with an optional message.

        Params:
            error = the error code. Must not be `ErrorCode.None`
            message = optional message.

    ***************************************************************************/

    public this (ErrorCode error, string message = null)
    {
        assert(error != ErrorCode.None);
        this.error = error;
        this.message = message;
    }

    // For the deserializer, should not be used by any other code
    public this (typeof(this.tupleof) fields, string mod = __MODULE__)
    {
        // precaution
        assert(mod == "agora.common.Serializer", mod);
        this.tupleof[] = fields[];
    }

    /// Convenience
    public string toString ()
    {
        if (this.error == ErrorCode.None)
            return format("%s", this.value);
        else
            return format("(Code: %s) %s", this.error, this.message);
    }
}

/// Helper routine
public string prettify (T)(T input)
{
    return input.to!string[0 .. 6];
}

/// Clone any type via the serializer
public T clone (T)(in T input)
{
    import agora.common.Serializer;
    return input.serializeFull.deserializeFull!T;
}
