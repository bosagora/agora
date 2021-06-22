/*******************************************************************************

    Contains types used for size & ABI object layout checks.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.tests.GlueTypes;

import scpd.scp.LocalNode;
import scpd.scp.BallotProtocol;
import scpd.scp.NominationProtocol;
import scpd.scp.SCP;
import scpd.scp.SCPDriver;
import scpd.scp.Slot;
import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types;
import scpd.types.Utils;
import scpd.types.XDRBase;

import std.meta;

import core.stdc.stdint;

// todo: replace with __allMembers tricks in the future
alias TypesWithLayout = AliasSeq!
(
    /// scpd.types.Stellar_SCP
    SCPBallot,
    SCPNomination,
    SCPStatement._pledges_t._prepare_t,
    SCPStatement._pledges_t._confirm_t,
    SCPStatement._pledges_t._externalize_t,
    SCPStatement._pledges_t,
    SCPStatement,
    SCPEnvelope,
    SCPQuorumSet,

    /// scpd.types.Stellar_types
    Hash,
);

/// For these types we cannot do layout checks as we require
/// access to private std::array fields to get the offset.
/// However we can still do sizeof() checks.
alias TypesNoLayout = AliasSeq!
(
    /// scpd.types.Stellar_SCP
    Value,
    SCPStatementType,
    NodeID,
    Signature,

    /// scpd.types.XDRBase
    xvector!Value,
    xvector!NodeID,
    xvector!SCPQuorumSet,

    LocalNode,
    BallotProtocol,
    NominationProtocol,
    SCP,
    Slot,

    // todo: these still don't match perfectly. Need to fix
    // some other C++ bindings for this to work. Most of these
    // types are not passed by value so it's currently ok.
    //SCPEnvelopeWrapper,
    //ValueWrapper,

    ValueWrapperPtr,
    BallotProtocol.SCPBallotWrapper,
);

/// All the glue types have sizeof(), but some may not have accessible layout information
alias GlueTypes = AliasSeq!(TypesWithLayout, TypesNoLayout);
