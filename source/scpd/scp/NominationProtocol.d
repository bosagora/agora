/*******************************************************************************

    Bindings for scp/NominationProtocol.h

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.scp.NominationProtocol;

import scpd.scp.SCPDriver;
import scpd.scp.SCP;
import scpd.scp.Slot;

import scpd.Cpp;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types;
import scpd.types.XDRBase;

import core.stdc.inttypes;

extern (C++, `stellar`):

extern(C++, class) public struct NominationProtocol
{
    Slot* mSlot;

    int32_t mRoundNumber;
    set!Value mVotes;                             // X
    set!Value mAccepted;                          // Y
    set!Value mCandidates;                        // Z
    map!(NodeID, SCPEnvelope) mLatestNominations; // N

    /// last envelope emitted by this node
    unique_ptr!SCPEnvelope mLastEnvelope;

    // nodes from quorum set that have the highest priority this round
    set!NodeID mRoundLeaders;

    // true if 'nominate' was called
    bool mNominationStarted;

    // the latest (if any) candidate value
    Value mLatestCompositeCandidate;

    // the value from the previous slot
    Value mPreviousValue;

    bool isNewerStatement(ref const(NodeID) nodeID, ref const(SCPNomination) st);
    static bool isNewerStatement(ref const(SCPNomination) oldst,
                                 ref const(SCPNomination) st);

    // returns true if 'p' is a subset of 'v'
    // also sets 'notEqual' if p and v differ
    // note: p and v must be sorted
    static bool isSubsetHelper(ref const(xvector!Value) p,
                               ref const(xvector!Value) v,
                               ref bool notEqual);

    SCPDriver.ValidationLevel validateValue(const ref Value v);
    Value extractValidValue(const ref Value value);

    bool isSane(const ref SCPStatement st);

    void recordEnvelope(const ref SCPEnvelope env);

    void emitNomination();

    // returns true if v is in the accepted list from the statement
    static bool acceptPredicate(const ref Value v, const ref SCPStatement st);

    // applies 'processor' to all values from the passed in nomination
    // static void applyAll(const ref SCPNomination nom,
    //                      std::function<void(Value const&)> processor);

    // updates the set of nodes that have priority over the others
    void updateRoundLeaders();

    // computes Gi(isPriority?P:N, prevValue, mRoundNumber, nodeID)
    // from the paper
    uint64_t hashNode(bool isPriority, const ref NodeID nodeID);

    // computes Gi(K, prevValue, mRoundNumber, value)
    uint64_t hashValue(const ref Value value);

    uint64_t getNodePriority(const ref NodeID nodeID, const ref SCPQuorumSet qset);

    // returns the highest value that we don't have yet, that we should
    // vote for, extracted from a nomination.
    // returns the empty value if no new value was found
    Value getNewValueFromNomination(const ref SCPNomination nom);

  public:
    //this(ref Slot slot);

    SCP.EnvelopeState processEnvelope(const ref SCPEnvelope envelope);

    static vector!Value getStatementValues(const ref SCPStatement st);

    // attempts to nominate a value for consensus
    bool nominate(const ref Value value, const ref Value previousValue,
                  bool timedout);

    // stops the nomination protocol
    void stopNomination();

    void setStateFromEnvelope(const ref SCPEnvelope e);

    vector!SCPEnvelope getCurrentState() const;
}

static assert(NominationProtocol.sizeof == 200);
