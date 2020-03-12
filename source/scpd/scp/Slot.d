/*******************************************************************************

    Bindings for scp/Slot.h

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.scp.Slot;

import scpd.Cpp;
import scpd.scp.BallotProtocol;
import scpd.scp.NominationProtocol;
import scpd.scp.SCP;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types;
import scpd.types.XDRBase;

import core.stdc.inttypes;
import core.stdc.time;

extern(C++, `stellar`):

/**
 * The Slot object is in charge of maintaining the state of the SCP protocol
 * for a given slot index.
 */
extern(C++, class) public struct Slot //: public std::enable_shared_from_this<Slot>
{
private:
    /// Base class is `std::enable_shared_from_this` which contains
    /// a weak_ptr which is 2 ptrs
    void*[2] base_class_data;

    const uint64_t mSlotIndex; // the index this slot is tracking
    SCP* mSCP;

    BallotProtocol mBallotProtocol;
    NominationProtocol mNominationProtocol;

    // keeps track of all statements seen so far for this slot.
    // it is used for debugging purpose
    // https://issues.dlang.org/show_bug.cgi?id=20701
    extern(C++, struct) struct HistoricalStatement
    {
        time_t mWhen;
        SCPStatement mStatement;
        bool mValidated;
    }

    vector!HistoricalStatement mStatementsHistory;

    // true if the Slot was fully validated
    bool mFullyValidated;

  public:
    this(uint64_t slotIndex, ref SCP SCP);

    uint64_t getSlotIndex() const
    {
        return mSlotIndex;
    }

    ref const(Value) getLatestCompositeCandidate();

    // // returns the latest messages the slot emitted
    // vector!SCPEnvelope getLatestMessagesSend() const;

    // // forces the state to match the one in the envelope
    // // this is used when rebuilding the state after a crash for example
    void setStateFromEnvelope(ref const(SCPEnvelope) e);

    // returns the latest messages known for this slot
    vector!SCPEnvelope getCurrentState() const;

    // returns messages that helped this slot externalize
    vector!SCPEnvelope getExternalizingState() const;

    // records the statement in the historical record for this slot
    void recordStatement(const ref SCPStatement st);

    // Process a newly received envelope for this slot and update the state of
    // the slot accordingly.
    // self: set to true when node wants to record its own messages (potentially
    // triggering more transitions)
    SCP.EnvelopeState processEnvelope(ref const(SCPEnvelope) envelope, bool self);

    bool abandonBallot();

    // bumps the ballot based on the local state and the value passed in:
    // in prepare phase, attempts to take value
    // otherwise, no-ops
    // force: when true, always bumps the value, otherwise only bumps
    // the state if no value was prepared
    bool bumpState(const ref Value value, bool force);

    // // attempts to nominate a value for consensus
    bool nominate(ref const(Value) value, ref const(Value) previousValue,
                  bool timedout);

    void stopNomination();

    bool isFullyValidated() const;
    void setFullyValidated(bool fullyValidated);

    // // ** status methods

    enum timerIDs
    {
        NOMINATION_TIMER = 0,
        BALLOT_PROTOCOL_TIMER = 1
    }

  protected:
    vector!SCPEnvelope getEntireCurrentState();
}

static assert(Slot.sizeof == 400);
