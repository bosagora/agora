/*******************************************************************************

    Contains definition for the `ValidatorBlockSig` struct,
    which is used to communicate block signatures between nodes.

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.ValidatorBlockSig;

import agora.common.Types;
import agora.common.crypto.Key;
import agora.crypto.ECC;
import agora.crypto.Schnorr;

import std.format;

/*******************************************************************************

    The `s` of a Schnorr signature (R, s) needs to be transferred via vibe.d to
    other nodes in the clear print format. SigScalar is used to enable this.

*******************************************************************************/

public struct SigScalar
{
    public Scalar data;

    public this (typeof(this.data) data) @safe @nogc nothrow
    {
        this.data = data;
    }

    public Scalar asScalar() const @safe @nogc nothrow
    {
        return this.data;
    }

    public string toString () const @safe
    {
        return data.toString(PrintMode.Clear);
    }

    // If we are sending this via vibe.d then it needs to be in the clear
    string toRepresentation() const @safe
    {
        return this.data.toString(PrintMode.Clear);
    }

    static SigScalar fromRepresentation(in char[] str) @safe
    {
        return SigScalar(Scalar.fromString(str));
    }
}

/*******************************************************************************

    Define Validator Block Signature information

*******************************************************************************/

public struct ValidatorBlockSig
{
    /// The block height of this signature
    public Height height;

    /// The public key of the validator
    public PublicKey public_key;

    /// The block signature as s of Sig (R, s) for the validator
    public SigScalar signature;

    public this (Height height, PublicKey public_key, SigScalar signature) @safe @nogc nothrow
    {
        this.height = height;
        this.public_key = public_key;
        this.signature = signature;
    }

    public this (Height height, PublicKey public_key, Scalar signature) @safe @nogc nothrow
    {
        this(height, public_key, SigScalar(signature));
    }
}

unittest
{
    import agora.common.Serializer;

    testSymmetry!ValidatorBlockSig();

    Height height = Height(100);
    PublicKey public_key = PublicKey.fromString(`GDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQFW`);
    Scalar signature = Scalar("0x0e00a8df701806cb4deac9bb09cc85b097ee713e055b9d2bf1daf668b3f63778");
    ValidatorBlockSig sig = ValidatorBlockSig(height, public_key, signature);
    testSymmetry(sig);

    import vibe.data.json;
    assert(sig.serializeToJsonString() == "{\"height\":\"100\"," ~
        "\"public_key\":\"GDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQFW\"," ~
        "\"signature\":\"0x0e00a8df701806cb4deac9bb09cc85b097ee713e055b9d2bf1daf668b3f63778\"}",
        sig.serializeToJsonString());
}
