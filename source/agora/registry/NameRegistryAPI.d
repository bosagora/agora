/*******************************************************************************

    Definitions of the name registry API

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.registry.NameRegistryAPI;

import agora.common.Hash;
import agora.common.Types;
import agora.common.crypto.Key;

import vibe.http.common;
import vibe.web.rest;

///
public struct RegistryPayloadData
{
    /// the public key that we want to register
    public PublicKey public_key;

    /// network addresses associated with the public key
    public const(Address)[] addresses;

    /// monotonically increasing sequence number
    public ulong seq;
}

///
public struct RegistryPayload
{
    ///
    public RegistryPayloadData data;

    /// signature over the `data` member
    public Signature signature;

    ///
    public void signPayload(const ref SecretKey secret_key) nothrow
    {
        signature = secret_key.sign(hashFull(data)[]);
    }

    ///
    public bool verifySignature(const ref PublicKey public_key) const nothrow @nogc @safe
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
            PUT /validator

    ***************************************************************************/

    public void putValidator (RegistryPayload registry_payload);
}
