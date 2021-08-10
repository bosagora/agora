/*******************************************************************************

    Contains validation routines for enrollments

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.validation.Enrollment;

import agora.common.Amount;
import agora.common.Types;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.state.UTXOCache;
import agora.consensus.state.ValidatorSet;
import agora.consensus.data.PreImageInfo;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr;

import std.conv;

version (unittest)
{
    import agora.consensus.data.Params;
    import agora.common.ManagedDatabase;
    import agora.consensus.PreImage;
}

/*******************************************************************************

    Check the validity of an enrollment.

    A Validator's enrollment is considered valid if:
        - UTXO is unspent frozen utxo
        - Signatures are authentic
        - The frozen amount must be equal to or greater than 40,000 BOA

    Params:
        enrollment = The enrollment of the target to be verified
        findUTXO = delegate to find the referenced unspent UTXOs with
        height = The `Height` that this `Enrollment` is proposed at

    Returns:
        `null` if the validator's UTXO is valid, otherwise a string
        explaining the reason it is invalid.

*******************************************************************************/

public string isInvalidReason (in Enrollment enrollment,
    scope UTXOFinder findUTXO, in Height height,
    scope EnrollmentFinder findEnrollment) nothrow @safe
{
    UTXO utxo_set_value;
    if (!findUTXO(enrollment.utxo_key, utxo_set_value))
        return "Enrollment: UTXO not found";

    if (utxo_set_value.output.type != OutputType.Freeze)
        return "Enrollment: UTXO is not frozen";

    Point address = utxo_set_value.output.address;

    if (!address.isValid())
        return "Enrollment: Address is not a valid point on Curve25519";

    if (!verify(address, enrollment.enroll_sig, enrollment))
        return "Enrollment: signature verification failed";

    if (utxo_set_value.output.value.integral() < Amount.MinFreezeAmount.integral())
    {
        static immutable Message =
            "Enrollment: The frozen amount must be equal to or greater than " ~
            Amount.MinFreezeAmount.integral().to!string ~ " BOA";
        return Message;
    }

    EnrollmentState enroll_state;
    if (findEnrollment(enrollment.utxo_key, enroll_state))
    {
        if (height <= enroll_state.enrolled_height)
            return "Already enrolled at this height";
        assert(enroll_state.preimage.height >= enroll_state.enrolled_height);

        // Create this enrollment pre-image info
        PreImageInfo enroll_preimage = PreImageInfo(
                enrollment.utxo_key, enrollment.commitment, height);
        // Now we can check the preimages are consistent
        if (enroll_state.preimage.height < enroll_preimage.height ?
            enroll_preimage[enroll_state.preimage.height] != enroll_state.preimage.hash :
            enroll_state.preimage[enroll_preimage.height] != enroll_preimage.hash)
            return "The seed has an invalid hash value";
    }

    return null;
}

/// Ditto but returns `bool`, only usable in unittests
version (unittest)
public bool isValid (in Enrollment enrollment,
    scope UTXOFinder findUTXO, in Height height,
    scope EnrollmentFinder findEnrollment) nothrow @safe
{
    return isInvalidReason(enrollment, findUTXO, height, findEnrollment) is null;
}

///
unittest
{
    import std.algorithm.searching;
    import std.string;
    import agora.consensus.state.UTXOSet;

    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random];

    auto params = new immutable(ConsensusParams)();
    auto stateDB = new ManagedDatabase(":memory:");
    scope utxo_set = new UTXOSet(stateDB);
    scope validator_set = new ValidatorSet(stateDB, params);
    scope UTXOFinder utxoFinder = utxo_set.getUTXOFinder();

    // normal frozen transaction
    Transaction tx1 = Transaction(
        [Output(Amount.MinFreezeAmount, key_pairs[0].address, OutputType.Freeze)]
    );

    // payment transaction
    Transaction tx2 = Transaction(
        [Output(Amount.MinFreezeAmount, key_pairs[1].address)]
    );

    // Insufficient freeze amount transaction
    Transaction tx3 = Transaction(
        [Output(Amount(1), key_pairs[2].address, OutputType.Freeze)]
    );

    // normal freeze amount transaction
    Transaction tx4 = Transaction(
        [Output(Amount.MinFreezeAmount, key_pairs[3].address)]
    );

    auto utxo_hash1 = UTXO.getHash(hashFull(tx1), 0);
    auto utxo_hash2 = UTXO.getHash(hashFull(tx2), 0);
    auto utxo_hash3 = UTXO.getHash(hashFull(tx3), 0);
    auto utxo_hash4 = UTXO.getHash(hashFull(tx4), 0);

    Pair signature_noise = Pair.random;

    Pair node_key_pair_1 = Pair.fromScalar(key_pairs[0].secret);

    Enrollment enroll1;
    enroll1.utxo_key = utxo_hash1;
    enroll1.commitment = hashFull(Scalar.random());
    enroll1.cycle_length = 1008;
    enroll1.enroll_sig = sign(node_key_pair_1, signature_noise, enroll1);

    Pair node_key_pair_2 = Pair.fromScalar(key_pairs[1].secret);

    Enrollment enroll2;
    enroll2.utxo_key = utxo_hash2;
    enroll2.commitment = hashFull(Scalar.random());
    enroll2.cycle_length = 1008;
    enroll2.enroll_sig = sign(node_key_pair_2, signature_noise, enroll2);

    Pair node_key_pair_3 = Pair.fromScalar(key_pairs[2].secret);

    Enrollment enroll3;
    enroll3.utxo_key = utxo_hash3;
    enroll3.commitment = hashFull(Scalar.random());
    enroll3.cycle_length = 1008;
    enroll3.enroll_sig = sign(node_key_pair_3, signature_noise, enroll3);

    // Make pair with non matching scalar and point
    Pair node_key_pair_invalid = Pair(node_key_pair_2.v, node_key_pair_3.V);

    Enrollment enroll4;
    enroll4.utxo_key = utxo_hash4;
    enroll4.commitment = hashFull(Scalar.random());
    enroll4.cycle_length = 1008;
    enroll4.enroll_sig = sign(node_key_pair_invalid, signature_noise, enroll4);

    assert(!enroll1.isValid(utxoFinder, Height(0),
                                    &validator_set.findRecentEnrollment));
    assert(!enroll2.isValid(utxoFinder, Height(0),
                                    &validator_set.findRecentEnrollment));
    assert(!enroll3.isValid(utxoFinder, Height(0),
                                    &validator_set.findRecentEnrollment));
    assert(!enroll4.isValid(utxoFinder, Height(0),
                                    &validator_set.findRecentEnrollment));

    utxo_set.updateUTXOCache(tx1, Height(0), params.CommonsBudgetAddress);
    utxo_set.updateUTXOCache(tx2, Height(0), params.CommonsBudgetAddress);
    utxo_set.updateUTXOCache(tx3, Height(0), params.CommonsBudgetAddress);
    utxo_set.updateUTXOCache(tx4, Height(0), params.CommonsBudgetAddress);

    // Nomal
    assert(enroll1.isValid(utxoFinder, Height(0),
                                        &validator_set.findRecentEnrollment));

    // Unspent frozen UTXO not found for the validator.
    assert(!enroll1.isValid( utxoFinder, Height(0),
                                        &validator_set.findRecentEnrollment));

    // UTXO is not frozen.
    assert(canFind(enroll2.isInvalidReason(utxoFinder,
        Height(0), &validator_set.findRecentEnrollment), "UTXO is not frozen"));

    // The frozen amount must be equal to or greater than 40,000 BOA.
    assert(!enroll3.isValid(utxoFinder, Height(0),
                                        &validator_set.findRecentEnrollment));

    // Enrollment signature verification has an error.
    assert(!enroll4.isValid(utxoFinder, Height(0),
                                        &validator_set.findRecentEnrollment));

    const utxoPeek = &utxo_set.peekUTXO;
    auto cycle = PreImageCycle(key_pairs[0].secret, params.ValidatorCycle);

    enroll1.utxo_key = utxo_hash1;
    enroll1.commitment = cycle[Height(0)];
    enroll1.cycle_length = params.ValidatorCycle;
    enroll1.enroll_sig = sign(node_key_pair_1, signature_noise, enroll1);

    assert(validator_set.add(Height(0), utxoPeek, enroll1,
                                                key_pairs[0].address) is null);

    assert(validator_set.countActive(Height(params.ValidatorCycle + 1)) == 0);

    // First 2 iterations should fail because commitment is wrong
    foreach (offset; [-1, +1, 0])
    {
        enroll1.commitment = cycle[Height(params.ValidatorCycle + offset)];
        enroll1.enroll_sig = sign(node_key_pair_1, signature_noise, enroll1);
        assert((offset == 0) == (validator_set.add(Height(params.ValidatorCycle),
                            utxoPeek, enroll1, key_pairs[0].address) is null));
    }
    assert(validator_set.countActive(Height(params.ValidatorCycle + 1)) == 1);

    Enrollment invalid;
    assert(isInvalidReason(invalid,
        (in Hash, out UTXO utxo) { utxo.output.type = OutputType.Freeze; return true; },
        Height(0), null)
        == "Enrollment: Address is not a valid point on Curve25519");
}
