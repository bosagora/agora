/*******************************************************************************

    Definitions of the name registry API implementation

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.Registry;

import agora.api.FullNode : FullNodeAPI = API;
import agora.api.Registry;
import agora.common.DNS;
import agora.common.Ensure;
import agora.common.Types;
import agora.consensus.data.ValidatorInfo;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.node.Config;
import agora.serialization.Serializer;
import agora.stats.Registry;
import agora.stats.Utils;
import agora.utils.Log;

import std.algorithm.comparison : equal;
import std.algorithm.iteration : splitter;
import std.algorithm.searching : endsWith;
import std.range : zip;
import std.socket;
static import std.uni;

/// Implementation of `NameRegistryAPI` using associative arrays
public class NameRegistry: NameRegistryAPI
{
    /// Logger instance
    protected Logger log;

    ///
    protected RegistryConfig config;

    ///
    private RegistryPayload[PublicKey] registry_map;

    /// Validator count stats
    private RegistryStats registry_stats;

    ///
    private FullNodeAPI agora_node;

    ///
    private Height validator_info_height;

    ///
    private ValidatorInfo[] validator_info;

    ///
    public this (RegistryConfig config, FullNodeAPI agora_node)
    {
        this.config = config;
        this.log = Logger(__MODULE__);
        if (this.config.dns.enabled)
            this.log.info("Starting authoritative DNS server for zones: {}",
                          this.config.dns.authoritative);
        this.agora_node = agora_node;
        Utils.getCollectorRegistry().addCollector(&this.collectRegistryStats);
    }

    ///
    mixin DefineCollectorForStats!("registry_stats", "collectRegistryStats");

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
        {
            log.trace("Successfull GET /validator: {} => {}", public_key, *payload);
            return *payload;
        }
        log.trace("Unsuccessfull GET /validators: {}", public_key);
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
        import std.algorithm;

        // verify signature
        ensure(registry_payload.verifySignature(registry_payload.data.public_key),
                "Incorrect signature for payload");

        // check if we received stale data
        if (auto previous = registry_payload.data.public_key in registry_map)
            ensure(previous.data.seq <= registry_payload.data.seq,
                "registry already has a more up-to-date version of the data");

        auto last_height = this.agora_node.getBlockHeight() + 1;
        if (last_height > this.validator_info_height || this.validator_info.length == 0)
        {
            this.validator_info = this.agora_node.getValidators(last_height);
            this.validator_info_height = last_height;
        }
        ensure(this.validator_info.map!(info => info.address)
            .canFind(registry_payload.data.public_key), "Not an enrolled validator");

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

    public Message answerQuestions (in Message query) @safe
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
        log.trace("{} DNS query: {} => {}",
                  (reply.header.RCODE == Header.RCode.NoError) ? "Fullfilled" : "Unsuccessfull",
                  query, reply);
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
        const ref Question question, ref ResourceRecord answer) @safe
    {
        const public_key = question.qname
            .parsePublicKeyFromDomain(this.config.dns.authoritative);
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
}

/***************************************************************************

    Parse a PublicKey from a domain name

    Our server is authoritative for 'realms', but it still receives UTF-8
    data, hence we need to iterate the string from beginning to end,
    and can't do arbitrary lookups.

    Start by checking that the first component has the correct length,
    then check that the other components are for domain we are
    authoritative for. If not, the caller will either reject or recurse.

    Params:
      domain = The full domain name to parse
      authoritative = The list of domain for which we are authoritative

    Returns:
      A valid `PublicKey` that `domain` points to, or `PublicKey.init`

    ***************************************************************************/

private PublicKey parsePublicKeyFromDomain (in char[] domain,
    in string[] authoritative) @safe
{
    auto range = domain.splitter('.');
    if (range.empty)
        return PublicKey.init;

    enum PublicKeyStringLength = 63;
    enum NoHRPPublicKeyStringLength = 63 - "boa1".length;
    // In the future, we may allow things like:
    // `admin.$PUBKEY.domain`, but for the moment, restrict it to
    // `$PUBKEY.domain`, and a public key is 63 chars with HRP,
    // 59 chars otherwise.
    const(char)[] keyWithHRP;
    if (range.front.length == PublicKeyStringLength)
        keyWithHRP = range.front;
    else if (range.front.length == NoHRPPublicKeyStringLength)
        keyWithHRP = "boa1" ~ range.front;
    else
        return PublicKey.init;

    range.popFront();
    if (range.empty) return PublicKey.init;

    // Now check that the pubkey is under a domain we know about
NEXT_DOMAIN:
    foreach (idx, ad; authoritative)
    {
        // We can't use `std.algorithm.comparison : equal` here,
        // as we may have an empty label at the end,
        // either for the authoritative domains or the requested one
        // We can't use a `std.range: {zip,lockstep}` + `foreach` approach either,
        // as it implicitly saves the range. So make a save of the `domain` range
        // (as we might be iterating multiple times over it), and do it manually.
        auto auth_domain_range = ad.splitter('.');
        auto domain_range = range.save();
        while (true)
        {
            // Pop empty label(s)
            if (!auth_domain_range.empty && auth_domain_range.front.length == 0)
                // Note: Should be empty after this, if the caller properly
                // validated its input to us.
                auth_domain_range.popFront();
            if (!domain_range.empty && domain_range.front.length == 0)
            {
                domain_range.popFront();
                // It means we have something like `a..b.com` which is not valid
                if (!domain_range.empty)
                    return PublicKey.init;
            }

            // Different length means they can't be equal
            if (auth_domain_range.empty != domain_range.empty)
                continue NEXT_DOMAIN;

            // Found a match
            if (domain_range.empty)
                break;

            if (std.uni.sicmp(domain_range.front, auth_domain_range.front))
                continue NEXT_DOMAIN; // `sicmp` returns `0` on match

            domain_range.popFront();
            auth_domain_range.popFront();
        }

        try
            return PublicKey.fromString(keyWithHRP);
        catch (Exception exc)
            return PublicKey.init;
    }
    return PublicKey.init;
}

// Check domain comparison
unittest
{
    import agora.utils.Test;

    const AStr = WK.Keys.A.address.toString();

    // Most likely case
    assert((AStr ~ ".net.bosagora.io")
           .parsePublicKeyFromDomain(["net.bosagora.io"]) == WK.Keys.A.address);

    // Technically, request may end with the null label (a dot), and the user
    // might also specify it, so test for it.
    assert((AStr ~ ".net.bosagora.io.")
           .parsePublicKeyFromDomain(["net.bosagora.io"]) == WK.Keys.A.address);
    assert((AStr ~ ".net.bosagora.io")
           .parsePublicKeyFromDomain(["net.bosagora.io."]) == WK.Keys.A.address);
    assert((AStr ~ ".net.bosagora.io.")
           .parsePublicKeyFromDomain(["net.bosagora.io."]) == WK.Keys.A.address);

    // Without the HRP
    assert((AStr["boa1".length .. $] ~ ".net.bosagora.io")
           .parsePublicKeyFromDomain(["net.bosagora.io"]) == WK.Keys.A.address);

    // Multiple domains
    assert((AStr ~ ".net.bosagora.io")
           .parsePublicKeyFromDomain(["net.bosagora.io", "foo.com"]) == WK.Keys.A.address);
    assert((AStr ~ ".net.bosagora.io")
           .parsePublicKeyFromDomain(["foo.com", "net.bosagora.io", "bar.foo"]) == WK.Keys.A.address);

    // Only gTLD
    assert((AStr ~ ".bosagora")
           .parsePublicKeyFromDomain(["net.foo", ".bosagora", "far.fetched"]) == WK.Keys.A.address);

    // Uppercase / lowercase doesn't matter, except for the key
    assert((AStr ~ ".BOSAGORA")
           .parsePublicKeyFromDomain(["net.foo", ".bosagora", "far.fetched"]) == WK.Keys.A.address);
    assert((AStr ~ ".BoSAGorA")
           .parsePublicKeyFromDomain(["net.foo", ".bosagora", "far.fetched"]) == WK.Keys.A.address);
    assert((AStr ~ ".BOSAGORA")
           .parsePublicKeyFromDomain(["net.foo", ".BoSAgOrA", "far.fetched"]) == WK.Keys.A.address);

    // Rejection tests
    assert((AStr[1 .. $] ~ ".boa")
           .parsePublicKeyFromDomain([".boa"]) is PublicKey.init);
    auto invalid = AStr.dup;
    invalid[0] = 'c';
    assert((invalid ~ ".boa")
           .parsePublicKeyFromDomain(["boa"]) is PublicKey.init);

    assert((AStr ~ ".boa")
           .parsePublicKeyFromDomain(["boap", "foo.bar"]) is PublicKey.init);
    assert((AStr ~ ".boa")
           .parsePublicKeyFromDomain(["boap", "foo.bar", "boa."]) == WK.Keys.A.address);
}
