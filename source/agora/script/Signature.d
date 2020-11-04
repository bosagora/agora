/*******************************************************************************

    Contains the signature definitions and the challenge routine.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.script.Signature;

import agora.common.Hash;
import agora.common.Types;
import agora.consensus.data.Transaction;

import std.range;

/// Used to select the behavior of the signature creation & validation algorithm
public enum SigHash : ubyte
{
    /// default, signs the entire transaction
    All = 1 << 0,
}

/// Contains the Signature and its associated SigHash
public struct SigPair
{
align(1):
    /// The signature (which also signs the sig_hash below)
    public Signature signature;

    /// Selects behavior of the signature creation & validation algorithm
    public SigHash sig_hash;

    /***************************************************************************

        Internal. Use `decodeSignature()` free function to construct
        a validated SigPair out of a byte array.

        Params:
            signature = the Signature
            sig_hash = the SigHash

    ***************************************************************************/

    private this (Signature signature, SigHash sig_hash)
        pure nothrow @safe @nogc
    {
        this.signature = signature;
        this.sig_hash = sig_hash;
    }

    /***************************************************************************

        todo: unittest

        Returns:
            The signature + SigHash as a byte array embeddable in a script

    ***************************************************************************/

    public inout(ubyte)[] opSlice () inout pure nothrow @safe /*@nogc*/
    {
        return this.signature[] ~ ubyte(this.sig_hash);
    }
}

/*******************************************************************************

    Decodes the raw byte representation of a signature to its
    `Signature` and `SigHash` parts, and validates the `SigHash`
    to be one of the known flags or accepted combination of flags.

    Params:
        bytes = contains the <Signature, SigHash> tuple
        sig_pair = will contain the signature tuple if the Signature was encoded
                   correctly and the SigHash is one of the known flags or
                   accepted combination of flags.

    Returns:
        null if the signature tuple was decoded correctly,
        otherwise the string explaining the reason why if decoding failed

*******************************************************************************/

public string decodeSignature (const(ubyte)[] bytes,
    out SigPair sig_pair) pure nothrow @safe @nogc
{
    if (bytes.length != SigPair.sizeof)
        return "Encoded signature tuple is of the wrong size";

    const sig = Signature(bytes[0 .. Signature.sizeof]);
    bytes.popFrontN(Signature.sizeof);

    assert(bytes.length == 1);
    const SigHash sig_hash = cast(SigHash)bytes[0];
    if (!isValidSigHash(sig_hash))
        return "Unknown SigHash";

    sig_pair = SigPair(sig, sig_hash);
    return null;
}

/*******************************************************************************

    Validates that the given `SigHash` is one of the known flags or one of
    the accepted combination of flags.

    Params:
        sig_hash = the `SigHash` to validate

    Returns:
        true if this is one of the known flags or accepted combination of flags

*******************************************************************************/

private bool isValidSigHash (in SigHash sig_hash) pure nothrow @safe @nogc
{
    switch (sig_hash)
    {
    case SigHash.All:
        break;

    default:
        return false;
    }

    return true;
}

///
unittest
{
    assert(!isValidSigHash(cast(SigHash)0));
    assert(isValidSigHash(SigHash.All));
}

/*******************************************************************************

    Gets the challenge hash for the provided transaction, input index,
    and the type of SigHash. This cannot be folded into a `sign` routine
    because it's also required during signature validation.

    The input index is only used for some types of SigHash (SigHash.NoInput).

    Params:
        tx = the transaction to sign
        sig_hash = the `SigHash` to use
        input_idx = the associated input index we're signing for

    Returns:
        the challenge as a hash

*******************************************************************************/

public Hash getChallenge (in Transaction tx, in SigHash sig_hash,
    in ulong input_idx) nothrow @safe
{
    assert(input_idx < tx.inputs.length, "Input index is out of range");

    switch (sig_hash)
    {
    case SigHash.All:
        return hashMulti(tx, sig_hash);

    default:
        assert(0);  // unhandled case
    }
}

///
unittest
{
    import agora.utils.Test;
    import ocean.core.Test;

    const Transaction tx = {
        unlock_height : 10,
        inputs: [Input(hashFull(1)),
                 Input(hashFull(2))]
    };

    test!"=="(getChallenge(tx, SigHash.All, 0),
        Hash.fromString("0xda16b36873065bc4e950901f9d2e6b2b3ec2baf33358f4dc61d83dca576a2b3d0a6c29b2453e2c0002374c16141c29b0786b99b222404c581fd0bf1ecb60dabf"));
    test!"=="(getChallenge(tx, SigHash.All, 1),
        Hash.fromString("0xda16b36873065bc4e950901f9d2e6b2b3ec2baf33358f4dc61d83dca576a2b3d0a6c29b2453e2c0002374c16141c29b0786b99b222404c581fd0bf1ecb60dabf"));  // same hash
}
