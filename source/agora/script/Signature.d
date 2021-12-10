/*******************************************************************************

    Contains the signature definitions and the challenge routine.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.script.Signature;

import agora.crypto.Schnorr;
import agora.crypto.Hash;
import agora.common.Types;
import agora.consensus.data.Transaction;
import agora.serialization.Serializer;

import std.range;
import std.algorithm;
import std.bitmanip;

/// Used to select the behavior of the signature creation & validation algorithm
public enum SigHash : ubyte
{
    /// default, signs the entire transaction
    All = 1 << 0,

    /// blanks out the associated Input, for use with Eltoo floating txs
    NoInput = 1 << 1,

    /// Signs only a single output
    Single = 1 << 2,

    /// Signs only a single input
    /// Modifier that can only be used with other SigHash types
    AnyoneCanPay = 1 << 3,

    /// Omits signing an output
    OmitSingle = 1 << 4,

    /// Combined types
    Single_AnyoneCanPay = Single | AnyoneCanPay,
    Single_NoInput_AnyoneCanPay = Single | NoInput | AnyoneCanPay,
    OmitSingle_NoInput_AnyoneCanPay = OmitSingle | NoInput | AnyoneCanPay,
}

/// Contains the Signature and its associated SigHash
public struct SigPair
{
    /// The signature (which also signs the sig_hash below)
    public Signature signature;

    /// Selects behavior of the signature creation & validation algorithm
    public SigHash sig_hash;

    /// Situational output index
    public ulong output_idx;

    /// Ctor
    this (Signature signature, SigHash sig_hash = SigHash.All, ulong output_idx = 0)
        inout pure nothrow @safe @nogc
    {
        this.signature = signature;
        this.sig_hash = sig_hash;
        assert(isValidSigHash(this.sig_hash));
        this.output_idx = output_idx;
    }

    /***************************************************************************

        todo: unittest

        Returns:
            The signature + SigHash as a byte array embeddable in a script

    ***************************************************************************/

    public inout(ubyte)[] opSlice () inout pure nothrow @safe /*@nogc*/
    {
        return this.signature.toBlob()[] ~ ubyte(this.sig_hash)
            ~ (SigPair.usesOutputIdx(this.sig_hash) ? nativeToLittleEndian(this.output_idx).dup : null);
    }

    /// Returns: If output_idx is valid
    @property static bool usesOutputIdx (SigHash sig_hash) pure nothrow @safe @nogc
    {
        return (sig_hash & SigHash.Single) || (sig_hash & SigHash.OmitSingle);
    }
}

unittest
{
    assert(SigPair.usesOutputIdx(SigHash.Single));
    assert(SigPair.usesOutputIdx(SigHash.Single_AnyoneCanPay));
    assert(SigPair.usesOutputIdx(SigHash.OmitSingle));
    assert(SigPair.usesOutputIdx(SigHash.OmitSingle_NoInput_AnyoneCanPay));

    assert(!SigPair.usesOutputIdx(SigHash.All));
    assert(!SigPair.usesOutputIdx(SigHash.NoInput));
    assert(!SigPair.usesOutputIdx(SigHash.AnyoneCanPay));
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
        pop_count = amount of bytes consumed

    Returns:
        null if the signature tuple was decoded correctly,
        otherwise the string explaining the reason why if decoding failed

*******************************************************************************/

public string decodeSignature (const(ubyte)[] bytes,
    out SigPair sig_pair, out ulong pop_count) pure nothrow @safe @nogc
{
    if (bytes.length < Signature.sizeof + SigHash.sizeof)
        return "Encoded signature tuple is of the wrong size";

    const sig = toSignature(bytes[0 .. Signature.sizeof]);
    bytes.popFrontN(Signature.sizeof);
    pop_count += Signature.sizeof;

    const SigHash sig_hash = cast(SigHash)bytes[0];
    if (!isValidSigHash(sig_hash))
        return "Unknown SigHash";
    bytes.popFrontN(SigHash.sizeof);
    pop_count += SigHash.sizeof;

    ulong output_idx;
    if (SigPair.usesOutputIdx(sig_hash))
    {
        if (bytes.length < ulong.sizeof)
            return "Encoded signature does not have output idx";
        output_idx = littleEndianToNative!ulong(bytes[0 .. ulong.sizeof]);
        pop_count += ulong.sizeof;
    }

    sig_pair = SigPair(sig, sig_hash, output_idx);
    return null;
}

unittest
{
    SigPair pair = SigPair(Signature.init, SigHash.Single, 1);
    auto serialized = pair[].dup;

    SigPair decoded_pair;
    ulong consumed;

    assert(decodeSignature(serialized, decoded_pair, consumed) is null);
    assert(pair == decoded_pair);
    assert(consumed == serialized.length);

    serialized ~= 44;
    assert(decodeSignature(serialized, decoded_pair, consumed) is null);
    assert(pair == decoded_pair);
    assert(consumed == serialized.length - 1);

    serialized = serialized[0 .. $ - 3];
    assert(decodeSignature(serialized, decoded_pair, consumed) !is null);

    pair = SigPair(Signature.init, SigHash.All, 1);
    serialized = pair[].dup;
    assert(serialized.length < SigPair.sizeof);
    assert(decodeSignature(serialized, decoded_pair, consumed) is null);
    assert(pair.signature == decoded_pair.signature);
    assert(pair.sig_hash == decoded_pair.sig_hash);
    assert(decoded_pair.output_idx == 0);
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
    case SigHash.NoInput:
    case SigHash.Single:
    case SigHash.OmitSingle:
    case SigHash.Single_AnyoneCanPay:
    case SigHash.OmitSingle_NoInput_AnyoneCanPay:
    case SigHash.Single_NoInput_AnyoneCanPay:
        break;

    case SigHash.AnyoneCanPay:
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
    assert(isValidSigHash(SigHash.NoInput));
    assert(isValidSigHash(SigHash.Single));
    assert(!isValidSigHash(SigHash.AnyoneCanPay));
    // this combo is unrecognized
    assert(!isValidSigHash(cast(SigHash)(SigHash.All | SigHash.NoInput)));
    assert(isValidSigHash(SigHash.Single_NoInput_AnyoneCanPay));
    assert(isValidSigHash(SigHash.OmitSingle));
    assert(isValidSigHash(SigHash.OmitSingle_NoInput_AnyoneCanPay));
    assert(!isValidSigHash(cast(SigHash)(SigHash.OmitSingle | SigHash.Single)));
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
        output_idx = the associated output index we're signing for

    Returns:
        the challenge as a hash

*******************************************************************************/

public Hash getChallenge (in Transaction tx, in SigHash sig_hash = SigHash.All,
    in ulong input_idx = 0, in ulong output_idx = 0) nothrow @safe
{
    import agora.script.Lock;
    import std.exception : assumeWontThrow;

    if (sig_hash != SigHash.All)
    {
        assert(input_idx < tx.inputs.length, "Input index is out of range");
        if (SigPair.usesOutputIdx(sig_hash))
            assert(output_idx < tx.outputs.length, "Output index is out of range");
    }

    Transaction dup = () @trusted { return *cast(Transaction*)&tx; }();

    final switch (sig_hash)
    {
    case SigHash.NoInput:  // eltoo support
        dup.inputs = dup.inputs[0..input_idx] ~ dup.inputs[input_idx + 1..$]; // blank out matching input
        return hashMulti(dup, sig_hash);
    // sign all inputs and a single output
    case SigHash.Single:
        dup.outputs = dup.outputs[output_idx .. output_idx + 1];
        return hashMulti(dup, sig_hash);
    // sign a single input and a single output
    case SigHash.Single_AnyoneCanPay:
        dup.inputs = dup.inputs[input_idx .. input_idx + 1];
        dup.outputs = dup.outputs[output_idx .. output_idx + 1];
        return hashMulti(dup, sig_hash);
    // sign a single output and no inputs
    case SigHash.Single_NoInput_AnyoneCanPay:
        dup.inputs = null;
        dup.outputs = dup.outputs[output_idx .. output_idx + 1];
        return hashMulti(dup, sig_hash);
    case SigHash.All:
        return hashMulti(dup, sig_hash);
    // sign all inputs and all outputs but one
    case SigHash.OmitSingle:
        dup.outputs = dup.outputs[0..output_idx] ~ dup.outputs[output_idx + 1..$]; // blank out matching output
        return hashMulti(dup, sig_hash);
    // sign no inputs and all outputs but one
    case SigHash.OmitSingle_NoInput_AnyoneCanPay:
        dup.inputs = null;
        dup.outputs = dup.outputs[0..output_idx] ~ dup.outputs[output_idx + 1..$]; // blank out matching output
        return hashMulti(dup, sig_hash);
    case SigHash.AnyoneCanPay:
        assert(0);
    }
}

///
unittest
{
    import agora.crypto.Key;
    import agora.common.Amount;
    import agora.utils.Test;
    import ocean.core.Test;

    // SigHash.All
    {
        auto tx = Transaction([Input(hashFull(1)), Input(hashFull(2))], [Output(Amount(1), PublicKey.init)], Height(10));
        auto challenge_idx_0 = getChallenge(tx, SigHash.All, 0);
        assert(challenge_idx_0 != tx.hashFull());
        assert(challenge_idx_0 == getChallenge(tx, SigHash.All, 1));
        tx.inputs[0] = Input(hashFull(3));
        assert(challenge_idx_0 != getChallenge(tx, SigHash.All, 1));
    }

    // SigHash.NoInput
    {
        auto tx = Transaction([Input(hashFull(1)), Input(hashFull(2))], [Output(Amount(1), PublicKey.init)], Height(10));
        auto challenge_idx_0 = getChallenge(tx, SigHash.NoInput, 0);
        assert(challenge_idx_0 != getChallenge(tx, SigHash.NoInput, 1));
        // Redirect input_0
        tx.inputs[0] = Input(hashFull(3));
        assert(challenge_idx_0 == getChallenge(tx, SigHash.NoInput, 0));
        // Redirect input_1
        tx.inputs[1] = Input(hashFull(4));
        assert(challenge_idx_0 != getChallenge(tx, SigHash.NoInput, 0));

        // restore input_1
        tx.inputs[1] = Input(hashFull(2));
        // add a new output
        tx.outputs ~= Output(Amount(2), PublicKey.init);
        assert(challenge_idx_0 != getChallenge(tx, SigHash.NoInput, 0));
    }

    // SigHash.Single
    {
        auto tx = Transaction([Input(hashFull(1)), Input(hashFull(2))], [Output(Amount(1), PublicKey.init)], Height(10));
        auto challenge_idx_0 = getChallenge(tx, SigHash.Single, 0, 0);

        // since SigHash.Single signs all inputs, challenges for different inputs should be the same
        assert(challenge_idx_0 == getChallenge(tx, SigHash.Single, 1, 0));

        // add a new not signed output
        tx.outputs ~= Output(Amount(2), PublicKey.init);
        // old challenge should still hold
        assert(challenge_idx_0 == getChallenge(tx, SigHash.Single, 0, 0));
        assert(challenge_idx_0 != getChallenge(tx, SigHash.Single, 0, 1));

        tx.outputs = Output(Amount(0), PublicKey.init) ~ tx.outputs;
        // output changes index, after updating the index challenge should hold
        assert(challenge_idx_0 == getChallenge(tx, SigHash.Single, 0, 1));

        // Redirect input_0
        tx.inputs[0] = Input(hashFull(3));
        assert(challenge_idx_0 != getChallenge(tx, SigHash.Single, 0, 1));

        // restore input_0 and add a new input
        tx.inputs[0] = Input(hashFull(1));
        tx.inputs ~= Input(hashFull(3));
        tx.inputs.sort();
        assert(challenge_idx_0 != getChallenge(tx, SigHash.Single, 0, 1));
    }

    // SigHash.Single | SigHash.AnyoneCanPay
    {
        auto tx = Transaction([Input(hashFull(1)), Input(hashFull(2))], [Output(Amount(1), PublicKey.init)], Height(10));
        auto challenge_idx_0 = getChallenge(tx, SigHash.Single_AnyoneCanPay, 0, 0);

        // add a new input, challenge should hold
        tx.inputs ~= Input(hashFull(0));
        assert(challenge_idx_0 == getChallenge(tx, SigHash.Single_AnyoneCanPay, 0, 0));

        // change an existing input, challenge should hold
        tx.inputs[1] = Input(hashFull(3));
        assert(challenge_idx_0 == getChallenge(tx, SigHash.Single_AnyoneCanPay, 0, 0));

        tx.inputs = Input.init ~ tx.inputs;
        // change input index, challenge should hold
        assert(challenge_idx_0 == getChallenge(tx, SigHash.Single_AnyoneCanPay, 1, 0));
    }

    // SigHash.Single | SigHash.NoInput | SigHash.AnyoneCanPay
    {
        auto tx = Transaction([Input(hashFull(1)), Input(hashFull(2))], [Output(Amount(1), PublicKey.init)], Height(10));
        auto challenge_idx_0 = getChallenge(tx, SigHash.Single_NoInput_AnyoneCanPay, 0, 0);

        // change signed input, challenge should hold
        tx.inputs[0] = Input.init;
        assert(challenge_idx_0 == getChallenge(tx, SigHash.Single_NoInput_AnyoneCanPay, 0, 0));
    }

    // SigHash.OmitSingle
    {
        auto tx = Transaction([Input(hashFull(1)), Input(hashFull(2))],
            [Output(Amount(1), PublicKey.init), Output(Amount(2), PublicKey.init)], Height(10));
        auto challenge_idx_0 = getChallenge(tx, SigHash.OmitSingle, 0, 0);

        // cannot add a new input
        tx.inputs ~= Input(hashFull(0));
        assert(challenge_idx_0 != getChallenge(tx, SigHash.OmitSingle, 0, 0));
        // revert
        tx.inputs = tx.inputs[0 .. $ - 1];

        auto old_input_0 = tx.inputs[0];
        // cannot change an input
        tx.inputs[0] = Input(hashFull(0));
        assert(challenge_idx_0 != getChallenge(tx, SigHash.OmitSingle, 0, 0));
        // revert
        tx.inputs[0] = old_input_0;

        auto old_output_1_value = tx.outputs[1].value;
        // cannot change signed output
        tx.outputs[1].value = Amount(3);
        assert(challenge_idx_0 != getChallenge(tx, SigHash.OmitSingle, 0, 0));
        // revert
        tx.outputs[1].value = old_output_1_value;

        // can change omitted output
        tx.outputs[0].value = Amount(3);
        assert(challenge_idx_0 == getChallenge(tx, SigHash.OmitSingle, 0, 0));

        // cannot add a new output
        tx.outputs ~= Output.init;
        assert(challenge_idx_0 != getChallenge(tx, SigHash.OmitSingle, 0, 0));
    }

    // SigHash.OmitSingle | SigHash.NoInput | SigHash.AnyoneCanPay
    {
        auto tx = Transaction([Input(hashFull(1)), Input(hashFull(2))], [Output(Amount(1), PublicKey.init)], Height(10));
        auto challenge_idx_0 = getChallenge(tx, SigHash.OmitSingle_NoInput_AnyoneCanPay, 0, 0);

        // change signed input, challenge should hold
        tx.inputs[0] = Input.init;
        assert(challenge_idx_0 == getChallenge(tx, SigHash.OmitSingle_NoInput_AnyoneCanPay, 0, 0));
    }
}
