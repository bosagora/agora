/*******************************************************************************

    Utilities for converting between bech32-encoded string and `ubyte` array.

    See_Also:
        https://github.com/sipa/bech32

    Copyright:
        Copyright (c) 2017, 2021 Pieter Wuille

        Permission is hereby granted, free of charge, to any person obtaining
        a copy of this software and associated documentation files
        (the "Software"), to deal in the Software without restriction, including
        without limitation the rights to use, copy, modify, merge, publish,
        distribute, sublicense, and/or sell copies of the Software, and to
        permit persons to whom the Software is furnished to do so, subject to
        the following conditions:

        The above copyright notice and this permission notice shall be included
        in all copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
        OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
        MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
        IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
        CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
        TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
        SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    License:
        Distributed under the MIT software license, see
        http://www.opensource.org/licenses/mit-license.php.

*******************************************************************************/

module agora.crypto.Bech32;

import agora.common.Ensure;
import agora.crypto.ECC;

import std.string;
import std.uni;

/// The Bech32 character set for encoding.
private immutable string CHARSET = "qpzry9x8gf2tvdw0s3jn54khce6mua7l";

/// The Bech32 character set for decoding.
private immutable byte[128] CHARSET_REV = [
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    15, -1, 10, 17, 21, 20, 26, 30,  7,  5, -1, -1, -1, -1, -1, -1,
    -1, 29, -1, 24, 13, 25,  9,  8, 23, -1, 18, 22, 31, 27, 19, -1,
     1,  0,  3, 16, 11, 28, 12, 14,  6,  4,  2, -1, -1, -1, -1, -1,
    -1, 29, -1, 24, 13, 25,  9,  8, 23, -1, 18, 22, 31, 27, 19, -1,
     1,  0,  3, 16, 11, 28, 12, 14,  6,  4,  2, -1, -1, -1, -1, -1
];

public enum Encoding
{
    Invalid,
    Bech32,  /// Bech32 encoding as defined in BIP173
    Bech32m, /// Bech32m encoding as defined in BIP350
}

/// Return type for `encodeBech32`
public struct DecodeResult
{
    /// Encoding used by the input to `encodeBech32`
    Encoding encoding;
    // Human readable part
    char[] hrp;
    // Payload (excluding checksum)
    ubyte[] data;
}

/*******************************************************************************

    Encode a Bech32 string.

    Params:
        hrp = human redable part
        values = values to be encoded
        encoding = encoding format to encode with

    Returns:
        encoded string

*******************************************************************************/

public char[] encodeBech32 (in char[] hrp, in ubyte[] values, Encoding encoding)
    @safe pure nothrow
{
    char[] encoded;
    ubyte[] conv;
    if (!convertBits(conv, values, 8, 5, true))
        assert(0);

    // First ensure that the HRP is all lowercase. BIP-173 requires an encoder
    // to return a lowercase Bech32 string, but if given an uppercase HRP, the
    // result will always be invalid.
    foreach (const ref c; hrp)
        assert(c < 'A' || c > 'Z');

    ubyte[] checksum = createChecksum(hrp, conv, encoding);
    conv ~= checksum;

    encoded ~= hrp ~ "1";
    foreach (const c ; conv)
        encoded ~= CHARSET[c];

    return encoded;
}

/*******************************************************************************

    Decode a Bech32 string.

    Params:
        str = encoded string

    Returns:
        A `DecodeResult` value, or `DecodeResult.init` on failure

*******************************************************************************/

public DecodeResult decodeBech32 (in char[] str)
    @safe
{
    import std.conv;

    bool lower = false, upper = false;
    for (size_t i = 0; i < str.length; ++i)
    {
        ubyte c = str[i];
        if (c >= 'a' && c <= 'z') lower = true;
        else if (c >= 'A' && c <= 'Z') upper = true;
        else
            ensure(c >= '!' && c <= '~',
                    "Character '{X}' at pos {} is outside of valid char range", c, i);
    }
    ensure(lower ^ upper, "Bech32 does not allow mixed lower and upper cases");

    auto pos = lastIndexOf(str, '1');
    ensure(str.length <= 90 && pos != -1 && pos != 0 && pos + 7 <= str.length,
            "Invalid HRP for Bech32: {} (pos: {})", str, pos);

    ubyte[] values;
    values.length = str.length - 1 - pos;
    for (size_t i = 0; i < values.length; ++i)
    {
        ubyte c = str[i + pos + 1];
        byte rev = CHARSET_REV[c];

        ensure(rev != -1,
                "Invalid byte '{X}' in data at position {}: {}", c, i + pos + 1, str);

        values[i] = rev;
    }
    char[] hrp;
    for (size_t i = 0; i < pos; ++i)
        hrp ~= toLower(str[i]);

    auto encoding = verifyChecksum(hrp, values);
    ensure(encoding != Encoding.Invalid, "Bech32 checksum is invalid: {}", str);

    ubyte[] conv;
    ensure(convertBits(conv, values[0 .. $ - 6], 5, 8, false),
        "Bech32 convertion of base failed: {}", str);

    return DecodeResult(encoding, hrp, conv);
}

/*******************************************************************************

    Determine the final constant to use for the specified encoding.

    Params:
        encoding = encoding to convert

    Returns:
        the final constant for the encoding

*******************************************************************************/

private uint encodingConstant (Encoding encoding) @safe pure nothrow @nogc
{
    assert(encoding == Encoding.Bech32 || encoding == Encoding.Bech32m);
    return encoding == Encoding.Bech32 ? 1 : 0x2bc830a3;
}

/*******************************************************************************

    This function will compute what 6 5-bit values to XOR into the last 6 input
    values, in order to make the checksum 0. These 6 values are packed together
    in a single 30-bit integer. The higher bits correspond to earlier values

    Params:
        values = 5-bit values to XOR

    Returns:
        checksum calculated through the polynomial

*******************************************************************************/

private uint polymod (in ubyte[] values) @safe pure nothrow @nogc
{
    // The input is interpreted as a list of coefficients of a polynomial over
    // F = GF(32), with an implicit 1 in front. If the input is [v0,v1,v2,v3,v4],
    // that polynomial is v(x) = 1*x^5 + v0*x^4 + v1*x^3 + v2*x^2 + v3*x + v4.
    // The implicit 1 guarantees that [v0,v1,v2,...] has a distinct checksum
    // from [0,v0,v1,v2,...].

    // The output is a 30-bit integer whose 5-bit groups are the coefficients
    // of the remainder of v(x) mod g(x), where g(x) is the Bech32 generator,
    // x^6 + {29}x^5 + {22}x^4 + {20}x^3 + {21}x^2 + {29}x + {18}. g(x) is
    // chosen in such a way that the resulting code is a BCH code, guaranteeing
    // detection of up to 3 errors within a window of 1023 characters. Among
    // the various possible BCH codes, one was selected to in fact guarantee
    // detection of up to 4 errors within a window of 89 characters.

    // Note that the coefficients are elements of GF(32), here represented as
    // decimal numbers between {}. In this finite field, addition is just XOR
    // of the corresponding numbers. For example, {27} + {13} = {27 ^ 13} = {22}.
    // Multiplication is more complicated, and requires treating the bits of
    // values themselves as coefficients of a polynomial over a smaller field,
    // GF(2), and multiplying those polynomials mod a^5 + a^3 + 1. For example,
    // {5} * {26} = (a^2 + 1) * (a^4 + a^3 + a) =
    // (a^4 + a^3 + a) * a^2 + (a^4 + a^3 + a) = a^6 + a^5 + a^4 + a =
    // a^3 + 1 (mod a^5 + a^3 + 1) = {9}.

    // During the course of the loop below, `c` contains the bitpacked
    // coefficients of the polynomial constructed from just the values of v
    // that were processed so far, mod g(x). In the above example, `c` initially
    // corresponds to 1 mod g(x), and after processing 2 inputs of v, it
    // corresponds to x^2 + v0*x + v1 mod g(x). As 1 mod g(x) = 1, that is
    // the starting value for `c`.
    uint c = 1;
    foreach (const v_i ; values)
    {
        // We want to update `c` to correspond to a polynomial with one extra
        // term. If the initial value of `c` consists of the coefficients of
        // c(x) = f(x) mod g(x), we modify it to correspond to
        // c'(x) = (f(x) * x + v_i) mod g(x), where v_i is the next input to
        // process. Simplifying:
        // c'(x) = (f(x) * x + v_i) mod g(x)
        //         ((f(x) mod g(x)) * x + v_i) mod g(x)
        //         (c(x) * x + v_i) mod g(x)
        // If c(x) = c0*x^5 + c1*x^4 + c2*x^3 + c3*x^2 + c4*x + c5,
        // we want to compute
        // c'(x) = (c0*x^5 + c1*x^4 + c2*x^3 + c3*x^2 + c4*x + c5) * x + v_i mod g(x)
        //       = c0*x^6 + c1*x^5 + c2*x^4 + c3*x^3 + c4*x^2 + c5*x + v_i mod g(x)
        //       = c0*(x^6 mod g(x)) + c1*x^5 + c2*x^4 + c3*x^3 + c4*x^2 + c5*x + v_i
        // If we call (x^6 mod g(x)) = k(x), this can be written as
        // c'(x) = (c1*x^5 + c2*x^4 + c3*x^3 + c4*x^2 + c5*x + v_i) + c0*k(x)

        // First, determine the value of c0:
        ubyte c0 = c >> 25;

        // Then compute c1*x^5 + c2*x^4 + c3*x^3 + c4*x^2 + c5*x + v_i:
        c = ((c & 0x1ffffff) << 5) ^ v_i;

        // Finally, for each set bit n in c0, conditionally add {2^n}k(x):
        if (c0 & 1)  c ^= 0x3b6a57b2; //     k(x) = {29}x^5 + {22}x^4 + {20}x^3 +
                                      //            {21}x^2 + {29}x + {18}
        if (c0 & 2)  c ^= 0x26508e6d; //  {2}k(x) = {19}x^5 +  {5}x^4 +     x^3 +
                                      //            {3}x^2 + {19}x + {13}
        if (c0 & 4)  c ^= 0x1ea119fa; //  {4}k(x) = {15}x^5 + {10}x^4 +  {2}x^3 +
                                      //            {6}x^2 + {15}x + {26}
        if (c0 & 8)  c ^= 0x3d4233dd; //  {8}k(x) = {30}x^5 + {20}x^4 +  {4}x^3 +
                                      //            {12}x^2 + {30}x + {29}
        if (c0 & 16) c ^= 0x2a1462b3; // {16}k(x) = {21}x^5 +     x^4 +  {8}x^3 +
                                      //            {24}x^2 + {21}x + {19}
    }
    return c;
}

/*******************************************************************************

    Expand a HRP (Human Readable Part) for use in checksum computation.

    Params:
        hrp = human redable part

    Returns:
        5-bits values for the hrp

*******************************************************************************/

private ubyte[] expandHRP (in char[] hrp) @safe pure nothrow
{
    ubyte[] ret;
    ret.length = hrp.length * 2 + 1;
    for (size_t i = 0; i < hrp.length; ++i)
    {
        ubyte c = hrp[i];
        ret[i] = c >> 5;
        ret[i + hrp.length + 1] = c & 0x1f;
    }
    ret[hrp.length] = 0;
    return ret;
}

/*******************************************************************************

    Create a checksum

    Params:
        hrp = human redable part
        values = values to get checksum from
        encoding = encoding format to encode with

    Returns:
        an checksum

*******************************************************************************/

ubyte[] createChecksum (in char[] hrp, in ubyte[] values, Encoding encoding)
    @safe pure nothrow
{
    ubyte[] enc = expandHRP(hrp);
    enc ~= values;
    enc.length = enc.length + 6;
    uint mod = polymod(enc) ^ encodingConstant(encoding);

    ubyte[] ret;
    ret.length = 6;
    for (size_t i = 0; i < 6; ++i)
        // Convert the 5-bit groups in mod to checksum values.
        ret[i] = (mod >> (5 * (5 - i))) & 31;

    return ret;
}

/*******************************************************************************

    Verify a checksum

    Params:
        hrp = human redable part
        values = values to verify the checksum with

    Returns:
        encoding if the checksum is valid; invalid encoding constant if not

*******************************************************************************/

Encoding verifyChecksum (in char[] hrp, in ubyte[] values) @safe pure nothrow
{
    // PolyMod computes what value to xor into the final values to make the
    // checksum 0. However, if we required that the checksum was 0, it would
    // be the case that appending a 0 to a valid list of values would result
    // in a new valid list. For that reason, Bech32 requires the resulting
    // checksum to be 1 instead. In Bech32m, this constant was amended.
    ubyte[] enc = expandHRP(hrp);
    enc ~= values;
    uint check = polymod(enc);
    if (check == encodingConstant(Encoding.Bech32))
        return Encoding.Bech32;
    if (check == encodingConstant(Encoding.Bech32m))
        return Encoding.Bech32m;

    return Encoding.Invalid;
}

/*******************************************************************************

    Convert from one power-of-2 number base to another

    Params:
        out_values = values that has converted
        in_values = values to be converted
        frombits = a power-of-2 number base of `in_values`
        tobits = a power-of-2 number base of `out_values`
        pad = check if the pads are added

    Returns:
        true if the conversion succeeds

*******************************************************************************/

bool convertBits (ref ubyte[] out_values, const(ubyte)[] in_values,
    int frombits, int tobits, bool pad) @safe pure nothrow
{
    int acc = 0;
    int bits = 0;
    const int maxv = (1 << tobits) - 1;
    const int max_acc = (1 << (frombits + tobits - 1)) - 1;
    for (size_t i = 0; i < in_values.length; ++i)
    {
        int value = in_values[i];
        acc = ((acc << frombits) | value) & max_acc;
        bits += frombits;
        while (bits >= tobits)
        {
            bits -= tobits;
            out_values ~= cast(ubyte)((acc >> bits) & maxv);
        }
    }
    if (pad)
    {
        if (bits)
            out_values ~= cast(ubyte)((acc << (tobits - bits)) & maxv);
    }
    else if (bits >= frombits || ((acc << (tobits - bits)) & maxv))
    {
        return false;
    }
    return true;
}

// Test for `expandHRP` function
unittest
{
    ubyte[] expected = [3, 3, 3, 0, 2, 15, 1];
    auto expanded = expandHRP("boa");
    assert(expanded == expected);
}

// Test for checksum for Bech32 encoding
unittest
{
    import std.exception;

    string[] valid_checksum_bech32 = [
        "A12UEL5L",
        "a12uel5l",
        "an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs",
        "abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw",
        "11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j",
        "split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w",
        "?1ezyfcl"
    ];

    string[] invalid_checksum_bech32 = [
        " 1nwldj5",
        "\x7f" ~ "1axkwrx",
        "\x80" ~ "1eym55h",
        "an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx",
        "pzry9x0s0muk",
        "1pzry9x0s0muk",
        "x1b4n0q5v",
        "li1dgmt3",
        "de1lg7wt\xff",
        "A1G7SGD8",
        "10a06t8",
        "1qzzfhee"
    ];

    foreach (const ref input; valid_checksum_bech32) {
        auto dec = decodeBech32(input);
        auto recode = encodeBech32(dec.hrp, dec.data, dec.encoding);
        assert(recode == toLower(input));
    }

    foreach (const ref input; invalid_checksum_bech32) {
        assertThrown(decodeBech32(input));
    }
}

// Test for checksum for Bech32m encoding
unittest
{
    import std.exception;

    string[] valid_checksum_bech32m = [
        "A1LQFN3A",
        "a1lqfn3a",
        "an83characterlonghumanreadablepartthatcontainsthetheexcludedcharactersbioandnumber11sg7hg6",
        "abcdef1l7aum6echk45nj3s0wdvt2fg8x9yrzpqzd3ryx",
        "split1checkupstagehandshakeupstreamerranterredcaperredlc445v",
        "?1v759aa"
    ];

    string[] invalid_checksum_bech32m = [
        " 1xj0phk",
        "\x7F" ~ "1g6xzxy",
        "\x80" ~ "1vctc34",
        "an84characterslonghumanreadablepartthatcontainsthetheexcludedcharactersbioandnumber11d6pts4",
        "qyrz8wqd2c9m",
        "1qyrz8wqd2c9m",
        "y1b0jsk6g",
        "lt1igcx5c0",
        "in1muywd",
        "mm1crxm3i",
        "au1s5cgom",
        "M1VUXWEZ",
        "16plkw9",
        "1p2gdwpf"
    ];

    foreach (const ref input; valid_checksum_bech32m) {
        auto dec = decodeBech32(input);
        auto recode = encodeBech32(dec.hrp, dec.data, dec.encoding);
        assert(recode == toLower(input));
    }

    foreach (const ref input; invalid_checksum_bech32m) {
        assertThrown(decodeBech32(input));
    }
}

private struct AddressData
{
    public string address;
    public Point pubkey;
}

// Test for valid Bech32 addresses
unittest
{
        AddressData[] addresses_bech32 = [
        // CoinNet Genesis Address
        // GDGENYO6TWO6EZG2OXEBVDCNKLHCV2UFLLZY6TJMWTGR23UMJHVHLHKJ
        AddressData(
            "boa1xrxydcw7nkw7yex6whyp4rzd2t8z4659ttec7nfvknx36m5vf8482zsr6r4",
            Point(cast(ubyte[])[
                204, 70, 225, 222, 157, 157, 226, 100,
                218, 117, 200, 26, 140, 77, 82, 206,
                42, 234, 133, 90, 243, 143, 77, 44,
                180, 205, 29, 110, 140, 73, 234, 117])
        ),
        // CoinNet CommonsBudget Address
        // GCOMBBXA6ON7PT7APS4IWS4N53FCBQTLWBPIU4JR2DSOBCA72WEB4XU4
        AddressData(
            "boa1xzwvpphq7wdl0nlq0jugkjudam9zpsntkp0g5uf36rjwpzql6kypuc3gffp",
            Point(cast(ubyte[])[
                156, 192, 134, 224, 243, 155, 247, 207,
                224, 124, 184, 139, 75, 141, 238, 202,
                32, 194, 107, 176, 94, 138, 113, 49,
                208, 228, 224, 136, 31, 213, 136, 30])
        ),
        // TestNet Genesis Address
        // GDGENES4KXH7RQJELTONR7HSVISVSQ5POSVBEWLR6EEIIL72H24IEDT4
        AddressData(
            "boa1xrxydyju2h8l3sfytnwd3l8j4gj4jsa0wj4pykt37yyggtl686ugypjzxpf",
            Point(cast(ubyte[])[
                204, 70, 146, 92, 85, 207, 248, 193,
                36, 92, 220, 216, 252, 242, 170, 37,
                89, 67, 175, 116, 170, 18, 89, 113,
                241, 8, 132, 47, 250, 62, 184, 130])
        ),
        // TestNet CommonsBudget Address
        // GDCOMMO272NFWHV5TQAIQFEDLQZLBMVVOJTHC3F567ZX4ZSRQQQWGLI3
        AddressData(
            "boa1xrzwvvw6l6d9k84ansqgs9yrtsetpv44wfn8zm9a7lehuej3ssskx7thkmj",
            Point(cast(ubyte[])[
                196, 230, 49, 218, 254, 154, 91, 30,
                189, 156, 0, 136, 20, 131, 92, 50,
                176, 178, 181, 114, 102, 113, 108, 189,
                247, 243, 126, 102, 81, 132, 33, 99])
        ),
        // Null Address
        AddressData(
            "boa1xqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqgezvze",
            Point.init
        ),
        // GDNODE2JBW65U6WVIOESR3OTJUFOHPHTEIL4GQINDB3MVB645KXAHG73
        AddressData(
            "boa1xrdwry6fpk7a57k4gwyj3mwnf59w808nygtuxsgdrpmv4p7ua2hqxtmjcu3",
            Point(cast(ubyte[])[
                218, 225, 147, 73, 13, 189, 218, 122,
                213, 67, 137, 40, 237, 211, 77, 10,
                227, 188, 243, 34, 23, 195, 65, 13,
                24, 118, 202, 135, 220, 234, 174, 3])
        ),
        // GDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQFW
        AddressData(
            "boa1xrra39xpg5q9zwhsq6u7pw508z2let6dj8r5lr4q0d0nff240fvd2tct454",
            Point(cast(ubyte[])[
                199, 216, 148, 193, 69, 0, 81, 58,
                240, 6, 185, 224, 186, 143, 56, 149,
                252, 175, 77, 145, 199, 79, 142, 160,
                123, 95, 52, 165, 85, 122, 88, 213])
        ),
        // GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN
        AddressData(
            "boa1xp9rtxssrry6zqc4yt40h5h3al6enaywnvxfsp0ng8jt0ywyecssz9deump",
            Point(cast(ubyte[])[
                74, 53, 154, 16, 24, 201, 161, 3,
                21, 34, 234, 251, 210, 241, 239, 245,
                153, 244, 142, 155, 12, 152, 5, 243,
                65, 228, 183, 145, 196, 206, 33, 1])
        ),
        // GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5
        AddressData(
            "boa1xpc2ugmlve2ttuq6sjl4fznrggf2l5hksk2h2nsakexn690zxg4gs9f3rtg",
            Point(cast(ubyte[])[
                112, 174, 35, 127, 102, 84, 181, 240,
                26, 132, 191, 84, 138, 99, 66, 18,
                175, 210, 246, 133, 149, 117, 78, 29,
                182, 77, 61, 21, 226, 50, 42, 136])
        ),
        // GCKLKUWUDJNWPSTU7MEN55KFBKJMQIB7H5NQDJ7MGGQVNYIVHB5ZM5XP
        AddressData(
            "boa1xz2t25k5rfdk0jn5lvydaa29p2fvsgpl8adsrflvxxs4dcg48paevj87akp",
            Point(cast(ubyte[])[
                148, 181, 82, 212, 26, 91, 103, 202,
                116, 251, 8, 222, 245, 69, 10, 146,
                200, 32, 63, 63, 91, 1, 167, 236,
                49, 161, 86, 225, 21, 56, 123, 150])
        ),
    ];

    foreach (input; addresses_bech32)
    {
        ubyte[] data_bin;
        data_bin.length = input.pubkey[].length + 1;
        data_bin[0] = 48;
        data_bin[1 .. $] = cast(ubyte[])input.pubkey[][0 .. $];

        ubyte[] conv_data;
        ubyte[] revert_data;
        assert(convertBits(conv_data, data_bin, 8, 5, true));
        assert(convertBits(revert_data, conv_data, 5, 8, false));
        assert(revert_data[] == data_bin);

        char[] addr_str = encodeBech32("boa", data_bin, Encoding.Bech32);
        assert(addr_str == input.address, addr_str);

        auto dec = decodeBech32(input.address);
        assert(dec.encoding == Encoding.Bech32);
        assert(dec.data == data_bin);
    }
}

// Test for valid Bech32m addresses
unittest
{
    AddressData[] addresses_bech32_m = [
        // CoinNet Genesis Address
        // GDGENYO6TWO6EZG2OXEBVDCNKLHCV2UFLLZY6TJMWTGR23UMJHVHLHKJ
        AddressData(
            "boa1xrxydcw7nkw7yex6whyp4rzd2t8z4659ttec7nfvknx36m5vf8482hvnkxh",
            Point(cast(ubyte[])[
                204, 70, 225, 222, 157, 157, 226, 100,
                218, 117, 200, 26, 140, 77, 82, 206,
                42, 234, 133, 90, 243, 143, 77, 44,
                180, 205, 29, 110, 140, 73, 234, 117])
        ),
        // CoinNet CommonsBudget Address
        // GCOMBBXA6ON7PT7APS4IWS4N53FCBQTLWBPIU4JR2DSOBCA72WEB4XU4
        AddressData(
            "boa1xzwvpphq7wdl0nlq0jugkjudam9zpsntkp0g5uf36rjwpzql6kypuddc9vr",
            Point(cast(ubyte[])[
                156, 192, 134, 224, 243, 155, 247, 207,
                224, 124, 184, 139, 75, 141, 238, 202,
                32, 194, 107, 176, 94, 138, 113, 49,
                208, 228, 224, 136, 31, 213, 136, 30])
        ),
        // TestNet Genesis Address
        // GDGENES4KXH7RQJELTONR7HSVISVSQ5POSVBEWLR6EEIIL72H24IEDT4
        AddressData(
            "boa1xrxydyju2h8l3sfytnwd3l8j4gj4jsa0wj4pykt37yyggtl686ugy5wj2yt",
            Point(cast(ubyte[])[
                204, 70, 146, 92, 85, 207, 248, 193,
                36, 92, 220, 216, 252, 242, 170, 37,
                89, 67, 175, 116, 170, 18, 89, 113,
                241, 8, 132, 47, 250, 62, 184, 130])
        ),
        // TestNet CommonsBudget Address
        // GDCOMMO272NFWHV5TQAIQFEDLQZLBMVVOJTHC3F567ZX4ZSRQQQWGLI3
        AddressData(
            "boa1xrzwvvw6l6d9k84ansqgs9yrtsetpv44wfn8zm9a7lehuej3ssskxth867s",
            Point(cast(ubyte[])[
                196, 230, 49, 218, 254, 154, 91, 30,
                189, 156, 0, 136, 20, 131, 92, 50,
                176, 178, 181, 114, 102, 113, 108, 189,
                247, 243, 126, 102, 81, 132, 33, 99])
        ),
        // Null Address
        AddressData(
            "boa1xqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqa9jq8m",
            Point.init
        ),
        // GDNODE2JBW65U6WVIOESR3OTJUFOHPHTEIL4GQINDB3MVB645KXAHG73
        AddressData(
            "boa1xrdwry6fpk7a57k4gwyj3mwnf59w808nygtuxsgdrpmv4p7ua2hqx78z5en",
            Point(cast(ubyte[])[
                218, 225, 147, 73, 13, 189, 218, 122,
                213, 67, 137, 40, 237, 211, 77, 10,
                227, 188, 243, 34, 23, 195, 65, 13,
                24, 118, 202, 135, 220, 234, 174, 3])
        ),
        // GDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQFW
        AddressData(
            "boa1xrra39xpg5q9zwhsq6u7pw508z2let6dj8r5lr4q0d0nff240fvd27yme3h",
            Point(cast(ubyte[])[
                199, 216, 148, 193, 69, 0, 81, 58,
                240, 6, 185, 224, 186, 143, 56, 149,
                252, 175, 77, 145, 199, 79, 142, 160,
                123, 95, 52, 165, 85, 122, 88, 213])
        ),
        // GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN
        AddressData(
            "boa1xp9rtxssrry6zqc4yt40h5h3al6enaywnvxfsp0ng8jt0ywyecsszs3fs7r",
            Point(cast(ubyte[])[
                74, 53, 154, 16, 24, 201, 161, 3,
                21, 34, 234, 251, 210, 241, 239, 245,
                153, 244, 142, 155, 12, 152, 5, 243,
                65, 228, 183, 145, 196, 206, 33, 1])
        ),
        // GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5
        AddressData(
            "boa1xpc2ugmlve2ttuq6sjl4fznrggf2l5hksk2h2nsakexn690zxg4gss4p0w2",
            Point(cast(ubyte[])[
                112, 174, 35, 127, 102, 84, 181, 240,
                26, 132, 191, 84, 138, 99, 66, 18,
                175, 210, 246, 133, 149, 117, 78, 29,
                182, 77, 61, 21, 226, 50, 42, 136])
        ),
        // GCKLKUWUDJNWPSTU7MEN55KFBKJMQIB7H5NQDJ7MGGQVNYIVHB5ZM5XP
        AddressData(
            "boa1xz2t25k5rfdk0jn5lvydaa29p2fvsgpl8adsrflvxxs4dcg48paev8mw3nr",
            Point(cast(ubyte[])[
                148, 181, 82, 212, 26, 91, 103, 202,
                116, 251, 8, 222, 245, 69, 10, 146,
                200, 32, 63, 63, 91, 1, 167, 236,
                49, 161, 86, 225, 21, 56, 123, 150])
        ),
    ];

    foreach (input; addresses_bech32_m)
    {
        ubyte[] data_bin;
        data_bin.length = input.pubkey[].length + 1;
        data_bin[0] = 48;
        data_bin[1 .. $] = cast(ubyte[])input.pubkey[][0 .. $];

        ubyte[] conv_data;
        ubyte[] revert_data;
        assert(convertBits(conv_data, data_bin, 8, 5, true));
        assert(convertBits(revert_data, conv_data, 5, 8, false));
        assert(revert_data[] == data_bin);

        char[] addr_str = encodeBech32("boa", data_bin, Encoding.Bech32m);
        assert(addr_str == input.address, addr_str);

        auto dec = decodeBech32(input.address);
        assert(dec.encoding == Encoding.Bech32m);
        assert(dec.data == data_bin);
    }
}
