/*******************************************************************************

    A simple `Nullable` type that doesn't get in your way.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.Nullable;

import std.traits;

/// Ditto
public struct Nullable (T)
{
    // If the type is a pointer, we don't require additional storage
    private enum PassThrough = is(T : Pointee*, Pointee);

    static if (!PassThrough)
    {
        // Storage, if needed
        private Unqual!T storage;
        /// Uses a bool to check if `null` or not, avoiding issues with
        // `hasUnsharedAliasing`, postblit, and co
        private bool isNull_;
    }
    else
    {
        private T storage;
    }

    ///
    public this (ref T v)
    {
        static if (PassThrough)
            this.storage = v;
        else
        {
            this.storage = v;
            this.isNull_ = false;
        }
    }

    ///
    public bool isNull () @safe pure nothrow @nogc
    {
        static if (PassThrough)
            return this.storage is null;
        else
            return this.isNull_;
    }

    ///
    public ref inout(T) get() @safe pure nothrow @nogc inout
    {
        assert(!this.isNull());
        static if (PassThrough)
            return *this.storage;
        else
            return this.storage;
    }

    ///
    public ref Nullable!T opAssign (ref T value)
    {
        static if (PassThrough)
            this.storage = value;
        else
        {
            this.storage = value;
            this.isNull_ = false;
        }
        return this;
    }

    ///
    public ref Nullable!T opAssign (typeof(null) null_)
    {
        static if (PassThrough)
            this.storage = null;
        else
            this.isNull_ = true;
        return this;
    }
}
