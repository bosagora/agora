/*******************************************************************************

    Definitions of the name registry API implementation

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.registry.Server;

import agora.common.Types;
import agora.common.crypto.Key;
import agora.crypto.Hash;
import agora.registry.API;
import agora.utils.Log;

import vibe.core.core;
import vibe.http.common;
import vibe.web.rest;

mixin AddLogger!();

/// Implementation of `NameRegistryAPI` using associative arrays
public final class NameRegistry: NameRegistryAPI
{
    ///
    private RegistryPayload[PublicKey] registry_map;

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

    public override const(RegistryPayload) getValidator (PublicKey public_key)
    {
        if (auto payload = public_key in registry_map)
            return *payload;
        return RegistryPayload.init;
    }

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

    public override void putValidator (RegistryPayload registry_payload)
    {
        // verify signature
        if (!registry_payload.verifySignature(registry_payload.data.public_key))
            throw new Exception("incorrect signature");

        // check if we received stale data
        if (auto previous = registry_payload.data.public_key in registry_map)
            if (previous.data.seq > registry_payload.data.seq)
                throw new Exception("registry already has a more up-to-date version of the data");

        // register data
        log.info("Registering network addresses: {} for public key: {}", registry_payload.data.addresses,
            registry_payload.data.public_key.toString());
        registry_map[registry_payload.data.public_key] = registry_payload;
    }
}
