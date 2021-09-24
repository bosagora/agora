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
