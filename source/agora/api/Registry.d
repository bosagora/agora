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

    ///
    public Signature sign (in KeyPair kp) const scope @safe nothrow
    {
        assert(this.public_key is kp.address);
        return kp.sign(hashFull(this)[]);
    }

    ///
    public bool verify (in Signature sig) const scope  @safe nothrow @nogc
    {
        return this.public_key.verify(sig, hashFull(this)[]);
    }

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

    public const(RegistryPayloadData) getValidator (PublicKey public_key);

    /***************************************************************************

        Register network addresses corresponding to a public key

        Params:
            data = the addresses to register with the name registry server
            sig = Signature matching `data`

        API:
            POST /validator

    ***************************************************************************/

    public void postValidator (RegistryPayloadData data, Signature sig);

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

    public const(RegistryPayloadData) getFlashNode (PublicKey public_key);

    /***************************************************************************

        Register network addresses corresponding to a public key

        Params:
            data = addresses to register with the name registry server
            sig = Signature matching `data`
            channel = a known channel of the registering public key

        API:
            POST /flash_node

    ***************************************************************************/

    public void postFlashNode (RegistryPayloadData data, Signature sig, KnownChannel channel);
}
