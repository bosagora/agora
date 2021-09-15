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
import agora.flash.Node;
import agora.serialization.Serializer;
import agora.stats.Registry;
import agora.stats.Utils;
import agora.utils.Log;

import std.algorithm.comparison : among, equal;
import std.algorithm.iteration : map, splitter;
import std.algorithm.searching : endsWith;
import std.array : replace;
import std.datetime;
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

    /// Associate a `RegistryPayload` with internal data
    static private struct TypedPayload
    {
        /// The DNS RR TYPE
        public TYPE type;

        /// The payload itself
        public RegistryPayload payload;
    }

    /// This server's SOA records, one for each authoritative zone
    private SOA[2] zones;

    ///
    private TypedPayload[PublicKey] validator_map;

    ///
    private TypedPayload[PublicKey] flash_map;

    /// Validator count stats
    private RegistryStats registry_stats;

    ///
    private FullNodeAPI agora_node;

    ///
    private Height validator_info_height;

    ///
    private ValidatorInfo[] validator_info;

    ///
    public this (string realm, RegistryConfig config, FullNodeAPI agora_node)
    {
        assert(config.enabled, "Registry instantiated but not enabled");

        this.config = config;
        this.log = Logger(__MODULE__);
        this.agora_node = agora_node;
        Utils.getCollectorRegistry().addCollector(&this.collectRegistryStats);

        const vname = "validators." ~ realm;
        const fname = "flash." ~ realm;
        static string serverType (bool auth)
        {
            return auth ? "authoritative" : "secondary";
        }

        this.log.info("Registry is {} DNS server for zone '{}'",
                      serverType(this.config.validators.authoritative), vname);
        this.log.info("Registry is {} DNS server for zone '{}'",
                      serverType(this.config.flash.authoritative), fname);

        auto currTime = Clock.currTime(UTC());
        // Serial's value wraps around so the cast is safe
        const serial = cast(uint) currTime.toUnixTime();

        this.zones[0] = config.validators.fromConfig(vname, serial);
        this.zones[1] = config.flash.fromConfig(fname, serial);
    }

    ///
    mixin DefineCollectorForStats!("registry_stats", "collectRegistryStats");

    /// Returns: throws if payload is not valid
    protected void ensureValidPayload (in RegistryPayload registry_payload,
        TypedPayload[PublicKey] map) @safe
    {
        // verify signature
        ensure(registry_payload.verifySignature(registry_payload.data.public_key),
                "Incorrect signature for payload");

        // check if we received stale data
        if (auto previous = registry_payload.data.public_key in map)
            ensure(previous.payload.data.seq <= registry_payload.data.seq,
                "registry already has a more up-to-date version of the data");

        ensure(registry_payload.data.addresses.length > 0,
                "Payload for '{}' should have addresses but have 0",
                registry_payload.data.public_key);
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
        if (auto ptr = public_key in validator_map)
        {
            log.trace("Successfull GET /validator: {} => {}", public_key, *ptr);
            return (*ptr).payload;
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
            POST /validator

    ***************************************************************************/

    public override void postValidator (RegistryPayload registry_payload)
    {
        import std.algorithm;

        ensureValidPayload(registry_payload, this.validator_map);

        // Check that there's either one CNAME, or multiple IPs
        TYPE payload_type = this.getPayloadType(registry_payload);

        // Last step is to check the state of the chain
        auto last_height = this.agora_node.getBlockHeight() + 1;
        if (last_height > this.validator_info_height || this.validator_info.length == 0)
        {
            this.validator_info = this.agora_node.getValidators(last_height);
            this.validator_info_height = last_height;
        }
        ensure(this.validator_info.map!(info => info.address)
            .canFind(registry_payload.data.public_key), "Not an enrolled validator");

        // register data
        log.info("Registering addresses {}: {} for public key: {}", payload_type,
                 registry_payload.data.addresses, registry_payload.data.public_key);
        validator_map[registry_payload.data.public_key] =
            TypedPayload(payload_type, registry_payload);
        this.registry_stats.setMetricTo!"registry_record_count"(validator_map.length + flash_map.length);
    }

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

    public override const(RegistryPayload) getFlashNode (PublicKey public_key)
    {
        if (auto ptr = public_key in flash_map)
        {
            log.trace("Successfull GET /flash_node: {} => {}", public_key, *ptr);
            return (*ptr).payload;
        }
        log.trace("Unsuccessfull GET /flash_node: {}", public_key);
        return RegistryPayload.init;
    }

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

    public override void postFlashNode (RegistryPayload registry_payload, KnownChannel channel)
    {
        ensureValidPayload(registry_payload, this.flash_map);

        ensure(isValidChannelOpen(channel.conf, this.agora_node.getBlock(channel.height)),
            "Not a valid channel");

        // Check that there's either one CNAME, or multiple IPs
        TYPE payload_type = this.getPayloadType(registry_payload);

        // register data
        log.info("Registering network addresses: {} for Flash public key: {}", registry_payload.data.addresses,
            registry_payload.data.public_key.toString());
        flash_map[registry_payload.data.public_key] =
            TypedPayload(payload_type, registry_payload);
        this.registry_stats.setMetricTo!"registry_record_count"(validator_map.length + flash_map.length);
    }

    ///
    protected TYPE getPayloadType (in RegistryPayload payload) @safe
    {
        // Check that there's either one CNAME, or multiple IPs
        TYPE payload_type;
        foreach (idx, const ref addr; payload.data.addresses)
        {
            const this_type = addr.guessAddressType();
            ensure(this_type != TYPE.CNAME || payload.data.addresses.length == 1,
                    "Can only have one domain name (CNAME) for payload, not: {}",
                    payload);
            payload_type = this_type;
        }
        return payload_type;
    }

    /***************************************************************************

        Accepts a DNS message and returns an answer to it.

        The input message should contains a serie of questions,
        which the server will answer.
        Currently, only one registry can exists (it assumes authority),
        and recursion is not yet supported.

        Params:
          query = The query received by the server
          sender = A delegate that allows to send a `Message` to the client.
                   A server may send multiple `Message`s as a response to a
                   single query, e.g. when doing zone transfer.

    ***************************************************************************/

    public void answerQuestions (
        in Message query, scope void delegate (in Message) @safe sender)
        @safe
    {
        Message reply;
        reply.header.RCODE = Header.RCode.FormatError;
        reply.header.RA = false; // TODO: Implement
        reply.header.AA = true;  // TODO: Make configurable

        // Note: Since DNS has some fields which apply to the full response but
        // should actually be in `answers`, most resolvers will not ask unrelated
        // questions / will only ask one question at a time.
        foreach (const ref q; query.questions)
        {
            // RFC1034: 3.7.1. Standard queries
            // Since a particular name server may not know all of
            // the classes available in the domain system, it can never know if it is
            // authoritative for all classes. Hence responses to QCLASS=* queries can
            // never be authoritative.
            if (q.qclass == QCLASS.ANY)
                reply.header.AA = false;
            else if (q.qclass != QCLASS.IN)
            {
                log.warn("DNS: Ignoring query with unknown QCLASS: {}", q);
                reply.header.RCODE = Header.RCode.NotImplemented;
                break;
            }

            if (q.qtype.among(QTYPE.A, QTYPE.CNAME, QTYPE.ALL))
            {
                auto rcode = this.getValidatorDNSRecord(q, reply);
                if (rcode != Header.RCode.NoError)
                {
                    reply.header.RCODE = rcode;
                    break;
                }
            }
            else
            {
                log.warn("DNS: Ignoring query for unknown QTYPE: {}", q);
                reply.header.RCODE = Header.RCode.NotImplemented;
            }
        }
        reply.fill(query.header);
        log.trace("{} DNS query: {} => {}",
                  (reply.header.RCODE == Header.RCode.NoError) ? "Fullfilled" : "Unsuccessfull",
                  query, reply);
        sender(reply);
    }

    /***************************************************************************

        Get a single validator's DNS record.

        Queries sent to the server may attempt to look up multiple validators,
        which is handled by `answerQuestions`. This method looks up a single
        host name and return all associated addresses.

        Since we might have multiple addresses registered for a single
        validator, we first attempt to find an IP address (`TYPE.A`) or
        IPv6 (`TYPE.AAAA`). If not, we return a `CNAME` (`TYPE.CNAME`).

        Params:
          question = The question being asked (contains the hostname)
          reply = A struct to fill the `answers` section with the addresses

        Returns:
          A code corresponding to the result of the lookup.
          If the lookup was successful, `Header.RCode.NoError` will be returned.
          Otherwise, the correct error code (non 0) is returned.

    ***************************************************************************/

    private Header.RCode getValidatorDNSRecord (
        const ref Question question, ref Message reply) @safe
    {
        const public_key = question.qname
            .parsePublicKeyFromDomain(this.zones[].map!(z => z.mname.value));
        if (public_key is PublicKey.init)
            return Header.RCode.FormatError;

        auto ptr = public_key in validator_map;
        // We are authoritative, so we can set `NameError`
        if (!ptr || !(*ptr).payload.data.addresses.length)
            return Header.RCode.NameError;

        ResourceRecord answer;
        answer.class_ = CLASS.IN; // Validated by the caller
        answer.type = ptr.type;

        if (ptr.type == TYPE.CNAME)
        {
            /* RFC1034: 4.3.2. Algorithm
             *
             * If the data at the node is a CNAME, and QTYPE doesn't
             * match CNAME, copy the CNAME RR into the answer section
             * of the response, change QNAME to the canonical name in
             * the CNAME RR, and go back to step 1.
             *
             * Otherwise, copy all RRs which match QTYPE into the
             * answer section and go to step 6.
             */
            assert(ptr.payload.data.addresses.length == 1);
            answer.name = ptr.payload.data.addresses[0];
            answer.rdata = answer.name.serializeFull();
            // We don't provide recursion yet, so just return this
            // and let the caller figure it out.
        }
        else if (ptr.type == TYPE.A)
        {
            foreach (idx, addr; ptr.payload.data.addresses)
            {
                uint ip4addr = InternetAddress.parse(addr);
                if (ip4addr == InternetAddress.ADDR_NONE)
                {
                    log.error("DNS: {} record '{}' (index: {}) is not an A record",
                              public_key, addr, idx);
                    return Header.RCode.ServerFailure;
                }
                answer.name = question.qname;
                answer.rdata ~= serializeFull(ip4addr, CompactMode.No);
            }
        }
        else
            ensure(0, "Unknown type: {} - {}", ptr.type, *ptr);

        reply.answers ~= answer;
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

private PublicKey parsePublicKeyFromDomain (StrRange) (in char[] domain,
    StrRange authoritative) @safe
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
    foreach (ad; authoritative)
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

/*******************************************************************************

    Returns the type of address that is stored in a payload

    The `RegistryPayload` struct only contains strings, however they may be
    either domain names (CNAME), IPv4 addresses (A), or IPv6 (AAAA).

    This function implements a few heuristics to guess which one it is.
    By default, we consider that an address is a CNAME.

    Note that there can only be one `CNAME` record for a given key, given that
    CNAME stands for canonical name.

*******************************************************************************/

private TYPE guessAddressType (in char[] address) @safe pure
{
    import std.algorithm.searching : canFind;

    // TODO: Implement support for IPv6 (need definitions in agora.common.DNS)
    version (none)
    {
        if (address.canFind(':'))
            return TYPE.AAAA;
    }
    if (address.length > "255.255.255.255".length || address.length < "1.2.3.4".length)
        return TYPE.CNAME;

    size_t index = 0;
    uint piece;
    foreach (part; 0 .. 4)
    {
        const dotAllowed = (part < 3);

        const char leadDigit = address[index++];
        if (leadDigit < '0' || leadDigit > '9')
            return TYPE.CNAME;

        piece = (leadDigit - '0');
        if (index >= address.length)
            return part == 3 ? TYPE.A : TYPE.CNAME;

        const char secondDigit = address[index++];
        if (dotAllowed && secondDigit == '.')
            continue;
        if (secondDigit < '0' || secondDigit > '9')
            return TYPE.CNAME;
        piece *= 10; // Value is [10; 90]
        piece += (secondDigit - '0');
        if (index >= address.length)
            return part == 3 ? TYPE.A : TYPE.CNAME;

        const char lastDigit = address[index++];
        if (dotAllowed && lastDigit == '.')
            continue;
        if (secondDigit < '0' || secondDigit > '9')
            return TYPE.CNAME;
        piece *= 10;
        piece += (lastDigit - '0');

        if (piece > 255)
            return TYPE.CNAME;
        if (dotAllowed &&
            ((index + 1) >= address.length || address[index++] != '.'))
            return TYPE.CNAME;

    }
    return TYPE.A;
}

unittest
{
    assert("1.0.0.0".guessAddressType == TYPE.A);
    assert("1.2.3.4".guessAddressType == TYPE.A);
    assert("255.255.255.255".guessAddressType == TYPE.A);

    // Rejects anything that is > 255
    assert("256.2.3.4".guessAddressType == TYPE.CNAME);
    assert("2.256.3.4".guessAddressType == TYPE.CNAME);
    assert("2.2.300.4".guessAddressType == TYPE.CNAME);
    assert("2.2.3.420".guessAddressType == TYPE.CNAME);

    assert("v4.bosagora.io".guessAddressType == TYPE.CNAME);
    assert("bosagora".guessAddressType == TYPE.CNAME);
}

/// Converts a `ZoneConfig` to an `SOA` record
private SOA fromConfig (in ZoneConfig zone, string name, uint serial) @safe pure
{
    SOA soa;
    soa.mname = name;
    soa.rname = zone.email.replace('@', '.');
    soa.serial = serial;
    // Casts are safe as the values are validated during config parsing
    soa.refresh = cast(int) zone.refresh.total!"seconds";
    soa.retry = cast(int) zone.retry.total!"seconds";
    soa.expire = cast(int) zone.expire.total!"seconds";
    soa.minimum = cast(uint) zone.minimum.total!"seconds";
    return soa;
}
