/*******************************************************************************

    Contains unittest functions used for size checks of the D glue layer.

    Note: This is not part of Stellar SCP code.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

#include <vector>
#include <type_traits>
#include "xdrpp/marshal.h"
#include "xdrpp/types.h"
#include "xdr/Stellar-SCP.h"
#include "xdr/Stellar-types.h"
#include "scp/Slot.h"
#include "scp/SCPDriver.h"
#include "crypto/ByteSlice.h"

using namespace xdr;
using namespace stellar;

/// note: can't use templates due to 'unsigned long long' mangling bug
#define CPPSIZEOF(T) unsigned long long cppSizeOf ( T &value ) { return sizeof(value); }

/// scpd.types.Stellar_SCP
CPPSIZEOF(Value)
CPPSIZEOF(SCPBallot)
CPPSIZEOF(SCPStatementType)
CPPSIZEOF(SCPNomination)
CPPSIZEOF(SCPStatement::_pledges_t::_prepare_t)
CPPSIZEOF(SCPStatement::_pledges_t::_confirm_t)
CPPSIZEOF(SCPStatement::_pledges_t::_externalize_t)
CPPSIZEOF(SCPStatement::_pledges_t)
CPPSIZEOF(SCPStatement)
CPPSIZEOF(SCPEnvelope)
CPPSIZEOF(SCPQuorumSet)

/// scpd.types.Stellar_types
CPPSIZEOF(Hash)
CPPSIZEOF(PublicKeyType)
CPPSIZEOF(PublicKey)
// Signature is removed because it is the same as Hash.
static_assert(std::is_same<Signature, Hash>::value, "Signature and Hash must be the same type");
CPPSIZEOF(ByteSlice)

// macros suck
#define COMMA ,

/// scpd.types.XDRBase
CPPSIZEOF(xarray<std::uint8_t COMMA 4>)
CPPSIZEOF(xvector<Value>)
CPPSIZEOF(xvector<PublicKey>)
CPPSIZEOF(xvector<SCPQuorumSet>)

CPPSIZEOF(LocalNode)
CPPSIZEOF(BallotProtocol)
CPPSIZEOF(NominationProtocol)
CPPSIZEOF(SCP)
CPPSIZEOF(Slot)
CPPSIZEOF(BallotProtocol::SCPBallotWrapper)
CPPSIZEOF(SCPEnvelopeWrapper)
CPPSIZEOF(ValueWrapper)
CPPSIZEOF(ValueWrapperPtr)
CPPSIZEOF(ValueWrapperPtrSet)
