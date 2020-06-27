/*******************************************************************************

    Data definition for enrollment of validator

    In order to become validators in the network, nodes must perform an action
    we refer to as 'enrollment', which consists of posting a collateral,
    providing a random value, and signing the result.

    This module provide the data definition for the struct,
    allowing it to be passed around without depending on the internals of
    the process.

    More details on the enrollment process can be found in
    `agora.consensus.EnrollmentManager`.

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.Enrollment;

import agora.common.Hash;
import agora.common.Types;

/*******************************************************************************

    Define enrollment data (enrollment data = validator)

*******************************************************************************/

public struct Enrollment
{
    /// K: UTXO hash, A hash of a frozen UTXO
    public Hash utxo_key;

    /// X: random seed, The nth image of random value
    public Hash random_seed;

    /// n: cycle length, the number of rounds a validator will participate in
    /// (currently fixed to (freezing period / 2)
    public uint cycle_length;

    /// S: A signature for the message H(K, X, n, R) and the key K, using R
    public Signature enroll_sig;

    /// The minimum number of validators required to create a block
    public static immutable uint MinValidatorCount = 1;

    /***************************************************************************

        Implements hashing support

        Params:
            dg = hashing function

    ***************************************************************************/

    public void computeHash (scope HashDg dg) const nothrow @safe @nogc
    {
        hashPart(this.utxo_key, dg);
        hashPart(this.random_seed, dg);
        hashPart(this.cycle_length, dg);
    }
}

/// test for the computeHash function
unittest
{
    static immutable ubyte[] hdata = [
        0xae,0x72,0x84,0xec,0xde,0x18,0x8d,0x94,0x81,0x28,0xb0,0x4d,
        0x31,0xae,0x2a,0xeb,
        0x96,0x4d,0x7f,0xe4,0x8e,0x6c,0x62,0x99,0xb5,0x10,0x76,0x5c,
        0x3f,0x0e,0x0b,0x2c,
        0xce,0x55,0x87,0xfe,0x5b,0x76,0x84,0x96,0xe4,0x64,0x2e,0x25,
        0x47,0x38,0xf2,0x5c,
        0x87,0x25,0x8f,0x0f,0x0b,0xa2,0x6f,0xf3,0xc7,0x1a,0xf4,0x77,
        0x3b,0x5b,0xbb,0xb7
    ];
    const enroll_exp = Hash(hdata, /*isLittleEndian:*/ true);
    Enrollment enroll = Enrollment.init;
    assert(enroll.hashFull() == enroll_exp);
}

unittest
{
    import agora.common.Serializer;

    testSymmetry!Enrollment();

    Hash key = Hash("0x000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f" ~
                    "1b60a8ce26f000000000019d6689c085ae165831e934ff763ae46a2" ~
                    "a6c172b3f1b60a8ce26f");
    Hash seed = Hash("0X4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB212" ~
                     "7B7AFDEDA33B4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E" ~
                     "2CC77AB2127B7AFDEDA33B");
    Signature sig = Signature("0x000000000000000000016f605ea9638d7bff58d2c0c" ~
                              "c2467c18e38b36367be78000000000000000000016f60" ~
                              "5ea9638d7bff58d2c0cc2467c18e38b36367be78");
    Enrollment record = {
        utxo_key: key,
        random_seed: seed,
        cycle_length: 42,
        enroll_sig: sig,
    };
    testSymmetry(record);
}
