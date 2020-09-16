/*******************************************************************************

    Contains unittest functions used for layout checks of the D glue layer.

    Note: This is not part of Stellar SCP code.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

#include <vector>
#include "xdrpp/marshal.h"
#include "xdrpp/types.h"
#include "xdr/Stellar-SCP.h"
#include "xdr/Stellar-types.h"
#include "scp/Slot.h"
#include "crypto/ByteSlice.h"

#include <stdio.h>
#include <string.h>

using namespace xdr;
using namespace stellar;

struct FieldInfo
{
    long long _size;
    long long _offset;
    //const(char)* mangleof;  // todo: could this work for type checks?

    FieldInfo(unsigned long long size,
              unsigned long long offset) : _size(size), _offset(offset) { };
};

#define HANDLE(FIELD) \
    if (strcmp(field_name, #FIELD) == 0) \
        return FieldInfo(sizeof(object.FIELD), (char*)&object.FIELD - (char*)&object);

/// scpd.types.Stellar_SCP
FieldInfo cppFieldInfo ( Hash &object, const char *field_name )
{
    // special-case: on the D side Hash just stores an internal 'base' field
    if (strcmp(field_name, "base") == 0) \
        return FieldInfo(sizeof(object), 0);

    return FieldInfo(-1, -1);  // assert on the D side for better error messages
}

FieldInfo cppFieldInfo ( SCPBallot &object, const char *field_name )
{
    /// todo: is there a way to automatically expand
    /// "MACRO(T1, T2)" to "HANDLE(T1) \n HANDLE(T2)" ?
    HANDLE(counter)
    HANDLE(value)

    return FieldInfo(-1, -1);  // assert on the D side for better error messages
}

FieldInfo cppFieldInfo ( SCPNomination &object, const char *field_name )
{
    HANDLE(quorumSetHash)
    HANDLE(votes)
    HANDLE(accepted)
    return FieldInfo(-1, -1);  // assert on the D side for better error messages
}

FieldInfo cppFieldInfo ( SCPStatement::_pledges_t::_prepare_t &object, const char *field_name )
{
    HANDLE(quorumSetHash)
    HANDLE(ballot)
    HANDLE(prepared)
    HANDLE(preparedPrime)
    HANDLE(nC)
    HANDLE(nH)
    return FieldInfo(-1, -1);  // assert on the D side for better error messages
}

FieldInfo cppFieldInfo ( SCPStatement::_pledges_t::_confirm_t &object, const char *field_name )
{
    HANDLE(ballot)
    HANDLE(value_sig)
    HANDLE(nPrepared)
    HANDLE(nCommit)
    HANDLE(nH)
    HANDLE(quorumSetHash)
    return FieldInfo(-1, -1);  // assert on the D side for better error messages
}

FieldInfo cppFieldInfo ( SCPStatement::_pledges_t::_externalize_t &object, const char *field_name )
{
    HANDLE(commit)
    HANDLE(nH)
    HANDLE(commitQuorumSetHash)
    return FieldInfo(-1, -1);  // assert on the D side for better error messages
}

FieldInfo cppFieldInfo ( SCPStatement::_pledges_t &object, const char *field_name )
{
    HANDLE(type_)
    HANDLE(prepare_)
    HANDLE(confirm_)
    HANDLE(externalize_)
    HANDLE(nominate_)
    return FieldInfo(-1, -1);  // assert on the D side for better error messages
}

FieldInfo cppFieldInfo ( SCPStatement &object, const char *field_name )
{
    HANDLE(nodeID)
    HANDLE(slotIndex)
    HANDLE(pledges)
    return FieldInfo(-1, -1);  // assert on the D side for better error messages
}

FieldInfo cppFieldInfo ( SCPEnvelope &object, const char *field_name )
{
    HANDLE(statement)
    HANDLE(signature)
    return FieldInfo(-1, -1);  // assert on the D side for better error messages
}

FieldInfo cppFieldInfo ( SCPQuorumSet &object, const char *field_name )
{
    HANDLE(threshold)
    HANDLE(validators)
    HANDLE(innerSets)
    return FieldInfo(-1, -1);  // assert on the D side for better error messages
}

/// scpd.types.Stellar_types

FieldInfo cppFieldInfo ( PublicKey &object, const char *field_name )
{
    HANDLE(type_)
    HANDLE(ed25519_)
    return FieldInfo(-1, -1);  // assert on the D side for better error messages
}

FieldInfo cppFieldInfo ( ByteSlice &object, const char *field_name )
{
    HANDLE(mData)
    HANDLE(mSize)
    return FieldInfo(-1, -1);  // assert on the D side for better error messages
}
