/*******************************************************************************

    Bindings for scp/BallotProtocol.h

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.scp.BallotProtocol;

import scpd.scp.LocalNode;
import scpd.scp.SCPDriver;
import scpd.scp.SCP;
import scpd.scp.Slot;

import scpd.Cpp;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types;
import scpd.types.XDRBase;

import core.stdc.inttypes;

extern (C++, `stellar`):

// Need to bind std::function
version (none)
{
    // used to filter statements and check how typedef mangles
    // typedef std::function<bool(SCPStatement const& st)> StatementPredicate;
}

/**
 * The Slot object is in charge of maintaining the state of the SCP protocol
 * for a given slot index.
 *
 * Defined as a struct to have the right size (`class` always have a vtable)
 */
extern(C++, class) public struct BallotProtocol
{
    Slot* mSlot;

    bool mHeardFromQuorum;

    // state tracking members
    enum SCPPhase
    {
        SCP_PHASE_PREPARE,
        SCP_PHASE_CONFIRM,
        SCP_PHASE_EXTERNALIZE,
        SCP_PHASE_NUM
    }
    // human readable names matching SCPPhase
    extern __gshared const(char*)[SCPPhase.max] phaseNames;

    unique_ptr!SCPBallot mCurrentBallot;      // b
    unique_ptr!SCPBallot mPrepared;           // p
    unique_ptr!SCPBallot mPreparedPrime;      // p'
    unique_ptr!SCPBallot mHighBallot;         // h
    unique_ptr!SCPBallot mCommit;             // c
    map!(NodeID, SCPEnvelope) mLatestEnvelopes; // M
    SCPPhase mPhase;                            // Phi
    unique_ptr!Value mValueOverride;            // z

    int mCurrentMessageLevel; // number of messages triggered in one run

    /// last envelope generated by this node
    shared_ptr!SCPEnvelope mLastEnvelope;

    /// last envelope emitted by this node
    shared_ptr!SCPEnvelope mLastEnvelopeEmit;

  public:
    /// Construct a new entity linked to a Slot
    this(ref Slot slot);

    // Process a newly received envelope for this slot and update the state of
    // the slot accordingly.
    // self: set to true when node feeds its own statements in order to
    // trigger more potential state changes
    SCP.EnvelopeState processEnvelope(const ref SCPEnvelope envelope, bool self);

    void ballotProtocolTimerExpired();
    // abandon's current ballot, move to a new ballot
    // at counter `n` (or, if n == 0, increment current counter)
    bool abandonBallot(uint32_t n);

    // bumps the ballot based on the local state and the value passed in:
    // in prepare phase, attempts to take value
    // otherwise, no-ops
    // force: when true, always bumps the value, otherwise only bumps
    // the state if no value was prepared
    bool bumpState(const ref Value value, bool force);
    // flavor that takes the actual desired counter value
    bool bumpState(const ref Value value, uint32_t n);

    // ** status methods

    // returns information about the local state in JSON format
    // including historical statements if available
    //Json::Value getJsonInfo();
    void* getJsonInfo();

    // returns information about the quorum for a given node
    //Json::Value getJsonQuorumInfo(NodeID const& id, bool summary,
    //                              bool fullKeys = false);
    void* getJsonQuorumInfo(ref const(NodeID)  id, bool summary,
        bool fullKeys = false);

    // returns the hash of the QuorumSet that should be downloaded
    // with the statement.
    // note: the companion hash for an EXTERNALIZE statement does
    // not match the hash of the QSet, but the hash of commitQuorumSetHash
    static Hash getCompanionQuorumSetHashFromStatement(const ref SCPStatement st);

    // helper function to retrieve b for PREPARE, P for CONFIRM or
    // c for EXTERNALIZE messages
    static SCPBallot getWorkingBallot(const ref SCPStatement st);

    SCPEnvelope* getLastMessageSend() const;

    void setStateFromEnvelope(const ref SCPEnvelope e);

    vector!SCPEnvelope getCurrentState() const;

    // returns the latest message from a node
    // or null if not found
    const(SCPEnvelope)* getLatestMessage(ref const(NodeID) id) const;

    vector!SCPEnvelope getExternalizingState() const;

  private:
    // attempts to make progress using the latest statement as a hint
    // calls into the various attempt* methods, emits message
    // to make progress
    void advanceSlot(const ref SCPStatement hint);

    // returns true if all values in statement are valid
    SCPDriver.ValidationLevel validateValues(const ref SCPStatement st);

    // send latest envelope if needed
    void sendLatestEnvelope();

    // `attempt*` methods are called by `advanceSlot` internally call the
    //  the `set*` methods.
    //   * check if the specified state for the current slot has been
    //     reached or not.
    //   * idempotent
    //  input: latest statement received (used as a hint to reduce the
    //  space to explore)
    //  output: returns true if the state was updated

    // `set*` methods progress the slot to the specified state
    //  input: state specific
    //  output: returns true if the state was updated.

    // step 1 and 5 from the SCP paper
    bool attemptPreparedAccept(const ref SCPStatement hint);
    // prepared: ballot that should be prepared
    bool setPreparedAccept(const ref SCPBallot prepared);

    // step 2+3+8 from the SCP paper
    // ballot is the candidate to record as 'confirmed prepared'
    bool attemptPreparedConfirmed(const ref SCPStatement hint);
    // newC, newH : low/high bounds prepared confirmed
    bool setPreparedConfirmed(const ref SCPBallot newC, const ref SCPBallot newH);

    // step (4 and 6)+8 from the SCP paper
    bool attemptAcceptCommit(const ref SCPStatement hint);
    // new values for c and h
    bool setAcceptCommit(const ref SCPBallot c, const ref SCPBallot h);

    // step 7+8 from the SCP paper
    bool attemptConfirmCommit(const ref SCPStatement hint);
    bool setConfirmCommit(const ref SCPBallot acceptCommitLow,
                          const ref SCPBallot acceptCommitHigh);

    // step 9 from the SCP paper
    bool attemptBump();

    // computes a list of candidate values that may have been prepared
    set!SCPBallot getPrepareCandidates(const ref SCPStatement hint);

    // helper to perform step (8) from the paper
    bool updateCurrentIfNeeded(const ref SCPBallot h);

    // Not needed ATM
    version (none)
    {
        // An interval is [low,high] represented as a pair
        alias Interval = pair!(uint32, uint32);

        // helper function to find a contiguous range 'candidate' that satisfies the
        // predicate.
        // updates 'candidate' (or leave it unchanged)
        static void findExtendedInterval(ref Interval candidate,
                                         const ref set!uint32 boundaries,
                                         std_function!(bool function(const ref Interval)) pred);
    }

    // constructs the set of counters representing the
    // commit ballots compatible with the ballot
    set!uint getCommitBoundariesFromStatements(const ref SCPBallot ballot);

    // ** helper predicates that evaluate if a statement satisfies
    // a certain property

    // is ballot prepared by st
    static bool hasPreparedBallot(const ref SCPBallot ballot,
                                  const ref SCPStatement st);

    // need to bind std::pair
    version (none)
    {
        // returns true if the statement commits the ballot in the range 'check'
        static bool commitPredicate(const ref SCPBallot ballot,
                                    const ref Interval check,
                                    const ref SCPStatement st);
    }

    // attempts to update p to ballot (updating p' if needed)
    bool setPrepared(const ref SCPBallot ballot);

    // ** Helper methods to compare two ballots

    // ballot comparison (ordering)
    static int compareBallots(const ref unique_ptr!SCPBallot b1,
                              const ref unique_ptr!SCPBallot b2);

    // b1 ~ b2
    static bool areBallotsCompatible(const ref SCPBallot b1, const ref SCPBallot b2);

    // b1 <= b2 && b1 !~ b2
    static bool areBallotsLessAndIncompatible(const ref SCPBallot b1,
                                              const ref SCPBallot b2);
    // b1 <= b2 && b1 ~ b2
    static bool areBallotsLessAndCompatible(const ref SCPBallot b1,
                                            const ref SCPBallot b2);

    // ** statement helper functions

    // returns true if the statement is newer than the one we know about
    // for a given node.
    bool isNewerStatement(const ref NodeID nodeID, const ref SCPStatement st);

    // returns true if st is newer than oldst
    static bool isNewerStatement(const ref SCPStatement oldst,
                                 const ref SCPStatement st);

    // basic sanity check on statement
    bool isStatementSane(const ref SCPStatement st, bool self);

    // records the statement in the state machine
    void recordEnvelope(const ref SCPEnvelope env);

    // ** State related methods

    // helper function that updates the current ballot
    // this is the lowest level method to update the current ballot and as
    // such doesn't do any validation
    // check: verifies that ballot is greater than old one
    void bumpToBallot(const ref SCPBallot ballot, bool check);

    // switch the local node to the given ballot's value
    // with the assumption that the ballot is more recent than the one
    // we have.
    bool updateCurrentValue(const ref SCPBallot ballot);

    // emits a statement reflecting the nodes' current state
    // and attempts to make progress
    void emitCurrentStateStatement();

    // verifies that the internal state is consistent
    void checkInvariants();

    // create a statement of the given type using the local state
    SCPStatement createStatement(const ref SCPStatementType type);

    // returns a string representing the slot's state
    // used for log lines
    version (none)
    std_string getLocalState() const;

    shared_ptr!LocalNode getLocalNode();

    // Need to bind std::function
    version (none)
    {
        bool federatedAccept(StatementPredicate voted, StatementPredicate accepted);
        bool federatedRatify(StatementPredicate voted);
    }

    void startBallotProtocolTimer();
    void stopBallotProtocolTimer();
    void checkHeardFromQuorum();
}

static assert(BallotProtocol.sizeof == 136);
