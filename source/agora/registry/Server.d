/*******************************************************************************

    Definitions of the name registry API implementation

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.registry.Server;

import agora.common.DNS;
import agora.common.Ensure;
import agora.common.Types;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.registry.API;
import agora.serialization.Serializer;
import agora.stats.Registry;
import agora.stats.Utils;
import agora.utils.Log;

import std.algorithm.iteration : splitter;
import std.algorithm.searching : endsWith;
import std.socket;

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

    /***************************************************************************

        Accepts a DNS message and returns an answer to it.

        The input message should contains a serie of questions,
        which the server will answer.
        Currently, only one registry can exists (it assumes authority),
        and recursion is not yet supported.

        Params:
          query = The query received by the server

        Returns:
          An answer that matches the query

    ***************************************************************************/

    public Message answerQuestions (in Message query)
    {
        Message reply;
        reply.header.RA = false; // TODO: Implement
        reply.header.AA = true;  // TODO: Make configurable

        ResourceRecord answer;
        answer.type = TYPE.A;
        answer.class_ = CLASS.IN;
        answer.ttl = 600;

        foreach (const ref q; query.questions)
        {
            auto rcode = this.getValidatorDNSRecord(q, answer);
            if (rcode != Header.RCode.NoError)
            {
                reply.header.RCODE = rcode;
                break;
            }
            reply.answers ~= answer;
        }
        return reply.fill(query.header);
    }

    /***************************************************************************

        Get a single validator's DNS record.

        Queries sent to the server may attempt to look up multiple validators,
        which is handled by `answerQuestions`. This method looks up a single
        host name and return all associated addresses.

        Params:
          question = The question being asked (contains the hostname)
          answer = A struct to fill with the addresses

        Returns:
          A code corresponding to the result of the lookup.
          If the lookup was successful, `Header.RCode.NoError` will be returned.
          Otherwise, the correct error code (non 0) is returned.

    ***************************************************************************/

    private Header.RCode getValidatorDNSRecord (
        in Question question, ref ResourceRecord answer)
    {
        const public_key = parsePublicKeyFromDomain(question.qname);
        if (public_key is PublicKey.init)
            return Header.RCode.FormatError;

        auto payload = public_key in registry_map;
        // We are authoritative, so we can set `NameError`
        if (!payload)
            return Header.RCode.NameError;

        answer.name = question.qname;
        foreach (idx, const ref addr; (*payload).data.addresses)
        {
            uint ip4addr = InternetAddress.parse(addr);
            if (ip4addr == InternetAddress.ADDR_NONE)
                continue;
            answer.rdata ~= serializeFull(ip4addr, CompactMode.No);
        }

        return Header.RCode.NoError;
    }

    ///
    mixin DefineCollectorForStats!("registry_stats", "collectRegistryStats");
}

/// Simplistic parsing function for domain name
/// This should be made configurable so that the registry can live under different
/// addresses, e.g. one for the validator and one for flash.
private PublicKey parsePublicKeyFromDomain (scope const(char)[] domain)
    @safe nothrow
{
    immutable string[2] ends = [
        ".net.bosagora.io",
        ".net.bosagora.io.",
    ];

    // TODO: Improve code and support uppercase queries
    scope odomain = domain;
    foreach (e; ends)
        if (domain.endsWith(e))
        {
            domain = domain[0 .. $ - e.length];
            break;
        }

    // Not something we know about
    if (odomain.length == domain.length)
        return PublicKey.init;

    try
        return PublicKey.fromString(domain);
    catch (Exception exc)
        return PublicKey.init;
}
