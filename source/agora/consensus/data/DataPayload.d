/*******************************************************************************

    Contains a type for storing data in a transaction

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.DataPayload;

import agora.common.Serializer;
import agora.crypto.Hash;

import std.algorithm.iteration;
import std.conv: parse;
import std.range;

/// The structure of for storing data in a transaction
public struct DataPayload
{
    /// The byte array of transaction data
    public const(ubyte)[] data;

    /***************************************************************************

        Create a DataPayload from binary data

        Params:
            bin  = Binary data to store in this `DataPayload`

    ***************************************************************************/

    public this (inout(ubyte)[] bin) inout pure nothrow @safe
    {
        this.data = bin;
    }

    /// Print `DataPayload`
    public void toString (scope void delegate(const(char)[]) @safe sink) const @safe
    {
        if (this.data.length == 0)
            return;

        auto toHexDigit = (ubyte value) @safe nothrow @nogc
        {
            return cast(char)(value + ((value < 10) ? 0x30 : 0x57));
        };

        sink("0x");
        char[2] hex;
        this.data.each!(
            (num)
            {
                hex[0] = toHexDigit(num >> 4);
                hex[1] = toHexDigit(num & 0xF);
                sink(hex);
            }
        );
    }

    /// Support for Vibe.d serialization
    public string toString () const @safe
    {
        if (this.data.length == 0)
            return "";

        size_t idx;
        char[] buffer;
        buffer.length = this.data.length * 2 + 2;
        scope sink = (const(char)[] v) {
            buffer[idx .. idx + v.length] = v;
            idx += v.length;
        };
        this.toString(sink);
        return buffer.idup;
    }

    /// Support for Vibe.d deserialization
    public static DataPayload fromString (scope const(char)[] str) @safe
    {
        if (str.length >= 2 && str[0] == '0' && (str[1] == 'x' || str[1] == 'X'))
            str = str[2 .. $];

        ubyte [] data = str.idup.chunks(2).map!(twoDigits => twoDigits.parse!ubyte(16)).array();
        return DataPayload(data);
    }

    /***************************************************************************

        Implements hashing support

        Params:
            dg = Hashing function accumulator

    ***************************************************************************/

    public void computeHash (scope HashDg dg) const nothrow @nogc @safe
    {
        hashPart(this.data, dg);
    }

    /***************************************************************************

        DataPayload Serialization

        Params:
            dg = serialize function accumulator

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) const @safe
    {
        serializePart(this.data, dg);
    }

    /***************************************************************************

        Returns a new instance of type `DataPayload`

        Params:
            DataPayloadT = Qualified type of DataPayload to return
            dg   = Delegate to read binary data
            opts = Deserialization options (should be forwarded)

        Returns:
            A new instance of type `DataPayload`

    ***************************************************************************/

    public static DataPayloadT fromBinary (DataPayloadT = DataPayload) (
        scope DeserializeDg dg, in DeserializerOptions opts) @safe
    {
        return DataPayload(deserializeFull!(ubyte[])(dg, opts));
    }
}

// Creation test - from hex string
unittest
{
    DataPayload data_payload1 = DataPayload.fromString("");
    assert(data_payload1.toString() == "");
    assert(data_payload1.data.length == 0);

    DataPayload data_payload2 = DataPayload.fromString("abcdef");
    assert(data_payload2.toString() == "0xabcdef");
    assert(data_payload2.data.length == 3);

    DataPayload data_payload3 = DataPayload.fromString("0xABCDEF");
    assert(data_payload3.toString() == "0xabcdef");
    assert(data_payload3.data.length == 3);
}

// Creation test - from ubyte array
unittest
{
    DataPayload data_payload = DataPayload(cast(ubyte[])[1, 2, 3, 4]);
    assert(data_payload.toString() == "0x01020304");
    assert(data_payload.data.length == 4);
}

// JSON serialization test
unittest
{
    import vibe.data.json;

    DataPayload old_data = DataPayload.fromString("0x1234567890ABCDEF");
    auto json_str = old_data.serializeToJsonString();
    assert(json_str == "\"0x1234567890abcdef\"");

    DataPayload new_data = deserializeJson!DataPayload(json_str);
    assert(new_data.data == old_data.data);
}

// HashFull test
unittest
{
    // https://tools.ietf.org/html/rfc7693#appendix-A
    static immutable ubyte[] hdata = [
        0xBA, 0x80, 0xA5, 0x3F, 0x98, 0x1C, 0x4D, 0x0D, 0x6A, 0x27, 0x97, 0xB6,
        0x9F, 0x12, 0xF6, 0xE9,
        0x4C, 0x21, 0x2F, 0x14, 0x68, 0x5A, 0xC4, 0xB7, 0x4B, 0x12, 0xBB, 0x6F,
        0xDB, 0xFF, 0xA2, 0xD1,
        0x7D, 0x87, 0xC5, 0x39, 0x2A, 0xAB, 0x79, 0x2D, 0xC2, 0x52, 0xD5, 0xDE,
        0x45, 0x33, 0xCC, 0x95,
        0x18, 0xD3, 0x8A, 0xA8, 0xDB, 0xF1, 0x92, 0x5A, 0xB9, 0x23, 0x86, 0xED,
        0xD4, 0x00, 0x99, 0x23
    ];
    const abc_exp = Hash(hdata);

    DataPayload data_payload = DataPayload(cast(ubyte[])"abc");
    assert(hashFull(data_payload) == abc_exp);
}

// serialization test
unittest
{
    DataPayload old_data = DataPayload(cast(ubyte[])[0, 1, 2]);
    auto bytes = old_data.serializeFull();
    assert(bytes == [3, 0, 1, 2]);
    auto new_data = deserializeFull!(DataPayload)(bytes);

    assert(new_data.data == old_data.data);
}

unittest
{
    DataPayload data_payload = DataPayload(cast(ubyte[])[0, 1, 2]);
    testSymmetry(data_payload);
}
