/*******************************************************************************

    Defines common types used by Agora

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Types;

import agora.crypto.ECC;
import agora.crypto.Key;
import agora.crypto.Schnorr;
public import agora.crypto.Types;

import geod24.bitblob;

import std.array : appender;
import std.conv : to;
import std.string: lastIndexOf, toLower;
import std.uri: encode;

/// Represents a specific point in time, it should be changed to time_t
/// after time_t became platform independent
public alias TimePoint = ulong;

/// An array of const characters
public alias cstring = const(char)[];

/// A network address
public alias Address = string;

/// Extension of Vibe.d's URL with normalization and `agora` schema capabilities
public struct URL
{
    import vibe.inet.url : VibeURL = URL, isCommonInternetSchema;

    /// Base Vibe.d URL implementation
    public VibeURL inner;

    /***************************************************************************
         
         Params:
           url = Plain URL

        Notes:
            - `url` must be plain and not percent-encoded
            - `url` host name can only contain ASCII characters, 
              [puny codes](https://github.com/vibe-d/vibe.d/issues/492) are not
              supported
            - `url` schema [must be](https://github.com/vibe-d/vibe.d/issues/2619)
              lowercase

    ***************************************************************************/

    public this (string url)
    {
        this.inner = VibeURL(url.encode);
    }

    /// The port part of the URL (optional, supports `agora` schema)
    @property ushort port() const nothrow 
    {
        return inner.port ? inner.port : defaultPort(inner.schema); 
    }

    /// ditto
    @property port(ushort v) nothrow { inner.port = v; }

    /// Get the default port for the given schema or 0 (supports `agora` schema)
    static ushort defaultPort(string schema)
    nothrow {
        switch (schema) {
            case "agora": return 2826;
            default:
                return VibeURL.defaultPort(schema);
        }
    }

    /// ditto
    ushort defaultPort()
    const nothrow {
        return defaultPort(inner.schema);
    }

    /***************************************************************************
         
        Normalizes URL by;
            - Lowering letter cases for schema and host
            - Hiding default port for the schema
            - Normalizing the path
            - Removing file segment from the path
            - Adding trailing slash
            - Removing the anchor

        Returns:
           url = Normalized representation of URL

        Notes:
            - Original URL is not modified

    ***************************************************************************/

    public string normalized()
    {
        auto urlbuilder = appender!string();

        // std.uri.encode percent encodes with Uppercase and passes unreserved 
        // characters (ALPHA, NUMERIC, - . _ ~) while encoding

        // Schema to lower case
        urlbuilder.put(inner.schema.toLower());
        urlbuilder.put(":");
        if (isCommonInternetSchema(inner.schema))
            urlbuilder.put("//");
        
        if (inner.username || inner.password)
        {
            urlbuilder.put(inner.username);
            if (inner.password)
            {
                urlbuilder.put(':');
                urlbuilder.put(inner.password);    
            }
            urlbuilder.put('@');
        }

        import std.algorithm : canFind;
        if (inner.host.canFind(":"))
        { // ipv6
		    urlbuilder.put('[');
		    urlbuilder.put(host);
		    urlbuilder.put(']');
        }
        else
        {
            // Host name to lower case
		    urlbuilder.put(inner.host.toLower());
        }

        // Pass default for the schema
        if (inner.port != defaultPort(inner.schema))
        {
            urlbuilder.put(':');
			urlbuilder.put(to!string(inner.port));
        }

        if (inner.pathString.length)
        {
            auto path = inner.path.normalized();
            auto str_path = path.toString();

            if (!path.fileExtension.empty)
            { // File segment is not necessary for normalized URLs
                str_path = str_path[0..str_path.lastIndexOf('/')];
            }

            // Normalized path
            urlbuilder.put(str_path);
        }

        // Always with trailing slash
        if (!path.endsWithSlash)
            urlbuilder.put("/");

        if (inner.queryString.length)
        {
            urlbuilder.put("?");
            urlbuilder.put(inner.queryString);
        }

        // Anchors are not necessary for normalized URLs
        // TODO We can reverse lookup DNS for IP addresses    

        return urlbuilder.data;
    }

    public alias inner this;

    unittest
    {
        import vibe.inet.url : VibeURL = URL, registerCommonInternetSchema;
        assert(URL.defaultPort("http") == VibeURL.defaultPort("http"));
        assert(URL("http://example.com").port == URL.defaultPort("http"));
        
        registerCommonInternetSchema("agora");
        assert(URL.defaultPort("agora") == 2826);
        assert(URL("agora://example.com:1234").port == 1234);
        assert(URL("agora://example.com").port == URL.defaultPort("agora"));
    }

    unittest
    {
        assert(URL("http://example.com").normalized == "http://example.com/");
        assert(URL("http://example.com:80/").normalized == "http://example.com/");
        assert(URL("http://example.com/foo//bar").normalized == "http://example.com/foo/bar/");
        assert(URL("https://example.com/example/path//").normalized == "https://example.com/example/path/");
        assert(URL("http://example.com/foo/./bar/baz/../qux").normalized == "http://example.com/foo/bar/qux/");
        assert(URL("http://example.com/bar.html#section1").normalized == "http://example.com/");
        assert(URL("https://example.com/hello/world//file.txt").normalized == "https://example.com/hello/world/");
        assert(URL("http://User@Example.COM/Foo").normalized == "http://User@example.com/Foo/");
        // Disabled due to https://github.com/vibe-d/vibe.d/issues/2619
        // assert(URL("HTTP://User@Example.COM/Foo").normalized == "http://User@example.com/Foo");
    }
}

/// The definition of a Quorum
public struct QuorumConfig
{
    /// Threshold of this quorum set
    public uint threshold = 1;

    /// List of nodes in this quorum
    public ulong[] nodes;

    /// List of any sub-quorums
    public QuorumConfig[] quorums;
}

/// A type to ensure that height and other integer values aren't mixed
public struct Height
{
    ///
    public ulong value;

    /// Provides implicit conversion to `ulong`
    public alias value this;

    /// Support for Vibe.d serialization to JSON
    public string toString () const @safe
    {
        import std.conv : to;
        return this.value.to!string;
    }

    /// Support for Vibe.d deserialization
    public static Height fromString (scope const(char)[] str) pure @safe
    {
        import std.conv : to;
        immutable ul = str.to!ulong;
        return Height(ul);
    }

    /// Prevent needing to cast when using unary post plus operator
    public Height opUnary (string op) () if (op == "++")
    {
        return Height(this.value++);
    }

    /// Allow to offset an height by a fixed number
    public Height opBinary (string op : "+") (ulong offset) const
    {
        return Height(this.value + offset);
    }

    /// Allow to offset an height by a fixed number
    public ref Height opBinaryAssign (string op : "+=") (ulong offset) return
    {
        this.value += offset;
        return this;
    }
}

///
unittest
{
    import vibe.data.json;

    const h = Height(1000);
    const(char)[] str_h = "1000";

    assert(h.toString() == str_h);
    assert(h.fromString(str_h) == h);
    assert(h.serializeToJsonString() == "\"1000\"");
    auto x = Height(10);
    assert(x++ == 10);
    assert(x == 11);

    auto y = x + 1;
    assert(y == 12);

    y += 5;
    assert(y == 17);
}

/// Converts a signature to a BitBlob
public BitBlob!(Signature.sizeof) toBlob (in Signature signature) pure nothrow @nogc @safe
{
    typeof(return) ret;
    ret[Scalar.sizeof .. $][] = signature.R[];
    ret[0 .. Scalar.sizeof][] = signature.s[];
    return ret;
}

/// Deserialize a binary blob into a signature
public static Signature toSignature (in BitBlob!(Signature.sizeof) bytes) pure nothrow @nogc @safe
{
    return Signature(Point(bytes[Scalar.sizeof .. $]), Scalar(bytes[0 .. Scalar.sizeof]));
}

/// Deserialize a ubyte array into a signature
public static Signature toSignature (in ubyte[] bytes) pure nothrow @nogc @safe
{
    return BitBlob!(Signature.sizeof)(bytes).toSignature();
}

///
unittest
{
    auto kp = KeyPair.random();
    static immutable string message = "Well Hello!";
    auto sig = kp.secret.sign(message);
    auto blob = sig.toBlob();
    assert(sig == blob.toSignature());
}
