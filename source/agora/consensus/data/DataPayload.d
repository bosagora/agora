/*******************************************************************************

    Contains a type for storing data in a transaction

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.DataPayload;

import agora.serialization.Serializer;
import agora.crypto.Hash;

import std.algorithm.iteration;
import std.conv: parse;
import std.range;

/// The structure of for storing data in a transaction
public struct DataPayload
{
    /// The byte array of transaction data
    public const(ubyte)[] bytes;

    /// The size of the data DataPayload object
    public ulong sizeInBytes () const nothrow pure @safe @nogc
    {
        return this.bytes.length * this.bytes[0].sizeof;
    }
    /***************************************************************************

        Create a DataPayload from binary data

        Params:
            bin  = Binary data to store in this `DataPayload`

    ***************************************************************************/

    public this (inout(ubyte)[] bin) inout pure nothrow @safe
    {
        this.bytes = bin;
    }

    /***************************************************************************

        Implements hashing support

        Params:
            dg = Hashing function accumulator

    ***************************************************************************/

    public void computeHash (scope HashDg dg) const nothrow @nogc @safe
    {
        hashPart(this.bytes, dg);
    }

    /***************************************************************************

        DataPayload Serialization

        Params:
            dg = serialize function accumulator

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) const @safe
    {
        serializePart(this.bytes, dg);
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

// serialization test
unittest
{
    DataPayload old_data = DataPayload(cast(ubyte[])[0, 1, 2]);
    auto bytes = old_data.serializeFull();
    assert(bytes == [3, 0, 1, 2]);
    auto new_data = deserializeFull!(DataPayload)(bytes);

    assert(new_data.bytes == old_data.bytes);
}

unittest
{
    DataPayload data_payload = DataPayload(cast(ubyte[])[0, 1, 2]);
    testSymmetry(data_payload);
}
