/*******************************************************************************

    Bindings for quorum/QuorumIntersectionChecker.h

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.quorum.QuorumIntersectionChecker;

nothrow @trusted @nogc:

import scpd.Cpp;
import scpd.quorum.QuorumTracker;
import scpd.types.Stellar_types;

extern (C++, `stellar`):

/// Ditto
public abstract class QuorumIntersectionChecker
{
  public:
    /// Create & initialize a QuorumIntersectionChecker with the given map
    static shared_ptr!QuorumIntersectionChecker create (
        ref const(QuorumTracker.QuorumMap) map);

    ~this () {}

    /// Returns: true if the network enjoys quorum intersection
    abstract bool networkEnjoysQuorumIntersection ();

    /// Returns: the total number of quorums found
    abstract size_t getMaxQuorumsFound ();

    /// Returns: A pair of possible quorum splits found, or empty pair if none
    abstract pair!(vector!NodeID, vector!NodeID) getPotentialSplit ();
}

static assert(__traits(classInstanceSize, QuorumIntersectionChecker) == 8);
