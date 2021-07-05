/*******************************************************************************

    Bindings for scp/SCPDriver.h, the class to derive to implement the SCP
    protocol

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.scp.SCPDriver;

import scpd.Cpp;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types;
import scpd.types.XDRBase;

import core.stdc.inttypes;

extern(C++, `stellar`):

extern (C++, class) public struct ValueWrapper
{
extern(C++):
    mixin NonMovableOrCopyable!();

    const Value value;

  public:
    this(const ref Value e);
    ~this();

    ref const(Value) getValue() const;
}

alias ValueWrapperPtr = shared_ptr!ValueWrapper;

extern (C++, class) public struct SCPEnvelopeWrapper
{
extern(C++):
    mixin NonMovableOrCopyable!();

    const SCPEnvelope mEnvelope;

  public:
    this(const ref SCPEnvelope e);
    ~this();

    ref const(SCPEnvelope) getEnvelope() const;
    ref const(SCPStatement) getStatement() const;
}

alias SCPEnvelopeWrapperPtr = shared_ptr!SCPEnvelopeWrapper;

extern (C++, class) public struct WrappedValuePtrComparator
{
extern(C++):
    bool opCall()(ref const(ValueWrapperPtr) l, ref const(ValueWrapperPtr) r) const;
}

alias ValueWrapperPtrSet = set!(ValueWrapperPtr, WrappedValuePtrComparator);

public abstract class SCPDriver
{
nothrow:
    ~this() {}

    // Envelope signature/verification
    abstract void signEnvelope(ref SCPEnvelope envelope);

    // SCPEnvelopeWrapper factory
    SCPEnvelopeWrapperPtr wrapEnvelope(ref const(SCPEnvelope) envelope);

    // ValueWrapperPtr factory
    ValueWrapperPtr wrapValue(ref const(Value) value);

    // Delegates the retrieval of the quorum set designated by `qSetHash` to
    // the user of SCP.
    abstract SCPQuorumSetPtr getQSet(ref const(Hash) qSetHash);

    // Users of the SCP library should inherit from SCPDriver and implement the
    // virtual methods which are called by the SCP implementation to
    // abstract the transport layer used from the implementation of the SCP
    // protocol.

    // Delegates the emission of an SCPEnvelope to the user of SCP. Envelopes
    // should be flooded to the network.
    abstract void emitEnvelope(ref const(SCPEnvelope) envelope);

    // methods to hand over the validation and ordering of values and ballots.

    // `validateValue` is called on each message received before any processing
    // is done. It should be used to filter out values that are not compatible
    // with the current state of that node. Unvalidated values can never
    // externalize.
    // If the value cannot be validated (node is missing some context) but
    // passes
    // the validity checks, kMaybeValidValue can be returned. This will cause
    // the current slot to be marked as a non validating slot: the local node
    // will abstain from emiting its position.
    // validation can be *more* restrictive during nomination as needed
    enum ValidationLevel
    {
        kInvalidValue = 0,       // value is invalid for sure
        kMaybeValidValue = 1,    // value may be valid
        kFullyValidatedValue = 2 // value is valid for sure
    }
    ValidationLevel validateValue(uint64_t slotIndex, ref const(Value) value, bool nomination);

    // `extractValidValue` transforms the value, if possible to a different
    // value that the local node would agree to (fully validated).
    // This is used during nomination when encountering an invalid value (ie
    // validateValue did not return `kFullyValidatedValue` for this value).
    // returning Value() means no valid value could be extracted
    ValueWrapperPtr extractValidValue(uint64_t slotIndex, ref const(Value) value);

    // `getValueString` is used for debugging
    // default implementation is the hash of the value
    std_string getValueString(ref const(Value) v) const
    {
        import agora.crypto.Hash;
        try
            return std_string(v.hashFull().toString());
        catch (Exception exc)
        {
            scope (failure) assert(0);
            return std_string("SCPDriver.getValueString() threw an Exception");
        }
    }

    // `toStrKey` returns StrKey encoded string representation
    std_string toStrKey(ref const(NodeID) pk, bool fullKey = true) const
    {
        try
            return std_string(Hash(pk).toString());
        catch (Exception exc)
        {
            scope (failure) assert(0);
            return std_string("SCPDriver.toStrKey() threw an Exception");
        }
    }

    // `toShortString` converts to the common name of a key if found
    std_string toShortString(ref const(NodeID) pk) const
    {
        import agora.crypto.Key : PublicKey;
        try
            return std_string(Hash(pk).toString());
        catch (Exception exc)
        {
            scope (failure) assert(0);
            return std_string("SCPDriver.toShortString() threw an Exception");
        }
    }

    // `getHashOf` computes the hash for the given vector of byte vector
    abstract Hash getHashOf(ref vector!Value vals) const;

    // Agora: routing through xdr_to_opaque to get the same hashing behavior
    Hash getHashOfQuorum(ref const(SCPQuorumSet) qSet) const @trusted;

    // `computeHashNode` is used by the nomination protocol to
    // randomize the order of messages between nodes.
    uint64_t computeHashNode(uint64_t slotIndex, ref const(Value) prev,
                           bool isPriority, int32_t roundNumber,
                           ref const(NodeID) nodeID);

    // `computeValueHash` is used by the nomination protocol to
    // randomize the relative order between values.
    uint64_t computeValueHash(uint64_t slotIndex, ref const(Value) prev,
                            int32_t roundNumber, ref const(Value) value);

    // `combineCandidates` computes the composite value based off a list
    // of candidate values.
    abstract ValueWrapperPtr combineCandidates(
        uint64_t slotIndex, ref const(ValueWrapperPtrSet) candidates);

    // `setupTimer`: requests to trigger 'cb' after timeout
    // if cb is nullptr, the timer is cancelled
    abstract void setupTimer(ulong slotIndex, int timerID,
                             milliseconds timeout,
                             CPPDelegate!(void function())*);

    // `computeTimeout` computes a timeout given a round number
    // it should be sufficiently large such that nodes in a
    // quorum can exchange 4 messages
    version (Windows)
    {
        // TODO Temporary action due to MSVC mangling problem
        // https://issues.dlang.org/show_bug.cgi?id=20700
        pragma(mangle, `?computeTimeout@SCPDriver@stellar@@UEAA?AV?$duration@_JU?$ratio@$00$0DOI@@std@@@chrono@std@@I@Z`)
        milliseconds computeTimeout(uint32_t roundNumber);  // Slot in the vtable
    }
    else
    {
        milliseconds computeTimeout(uint32_t roundNumber);  // Slot in the vtable
    }
    // Inform about events happening within the consensus algorithm.

    // `valueExternalized` is called at most once per slot when the slot
    // externalize its value.
    void valueExternalized(uint64_t slotIndex, ref const(Value) value);

    // ``nominatingValue`` is called every time the local instance nominates
    // a new value.
    void nominatingValue(uint64_t slotIndex, ref const(Value) value);

    // the following methods are used for monitoring of the SCP subsystem
    // most implementation don't really need to do anything with these

    // `updatedCandidateValue` is called every time a new candidate value
    // is included in the candidate set, the value passed in is
    // a composite value
    void updatedCandidateValue(uint64_t slotIndex, ref const(Value) value);

    // `startedBallotProtocol` is called when the ballot protocol is started
    // (ie attempts to prepare a new ballot)
    void startedBallotProtocol(uint64_t slotIndex, ref const(SCPBallot) ballot);

    // `acceptedBallotPrepared` every time a ballot is accepted as prepared
    void acceptedBallotPrepared(uint64_t slotIndex, ref const(SCPBallot) ballot);

    // `confirmedBallotPrepared` every time a ballot is confirmed prepared
    void confirmedBallotPrepared(uint64_t slotIndex, ref const(SCPBallot) ballot);

    // `acceptedCommit` every time a ballot is accepted commit
    void acceptedCommit(uint64_t slotIndex, ref const(SCPBallot) ballot);

    // `ballotDidHearFromQuorum` is called when we received messages related to
    // the current `mBallot` from a set of node that is a transitive quorum for
    // the local node.
    void ballotDidHearFromQuorum(uint64_t slotIndex, ref const(SCPBallot) ballot);
}

static assert(__traits(classInstanceSize, SCPDriver) == 8);
