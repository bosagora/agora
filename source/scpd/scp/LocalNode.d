/*******************************************************************************

    Bindings for scp/LocalNode.h

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.scp.LocalNode;

import scpd.scp.SCP;
import scpd.Cpp;

import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types;
import scpd.types.XDRBase;

import core.stdc.stdint;

extern(C++, stellar):

/**
 * This is one Node in the stellar network
 */
extern(C++, class) public struct LocalNode
{
  protected:
    const NodeID mNodeID;
    const bool mIsValidator;
    SCPQuorumSet mQSet;
    Hash mQSetHash;

    // // alternative qset used during externalize {{mNodeID}}
    Hash            gSingleQSetHash;  // hash of the singleton qset
    SCPQuorumSetPtr mSingleQSet;      // {{mNodeID}}

    SCP* mSCP;

  public:
    this(ref const(NodeID) nodeID, bool isValidator,
         ref const(SCPQuorumSet) qSet, SCP scp);

    ref const(NodeID) getNodeID();

    void updateQuorumSet(ref const(SCPQuorumSet) qSet);

    ref const(SCPQuorumSet) getQuorumSet();
    ref const(Hash) getQuorumSetHash();
    bool isValidator();

    // returns the quorum set {{X}}
    static SCPQuorumSetPtr getSingletonQSet(const ref NodeID nodeID);

    // runs proc over all nodes contained in qset
    static void forAllNodes(const ref SCPQuorumSet qset,
                            CPPDelegate!(void function(const ref NodeID)));

    // returns the weight of the node within the qset
    // normalized between 0-uint64_t_MAX
    static uint64_t getNodeWeight(const ref NodeID nodeID, const ref SCPQuorumSet qset);

    // Tests this node against nodeSet for the specified qSethash.
    static bool isQuorumSlice(const ref SCPQuorumSet qSet,
                              const ref vector!NodeID nodeSet);
    static bool isVBlocking(const ref SCPQuorumSet qSet,
                            const ref vector!NodeID nodeSet);

    // Tests this node against a map of nodeID -> T for the specified qSetHash.

    // `isVBlocking` tests if the filtered nodes V are a v-blocking set for
    // this node.
    static bool isVBlocking(const ref SCPQuorumSet qSet,
                const ref map!(NodeID, SCPEnvelope) _map,
                CPPDelegate!(bool function(const ref SCPStatement)) filter);

    // `isQuorum` tests if the filtered nodes V form a quorum
    // (meaning for each v \in V there is q \in Q(v)
    // included in V and we have quorum on V for qSetHash). `qfun` extracts the
    // SCPQuorumSetPtr from the SCPStatement for its associated node in map
    // (required for transitivity)
    static bool isQuorum(const ref SCPQuorumSet qSet,
        const ref map!(NodeID, SCPEnvelope) _map,
             const ref CPPDelegate!(SCPQuorumSetPtr function(const ref SCPStatement)) qfun,
             const ref CPPDelegate!(bool function(const ref SCPStatement)) filter);

    // computes the distance to the set of v-blocking sets given
    // a set of nodes that agree (but can fail)
    // excluded, if set will be skipped altogether
    static vector!NodeID findClosestVBlocking(const ref SCPQuorumSet qset,
        const ref set!NodeID nodes, const(NodeID)* excluded);

    static vector!NodeID findClosestVBlocking (
        const ref SCPQuorumSet qset, const ref map!(NodeID, SCPEnvelope) _map,
        const ref CPPDelegate!(bool function(const ref SCPStatement)) filter,
        const(NodeID)* excluded = null);

    // todo
    //Json::Value toJson (SCPQuorumSet const& qSet, bool fullKeys) const;
    //std::string to_string (SCPQuorumSet const& qSet) const;

    static uint64_t computeWeight(uint64_t m, uint64_t total, uint64_t threshold);

  protected:
    // returns a quorum set {{ nodeID }}
    static SCPQuorumSet buildSingletonQSet(const ref NodeID nodeID);

    // called recursively
    static bool isQuorumSliceInternal(const ref SCPQuorumSet qset,
                                      const ref vector!NodeID nodeSet);
    static bool isVBlockingInternal(const ref SCPQuorumSet qset,
                                    const ref vector!NodeID nodeSet);
}

static assert(LocalNode.sizeof == 184);
