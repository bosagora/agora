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

import agora.flash.ErrorCode;
import agora.flash.Route;
import agora.flash.Types;

import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Types;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Schnorr;
import agora.script.Lock;
import agora.script.Script;
import agora.serialization.Serializer;
import agora.utils.Log;

import libsodium.randombytes;
import libsodium.crypto_secretbox;
import libsodium.crypto_generichash;

import std.range;

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

    // encrypted payload. The first one decrypts & deserializes to a `Payload`.
    // the next payload may or may not be legitimate, but it depends entirely
    // on the next node's ability to decrypt the payload.
    public EncryptedPayload[20] encrypted_payloads;
}

/// Contains the encrypted payload and the nonce used to encrypt it
struct EncryptedPayload
{
    /// Nonce used for encryption
    public ubyte[crypto_secretbox_NONCEBYTES] nonce;

    /// The serialized & encrypted payload
    public ubyte[crypto_secretbox_MACBYTES + SerializedPayloadSize] payload;
}

// Payload size without the encryption metadata
private enum SerializedPayloadSize = 80;

/// always same static size, no VarInt
unittest
{
    assert(serializeFull(Payload(Hash.init, Amount.init, Height(0)))
        .length == SerializedPayloadSize);
    assert(serializeFull(Payload(Hash.init, Amount.init, Height(ulong.max)))
        .length == SerializedPayloadSize);
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

    /// Serialization hook
    public void serialize (scope SerializeDg dg) const @trusted
    {
        serializePart(this.next_chan_id, dg, CompactMode.No);
        serializePart(this.forward_amount, dg, CompactMode.No);
        serializePart(this.outgoing_lock_height.value, dg, CompactMode.No);
    }

    /// Deserialization hook
    public static QT fromBinary (QT) (
        scope DeserializeDg dg, in DeserializerOptions opts) @safe
    {
        auto next_chan_id = deserializeFull!Hash(dg, opts);
        auto forward_amount = deserializeFull!Amount(dg, opts);
        auto outgoing_lock_height = Height(deserializeFull!ulong(dg, opts));
        return QT(next_chan_id, forward_amount, outgoing_lock_height);
    }
}

/*******************************************************************************

    Create an onion packet for the given path. Each hop will contain an
    ephemeral public key to derive a common secret with which the hop's
    payload will be encrypted and may later be decrypted by the hop node
    which owns their private key.

    The onion packet is fixed in size, and uses encrypted padding bytes
    to obfuscate its true size. When a node peels of their layer of the
    encrypted packet, it adds additional pading to fill the packet size
    back to its expected fixed length size.

    Params:
        payment_hash = the payment hash to use
        lock_height = the initial lock height
        amount = the amount for the payment
        path = the individual hops (including destination hop)
        total_amount = will contain the amount which needs to be paid to the
            first channel along the route. Different to `amount` as it also
            includes fees.

    Returns:
        the onion packet ready to be routed through the first payment path.

*******************************************************************************/

public OnionPacket createOnionPacket (in Hash payment_hash,
    in Height lock_height, in Amount amount, in Hop[] path,
    out Amount total_amount, out Height use_lock_height)
{
    assert(path.length >= 1);

    // todo: setting fees should be part of the routing algorithm
    total_amount = amount;
    foreach (hop; path)
    {
        if (!total_amount.add(hop.fee))
            assert(0);
    }

    Amount forward_amount = amount;
    Height outgoing_lock_height = lock_height;
    Hash next_chan_id;

    Pair ephemeral_kp = Pair.random();
    OnionPacket packet = { version_byte : 0 };

    // onion packets have to be created from right to left
    assert(path.length <= 20);
    ulong last_index = path.length - 1;

    foreach (hop; path.retro)
    {
        Payload payload =
        {
            next_chan_id : next_chan_id,
            forward_amount : forward_amount,
            outgoing_lock_height : outgoing_lock_height,
        };

        auto encrypted_payload = encryptPayload(payload, ephemeral_kp,
            hop.pub_key);

        packet.encrypted_payloads[last_index] = encrypted_payload;
        last_index--;
        if (!forward_amount.add(hop.fee))
            assert(0);

        // todo: use htlc_delta config here from the channel config
        outgoing_lock_height = Height(outgoing_lock_height + 1);

        next_chan_id = hop.chan_id;

        // keep updating last valid ephemeral key
        packet.ephemeral_pk = ephemeral_kp.V;

        // todo: use hashing for derivation instead
        auto next_secret = ephemeral_kp.v + Scalar(hashFull(1));
        ephemeral_kp = Pair(next_secret, next_secret.toPoint());
    }

    use_lock_height = outgoing_lock_height;

    // fill out the rest with encrypted filler
    foreach (ref payload; packet.encrypted_payloads[path.length .. $])
        fillGarbage(payload);

    return packet;
}

///
unittest
{
    Pair kp1 = Pair.random();
    Pair kp2 = Pair.random();
    Pair kp3 = Pair.random();
    Pair kp4 = Pair.random();

    Hop[] hops = [
        Hop(kp1.V, hashFull(1), Amount(100)),
        Hop(kp2.V, hashFull(2), Amount(200)),
        Hop(kp3.V, hashFull(3), Amount(300)),
        Hop(kp4.V, hashFull(4), Amount(400)),
    ];

    Amount total_amount;
    Height use_lock_height;
    auto packet = createOnionPacket(hashFull(42),
        Height(100), Amount(1000), hops, total_amount, use_lock_height);
    assert(total_amount == Amount(2000));
    assert(use_lock_height == 104);

    Payload payload;
    assert(!decryptPayload(packet.encrypted_payloads[0],
        kp2.v, packet.ephemeral_pk, payload));  // cannot decrypt with other keys
    assert(decryptPayload(packet.encrypted_payloads[0],
        kp1.v, packet.ephemeral_pk, payload));
    assert(payload == Payload(hashFull(2), Amount(1900), Height(103)));

    assert(!decryptPayload(packet.encrypted_payloads[1],
        kp2.v, packet.ephemeral_pk, payload));  // cannot decrypt with same ephemeral key
    packet = nextPacket(packet);  // switch ephemeral key
    assert(decryptPayload(packet.encrypted_payloads[0],
        kp2.v, packet.ephemeral_pk, payload));
    assert(payload == Payload(hashFull(3), Amount(1700), Height(102)));

    packet = nextPacket(packet);
    assert(decryptPayload(packet.encrypted_payloads[0],
        kp3.v, packet.ephemeral_pk, payload));
    assert(payload == Payload(hashFull(4), Amount(1400), Height(101)));

    packet = nextPacket(packet);
    assert(decryptPayload(packet.encrypted_payloads[0],
        kp4.v, packet.ephemeral_pk, payload));
    assert(payload == Payload(Hash.init, Amount(1000), Height(100)));
}

/// Fill the payload with random encrypted data so it looks real but it ain't
private void fillGarbage (ref EncryptedPayload payload)
{
    randombytes_buf(payload.nonce.ptr, payload.nonce.length);

    auto ephemeral_kp = Pair.random();
    ubyte[32] key_bytes = ephemeral_kp.v[][0 .. 32];

    randombytes_buf_deterministic(payload.payload.ptr,
        payload.payload.length, key_bytes);
}

/// Create the next packet for routing (if the next channel ID is not empty)
public OnionPacket nextPacket (in OnionPacket packet)
{
    OnionPacket next = packet.serializeFull.deserializeFull!OnionPacket();
    next.encrypted_payloads[0 .. $ - 1] = cast(EncryptedPayload[])packet.encrypted_payloads[1 .. $];
    fillGarbage(next.encrypted_payloads[$ - 1]);
    auto next_point = packet.ephemeral_pk - Scalar(hashFull(1)).toPoint;
    next.ephemeral_pk = next_point;
    return next;
}

/*******************************************************************************

    Encrypt the payload with the shared secret generated from the ephemeral
    key-pair and the target node's public key.

    Params:
        payload = the raw payload
        ephemeral_kp = the ephemeral key-pair that's generated uniquely for
            each new payload
        target_pk = the target node's public key
        shared_secret = secret used to encrypt the payload

    Returns:
        the serialized and encrypted payload

*******************************************************************************/

public EncryptedPayload encryptPayload (Payload payload, Pair ephemeral_kp,
    Point target_pk, out Point shared_secret)
{
    EncryptedPayload result;
    randombytes_buf(result.nonce.ptr, result.nonce.length);

    const data = payload.serializeFull();
    auto ciphertext_len = crypto_secretbox_MACBYTES + data.length;

    shared_secret = generateSharedSecret(true, ephemeral_kp.v, target_pk);
    if (crypto_secretbox_easy(result.payload.ptr, data.ptr, data.length,
        result.nonce.ptr, shared_secret[].ptr) != 0)
        assert(0);  // this should never fail

    return result;
}

/// Ditto
public EncryptedPayload encryptPayload (Payload payload, Pair ephemeral_kp,
    Point target_pk)
{
    Point shared_secret;
    return encryptPayload (payload, ephemeral_kp, target_pk, shared_secret);
}

/*******************************************************************************

    Decrypt an encrypted payload with the shared secret generated from the
    ephemeral public key and the target node's private key.

    Params:
        encrypted = the encrypted payload
        our_key = the target node's private key
        ephemeral_pk = the ephemeral public key
        payload = on success will contain the decrypted payload
        shared_secret = secret used to decrypt the payload

    Returns:
        true if decryption and deserialization succeeded

*******************************************************************************/

public bool decryptPayload (in EncryptedPayload encrypted,
    in Scalar our_key, in Point ephemeral_pk, out Payload payload,
    out Point shared_secret)
{
    if (encrypted.payload.length <= crypto_secretbox_MACBYTES)
        return false;

    shared_secret = generateSharedSecret(false, our_key, ephemeral_pk);

    ubyte[] decrypted
        = new ubyte[](encrypted.payload.length - crypto_secretbox_MACBYTES);
    if (crypto_secretbox_open_easy(decrypted.ptr, encrypted.payload.ptr,
        encrypted.payload.length, encrypted.nonce.ptr, shared_secret[].ptr) != 0)
    {
        log.info("Decrypting failed for key {} and ephemeral key {}",
            our_key, ephemeral_pk);
        return false;
    }
    assert(decrypted.length == SerializedPayloadSize);

    try
    {
        const DeserializerOptions opts = { maxLength : DefaultMaxLength,
            compact : CompactMode.No };

        import std.format;
        scope DeserializeDg dg = (size) @safe
        {
            if (size > decrypted.length)
                throw new Exception(
                    format("Requested %d bytes but only %d bytes available", size, decrypted.length));

            auto res = decrypted[0 .. size];
            decrypted = decrypted[size .. $];
            return res;
        };

        payload = deserializeFull!Payload(dg, opts);
        return true;
    }
    catch (Exception ex)
    {
        log.info("Failed to deserialize decrtyped payload: {}", ex);
        return false;
    }
}

/// Ditto
public bool decryptPayload (in EncryptedPayload encrypted,
    in Scalar our_key, in Point ephemeral_pk, out Payload payload)
{
    Point shared_secret;
    return decryptPayload (encrypted, our_key, ephemeral_pk, payload, shared_secret);
}

///
unittest
{
    Payload payload =
    {
        next_chan_id : hashFull(42),
        forward_amount : Amount(123),
        outgoing_lock_height : Height(100),
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
    void delegate (in Hash chan_id, in Hash payment_hash, in Amount amount,
        in Height lock_height, in OnionPacket packet);

/// Routing failure packet
public struct OnionError
{
    // todo: replace with actual HMAC
    Hash hmac;

    /// Failed payment hash
    Hash payment_hash;

    /// Point of failure
    Hash chan_id;

    /// Error code
    ErrorCode err;
}

/*******************************************************************************

    Obfuscate/deobfuscate an OnionError with the given secret.

    Params:
        error = Error to obfuscate/deobfuscate
        secret = Shared secret

    Returns:
        Obfuscated/deobfuscated OnionError

*******************************************************************************/

public OnionError obfuscate (OnionError error, Point secret) @trusted
{
    import libsodium.crypto_stream_chacha20;

    const key = hashFull(secret);
    assert(key[].length >= crypto_stream_chacha20_KEYBYTES);
    assert(error.payment_hash[].length >= crypto_stream_chacha20_NONCEBYTES);

    ubyte[OnionError.sizeof] stream;
    crypto_stream_chacha20(stream.ptr, stream.length, error.payment_hash[].ptr, key[].ptr);
    // Don't obfuscate payment_hash
    stream[OnionError.payment_hash.offsetof ..
            OnionError.payment_hash.offsetof + OnionError.payment_hash.sizeof] = 0;

    ubyte* obfuscated_array = cast(ubyte*) &error;
    foreach (idx; 0 .. OnionError.sizeof)
        obfuscated_array[idx] ^= stream[idx];
    return error;
}

unittest
{
    auto org = OnionError(hashFull(1), hashFull(2),
        hashFull(3), ErrorCode.LockTooLarge);
    const secret = Pair.random.V;

    auto obfuscated = org.obfuscate(secret);
    assert(org != obfuscated);
    assert(org.payment_hash == obfuscated.payment_hash);
    auto deobfuscated = obfuscated.obfuscate(secret);
    assert(org == deobfuscated);
}
