/*******************************************************************************

    Bindings for scp/SCP.h, the main class / entrypoint of the SCP protocol

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
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

public alias PCSCallback = extern(C++) bool function(ref const(SCPEnvelope));

public alias PSCallback = extern(C++) bool function(uint64_t);

shared static this ()
{
    initialize_byteslice_hasher();
}

extern(C++, `stellar`):

// needed for some utility hashing routines
extern(C++, `shortHash`) private void initialize_byteslice_hasher ();

// typedef std::shared_ptr<SCPQuorumSet> SCPQuorumSetPtr;

extern(C++, class) public struct SCP
{
    private SCPDriver mDriver;
    protected shared_ptr!LocalNode mLocalNode;
    protected map!(uint64_t, shared_ptr!Slot) mKnownSlots;
    /// Slot getter
    public inout(shared_ptr!Slot) getSlot(uint64_t slotIndex, bool create) inout;

nothrow:
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
    EnvelopeState receiveEnvelope(SCPEnvelopeWrapperPtr envelope);

    // Submit a value to consider for slotIndex
    // previousValue is the value from slotIndex-1
    bool nominate(uint64_t slotIndex, ValueWrapperPtr value,
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

    // returns if we received messages from a v-blocking set
    bool gotVBlocking(uint64_t slotIndex);

    // Helpers for monitoring and reporting the internal memory-usage of the SCP
    // protocol to system metric reporters.
    size_t getKnownSlotsCount() const;
    size_t getCumulativeStatemtCount() const;

    // returns the latest messages sent for the given slot
    vector!SCPEnvelope getLatestMessagesSend(uint64_t slotIndex);

    // forces the state to match the one in the envelope
    // this is used when rebuilding the state after a crash for example
    void setStateFromEnvelope(uint64_t slotIndex, SCPEnvelopeWrapperPtr e);

    // check if we are holding some slots
    bool empty() const;

    // invokes f for all latest messages
    // if forceSelf, return messages for self even if not fully validated
    // f returns false to stop processing, true otherwise
    void processCurrentState(uint64_t slotIndex,
                             ref const(CPPDelegate!PCSCallback) f,
                             bool forceSelf);

    // iterates through slots, starting from slot startIndex
    void processSlotsAscendingFrom(uint64_t startIndex,
                                   ref const(CPPDelegate!PSCallback) f);

    // iterates through slots, starting from slot startIndex
    void processSlotsDescendingFrom(uint64_t startIndex,
                                    ref const(CPPDelegate!PSCallback) f);

    // Recovered from previous SCP versions
    uint64_t getHighSlotIndex() const;

    // returns the latest message from a node
    // or null if not found
    const(SCPEnvelope)* getLatestMessage(ref const(NodeID) id);

    // returns messages that contributed to externalizing the slot
    // (or empty if the slot didn't externalize)
    vector!SCPEnvelope getExternalizingState(uint64_t slotIndex);
}

extern (D):
unittest
{
    assert(SCP.sizeof == getCPPSizeof!SCP());
}
