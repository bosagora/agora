/*******************************************************************************

     Throw a statically allocated exception with formatting capacility.

     The function in this module are not `@nogc` / `pure` but they do not
     allocate if the formatting does not allocate.
     A static buffer is used by the Exception, so the output length is limited.
     Do not try to print a full block, for example.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Ensure;

import ocean.text.convert.Formatter;

/// Module ctor to initialize the thread-local instance
static this ()
{
    instance = new FormattedException();
}

/// The underlying instance
private FormattedException instance;

/// An exception which doesn't allocate but allows formatting a message
private final class FormattedException : Exception
{
    /// Internal buffer, should be enough for most messages
    private char[2048] buffer;
    /// Used size
    private size_t end;

    private this () @safe pure nothrow @nogc
    {
        super("An Exception occured");
    }

    public override const(char)[] message () const return
        @safe pure nothrow @nogc
    {
        return this.buffer[0 .. this.end];
    }
}

public void ensure (Args...) (bool exp, string fmt, lazy Args args,
    string file = __FILE__, typeof(__LINE__) line = __LINE__)
{
    if (!exp)
    {
        auto res = instance.buffer.snformat(fmt, args);
        instance.end = res.length;
        instance.file = file;
        instance.line = line;
        throw instance;
    }
}
