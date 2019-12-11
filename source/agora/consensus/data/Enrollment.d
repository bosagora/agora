/*******************************************************************************

    Contains supporting code for a enrollment data used in enrollment process.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.Enrollment;

import agora.common.Types;
import agora.common.crypto.Schnorr : Signature;

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
}
