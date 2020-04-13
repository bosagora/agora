/*******************************************************************************

    Bindings for quorum/QuorumTracker.h

    Note that D code does not need to use anything in this class except the
    QuorumMap definition.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.quorum.QuorumTracker;

@trusted @nogc nothrow:

import scpd.Cpp;
import scpd.scp.SCP;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types;

extern (C++, `stellar`):

private mixin template NonMovableOrCopyable ()
{
    @disable this ();
    @disable this (this);
    @disable ref typeof (this) opAssign () (auto ref typeof(this) rhs);
}

/// helper class to help track the overall quorum over time
/// a node tracked is definitely in the transitive quorum.
/// If its associated quorum set is empty (nullptr), it just means
/// that another node has that node in its quorum set
/// but could not explore the quorum further (as we're missing the quorum set)
/// Nodes can be added one by one (calling `expand`, most efficient)
/// or the quorum can be rebuilt from scratch by using a lookup function
extern (C++, class) public struct QuorumTracker
{
    mixin NonMovableOrCopyable!();

private:
    SCP* mSCP;
    QuorumMap mQuorum;

public:
    /// The Node ID => Quorum set map type
    alias QuorumMap = unordered_map!(NodeID, SCPQuorumSetPtr);

    /// Initialize a new QuorumTracker
    this (SCP* scp);

    /// returns true if id is in transitive quorum for sure
    bool isNodeDefinitelyInQuorum (const ref NodeID id);

    /// attempts to expand quorum at node `id`
    /// expansion here means adding `id` to the known quorum
    /// and add its dependencies as defined by `qset`
    /// returns true if expansion succeeded
    ///     `id` was unknown
    ///     `id` was known and didn't have a quorumset
    /// returns false on failure
    /// if expand fails, the caller should instead use `rebuild`
    bool expand (const ref NodeID id, SCPQuorumSetPtr qSet);

    /// returns the known quorum map of the entire network
    ref const(QuorumMap) getQuorum () const;
}

// should be 48, see #753
static assert(QuorumTracker.sizeof == 16);
