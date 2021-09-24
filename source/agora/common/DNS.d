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
import agora.serialization.Serializer;

import std.algorithm.iteration;
import std.bitmanip;
import std.format;
import std.string;
static import std.utf;

/// https://datatracker.ietf.org/doc/html/rfc1035#section-3.2.2
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
    HINFO = 13, /// host information
    MINFO = 14, /// mailbox or mail list information
    MX    = 15, /// mail exchange
    TXT   = 16, /// text strings
}

/// https://datatracker.ietf.org/doc/html/rfc1035#section-3.2.3
enum QTYPE : ushort
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
    HINFO = 13, /// host information
    MINFO = 14, /// mailbox or mail list information
    MX    = 15, /// mail exchange
    TXT   = 16, /// text strings

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
}

/// https://datatracker.ietf.org/doc/html/rfc1035#section-3.3.14
public struct RDATA
{
    /// A 32 bit Internet address.
    public uint address;
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
        scope DeserializeDg data, in DeserializerOptions oopts) @safe
    {
        import std.array : array;
        import std.range : iota;

        DeserializerOptions opts = { maxLength: oopts.maxLength, compact: CompactMode.No };
        auto hdr = deserializeFull!(typeof(T.header))(data, opts);
        auto f1 = iota(hdr.QDCOUNT)
            .map!(_ => deserializeFull!(typeof(T.questions[0]))(data, opts)).array();
        auto f2 = iota(hdr.ANCOUNT)
            .map!(_ => deserializeFull!(typeof(T.answers[0]))(data, opts)).array();
        auto f3 = iota(hdr.NSCOUNT)
            .map!(_ => deserializeFull!(typeof(T.authorities[0]))(data, opts)).array();
        auto f4 = iota(hdr.ARCOUNT)
            .map!(_ => deserializeFull!(typeof(T.additionals[0]))(data, opts)).array();
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
}

/// https://datatracker.ietf.org/doc/html/rfc1035#section-4.1.1
public struct Header
{
    /// Humean readable representation loosely inspired from `dig`
    public void toString (scope void delegate(scope const(char)[]) @safe sink)
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
    public short ID;

    /// A one bit field that specifies whether this message is a
    /// query (0), or a response (1).
    public bool QR () const scope { return !!(this.field2 & 0b1_0000_0_0_0_0_000_0000); }
    /// Ditto
    public void QR (bool val) scope { this.field2 |= 1 << (ushort.sizeof * 8 - 1); }

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
    public OpCode OPCODE () const scope
    {
        //
        ubyte val = (this.field2 & 0b0_1111_0_0_0_0_000_0000) >> 11;
        assert(val <= OpCode.max);
        return cast(OpCode) val;
    }
    /// Ditto
    public void OPCODE (OpCode val) scope { this.field2 |= val << (ushort.sizeof * 8 - 5); }

    /***************************************************************************

        Authoritative Answer

        This bit is valid in responses, and specifies that the responding
        name server is an authority for the domain name in question section.

        Note that the contents of the answer section may have
        multiple owner names because of aliases.
        The AA bit corresponds to the name which matches the query name, or
        the first owner name in the answer section.

    ***************************************************************************/

    public bool AA () const scope { return !!(this.field2 & 0b0_0000_1_0_0_0_000_0000); }
    /// Ditto
    public void AA (bool val) scope { this.field2 |= 1 << (ushort.sizeof * 8 - 6); }

    /// TrunCation - specifies that this message was truncated
    /// due to length greater than that permitted on the transmission channel.
    public bool TC () const scope { return !!(this.field2 & 0b0_0000_0_1_0_0_000_0000); }
    /// Ditto
    public void TC (bool val) scope { this.field2 |= 1 << (ushort.sizeof * 8 - 7); }

    /// Recursion Desired
    /// This bit may be set in a query and is copied into the response.
    /// If RD is set, it directs the name server to pursue the query recursively.
    /// Recursive query support is optional.
    public bool RD () const scope { return !!(this.field2 & 0b0_0000_0_0_1_0_000_0000); }
    /// Ditto
    public void RD (bool val) scope { this.field2 |= 1 << (ushort.sizeof * 8 - 8); }

    /// Recursion Available
    /// This bit is set or cleared in a response, and denotes whether recursive
    /// query support is available in the name server.
    public bool RA () const scope { return !!(this.field2 & 0b0_0000_0_0_0_1_000_0000); }
    /// Ditto
    public void RA (bool val) scope { this.field2 |= 1 << (ushort.sizeof * 8 - 9); }

    /// Reserved for future use. Must be zero in all queries and responses.
    public ubyte Z () const scope { return (this.field2 & 0b0_0000_0_0_0_0_111_0000) >> 4; }

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
    public RCode RCODE () const scope
    {
        //
        ubyte val = (this.field2 & 0b0_0000_0_0_0_0_000_1111);
        assert(val <= RCode.max);
        return cast(RCode) val;
    }
    /// Ditto
    public void RCODE (RCode val) scope { this.field2 |= val; }

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

    assert(hdr.OPCODE == Header.OpCode.QUERY);
    hdr.OPCODE = Header.OpCode.STATUS;
    assert(hdr.OPCODE == Header.OpCode.STATUS);

    assert(!hdr.AA);
    hdr.AA = true;
    assert(hdr.AA);

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
}

/// https://datatracker.ietf.org/doc/html/rfc1035#section-4.1.3
public struct ResourceRecord
{
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
    public ubyte[] rdata;

    /// Support for network serialization
    public static T fromBinary (T) (
        scope DeserializeDg data, in DeserializerOptions oopts) @safe
    {
        DeserializerOptions opts = { maxLength: oopts.maxLength, compact: CompactMode.No };
        auto tmp = T(
            deserializeFull!(typeof(T.name))(data, opts),
            deserializeFull!(TYPE)(data, opts),
            deserializeFull!(CLASS)(data, opts),
            deserializeFull!(uint)(data, opts),
        );
        auto rdlength = deserializeFull!(ushort)(data, opts);
        return T(
            tmp.name, tmp.type, tmp.class_, tmp.ttl,
            () @trusted { return cast(typeof(T.rdata)) data(rdlength); }(),
        );
    }

    /// Ditto
    public void serialize (scope SerializeDg dg) const @safe
    {
        serializePart(this.name, dg, CompactMode.No);
        serializePart(this.type, dg, CompactMode.No);
        serializePart(this.class_, dg, CompactMode.No);
        serializePart(this.ttl, dg, CompactMode.No);
        ensure(this.rdata.length < ushort.max,
               "Field `DNS.ResourceRecord.rdata` should exceed data limit: {}",
               this.rdata.length);
        serializePart!ushort(this.rdata.length % ushort.max, dg, CompactMode.No);
        dg(this.rdata);
    }
}

/// Thin wrapper around a string, used for domain name serialization
public struct Domain
{
    /// The domain name
    public const(char)[] value;

    ///
    alias value this;

    /// Support for network serialization
    public static T fromBinary (T) (
        scope DeserializeDg data, in DeserializerOptions opts) @safe
    {
        // https://datatracker.ietf.org/doc/html/rfc1035#section-3.1
        // Total limit is 255 octets (not chars) and each label is 63 chars or less
        char[255] buffer;
        size_t count;
        while (true)
        {
            const len = data(1)[0];

            // NULL label means we reached the root
            if (len == 0)
                break;

            // By the RFC
            ensure(len <= 63,
                   "Domain name label should be 64 octets or less, not {}",
                   len);
            // Cast is safe because we validate the whole string at once later
            () @trusted {
                buffer[count .. count + len] = cast(const(char[])) data(len);
            }();
            buffer[count + len] = '.';
            count += len + 1;

            // By the RFC
            ensure(count <= 255,
                   "Total domain name length should be 255 octets or less, not {}",
                   count);
        }

        if (count == 0)
            return T();

        // Let's say we got `5agora8bosagora2io0`, for domain `agora.bosagora.io`
        // Our string will be `agora.bosagora.io.`, so just drop the last char
        std.utf.validate(buffer[0 .. count]);
        static if (is(T : Domain)) // Mutable
            return T(buffer[0 .. count - 1].dup);
        else
            return T(buffer[0 .. count - 1].idup);
    }

    /// Ditto
    public void serialize (scope SerializeDg dg) const @safe
    {
        bool finalLabel = false;
        this.value.splitter('.').each!(
            (const(char)[] label) {
                assert(label.length <= 64);
                serializePart!ubyte(label.length % 64, dg);
                dg(label.representation);

                if (!label.length)
                {
                    assert(!finalLabel, "Empty label present more than once in domain");
                    finalLabel = true;
                }
            });
        if (!finalLabel)
            serializePart!ubyte(0, dg);
    }
}

unittest
{
    checkFromBinary!Domain();
    checkFromBinary!Message();
    checkFromBinary!ResourceRecord();
}

unittest
{
    Domain d1 = Domain("hello.world");
    assert(d1.serializeFull() ==
           [0x05, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x05, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x00 ]);
    testSymmetry(d1);
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
