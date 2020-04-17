/*******************************************************************************

    Contains supporting code for enrollment process.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.EnrollmentManager;

import agora.common.crypto.ECC;
import agora.common.crypto.Key;
import agora.common.crypto.Schnorr;
import agora.common.Hash;
import agora.common.Serializer;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.UTXOSet;
import agora.consensus.Validation;
import agora.consensus.ValidatorSet;
import agora.utils.Log;

import d2sqlite3.database;
import d2sqlite3.library;
import d2sqlite3.results;
import d2sqlite3.sqlite3;

import std.algorithm;
import std.file;
import std.path;
import std.string;

mixin AddLogger!();

/*******************************************************************************

    Handle enrollment data and manage the validators set

*******************************************************************************/

public class EnrollmentManager
{
    /// SQLite db instance
    private Database db;

    /// Node's key pair
    private Pair key_pair;

    /// Key used for enrollment which is actually an UTXO hash
    private Hash enroll_key;

    /// Pre-images for each point with the interval of validator cycle
    private Hash[ulong] preimage_rounds;

    /// Pre-images for current validator cycle
    private Hash[ulong] cycle_preimages;

    /// Random key for enrollment
    private Pair signature_noise;

    /// Enrollment data object
    private Enrollment data;

    /// Next height for pre-image revelation
    private ulong next_reveal_height;

    /// The period for revealing a preimage
    /// It is an hour interval if a block is made in every 10 minutes
    public static immutable uint PreimageRevealPeriod = 6;

    /// Validator set managing validators' information such as Enrollment object
    /// enrolled height, and preimages.
    private ValidatorSet validator_set;

    /// The count for generating pre-images
    private immutable uint AllCountPreimages = ValidatorSet.ValidatorCycle * 100;

    /***************************************************************************

        Constructor

        Params:
            db_path = path to the database file, or in-memory storage if
                        :memory: was passed
            key_pair = the keypair of the owner node

    ***************************************************************************/

    public this (string db_path, KeyPair key_pair)
    {
        this.validator_set = new ValidatorSet(db_path);

        this.db = Database(db_path);

        // create the table for enrollment data for a node itself
        this.db.execute("CREATE TABLE IF NOT EXISTS node_enroll_data " ~
            "(key CHAR(128) PRIMARY KEY, val BLOB NOT NULL)");

        // create Pair object from KeyPair object
        this.key_pair.v = secretKeyToCurveScalar(key_pair.secret);
        this.key_pair.V = this.key_pair.v.toPoint();

        // load enroll_key
        auto results = this.db.execute("SELECT val FROM node_enroll_data " ~
            "WHERE key = ?", "enroll_key");

        if (!results.empty)
            this.enroll_key = results.oneValue!(ubyte[]).deserializeFull!(Hash);

        // load next height for preimage revelation
        this.next_reveal_height = this.getNextRevealHeight();
    }

    /***************************************************************************

        Shut down the database

        Note: this method must be called explicitly, and not inside of
        a destructor.

    ***************************************************************************/

    public void shutdown ()
    {
        this.db.close();
        this.validator_set.shutdown();
    }

    /***************************************************************************

        Add a enrollment data to the validators set

        Params:
            block_height = the current block height in the ledger
            finder = the delegate to find UTXOs with
            enroll = the enrollment data to add

        Returns:
            true if the enrollment data has been added to the validator set

    ***************************************************************************/

    public bool add (ulong block_height, scope UTXOFinder finder,
        const ref Enrollment enroll) @safe nothrow
    {
        return this.validator_set.add(block_height, finder, enroll);
    }

    /***************************************************************************

        Returns:
            the number of enrollments being managed by this EnrollmentManager.
            Note: this includes both registered and un-registered enrollments.

    ***************************************************************************/

    public size_t count () @safe
    {
        return this.validator_set.count();
    }

    /***************************************************************************

        Remove the enrollment data with the given key from the validator set

        Params:
            enroll_hash = key for an enrollment data to remove

    ***************************************************************************/

    public void remove (const ref Hash enroll_hash) @trusted
    {
        this.validator_set.remove(enroll_hash);
    }

    /***************************************************************************

        In validatorSet DB, return the enrolled block height.

        Params:
            enroll_hash = key for an enrollment block height

        Returns:
            the enrolled block height, or 0 if no matching key exists

    ***************************************************************************/

    public size_t getEnrolledHeight (const ref Hash enroll_hash) @trusted
    {
        return this.validator_set.getEnrolledHeight(enroll_hash);
    }

    /***************************************************************************

        Update the enrolled height of the validatorSet DB.

        Params:
            enroll_hash = enrollment blockheight to update enroll hash
            block_height = enrolled blockheight

        Returns:
            true if the update operation was successful, false otherwise

    ***************************************************************************/

    public bool updateEnrolledHeight (const ref Hash enroll_hash,
        const size_t block_height) @safe
    {
        if (!this.validator_set.updateEnrolledHeight(enroll_hash, block_height))
            return false;

        // set next height for revealing a pre-image
        if (enroll_hash == this.enroll_key)
            this.setNextRevealHeight(block_height);

        return true;
    }

    /***************************************************************************

        Make an enrollment data for enrollment process

        Params:
            frozen_utxo_hash = the hash of a frozen UTXO used to identify a validator
                        and to generate a siging key
            height = the starting index for generating pre-images
            enroll = will contain the Enrollment if created

        Returns:
            true if the enrollment manager succeeded in creating the Enrollment

    ***************************************************************************/

    public bool createEnrollment (Hash frozen_utxo_hash, ulong height,
        out Enrollment enroll) @trusted nothrow
    {
        static ubyte[] buffer;

        // K, frozen UTXO hash
        this.data.utxo_key = frozen_utxo_hash;
        this.enroll_key = frozen_utxo_hash;

        // N, cycle length
        this.data.cycle_length = ValidatorSet.ValidatorCycle;

        // X, final seed data and preimages of hashes
        this.data.random_seed = this.generatePreimages(height);

        // R, signature noise
        this.signature_noise = this.createSignatureNoise(height);

        // save enroll_key
        try
        {
            serializeToBuffer(this.enroll_key, buffer);
        }
        catch (Exception ex)
        {
            this.logMessage("Serialization error of enroll_key", enroll, ex);
            return false;
        }

        try
        {
            () @trusted {
                auto results = this.db.execute("SELECT EXISTS(SELECT 1 FROM " ~
                    "node_enroll_data WHERE key = ?)", "enroll_key");
                if (results.oneValue!(bool))
                    this.db.execute("UPDATE node_enroll_data SET val = ? " ~
                        "WHERE key = ?", buffer, "enroll_key");
                else
                    this.db.execute("INSERT INTO node_enroll_data (key, val)" ~
                        " VALUES (?, ?)", "enroll_key", buffer);
            }();
        }
        catch (Exception ex)
        {
            this.logMessage("Database operation error", enroll, ex);
            return false;
        }

        // signature
        data.enroll_sig = sign(this.key_pair.v, this.key_pair.V, this.signature_noise.V,
            this.signature_noise.v, this.data);

        enroll = this.data;
        return true;
    }

    /***************************************************************************

        Check if a enrollment data exists in the validator set.

        Params:
            enroll_hash = key for an enrollment data which is hash of frozen UTXO

        Returns:
            true if the validator set has the enrollment data

    ***************************************************************************/

    public bool hasEnrollment (const ref Hash enroll_hash) @trusted
    {
        return this.validator_set.hasEnrollment(enroll_hash);
    }

    /***************************************************************************

        Get the enrollment data with the key, and store it to 'enroll' if found

        Params:
            enroll_hash = key for an enrollment data which is a hash of a frozen
                            UTXO
            enroll = will contain the enrollment data if found

        Returns:
            Return true if the enrollment data was found

    ***************************************************************************/

    public bool getEnrollment (const ref Hash enroll_hash,
        out Enrollment enroll) @trusted
    {
        return this.validator_set.getEnrollment(enroll_hash, enroll);
    }

    /***************************************************************************

        Get all the current validators

        Params:
            validators = will be filled with all the validators during
                their validation cycles

        Returns:
            Return true if there is no error in getting validators

    ***************************************************************************/

    public bool getValidators (out Enrollment[] validators) @safe nothrow
    {
        return this.validator_set.getValidators(validators);
    }

    /***************************************************************************

        Clear up expired validators whose cycle for a validator ends

        The enrollment manager clears up expired validators from the set based
        on the block height.

        Params:
            block_height = current block height

    ***************************************************************************/

    public void clearExpiredValidators (ulong block_height) @safe nothrow
    {
        this.validator_set.clearExpiredValidators(block_height);
    }

    /***************************************************************************

        Get the unregistered enrollments in the block
        And this is arranged in ascending order with the utxo_key

        Params:
            enrolls = will contain the unregistered enrollments data if found

        Returns:
            The unregistered enrollments data

    ***************************************************************************/

    public Enrollment[] getUnregistered (ref Enrollment[] enrolls)
        @trusted
    {
        return this.validator_set.getUnregistered(enrolls);
    }

    /***************************************************************************

        Get a pre-image for revelation

        Params:
            preimage = will contain the PreImageInfo if exists

        Returns:
            true if the pre-image exists

    ***************************************************************************/

    public bool getNextPreimage (out PreImageInfo preimage) @safe
    {
        auto height = this.next_reveal_height + PreimageRevealPeriod * 2;
        return getPreimage(height, preimage);
    }

    /***************************************************************************

        Get a pre-image at a certain height

        Params:
            height = the number of the height at which the pre-image exists
            preimage = will contain the PreImageInfo if exists

        Returns:
            true if the pre-image exists

    ***************************************************************************/

    public bool getPreimage (ulong height, out PreImageInfo preimage) @safe
    {
        const start_height =
            this.validator_set.getEnrolledHeight(this.enroll_key) + 1;
        if (height < start_height ||
            (height - start_height) > ValidatorSet.ValidatorCycle - 1)
            return false;

        if (height !in this.cycle_preimages)
            this.generatePreimages(height);

        preimage.enroll_key = this.data.utxo_key;
        preimage.height = height;
        preimage.hash = this.cycle_preimages[height];
        return true;
    }

    /***************************************************************************

        Check if a pre-image exists

        Params:
            enroll_key = The key for the enrollment in which the pre-image is
                contained.
            height = The block height of the preimage to check existence

        Returns:
            true if the pre-image exists

    ***************************************************************************/

    public bool hasPreimage (const ref Hash enroll_key, ulong height) @safe
        nothrow
    {
        return this.validator_set.hasPreimage(enroll_key, height);
    }

    /***************************************************************************

        Get validator's pre-image from the validator set

        Params:
            enroll_key = The key for the enrollment in which the pre-image is
                contained.
            result_image = will contain the PreImageInfo if exists

        Returns:
            true if getting pre-image is successfully processed

    ***************************************************************************/

    public bool getValidatorPreimage (const ref Hash enroll_key,
        out PreImageInfo result_image) @trusted nothrow
    {
        return this.validator_set.getPreimage(enroll_key, result_image);
    }

    /***************************************************************************

        Add a pre-image information to a validator data

        Params:
            preimage = the pre-image information to add

        Returns:
            true if the pre-image information has been added to the validator

    ***************************************************************************/

    public bool addPreimage (const ref PreImageInfo preimage) @safe nothrow
    {
        return this.validator_set.addPreimage(preimage);
    }

    /***************************************************************************

        Check if revealing a pre-image is needed at a certain height

        Params:
            height = block height to check

        Returns:
            true if revealing a pre-image is needed

    ***************************************************************************/

    public bool needRevealPreimage (ulong height) @safe nothrow
    {
        return height >= this.next_reveal_height;
    }

    /***************************************************************************

        Increase the next reveal height by the revelation period

    ***************************************************************************/

    public void increaseNextRevealHeight () @safe nothrow
    {
        ulong next_height = this.getNextRevealHeight();
        if (this.next_reveal_height < ulong.max)
            this.setNextRevealHeight(next_height + PreimageRevealPeriod);
    }

    /***************************************************************************

        Restore validators' information from block

        Params:
            last_height = the latest block height
            block = the block to update the validator set with
            finder = the delegate to find UTXOs with

    ***************************************************************************/

    public void restoreValidators (ulong last_height, const ref Block block,
        scope UTXOFinder finder) @safe nothrow
    {
        this.validator_set.restoreValidators(last_height, block, finder);
    }

    /***************************************************************************

        Get the next block height to reveal a pre-image

        Returns:
            the next block height to reveal a pre-image. if any problem in
            getting the value, it returns the MAX ulong value.

    ***************************************************************************/

    private ulong getNextRevealHeight () @safe nothrow
    {
        ulong next_height = ulong.max;
        try
        {
            () @trusted {
                auto results = this.db.execute("SELECT val FROM node_enroll_data " ~
                    "WHERE key = ?", "next_reveal_height");
                if (!results.empty)
                    next_height = results.oneValue!(size_t);
            }();
        }
        catch (Exception ex)
        {
            log.error("Database operation error {}", ex);
        }
        return next_height;
    }

    /***************************************************************************

        Set the next block height to reveal a pre-image

        Params:
            height = the next block height to reveal a pre-image

    ***************************************************************************/

    private void setNextRevealHeight (ulong height) @safe nothrow
    {
        try
        {
            () @trusted {
                auto results = this.db.execute("SELECT EXISTS(SELECT 1 FROM " ~
                    "node_enroll_data WHERE key = ?)", "next_reveal_height");
                if (results.oneValue!(bool))
                    this.db.execute("UPDATE node_enroll_data SET val = ? " ~
                        "WHERE key = ?", height, "next_reveal_height");
                else
                    this.db.execute("INSERT INTO node_enroll_data (key, val)" ~
                        " VALUES (?, ?)", "next_reveal_height", height);

                this.next_reveal_height = height;
            }();
        }
        catch (Exception ex)
        {
            log.error("Database operation error {}", ex);
        }
    }

    /***************************************************************************

        Generate and store pre-images for this cycle, as well as sparsely
        selected preimages for other cycles.

        This generates all pre-images needed for a cycle in the range of less
        than two times of a validator cycle and store them in `cycle_preimages`.
        Additionally, It generates and stores pre-images being used for defined
        number of cycles in `preimage_rounds` when there is no pre-image needed.
        This function is very expensive, but should be seldom called, and might
        take more than 30ms for generating a hundred thousand number of them.

        Params:
            height = block height used to determine which range of
                pre-images will be generated.

        Returns:
            the pre-image value in index of `height`

    ***************************************************************************/

    private Hash generatePreimages (ulong height) @safe nothrow
    {
        // This determines which range of preimages must be generated.
        // In order to get hash values more than one cycle, the `start_height`
        // is to be the height of the last preimage of next cycle. The value of
        // `height / ValidatorSet.ValidatorCycle` is the index of previous
        // cycle, so we need to plus 2 to the value in order to get the index
        // of the next cycle.
        ulong start_height =
            ((height / ValidatorSet.ValidatorCycle) + 2) *
                ValidatorSet.ValidatorCycle;

        // Clear if recreating pre-images is needed
        if (this.preimage_rounds.byKey.maxElement(0) < start_height)
        {
            () @trusted {
                this.preimage_rounds.clear();
            }();
        }

        // if there is no pre-image, the defined number of pre-images must
        // be generated with the interval of ValidatorCycle.
        if (this.preimage_rounds.length == 0)
        {
            // The value of `bulk_index` is zero-based. so we need to plus 1 to
            // the value to get the max height(`MaxHeight`) of this bulk.
            ulong bulk_index = start_height / AllCountPreimages;
            const ulong MaxHeight = (bulk_index + 1) * AllCountPreimages;
            auto hash = hashMulti(this.key_pair.v, "consensus.preimages", bulk_index);
            ulong idx = MaxHeight;
            this.preimage_rounds[idx] = hash;
            for (--idx; idx >= height; --idx)
            {
                hash = hashFull(hash);
                if (idx % ValidatorSet.ValidatorCycle == 0)
                    this.preimage_rounds[idx] = hash;
            }
        }

        return this.populateCycleCache(this.preimage_rounds[start_height], start_height);
    }

    /***************************************************************************

        This generates all the sequential pre-images from `height` and
        stores them in the `cycle_preimages` cache.

        Params:
            seed = The initial value for this round to derive pre-images from.
            height = height at which the seed is.

        Returns:
            The last value for the cycle

    ***************************************************************************/

    public Hash populateCycleCache (Hash seed, ulong height) @safe nothrow
    {
        // Clear previous cycle data
        () @trusted { this.cycle_preimages.clear(); }();

        // Load first entry from the rounds
        this.cycle_preimages[height] = seed;
        // Fill the cache
        foreach (idx; 1 .. ValidatorSet.ValidatorCycle * 2)
        {
            seed = hashFull(seed);
            this.cycle_preimages[height - idx] = seed;
        }
        // Return the last entry in the cache
        return seed;
    }

    /***************************************************************************

        Create signature noise for enrollment data.

        It creates a signature noise for enrollment data by hashing the private
        key, the constant value which states the "purpose", and non-constant
        value like a block height. This makes the enrollment data for a
        validator recoverable in any abnormal situation.

        Params:
            height = the height used for a salt value

        Returns:
            the signature noise created using the private key

    ***************************************************************************/

    private Pair createSignatureNoise (ulong height) nothrow @safe @nogc
    {
        Pair key_pair;
        key_pair.v = Scalar(hashMulti(this.key_pair.v,
            "consensus.signature.noise", height));
        key_pair.V = key_pair.v.toPoint();
        return key_pair;
    }

    /***************************************************************************

        Logs message

        Params:
            msg = the log message to be logged
            enroll = the Enrollment object, the information of which will be logged
            ex = the Exception object, the message of which will be logged

    ***************************************************************************/

    private static void logMessage (string msg, const ref Enrollment enroll,
        const Exception ex = null) @safe nothrow
    {
        try
        {
            if (ex !is null)
            {
                log.error("{}, enrollment:{}, exception:{}", msg, enroll, ex);
            }
            else
            {
                log.info("{}, enrollment:{}", msg, enroll);
            }
        }
        catch (Exception ex)
        {}
    }
}

/// tests for member functions of EnrollmentManager
unittest
{
    import agora.common.Amount;
    import agora.consensus.data.Transaction;
    import agora.consensus.Genesis;
    import std.algorithm;
    import std.format;
    import std.conv;

    scope storage = new TestUTXOSet;

    auto gen_key_pair = getGenesisKeyPair();
    KeyPair key_pair = KeyPair.random();

    foreach (idx; 0 .. 8)
    {
        auto input = Input(hashFull(GenesisTransaction), idx.to!uint);

        Transaction tx =
        {
            TxType.Freeze,
            [input],
            [Output(Amount.MinFreezeAmount, key_pair.address)]
        };

        auto signature = gen_key_pair.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        storage.put(tx);
    }

    // create an EnrollmentManager object
    auto man = new EnrollmentManager(":memory:", key_pair);
    scope (exit) man.shutdown();
    Hash[] utxo_hashes = storage.keys;

    // create and add the first Enrollment object
    auto utxo_hash = utxo_hashes[0];
    Enrollment enroll;
    Enrollment enroll2;
    Enrollment fail_enroll;

    Pair signature_noise = man.createSignatureNoise(1);
    Pair fail_enroll_key_pair;
    fail_enroll_key_pair.v = secretKeyToCurveScalar(gen_key_pair.secret);
    fail_enroll_key_pair.V = fail_enroll_key_pair.v.toPoint();

    fail_enroll.utxo_key = utxo_hash;
    fail_enroll.random_seed = hashFull(Scalar.random());
    fail_enroll.cycle_length = 1008;
    fail_enroll.enroll_sig = sign(fail_enroll_key_pair.v, fail_enroll_key_pair.V,
        signature_noise.V, signature_noise.v, fail_enroll);

    assert(man.createEnrollment(utxo_hash, 1, enroll));
    assert(!man.hasEnrollment(utxo_hash));
    assert(!man.add(0, &storage.findUTXO, fail_enroll));
    assert(man.add(0, &storage.findUTXO, enroll));
    assert(man.count() == 1);
    assert(man.hasEnrollment(utxo_hash));
    assert(!man.add(0, &storage.findUTXO, enroll));

    // create and add the second Enrollment object
    auto utxo_hash2 = utxo_hashes[1];
    assert(man.createEnrollment(utxo_hash2, 1, enroll2));
    assert(man.add(0, &storage.findUTXO, enroll2));
    assert(man.count() == 2);

    auto utxo_hash3 = utxo_hashes[2];
    Enrollment enroll3;
    assert(man.createEnrollment(utxo_hash3, 1, enroll3));
    assert(man.add(0, &storage.findUTXO, enroll3));
    assert(man.count() == 3);

    Enrollment[] enrolls;
    man.getUnregistered(enrolls);
    assert(enrolls.length == 3);
    assert(enrolls.isStrictlyMonotonic!("a.utxo_key < b.utxo_key"));

    // get a stored Enrollment object
    Enrollment stored_enroll;
    assert(man.getEnrollment(utxo_hash2, stored_enroll));
    assert(stored_enroll == enroll2);

    // remove an Enrollment object
    man.remove(utxo_hash2);
    assert(man.count() == 2);

    // test for getEnrollment with removed enrollment
    assert(!man.getEnrollment(utxo_hash2, stored_enroll));

    // test for enrollment block height update
    assert(!man.getEnrolledHeight(utxo_hash));
    assert(man.updateEnrolledHeight(utxo_hash, 9));
    assert(man.getEnrolledHeight(utxo_hash) == 9);
    assert(!man.updateEnrolledHeight(utxo_hash, 9));
    assert(man.getEnrolledHeight(utxo_hash2) == 0);
    man.getUnregistered(enrolls);
    assert(enrolls.length == 1);
    assert(man.count() == 2);  // has not changed

    man.remove(utxo_hash);
    man.remove(utxo_hash2);
    man.remove(utxo_hash3);
    assert(man.getUnregistered(enrolls).length == 0);

    Enrollment[] ordered_enrollments;
    ordered_enrollments ~= enroll;
    ordered_enrollments ~= enroll2;
    ordered_enrollments ~= enroll3;
    // Reverse ordering
    ordered_enrollments.sort!("a.utxo_key > b.utxo_key");
    foreach (ordered_enroll; ordered_enrollments)
        assert(man.add(0, &storage.findUTXO, ordered_enroll));
    man.getUnregistered(enrolls);
    assert(enrolls.length == 3);
    assert(enrolls.isStrictlyMonotonic!("a.utxo_key < b.utxo_key"));

    // get a pre-image at a certain height
    // A validation can start at the height of the enrolled height plus 1.
    // So, a pre-image can only be got from the start height.
    PreImageInfo preimage;
    assert(man.createEnrollment(utxo_hash, 1, enroll));
    assert(man.updateEnrolledHeight(utxo_hash, 10));
    assert(!man.getPreimage(10, preimage));
    assert(man.getPreimage(11, preimage));
    assert(man.getPreimage(10 + ValidatorSet.ValidatorCycle, preimage));
    assert(!man.getPreimage(11 + ValidatorSet.ValidatorCycle, preimage));

    /// test for the functions about periodic revelation of a pre-image
    assert(man.needRevealPreimage(10));
    man.increaseNextRevealHeight();
    assert(man.needRevealPreimage(16));

    // If the height of the requested preimage exceeds the height of the end of
    // the validator cycle, the `getNextPreimage` must return `false`.
    man.next_reveal_height = 10 + ValidatorSet.ValidatorCycle;
    assert(!man.getNextPreimage(preimage));

    // test for getting validators
    Enrollment[] validators;

    // validator A with the `utxo_hash` and the enrolled height of 10.
    // validator B with the 'utxo_hash2' and the enrolled height of 11.
    // validator C with the 'utxo_hash3' and no enrolled height.
    assert(man.updateEnrolledHeight(utxo_hash2, 11));
    man.clearExpiredValidators(11);
    assert(man.getValidators(validators));
    assert(validators.length == 2);

    // set an enrolled height for validator C
    // set the block height to 1019, which means validator B is expired.
    // there is only one validator in the middle of 1020th block being made.
    assert(man.updateEnrolledHeight(utxo_hash3, 1019));
    man.clearExpiredValidators(1019);
    assert(man.getValidators(validators));
    assert(validators.length == 1);
    assert(validators[0].utxo_key == utxo_hash3);
}

/// tests for addPreimage and getValidatorPreimage
unittest
{
    import agora.common.Amount;
    import agora.consensus.data.Transaction;
    import agora.consensus.Genesis;
    import std.conv;

    scope storage = new TestUTXOSet;
    auto gen_key_pair = getGenesisKeyPair();
    KeyPair key_pair = KeyPair.random();

    foreach (idx; 0 .. 8)
    {
        auto input = Input(hashFull(GenesisTransaction), idx.to!uint);

        Transaction tx =
        {
            TxType.Freeze,
            [input],
            [Output(Amount.MinFreezeAmount, key_pair.address)]
        };

        auto signature = gen_key_pair.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        storage.put(tx);
    }

    auto man = new EnrollmentManager(":memory:", key_pair);
    scope (exit) man.shutdown();
    Hash[] utxo_hashes = storage.keys;

    auto utxo_hash = utxo_hashes[0];
    Enrollment enroll;
    assert(man.createEnrollment(utxo_hash, 1, enroll));
    assert(man.add(0, &storage.findUTXO, enroll));
    assert(man.hasEnrollment(utxo_hash));

    PreImageInfo result_image;
    assert(man.getValidatorPreimage(utxo_hash, result_image));
    assert(result_image == PreImageInfo.init);
    auto preimage = PreImageInfo(utxo_hash, man.cycle_preimages[100], 1100);
    assert(man.addPreimage(preimage));
    assert(man.getValidatorPreimage(utxo_hash, result_image));
    assert(result_image.enroll_key == utxo_hash);
    assert(result_image.hash == man.cycle_preimages[100]);
    assert(result_image.height == 1100);
}
