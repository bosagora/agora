/*******************************************************************************

    Definitions of the name registry API implementation

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.registry.Server;

import agora.common.Ensure;
import agora.common.Types;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.registry.API;
import agora.stats.Registry;
import agora.stats.Utils;
import agora.utils.Log;

mixin AddLogger!();

/// Implementation of `NameRegistryAPI` using associative arrays
public final class NameRegistry: NameRegistryAPI
{
    ///
    private RegistryPayload[PublicKey] registry_map;

    /// Validator count stats
    private RegistryStats registry_stats;

    ///
    public this ()
    {
        Utils.getCollectorRegistry().addCollector(&this.collectRegistryStats);
    }

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
        ensure(registry_payload.verifySignature(registry_payload.data.public_key),
                "Incorrect signature for payload");

        // check if we received stale data
        if (auto previous = registry_payload.data.public_key in registry_map)
            ensure(previous.data.seq <= registry_payload.data.seq,
                "registry already has a more up-to-date version of the data");

        // register data
        log.info("Registering network addresses: {} for public key: {}", registry_payload.data.addresses,
            registry_payload.data.public_key.toString());
        registry_map[registry_payload.data.public_key] = registry_payload;
        this.registry_stats.setMetricTo!"registry_record_count"(registry_map.length);
    }

    mixin DefineCollectorForStats!("registry_stats", "collectRegistryStats");
}
