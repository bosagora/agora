// Copyright Mathias Lang
// Not originally part of SCP but required for the D side to work

#include "DUtils.h"
#include "xdrpp/marshal.h"
#include "xdr/Stellar-SCP.h"
#include <functional>

using namespace xdr;
using namespace stellar;

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

PUSHBACKINST2(const PublicKey, xvector<PublicKey>)
PUSHBACKINST3(xvector<unsigned char>, std::vector)
PUSHBACKINST3(unsigned char, std::vector)

PUSHBACKINST1(unsigned char)
PUSHBACKINST1(xvector<unsigned char>)

PUSHBACKINST1(PublicKey)
PUSHBACKINST1(SCPQuorumSet)
PUSHBACKINST3(PublicKey, std::vector)
PUSHBACKINST3(SCPEnvelope, std::vector)
PUSHBACKINST3(SCPQuorumSet, std::vector)

template opaque_vec<> duplicate<opaque_vec<>>(opaque_vec<> const&);

#define CPPSETFOREACHINST(T) template int cpp_set_foreach<T>(void*, void*, void*);
CPPSETFOREACHINST(Value)
CPPSETFOREACHINST(SCPBallot)
CPPSETFOREACHINST(PublicKey)
CPPSETFOREACHINST(unsigned int)

#define CPPSETEMPTYINST(T) template bool cpp_set_empty<T>(const void*);
CPPSETEMPTYINST(Value)
CPPSETEMPTYINST(SCPBallot)
CPPSETEMPTYINST(PublicKey)
CPPSETEMPTYINST(unsigned int)

void callCPPDelegate (void* cb)
{
    auto callback = (std::function<void()>*)cb;
    (*callback)();
    delete callback;
}

std::shared_ptr<SCPQuorumSet> makeSharedSCPQuorumSet (
    SCPQuorumSet& quorum)
{
    return std::make_shared<SCPQuorumSet>(quorum);
}
