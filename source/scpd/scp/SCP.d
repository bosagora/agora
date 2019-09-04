/*******************************************************************************

    Bindings for scp/SCP.h, the main class / entrypoint of the SCP protocol

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.scp.SCP;

import scpd.scp.LocalNode;
import scpd.scp.SCPDriver;
import scpd.scp.Slot;

import scpd.Cpp;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types;
import scpd.types.XDRBase;

import core.stdc.inttypes;

extern(C++, `stellar`):

// typedef std::shared_ptr<SCPQuorumSet> SCPQuorumSetPtr;

extern(C++, class) public struct SCP
{
    private SCPDriver mDriver;
    protected shared_ptr!LocalNode mLocalNode;
    protected map!(uint64_t, shared_ptr!Slot) mKnownSlots;
    /// Slot getter
    public inout(shared_ptr!Slot) getSlot(uint64_t slotIndex, bool create) inout;

    /*
      Cannot have class ref in D, so it was modified to a class pointer
    SCP(SCPDriver& driver, NodeID const& nodeID, bool isValidator,
        SCPQuorumSet const& qSetLocal);
    */
    this(SCPDriver driver, ref const(NodeID) nodeID, bool isValidator,
         ref const(SCPQuorumSet) qSetLocal);

    enum EnvelopeState
    {
        INVALID, // the envelope is considered invalid
        VALID    // the envelope is valid
    }

    enum TriBool
    {
        TB_TRUE,
        TB_FALSE,
        TB_MAYBE
    }

    // this is the main entry point of the SCP library
    // it processes the envelope, updates the internal state and
    // invokes the appropriate methods
    EnvelopeState receiveEnvelope(ref const(SCPEnvelope) envelope);

    // Submit a value to consider for slotIndex
    // previousValue is the value from slotIndex-1
    bool nominate(uint64_t slotIndex, ref const(Value) value,
                        ref const(Value) previousValue);

    // stops nomination for a slot
    void stopNomination(uint64_t slotIndex);

    // Local QuorumSet interface (can be dynamically updated)
    void updateLocalQuorumSet(ref const(SCPQuorumSet) qSet);
    ref const(SCPQuorumSet) getLocalQuorumSet();

    // Local nodeID getter
    ref const(NodeID) getLocalNodeID();

    // returns the local node descriptor
    //std::shared_ptr<LocalNode> getLocalNode();
    shared_ptr!LocalNode getLocalNode();

    // Purges all data relative to all the slots whose slotIndex is smaller
    // than the specified `maxSlotIndex`.
    void purgeSlots(uint64_t maxSlotIndex);

    // Returns whether the local node is a validator.
    bool isValidator();

    // returns the validation state of the given slot
    bool isSlotFullyValidated(uint64_t slotIndex);

    // Helpers for monitoring and reporting the internal memory-usage of the SCP
    // protocol to system metric reporters.
    size_t getKnownSlotsCount() const;
    size_t getCumulativeStatemtCount() const;

    // returns the latest messages sent for the given slot
    vector!SCPEnvelope getLatestMessagesSend(uint64_t slotIndex);

    // forces the state to match the one in the envelope
    // this is used when rebuilding the state after a crash for example
    void setStateFromEnvelope(uint64_t slotIndex, ref const(SCPEnvelope) e);

    // check if we are holding some slots
    bool empty() const;
    // return lowest slot index value
    uint64_t getLowSlotIndex() const;
    // return highest slot index value
    uint64_t getHighSlotIndex() const;

    // returns all messages for the slot
    vector!SCPEnvelope getCurrentState(uint64_t slotIndex);

    // returns messages that contributed to externalizing the slot
    // (or empty if the slot didn't externalize)
    vector!SCPEnvelope getExternalizingState(uint64_t slotIndex);

    // returns if a node is in the (transitive) quorum originating at
    // the local node, scanning the known slots.
    // TB_TRUE iff n is in the quorum
    // TB_FALSE iff n is not in the quorum
    // TB_MAYBE iff the quorum cannot be computed
    TriBool isNodeInQuorum(ref const(NodeID) node);
}

static assert(SCP.sizeof == 48);
