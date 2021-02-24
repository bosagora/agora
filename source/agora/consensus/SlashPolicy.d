/*******************************************************************************

    Manages the slashing policy for the misbehaving validators that do not
    reveal their pre-images timely.

    This class currently has two responsibilities:
    - It determines when the misbehaving validators will be slashed -- in other
        words, how many times of missing pre-images it will allow.
    - It determines what the penalty is for misbehaving validators -- in other
        words, How many BOAs it will impose on the misbehaving validators
        as a penalty

    All the validators should reveal their pre-images timely in order for
    the network to maintain randomness. So we need a penalty as an incentive
    to make validators reveal them regularly. So this class manages all the
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
import agora.consensus.data.Params;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.state.UTXODB;
import agora.utils.Log;
version (unittest) import agora.utils.Test;

import std.algorithm;
import std.conv;
import std.range;

mixin AddLogger!();

/*******************************************************************************

    Manage the policy for slashing

*******************************************************************************/

public class SlashPolicy
{
    // The amount of a penalty
    public immutable Amount penalty_amount;

    // The address to get a penalty
    public immutable PublicKey penalty_address;

    // Enrollment manager
    private EnrollmentManager enroll_man;

    /***************************************************************************

        Constructor

        Params:
            enroll_man = the EnrollmentManager
            params = the consensus-critical constants

    ***************************************************************************/

    public this (EnrollmentManager enroll_man, immutable(ConsensusParams) params)
    {
        this.enroll_man = enroll_man;
        this.penalty_amount = params.SlashPenaltyAmount;
        this.penalty_address = params.CommonsBudgetAddress;
    }

    /***************************************************************************

        Get the validators that do not reveal their pre-images and will be
        slashed through the consensus procoess.

        Params:
            missing_validators = will contain the validators
            height = the desired block height to look up the validators for

    ***************************************************************************/

    public void getMissingValidators (ref uint[] missing_validators,
        in Height height) @safe nothrow
    {
        missing_validators.length = 0;
        () @trusted { assumeSafeAppend(missing_validators); }();

        Hash[] keys;
        if (!this.enroll_man.getEnrolledUTXOs(keys) || keys.length == 0)
        {
            log.fatal("Could not retrieve enrollments / no enrollments found");
            assert(0);
        }

        foreach (idx, utxo_key; keys)
        {
            if (!this.hasRevealedPreimage(height, utxo_key))
            {
                missing_validators ~= cast(uint)idx;
            }
        }
    }

    /***************************************************************************

        Get the UTXOs of the validators that do not reveal their pre-images
        by indices

        Params:
            validators_utxos = will contain the UTXOs ot the validators
            missing_validators = indices of validators being slashed

    ***************************************************************************/

    public void getMissingValidatorsUTXOs (ref Hash[] validators_utxos,
        const uint[] missing_validators) @safe nothrow
    {
        validators_utxos.length = 0;
        () @trusted { assumeSafeAppend(validators_utxos); }();

        Hash[] keys;
        if (!this.enroll_man.getEnrolledUTXOs(keys))
        {
            log.fatal("Could not retrieve enrollments");
            assert(0);
        }

        foreach (idx; missing_validators)
        {
            validators_utxos ~= keys[idx];
        }
    }

    /***************************************************************************

        Get the random seed reduced from the preimages for the provided
        block height.

        Params:
            height = the desired block height to look up the hash for

        Returns:
            the random seed if there are one or more valid preimages,
            otherwise Hash.init.

    ***************************************************************************/

    public Hash getRandomSeed (in Height height) @safe nothrow
    {
        Hash[] keys;
        if (!this.enroll_man.getEnrolledUTXOs(keys) || keys.length == 0)
        {
            log.fatal("Could not retrieve enrollments / no enrollments found");
            assert(0);
        }

        Hash[] valid_keys;
        foreach (key; keys)
        {
            if (this.hasRevealedPreimage(height, key))
                valid_keys ~= key;
        }

        // NOTE: The random seed of `Hash.init` value is currently
        // checked in the `validateSlashingData` function of `Ledger`.
        if (valid_keys.length == 0)
            return Hash.init;

        return this.enroll_man.getRandomSeed(valid_keys, height);
    }

    /***************************************************************************

        Get the random seed reduced from the preimages of validators
        except the provided 'missing_validators'.

        Params:
            height = the desired block height to look up the hash for
            missing_validators = the validators that did not reveal their
                preimages for the height

        Returns:
            the random seed if there are one or more valid preimages,
            otherwise Hash.init.

    ***************************************************************************/

    public Hash getExternalizedRandomSeed (in Height height,
        const ref uint[] missing_validators) @safe nothrow
    {
        Hash[] keys;
        if (!this.enroll_man.getEnrolledUTXOs(keys) || keys.length == 0)
        {
            log.fatal("Could not retrieve enrollments / no enrollments found");
            assert(0);
        }

        Hash[] valid_keys;
        foreach (idx, key; keys)
        {
            if (missing_validators.find(idx).empty())
                valid_keys ~= key;
        }

        return this.enroll_man.getRandomSeed(valid_keys, height);
    }

    /***************************************************************************

        Check if a validator has a pre-image for the height

        Params:
            height = the desired block height to look up the hash for
            utxo_key = the UTXO key idendifying a validator

        Returns:
            true if the validator has revealed its preimage for the provided
                block height

    ***************************************************************************/

    private bool hasRevealedPreimage (in Height height, in Hash utxo_key)
        @safe nothrow
    {
        if (utxo_key == this.enroll_man.getEnrollmentKey())
            return true;

        auto preimage = this.enroll_man.getValidatorPreimage(utxo_key);
        auto enrolled = this.enroll_man.getEnrolledHeight(preimage.enroll_key);
        assert(height >= enrolled);
        if (preimage.distance >= cast(ushort)(height - enrolled))
            return true;
        else
            return false;
    }

    /***************************************************************************

        Check if information for pre-images and slashed validators is valid

        Params:
            height = the height of proposed block
            missing_validators = list of indices to the validator UTXO set
                which have not revealed the preimage

        Returns:
            `null` if the information is valid at the proposed height,
            otherwise a string explaining the reason it is invalid.

    ***************************************************************************/

    public string isInvalidPreimageRootReason (Height height,
        const ref uint[] missing_validators) @safe
    {
        Hash[] keys;
        if (!this.enroll_man.getEnrolledUTXOs(keys) || keys.length == 0)
        {
            log.fatal("Could not retrieve enrollments / no enrollments found");
            assert(0);
        }

        auto enroll_index = this.enroll_man.getIndexOfEnrollment();
        if (enroll_index != ulong.max && !missing_validators.find(enroll_index).empty)
        {
            log.fatal("The node is slashing itself.");
            assert(0);
        }

        uint[] local_missing_validators;
        foreach (idx, key; keys)
        {
            if (!this.hasRevealedPreimage(height, key))
                local_missing_validators ~= cast(uint)idx;
        }

        if (local_missing_validators != missing_validators)
            return "The list of missing validators does not match with the local one. " ~
                "The local missing validators: " ~ to!string(local_missing_validators);

        return null;
    }
}

// Test for getting the candidates to be slashed due to missing pre-images
unittest
{
    import agora.consensus.data.Transaction;
    import agora.consensus.PreImage;
    import agora.consensus.state.UTXOSet;
    import agora.crypto.Hash;
    import agora.crypto.Schnorr;

    import std.algorithm;
    import std.format;
    import std.range;

    import TESTNET = agora.consensus.data.genesis.Test;

    scope utxo_set = new TestUTXOSet;
    Hash[] utxo_hashes;

    // genesisSpendable returns 8 outputs
    auto pairs = iota(8).map!(idx => WK.Keys[idx]).array;
    genesisSpendable()
        .enumerate
        .map!(tup => tup.value
            .refund(pairs[tup.index].address)
            .sign(TxType.Freeze))
        .each!((tx) {
            utxo_set.put(tx);
            utxo_hashes ~= UTXO.getHash(tx.hashFull(), 0);
        });

    ConsensusConfig conf = { slash_penalty_amount: 20_000.coins };
    auto params = new immutable(ConsensusParams)(
        TESTNET.GenesisBlock,
        TESTNET.CommonsBudgetAddress,
        conf);
    scope enroll_man = new EnrollmentManager(":memory:", WK.Keys.A, params);

    // create 8 enrollments
    Enrollment[] enrollments;
    PreImageCache[] caches;
    foreach (idx, kp; pairs)
    {
        auto pair = Pair.fromScalar(secretKeyToCurveScalar(kp.secret));
        auto cycle = PreImageCycle(
                0, 0,
                PreImageCache(PreImageCycle.NumberOfCycles, params.ValidatorCycle),
                PreImageCache(params.ValidatorCycle, 1));
        const seed = cycle.populate(pair.v, true);
        caches ~= cycle.preimages;
        auto enroll = EnrollmentManager.makeEnrollment(
            pair, utxo_hashes[idx], params.ValidatorCycle,
            seed, idx);
        assert(enroll_man.addEnrollment(enroll, kp.address, Height(1),
                &utxo_set.peekUTXO));
        enrollments ~= enroll;
    }

    // 8 validators(=enrollments) are enrolled at the height of 1
    UTXO[Hash] self_utxos;
    self_utxos[utxo_hashes[0]] = utxo_set[utxo_hashes[0]];
    foreach (idx, enroll; enrollments)
        assert(enroll_man.addValidator(enroll, pairs[idx].address, Height(1),
            &utxo_set.peekUTXO, self_utxos) is null);
    assert(enroll_man.validatorCount() == 8);

    // create slashing manager
    scope slash_man = new SlashPolicy(enroll_man, params);
    assert(slash_man.penalty_amount == Amount(200_000_000_000L));

    // get all the validators and find index of the first and second validastors
    uint first_validator;
    uint second_validator;
    Hash first_validator_utxo;
    Hash second_validator_utxo;
    Hash[] utxos;
    assert(enroll_man.getEnrolledUTXOs(utxos));
    foreach (idx, utxo; utxos)
        if (utxo == enrollments[0].utxo_key)
        {
            first_validator = cast(uint)idx;
            first_validator_utxo = utxo;
            break;
        }
    foreach (idx, utxo; utxos)
        if (utxo == enrollments[1].utxo_key)
        {
            second_validator = cast(uint)idx;
            second_validator_utxo = utxo;
            break;
        }

    // the first validator reveals a pre-image
    PreImageInfo preimage_1 = PreImageInfo(
        enrollments[0].utxo_key,
        caches[0][$ - 2],
        1
    );
    assert(hashFull(preimage_1.hash) == enrollments[0].random_seed);
    enroll_man.addPreimage(preimage_1);
    auto gotten_image = enroll_man.getValidatorPreimage(enrollments[0].utxo_key);
    assert(preimage_1 == gotten_image);

    // the second validator reveals a pre-image
    PreImageInfo preimage_2 = PreImageInfo(
        enrollments[1].utxo_key,
        caches[1][$ - 2],
        1
    );
    assert(hashFull(preimage_2.hash) == enrollments[1].random_seed);
    enroll_man.addPreimage(preimage_2);
    gotten_image = enroll_man.getValidatorPreimage(enrollments[1].utxo_key);
    assert(preimage_2 == gotten_image);

    // check missing pre-image at the current height of 2
    uint[] missing_validators;
    slash_man.getMissingValidators(missing_validators, Height(2));
    assert(missing_validators.length == 6,
            format!"Current missing preimage validaters: %s"
                (missing_validators.length));
    assert(missing_validators.find(first_validator).empty());
    assert(missing_validators.find(second_validator).empty());

    // check the error string for invalid missing validators
    const expected_res = "The list of missing validators does not match with the local one. The local missing validators: [0, 1, 3, 4, 5, 7]";
    uint[] fake_missing_validators = [];
    auto actual_res = slash_man.isInvalidPreimageRootReason(Height(2), fake_missing_validators);
    assert(actual_res == expected_res, actual_res);

    // get the UTXOs of the validators that do not reveals preimages
    Hash[] validators_utxos;
    slash_man.getMissingValidatorsUTXOs(validators_utxos, missing_validators);
    assert(validators_utxos.find(first_validator_utxo).empty());
    assert(validators_utxos.find(second_validator_utxo).empty());

    // get and check random seed
    Hash preimage_root = slash_man.getRandomSeed(Height(2));
    assert(preimage_root ==
        hashMulti(hashMulti(Hash.init, preimage_2), preimage_1));

    // get and check random seed when a block being externalized
    Hash externalized_seed = slash_man.getExternalizedRandomSeed(Height(2),
        missing_validators);
    assert(externalized_seed ==
        hashMulti(hashMulti(Hash.init, preimage_2), preimage_1));
}
