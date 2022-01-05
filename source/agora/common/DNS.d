/*******************************************************************************

    Type definitions for implementing and communicating with a DNS server.

    The type names may follow RFC1035 rather than our own coding convention,
    although exceptions are made, e.g. when a field name and type conflict.
    Comments have been copied from RFC1035 verbatim.

    Extensions to RFC1035, such as the RFC linked below, are currently
    not implemented.

    See_Also:
        - Initial RFC: https://datatracker.ietf.org/doc/html/rfc1035
        - IANA considerations: https://datatracker.ietf.org/doc/html/rfc5395
        - Extension (EDNS0): https://datatracker.ietf.org/doc/html/rfc6891
        - DNSSEC: https://www.internetsociety.org/resources/deploy360/2011/dnssec-rfcs-3/

*******************************************************************************/

module agora.common.DNS;

import agora.common.Ensure;
import agora.common.Types : Address;
import agora.serialization.Serializer;

import std.algorithm.iteration;
import std.bitmanip;
import std.format;
import std.range;
import std.string;

/*******************************************************************************

    List of record types.

    Originally defined in RFC1035, then extended through many RFCs.
    A good overview can be obtained from the Wikipedia article linked below.

    See_Also:
        https://datatracker.ietf.org/doc/html/rfc1035#section-3.2.2
        https://en.wikipedia.org/wiki/List_of_DNS_record_types

*******************************************************************************/

enum TYPE : ushort
{
    A     =  1, /// a host address
    NS    =  2, /// an authoritative name server
    MD    =  3, /// a mail destination (Obsolete - use MX)
    MF    =  4, /// a mail forwarder (Obsolete - use MX)
    CNAME =  5, /// the canonical name for an alias
    SOA   =  6, //// marks the start of a zone of authority
    MB    =  7, /// a mailbox domain name (EXPERIMENTAL)
    MG    =  8, /// a mail group member (EXPERIMENTAL)
    MR    =  9, /// a mail rename domain name (EXPERIMENTAL)
    NULL  = 10, /// a null RR (EXPERIMENTAL)
    WKS   = 11, /// a well known service description
    PTR   = 12, /// a domain name pointer
    HINFO = 13, /// host information (redefined in RFC 8482)
    MINFO = 14, /// mailbox or mail list information
    MX    = 15, /// mail exchange
    TXT   = 16, /// text strings

    // End of RFC1035 records

    AAAA   =  28, /// IPv6 host address (RFC 3596)
    LOC    =  29, /// Geolocation record (RFC 1876)
    SRV    =  33, /// Generalized service location record (RFC 2782)
    NAPTR  =  35, /// Naming Authority Pointer (RFC 3403)
    DNAME  =  39, /// Delegated name, a non-unique CNAME (RFC 6672)
    OPT    =  41, /// Options (Pseudo record for EDNS)
    DS     =  43, /// DNSSEC Delegation signer (RFC 4034)
    RRSIG  =  46, /// DNSSEC Signature (RFC 4034)
    DNSKEY =  48, /// DNSSEC Key record (RFC 4034)
    CSYNC  =  62, /// Child to parent synchronization (RFC 7477)
    URI    = 256, /// Mappings from hostnames to URIs (RFC 7553)
    CAA    = 257, /// DNS certification authority authorization (RFC 6844)

}

/// https://datatracker.ietf.org/doc/html/rfc1035#section-3.2.3
enum QTYPE : ushort
{
    A      = TYPE.A     , /// a host address
    NS     = TYPE.NS    , /// an authoritative name server
    MD     = TYPE.MD    , /// a mail destination (Obsolete - use MX)
    MF     = TYPE.MF    , /// a mail forwarder (Obsolete - use MX)
    CNAME  = TYPE.CNAME , /// the canonical name for an alias
    SOA    = TYPE.SOA   , //// marks the start of a zone of authority
    MB     = TYPE.MB    , /// a mailbox domain name (EXPERIMENTAL)
    MG     = TYPE.MG    , /// a mail group member (EXPERIMENTAL)
    MR     = TYPE.MR    , /// a mail rename domain name (EXPERIMENTAL)
    NULL   = TYPE.NULL  , /// a null RR (EXPERIMENTAL)
    WKS    = TYPE.WKS   , /// a well known service description
    PTR    = TYPE.PTR   , /// a domain name pointer
    HINFO  = TYPE.HINFO , /// host information
    MINFO  = TYPE.MINFO , /// mailbox or mail list information
    MX     = TYPE.MX    , /// mail exchange
    TXT    = TYPE.TXT   , /// text strings
    AAAA   = TYPE.AAAA  , /// IPv6 host address (RFC 3596)
    LOC    = TYPE.LOC   , /// Geolocation record (RFC 1876)
    SRV    = TYPE.SRV   , /// Generalized service location record (RFC 2782)
    NAPTR  = TYPE.NAPTR , /// Naming Authority Pointer (RFC 3403)
    DNAME  = TYPE.DNAME , /// Delegated name, a non-unique CNAME (RFC 6672)
    DS     = TYPE.DS    , /// DNSSEC Delegation signer (RFC 4034)
    RRSIG  = TYPE.RRSIG , /// DNSSEC Signature (RFC 4034)
    DNSKEY = TYPE.DNSKEY, /// DNSSEC Key record (RFC 4034)
    CSYNC  = TYPE.CSYNC , /// Child to parent synchronization (RFC 7477)
    URI    = TYPE.URI   , /// Mappings from hostnames to URIs (RFC 7553)
    CAA    = TYPE.CAA   , /// DNS certification authority authorization (RFC 6844)

    IXFR  = 251, /// Incremental zone transfer (RFC 1996)
    AXFR  = 252, /// A request for a transfer of an entire zone
    MAILB = 253, /// A request for mailbox-related records (MB, MG or MR)
    MAILA = 254, /// A request for mail agent RRs (Obsolete - see MX)
    ALL   = 255, /// A request for all records
}

/// https://datatracker.ietf.org/doc/html/rfc1035#section-3.2.4
enum CLASS : ushort
{
    IN = 1, /// the Internet
    CS = 2, /// the CSNET class (Obsolete - used only for examples in some obsolete RFCs)
    CH = 3, /// the CHAOS class
    HS = 4, /// Hesiod [Dyer 87]
}

/// https://datatracker.ietf.org/doc/html/rfc1035#section-3.2.5
enum QCLASS : ushort
{
    IN = 1, /// the Internet
    CS = 2, /// the CSNET class (Obsolete - used only for examples in some obsolete RFCs)
    CH = 3, /// the CHAOS class
    HS = 4, /// Hesiod [Dyer 87]

    ANY = 255, /// any class
}

/// https://datatracker.ietf.org/doc/html/rfc1035#section-3.3.13
public struct SOA
{
    /// The <domain-name> of the name server that was the
    /// original or primary source of data for this zone.
    public Domain mname;

    /// A <domain-name> which specifies the mailbox of the
    /// person responsible for this zone.
    public Domain rname;

    /// The unsigned 32 bit version number of the original copy
    /// of the zone.  Zone transfers preserve this value.  This
    /// value wraps and should be compared using sequence space
    /// arithmetic.
    public uint serial;

    /// A 32 bit time interval before the zone should be refreshed.
    public int refresh;

    /// A 32 bit time interval that should elapse before a
    /// failed refresh should be retried.
    public int retry;

    /// A 32 bit time value that specifies the upper limit on
    /// the time interval that can elapse before the zone is no
    /// longer authoritative.
    public int expire;

    /// The unsigned 32 bit minimum TTL field that should be
    /// exported with any RR from this zone.
    public uint minimum;

    /// Support for network serialization
    public static T fromBinary (T) (scope ref DNSDeserializerContext ctx) @safe
    {
        return T(Domain.fromBinary!(typeof(T.mname))(ctx),
            Domain.fromBinary!(typeof(T.rname))(ctx),
            deserializeFull!(uint)(&ctx.read, ctx.options),
            deserializeFull!(int)(&ctx.read, ctx.options),
            deserializeFull!(int)(&ctx.read, ctx.options),
            deserializeFull!(int)(&ctx.read, ctx.options),
            deserializeFull!(uint)(&ctx.read, ctx.options),
        );
    }
}

/// https://datatracker.ietf.org/doc/html/rfc2782
public struct SRVRDATA
{
    /// The priority of this target host (lowest is better)
    public ushort priority;

    /// A server selection mechanism for entries with the same priority
    public ushort weight;

    // The port on this target host of this service.
    public ushort port;

    /// The domain name of the target host (should not be an alias)
    /// Using '.' means that the service doesn't exists.
    public Domain target;
}

/// https://datatracker.ietf.org/doc/html/rfc7553#section-4
public struct URIRDATA
{
    /// The priority of this target host (lowest is better)
    public ushort priority;

    /// A server selection mechanism for entries with the same priority
    public ushort weight;

    /// This field holds the URI of the target (RFC 3986)
    /// Resolution of the URI is according to the definitions for the Scheme of the URI.
    public Address target;
}

/// https://datatracker.ietf.org/doc/html/rfc1035#section-4
public struct Message
{
    /// Always present
    public Header header;

    /// The question for the name server
    public Question[] questions;

    /// RRs answering the question
    public ResourceRecord[] answers;

    /// RRs pointing toward an authority
    public ResourceRecord[] authorities;

    /// RRs holding additional information
    public ResourceRecord[] additionals;

    /***************************************************************************

        Fill this `Message`'s header, ensuring consistency with a query

        This method allows a server to simplify a few of the tasks required
        when answering a DNS query:
        - It sets the `ID` in the header to match the query's;
        - It sets the header's `*COUNT` fields according to the arrays here;
        - It will perform any additional setup required based on the query;

        Params:
            query = The `Header` of the query

        Returns:
            A reference to `this`

    ***************************************************************************/

    public ref Message fill (in Header query) return @safe pure nothrow @nogc
    {
        this.header.ID = query.ID;
        this.header.QR = true;
        this.header.OPCODE = query.OPCODE;
        // Copied regardless of support according to the RFC
        this.header.RD = query.RD;

        assert(this.questions.length <= ushort.max);
        this.header.QDCOUNT = cast(ushort) this.questions.length;
        assert(this.answers.length <= ushort.max);
        this.header.ANCOUNT = cast(ushort) this.answers.length;
        assert(this.authorities.length <= ushort.max);
        this.header.NSCOUNT = cast(ushort) this.authorities.length;
        assert(this.additionals.length <= ushort.max);
        this.header.ARCOUNT = cast(ushort) this.additionals.length;

        return this;
    }

    /// Support for network serialization
    public static T fromBinary (T) (
        scope DeserializeDg data, in DeserializerOptions opts) @safe
    {
        import std.array : array;
        import std.range : iota;

        // Needed to keep track of previously seen domains
        DNSDeserializerContext ctx = {
            index: 0,
            domains: null,
            data: data,
            options: { maxLength: opts.maxLength, compact: CompactMode.No },
        };

        // All RR are qualified the same so just use this
        alias QRRT = typeof(T.answers[0]);

        auto hdr = deserializeFull!(typeof(T.header))(&ctx.read, ctx.options);
        auto f1 = iota(hdr.QDCOUNT)
            .map!(_ => Question.fromBinary!(typeof(T.questions[0]))(ctx)).array();
        auto f2 = iota(hdr.ANCOUNT)
            .map!(_ => ResourceRecord.fromBinary!QRRT(ctx)).array();
        auto f3 = iota(hdr.NSCOUNT)
            .map!(_ => ResourceRecord.fromBinary!QRRT(ctx)).array();
        auto f4 = iota(hdr.ARCOUNT)
            .map!(_ => ResourceRecord.fromBinary!QRRT(ctx)).array();
        return T(hdr, f1, f2, f3, f4);
    }

    /// Ditto
    public void serialize (scope SerializeDg dg) const @safe
    {
        serializePart(this.header, dg, CompactMode.No);
        this.questions.each!(e => serializePart(e, dg, CompactMode.No));
        this.answers.each!(e => serializePart(e, dg, CompactMode.No));
        this.authorities.each!(e => serializePart(e, dg, CompactMode.No));
        this.additionals.each!(e => serializePart(e, dg, CompactMode.No));
    }

    /***************************************************************************

        Gives the estimated serialized size

        This routine can be used to avoid serialization if it goes over the
        payload size (either 512 or EDNS0-set) expectation.
        Note that this does not take into account compression, which could
        significantly reduce the size.

    ***************************************************************************/

    public size_t maxSerializedSize () const scope @safe pure nothrow @nogc
    {
        // Header is a POD without indirection
        size_t size = Header.sizeof;

        // Question is QTYPE + QCLASS + Domain
        // Domain's serialized size is at most `data.length + 1`,
        // and at least 2 bytes (a pointer)
        foreach (const ref q; this.questions)
            size += (QTYPE.sizeof + QCLASS.sizeof + q.qname.value.length + 1);

        auto allRRs = this.answers.chain(this.authorities).chain(this.additionals);
        foreach (const ref a; allRRs)
        {
            () @trusted
            {
                size += (a.name.value.length + 1 + TYPE.sizeof + CLASS.sizeof +
                    uint.sizeof + ushort.sizeof + a.rdata.binary.length);
            } ();
        }

        return size;
    }
}

/// https://datatracker.ietf.org/doc/html/rfc1035#section-4.1.1
public struct Header
{
    /// Humean readable representation loosely inspired from `dig`
    public void toString (scope void delegate(in char[]) @safe sink)
        const scope @safe
    {
        formattedWrite!"ID: %04x %s"(sink, this.ID, this.OPCODE);
        if (this.QR) sink(" qr");
        if (this.AA) sink(" aa");
        if (this.TC) sink(" tc");
        if (this.RD) sink(" rd");
        if (this.RA) sink(" ra");
        formattedWrite!" %s, Query: %s, Answer: %s, Authority: %s, Additional: %s"(
            sink, this.RCODE, this.QDCOUNT, this.ANCOUNT, this.NSCOUNT, this.ARCOUNT);
    }

    @safe pure nothrow @nogc:

    /// A 16 bit identifier assigned by the program that
    /// generates any kind of query.  This identifier is copied
    /// the corresponding reply and can be used by the requester
    /// to match up replies to outstanding queries.
    public ushort ID;

    /***************************************************************************

        Function prototype for setting or getting specified bit(s) of field

        Params:
            position = LSB position for reqested bit(s)
            T = Type to cast when getting bit(s), default is `bool`
            mask = Bitmask to select bit(s) to be effected starting from `position`, default is 1-bit

    ***************************************************************************/
    private mixin template BitGetterSetter (ubyte position, T = bool, ushort mask = 0x1)
    {
        /// Get bit(s) masked with `mask` starting from `position` as `T`
        T getset () const scope { return cast (T) ((this.field2 >> position) & mask); }
        /// Set bit(s) masked with `mask` starting from `position`
        void getset (T val) scope { this.field2 = (this.field2 & ~(mask << position)) | ((mask&val) << position); }
    }

    mixin BitGetterSetter!(15) mix_QR;
    /// A one bit field that specifies whether this message is a
    /// query (0), or a response (1).
    public alias QR = mix_QR.getset;

    mixin BitGetterSetter!(11, OpCode, 0xf) mix_OPCODE;
    /// A four bit field that specifies kind of query in this message.
    /// This value is set by the originator of a query and copied into the response.
    enum OpCode : ubyte
    {
        /// a standard query
        QUERY =  0,
        /// an inverse query (IQUERY)
        IQUERY = 1,
        /// a server status request
        STATUS = 2,
        // 3-15: reserved for future use
    }
    /// Ditto
    public alias OPCODE = mix_OPCODE.getset;

    mixin BitGetterSetter!(10) mix_AA;
    /***************************************************************************

        Authoritative Answer

        This bit is valid in responses, and specifies that the responding
        name server is an authority for the domain name in question section.

        Note that the contents of the answer section may have
        multiple owner names because of aliases.
        The AA bit corresponds to the name which matches the query name, or
        the first owner name in the answer section.

    ***************************************************************************/
    public alias AA = mix_AA.getset;

    mixin BitGetterSetter!(9) mix_TC;
    /// TrunCation - specifies that this message was truncated
    /// due to length greater than that permitted on the transmission channel.
    public alias TC = mix_TC.getset;

    mixin BitGetterSetter!(8) mix_RD;
    /// Recursion Desired
    /// This bit may be set in a query and is copied into the response.
    /// If RD is set, it directs the name server to pursue the query recursively.
    /// Recursive query support is optional.
    public alias RD = mix_RD.getset;

    mixin BitGetterSetter!(7) mix_RA;
    /// Recursion Available
    /// This bit is set or cleared in a response, and denotes whether recursive
    /// query support is available in the name server.
    public alias RA = mix_RA.getset;

    mixin BitGetterSetter!(6) mix_Z;
    /// Reserved for future use. Must be zero in all queries and responses.
    public alias Z = mix_Z.getset;

    mixin BitGetterSetter!(5) mix_AD;
    /// Authenticated Data, initially defined in RFC2065
    public alias AD  = mix_AD.getset;

    mixin BitGetterSetter!(4) mix_CD;
    /// Checking Disabled, initially defined in RFC2065
    public alias CD = mix_CD.getset;

    mixin BitGetterSetter!(0, RCode, 0xf) mix_RCODE;
    /// Response code - this 4 bit field is set as part of responses.
    public enum RCode : ubyte
    {
        // No error condition
        NoError = 0,

        /// The name server was unable to interpret the query.
        FormatError = 1,

        /// The name server was unable to process this query due to a
        /// problem with the name server.
        ServerFailure = 2,

        /// Meaningful only for responses from an authoritative name server,
        /// this code signifies that the domain name referenced in the query
        /// does not exist.
        NameError = 3,

        /// The name server does not support the requested kind of query.
        NotImplemented = 4,

        /// The name server refuses to perform the specified operation for
        /// policy reasons. For example, a name server may not wish to provide
        /// the information to the particular requester,
        /// or a name server may not wish to perform a particular operation
        /// (e.g., zone transfer) for particular data.
        Refused = 5,
        // 6-15: Reserved for future use.
    }
    /// Ditto
    public alias RCODE = mix_RCODE.getset;

    /// 16 bits backing the second "line" of the header, see RFC1035, 4.1.1
    private ushort field2;

    /// An unsigned 16 bit integer specifying the number of entries in the question section.
    public ushort QDCOUNT;

    /// An unsigned 16 bit integer specifying the number of resource records in the answer section.
    public ushort ANCOUNT;

    /// An unsigned 16 bit integer specifying the number of name server resource records
    /// in the authority records section.
    public ushort NSCOUNT;

    /// An unsigned 16 bit integer specifying the number of resource records
    /// in the additional records section.
    public ushort ARCOUNT;
}

unittest
{
    Header hdr;

    assert(!hdr.QR);
    hdr.QR = true;
    assert(hdr.QR);
    hdr.QR = false;
    assert(!hdr.QR);
    hdr.QR = true;
    assert(hdr.QR);

    assert(hdr.OPCODE == Header.OpCode.QUERY);
    hdr.OPCODE = Header.OpCode.STATUS;
    assert(hdr.OPCODE == Header.OpCode.STATUS);

    assert(!hdr.AA);
    hdr.AA = true;
    assert(hdr.AA);

    assert(!hdr.TC);
    hdr.TC = true;
    assert(hdr.TC);
    hdr.TC = false;
    assert(!hdr.TC);
    hdr.TC = true;
    assert(hdr.TC);

    assert(!hdr.RD);
    hdr.RD = true;
    assert(hdr.RD);

    assert(!hdr.RA);
    hdr.RA = true;
    assert(hdr.RA);

    assert(hdr.RCODE == Header.RCode.NoError);
    hdr.RCODE = Header.RCode.Refused;
    assert(hdr.RCODE == Header.RCode.Refused);
    hdr.RCODE = Header.RCode.NoError;
    assert(hdr.RCODE == Header.RCode.NoError);
    hdr.RCODE = Header.RCode.Refused;

    assert(hdr.field2 == 0b1_0010_1_1_1_1_000_0101);
}

/// https://datatracker.ietf.org/doc/html/rfc1035#section-4.1.2
public struct Question
{
    /// A  domain name represented as a sequence of labels, where
    /// each label consists of a length octet followed by that
    /// number of octets.  The domain name terminates with the
    /// zero length octet for the null label of the root.  Note
    /// that this field may be an odd number of octets; no
    /// padding is used.
    public Domain qname;

    /// A two octet code which specifies the type of the query.
    /// The values for this field include all codes valid for a
    /// TYPE field, together with some more general codes which
    /// can match more than one type of RR.
    public QTYPE qtype;

    /// A two octet code that specifies the class of the query.
    /// For example, the QCLASS field is IN for the Internet.
    public QCLASS qclass;

    /// Support for network serialization
    /// Note that this method is not called directly by the deserializer,
    /// as it needs to support arbitrary pointers into the message
    public static T fromBinary (T) (scope ref DNSDeserializerContext ctx) @safe
    {
        return T(Domain.fromBinary!(typeof(T.init.qname))(ctx),
                 deserializeFull!QTYPE(&ctx.read, ctx.options),
                 deserializeFull!QCLASS(&ctx.read, ctx.options),
            );
    }
}

/// https://datatracker.ietf.org/doc/html/rfc1035#section-4.1.3
public struct ResourceRecord
{
    /// Make a record of the given type
    public static ResourceRecord make (TYPE type) (Domain name, uint ttl,
        ubyte[] rdata) @safe
    {
        return ResourceRecord(name, type, CLASS.IN, ttl, RDATA(rdata));
    }

    /// Make a record of SOA type
    public static ResourceRecord make (TYPE type : TYPE.SOA) (
        Domain name, uint ttl, SOA soa) @safe
    {
        return ResourceRecord(name, TYPE.SOA, CLASS.IN, ttl, RDATA(soa));
    }

    /// Make a record of CNAME type
    public static ResourceRecord make (TYPE type : TYPE.CNAME) (
        Domain name, uint ttl, Domain cname) @safe
    {
        return ResourceRecord(name, TYPE.CNAME, CLASS.IN, ttl, RDATA(cname));
    }

    /// Make a record of A type
    public static ResourceRecord make (TYPE type : TYPE.A) (
        Domain name, uint ttl, uint[] ipv4...) @safe
    {
        return ResourceRecord(name, TYPE.A, CLASS.IN, ttl, RDATA(ipv4));
    }

    /// Make a record of URI type
    public static ResourceRecord make (TYPE type : TYPE.URI) (
        Domain name, uint ttl, Address uri, ushort prio = 0, ushort weight = 0)
        @safe
    {
        return ResourceRecord(name, TYPE.URI, CLASS.IN, ttl, RDATA(URIRDATA(
            prio, weight, uri
        )));
    }

    /// A domain name to which this resource record pertains.
    public Domain name;

    /// Two octets containing one of the RR type codes.
    /// This field specifies the meaning of the data in the RDATA field.
    public TYPE type;

    /// Two octets which specify the class of the data in the RDATA field.
    public CLASS class_;

    /// A 32 bit unsigned integer that specifies the time interval (in seconds)
    /// that the resource record may be cached before it should be discarded.
    /// Zero values are interpreted to mean that the RR can only be used for the
    /// transaction in progress, and should not be cached.
    public uint ttl;

    // This is `rdata.length` with extra validation
    version (none)
    {
        /// An unsigned 16 bit integer that specifies the length in octets of the RDATA field.
        public ushort rdlength;
    }

    /// A variable length string of octets that describes the resource.
    /// The format of this information varies according to the TYPE and CLASS
    /// of the resource record.
    /// For example, the if the TYPE is A and the CLASS is IN,
    /// the RDATA field is a 4 octet ARPA Internet address.
    public union RDATA
    {
        /// The binary data, if the `TYPE` is not known / implemented
        public ubyte[] binary;

        /// An `A` record, meaning one or more IPv4 addresses
        /// https://datatracker.ietf.org/doc/html/rfc1035#section-3.3.14
        public uint[] a;

        /// A 128 bit IPv6 address is encoded in the data portion of an AAAA
        /// resource record in network byte order (high-order byte first).
        /// https://datatracker.ietf.org/doc/html/rfc3596#section-2.2
        public ulong[2] aaaa;

        /// A domain name: this is used by various record types,
        /// for example as CNAME, MX, NS...
        public Domain name;

        /// The content of an SOA section
        public SOA soa;

        /// An `URI` record data
        public URIRDATA uri;

        /***********************************************************************

           Construct an instance of this union

           Supported types are that of the `union`, plus a special overload
           for `typeof(null)` (equivalent to `(ubyte[]).init`).

        ***********************************************************************/

        public this (inout(ubyte)[] val) inout @safe pure nothrow @nogc
        {
            this.binary = val;
        }

        /// Ditto
        public this (inout typeof(null)) inout @safe pure nothrow @nogc
        {
            this.binary = null;
        }

        /// Ditto
        public this (inout(uint)[] val) inout @safe pure nothrow @nogc
        {
            this.a = val;
        }

        /// Ditto
        public this (inout(Domain) val) inout @safe pure nothrow @nogc
        {
            this.name = val;
        }

        /// Ditto
        public this (inout(SOA) val) inout @safe pure nothrow @nogc
        {
            this.soa = val;
        }

        /// Ditto
        public this (inout(URIRDATA) val) inout @safe pure nothrow @nogc
        {
            this.uri = val;
        }

        public void toString (scope void delegate(in char[]) @safe sink)
            const scope @trusted
        {
            formattedWrite!"%u byte(s)"(sink, this.binary.length);
        }
    }

    public RDATA rdata;

    /// Support for network serialization
    public static T fromBinary (T) (scope ref DNSDeserializerContext ctx) @safe
    {
        auto tmp = T(
            Domain.fromBinary!(typeof(T.name))(ctx),
            deserializeFull!(TYPE)(&ctx.read, ctx.options),
            deserializeFull!(CLASS)(&ctx.read, ctx.options),
            deserializeFull!(uint)(&ctx.read, ctx.options),
        );

        auto rdlength = deserializeFull!(ushort)(&ctx.read, ctx.options);

        ResourceRecord.RDATA tmp_data;
        () @trusted
        {
            switch (tmp.type)
            {
                case TYPE.A:
                    foreach (_; 0 .. (rdlength / uint.sizeof))
                       tmp_data.a ~= deserializeFull!(uint)(&ctx.read, ctx.options);
                    break;
                case TYPE.CNAME:
                    tmp_data.name = Domain.fromBinary!(Domain)(ctx);
                    break;
                case TYPE.SOA:
                    tmp_data.soa = SOA.fromBinary!(SOA)(ctx);
                    break;
                case TYPE.URI:
                    tmp_data.uri = deserializeFull!(URIRDATA)(&ctx.read, ctx.options);
                    break;
                default:
                    tmp_data.binary = cast(ubyte[]) ctx.read(rdlength);
                    break;
            }
        } ();

        return T(
            tmp.name, tmp.type, tmp.class_, tmp.ttl,
            () @trusted { return cast(typeof(T.rdata)) tmp_data; } ()
        );
    }

    /// Ditto
    public void serialize (scope SerializeDg dg) const @safe
    {
        serializePart(this.name, dg, CompactMode.No);
        serializePart(this.type, dg, CompactMode.No);
        serializePart(this.class_, dg, CompactMode.No);
        serializePart(this.ttl, dg, CompactMode.No);
        auto rdata = () @trusted
        {
            switch (this.type)
            {
                case TYPE.A:
                    ubyte[] tmp_ip;
                    foreach (ip; this.rdata.a)
                        tmp_ip ~= ip.serializeFull(CompactMode.No);
                    return tmp_ip;
                case TYPE.CNAME:
                    return this.rdata.name.serializeFull();
                case TYPE.SOA:
                    return this.rdata.soa.serializeFull(CompactMode.No);
                case TYPE.URI:
                    return this.rdata.uri.serializeFull(CompactMode.No);
                default:
                    return this.rdata.binary;
            }
        } ();
        ensure(rdata.length < ushort.max,
               "Field `DNS.ResourceRecord.rdata` should exceed data limit: {}",
               rdata.length);
        serializePart!ushort(rdata.length % ushort.max, dg, CompactMode.No);
        dg(rdata);
    }
}

unittest
{
    checkFromBinary!Message();

    auto root = Domain(".");
    assert(root.serializeFull() == [0]);

    auto dlang = Domain("dlang.org.");
    assert(dlang.serializeFull() == [ubyte(5), 'd', 'l', 'a', 'n', 'g', 3, 'o', 'r', 'g', 0 ]);

    auto dlang2 = Domain("dlang.org"); // No trailing dot
    assert(dlang.serializeFull() == dlang2.serializeFull());

    auto lroot = root.byLabel();
    assert(!lroot.empty);
    assert(lroot.front.length == 0);
    lroot.popFront();
    assert(lroot.empty);

    auto ldlang = dlang.byLabel();
    assert(!ldlang.empty);
    ldlang.popFront();
    assert(!ldlang.empty);
    assert(ldlang.front == "org");
    ldlang.popFront();
    assert(!ldlang.empty);
    assert(ldlang.front == "dlang");
    ldlang.popFront();
    assert(ldlang.empty);
}

unittest
{
    import std.socket : InternetAddress;

    string test_ip = "127.0.0.1";
    auto ips = new uint[](1);
    ips[0] = InternetAddress.parse(test_ip);

    ResourceRecord a_rr = ResourceRecord.make!(TYPE.A)(Domain("localhost"), 0, ips);

    auto uri_target = Address("agora://test.local:1234");
    ResourceRecord uri_rr = ResourceRecord.make!(TYPE.URI)(
        Domain("_agora._tcp"), 0, uri_target
    );
    Message msg;
    msg.answers ~= a_rr;
    msg.answers ~= uri_rr;
    msg.fill(msg.header);

    ubyte[] serialized_msg = msg.serializeFull(CompactMode.No);
    Message deserialized_msg = serialized_msg.deserializeFull!(Message);
    assert(deserialized_msg.answers.length == 2);
    ResourceRecord msg_a_rr = deserialized_msg.answers[0];
    ResourceRecord msg_uri_rr = deserialized_msg.answers[1];

    assert(msg_a_rr.type == TYPE.A);
    assert(msg_a_rr.rdata.a[0] == ips[0]);
    assert(msg_uri_rr.type == TYPE.URI);
    assert(msg_uri_rr.rdata.uri.priority == 0);
    assert(msg_uri_rr.rdata.uri.target.port == 1234);
    assert(msg_uri_rr.rdata.uri.target == uri_target);
}

/// The OPT opcode is a special ResourceRecord with its own semantic
/// See https://datatracker.ietf.org/doc/html/rfc6891
public struct OPTRR
{
    @safe pure nothrow @nogc:

    /***************************************************************************

        The underlying ResourceRecord

        OPT records are backed by RR, but their fields are to be interpreted
        differently, e.g. `ttl` is a bitfield (since OPT MUST NOT be cached),
        and `CLASS` is the UDP payload size.

        This struct wraps the record and expose a set of get / set properties
        for easy manipulation.

        See_Also:
          https://datatracker.ietf.org/doc/html/rfc6891#section-6.1.3

    ***************************************************************************/

    public ResourceRecord record = ResourceRecord(Domain.init, TYPE.OPT, cast(CLASS) 4096);

    /// Requestor's UDP payload size
    public ushort payloadSize () scope const
    {
        return this.record.class_;
    }

    /// Ditto
    public void payloadSize (ushort value) scope
    {
        this.record.class_ = cast(CLASS) value;
    }

    /// Upper byte of the header RCODE
    /// Currently only BADVERS (0x01) is supported
    public ubyte extendedRCODE () scope const
    {
        return this.record.ttl >> 24;
    }

    /// Ditto
    public void extendedRCODE (ubyte upperByteValue) scope
    {
        this.record.ttl = (this.record.ttl & 0x00FF_FFFF) | (upperByteValue << 24);
    }

    /// EDNS maximum supported version
    /// Currently only 0 is supported.
    public ubyte EDNSVersion () const scope
    {
        return (this.record.ttl >> 16) & 0xFF;
    }

    // Read the 'DO' bit, checking for DNSSEC support
    public bool DNSSEC () const scope
    {
        return !!(this.record.ttl & 0xF0_00);
    }

    // Set the 'DO' bit controlling DNSSEC support
    public void DNSSEC (bool val) scope
    {
        this.record.ttl = (this.record.ttl & 0xF0_00) | (val << 15);
    }
}

/// Thin wrapper around a string, used for domain name serialization
public struct Domain
{
    /// The domain name
    public const(char)[] value = ".";

    /// Creates domain name with always trailing root
    public this (scope inout const(char)[] v) @trusted inout pure nothrow
    {
        if (v.length && v[$-1] == '.')
            this.value = v.idup;
        else
            this.value = cast(string) (v ~ '.');
    }

    size_t toHash () const @safe pure nothrow
    {
        import std.ascii : toLower;
        char[255] buffer;

        foreach (ix, char c; this.value)
            buffer[ix] = toLower(c);

        return buffer.hashOf;
    }

    bool opEquals (in Domain other) const nothrow @safe
    {
        import std.uni : sicmp;
        return (sicmp(other.value, value) == 0);
    }

    /// Returns: A forward range allowing to iterate by label
    /// Iteration is done in reverse order from the string ordering,
    /// meaning for `bosagora.io.`, the initialized state is root (empty string)
    /// followed by `io` then `bosagora`.
    public LabelRange byLabel () const return @safe pure nothrow @nogc
    {
        return LabelRange(this.value, this.value.length, this.value.length);
    }

    /// Manual implementation (instead of splitter + retro) to avoid autodecoding
    /// and things being not `@nogc` / `nothrow`.
    private struct LabelRange
    {
        @safe pure nothrow @nogc:

        /// The value we iterate on
        private const(char)[] value;

        /// The current indexes
        private size_t from;

        /// Ditto
        private size_t to;

        /// Forward range implementation
        public LabelRange save () return { return this; }

        /// Input range implementation
        public const(char)[] front () const return { return this.value[this.from .. this.to]; }

        /// Ditto
        public void popFront ()
        {
            // The range is empty when to == 0, meaning it's an empty slice
            // starting at the beginning.
            // In its initial state, the range is most likely not empty,
            // as `.init` means `value == "."`.
            // However, the initial state is the root label.
            if (this.empty)
                return;

            // Switch to empty state
            if (this.from == 0 || this.value == ".")
            {
                // The special case can only happen with the root domain,
                // as all other values should end with the root domain.
                this.from = this.to = 0;
                return;
            }

            // Otherwise there should be a dot before `from`
            assert(this.from >= 2);
            assert(value[this.from - 1] == '.');

            this.from -= 2;
            this.to = this.from + 1;

            while (this.from > 0)
            {
                if (value[this.from - 1] == '.')
                    break;
                this.from--;
            }
        }

        /// Ditto
        public bool empty () const { return this.to == 0; }
    }

    /***************************************************************************

        Support for network deserialization

        We will receive the domain name encoded. Each label starts with the
        length of the label. Each domain name ends with the empty label.
        Hence, if we were to receive the string `5agora8bosagora2io0`,
        it would decode to `agora.bosagora.io.`. The final dot (root domain)
        is usually omitted, although the struct always keeps it for simplicity.

        Labels cannot be more than 63 characters, and the full domain is limited
        to 255 octets. If a label length has a numeric value > 63, it is a
        pointer to a previously seen domain / label.

        Note:
          This method is not called directly by the deserializer,
          as it needs to support arbitrary pointers into the message

    ***************************************************************************/

    public static T fromBinary (T) (scope ref DNSDeserializerContext ctx) @safe
    {
        // https://datatracker.ietf.org/doc/html/rfc1035#section-3.1
        // Total limit is 255 octets (not chars) and each label is 63 chars or less
        char[255] buffer;
        size_t count;

        // First, save the index we're at, as it could be later used
        const startOffset = ctx.index;

        void appendLabel (in ubyte[] label)
        {
            // Limits as defined in the RFC
            ensure(label.length <= 63,
                "Domain name label should be 64 octets or less, not {}", label.length);
            ensure(count + label.length < 255, // Less than to account for + 1
                "Label of length {} would exceeds total domain name length " ~
                "limit of 255 octets (currently: {} octets)",
                label.length, count);

            // Cast is safe because we validate the whole string at once later
            () @trusted {
                buffer[count .. count + label.length] = cast(const(char[])) label;
            }();
            buffer[count + label.length] = '.';

            // Only [a-z], [A-Z], [0-9], or "-" (dash), or "_" (underscore)
            // "_" is to support service labels
            // https://datatracker.ietf.org/doc/html/rfc1034#section-3.5
            foreach (idx, char c; buffer[count .. count + label.length])
            {
                ensure((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
                    (c >= '0' && c <= '9') || c == '-' || (c == '_' && idx == 0),
                    "Invalid char '{}' in domain name at index {}", c, count + idx);
            }
            count += label.length + 1;
        }

        // Return the final value, and save the start index / slice in the context
        T returnValue (typeof(T.value) value)
        {
            ctx.domains ~= DNSDeserializerContext.DomainRecord(startOffset, value);
            return T(value);
        }

        while (true)
        {
            const len = ctx.read(1)[0];

            // NULL label means we reached the root
            if (len == 0)
                break;

            // Message compression is in effect
            if (len & 0b1100_0000)
            {
                ushort offset = ctx.read(1)[0];
                offset |= (len & 0b0011_1111) << 8;
                const previous = ctx.lookup(offset);
                ensure(count + previous.length < buffer.length,
                        "Using previous label would overflow the 255 characters limit: {} + {}",
                        count, previous.length);
                buffer[count .. count + previous.length] = previous[];
                count += previous.length;
                // If we found a pointer, we have the whole domain
                break;
            }
            else
                appendLabel(ctx.read(len));
        }

        assert(ctx.index >= startOffset);

        // It'd be impractical to send this instead of just 0,
        // but we have to be compliant, so this appends the empty label
        // to the list of previously seen domains
        if (count == 0)
            return returnValue(null);

        static if (is(T : Domain)) // Mutable
            return returnValue(buffer[0 .. count].dup);
        else
            return returnValue(buffer[0 .. count].idup);
    }

    /// Ditto
    public void serialize (scope SerializeDg dg) const @safe
    {
        // If we get '.' there is no way to tell (using splitter)
        // the difference with 'foo..bar', so we just trim the trailing
        // dot and reject any empty label.
        size_t end = this.value.length > 0 ? (this.value.length - 1) : 0;

        this.value[0 .. end].splitter('.').each!(
            (const(char)[] label) {
                assert(label.length <= 64);
                assert(label.length > 0, "Empty label present more than once in domain");

                serializePart!ubyte(label.length % 64, dg);
                dg(label.representation);
            });
        serializePart!ubyte(0, dg);
    }
}

/// Context used while deserializing a DNS message
private struct DNSDeserializerContext
{
    /// Type of delegate used by the parent to lookup a previous name
    public alias DNSPointerLookup = const(ubyte)[] delegate (ubyte) @safe;

    /// Record of previous domains
    public struct DomainRecord
    {
        ///
        public ushort start;

        ///
        public const(char)[] data;
    }

    /// The number of bytes read this far
    private ushort index;

    ///
    private DomainRecord[] domains;

    /// The deserialization delegate
    private DeserializeDg data;

    /// Options for the deserialization
    private const DeserializerOptions options;

    /// Query `data` and updates `index` accordingly
    public const(ubyte)[] read (size_t length) @safe
    {
        this.index += length;
        return this.data(length);
    }

    /// Look a previous label up
    public const(char)[] lookup (ushort index) const @safe
    {
        const(char)[] binarySearch (in DomainRecord[] record)
        {
            auto pivot = record[$/2];
            if (index < pivot.start)
            {
                ensure(record.length > 1, "{} is not a valid index for a previous domain", index);
                return binarySearch(record[0 .. $/2]);
            }
            if (index <= pivot.start + pivot.data.length)
                return pivot.data[index - pivot.start .. $];
            ensure(record.length > 1, "{} is not a valid index for a previous domain", index);
            return binarySearch(record[$/2 .. $]);
        }

        ensure(this.domains.length > 0, "Looking up index {} on empty list of domains", index);
        return binarySearch(this.domains);
    }
}

/*******************************************************************************

    Returns the type of address that is represented in `address`

    When one is presented with a string, e.g. from user input, the correect type
    might need to be guessed. In Agora's case, there are only three kind of
    addresses that may be guessed: domain names (CNAME), IPv4 addresses (A),
    or IPv6 addresses (AAAA).

    This function implements a few heuristics to guess which one it is.
    By default, we consider that an address is a CNAME.

    Params:
      address = The string to guess the type of

    Returns:
      By default, `TYPE.CNAME`, and depending on the format,
       either `TYPE.A` or `TYPE.AAAA`

*******************************************************************************/

public TYPE guessAddressType (in char[] address) @safe pure
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

unittest
{
    import std.algorithm : all;
    import std.array : array;

    auto query = GoogleANYQuery.deserializeFull!Message();

    assert(query.header.ID == 0xa3de);
    assert(!query.header.QR);
    assert(query.header.OPCODE == Header.OpCode.QUERY);
    assert(!query.header.TC);
    assert(query.header.RD);
    assert(!query.header.TC);
    assert(query.header.RD);
    assert(query.header.AD);
    assert(!query.header.CD);

    assert(query.questions.length == 1);
    {
        scope q = &query.questions[0];
        assert(q.qname == Domain("google.com."));
        assert(q.qtype == QTYPE.ALL);
        assert(q.qclass == QCLASS.IN);
    }

    assert(query.answers.length == 0);
    assert(query.authorities.length == 0);

    assert(query.additionals.length == 1);
    {
        scope opt = OPTRR(query.additionals[0]);
        assert(opt.record.name == Domain.init);
        assert(opt.record.type == TYPE.OPT);

        assert(opt.payloadSize() == 4096);
        assert(opt.extendedRCODE() == 0);
        assert(opt.EDNSVersion() == 0);
        assert(!opt.DNSSEC());
    }

    auto answer = GoogleANYAnswer.deserializeFull!Message();
    assert(answer.header.ID == query.header.ID);
    assert(answer.header.QR == !query.header.QR);
    assert(answer.header.RD && answer.header.RA);
    assert(answer.header.RCODE == Header.RCode.NoError);

    assert(answer.questions == query.questions);

    assert(answer.answers.length == 22);
    {
        assert(answer.answers.all!(rr => rr.class_ == CLASS.IN));
        assert(answer.answers.all!((rr) { return rr.name == Domain("google.com."); }));
        // Using `.array` for better error messages
        assert(answer.answers.map!(rr => rr.type).array == [
            TYPE.A, TYPE.AAAA, TYPE.NS, TYPE.MX,
            TYPE.TXT, TYPE.TXT, TYPE.TXT, TYPE.TXT, TYPE.CAA,
            TYPE.TXT, TYPE.TXT, TYPE.TXT, TYPE.TXT, TYPE.SOA,
            TYPE.MX, TYPE.MX, TYPE.TXT, TYPE.MX, TYPE.MX,
            TYPE.NS,TYPE.NS,TYPE.NS,
        ]);
    }

    assert(answer.authorities.length == 0);
    assert(answer.additionals.length == 1);
    {
        scope opt = OPTRR(answer.additionals[0]);
        assert(opt.record.name == Domain.init);
        assert(opt.record.type == TYPE.OPT);

        assert(opt.payloadSize() == 512);
        assert(opt.extendedRCODE() == 0);
        assert(opt.EDNSVersion() == 0);
        assert(!opt.DNSSEC());
    }
}

version (unittest):
/// Generated via `dig ANY @8.8.8.8 google.com.`
/// Wireshark, select DNS, right click, "Show packet bytes", "Show as C Array"
private immutable ubyte[] GoogleANYQuery = [
    0xa3, 0xde, 0x01, 0x20, 0x00, 0x01, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x01, 0x06, 0x67, 0x6f, 0x6f,
    0x67, 0x6c, 0x65, 0x03, 0x63, 0x6f, 0x6d, 0x00,
    0x00, 0xff, 0x00, 0x01, 0x00, 0x00, 0x29, 0x10,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
];

/// A response to the above query (922 bytes)
private immutable ubyte[] GoogleANYAnswer = [
    0xa3, 0xde, 0x81, 0x80, 0x00, 0x01, 0x00, 0x16,
    0x00, 0x00, 0x00, 0x01, 0x06, 0x67, 0x6f, 0x6f,
    0x67, 0x6c, 0x65, 0x03, 0x63, 0x6f, 0x6d, 0x00,
    0x00, 0xff, 0x00, 0x01, 0xc0, 0x0c, 0x00, 0x01,
    0x00, 0x01, 0x00, 0x00, 0x01, 0x19, 0x00, 0x04,
    0x8e, 0xfb, 0x2a, 0x8e, 0xc0, 0x0c, 0x00, 0x1c,
    0x00, 0x01, 0x00, 0x00, 0x01, 0x19, 0x00, 0x10,
    0x24, 0x04, 0x68, 0x00, 0x40, 0x04, 0x08, 0x25,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x0e,
    0xc0, 0x0c, 0x00, 0x02, 0x00, 0x01, 0x00, 0x00,
    0x54, 0x4d, 0x00, 0x06, 0x03, 0x6e, 0x73, 0x33,
    0xc0, 0x0c, 0xc0, 0x0c, 0x00, 0x0f, 0x00, 0x01,
    0x00, 0x00, 0x02, 0x45, 0x00, 0x11, 0x00, 0x1e,
    0x04, 0x61, 0x6c, 0x74, 0x32, 0x05, 0x61, 0x73,
    0x70, 0x6d, 0x78, 0x01, 0x6c, 0xc0, 0x0c, 0xc0,
    0x0c, 0x00, 0x10, 0x00, 0x01, 0x00, 0x00, 0x0d,
    0xfd, 0x00, 0x45, 0x44, 0x67, 0x6f, 0x6f, 0x67,
    0x6c, 0x65, 0x2d, 0x73, 0x69, 0x74, 0x65, 0x2d,
    0x76, 0x65, 0x72, 0x69, 0x66, 0x69, 0x63, 0x61,
    0x74, 0x69, 0x6f, 0x6e, 0x3d, 0x54, 0x56, 0x39,
    0x2d, 0x44, 0x42, 0x65, 0x34, 0x52, 0x38, 0x30,
    0x58, 0x34, 0x76, 0x30, 0x4d, 0x34, 0x55, 0x5f,
    0x62, 0x64, 0x5f, 0x4a, 0x39, 0x63, 0x70, 0x4f,
    0x4a, 0x4d, 0x30, 0x6e, 0x69, 0x6b, 0x66, 0x74,
    0x30, 0x6a, 0x41, 0x67, 0x6a, 0x6d, 0x73, 0x51,
    0xc0, 0x0c, 0x00, 0x10, 0x00, 0x01, 0x00, 0x00,
    0x0d, 0xfd, 0x00, 0x2e, 0x2d, 0x64, 0x6f, 0x63,
    0x75, 0x73, 0x69, 0x67, 0x6e, 0x3d, 0x30, 0x35,
    0x39, 0x35, 0x38, 0x34, 0x38, 0x38, 0x2d, 0x34,
    0x37, 0x35, 0x32, 0x2d, 0x34, 0x65, 0x66, 0x32,
    0x2d, 0x39, 0x35, 0x65, 0x62, 0x2d, 0x61, 0x61,
    0x37, 0x62, 0x61, 0x38, 0x61, 0x33, 0x62, 0x64,
    0x30, 0x65, 0xc0, 0x0c, 0x00, 0x10, 0x00, 0x01,
    0x00, 0x00, 0x0d, 0xfd, 0x00, 0x3c, 0x3b, 0x66,
    0x61, 0x63, 0x65, 0x62, 0x6f, 0x6f, 0x6b, 0x2d,
    0x64, 0x6f, 0x6d, 0x61, 0x69, 0x6e, 0x2d, 0x76,
    0x65, 0x72, 0x69, 0x66, 0x69, 0x63, 0x61, 0x74,
    0x69, 0x6f, 0x6e, 0x3d, 0x32, 0x32, 0x72, 0x6d,
    0x35, 0x35, 0x31, 0x63, 0x75, 0x34, 0x6b, 0x30,
    0x61, 0x62, 0x30, 0x62, 0x78, 0x73, 0x77, 0x35,
    0x33, 0x36, 0x74, 0x6c, 0x64, 0x73, 0x34, 0x68,
    0x39, 0x35, 0xc0, 0x0c, 0x00, 0x10, 0x00, 0x01,
    0x00, 0x00, 0x0d, 0xfd, 0x00, 0x41, 0x40, 0x67,
    0x6c, 0x6f, 0x62, 0x61, 0x6c, 0x73, 0x69, 0x67,
    0x6e, 0x2d, 0x73, 0x6d, 0x69, 0x6d, 0x65, 0x2d,
    0x64, 0x76, 0x3d, 0x43, 0x44, 0x59, 0x58, 0x2b,
    0x58, 0x46, 0x48, 0x55, 0x77, 0x32, 0x77, 0x6d,
    0x6c, 0x36, 0x2f, 0x47, 0x62, 0x38, 0x2b, 0x35,
    0x39, 0x42, 0x73, 0x48, 0x33, 0x31, 0x4b, 0x7a,
    0x55, 0x72, 0x36, 0x63, 0x31, 0x6c, 0x32, 0x42,
    0x50, 0x76, 0x71, 0x4b, 0x58, 0x38, 0x3d, 0xc0,
    0x0c, 0x01, 0x01, 0x00, 0x01, 0x00, 0x00, 0x54,
    0x4d, 0x00, 0x0f, 0x00, 0x05, 0x69, 0x73, 0x73,
    0x75, 0x65, 0x70, 0x6b, 0x69, 0x2e, 0x67, 0x6f,
    0x6f, 0x67, 0xc0, 0x0c, 0x00, 0x10, 0x00, 0x01,
    0x00, 0x00, 0x0d, 0xfd, 0x00, 0x24, 0x23, 0x76,
    0x3d, 0x73, 0x70, 0x66, 0x31, 0x20, 0x69, 0x6e,
    0x63, 0x6c, 0x75, 0x64, 0x65, 0x3a, 0x5f, 0x73,
    0x70, 0x66, 0x2e, 0x67, 0x6f, 0x6f, 0x67, 0x6c,
    0x65, 0x2e, 0x63, 0x6f, 0x6d, 0x20, 0x7e, 0x61,
    0x6c, 0x6c, 0xc0, 0x0c, 0x00, 0x10, 0x00, 0x01,
    0x00, 0x00, 0x0d, 0xfd, 0x00, 0x2c, 0x2b, 0x4d,
    0x53, 0x3d, 0x45, 0x34, 0x41, 0x36, 0x38, 0x42,
    0x39, 0x41, 0x42, 0x32, 0x42, 0x42, 0x39, 0x36,
    0x37, 0x30, 0x42, 0x43, 0x45, 0x31, 0x35, 0x34,
    0x31, 0x32, 0x46, 0x36, 0x32, 0x39, 0x31, 0x36,
    0x31, 0x36, 0x34, 0x43, 0x30, 0x42, 0x32, 0x30,
    0x42, 0x42, 0xc0, 0x0c, 0x00, 0x10, 0x00, 0x01,
    0x00, 0x00, 0x0d, 0xfd, 0x00, 0x2b, 0x2a, 0x61,
    0x70, 0x70, 0x6c, 0x65, 0x2d, 0x64, 0x6f, 0x6d,
    0x61, 0x69, 0x6e, 0x2d, 0x76, 0x65, 0x72, 0x69,
    0x66, 0x69, 0x63, 0x61, 0x74, 0x69, 0x6f, 0x6e,
    0x3d, 0x33, 0x30, 0x61, 0x66, 0x49, 0x42, 0x63,
    0x76, 0x53, 0x75, 0x44, 0x56, 0x32, 0x50, 0x4c,
    0x58, 0xc0, 0x0c, 0x00, 0x10, 0x00, 0x01, 0x00,
    0x00, 0x0d, 0xfd, 0x00, 0x45, 0x44, 0x67, 0x6f,
    0x6f, 0x67, 0x6c, 0x65, 0x2d, 0x73, 0x69, 0x74,
    0x65, 0x2d, 0x76, 0x65, 0x72, 0x69, 0x66, 0x69,
    0x63, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x3d, 0x77,
    0x44, 0x38, 0x4e, 0x37, 0x69, 0x31, 0x4a, 0x54,
    0x4e, 0x54, 0x6b, 0x65, 0x7a, 0x4a, 0x34, 0x39,
    0x73, 0x77, 0x76, 0x57, 0x57, 0x34, 0x38, 0x66,
    0x38, 0x5f, 0x39, 0x78, 0x76, 0x65, 0x52, 0x45,
    0x56, 0x34, 0x6f, 0x42, 0x2d, 0x30, 0x48, 0x66,
    0x35, 0x6f, 0xc0, 0x0c, 0x00, 0x06, 0x00, 0x01,
    0x00, 0x00, 0x00, 0x29, 0x00, 0x26, 0x03, 0x6e,
    0x73, 0x31, 0xc0, 0x0c, 0x09, 0x64, 0x6e, 0x73,
    0x2d, 0x61, 0x64, 0x6d, 0x69, 0x6e, 0xc0, 0x0c,
    0x18, 0x42, 0xde, 0xc7, 0x00, 0x00, 0x03, 0x84,
    0x00, 0x00, 0x03, 0x84, 0x00, 0x00, 0x07, 0x08,
    0x00, 0x00, 0x00, 0x3c, 0xc0, 0x0c, 0x00, 0x0f,
    0x00, 0x01, 0x00, 0x00, 0x02, 0x45, 0x00, 0x09,
    0x00, 0x28, 0x04, 0x61, 0x6c, 0x74, 0x33, 0xc0,
    0x6d, 0xc0, 0x0c, 0x00, 0x0f, 0x00, 0x01, 0x00,
    0x00, 0x02, 0x45, 0x00, 0x09, 0x00, 0x14, 0x04,
    0x61, 0x6c, 0x74, 0x31, 0xc0, 0x6d, 0xc0, 0x0c,
    0x00, 0x10, 0x00, 0x01, 0x00, 0x00, 0x0d, 0xfd,
    0x00, 0x2e, 0x2d, 0x64, 0x6f, 0x63, 0x75, 0x73,
    0x69, 0x67, 0x6e, 0x3d, 0x31, 0x62, 0x30, 0x61,
    0x36, 0x37, 0x35, 0x34, 0x2d, 0x34, 0x39, 0x62,
    0x31, 0x2d, 0x34, 0x64, 0x62, 0x35, 0x2d, 0x38,
    0x35, 0x34, 0x30, 0x2d, 0x64, 0x32, 0x63, 0x31,
    0x32, 0x36, 0x36, 0x34, 0x62, 0x32, 0x38, 0x39,
    0xc0, 0x0c, 0x00, 0x0f, 0x00, 0x01, 0x00, 0x00,
    0x02, 0x45, 0x00, 0x09, 0x00, 0x32, 0x04, 0x61,
    0x6c, 0x74, 0x34, 0xc0, 0x6d, 0xc0, 0x0c, 0x00,
    0x0f, 0x00, 0x01, 0x00, 0x00, 0x02, 0x45, 0x00,
    0x04, 0x00, 0x0a, 0xc0, 0x6d, 0xc0, 0x0c, 0x00,
    0x02, 0x00, 0x01, 0x00, 0x00, 0x54, 0x4d, 0x00,
    0x02, 0xc2, 0xae, 0xc0, 0x0c, 0x00, 0x02, 0x00,
    0x01, 0x00, 0x00, 0x54, 0x4d, 0x00, 0x06, 0x03,
    0x6e, 0x73, 0x32, 0xc0, 0x0c, 0xc0, 0x0c, 0x00,
    0x02, 0x00, 0x01, 0x00, 0x00, 0x54, 0x4d, 0x00,
    0x06, 0x03, 0x6e, 0x73, 0x34, 0xc0, 0x0c, 0x00,
    0x00, 0x29, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00,
];
