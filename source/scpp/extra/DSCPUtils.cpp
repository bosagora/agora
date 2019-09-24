// Copyright Mathias Lang
// Not originally part of SCP but required for the D side to work

#include "DUtils.h"
#include "xdrpp/marshal.h"
#include "xdr/Stellar-SCP.h"
#include "scp/Slot.h"

using namespace xdr;
using namespace stellar;

SCP* createSCP(SCPDriver* driver, NodeID const& nodeID, bool isValidator, SCPQuorumSet const& qSetLocal)
{
    return new stellar::SCP(*driver, nodeID, isValidator, qSetLocal);
}

#define PUSHBACKINST3(T, V) template void push_back<T, V<T>>(V<T>&, T&);
PUSHBACKINST3(Slot::HistoricalStatement, std::vector)
