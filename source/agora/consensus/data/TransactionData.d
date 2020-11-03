/*******************************************************************************

    Contains a type for storing data in a transaction

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.TransactionData;

import agora.common.Hash;
import agora.common.Serializer;

import std.algorithm.comparison;
import std.algorithm.iteration;
import std.range;
import std.utf;

/// The structure of for storing data in a transaction
public struct TransactionData
{
    /// The byte array of transaction data
    public ubyte[] data;

    /// The error for fromString(),
    /// This will be checked in the validation of the transaction.
    public string error;

    /***************************************************************************

        Create a TransactionData from binary data

        Params:
            bin  = Binary data to store in this `TransactionData`
            message = Error message when deserializing data,
                if this value is null, then it is normal data.

    ***************************************************************************/

    public this (scope const ubyte[] bin, scope const(char)[] message = null) pure nothrow @safe
    {
        this.data.length = bin.length;
        this.data[] = bin[];
        if (message !is null)
            this.error = message.idup;
    }

    /// Print `TransactionData`
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
    public static TransactionData fromString (scope const(char)[] str) @safe
    {
        if (str.length % 2)
            return TransactionData([], "The length of the hexadecimal string is not even");

        if (str.length >= 2 && str[0] == '0' && (str[1] == 'x' || str[1] == 'X'))
            str = str[2 .. $];

        auto hexDecoder = (char c) @safe nothrow @nogc
        {
            switch (c) {
                case '0': .. case '9':
                    return cast(ubyte)(c - '0');
                case 'a': .. case 'f':
                    return cast(ubyte)(10 + c - 'a');
                case 'A': .. case 'F':
                    return cast(ubyte)(10 + c - 'A');
                default:
                    return 0xff;    //  mark error
            }
        };

        ubyte [] data;
        data.length = str.length / 2;

        size_t idx;
        foreach (chunk; str.byChar.map!(c => hexDecoder(c)).chunks(2))
        {
            if (chunk[0] == 0xff || chunk[1] == 0xff)
                return TransactionData([], "The hexadecimal string contains an abnormal character");

            data[idx++] = cast(ubyte)((chunk[0] << 4) + chunk[1]);
        }

        return TransactionData(data);
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

        TransactionData Serialization

        Params:
            dg = serialize function accumulator

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) const @safe
    {
        serializePart(this.data, dg);
    }

    /***************************************************************************

        Returns a new instance of type `TransactionData`

        Params:
            TransactionDataT = Qualified type of TransactionData to return
            dg   = Delegate to read binary data
            opts = Deserialization options (should be forwarded)

        Returns:
            A new instance of type `TransactionData`

    ***************************************************************************/

    public static TransactionDataT fromBinary (TransactionDataT = TransactionData) (
        scope DeserializeDg dg, const ref DeserializerOptions opts) @safe
    {
        return TransactionData(deserializeFull!(ubyte[])(dg, opts));
    }

    /// Support for comparison
    public int opCmp (ref const typeof(this) s) const nothrow @safe @nogc
    {
        size_t len = min(this.length, s.length);
        foreach (idx; 0 .. len)
            if (this.data[idx] != s.data[idx])
                return this.data[idx] - s.data[idx];

        return (this.length == s.length) ? 0
                                         : ((this.length > s.length) ? 1 : -1);
    }

    /// Support for comparison (rvalue overload)
    public int opCmp (const typeof(this) s) const nothrow @safe @nogc
    {
        return this.opCmp(s);
    }

    /// Returns the number of elements in the data
    @property size_t length() const pure nothrow @safe @nogc
    {
        return this.data.length;
    }

    /// Returns the length of this data.
    alias opDollar = length;
}

// Creation test - from hex string
unittest
{
    TransactionData tx_data1 = TransactionData.fromString("0xnonhex");
    assert(tx_data1.error == "The hexadecimal string contains an abnormal character");
    assert(tx_data1.length == 0);

    TransactionData tx_data2 = TransactionData.fromString("0xNONHEX");
    assert(tx_data2.error == "The hexadecimal string contains an abnormal character");
    assert(tx_data2.length == 0);

    TransactionData tx_data3 = TransactionData.fromString("abcde");
    assert(tx_data3.error == "The length of the hexadecimal string is not even");
    assert(tx_data3.length == 0);

    TransactionData tx_data4 = TransactionData.fromString("abcdef");
    assert(tx_data4.error == null);
    assert(tx_data4.toString() == "0xabcdef");
    assert(tx_data4.length == 3);

    TransactionData tx_data5 = TransactionData.fromString("0xABcdef");
    assert(tx_data5.error == null);
    assert(tx_data5.toString() == "0xabcdef");
    assert(tx_data5.length == 3);
}

// Creation test - from ubyte array
unittest
{
    TransactionData tx_data = TransactionData(cast(ubyte[])[1, 2, 3, 4]);
    assert(tx_data.toString() == "0x01020304");
    assert(tx_data.length == 4);
}

// JSON serialization test
unittest
{
    import vibe.data.json;

    TransactionData tx_data1 = deserializeJson!TransactionData("\"0xabcdefgh\"");
    assert(tx_data1.error == "The hexadecimal string contains an abnormal character");
    assert(tx_data1.length == 0);

    TransactionData tx_data2 = deserializeJson!TransactionData("\"0xabcde\"");
    assert(tx_data2.error == "The length of the hexadecimal string is not even");
    assert(tx_data2.length == 0);

    TransactionData old_data = TransactionData.fromString("0x01020304");
    auto json_str = old_data.serializeToJsonString();
    assert(json_str == "\"0x01020304\"");

    TransactionData new_data = deserializeJson!TransactionData(json_str);
    assert(new_data == old_data);
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

    TransactionData tx_data = TransactionData(cast(ubyte[])"abc");
    assert(hashFull(tx_data) == abc_exp);
}

// serialization test
unittest
{
    TransactionData old_data = TransactionData(cast(ubyte[])[0, 1, 2]);
    auto bytes = old_data.serializeFull();
    assert(bytes == [3, 0, 1, 2]);
    auto new_data = deserializeFull!(TransactionData)(bytes);

    assert(new_data == old_data);
}

unittest
{
    TransactionData tx_data = TransactionData(cast(ubyte[])[0, 1, 2]);
    testSymmetry(tx_data);
}
