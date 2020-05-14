/*******************************************************************************

    Contains validation routines for all data types required for consensus.

    We split validation in two separate phases:
    - Validation that does not require a 'context';
    - Validation that does require a context;

    We refer to context-less checks as 'syntax' checks, and context-using
    checks as 'semantic' checks (even though those terms are misnomers).

    Elements (blocks, transactions) that are invalid without a context will
    *always* be invalid for this version of the software.
    However it is possible a later upgrade will accept the element,
    or that they were previously accepted in an older version.

    Elements that are invalid in a given context could become valid with
    a new, different context. An example is a transaction referencing a
    non-existing UTXO: the transaction could have not been broadcast yet,
    or could have not been reached the node yet.

    Such a distinction is important to prevent denial of service,
    and to allow testing consensus rules under a different context,
    which is mandatory for our slasher implementation.

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.validation;

public import agora.consensus.validation.Block       : isInvalidReason;
public import agora.consensus.validation.Enrollment  : isInvalidReason;
public import agora.consensus.validation.PreImage    : isInvalidReason;
public import agora.consensus.validation.Transaction : isInvalidReason;

version (unittest)
{
    public import agora.consensus.validation.Block       : isValid;
    public import agora.consensus.validation.Enrollment  : isValid;
    public import agora.consensus.validation.PreImage    : isValid;
    public import agora.consensus.validation.Transaction : isValid;
}
