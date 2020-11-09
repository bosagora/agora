/*******************************************************************************

    Manages the slashing policy for the misbehaving validators that do not
    publish pre-images timely.

    This class currently has two responsibilities:
    - It determines when the misbehaving validators will be slashed -- in other
        words, how many times of missing pre-images it will allow.
    - It determines what the penalty is for misbehaving validators -- in other
        words, how many BOA it should pay for a penalty.

    All the validators should publish their pre-images timely in order for
    the network to maintain randomness. So we need a penalty as an incentive
    to make validators publish them regularly. So this class manages all the
    policies for penalty and slashing.
    See https://github.com/bpfkorea/agora/issues/1076.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.SlashPolicy;

import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Types;
import agora.consensus.EnrollmentManager;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.state.UTXODB;
import agora.utils.Log;
version (unittest) import agora.utils.Test;

import std.exception;

mixin AddLogger!();

/*******************************************************************************

    Manage the policy for slashing

*******************************************************************************/

public class SlashPolicy
{
    // The amount of the penalty set to 10K BOA
    public immutable Amount penalty_amount;

    // Enrollment manager
    private EnrollmentManager enroll_man;

    /***************************************************************************

        Constructor

        Params:
            enroll_man = the EnrollmentManager

    ***************************************************************************/

    public this (EnrollmentManager enroll_man)
    {
        this.enroll_man = enroll_man;
        this.penalty_amount = Amount(100_000_000_000);
    }

    /***************************************************************************

        Get validators to be slashed due to missing pre-images

        This finds the misbehaving validators which fail to publish their
        pre-images regularly. A validator will be the candidate for slashing
        if the last revealed pre-image is behind, based on the current height.

        Params:
            height = current block height
            finder = the delegate to find UTXOs with

        Returns:
            `PublicKey`s for the validators

    ***************************************************************************/

    public PublicKey[] getSlashCandidates (Height height, scope UTXOFinder finder)
        @safe nothrow
    {
        PublicKey[] slashed_keys;
        PreImageInfo[] preimages = this.enroll_man.getAllPreimages();

        foreach (preimage; preimages)
        {
            auto enrolled = this.enroll_man.getEnrolledHeight(preimage.enroll_key);
            assert(height >= enrolled);
            ushort curr_distance = cast(ushort)(height - enrolled);
            if (preimage.distance < curr_distance)
            {
                UTXO utxo_value;
                // This should not happen. There must be a UTXO for a validator.
                if (!finder(preimage.enroll_key, utxo_value))
                {
                    log.fatal("No UTXO for a validator key {}", preimage.enroll_key);
                    assert(0, "No UTXO for a validator");
                }
                slashed_keys ~= utxo_value.output.address;
            }
        }

        return slashed_keys;
    }
}

// Test for getting the candidates to be slashed due to missing pre-images
unittest
{
    import agora.common.crypto.Schnorr;
    import agora.consensus.data.Params;
    import agora.consensus.data.Transaction;
    import agora.consensus.state.UTXOSet;

    import std.algorithm;
    import std.range;

    scope utxo_set = new TestUTXOSet;
    KeyPair key_pair = KeyPair.random();
    genesisSpendable()
        .map!(txb => txb.refund(key_pair.address).sign(TxType.Freeze))
        .each!(tx => utxo_set.put(tx));

    auto params = new immutable(ConsensusParams);
    scope enroll_man = new EnrollmentManager(":memory:", key_pair, params);

   // create the first enrollment and add it as a validator
    auto enroll = enroll_man.createEnrollment(utxo_set.keys[0]);
    assert(enroll_man.addValidator(
        enroll, Height(1), utxo_set.getUTXOFinder(), utxo_set.storage) is null);

    // a pre-image exists as commitment of the enrollment
    scope slash_man = new SlashPolicy(enroll_man);
    PublicKey[] slashed = slash_man.getSlashCandidates(Height(1),
        utxo_set.getUTXOFinder());
    assert(slashed.length == 0);

    // the next pre-image is missing
    slashed = slash_man.getSlashCandidates(Height(2), utxo_set.getUTXOFinder());
    assert(slashed.length == 1);
    assert(slashed[0] == key_pair.address);
}
