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
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.UTXO;
import agora.consensus.data.ValidatorInfo;
import agora.consensus.Ledger;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr: Signature;
import agora.network.DNSResolver : DNSResolver;
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

import core.time;

static import std.uni;

import d2sqlite3 : ResultRange;
import vibe.http.client;
import vibe.web.rest;

/// Implementation of `NameRegistryAPI` using associative arrays
public class NameRegistry: NameRegistryAPI
{
    /// Logger instance
    protected Logger log;

    ///
    protected RegistryConfig config;

    /// Zones of the registry
    private ZoneData[3] zones;

    /// The domain for `realm`
    private Domain realm;

    /// The domain of `validators` zone
    private Domain validators;

    /// The domain of `flash` zone
    private Domain flash;

    ///
    private Ledger ledger;

    ///
    private Height validator_info_height;

    ///
    private ValidatorInfo[] validator_info;

    /// Supported DNS query types
    private immutable QTYPE[] supported_query_types = [
        QTYPE.A, QTYPE.CNAME, QTYPE.AXFR, QTYPE.ALL, QTYPE.SOA,
    ];

    ///
    private ResourceRecord[] nsRecords = [
        ResourceRecord(
            Domain("testnet.bosagora.io"), TYPE.NS, CLASS.IN, 600,
            ResourceRecord.RDATA(Domain("ns1.bosagora.io."))),
    ];

    ///
    public this (string realm, RegistryConfig config, Ledger ledger,
        ManagedDatabase cache_db, ITaskManager taskman)
    {
        assert(realm.length > 0, "No 'realm' provided");
        assert(ledger !is null);
        assert(cache_db !is null);

        this.config = config;
        this.log = Logger(__MODULE__);

        this.ledger = ledger;

        this.realm = Domain(realm);
        this.validators = Domain("validators." ~ realm);
        this.flash = Domain("flash." ~ realm);

        this.zones = [
            ZoneData("realm", this.realm,
                this.config.realm, cache_db, log, taskman),
            ZoneData("validator", this.validators,
                this.config.validators, cache_db, log, taskman),
            ZoneData("flash",  this.flash,
                this.config.flash, cache_db, log, taskman)
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
        stats.registry_validator_record_count = this.zones[1].count();
        stats.registry_flash_record_count = this.zones[2].count();
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
        TypedPayload payload = this.zones[1].get(public_key);
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

    public Address[] getValidatorsAddresses ()
    {
        return this.zones[1].getAddresses();
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
        if (this.zones[1].config.type == ZoneConfig.Type.secondary)
        {
            this.zones[1].redirect_primary.postValidator(registry_payload);
            return;
        }

        TYPE payload_type = this.ensureValidPayload(registry_payload,
            this.zones[1].get(registry_payload.data.public_key));

        // Last step is to check the state of the chain
        auto last_height = this.ledger.getBlockHeight() + 1;
        if (last_height > this.validator_info_height || this.validator_info.length == 0)
        {
            this.validator_info = this.ledger.getValidators(last_height);
            this.validator_info_height = last_height;
        }
        UTXO utxo;
        auto validator_info = this.validator_info
            .find!(info => info.address == registry_payload.data.public_key);
        auto enrollment = this.ledger.getCandidateEnrollments(last_height, &this.ledger.peekUTXO)
                .find!(enroll => this.ledger.peekUTXO(enroll.utxo_key, utxo)
                    && (utxo.output.address == registry_payload.data.public_key));
        ensure(!validator_info.empty || !enrollment.empty, "Not an enrolled validator");
        auto stake = validator_info.empty ? enrollment.front.utxo_key : validator_info.front.utxo;
        assert(stake != Hash.init);

        this.zones[1].update(TypedPayload(payload_type, registry_payload, stake));
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
        TypedPayload payload = this.zones[2].get(public_key);
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
        if (this.zones[2].config.type == ZoneConfig.Type.secondary)
        {
            this.zones[2].redirect_primary.postFlashNode(registry_payload, channel);
            return;
        }

        TYPE payload_type = this.ensureValidPayload(registry_payload,
            this.zones[2].get(registry_payload.data.public_key));

        auto range = this.ledger.getBlocksFrom(channel.height);
        ensure(!range.empty && isValidChannelOpen(channel.conf, range.front),
               "Not a valid channel");

        // register data
        log.info("Registering network addresses: {} for Flash public key: {}", registry_payload.data.addresses,
            registry_payload.data.public_key.toString());
        this.zones[2].update(TypedPayload(payload_type, registry_payload));
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
        in Message query, string peer, scope void delegate (in Message) @safe sender)
        @safe
    {
        Message reply;
        reply.header.RCODE = Header.RCode.FormatError;
        reply.header.RA = false;
        reply.header.AA = true;

        // EDNS(0) support
        // payloadSize must be treated to be at least 512. A payloadSize of 0
        // means no OPT record were found (there should be only one),
        // the requestor does not support EDNS0, and we should not include
        // an OPT record in our answer.
        ushort payloadSize;
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

            // Relying on the note of loop
            reply.header.RCODE = answer(q, reply, peer);

            if (reply.maxSerializedSize() > payloadSize)
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
        foreach (i, zone; this.zones)
            if (zone.root == name)
                return matches ?
                    &this.zones[i].answer_matches : &this.zones[i].answer_owns;

        auto range = name.value.splitter('.');
        if (range.empty || range.front.length < 1)
            return null;

        const child = range.front;
        range.popFront();
        if (range.empty)
            return null;
        // Slice past the dot, after making sure there is one (bosagora/agora#2551)
        const parentDomain = Domain(name.value[child.length + 1 .. $]);
        return this.findZone(parentDomain, false);
    }

    /***************************************************************************

        Callback for block creation

        Params:
          block = New block
          validators_changed = if the validator set has changed with this block

    ***************************************************************************/

    public void onAcceptedBlock (in Block, bool validators_changed)
        @safe
    {
        ZoneConfig.Type validator_type = this.zones[1].config.type;

        if (validator_type == ZoneConfig.Type.primary)
        {
            this.zones[1].each!((TypedPayload tpayload) {
                if (this.ledger.getPenaltyDeposit(tpayload.utxo) == 0.coins)
                    this.zones[1].remove(tpayload.payload.data.public_key);
            });
        }
        else if (validator_type == ZoneConfig.Type.secondary
                    && validators_changed)
        {
            // Even this manipulates the SOA timings, we can think it as a
            // NOTIFY request of the DNS, new node is found and zone needs update
            () @trusted {
                if (this.zones[1].soa_update_timer.pending)
                {
                    this.zones[1].soa_update_timer.stop;
                    this.zones[1].updateSOA();
                }
            } ();
        }
    }
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
    assert(zone.parsePublicKeyFromDomain(AStr ~ ".net.bosagora.io") ==
           WK.Keys.A.address);

    // Technically, request may end with the null label (a dot), and the user
    // might also specify it, so test for it.
    assert(zone.parsePublicKeyFromDomain(AStr ~ ".net.bosagora.io.") ==
           WK.Keys.A.address);

    // Without the HRP
    assert(zone.parsePublicKeyFromDomain(AStr["boa1".length .. $] ~ ".net.bosagora.io") ==
           WK.Keys.A.address);

    // Only gTLD
    zone.root = Domain("bosagora");
    assert(zone.parsePublicKeyFromDomain(AStr ~ ".bosagora") == WK.Keys.A.address);

    // Uppercase / lowercase doesn't matter, except for the key
    assert(zone.parsePublicKeyFromDomain(AStr ~ ".BOSAGORA") == WK.Keys.A.address);
    assert(zone.parsePublicKeyFromDomain(AStr ~ ".BoSAGorA") == WK.Keys.A.address);
    zone.root = Domain(".BoSAgOrA");
    assert(zone.parsePublicKeyFromDomain(AStr ~ ".BOSAGORA") == WK.Keys.A.address);

    // Rejection tests
    zone.root = Domain("boa");
    assert(zone.parsePublicKeyFromDomain(AStr[1 .. $] ~ ".boa") is PublicKey.init);
    auto invalid = AStr.dup;
    invalid[0] = 'c';
    assert(zone.parsePublicKeyFromDomain(invalid ~ ".boa") is PublicKey.init);
}

/// Converts a `ZoneConfig` to an `SOA` record
private SOA fromConfig (in ZoneConfig zone, Domain name) @safe pure
{
    SOA soa;
    soa.mname = Domain(format("ns1.%s", name.value));
    soa.rname = Domain(zone.soa.email.value.replace('@', '.'));
    soa.serial = 0;
    // Casts are safe as the values are validated during config parsing
    soa.refresh = cast(int) zone.soa.refresh.total!"seconds";
    soa.retry = cast(int) zone.soa.retry.total!"seconds";
    soa.expire = cast(int) zone.soa.expire.total!"seconds";
    soa.minimum = cast(uint) zone.soa.minimum.total!"seconds";
    return soa;
}

/// Associate a `RegistryPayload` with internal data
private struct TypedPayload
{
    /// The DNS RR TYPE
    public TYPE type;

    /// The payload itself
    public RegistryPayload payload;

    /// UTXO
    public Hash utxo;

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
                Domain(this.payload.data.addresses[0].host));

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
    /// Name of the zone
    private string name;

    /// Logger instance used by this zone
    private Logger log;

    /// The zone fully qualified name
    public Domain root;

    /// The SOA record
    public SOA soa;

    /// TTL of the SOA RR
    private uint soa_ttl;

    ///
    private ZoneConfig config;

    /// Query for registry count interface
    private string query_count;

    /// Query for getting all registries
    private string query_registry_get;

    /// Query for getting payload
    private string query_payload;

    /// Query for adding registry signature table, only for primary
    private string query_utxo_add;

    /// Query for adding registry to addresses table
    private string query_addresses_add;

    /// Query for removing from registry signature table, only for primary
    private string query_remove_sig;

    /// Query for getting all registered network addresses
    private string query_addresses_get;

    /// Query for clean up zone before AXFR, only for secondary zone
    private string query_axfr_cleanup;

    /// Database to store data
    private ManagedDatabase db;

    /// DNS resolver to send request, only for secondary
    private DNSResolver resolver;

    /// Timer for requesting SOA from a primary to check serial, only for secondary
    private ITimer soa_update_timer;

    /// Timer for disabling zone when SOA check cannot be completed, only for secondary
    private ITimer soa_update_expire_timer;

    /// Task manager to manage timers
    private ITaskManager taskman;

    /// REST API of a primary registry to redirect API calls, only for secondary
    private NameRegistryAPI redirect_primary;

    /***************************************************************************

         Params:
           type_table_name = Registry table for table name
           cache_db = Database instance

    ***************************************************************************/

    public this (string zone_name, Domain root, ZoneConfig config,
        ManagedDatabase cache_db, Logger logger, ITaskManager taskman)
    {
        this.name = zone_name;
        this.db = cache_db;
        this.log = logger;
        this.config = config;
        this.root = root;

        static string serverType (ZoneConfig.Type zone_type)
        {
            switch (zone_type)
            {
                case ZoneConfig.Type.primary: return "primary (authoritative)";
                case ZoneConfig.Type.secondary: return "secondary (authoritative)";
                case ZoneConfig.Type.caching: return "caching (non-authoritative)";
                default: return "Unknown";
            }
        }

        this.log.info("Registry is {} DNS server for zone '{}'",
            serverType(this.config.type),
            this.root);

         // Initialize zone type specific queries
        string query_addr_create;
        auto utxo_exists = !this.db.execute(
                format("SELECT name FROM sqlite_master WHERE type='table' " ~
                    "AND name='registry_%s_utxo'", name)
            ).empty();
        if (this.config.type == ZoneConfig.Type.primary)
        {
            // Zone type might be changed to primary
            if (!utxo_exists)
                this.db.execute(
                    format("DROP TABLE IF EXISTS registry_%s_addresses", name));

            this.query_utxo_add = format("REPLACE INTO registry_%s_utxo " ~
                "(pubkey, sequence, utxo) VALUES (?, ?, ?)", name);

            this.query_remove_sig = format("DELETE FROM registry_%s_utxo WHERE pubkey = ?",
                name);

            this.query_payload = format("SELECT sequence, address, type, utxo " ~
                "FROM registry_%s_addresses l " ~
                "INNER JOIN registry_%s_utxo r ON l.pubkey = r.pubkey " ~
                "WHERE l.pubkey = ?", name, name);

            string query_sig_create = format("CREATE TABLE IF NOT EXISTS registry_%s_utxo " ~
                "(pubkey TEXT, sequence INTEGER NOT NULL," ~
                "utxo TEXT NOT NULL, PRIMARY KEY(pubkey))", name);

            query_addr_create = format("CREATE TABLE IF NOT EXISTS registry_%s_addresses " ~
                "(pubkey TEXT, address TEXT NOT NULL, type INTEGER NOT NULL, " ~
                "ttl INTEGER NOT NULL, " ~
                "FOREIGN KEY(pubkey) REFERENCES registry_%s_utxo(pubkey) ON DELETE CASCADE, " ~
                "PRIMARY KEY(pubkey, address))", name, name);

            this.db.execute(query_sig_create);
        }
        else if (this.config.type == ZoneConfig.Type.secondary
                    || this.config.type == ZoneConfig.Type.caching)
        {
            // Zone type changed from primary
            if (utxo_exists)
            {
                this.db.execute(format("DROP TABLE registry_%s_utxo", name));
                this.db.execute(
                    format("DROP TABLE IF EXISTS registry_%s_addresses", name));
            }

            this.query_payload = format("SELECT address, type " ~
                "FROM registry_%s_addresses " ~
                "WHERE pubkey = ?", name);

            query_addr_create = format("CREATE TABLE IF NOT EXISTS registry_%s_addresses " ~
                "(pubkey TEXT, address TEXT NOT NULL, type INTEGER NOT NULL, " ~
                "ttl INTEGER NOT NULL, expires INTEGER, " ~
                "PRIMARY KEY(pubkey, address))", name);

            this.taskman = taskman;

            // DNS resolver is used to get SOA RR and performing AXFR
            Address[] peer_addrs;
            this.config.primary_servers.each!(
                peer => peer_addrs ~= Address("dns://" ~ peer)
            );
            this.resolver = new DNSResolver(peer_addrs);

            if (this.config.type == ZoneConfig.Type.secondary)
            {
                this.query_axfr_cleanup = format("DELETE FROM registry_%s_addresses", name);
                // Since a secondary zone cannot transfer UTXO, sequence and signature
                // fields of data from a primary, it redirects API calls to API of the
                // configured primary
                auto settings = new RestInterfaceSettings;
                settings.baseURL = Address(this.config.redirect_primary);
                settings.httpClientSettings = new HTTPClientSettings;
                settings.httpClientSettings.connectTimeout = 2.seconds;
                settings.httpClientSettings.readTimeout = 2.seconds;
                this.redirect_primary = new RestInterfaceClient!NameRegistryAPI(settings);
                this.soa_update_expire_timer = this.taskman.createTimer(&this.disable);
            }

            this.soa_update_timer = this.taskman.createTimer(&this.updateSOA);
        }
        else // Caching (not implemented yet) or unknown
            return;

        // Initialize common fields
        this.soa = this.config.fromConfig(this.root);
        this.soa_ttl = 0;

        this.query_count = format("SELECT COUNT(DISTINCT pubkey) FROM registry_%s_addresses",
            name);

        this.query_registry_get = format("SELECT DISTINCT(pubkey) " ~
            "FROM registry_%s_addresses", name);

        this.query_addresses_add = format("REPLACE INTO registry_%s_addresses " ~
                    "(pubkey, address, type, ttl) VALUES (?, ?, ?, ?)", name);

        this.query_addresses_get = format("SELECT address " ~
            "FROM registry_%s_addresses", name);

        // UTXO table is only available on primary Zones
        this.db.execute(query_addr_create);
        this.updateSOA();
    }

    /***************************************************************************

        Update the SOA RR of the zone

        Zone serial is set to current time when the zone is primary.
        If zone is secondary, SOA RR is requested from a configured primary and
        local SOA RR is updated accordingly. If new SOA RR has newer serial field
        AXFR transfer is initiated. SOA RR update is performed periodically
        according to the SOA RR's refresh field. SOA RR update period will be
        changed to the SOA RR's retry field and zone will be disabled after
        `EXPIRE` time when SOA RR request from primary fails.

        See also RFC 1034 - Section 4.3.5

        Caching zone will cache the SOA RR and will refresh the record according
        to the TTL value.

        Caching the SOA is allowed, see RFC 2181 - Section 7.2

    ***************************************************************************/

    private void updateSOA ()
    {
        if (this.config.type == ZoneConfig.Type.primary)
        {
            () @trusted
            {
                this.soa.serial = cast(uint) Clock.currTime(UTC()).toUnixTime();
            } ();
            return;
        }

        auto soa_answer = this.resolver.query(this.root.value, QTYPE.SOA);
        if (soa_answer.length != 1 || soa_answer[0].type != TYPE.SOA)
        {
            this.log.warn("{}: Couldn't get SOA record, will retry in {} seconds",
                this.name, this.soa.retry);

            this.soa_update_timer.rearm(this.soa.retry.seconds, false);
            if (this.config.type == ZoneConfig.Type.secondary)
                this.soa_update_expire_timer.rearm(this.soa.expire.seconds, false);

            return;
        }

        this.soa_ttl = soa_answer[0].ttl;
        SOA new_soa = soa_answer[0].rdata.soa;
        if (new_soa.serial > this.soa.serial)
        {
            this.soa = new_soa;
            if (this.config.type == ZoneConfig.Type.secondary)
                this.axfrTransfer();
        }
        else
            this.log.info("{}: Zone SOA is up-to-date", this.name);

        auto refresh = (this.config.type == ZoneConfig.Type.secondary)
                        ? this.soa.refresh.seconds : this.soa_ttl.seconds;

        refresh = (refresh == 0) ? 5.seconds : refresh;

        this.soa_update_timer.rearm(refresh, false);

        if (this.config.type == ZoneConfig.Type.secondary)
            this.soa_update_expire_timer.stop();
    }

    /***************************************************************************

        Disable the zone

        A secondary zone is disabled when SOA serial cannot be checked for updates
        after `EXPIRE` amount of time. Zone is disabled by cleaning up all RRs.
        Thus, zone will return `NameError` to queries.

    ***************************************************************************/

    private void disable ()
    {
        // This will cause disabled zone to return NameError for queries
        this.db.execute(this.query_axfr_cleanup);
        this.log.warn("{}: Zone is disabled until one of primaries is reachable",
            this.name);
    }

    /***************************************************************************

        Perform AXFR zone transfer

        A secondary server will transfer zone from primary when a zone update
        is detected.

    ***************************************************************************/

    private void axfrTransfer ()
    {
        ResourceRecord[] axfr_answer = this.resolver.query(this.root.value, QTYPE.AXFR);

        // We should answer with old Zone data until AXFR completes
        // since Agora is single threaded, there is nothing to do
        this.db.execute(this.query_axfr_cleanup);

        foreach (ResourceRecord rr; axfr_answer)
        {
            auto label = this.parsePublicKeyFromDomain(rr.name.value);
            if (label == PublicKey.init)
                continue;

            if (rr.type == TYPE.CNAME)
            {
                auto address = rr.rdata.name;
                this.db.execute(this.query_addresses_add,
                    label,
                    "http://" ~ address.value, // TODO SRV is needed to keep intact
                    rr.type.to!ushort,
                    rr.ttl);
            }
            else if (rr.type == TYPE.A)
            {
                import std.socket : InternetAddress;
                auto addresses = rr.rdata.a;
                foreach (addr; addresses)
                {
                    auto inaddr = new InternetAddress(addr, InternetAddress.PORT_ANY);
                    this.db.execute(this.query_addresses_add,
                        label,
                        "http://" ~ inaddr.toAddrString(), // TODO SRV is needed to keep intact
                        rr.type.to!ushort,
                        rr.ttl);
                }
            }
        }
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
            - Requesting peer is not whitelisted to perform AXFR

          Check `doAXFR` (AXFR queries) or `getKeyDNSRecord` (other queries)
          for other returns.

    ***************************************************************************/

    public Header.RCode answer (bool matches, in Question q,
        ref Message reply, string peer) @safe
    {
        if (this.config.type == ZoneConfig.Type.caching)
        {
            reply.header.AA = false;
            reply.header.RA = true;
        }

        if (q.qtype == QTYPE.AXFR)
            return matches
                    && this.config.allow_transfer.canFind(peer)
                    && this.config.type != ZoneConfig.Type.caching
                    ? this.doAXFR(reply) : Header.RCode.Refused;
        else if (q.qtype == QTYPE.SOA)
        {
            if (matches)
                reply.answers ~= ResourceRecord.make!(TYPE.SOA)(this.root,
                    this.soa_ttl, this.soa);
            else
                reply.authorities ~= ResourceRecord.make!(TYPE.SOA)(this.root,
                    this.soa_ttl, this.soa);

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

        auto soa = ResourceRecord.make!(TYPE.SOA)(this.root, this.soa_ttl, this.soa);
        reply.answers ~= soa;

        foreach (const ref payload; this)
        {
            reply.answers ~= payload.toRR(Domain(format("%s.%s",
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
        const public_key = this.parsePublicKeyFromDomain(question.qname.value);
        if (public_key is PublicKey.init)
            return Header.RCode.FormatError;

        ResourceRecord[] answers;
        TypedPayload payload = this.get(public_key, question.qtype);
        if (payload == TypedPayload.init || !payload.payload.data.addresses.length)
            if (this.config.type == ZoneConfig.Type.caching)
                answers = this.resolver.query(question.qname.value, question.qtype);
            else
                return Header.RCode.NameError;
        else
            answers = payload.toRR(question.qname);

        if (this.config.type != ZoneConfig.Type.caching ||
            (this.config.type == ZoneConfig.Type.caching && !answers.length))
                reply.authorities ~= ResourceRecord.make!(TYPE.SOA)(
                                        this.root, this.soa_ttl, this.soa); // optional

        if (!answers.length)
            return Header.RCode.NameError;
        else if (this.config.type == ZoneConfig.type.caching)
        {
            // TODO add to DB if TTL > 0
            // TODO setup TTL timer
        }

        reply.answers ~= answers;

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

        const ulong sequence = (this.config.type == ZoneConfig.Type.primary) ?
            results.front["sequence"].as!ulong : 0;
        Hash utxo = Hash.init;
        if (this.config.type == ZoneConfig.Type.primary)
            utxo = Hash.fromString(results.front["utxo"].as!string);

        const auto addresses = results.map!(r => Address(r["address"].as!string)).array;

        const RegistryPayload payload =
        {
            data:
            {
                public_key : public_key,
                addresses : addresses,
                seq : sequence,
            },
        };

        // CNAME and A cannot exist at the same time for a node
        TypedPayload typed_payload =
        {
            type: node_type,
            payload: payload,
            utxo: utxo,
        };

        return typed_payload;
    }

    public Address[] getAddresses ()
    {
        auto results = this.db.execute(this.query_addresses_get);

        if (results.empty)
            return null;

        return results.map!(r => Address(r["address"].as!string)).array;
    }

    /***************************************************************************

         Remove payload data from persistent storage

         Params:
           public_key = the public key that was used to register
                         the network addresses

    ***************************************************************************/

    public void remove (PublicKey public_key) @trusted
    {
        this.db.execute(this.query_remove_sig, public_key);

        if (this.db.changes)
            this.updateSOA();
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

        this.updateSOA();
    }

    /***************************************************************************

        Parse a PublicKey from a domain name for the given zone

        Params:
          domain = The full domain name to parse

        Returns:
          A valid `PublicKey` that `domain` points to, or `PublicKey.init`

    ***************************************************************************/

    private PublicKey parsePublicKeyFromDomain (in char[] domain) const scope
        @safe
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

        // `findZone` ensures, `domain` is owned by us;
        // thus this method should NEVER be `public`
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
    import agora.test.Base : LocalRestTaskManager;

    NameRegistry registry;
    scope ledger = new TestLedger(genesis_validator_keys[0], null, null, (in Block block, bool changed) @safe {
        registry.onAcceptedBlock(block, changed);
    });

    import agora.config.Attributes : SetInfo;
    auto validator_soa = ZoneConfig.SOAConfig(SetInfo!string("test@localhost", true));
    auto validator = ZoneConfig(ZoneConfig.type.primary, ["localhost"], null,
        "", validator_soa);
    auto reg_config = RegistryConfig(true, "0.0.0.0", 53, ZoneConfig.init,
        validator, ZoneConfig.init);

    registry = new NameRegistry("test", reg_config, ledger,
        new ManagedDatabase(":memory:"), new LocalRestTaskManager);

    // Generate payment transactions to the first 8 well-known keypairs
    auto txs = genesisSpendable().enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign(OutputType.Freeze))
        .array;
    txs.each!(tx => assert(ledger.acceptTransaction(tx) is null));
    ledger.forceCreateBlock();
    assert(ledger.getBlockHeight() == 1);

    auto payload = RegistryPayload(RegistryPayloadData(WK.Keys[0].address, [Address("agora://address")], 0));
    auto payloadA = RegistryPayload(RegistryPayloadData(WK.Keys[1].address, [Address("agora://127.0.0.1")], 0));
    payload.signPayload(WK.Keys[0]);
    payloadA.signPayload(WK.Keys[1]);

    try
    {
        registry.postValidator(payload);
        assert(0);
    }
    catch (Exception e)
        assert(e.message == "Not an enrolled validator");

    auto enroll = Enrollment(
        UTXO.getHash(txs[0].hashFull(), 0),
        Hash.init,
    );
    enroll.enroll_sig = WK.Keys[0].sign(enroll);
    assert(ledger.enrollment_manager.addEnrollment(enroll, WK.Keys[0].address,
        Height(2), &ledger.peekUTXO, &ledger.getPenaltyDeposit));
    enroll = Enrollment(UTXO.getHash(txs[1].hashFull(), 0), Hash.init);
    enroll.enroll_sig = WK.Keys[1].sign(enroll);
    ledger.enrollment_manager.addEnrollment(enroll, WK.Keys[1].address,
        Height(2), &ledger.peekUTXO, &ledger.getPenaltyDeposit);

    try
    {
        registry.postValidator(payload);
        registry.postValidator(payloadA);
    }
    catch (Exception e)
        assert(0, e.message);

    // externalize enrollment
    ledger.forceCreateBlock(0);
    assert(ledger.getBlockHeight() == 2);
    assert(RegistryPayload.init != registry.getValidator(WK.Keys[0].address));

    // Test DNS implementation
    import std.random : uniform;

    Message ask;
    ask.header.ID = uniform!short;
    ask.header.RD = true;
    ask.header.QDCOUNT = 1;
    ask.questions ~= Question.init;

    Question[] test_qs = [
        /* valid_cname */
        Question(
            Domain(WK.Keys[0].address.toString~".validators.test"),
            QTYPE.CNAME, QCLASS.IN
        ),
        /* unsup_query */
        Question(
            Domain(WK.Keys[0].address.toString~".validators.test"),
            QTYPE.HINFO, QCLASS.IN
        ),
        /* nonexisting_zone */
        Question(
            Domain(WK.Keys[0].address.toString~".nonexist.not"),
            QTYPE.CNAME, QCLASS.IN
        ),
        /* soa_answer */
        Question(
            Domain("validators.test"), QTYPE.SOA, QCLASS.IN
        ),
        /* soa_auth */
        Question(
            Domain(WK.Keys[0].address.toString~".validators.test"),
            QTYPE.SOA, QCLASS.IN
        ),
        /* AXFR not matches */
        Question(
            Domain(WK.Keys[0].address.toString~".validators.test"),
            QTYPE.AXFR, QCLASS.IN
        ),
        /* AXFR */
        Question(
            Domain("validators.test"),
            QTYPE.AXFR, QCLASS.IN
        ),
        /* A query shall return CNAME */
        Question(
            Domain(WK.Keys[0].address.toString~".validators.test"),
            QTYPE.A, QCLASS.IN
        ),
        /* valid A */
        Question(
            Domain(WK.Keys[1].address.toString~".validators.test"),
            QTYPE.A, QCLASS.IN
        ),
    ];

    void dns_answer(in Message msg) @trusted
    {
        if (msg.questions.length != 1)
            assert(0);

        if (msg.questions[0] == test_qs[0])
        {
            assert(msg.header.RCODE == Header.RCode.NoError);
            assert(1 == msg.answers.length);
            assert(TYPE.CNAME == msg.answers[0].type);
            assert(Domain("address") == msg.answers[0].rdata.name);
        }
        else if (msg.questions[0] == test_qs[1])
            assert(msg.header.RCODE == Header.RCode.NotImplemented);
        else if (msg.questions[0] == test_qs[2])
            assert(msg.header.RCODE == Header.RCode.Refused);
        else if (msg.questions[0] == test_qs[3])
        {
            assert(msg.header.RCODE == Header.RCode.NoError);
            assert(1 == msg.answers.length);
            assert(TYPE.SOA == msg.answers[0].type);
            assert(Domain("ns1.validators.test") == msg.answers[0].rdata.soa.mname);
        }
        else if (msg.questions[0] == test_qs[4])
        {
            assert(msg.header.RCODE == Header.RCode.NoError);
            assert(1 == msg.authorities.length);
            assert(TYPE.SOA == msg.authorities[0].type);
            assert(Domain("ns1.validators.test") == msg.authorities[0].rdata.soa.mname);
        }
        else if (msg.questions[0] == test_qs[5])
            assert(msg.header.RCODE == Header.RCode.Refused);
        else if (msg.questions[0] == test_qs[6])
        {
            assert(msg.header.RCODE == Header.RCode.NoError);
            assert(4 == msg.answers.length);
            assert(TYPE.SOA == msg.answers[0].type);
            assert(TYPE.CNAME == msg.answers[2].type);
            assert(TYPE.SOA == msg.answers[3].type);
            assert(msg.answers[0] == msg.answers[3]);
            assert(Domain("address") == msg.answers[2].rdata.name);
        }
        else if (msg.questions[0] == test_qs[7])
        {
            assert(msg.header.RCODE == Header.RCode.NoError);
            assert(TYPE.CNAME == msg.answers[0].type);
            assert(Domain("address") == msg.answers[0].rdata.name);
        }
        else if (msg.questions[0] == test_qs[8])
        {
            assert(msg.header.RCODE == Header.RCode.NoError);
            assert(1 == msg.answers.length);
            assert(TYPE.A == msg.answers[0].type);
            assert("127.0.0.1:0" ==
                new InternetAddress(msg.answers[0].rdata.a[0],
                    InternetAddress.PORT_ANY).toString);
        }
        else
        {
            assert(0);
        }
    }

    foreach (q; test_qs)
    {
        ask.questions[0] = q;
        registry.answerQuestions(ask, "localhost", &dns_answer);
    }

    ledger.forceCreateBlock(0);
    assert(ledger.getBlockHeight() == 3);
    // frozen UTXO is spent (slashed), entry should have been deleted
    assert(RegistryPayload.init == registry.getValidator(WK.Keys[0].address));
}
