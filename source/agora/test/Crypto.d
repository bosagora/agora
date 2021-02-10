/*******************************************************************************

    Contains extra tests for the `crypto` library

    Those tests do not belong to the crypto library, but ensures that it
    integrates correctly with utilities we use.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Crypto;

import agora.crypto.Types;
import agora.crypto.ECC;
import agora.crypto.Schnorr;
import agora.crypto.Serializer;

unittest
{
    auto s = Scalar("0x0e00a8df701806cb4deac9bb09cc85b097ee713e055b9d2bf1daf668b3f63778");

    // Test default formatting behavior with Ocean's sformat/log
    // The library test integration with Phobos
    import ocean.text.convert.Formatter : format;
    assert(format("{}", s) == "**SCALAR**");

    import vibe.data.json;
    assert(s.serializeToJsonString() == "\"**SCALAR**\"",
           s.serializeToJsonString());
}

///
unittest
{
    testSymmetry!Scalar();
    testSymmetry(Scalar.random());
    testSymmetry!Point();
    testSymmetry(Scalar.random().toPoint());
    // Make sure it's serialized as a value type (without length)
    assert(Scalar.random().toPoint().serializeFull().length == Point.sizeof);
    static struct Bar
    {
        string val;
        int other;
        uint us;
    }

    Bar[3] arr = [
        Bar("Hello", 42, 82),
        Bar("Cruel", 420, 840),
        Bar("World", 2424, 100_000),
    ];

    ubyte[] buffer = new ubyte[512];
    import ocean.core.Test: testNoAlloc;

    testNoAlloc({
            auto ret1 = serializeToBuffer(arr, buffer);
            assert(ret1.length ==
                   1 /* Top level array length */ +
                   "HelloCruelWorld".length +
                   3 /* length of string encoded as a single byte */ +
                   5 /* 42 encoded as 4 bytes, 82 encoded as a single byte */ +
                   6 /* 420 as 4 bytes, 840 as 2 bytes */ +
                   9 /* 2424 as 4 bytes, 100k as 5 bytes */);
            assert(ret1.ptr is buffer.ptr);
        }());
}

/// Test for static arrays
unittest
{
    static struct Container
    {
        uint[4] data;
    }

    static struct Container2
    {
        Container[4] data;
    }

    Container2 c = {
        data: [ {[ 1, 2, 3, 4 ]}, {[ 5, 6, 7, 8 ]},
                {[ 9, 10, 11, 12 ]}, {[ 13, 14, 15, 16 ]} ]
    };

    // Check that no allocation is performed
    auto serialized = serializeFull(c);

    import ocean.core.Test: testNoAlloc;
    testNoAlloc({
            const res = deserializeFull!Container2(serialized);
            assert(res == c);
        }());
}
