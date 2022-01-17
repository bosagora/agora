/*******************************************************************************

    Definitions of the name registry API implementation

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.Registry;

import agora.api.Registry;
import agora.common.Amount;
import agora.common.DNS;
import agora.common.Ensure;
import agora.common.ManagedDatabase;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.UTXO;
import agora.consensus.data.ValidatorInfo;
import agora.consensus.Ledger;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr: Signature;
import agora.node.Config;
import agora.flash.api.FlashAPI;
import agora.flash.Node;
import agora.serialization.Serializer;
import agora.stats.Registry;
import agora.stats.Utils;
import agora.utils.Log;

import std.algorithm;
import std.array : array, replace;
import std.conv;
import std.datetime;
import std.format;
import std.range;
import std.socket : InternetAddress;
import std.string;

static import std.uni;

import d2sqlite3 : ResultRange;

/// Implementation of `NameRegistryAPI` using associative arrays
public class NameRegistry: NameRegistryAPI
{
    /// Logger instance
    protected Logger log;

    ///
    protected RegistryConfig config;

    /// Indexes for `zones`
    private enum ZoneIndex
    {
        Realm = 0,
        Validator = 1,
        Flash = 2,
    }

    /// Zones of the registry
    private ZoneData[ZoneIndex.max + 1] zones;

    /// The domain for `realm`
    private Domain realm;

    /// The domain of `validators` zone
    private Domain validators;

    /// The domain of `flash` zone
    private Domain flash;

    ///
    private NodeLedger ledger;

    ///
    private Height validator_info_height;

    ///
    private ValidatorInfo[] validator_info;

    /// Supported DNS query types
    private immutable QTYPE[] supported_query_types = [
        QTYPE.A, QTYPE.AAAA, QTYPE.CNAME, QTYPE.AXFR, QTYPE.ALL, QTYPE.SOA, QTYPE.NS,
    ];

    ///
    public this (Domain realm, RegistryConfig config, NodeLedger ledger,
        ManagedDatabase cache_db)
    {
        assert(ledger !is null);
        assert(cache_db !is null);

        this.config = config;
        this.log = Logger(__MODULE__);

        this.ledger = ledger;

        this.realm = realm;
        this.validators = Domain.fromSafeString("validators." ~ realm.toString());
        this.flash = Domain.fromSafeString("flash." ~ realm.toString());

        this.zones = [
            ZoneData("realm", this.realm,
                this.config.realm, cache_db, log),
            ZoneData("validator", this.validators,
                this.config.validators, cache_db, log),
            ZoneData("flash",  this.flash,
                this.config.flash, cache_db, log)
        ];

        Utils.getCollectorRegistry().addCollector(&this.collectStats);
    }

    /***************************************************************************

        Collect registry stats

        Params:
            collector = the Collector to collect the stats into

    ***************************************************************************/

    private void collectStats (Collector collector)
    {
        RegistryStats stats;
        stats.registry_validator_record_count = this.zones[ZoneIndex.Validator].count();
        stats.registry_flash_record_count = this.zones[ZoneIndex.Flash].count();
        collector.collect(stats);
    }

    /// Returns: throws if payload is not valid
    protected TYPE ensureValidPayload (in RegistryPayload payload,
        TypedPayload previous) @safe
    {
        // verify signature
        ensure(payload.verifySignature(payload.data.public_key),
                "Incorrect signature for payload");

        // check if we received stale data
        if (previous != TypedPayload.init)
            ensure(previous.payload.data.seq <= payload.data.seq,
                "registry already has a more up-to-date version of the data");

        ensure(payload.data.addresses.length > 0,
                "Payload for '{}' should have addresses but have 0",
                payload.data.public_key);

        // Check that there's either one CNAME, or multiple IPs
        TYPE payload_type;
        foreach (idx, const ref addr; payload.data.addresses)
        {
            const this_type = addr.host.guessAddressType();
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
        TypedPayload payload = this.zones[ZoneIndex.Validator].get(public_key);
        if (payload != TypedPayload.init)
        {
            log.trace("Successfull GET /validator: {} => {}", public_key, payload);
            return payload.payload;
        }
        log.trace("Unsuccessfull GET /validators: {}", public_key);
        return RegistryPayload.init;
    }

    /***************************************************************************

        Get all network addresses of all validators

        Returns:
            Network addresses of all validators

    ***************************************************************************/

    public auto validatorsAddresses ()
    {
        return this.zones[ZoneIndex.Validator].getAddresses();
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
        TYPE payload_type = this.ensureValidPayload(registry_payload,
            this.zones[ZoneIndex.Validator].get(registry_payload.data.public_key));

        // Last step is to check the state of the chain
        auto last_height = this.ledger.getBlockHeight() + 1;
        if (last_height > this.validator_info_height || this.validator_info.length == 0)
        {
            this.validator_info = this.ledger.getValidators(last_height);
            this.validator_info_height = last_height;
        }
        const stake = this.getStake(registry_payload.data.public_key);
        ensure(stake !is Hash.init, "Couldn't find an existing stake to match this key");

        this.zones[ZoneIndex.Validator].update(TypedPayload(payload_type, registry_payload, stake));
    }

    /// Get the stake for which a validator is registering
    private Hash getStake (in PublicKey public_key) @safe
    {
        auto validator_info = this.validator_info
            .find!(info => info.address == public_key);
        if (!validator_info.empty)
            return validator_info.front.utxo;

        foreach (st; this.ledger.getStakes())
            if (public_key == st.output.address())
                return st.hash;

        return Hash.init;
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
        TypedPayload payload = this.zones[ZoneIndex.Flash].get(public_key);
        if (payload != TypedPayload.init)
        {
            log.trace("Successfull GET /flash_node: {} => {}", public_key, payload);
            return payload.payload;
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
        TYPE payload_type = this.ensureValidPayload(registry_payload,
            this.zones[ZoneIndex.Flash].get(registry_payload.data.public_key));

        auto range = this.ledger.getBlocksFrom(channel.height);
        ensure(!range.empty && isValidChannelOpen(channel.conf, range.front),
               "Not a valid channel");

        // register data
        log.info("Registering network addresses: {} for Flash public key: {}", registry_payload.data.addresses,
            registry_payload.data.public_key.toString());
        this.zones[ZoneIndex.Flash].update(TypedPayload(payload_type, registry_payload));
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
          tcp = True if DNS is accessed through TCP

    ***************************************************************************/

    public void answerQuestions (
        in Message query, string peer, scope void delegate (in Message) @safe sender,
        bool tcp = false)
        @safe
    {
        Message reply;
        reply.header.RCODE = Header.RCode.FormatError;
        reply.header.RA = false; // TODO: Implement
        reply.header.AA = true;  // TODO: Make configurable

        // EDNS(0) support
        // payloadSize must be treated to be at least 512. A payloadSize of 0
        // means no OPT record were found (there should be only one),
        // the requestor does not support EDNS0, and we should not include
        // an OPT record in our answer. It is only applicable for UDP.
        ushort payloadSize;
        if (!tcp)
        {
            foreach (const ref add; query.additionals)
            {
                if (add.type == TYPE.OPT)
                {
                    // This is a second OPT record, which is illegal by spec and
                    // triggers a FORMERR
                    if (payloadSize > 0)
                        goto BAILOUT;

                    scope opt = const(OPTRR)(add);
                    // 6.1.1: If an OPT record is present in a received request,
                    // compliant responders MUST include an OPT record in their
                    // respective responses.
                    OPTRR responseOPT;

                    if (opt.EDNSVersion() > 0)
                    {
                        responseOPT.extendedRCODE = 1; // BADVERS
                        reply.additionals ~= responseOPT.record;
                        goto BAILOUT;
                    }
                    // Ignore the DO bit for now
                    payloadSize = min(opt.payloadSize(), ushort(512));
                    reply.additionals ~= responseOPT.record;
                }
            }
            // No OPT record present, the client does not support EDNS
            if (payloadSize == 0)
                payloadSize = 512;
        }

        // Note: Since DNS has some fields which apply to the full response but
        // should actually be in `answers`, most resolvers will not ask unrelated
        // questions / will only ask one question at a time.
        foreach (const ref q; query.questions)
        {
            reply.questions ~= q;

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

            if (!supported_query_types.canFind(q.qtype))
            {
                log.warn("DNS: Ignoring query for unknown QTYPE: {}", q);
                reply.header.RCODE = Header.RCode.NotImplemented;
                break;
            }

            auto answer = this.findZone(q.qname);
            if (!answer)
            {
                log.warn("Refusing {} for unknown zone: {}", q.qtype, q.qname);
                reply.header.RCODE = Header.RCode.Refused;
                break;
            }

            reply.header.RCODE = answer(q, reply, peer);

            if (!tcp && reply.maxSerializedSize() > payloadSize)
            {
                reply.questions = reply.questions[0 .. $ - 1];
                reply.answers = reply.answers[0 .. $ - 1];
                reply.header.TC = true;
                break;
            }
        }

    BAILOUT:
        reply.fill(query.header);
        log.trace("{} DNS query: {} => {}",
                  (reply.header.RCODE == Header.RCode.NoError) ? "Fullfilled" : "Unsuccessfull",
                  query, reply);
        sender(reply);
    }

    /***************************************************************************

        Find zone in registry

        Params:
            name = Domain name of the zone to be found

        Returns:
            Function pointer of answer for the zone, `null` is returned when no
            zone can be found

    ***************************************************************************/

    auto findZone (Domain name, bool matches = true) @safe
    {
        foreach (i, const ref zone; this.zones)
            if (zone.root == name)
                return matches ?
                    &this.zones[i].answer_matches : &this.zones[i].answer_owns;

        auto range = name.value.splitter('.');

        const child = range.front;
        range.popFront();
        if (child.length < 1 || range.front.length < 1)
            return null;
        // Slice past the dot, after making sure there is one (bosagora/agora#2551)
        const parentDomain = Domain.fromSafeString(name.value[child.length + 1 .. $]);
        return this.findZone(parentDomain, false);
    }

    /***************************************************************************

        Callback for block creation

        Params:
          block = New block
          validators_changed = if the validator set has changed with this block

    ***************************************************************************/

    public void onAcceptedBlock (in Block, bool)
        @safe
    {
        this.zones[ZoneIndex.Validator].each!((TypedPayload tpayload) {
            if (this.ledger.getPenaltyDeposit(tpayload.utxo) == 0.coins)
                this.zones[ZoneIndex.Validator].remove(tpayload.payload.data.public_key);
       });
    }
}

/*******************************************************************************

    Parse a PublicKey from the first label of a domain name

    Params:
      domain = The full domain name to parse

    Returns:
      A valid `PublicKey`, or `PublicKey.init`

*******************************************************************************/

private PublicKey extractPublicKey (in char[] domain) @safe
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

    if (auto str = domain.splitter('.').front)
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

    // Most likely case
    assert(extractPublicKey(AStr ~ ".net.bosagora.io") ==
           WK.Keys.A.address);

    // Technically, request may end with the null label (a dot), and the user
    // might also specify it, so test for it.
    assert(extractPublicKey(AStr ~ ".net.bosagora.io.") ==
           WK.Keys.A.address);

    // Without the HRP
    assert(extractPublicKey(AStr["boa1".length .. $] ~ ".net.bosagora.io") ==
           WK.Keys.A.address);

    // Only gTLD
    assert(extractPublicKey(AStr ~ ".bosagora") == WK.Keys.A.address);

    // Uppercase / lowercase doesn't matter, except for the key
    assert(extractPublicKey(AStr ~ ".BOSAGORA") == WK.Keys.A.address);
    assert(extractPublicKey(AStr ~ ".BoSAGorA") == WK.Keys.A.address);
    assert(extractPublicKey(AStr ~ ".BOSAGORA") == WK.Keys.A.address);

    // Rejection tests
    assert(extractPublicKey(AStr[1 .. $] ~ ".boa") is PublicKey.init);
    assert(extractPublicKey(AStr ~ ".bosagora") == WK.Keys.A.address);

    // Uppercase / lowercase doesn't matter, except for the key
    assert(extractPublicKey(AStr ~ ".BOSAGORA") == WK.Keys.A.address);
    assert(extractPublicKey(AStr ~ ".BoSAGorA") == WK.Keys.A.address);
    assert(extractPublicKey(AStr ~ ".BOSAGORA") == WK.Keys.A.address);

    // Rejection tests
    assert(extractPublicKey(AStr[1 .. $] ~ ".boa") is PublicKey.init);
    auto invalid = AStr.dup;
    invalid[0] = 'c';
    assert(extractPublicKey(invalid ~ ".boa") is PublicKey.init);
}

/// Converts a `ZoneConfig` to an `SOA` record
private SOA fromConfig (in ZoneConfig zone, Domain name, uint serial) @safe
{
    return SOA(
        // mname, rname
        Domain.fromString(zone.primary), Domain.fromString(zone.soa.email.value.replace('@', '.')),
        serial,
        // Casts are safe as the values are validated during config parsing
        cast(int) zone.soa.refresh.total!"seconds",
        cast(int) zone.soa.retry.total!"seconds",
        cast(int) zone.soa.expire.total!"seconds",
        cast(uint) zone.soa.minimum.total!"seconds",
    );
}

/// Internal registry data
private struct TypedPayload
{
    /// The DNS RR TYPE
    public TYPE type;

    /// The payload itself
    public RegistryPayload payload;

    /// UTXO
    public Hash utxo;

    /***************************************************************************

        Make an instance of an `TypedPayload` from DNS payload
        (Resource record)

        Params:
            rr = DNS Resource record
            pubKeyParser = Delegate for parsing public key from RR domain

    ***************************************************************************/

    public static TypedPayload make (ResourceRecord rr)
    {
        auto public_key = rr.name.value.extractPublicKey();
        assert(public_key != PublicKey.init,
            "PublicKey cannot be extracted from domain");

        RegistryPayload reg_payload;
        reg_payload.data.public_key = public_key;
        reg_payload.data.ttl = rr.ttl;

        if (rr.type == TYPE.CNAME)
        {
            auto address = rr.rdata.name;

            // TODO SRV is needed to keep intact
            reg_payload.data.addresses ~= Address("http://" ~
                                            cast(string) address.value);
        }
        else if (rr.type == TYPE.A)
        {
            import std.socket : InternetAddress;
            auto addresses = rr.rdata.a;
            reg_payload.data.addresses = addresses.map!(
                (addr) {
                    scope in_addr = new InternetAddress(addr,
                                        InternetAddress.PORT_ANY);

                    // TODO SRV is needed to keep intact
                    return Address("http://" ~ in_addr.toAddrString());
                }
            ).array;
        }

        return TypedPayload(rr.type, reg_payload);
    }

    /***************************************************************************

        Converts a `TypedPayload` to a valid `ResourceRecord`

        Params:
          name = The "question name", or the record name (e.g. in AXFR)

        Throws:
          If the type of `this` payload is not supported, which would be
          a programming error.

    ***************************************************************************/

    public ResourceRecord toRR (const Domain name) const scope
        @safe
    {
        switch (this.type)
        {
        case TYPE.CNAME:
            assert(this.payload.data.addresses.length == 1);
            // FIXME: Use a proper TTL

            /* If it's a CNAME, it has to be to another domain, as we don't
             * yet support aliases in the same zone, hence the algorithm in
             * "RFC1034: 4.3.2. Algorithm" can be reduced to "return the CNAME".
             */
            assert(this.payload.data.addresses.length == 1);
            return ResourceRecord.make!(TYPE.CNAME)(name, this.payload.data.ttl,
                Domain.fromString(this.payload.data.addresses[0].host));

        case TYPE.A:
            // FIXME: Remove allocation
            scope uint[] tmp = new uint[](this.payload.data.addresses.length);
            foreach (idx, addr; this.payload.data.addresses)
            {
                tmp[idx] = InternetAddress.parse(addr.host);
                ensure(tmp[idx] != InternetAddress.ADDR_NONE,
                       "DNS: Address '{}' (index: {}) is not an A record (record: {})",
                       addr, idx, this);
            }
            return ResourceRecord.make!(TYPE.A)(name, this.payload.data.ttl, tmp);
        default:
            ensure(0, "Unknown type: {} - {}", this.type, this);
            assert(0);
        }
    }
}

/// Contains infos related to either `validators` or `flash`
private struct ZoneData
{
    /// Logger instance used by this zone
    private Logger log;

    /// The zone fully qualified name
    public Domain root;

    /// The SOA record
    public SOA soa;

    /// The NS record
    public ResourceRecord nsRecord;

    ///
    private ZoneConfig config;

    /// Query for registry count interface
    private string query_count;

    /// Query for getting all registries
    private string query_registry_get;

    /// Query for getting payload
    private string query_payload;

    /// Query for adding registry utxo table
    private string query_utxo_add;

    /// Query for adding registry to addresses table
    private string query_addresses_add;

    /// Query for removing from registry utxo table
    private string query_utxo_remove;

    /// Query for getting all registered network addresses
    private string query_addresses_get;

    /// Database to store data
    private ManagedDatabase db;

    /***************************************************************************

         Params:
           type_table_name = Registry table for table name
           cache_db = Database instance

    ***************************************************************************/

    public this (string zone_name, Domain root, ZoneConfig config,
        ManagedDatabase cache_db, Logger logger)
    {
        this.db = cache_db;
        this.log = logger;
        this.config = config;
        this.root = root;

        static string serverType (bool auth, bool primary)
        {
            return primary ? "primary" : (auth ? "secondary" : "caching");
        }

        this.log.info("Registry is {} DNS server for zone '{}'",
            serverType(this.config.authoritative, this.config.primary.set),
            this.root);

        if (this.config.primary.set)
            // FIXME: Make it a Domain in the config
            this.nsRecord = ResourceRecord.make!(TYPE.NS)(root, 600, Domain.fromString(this.config.primary.value));
        else
            this.nsRecord = ResourceRecord.init;

        this.query_count = format("SELECT COUNT(*) FROM registry_%s_utxo",
            zone_name);

        this.query_registry_get = format("SELECT pubkey " ~
            "FROM registry_%s_utxo", zone_name);

        this.query_payload = format("SELECT sequence, address, type, utxo, ttl " ~
            "FROM registry_%s_addresses l " ~
            "INNER JOIN registry_%s_utxo r ON l.pubkey = r.pubkey " ~
            "WHERE l.pubkey = ?", zone_name, zone_name);

        this.query_utxo_add = format("REPLACE INTO registry_%s_utxo " ~
            "(pubkey, sequence, utxo) VALUES (?, ?, ?)", zone_name);

        this.query_addresses_add = format("REPLACE INTO registry_%s_addresses " ~
                    "(pubkey, address, type, ttl) VALUES (?, ?, ?, ?)", zone_name);

        this.query_utxo_remove = format("DELETE FROM registry_%s_utxo WHERE pubkey = ?",
            zone_name);

        this.query_addresses_get = format("SELECT address " ~
            "FROM registry_%s_addresses", zone_name);

        string query_sig_create = format("CREATE TABLE IF NOT EXISTS registry_%s_utxo " ~
            "(pubkey TEXT, sequence INTEGER NOT NULL, " ~
            "utxo TEXT NOT NULL, PRIMARY KEY(pubkey))", zone_name);

        string query_addr_create = format("CREATE TABLE IF NOT EXISTS registry_%s_addresses " ~
            "(pubkey TEXT, address TEXT NOT NULL, type INTEGER NOT NULL, " ~
            "ttl INTEGER NOT NULL, " ~
            "FOREIGN KEY(pubkey) REFERENCES registry_%s_utxo(pubkey) ON DELETE CASCADE, " ~
            "PRIMARY KEY(pubkey, address))", zone_name, zone_name);

        this.db.execute(query_sig_create);
        this.db.execute(query_addr_create);

        if (this.config.primary.set)
        {
            // Serial's value wraps around so the cast is safe
            const serial = cast(uint) Clock.currTime(UTC()).toUnixTime();
            this.soa = this.config.fromConfig(this.root, serial);
        }
        else
            // SOA is not default-constructible, so the compiler complains
            this.soa = SOA.init;
    }

    /***************************************************************************

         Returns:
           Total number of name registries

    ***************************************************************************/

    public ulong count () @trusted
    {
        auto results = this.db.execute(this.query_count);
        return results.empty ? 0 : results.oneValue!(ulong);
    }


    /***************************************************************************

        Iterates over all registered payloads

        This function supports iterating over all payload, allowing for zone
        transfer or any other zone-wide operation.

    ***************************************************************************/

    public int opApply (scope int delegate(ref const TypedPayload) dg) @trusted
    {
        auto query_results = this.db.execute(this.query_registry_get);

        foreach (row; query_results)
        {
            auto registry_pub_key = PublicKey.fromString(row["pubkey"].as!string);
            auto payload = this.get(registry_pub_key);
            if (auto res = dg(payload))
                return res;
        }

        return 0;
    }

    /***************************************************************************

         Answer a given question using this zone's data

         Returns:
          A code corresponding to the result of the query.
          `Header.RCode.Refused` is returned for the following conditions;
            - Query type is AXFR and query name is not matching with zone
            - Query type is not AXFR and query name is not owned by zone

          Check `doAXFR` (AXFR queries) or `getKeyDNSRecord` (other queries)
          for other returns.

    ***************************************************************************/

    public Header.RCode answer (bool matches, in Question q, ref Message reply,
        string peer) @safe
    {
        if (q.qtype == QTYPE.AXFR)
            return matches && this.config.allow_transfer.canFind(peer)
                ? this.doAXFR(reply) : Header.RCode.Refused;
        else if (q.qtype == QTYPE.SOA)
        {
            if (matches)
                reply.answers ~= ResourceRecord.make!(TYPE.SOA)(this.root, 0, this.soa);
            else
                reply.authorities ~= ResourceRecord.make!(TYPE.SOA)(this.root, 0, this.soa);

            return Header.RCode.NoError;
        }
        else if (q.qtype == QTYPE.NS)
        {
            if (!matches)
                return Header.RCode.Refused;
            reply.answers ~= this.nsRecord;
            return Header.RCode.NoError;
        }
        else if (!matches)
            return this.getKeyDNSRecord(q, reply);
        else
            return Header.RCode.Refused;
    }

    /// Ditto
    public Header.RCode answer_matches (in Question q, ref Message reply,
        string peer) @safe
    {
        return this.answer(true, q, reply, peer);
    }

    /// Ditto
    public Header.RCode answer_owns (in Question q, ref Message reply,
        string peer) @safe
    {
        return this.answer(false, q, reply, peer);
    }

    /***************************************************************************

        Perform AXFR for this zone

        Allow servers to synchronize with one another using this standard DNS
        query. Note that there are better ways to do synchronization,
        but AXFR was in the original specification.
        See RFC1034 "4.3.5. Zone maintenance and transfers".

        Params:
          reply = The `Message` to write to

    ***************************************************************************/

    private Header.RCode doAXFR (ref Message reply) @safe
    {
        log.info("Performing AXFR for {} ({} entries)", this.root.value, this.count());

        auto soa = ResourceRecord.make!(TYPE.SOA)(this.root, 0, this.soa);
        reply.answers ~= soa;

        foreach (const ref payload; this)
        {
            reply.answers ~= payload.toRR(Domain.fromString(format("%s.%s",
                payload.payload.data.public_key, this.root.value)));
        }

        reply.answers ~= soa;
        return Header.RCode.NoError;
    }

    /***************************************************************************

        Get a single key's DNS record.

        Queries sent to the server may attempt to look up multiple keys,
        which is handled by `answer`. This method looks up a single
        host name and return all associated addresses.

        Since we might have multiple addresses registered for a single key,
        we first attempt to find an IP address (`TYPE.A`) or IPv6 (`TYPE.AAAA`).
        If not, we return a `CNAME` (`TYPE.CNAME`).

        Params:
          question = The question being asked (contains the hostname)
          reply = A struct to fill the `answers` section with the addresses

        Returns:
          A code corresponding to the result of the lookup.
          If the lookup was successful, `Header.RCode.NoError` will be returned.
          Otherwise, the correct error code (non 0) is returned.

    ***************************************************************************/

    private Header.RCode getKeyDNSRecord (
        const ref Question question, ref Message reply) @safe
    {
        const public_key = question.qname.value.extractPublicKey();
        if (public_key is PublicKey.init)
            return Header.RCode.FormatError;

        TypedPayload payload = this.get(public_key, question.qtype);
        // We are authoritative, so we can set `NameError`
        if (payload == TypedPayload.init || !payload.payload.data.addresses.length)
            return Header.RCode.NameError;

        reply.answers ~= payload.toRR(question.qname);
        reply.authorities ~= ResourceRecord.make!(TYPE.SOA)(this.root, 0, this.soa); // optional
        return Header.RCode.NoError;
    }

    /***************************************************************************

         Get payload data from persistent storage

         Params:
           public_key = the public key that was used to register
                         the network addresses

           type = the type of the record that was requested, default is `ALL`

        Returns:
            TypedPayload with type `type` of name registry associated with
            `public_key`. All records are returned when `type` is `ALL`

    ***************************************************************************/

    public TypedPayload get (PublicKey public_key, QTYPE type = QTYPE.ALL) @trusted
    {
        auto results = this.db.execute(this.query_payload, public_key);

        if (results.empty)
            return TypedPayload.init;

        // Address loop consumes data, gather following first
        const TYPE node_type = to!TYPE(results.front["type"].as!ushort);

        // Check query type; QTYPE is superset of TYPE, casting is OK
        // RFC#1034 : Section 3.6.2
        if (node_type != TYPE.CNAME
            && type != QTYPE.ALL && type != cast(QTYPE) node_type)
            return TypedPayload.init;

        const ulong sequence = results.front["sequence"].as!ulong;
        const Hash utxo = Hash.fromString(results.front["utxo"].as!string);
        const auto ttl = results.front["ttl"].as!uint;
        const auto addresses = results.map!(r => Address(r["address"].as!string)).array;

        const RegistryPayload payload =
        {
            data:
            {
                public_key : public_key,
                addresses : addresses,
                seq : sequence,
                ttl : ttl,
            },
        };

        return TypedPayload(node_type, payload, utxo);
    }

    /***************************************************************************

        Returns:
          A range of addresses contained in this zone

    ***************************************************************************/

    public auto getAddresses ()
    {
        auto results = this.db.execute(this.query_addresses_get);
        return results.map!(r => Address(r["address"].as!string));
    }

    /***************************************************************************

         Remove payload data from persistent storage

         Params:
           public_key = the public key that was used to register
                         the network addresses

    ***************************************************************************/

    public void remove (PublicKey public_key) @trusted
    {
        this.db.execute(this.query_utxo_remove, public_key);

        if (this.db.changes)
            this.soa.serial = cast(uint) Clock.currTime(UTC()).toUnixTime();
    }

    /***************************************************************************

         Updates matching payload in the persistent storage. Payload is added
         to the persistent storage when no matching payload is found.

         Params:
           payload = Payload to update

    ***************************************************************************/

    public void update (TypedPayload payload) @trusted
    {
        if (payload.payload.data.addresses.length == 0)
            return;

        // Payload is equal to Zone's data, no need to update
        if (this.get(payload.payload.data.public_key) == payload)
        {
            log.info("{} sent same payload data, zone is not updated",
                payload.payload.data.public_key);
            return;
        }

        log.info("Registering addresses {}: {} for public key: {}", payload.type,
            payload.payload.data.addresses, payload.payload.data.public_key);

        db.execute(this.query_utxo_add,
            payload.payload.data.public_key,
            payload.payload.data.seq,
            payload.utxo);

        // There is no need to check for stale addresses
        // since `REPLACE INTO` is used and `DELETE` is cascaded.
        foreach (address; payload.payload.data.addresses)
        {
            db.execute(this.query_addresses_add,
                payload.payload.data.public_key,
                address,
                payload.type.to!ushort,
                payload.payload.data.ttl);
        }

        this.soa.serial = cast(uint) Clock.currTime(UTC()).toUnixTime();
    }
}

unittest
{
    import std.algorithm;
    import agora.consensus.Ledger;
    import agora.utils.Test;
    import agora.consensus.data.genesis.Test: genesis_validator_keys;
    import agora.consensus.data.Transaction;
    import agora.consensus.data.Enrollment;
    import agora.consensus.data.UTXO;

    NameRegistry registry;
    scope ledger = new TestLedger(genesis_validator_keys[0], null, null,
        (in Block block, bool changed) @safe {
            registry.onAcceptedBlock(block, changed);
        });
    registry = new NameRegistry(Domain.fromSafeString("test."),
        RegistryConfig(true), ledger, new ManagedDatabase(":memory:"));

    static RegistryPayload makeTestPayload (in KeyPair pair)
    {
        auto result = RegistryPayload(
            RegistryPayloadData(pair.address, [Address("agora://address")], 0)
        );
        result.signPayload(pair);
        return result;
    }

    // Make sure it fails initially
    auto payload = makeTestPayload(WK.Keys[0]);
    payload.signPayload(WK.Keys[0]);
    assert(payload.verifySignature(payload.data.public_key));
    assert(payload.verifySignature(WK.Keys[0].address));

    try
    {
        registry.postValidator(payload);
        assert(0);
    }
    catch (Exception e)
        assert(e.message == "Couldn't find an existing stake to match this key");

    // Generate payment transactions to the first 8 well-known keypairs
    auto txs = genesisSpendable().enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign(OutputType.Freeze))
        .array;
    txs.each!(tx => assert(ledger.acceptTransaction(tx) is null));
    ledger.forceCreateBlock();
    assert(ledger.getBlockHeight() == 1);

    // Test a key that is not enrolled
    auto nep = makeTestPayload(WK.Keys[1]);
    registry.postValidator(nep);

    // Now enroll and see if it works as validator too
    auto enroll = Enrollment(
        UTXO.getHash(txs[0].hashFull(), 0),
        Hash.init,
    );
    enroll.enroll_sig = WK.Keys[0].sign(hashMulti(Height(2), enroll));
    assert(ledger.enrollment_manager.addEnrollment(enroll, WK.Keys[0].address,
        Height(2), &ledger.peekUTXO, &ledger.getPenaltyDeposit));

    // externalize enrollment
    ledger.forceCreateBlock();
    assert(ledger.getBlockHeight() == 2);

    try
        registry.postValidator(payload);
    catch (Exception e)
        assert(0, e.message);

    assert(RegistryPayload.init != registry.getValidator(WK.Keys[0].address));

    ledger.forceCreateBlock();
    assert(ledger.getBlockHeight() == 3);
    // frozen UTXO is spent (slashed), entry should have been deleted
    assert(RegistryPayload.init == registry.getValidator(WK.Keys[0].address));
}
