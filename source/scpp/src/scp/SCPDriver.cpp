// Copyright 2014 Stellar Development Foundation and contributors. Licensed
// under the Apache License, Version 2.0. See the COPYING file at the root
// of this distribution or at http://www.apache.org/licenses/LICENSE-2.0

#include "SCPDriver.h"

#include <algorithm>

#include "crypto/Hex.h"
#include "crypto/KeyUtils.h"
#include "crypto/SHA.h"
#include "crypto/SecretKey.h"
#include "xdrpp/marshal.h"

namespace stellar
{

std::string
SCPDriver::getValueString(Value const& v) const
{
    uint512 valueHash = sha512(xdr::xdr_to_opaque(v));

    return hexAbbrev(valueHash);
}

std::string
SCPDriver::toStrKey(PublicKey const& pk, bool fullKey) const
{
    return fullKey ? KeyUtils::toStrKey(pk) : toShortString(pk);
}

std::string
SCPDriver::toShortString(PublicKey const& pk) const
{
    return KeyUtils::toShortString(pk);
}

// values used to switch hash function between priority and neighborhood checks
static const uint32 hash_N = 1;
static const uint32 hash_P = 2;
static const uint32 hash_K = 3;

static uint64
hashHelper(uint64 slotIndex, Value const& prev,
           std::function<void(SHA512*)> extra)
{
    auto h = SHA512::create();
    h->add(xdr::xdr_to_opaque(slotIndex));
    h->add(xdr::xdr_to_opaque(prev));
    extra(h.get());
    uint512 t = h->finish();
    uint64 res = 0;
    for (size_t i = 0; i < sizeof(res); i++)
    {
        res = (res << 8) | t[i];
    }
    return res;
}

uint64
SCPDriver::computeHashNode(uint64 slotIndex, Value const& prev, bool isPriority,
                           int32_t roundNumber, NodeID const& nodeID)
{
    return hashHelper(slotIndex, prev, [&](SHA512* h) {
        h->add(xdr::xdr_to_opaque(isPriority ? hash_P : hash_N));
        h->add(xdr::xdr_to_opaque(roundNumber));
        h->add(xdr::xdr_to_opaque(nodeID));
    });
}

uint64
SCPDriver::computeValueHash(uint64 slotIndex, Value const& prev,
                            int32_t roundNumber, Value const& value)
{
    return hashHelper(slotIndex, prev, [&](SHA512* h) {
        h->add(xdr::xdr_to_opaque(hash_K));
        h->add(xdr::xdr_to_opaque(roundNumber));
        h->add(xdr::xdr_to_opaque(value));
    });
}

static const int MAX_TIMEOUT_SECONDS = (30 * 60);

std::chrono::milliseconds
SCPDriver::computeTimeout(uint32 roundNumber)
{
    // straight linear timeout
    // starting at 1 second and capping at MAX_TIMEOUT_SECONDS

    int timeoutInSeconds;
    if (roundNumber > MAX_TIMEOUT_SECONDS)
    {
        timeoutInSeconds = MAX_TIMEOUT_SECONDS;
    }
    else
    {
        timeoutInSeconds = (int)roundNumber;
    }
    return std::chrono::seconds(timeoutInSeconds);
}

Value SCPDriver::extractValidValue(uint64 slotIndex, Value const& value)
{
    return Value();
}

void SCPDriver::nominatingValue(uint64 slotIndex, Value const& value)
{
}

void SCPDriver::updatedCandidateValue(uint64 slotIndex, Value const& value)
{
}

void SCPDriver::startedBallotProtocol(uint64 slotIndex, SCPBallot const& ballot)
{
}

void SCPDriver::acceptedBallotPrepared(uint64 slotIndex, SCPBallot const& ballot)
{
}

void SCPDriver::confirmedBallotPrepared(uint64 slotIndex, SCPBallot const& ballot)
{
}

void SCPDriver::acceptedCommit(uint64 slotIndex, SCPBallot const& ballot)
{
}

void SCPDriver::ballotDidHearFromQuorum(uint64 slotIndex, SCPBallot const& ballot)
{
}
}
