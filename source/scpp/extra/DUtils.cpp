// Copyright Mathias Lang
// Not originally part of SCP but required for the D side to work

#include <functional>

#include "DUtils.h"
#include "quorum/QuorumTracker.h"
#include "quorum/QuorumIntersectionChecker.h"
#include "scp/BallotProtocol.h"
#include "scp/NominationProtocol.h"
#include "scp/SCP.h"
#include "scp/SCPDriver.h"
#include "scp/Slot.h"
#include "util/XDROperators.h"
#include "xdr/Stellar-SCP.h"
#include "xdrpp/marshal.h"

using namespace xdr;
using namespace stellar;

std::string sliceToStdString (char const* ptr, size_t length)
{
    return std::string(ptr, length);
}

std::set<unsigned int>* makeTestSet()
{
    std::set<unsigned int>* set = new std::set<unsigned int>({1, 2, 3, 4, 5});
    return set;
}

opaque_vec<> XDRToOpaque(const xdr::xvector<unsigned char>& param)
{
    return xdr::xdr_to_opaque(param);
}
opaque_vec<> XDRToOpaque(const stellar::SCPQuorumSet& param)
{
    return xdr::xdr_to_opaque(param);
}
opaque_vec<> XDRToOpaque(const stellar::SCPStatement& param)
{
    return xdr::xdr_to_opaque(param);
}

#define PUSHBACKINST1(T) template void push_back<T, xvector<T>>(xvector<T>&, T&);
#define PUSHBACKINST2(T, VT) template void push_back<T, VT>(VT&, T&);
#define PUSHBACKINST3(T, V) template void push_back<T, V<T>>(V<T>&, T&);

PUSHBACKINST2(const NodeID, xvector<NodeID>)
PUSHBACKINST3(xvector<unsigned char>, std::vector)
PUSHBACKINST3(unsigned char, std::vector)

PUSHBACKINST1(unsigned char)
// Workarounds for Dlang issue #20805
#if MSVC
void push_back_vec (void *this_, void const *value_)
{
    auto value = (xvector<unsigned char>*)value_;
    auto this_obj = (xvector<xvector<unsigned char> >*)this_;
    (*this_obj).push_back(*value);
}
PUSHBACKINST1(xvector<unsigned char>)
#else // !MSVC
PUSHBACKINST1(xvector<unsigned char>)
#endif // !MSVC

opaque_vec<> duplicate_value (void const *value_)
{
    auto value = (xvector<unsigned char>*)value_;
    opaque_vec<> dup = opaque_vec<>(*value);
    return dup;
}

PUSHBACKINST1(NodeID)
PUSHBACKINST1(SCPQuorumSet)
PUSHBACKINST3(NodeID, std::vector)
PUSHBACKINST3(SCPEnvelope, std::vector)
PUSHBACKINST3(SCPQuorumSet, std::vector)

#define CPPSETFOREACHINST(T) template int cpp_set_foreach<T>(void*, void*, void*);
CPPSETFOREACHINST(int)
CPPSETFOREACHINST(Value)
CPPSETFOREACHINST(ValueWrapperPtr)
CPPSETFOREACHINST(SCPBallot)
CPPSETFOREACHINST(NodeID)
CPPSETFOREACHINST(unsigned int)

#define CPPSETEMPTYINST(T) template bool cpp_set_empty<T>(const void*);
CPPSETEMPTYINST(int)
CPPSETEMPTYINST(Value)
CPPSETEMPTYINST(ValueWrapperPtr)
CPPSETEMPTYINST(SCPBallot)
CPPSETEMPTYINST(NodeID)
CPPSETEMPTYINST(unsigned int)

#define CPPUNORDEREDMAPASSIGNINST(K, V) template void cpp_unordered_map_assign<K, V>(void*, const K&, const V&);
CPPUNORDEREDMAPASSIGNINST(NodeID, std::shared_ptr<SCPQuorumSet>)
CPPUNORDEREDMAPASSIGNINST(NodeID, QuorumTracker::NodeInfo)
CPPUNORDEREDMAPASSIGNINST(int, int)

#define CPPUNORDEREDMAPLENGTHINST(K, V) template std::size_t cpp_unordered_map_length<K, V>(const void*);
CPPUNORDEREDMAPLENGTHINST(NodeID, std::shared_ptr<SCPQuorumSet>)
CPPUNORDEREDMAPLENGTHINST(NodeID, QuorumTracker::NodeInfo)
CPPUNORDEREDMAPLENGTHINST(int, int)

void callCPPDelegate (void* cb)
{
    auto callback = (std::function<void()>*)cb;
    (*callback)();
    delete callback;
}

std::shared_ptr<SCPQuorumSet> makeSharedSCPQuorumSet (
    const SCPQuorumSet& quorum)
{
    return std::make_shared<SCPQuorumSet>(quorum);
}

#define CPPDEFAULTCTORINST(T) template void defaultCtorCPPObject<T>(T*);
#define CPPDTORINST(T) template void dtorCPPObject<T>(T*);
#define CPPSIZEOFINST(T) template int getCPPSizeof<T>();
#define CPPASSIGNINST(T) template void opAssignCPPObject<T> (T* lhs, T* rhs);
#define CPPCOPYCTORINST(T) template void copyCtorCPPObject<T> (T* ptr, T* rhs);
CPPSIZEOFINST(QuorumTracker);
CPPSIZEOFINST(Slot);
CPPSIZEOFINST(NominationProtocol);
CPPSIZEOFINST(SCP);
CPPSIZEOFINST(BallotProtocol);

#define CPPOBJECTINST(T) CPPDEFAULTCTORINST(T) \
                         CPPDTORINST(T)        \
                         CPPSIZEOFINST(T)      \
                         CPPASSIGNINST(T)      \
                         CPPCOPYCTORINST(T)
CPPOBJECTINST(std::shared_ptr<int>);
CPPOBJECTINST(std::shared_ptr<SCPQuorumSet>);
CPPOBJECTINST(std::shared_ptr<SCPEnvelope>);
CPPOBJECTINST(std::shared_ptr<Slot>);
CPPOBJECTINST(std::shared_ptr<LocalNode>);
CPPOBJECTINST(std::shared_ptr<QuorumIntersectionChecker*>);
CPPOBJECTINST(std::shared_ptr<ValueWrapper>);
CPPOBJECTINST(std::shared_ptr<SCPEnvelopeWrapper>);

CPPOBJECTINST(std::set<int>);
CPPOBJECTINST(std::set<Value>);
CPPOBJECTINST(std::set<NodeID>);
CPPOBJECTINST(std::set<SCPBallot>);
CPPOBJECTINST(std::set<unsigned int>);

#define CPPUNIQUEPTRINST(T) CPPDEFAULTCTORINST(std::unique_ptr<T>) \
                            CPPDTORINST(std::unique_ptr<T>)        \
                            CPPSIZEOFINST(std::unique_ptr<T>)
CPPUNIQUEPTRINST(SCPEnvelope);
CPPUNIQUEPTRINST(SCPBallot);
CPPUNIQUEPTRINST(Value);
CPPUNIQUEPTRINST(stellar::BallotProtocol::SCPBallotWrapper);

#define CPPUNORDEREDMAPINST(K, V, id)   typedef std::unordered_map<K, V> ump_type_##id;  \
                                        CPPOBJECTINST(ump_type_##id);
CPPUNORDEREDMAPINST(NodeID, std::shared_ptr<SCPQuorumSet>, 0)
CPPUNORDEREDMAPINST(int, int, 1)

#define CPPMAPINST(K, V, id)   typedef std::map<K, V> map_type_##id;  \
                                CPPOBJECTINST(map_type_##id);
CPPMAPINST(int, int, 0)
CPPMAPINST(NodeID, SCPEnvelope, 1)
CPPMAPINST(uint64_t, std::shared_ptr<Slot>, 2)
CPPMAPINST(stellar::NodeID, std::shared_ptr<SCPEnvelopeWrapper>, 3)

#define CPPUNORDEREDMAPRANDHASHINST(K, V, id)   typedef std::unordered_map<K, V, stellar::RandHasher<K, std::hash<K > > > rand_map_type_##id;  \
                                CPPOBJECTINST(rand_map_type_##id);


CPPUNORDEREDMAPRANDHASHINST(int, int, 0);
CPPUNORDEREDMAPRANDHASHINST(stellar::NodeID, stellar::QuorumTracker::NodeInfo, 1);

// typedef std::set<ValueWrapperPtr, WrappedValuePtrComparator*> ValueWrapperPtrSet2;

CPPDEFAULTCTORINST(ValueWrapperPtrSet);
CPPDTORINST(ValueWrapperPtrSet);
CPPCOPYCTORINST(ValueWrapperPtrSet);
