/*******************************************************************************

    Bindings for quorum/QuorumIntersectionChecker.h

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.quorum.QuorumIntersectionChecker;

nothrow @trusted @nogc:

import scpd.Cpp;
import scpd.quorum.QuorumTracker;
import scpd.types.Stellar_types;

// Quorum intersection checker implementation
// This method was originally implemented in C++ but
// since the changes to `NodeID` had to be moved to D.
extern (C++, "_GLOBAL__N_1") {
    extern class QuorumIntersectionCheckerImpl {
        std_string nodeName (const NodeID node) const
        {
            import std.conv;
            auto slice = node.to!string;
            return sliceToStdString(slice.ptr, slice.length);
        }
    }
}

extern (C++, `stellar`):

/// Ditto
public abstract class QuorumIntersectionChecker
{
  public:
    /// Create & initialize a QuorumIntersectionChecker with the given map
    static shared_ptr!QuorumIntersectionChecker create (
        ref const(QuorumTracker.QuorumMap) map,
	bool quiet = false);

    ~this () {}

    /// Returns: true if the network enjoys quorum intersection
    abstract bool networkEnjoysQuorumIntersection ();

    /// Returns: the total number of quorums found
    abstract size_t getMaxQuorumsFound ();

    /// Returns: A pair of possible quorum splits found, or empty pair if none
    abstract pair!(vector!NodeID, vector!NodeID) getPotentialSplit ();
}

static assert(__traits(classInstanceSize, QuorumIntersectionChecker) == 8);
