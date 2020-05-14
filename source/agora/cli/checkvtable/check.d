/*******************************************************************************

    The agora-checkvtable-run sub-function for checking virtual method offset

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.cli.checkvtable.check;

import agora.cli.checkvtable.types;

import std.format;
import std.stdio;
import std.string;

version (Windows)
{
    pragma(msg, __MODULE__, " : This does not support Windows.");
}
else:

version (unittest) { } else:

extern(C++) int checkVMOffset (const char* classname, const char* offsets);

/// This is agora-checkvtable sub-function for checking virtual method offset
private int main (string[] args)
{
    /// Associated array to store offset of members
    long[string] offsets;

    /// Offset of current method
    long current_offset;

    /// Used to deliver `offsets` to C++
    string serialized_offsets;

    static foreach (e; VTableCheckClasses)
    {
        offsets.clear();
        current_offset = 0;

        mixin(
        q{
            static foreach (member; __traits(allMembers, %1$s))
            {
                mixin(
                q{
                    static if (__traits(isVirtualMethod, %1$s.%2$s) && (`%2$s` != `__xdtor`))
                    {
                        static if (`%2$s` == `__dtor`)
                            current_offset += 2;
                        else
                            offsets[`%2$s`] = current_offset++;
                    }
                }.format(`%1$s`, member));
            }

            serialized_offsets = "";
            foreach (k,v; offsets)
                serialized_offsets ~= format(`%%s=%%d:`, k,v);

            assert(checkVMOffset(`%1$s`, toStringz(serialized_offsets)) == 0, "The virtual method offset of %1$s does not match.");

        }.format(e, `%2$s`));
    }

    writefln("The virtual method offsets of all classes match");
    return 0;
}
