/*******************************************************************************

    Bindings for quorum/QuorumTracker.h

    Note that D code does not need to use anything in this class except the
    QuorumMap definition.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
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
    const(NodeID) mLocalNodeID;
    QuorumMap mQuorum;

public:
    static struct NodeInfo
    {
        SCPQuorumSetPtr mQuorumSet;

        this (SCPQuorumSetPtr quorumSet)
        {
            this.mQuorumSet = quorumSet;
            this.mClosestValidators = set!NodeID(CppCtor.Use);  // must initialize
        }

        // The next two fields represent distance to the local node and a set of
        // validators in the local qset that are closest to the node that
        // NodeInfo represents. If NodeInfo is the local node, mDistance is 0
        // and mClosestValidators is empty. If NodeInfo is a node in the local
        // qset, mDistance is 1 and mClosestValidators only contains the local
        // qset node. Otherwise, mDistance is the shortest distance to NodeInfo
        // from the local node, and mClosestValidators contains all validators
        // in the local qset that are (mDistance - 1) away from NodeInfo.
        int mDistance;
        set!NodeID mClosestValidators;
    }

    /// The Node ID => Quorum set map type
    alias QuorumMap = unordered_map!(NodeID, NodeInfo);

    /// Initialize a new QuorumTracker
    this (ref const(NodeID) localNodeID);

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

extern (D):
unittest
{
    assert(QuorumTracker.sizeof == getCPPSizeof!QuorumTracker());
}
