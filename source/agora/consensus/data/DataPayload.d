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
