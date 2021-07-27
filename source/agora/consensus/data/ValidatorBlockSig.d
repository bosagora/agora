/*******************************************************************************

    Contains definition for the `ValidatorBlockSig` struct,
    which is used to communicate block signatures between nodes.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.ValidatorBlockSig;

import agora.common.Types;
import agora.crypto.ECC;
import agora.crypto.Key;
import agora.crypto.Schnorr;

import std.format;

/*******************************************************************************

    The `s` of a Schnorr signature (R, s) needs to be transferred via vibe.d to
    other nodes in the clear print format. SigScalar is used to enable this.

*******************************************************************************/

public struct SigScalar
{
    public Scalar data;

    alias data this;

    public static SigScalar fromString (in char[] str) @safe
    {
        return SigScalar(Scalar.fromString(str));
    }

    public string toString () const @safe
    {
        return this.data.toString(PrintMode.Clear);
    }

    public void toString (scope void delegate (scope const(char)[]) @safe sink)
        const @safe
    {
        FormatSpec!char spec;
        spec.spec = 'c';
        this.data.toString(sink, spec);
    }
}

/*******************************************************************************

    Define Validator Block Signature information

*******************************************************************************/

public struct ValidatorBlockSig
{
    /// The block height of this signature
    public Height height;

    /// The stake of the validator
    public Hash utxo;

    /// The block signature as s of Signature (R, s) for the validator
    public SigScalar signature;

    public this (Height height, Hash utxo, SigScalar signature) @safe @nogc nothrow
    {
        this.height = height;
        this.utxo = utxo;
        this.signature = signature;
    }

    public this (Height height, Hash utxo, Scalar signature) @safe @nogc nothrow
    {
        this(height, utxo, SigScalar(signature));
    }
}

unittest
{
    import agora.crypto.Hash;
    import agora.serialization.Serializer;

    testSymmetry!ValidatorBlockSig();

    Height height = Height(100);
    Hash hash = "Hello world".hashFull();
    Scalar signature = Scalar("0x0e00a8df701806cb4deac9bb09cc85b097ee713e055b9d2bf1daf668b3f63778");
    ValidatorBlockSig sig = ValidatorBlockSig(height, hash, signature);
    testSymmetry(sig);

    import vibe.data.json;
    assert(sig.serializeToJsonString() == "{\"height\":\"100\"," ~
        "\"utxo\":\"0xee438b9928cd623262b040b3b2b1522235b8a92269d1a724cd53c25" ~
           "d1042ec86b2d178cef755014a5892706e689cd82e00de9f1225e87dcc0600b2c8b2be9931\"," ~
        "\"signature\":\"0x0e00a8df701806cb4deac9bb09cc85b097ee713e055b9d2bf1daf668b3f63778\"}");
}
