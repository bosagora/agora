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
import agora.flash.api.FlashAPI;
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
import std.format;
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

    /// The `validators` zone
    private ZoneData validators;

    /// The `flash` zone
    private ZoneData flash;

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
        Utils.getCollectorRegistry().addCollector(&this.collectStats);

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

        this.validators.fill(vname, this.config.validators, serial);
        this.flash.fill(fname, this.config.flash, serial);
    }

    /***************************************************************************

        Collect registry stats

        Params:
            collector = the Collector to collect the stats into

    ***************************************************************************/

    private void collectStats (Collector collector)
    {
        RegistryStats stats;
        stats.registry_validator_record_count = this.validators.map.length;
        stats.registry_flash_record_count = this.flash.map.length;
        collector.collect(stats);
    }

    /// Returns: throws if payload is not valid
    protected TYPE ensureValidPayload (in RegistryPayload payload,
        TypedPayload[PublicKey] map) @safe
    {
        // verify signature
        ensure(payload.verifySignature(payload.data.public_key),
                "Incorrect signature for payload");

        // check if we received stale data
        if (auto previous = payload.data.public_key in map)
            ensure(previous.payload.data.seq <= payload.data.seq,
                "registry already has a more up-to-date version of the data");

        ensure(payload.data.addresses.length > 0,
                "Payload for '{}' should have addresses but have 0",
                payload.data.public_key);

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
        if (auto ptr = public_key in this.validators.map)
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

        TYPE payload_type = this.ensureValidPayload(registry_payload, this.validators.map);

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
        this.validators.map[registry_payload.data.public_key] =
            TypedPayload(payload_type, registry_payload);
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
        if (auto ptr = public_key in this.flash.map)
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
        TYPE payload_type = this.ensureValidPayload(registry_payload, this.flash.map);

        ensure(isValidChannelOpen(channel.conf, this.agora_node.getBlock(channel.height)),
            "Not a valid channel");

        // register data
        log.info("Registering network addresses: {} for Flash public key: {}", registry_payload.data.addresses,
            registry_payload.data.public_key.toString());
        this.flash.map[registry_payload.data.public_key] =
            TypedPayload(payload_type, registry_payload);
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

            if (q.qtype == QTYPE.AXFR)
            {
                if (this.validators.matches(q.qname))
                    this.doAXFR(this.validators, reply);
                else if (this.flash.matches(q.qname))
                    this.doAXFR(this.flash, reply);
                else
                {
                    log.warn("Refusing AXFR for unknown zone: {}", q.qname);
                    reply.header.RCODE = Header.RCode.Refused;
                    break;
                }
            }
            else if (q.qtype.among(QTYPE.A, QTYPE.CNAME, QTYPE.ALL))
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

        Perform an AXFR for a given `zone`

        Allow servers to synchronize with one another using this standard DNS
        query. Note that there are better ways to do synchronization,
        but AXFR was in the original specification.
        See RFC1034 "4.3.5. Zone maintenance and transfers".

        Params:
          zone = The zone to transfer
          reply = The `Message` to write to

    ***************************************************************************/

    private void doAXFR (in ZoneData zone, ref Message reply) @safe
    {
        log.info("Performing AXFR for {} ({} entries)",
                 zone.root.value, zone.map.length);
        auto soa = zone.toRR();
        reply.answers ~= soa;
        foreach (const ref key, const ref value; zone.map)
            reply.answers ~= this.convertPayload(value, format("%s.%s", key, zone.root.value));
        reply.answers ~= soa;
        reply.header.RCODE = Header.RCode.NoError;
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
            .parsePublicKeyFromDomain(this.validators);
        if (public_key is PublicKey.init)
            return Header.RCode.FormatError;

        auto ptr = public_key in this.validators.map;
        // We are authoritative, so we can set `NameError`
        if (!ptr || !(*ptr).payload.data.addresses.length)
            return Header.RCode.NameError;

        reply.answers ~= this.convertPayload(*ptr, question.qname);
        return Header.RCode.NoError;
    }

    /***************************************************************************

        Converts a `TypedPayload` to a valid `ResourceRecord`

        Params:
          tp = The typed payload as found in one of the zones map
          qname = The "question name", or the record name (e.g. in AXFR)

        Throws:
          If the type of `tp` is not supported
          (this would be a programming error).

    ***************************************************************************/

    private ResourceRecord convertPayload (in TypedPayload tp, const char[] qname)
        const @safe
    {
        ResourceRecord answer;
        answer.class_ = CLASS.IN; // Validated by the caller
        answer.type = tp.type;
        answer.name = qname;

        if (tp.type == TYPE.CNAME)
        {
            /* If it's a CNAME, it has to be to another domain, as we don't
             * yet support aliases in the same zone, hence the algorithm in
             * "RFC1034: 4.3.2. Algorithm" can be reduced to "return the CNAME".
             */
            assert(tp.payload.data.addresses.length == 1);
            answer.rdata = answer.name.serializeFull();
            // We don't provide recursion yet, so just return this
            // and let the caller figure it out.
        }
        else if (tp.type == TYPE.A)
        {
            foreach (idx, addr; tp.payload.data.addresses)
            {
                uint ip4addr = InternetAddress.parse(addr);
                ensure(ip4addr != InternetAddress.ADDR_NONE,
                       "DNS: Address '{}' (index: {}) is not an A record (record: {})",
                       addr, idx, tp);
                answer.rdata ~= serializeFull(ip4addr, CompactMode.No);
            }
        }
        else
            ensure(0, "Unknown type: {} - {}", tp.type, tp);

        return answer;
    }
}

/***************************************************************************

    Parse a PublicKey from a domain name for the given zone

    Params:
      domain = The full domain name to parse
      zone = The zone we are matching against

    Returns:
      A valid `PublicKey` that `domain` points to, or `PublicKey.init`

    ***************************************************************************/

private PublicKey parsePublicKeyFromDomain (in char[] domain,
    ZoneData zone) @safe
{
    // In the future, we may allow things like:
    // `admin.$PUBKEY.domain`, but for the moment, restrict it to
    // `$PUBKEY.domain`, and a public key is 63 chars with HRP,
    // 59 chars otherwise.
    enum PublicKeyStringLength = 63;
    enum NoHRPPublicKeyStringLength = 63 - "boa1".length;

    static PublicKey tryParse (in char[] data)
    {
        try return PublicKey.fromString(data);
        catch (Exception exc) return PublicKey.init;
    }

    if (auto str = zone.owns(domain))
    {
        if (str.length == PublicKeyStringLength)
            return tryParse(str);
        else if (str.length == NoHRPPublicKeyStringLength)
            return tryParse("boa1" ~ str);
        else
            return PublicKey.init;
    }
    return PublicKey.init;
}

// Check domain comparison
unittest
{
    import agora.utils.Test;

    const AStr = WK.Keys.A.address.toString();
    // We only need a valid mname
    ZoneData zone;
    zone.root = Domain("net.bosagora.io");

    // Most likely case
    assert((AStr ~ ".net.bosagora.io")
           .parsePublicKeyFromDomain(zone) == WK.Keys.A.address);

    // Technically, request may end with the null label (a dot), and the user
    // might also specify it, so test for it.
    assert((AStr ~ ".net.bosagora.io.")
           .parsePublicKeyFromDomain(zone) == WK.Keys.A.address);

    // Without the HRP
    assert((AStr["boa1".length .. $] ~ ".net.bosagora.io")
           .parsePublicKeyFromDomain(zone) == WK.Keys.A.address);

    // Only gTLD
    zone.root = Domain("bosagora");
    assert((AStr ~ ".bosagora")
           .parsePublicKeyFromDomain(zone) == WK.Keys.A.address);

    // Uppercase / lowercase doesn't matter, except for the key
    assert((AStr ~ ".BOSAGORA")
           .parsePublicKeyFromDomain(zone) == WK.Keys.A.address);
    assert((AStr ~ ".BoSAGorA")
           .parsePublicKeyFromDomain(zone) == WK.Keys.A.address);
    zone.root = Domain(".BoSAgOrA");
    assert((AStr ~ ".BOSAGORA")
           .parsePublicKeyFromDomain(zone) == WK.Keys.A.address);

    // Rejection tests
    zone.root = Domain("boa");
    assert((AStr[1 .. $] ~ ".boa")
           .parsePublicKeyFromDomain(zone) is PublicKey.init);
    auto invalid = AStr.dup;
    invalid[0] = 'c';
    assert((invalid ~ ".boa")
           .parsePublicKeyFromDomain(zone) is PublicKey.init);

    zone.root = Domain("boap");
    assert((AStr ~ ".boa")
           .parsePublicKeyFromDomain(zone) is PublicKey.init);
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
    soa.mname = format("ns1.%s", name);
    soa.rname = zone.email.replace('@', '.');
    soa.serial = serial;
    // Casts are safe as the values are validated during config parsing
    soa.refresh = cast(int) zone.refresh.total!"seconds";
    soa.retry = cast(int) zone.retry.total!"seconds";
    soa.expire = cast(int) zone.expire.total!"seconds";
    soa.minimum = cast(uint) zone.minimum.total!"seconds";
    return soa;
}

/// Associate a `RegistryPayload` with internal data
private struct TypedPayload
{
    /// The DNS RR TYPE
    public TYPE type;

    /// The payload itself
    public RegistryPayload payload;
}

/// Contains infos related to either `validators` or `flash`
private struct ZoneData
{
    /// The zone fully qualified name
    public Domain root;

    /// The SOA record
    public SOA soa;

    /// Whether we are authoritative or we're just caching
    public bool authoritative;

    /// The content of the zone
    public TypedPayload[PublicKey] map;

    /// Fill this from the configuration
    public void fill (in string name, in ZoneConfig config, uint serial)
    {
        this.root = Domain(name);
        this.authoritative = config.authoritative;

        if (this.authoritative)
            this.soa = config.fromConfig(name, serial);
        else
            this.soa.mname = format("ns1.%s", this.root);
    }

    /***************************************************************************

         Returns:
           A ResourceRecord matching this zone's SOA.

    ***************************************************************************/

    public ResourceRecord toRR () const @safe
    {
        ResourceRecord result;
        result.name = this.soa.mname;
        result.type = TYPE.SOA;
        result.class_ = CLASS.IN;
        result.rdata = this.soa.serializeFull(CompactMode.No);
        return result;
    }

    /***************************************************************************

         Check if the provided name exactly matches this domain

         Note: this should be `@nogc`, but `splitter` is not
         (https://issues.dlang.org/show_bug.cgi?id=12768))

         Params:
           input = The string to check against this zone's mname

    ***************************************************************************/

    public bool matches (in char[] input) const scope @safe pure
    {
        // We can't use `std.algorithm.comparison : equal` here,
        // as we may have an empty label at the end,
        // either for the domain we're matching against or the requested one
        // We can't use a `std.range: {zip,lockstep}` + `foreach` approach either,
        // as it implicitly saves the range. So make a save of the `domain` range
        // (as we might be iterating multiple times over it), and do it manually.
        auto auth_domain_range = this.root.value.splitter('.');
        auto domain_range = input.splitter('.');
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
                    return false;
            }

            // Different length means they can't be equal
            if (auth_domain_range.empty != domain_range.empty)
                return false;

            // Found a match
            if (domain_range.empty)
                return true;

            if (std.uni.sicmp(domain_range.front, auth_domain_range.front))
                return false; // `sicmp` returns `0` on match

            domain_range.popFront();
            auth_domain_range.popFront();
        }
    }

    ///
    unittest
    {
        ZoneData zone;
        zone.root = Domain("example.com");
        assert(zone.matches("example.com"));
        assert(!zone.matches("a.example.com"));
        assert(!zone.matches("exampld.com"));
        assert(!zone.matches("example.bar"));
        assert(!zone.matches("example.com.a"));
    }

    /***************************************************************************

         Check if the provided name is a direct child of this domain

         Params:
           input = The string to check against this zone's mname

         Returns:
           The owned subdomain, or `null` if it is not a subdomain of this zone.

    ***************************************************************************/

    public const(char)[] owns (return in char[] input)
        const scope @safe pure
    {
        auto range = input.splitter('.');
        if (range.empty || range.front.length < 1)
            return null;

        const child = range.front;
        range.popFront();
        if (range.empty)
            return null;
        // Slice past the dot, after making sure there is one (bosagora/agora#2551)
        const parentDomain = input[child.length + 1 .. $];
        return this.matches(parentDomain) ? child : null;
    }

    ///
    unittest
    {
        ZoneData zone;
        zone.root = Domain("example.com");
        assert(zone.owns("a.example.com"));
        // Owns is only about sub-domain
        assert(!zone.owns("example.com"));
        // But only direct sub-domain
        assert(!zone.owns("a.b.exampld.com"));
        // bosagora/agora#2551
        assert(!zone.owns("oops"));
    }
}
