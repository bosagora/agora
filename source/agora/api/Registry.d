/*******************************************************************************

    Definitions of the name registry API

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.api.Registry;

import agora.common.Types;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr: Signature;
import agora.flash.api.FlashAPI;

import std.algorithm.comparison : isPermutation, cmp;
import std.range : zip;

///
public struct RegistryPayloadData
{
    /// the public key that we want to register
    public PublicKey public_key;

    /// network addresses associated with the public key
    public const(Address)[] addresses;

    /// monotonically increasing sequence number
    public ulong seq;

    /// TTL of the registry record
    public uint ttl = 600;

    /// Compares payload data for equality, ignores `seq`
    /// and permutations of `addresses` are considered as equal, `ttl` is ignored
    bool opEquals (in RegistryPayloadData other) const nothrow @safe
    {
        return (this.public_key == other.public_key)
            && (this.addresses.isPermutation(other.addresses));
    }

    /// Overload for `toHash`, required when implementing `opEquals`
    public size_t toHash () const scope @trusted pure nothrow @nogc
    {
        // If you have one, please let us know, we'd like to hear about it.
        static assert(PublicKey.sizeof >= size_t.sizeof,
                      "512 bits machines are not supported");

        // The last bytes represent the checksum
        return *(cast(size_t*) this.public_key[][$ - size_t.sizeof .. $].ptr);
    }

    /***************************************************************************

        Orders payload data according to `public_key`, when `public_key`s are
        equal, `opEquals` is considered for equality. Comparison falls back to
        `seq`, length of `addresses` and individual addresses in respective order
        when `opEquals` fail. This will eventually result in different equality
        from `opEquals`

    ***************************************************************************/

    public int opCmp (in RegistryPayloadData other) const nothrow @safe
    {
        if (this.public_key == other.public_key)
        {
            if (this.opEquals(other)) return 0;

            if (this.seq != other.seq)
                return this.seq < other.seq ? -1 : 1;

            if (this.addresses.length != other.addresses.length)
                return this.addresses.length < other.addresses.length ? -1 : 1;

            foreach (thisAddr, otherAddr; this.addresses.zip(other.addresses))
                if (auto c = thisAddr.opCmp(otherAddr))
                    return c;
        }

        return this.public_key.opCmp(other.public_key);
    }
}

///
public struct RegistryPayload
{
    ///
    public RegistryPayloadData data;

    /// signature over the `data` member
    public Signature signature;

    /// Compares payload, ignores `signature` of the data since
    /// `RegistryPayloadData` ignores `seq`
    bool opEquals (in RegistryPayload other) const nothrow @safe
    {
        return this.data == other.data;
    }

    /// Required when `opEquals` is implemented
    public size_t toHash () const scope @safe pure nothrow @nogc
    {
        return this.data.toHash();
    }

    /// Orders payload according to `data`
    public int opCmp (in RegistryPayload other) const nothrow
    {
        return this.data.opCmp(other.data);
    }

    ///
    public void signPayload (in KeyPair kp) @safe nothrow
    {
        this.signature = kp.sign(hashFull(this.data)[]);
    }

    ///
    public bool verifySignature (in PublicKey public_key) const nothrow @nogc @safe
    {
        return public_key.verify(this.signature, hashFull(this.data)[]);
    }
}

/// API allowing to store network addresses under a public key
public interface NameRegistryAPI
{
    @safe:

    /***************************************************************************

        Get network addresses corresponding to a public key

        Params:
            public_key = the public key that was used to register
                         the network addresses

        Returns:
            Network addresses associated with the `public_key`

        API:
            GET /validator

    ***************************************************************************/

    public const(RegistryPayload) getValidator (PublicKey public_key);

    /***************************************************************************

        Register network addresses corresponding to a public key

        Params:
            registry_payload =
                the data we want to register with the name registry server

        Returns:
            empty string, if the registration was successful, otherwise returns
            the error message

        API:
            POST /validator

    ***************************************************************************/

    public void postValidator (RegistryPayload registry_payload);

    /***************************************************************************

        Get network addresses corresponding to a flash node that is controlling
        given public_key

        Params:
            public_key = the public key that was used to register
                         the network addresses

        Returns:
            Network addresses associated with the `public_key`

        API:
            GET /flash_node

    ***************************************************************************/

    public const(RegistryPayload) getFlashNode (PublicKey public_key);

    /***************************************************************************

        Register network addresses corresponding to a public key

        Params:
            registry_payload =
                the data we want to register with the name registry server
            channel =
                a known channel of the registering public key

        API:
            POST /flash_node

    ***************************************************************************/

    public void postFlashNode (RegistryPayload registry_payload, KnownChannel channel);
}
