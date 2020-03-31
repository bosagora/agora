/*******************************************************************************

    Entry point for the agora-gen

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.cli.gen.main;

import scpd.scp.SCPDriver;
import scpd.tests.VTableTest;

import std.format;
import std.stdio;
import std.traits;

/// Workaround for issue likely related to dub #225,
/// expects a main() function and invokes it after unittesting.
version (unittest) void main () { } else:

/*******************************************************************************

    Application entry point

*******************************************************************************/

int main (string[] args)
{
    const string[] entries = ["TestA", "SCPDriver"];
    bool first;

    writeHeader();

    static foreach (e; entries)
    {
        mixin(
        q{
            writeMethodHeader(`%1$s`, `getVMOffset%1$s`);

            first = true;
            static foreach (idx, member; __traits(allMembers, %1$s))
            {
                mixin(
                q{
                    static if (__traits(isVirtualMethod, %1$s.%2$s) && (`%2$s` != `__dtor`) && (`%2$s` != `__xdtor`))
                    {
                        writeMethodContents(first, `%1$s`, `%2$s`);
                        first = false;
                    }
                }.format(`%1$s`, member));
            }

            writeMethodFooter();

        }.format(e, `%2$s`));
    }

    return 0;
}

/// Writes the header of the source file
void writeHeader()
{
    writeln(
`/*******************************************************************************

    Contains checking the order of virtual methods.

    Note: This is not part of Stellar SCP code.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

#include "DVTableChecks.h"
#include "scp/SCPDriver.h"

using namespace stellar;
`
    );
}

/// Writes the name of the method
void writeMethodHeader(string class_name, string method_name)
{
    writefln(`///  Returns the offset of virtual methods inside the class %s.
long %s (const char* name)
{`,
    class_name, method_name);
}

/// Writes the end of the method
void writeMethodFooter()
{
    writeln(`    else
    {
        return -1;
    }
}
`
    );
}

/// Writes the contents of the method
void writeMethodContents(bool first, string entry, string method)
{
    if (first)
        writefln(`    if (strcmp(name, "%s") == 0) `, method);
    else
        writefln(`    else if (strcmp(name, "%s") == 0) `, method);

    writefln(
`    {
        auto pf = &%s::%s;
        return ((long)reinterpret_cast<void *&>(pf)) / sizeof(long);
    }`, entry, method);
}
