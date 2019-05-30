// Copyright Mathias Lang
// Not originally part of SCP but required for the D side to work

#include <vector>
#include "xdrpp/marshal.h"
#include "xdr/Stellar-SCP.h"
#include "scp/Slot.h"

using namespace xdr;
using namespace stellar;

SCP* createSCP(SCPDriver* driver, NodeID const& nodeID, bool isValidator, SCPQuorumSet const& qSetLocal)
{
    return new stellar::SCP(*driver, nodeID, isValidator, qSetLocal);
}

// Not in a namespace because it triggers a DMD bug
//namespace stellar

template<typename T, typename VectorT>
void push_back(VectorT& this_, T& value)
{
    this_.push_back(value);
}

template<typename VectorT>
VectorT duplicate(const VectorT& this_)
{
    VectorT dup = VectorT(this_);
    return dup;
}

opaque_vec<> XDRToOpaque(const xdr::xvector<unsigned char>& param)
{
    return xdr::xdr_to_opaque(param);
}
opaque_vec<> XDRToOpaque(const stellar::SCPQuorumSet& param)
{
    return xdr::xdr_to_opaque(param);
}

#define PUSHBACKINST1(T) template void push_back<T, xvector<T>>(xvector<T>&, T&);
#define PUSHBACKINST2(T, VT) template void push_back<T, VT>(VT&, T&);
#define PUSHBACKINST3(T, V) template void push_back<T, V<T>>(V<T>&, T&);

PUSHBACKINST2(const PublicKey, xvector<PublicKey>)
PUSHBACKINST3(xvector<unsigned char>, std::vector)
PUSHBACKINST3(unsigned char, std::vector)

PUSHBACKINST1(unsigned char)
PUSHBACKINST1(xvector<unsigned char>)

PUSHBACKINST1(PublicKey)
PUSHBACKINST3(PublicKey, std::vector)
PUSHBACKINST3(SCPEnvelope, std::vector)
PUSHBACKINST3(SCPQuorumSet, std::vector)
PUSHBACKINST3(Slot::HistoricalStatement, std::vector)

template opaque_vec<> duplicate<opaque_vec<>>(opaque_vec<> const&);
