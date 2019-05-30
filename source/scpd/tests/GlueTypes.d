/*******************************************************************************

    Contains types used for size & ABI object layout checks.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module scpd.tests.GlueTypes;

import core.stdc.stdint;
import std.meta;

import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types;
import scpd.types.Utils;
import scpd.types.XDRBase;

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
    PublicKey,
    Hash,

    /// scpd.types.Utils
    ByteSlice,
);

/// For these types we cannot do layout checks as we require
/// access to private std::array fields to get the offset.
/// However we can still do sizeof() checks.
alias TypesNoLayout = AliasSeq!
(
    /// scpd.types.Stellar_SCP
    Value,
    SCPStatementType,
    CryptoKeyType,
    PublicKeyType,
    SignerKeyType,
    Signature,
    SignatureHint,

    /// scpd.types.XDRBase
    xvector!Value,
    xvector!PublicKey,
    xvector!SCPQuorumSet,
);

/// All the glue types have sizeof(), but some may not have accessible layout information
alias GlueTypes = AliasSeq!(TypesWithLayout, TypesNoLayout);
