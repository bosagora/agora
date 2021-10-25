/*******************************************************************************

    Contains the common types used by the Flash node and the API,
    as well as some helper types.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.Types;

import agora.common.Amount;
import agora.common.Types;
import agora.consensus.data.Transaction;
import agora.crypto.ECC;
import agora.crypto.Key;
import agora.crypto.Schnorr;
import agora.flash.ErrorCode;
import agora.serialization.Serializer;
import agora.script.Signature;
import agora.utils.Test;

import std.conv;
import std.format;
import std.traits;

public enum PaymentDirection
{
    /// refund towards us
    TowardsOwner,

    /// payment towards the counter-party
    TowardsPeer
}

/// Tracks the current state of the channel.
/// States can only move forwards, and never back.
/// Once a channel is closed, it may never be re-opened again.
public enum ChannelState
{
    /// The channel is being negotiated for opening with the counter-party.
    /// Later it may transition to either Rejected or SettingUp (if accepted).
    Negotiating,

    /// Channel open request has been rejected by the counter-party
    Rejected,

    /// Channel has been started (counter-party accepted open proposal).
    /// Now cooperating on the initial trigger and settlement txs.
    SettingUp,

    /// Waiting for the funding tx to appear in the blockchain.
    WaitingForFunding,

    /// The channel is open and ready for new balance update requests.
    Open,

    /// A channel closure was requested either by the wallet or by the
    /// counter-party. New balance update requests will be rejected.
    //// For safety reasons the channel's metadata should be kept
    /// around until the channel's state becomes `Closed`.
    StartedCollaborativeClose,

    /// The counter-party rejected collaboratively closing this channel.
    /// The wallet has the option to either unilaterally close the channel,
    /// or to attempt a collaborative close again at a later point.
    RejectedCollaborativeClose,

    /// The channel is being unilaterally closed by publishing an
    /// update transaction to the blockchain.
    StartedUnilateralClose,

    /// Waiting for the settlement branch to be unlocked in the update tx's
    /// Output. Once it's unlocked, the settlement will be published. Once
    /// the settlement is externalized, the channel will be set to Closed.
    WaitingOnSettlement,

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

    /// Our portion of the settlement multi-sig
    public Signature our_settle_sig;

    /// Update tx which spends the trigger tx's outputs and can replace
    /// any previous update containing a lower sequence ID than this one's.
    public Transaction update_tx;

    /// Our portion of the update multi-sig
    public SigPair our_update_sig;

    /// Our portion of the update multi-sig
    public SigPair multi_update_sig;
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

    /// HTLCs we've been offered by the counter-party in return for a secret
    public HTLC[Hash] incoming_htlcs;

    /// HTLCs we're offering to the counter-party in return for a secret
    public HTLC[Hash] outgoing_htlcs;


    /***************************************************************************

        Serialization support

        Params:
            dg = Serialize delegate

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) const @safe
    {
        serializePart(this.refund_amount, dg);
        serializePart(this.payment_amount, dg);
        serializePart(serializeMap(this.incoming_htlcs), dg);
        serializePart(serializeMap(this.outgoing_htlcs), dg);
    }

    /***************************************************************************

        Returns a newly instantiated `Balance` of type `QT`

        Params:
            QT = Qualified type of `Balance` to return
            dg   = Delegate to read binary data
            opts = Deserialization options (should be forwarded)

        Returns:
            A new instance of type `QT`

    ***************************************************************************/

    public static QT fromBinary (QT) (
        scope DeserializeDg dg, in DeserializerOptions opts) @safe
    {
        Balance balance =
        {
            refund_amount : deserializeFull!Amount(dg, opts),
            payment_amount : deserializeFull!Amount(dg, opts),
            incoming_htlcs : deserializeFull!(SerializeMap!(HTLC[Hash]))(dg, opts),
            outgoing_htlcs : deserializeFull!(SerializeMap!(HTLC[Hash]))(dg, opts),
        };
        return (() @trusted => cast(QT)balance)();
    }
}

/// Channel information for Wallets
public struct ChannelInfo
{
    /// The associated channel ID
    public Hash chan_id;

    /// The original funder of this channel (managed by the Wallet)
    public PublicKey owner_key;

    /// The counter-party of this channel
    public PublicKey peer_key;

    /// The amount that's currently held by the owner
    public Amount owner_balance;

    /// The amount that's currently held by the counter-party
    public Amount peer_balance;

    /// The current channel state (e.g. open / closed / etc)
    public ChannelState state;
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
        this.tupleof[] = fields[];
    }

    /// Convenience
    public string toString () const @safe
    {
        if (this.error == ErrorCode.None)
            return format("%s", this.value);
        else
            return format("(Code: %s) %s", this.error, this.message);
    }
}

private struct WKName
{
    string name;
    PublicKey address;
}

private static immutable WKName[] pk_keys = [
    { "Alice",   WK.Keys.A.address, },
    { "Diego",   WK.Keys.D.address, },
    { "Charlie", WK.Keys.C.address, },
];

/// Helper routine
public string flashPrettify (T)(T input)
{
    // some well-known key-pairs used in the flash tests
    static if (is(immutable(T) == immutable(PublicKey))
        || is(immutable(T) == immutable(Point)))
    {
        foreach (const ref known; pk_keys)
            if (known.address == input)
                return known.name;
    }

    return input.to!string[0 .. 8];
}

///
unittest
{
    import agora.crypto.Key;
    import agora.utils.Test;
    assert(flashPrettify(Point(WK.Keys[0].address[])) == "Alice");
    assert(flashPrettify(WK.Keys[0].address) == "Alice");
    static immutable string s = "0x1000000000000000000000000000000014def9dea2f79cd65812631a5cf5d3ec";
    assert(flashPrettify(Scalar.fromString(s).toPoint()) == "0xe66666",
        flashPrettify(Scalar.fromString(s).toPoint()));
    assert(flashPrettify(PublicKey(Scalar.fromString(s).toPoint())) == "boa1xpvx",
        flashPrettify(PublicKey(Scalar.fromString(s).toPoint())));
}

/// Clone any type via the serializer
public T clone (T)(in T input)
{
    import agora.serialization.Serializer;
    return input.serializeFull.deserializeFull!T;
}

/// Rudimentary support for serializing hashmaps
public struct SerializeMap (Value : Value[Key], Key)
{
    /// Type of the map
    private alias Map = Value[Key];

    /// The map
    public Map _map;

    ///
    public alias _map this;

    /***************************************************************************

        Serialization support

        Params:
            dg = Serialize delegate

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) const @safe
    {
        serializePart(this._map.length, dg);
        foreach (const ref pair; this._map.byKeyValue)
        {
            serializePart(pair.key, dg);

            // nested AA
            static if (isAssociativeArray!Value)
            {
                serializePart(pair.value.length, dg);
                foreach (key, val; pair.value)
                {
                    serializePart(key, dg);
                    serializePart(val, dg);
                }
            }
            else
            {
                serializePart(pair.value, dg);
            }
        }
    }

    /***************************************************************************

        Returns a newly instantiated `SerializeMap` of type `QT`

        Params:
            QT = Qualified type of `SerializeMap` to return
            dg   = Delegate to read binary data
            opts = Deserialization options (should be forwarded)

        Returns:
            A new instance of type `QT`

    ***************************************************************************/

    public static QT fromBinary (QT) (
        scope DeserializeDg dg, in DeserializerOptions opts) @safe
    {
        size_t length = deserializeLength(dg, opts.maxLength);
        Map map;
        foreach (_; 0 .. length)
        {
            auto key = deserializeFull!Key(dg, opts);

            static if (isAssociativeArray!Value)
            {
                size_t inner_length = deserializeLength(dg, opts.maxLength);
                alias IK = KeyType!Value;
                alias IV = ValueType!Value;

                Value val;
                foreach (_i; 0 .. inner_length)
                {
                    auto k = deserializeFull!IK(dg, opts);
                    auto v = deserializeFull!IV(dg, opts);
                    val[k] = v;
                }
            }
            else
            {
                auto val = deserializeFull!Value(dg, opts);
            }

            map[key] = val;
        }

        return (() @trusted => cast(QT)SerializeMap(map))();
    }
}

/// Ditto
auto serializeMap (K)(K val) @trusted
{
    alias InnerType = SerializeMap!K.Map;
    return SerializeMap!K(cast(InnerType)val);
}

///
unittest
{
    int[int] map;
    map[1] = 10;
    map[2] = 20;
    auto map_data = serializeFull(serializeMap(map));
    auto map_des = deserializeFull!(SerializeMap!(typeof(map)))(map_data);
    assert(map_des.length == 2);
    assert(map_des[1] == 10);
    assert(map_des[2] == 20);

    int[int][int] nested;
    nested[1][1] = 10;
    nested[1][2] = 20;
    nested[2][1] = 30;
    nested[2][2] = 40;
    auto nested_data = serializeFull(serializeMap(nested));
    auto nested_des = deserializeFull!(SerializeMap!(typeof(nested)))(nested_data);
    assert(nested_des.length == 2);
    assert(nested_des[1][1] == 10);
    assert(nested_des[1][2] == 20);
    assert(nested_des[2][1] == 30);
    assert(nested_des[2][2] == 40);
}
