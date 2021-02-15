/*******************************************************************************

    Contains the routing path encoding structure.

    An origin node which wishes to make a payment to a destination node needs
    to find a route to the destination node. Once it does, it needs to
    be able to encode this in a single structure so it may forward it to the
    first hop in the payment route, which in turn forwards it to the next hop,
    and so on..

    Consider payment of A to D via A -> B -> C -> D:

    The origin node must encode the payment route for each hop (B, C, D).
    It must do it in a way that each hop node only knows where to forward
    the packet to next, but may not know the entire route path.

    NOTE: See https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md
    NOTE: See https://medium.com/softblocks/lightning-network-in-depth-part-2-htlc-and-payment-routing-db46aea445a8

    Copyright:
        Copyright (c) 2021 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.OnionPacket;

import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Serializer;
import agora.common.Types;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Schnorr;
import agora.script.Lock;
import agora.script.Script;
import agora.utils.Log;

import libsodium.randombytes;
import libsodium.crypto_secretbox;
import libsodium.crypto_generichash;

import core.stdc.time;

version (unittest)
{
    import std.stdio;
}

mixin AddLogger!();

/// Per-hop onion packet
public struct OnionPacket
{
    // version byte for compatibility
    public ubyte version_byte;

    // ephemeral key that's used with the receiver's private key to derive the
    // shared secret for decrypting
    public Point ephemeral_pk;

    // encrypted payload, decrypts to a `Payload`
    public EncryptedPayload encrypted_payload;

    // todo: replace with actual HMAC
    public Hash hmac;
}

/// Contains the encrypted payload and the nonce used to encrypt it
struct EncryptedPayload
{
    /// Nonce used for encryption
    public ubyte[crypto_secretbox_NONCEBYTES] nonce;

    /// The serialized & encrypted payload
    public ubyte[] payload;
}

/// Decrypted Payload which is originally stored encrypted in the OnionPacket
public struct Payload
{
    /// The channel ID to forward the next packet to. If this is zero,
    /// it means this was the destination node.
    public Hash next_chan_id;

    /// the amount to forward to the next node, or the total payment amount
    /// if this was the final node.
    ///
    /// for hops need to verify:
    /// `incoming_htlc_amt - fee_next_node >= forward_amount`
    /// for final nodes need to verify:
    /// `incoming_htlc_amt == forward_amount`
    public Amount forward_amount;

    // need to verify:
    // cltv_expiry - cltv_expiry_delta >= outgoing_lock_height
    public Height outgoing_lock_height;

    /// the packet to send to the next node
    public OnionPacket next_packet;

    // todo: replace with actual HMAC
    public Hash hmac;
}

/*******************************************************************************

    Encrypt the payload with the shared secret generated from the ephemeral
    key-pair and the target node's public key.

    Params:
        payload = the raw payload
        ephemeral_kp = the ephemeral key-pair that's generated uniquely for
            each new payload
        target_pk = the target node's public key

    Returns:
        the serialized and encrypted payload

*******************************************************************************/

public EncryptedPayload encryptPayload (Payload payload, Pair ephemeral_kp,
    Point target_pk)
{
    EncryptedPayload result;
    randombytes_buf(result.nonce.ptr, result.nonce.length);

    const data = payload.serializeFull();
    auto ciphertext_len = crypto_secretbox_MACBYTES + data.length;
    result.payload = new ubyte[](ciphertext_len);

    Point secret = generateSharedSecret(true, ephemeral_kp.v, target_pk);
    if (crypto_secretbox_easy(result.payload.ptr, data.ptr, data.length,
        result.nonce.ptr, secret[].ptr) != 0)
        assert(0);  // this should never fail

    return result;
}

/*******************************************************************************

    Decrypt an encrypted payload with the shared secret generated from the
    ephemeral public key and the target node's private key.

    Params:
        encrypted = the encrypted payload
        our_key = the target node's private key
        ephemeral_pk = the ephemeral public key
        payload = on success will contain the decrypted payload

    Returns:
        true if decryption and deserialization succeeded

*******************************************************************************/

public bool decryptPayload (in EncryptedPayload encrypted,
    in Scalar our_key, in Point ephemeral_pk, out Payload payload)
{
    if (encrypted.payload.length <= crypto_secretbox_MACBYTES)
        return false;

    Point secret = generateSharedSecret(false, our_key, ephemeral_pk);

    ubyte[] decrypted
        = new ubyte[](encrypted.payload.length - crypto_secretbox_MACBYTES);
    if (crypto_secretbox_open_easy(decrypted.ptr, encrypted.payload.ptr,
        encrypted.payload.length, encrypted.nonce.ptr, secret[].ptr) != 0)
    {
        log.info("Decrypting failed for key {} and ephemeral key {}",
            our_key, ephemeral_pk);
        return false;
    }

    try
    {
        payload = deserializeFull!Payload(decrypted);
        return true;
    }
    catch (Exception ex)
    {
        log.info("Failed to deserialize decrtyped payload: {}", ex);
        return false;
    }
}

///
unittest
{
    Payload payload =
    {
        next_chan_id : hashFull(42),
        forward_amount : Amount(123),
        outgoing_lock_height : Height(100),
        next_packet : OnionPacket.init,
        hmac : hashFull(111),
    };

    Pair ephemeral_kp = Pair.random();
    Pair bob_kp = Pair.random();

    EncryptedPayload encrypted = encryptPayload(payload, ephemeral_kp, bob_kp.V);
    Payload decrypted;
    assert(decryptPayload(encrypted, bob_kp.v, ephemeral_kp.V, decrypted));
    assert(decrypted == payload);
}

/*******************************************************************************

    Generate a shared secret to encrypt / decrypt a payload between two parties.

    Params:
        is_sender = the sender encrypts, therefore `our_secret` is the sender's
            ephemeral secret key. The receiver must set this to false to make
            sure internal hashing is consistent between sender & receiver
        our_secret = either the ephemeral secret key, or the receiver's secret
            key if `is_sender` is false
        their_pubkey = either the ephemeral public key, or the receiver's public
            key if `is_sender` is false

    Returns:
        a shared secret which can be used for encryption

*******************************************************************************/

private Point generateSharedSecret (bool is_sender, Scalar our_secret,
    Point their_pubkey)
{
    auto shared_key = our_secret * their_pubkey;

    // hashing is recommended
    Hash hash;
    if (is_sender)  // order of keys in call to hashMulti() must be preserved
        hash = hashMulti(shared_key, our_secret.toPoint(), their_pubkey);
    else
        hash = hashMulti(shared_key, their_pubkey, our_secret.toPoint());

    // need to reduce 64-byte hash to 32-bytes
    ubyte[32] reduced;
    assert(crypto_generichash(reduced[].ptr, typeof(reduced).sizeof,
        hash[].ptr, hash.sizeof, null, 0) == 0);
    return Point(reduced[]);
}

///
unittest
{
    Pair alice = Pair.random();
    Pair bob = Pair.random();

    Point secret1 = generateSharedSecret(true, alice.v, bob.V);
    Point secret2 = generateSharedSecret(false, bob.v, alice.V);
    assert(secret1 == secret2);

    static struct S
    {
        int x = 123;
    }

    S s;
    const payload = s.serializeFull();

    ubyte[crypto_secretbox_NONCEBYTES] nonce;
    randombytes_buf(nonce.ptr, nonce.length);

    auto ciphertext_len = crypto_secretbox_MACBYTES + payload.length;
    ubyte[] ciphertext = new ubyte[](ciphertext_len);
    if (crypto_secretbox_easy(ciphertext.ptr, payload.ptr, payload.length,
        nonce.ptr, secret1[].ptr) != 0)
        assert(0);

    ubyte[] decrypted = new ubyte[](payload.length);
    if (crypto_secretbox_open_easy(decrypted.ptr, ciphertext.ptr,
        ciphertext_len, nonce.ptr, secret1[].ptr) != 0)
        assert(0);

    S deserialized = deserializeFull!S(decrypted);
    assert(deserialized.x == s.x);
}

/// OnionPacket payment router
public alias PaymentRouter =
    bool delegate (in Hash chan_id, in Hash payment_hash, in Amount amount,
        in Height lock_height, in OnionPacket packet);
