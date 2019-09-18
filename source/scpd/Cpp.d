/*******************************************************************************

    Types currently missing from `core.stdcpp` and some additions

    Hopefully in the future we can reduce / remove this module.
    In the meantime, this is the most pragmatic way to do C++ bindings,
    as code in `core.stdcpp` needs to care about cross platform,
    cross compiler, cross C++ versions compatibility, but we have a much smaller
    target.

    The first step in reducing / removing this module would be to import
    exceptions / runtime binding for OSX to Druntime.

    At the moment, we build for Ubuntu 16.04 (Travis) and Mac OSX 14

    See_Also:
      https://github.com/dlang-cpp-interop

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.Cpp;

//import core.stdcpp.exception;
import std.meta;

import vibe.data.json;

/// Work around dual ABI issues
/// https://gcc.gnu.org/onlinedocs/libstdc++/manual/using_dual_abi.html
private template StdNS ()
{
    version (darwin)
        alias StdNS = AliasSeq!(`std`, `__1`);
    else
        alias StdNS = AliasSeq!(`std`);
}

extern(C++, (StdNS!())) {
    /// Simple binding to `std::shared_ptr`
    struct shared_ptr (T)
    {
        static if (is(T == class) || is(T == interface))
            private alias TPtr = T;
        else
            private alias TPtr = T*;

        ~this() {}
        TPtr ptr;
        void* _control_block;
        alias ptr this;
    }

    /// Simple binding to `std::unique_ptr`
    struct unique_ptr (T)
    {
        static if (is(T == class) || is(T == interface))
            private alias TPtr = T;
        else
            private alias TPtr = T*;

        TPtr ptr;
        alias ptr this;
    }
}

/// C++ support for foreach
extern(C++) private int cpp_set_foreach(T)(void* set, void* ctx, void* cb);

extern(C++, `std`) {
    /// Binding: Needs to be instantiated on C++ side
    shared_ptr!T make_shared(T, Args...)(Args args);

    class runtime_error : exception { }
    class logic_error : exception { }

    /// TODO: Move to druntime
    class exception
    {
        this() nothrow {}
        const(char)* what() const nothrow;
    }

    /// Fake bindings for std::set
    public struct set (Key)
    {
        void*[3] ptr;

        /// Foreach support
        extern(D) public int opApply (scope int delegate(ref const(Key)) dg) const
        {
            extern(C++) static int wrapper (void* context, ref const(Key) value)
            {
                auto dg = *cast(typeof(dg)*)context;
                return dg(value);
            }

            return cpp_set_foreach!Key(cast(void*)&this, cast(void*)&dg,
                cast(void*)&wrapper);
        }
    }

    /// Fake bindings for std::map
    public struct map (Key, Value)
    {
        void*[3] ptr;
    }
}

private extern(C++) set!uint* makeTestSet();

unittest
{
    auto set = makeTestSet;
    uint[] values;
    foreach (val; *set)
        values ~= val;
    assert(values == [1, 2, 3, 4, 5]);
}

/// Can't import `core.stdcpp.allocator` because it transitively imports
/// `core.stdcpp.exception`
/// In this case we just need to get the name right for `vector`
extern(C++, (StdNS!())) struct allocator (T) {}

/// Simple bindings from `std::vector`
/// Note: It's very easy to get the memory management wrong
/// Extra items, like `ConstIterator` and `toString` / `fromString`
/// are for ease of use
/// `to/fromString` actually allows vibe.d to deserialize it
extern(C++, (StdNS!())) struct vector (T, Alloc = allocator!T)
{
    T* _start;
    T* _end;
    T* _end_of_storage;

    extern(D)
    {
        /// TODO: Separate from `vector` definition
        private static struct ConstIterator
        {
            const(T)* ptr;
            const(vector!T) orig;

            public ref const(T) front () const pure nothrow @nogc
            {
                if (this.empty)
                    assert(0);
                return *this.ptr;
            }
            public void popFront () pure nothrow @nogc
            {
                if (!this.empty)
                    this.ptr++;
            }
            public @property bool empty () const pure nothrow @safe @nogc
            {
                return !(this.ptr < this.orig._end);
            }
        }

        public ref inout(T) opIndex(size_t idx) inout pure nothrow @nogc
        {
            assert(idx < this.length);
            return this._start[idx];
        }

        public size_t length () const pure nothrow @nogc
        {
            return this._end - this._start;
        }

        public ConstIterator constIterator () const pure nothrow @nogc @safe
        {
            return ConstIterator(this._start, this);
        }

        string toString() const @trusted
        {
            bool first = true;
            string ret = "[ ";
            foreach (ref entry; this.constIterator())
            {
                if (!first)
                    ret ~= ", ";
                ret ~= entry.serializeToJsonString();
                first = false;
            }
            ret ~= " ]";
            return ret;
        }

        static typeof(this) fromString(string src) @safe
        {
            import scpd.types.Utils;
            auto array = src.deserializeJson!(T[]);
            typeof(this) vec;
            foreach (ref item; array)
                vec.push_back(item);
            return vec;
        }
    }
}

unittest
{
    import scpd.types.Utils;
    vector!ubyte vec;
    assert(vec.length == 0);

    ubyte x = 1;
    vec.push_back(x);
    x = 2;
    vec.push_back(x);
    x = 3;
    vec.push_back(x);
    assert(vec.length == 3);
}
