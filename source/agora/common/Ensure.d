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

    /// Overrides `Throwable.message`
    public override const(char)[] message () const return
        @safe pure nothrow @nogc
    {
        return this.buffer[0 .. this.end];
    }

    /***************************************************************************

        Overrides `Throwable.toString` sink overload

        Unfortunately, `Throwable.toString` does not call `message`,
        instead calling `msg` directly, which means our overload of `message`
        does not help. We need to overload this method and replicate the logic
        in the original code (see `object.d` in druntime for the original).

        Params:
          sink = The sink to send the piece-meal string to

    ***************************************************************************/

    public override void toString (scope void delegate(in char[]) sink) const scope
    {
        import core.internal.string : unsignedToTempString;

        char[20] buff = void;

        sink(typeid(this).name);
        sink("@"); sink(file);
        sink("("); sink(unsignedToTempString(line, buff)); sink(")");

        if (this.end > 0)
        {
            // Aside from a couple stylistic changes,
            // this is the only line that differs from `Throwable.toString`
            sink(": "); sink(this.message());
        }
        // `Throwable.info` might be `null`, e.g. in a finalizer,
        // but will probably never be for us.
        if (this.info)
        {
            try
            {
                sink("\n----------------");
                foreach (t; info)
                {
                    sink("\n"); sink(t);
                }
            }
            catch (Throwable)
            {
                // ignore more errors
            }
        }
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
