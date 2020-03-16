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
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreimageInfo;
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

    /// Random seed
    private Scalar random_seed_src;

    /// Preimages of hashes of random value
    public Hash[] preimages;

    /// Random key for enrollment
    private Pair signature_noise;

    /// Enrollment data object
    private Enrollment data;

    /// Next height for pre-image revelation
    private ulong next_reveal_height;

    /// The cycle length for a validator
    public static immutable uint ValidatorCycle = 1008; // freezing period / 2

    /// The period for revealing a preimage
    /// It is an hour interval if a block is made in every 10 minutes
    public static immutable uint PreimageRevealPeriod = 6;

    /// Validator set managing validators' information such as Enrollment object
    /// enrolled height, and preimages.
    private ValidatorSet validator_set;

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

        // load signature noise
        auto results = this.db.execute("SELECT val FROM node_enroll_data " ~
            "WHERE key = ?", "signature_noise");

        foreach (row; results)
        {
            signature_noise = deserializeFull!Pair(row.peek!(ubyte[])(0));
            break;
        }

        // load preimages
        results = this.db.execute("SELECT val FROM node_enroll_data " ~
            "WHERE key = ?", "preimages");

        if (!results.empty)
            this.preimages = results.oneValue!(ubyte[]).deserializeFull!(Hash[]);

        // load enroll_key
        results = this.db.execute("SELECT val FROM node_enroll_data " ~
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
            enroll = will contain the Enrollment if created

        Returns:
            true if the enrollment manager succeeded in creating the Enrollment

    ***************************************************************************/

    public bool createEnrollment (Hash frozen_utxo_hash, out Enrollment enroll) @trusted nothrow
    {
        static ubyte[] buffer;
        buffer.length = 0;
        () @trusted { assumeSafeAppend(buffer); }();

        // K, frozen UTXO hash
        this.data.utxo_key = frozen_utxo_hash;
        this.enroll_key = frozen_utxo_hash;

        // N, cycle length
        this.data.cycle_length = ValidatorCycle;

        // generate random seed value
        this.random_seed_src = Scalar.random();

        // X, final seed data and preimages of hashes
        this.preimages.length = 0;
        assumeSafeAppend(this.preimages);
        this.preimages ~= hashFull(this.random_seed_src);
        foreach (i; 0 .. this.data.cycle_length-1)
            this.preimages ~= hashFull(this.preimages[i]);
        reverse(this.preimages);
        this.data.random_seed = this.preimages[0];

        // R, signature noise
        this.signature_noise = Pair.random();

        scope SerializeDg dg = (scope const(ubyte[]) data) nothrow @safe
        {
            buffer ~= data;
        };

        try
        {
            serializePart(this.signature_noise, dg);
        }
        catch (Exception ex)
        {
            this.logMessage("Serialization error", enroll, ex);
            return false;
        }

        try
        {
            () @trusted {
                auto results = this.db.execute("SELECT EXISTS(SELECT 1 FROM node_enroll_data " ~
                    "WHERE key = ?)", "signature_noise");
                if (results.oneValue!(bool))
                {
                    this.db.execute("UPDATE node_enroll_data SET val = ? WHERE key = ?",
                        buffer, "signature_noise");
                }
                else
                {
                    this.db.execute("INSERT INTO node_enroll_data (key, val) VALUES (?, ?)",
                        "signature_noise", buffer);
                }
            }();
        }
        catch (Exception ex)
        {
            this.logMessage("Database operation error", enroll, ex);
            return false;
        }

        // serialize preimages
        buffer.length = 0;
        assumeSafeAppend(buffer);
        try
        {
            serializePart(this.preimages, dg);
        }
        catch (Exception ex)
        {
            this.logMessage("Serialization error of preimages", enroll, ex);
            return false;
        }

        try
        {
            () @trusted {
                auto results = this.db.execute("SELECT EXISTS(SELECT 1 FROM node_enroll_data " ~
                    "WHERE key = ?)", "preimages");
                if (results.oneValue!(bool))
                {
                    this.db.execute("UPDATE node_enroll_data SET val = ? WHERE key = ?",
                        buffer, "preimages");
                }
                else
                {
                    this.db.execute("INSERT INTO node_enroll_data (key, val) VALUES (?, ?)",
                        "preimages", buffer);
                }
            }();
        }
        catch (Exception ex)
        {
            this.logMessage("Database operation error", enroll, ex);
            return false;
        }

        // save enroll_key
        buffer.length = 0;
        assumeSafeAppend(buffer);
        try
        {
            serializePart(this.enroll_key, dg);
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

        Set current block height

        The enrollment manager can weed out expired validators from the set
        based on the block height. Validators are deleted if their enrolled
        height is less than or equal to the value of the passed block height
        minus the validator cycle.

        Params:
            block_height = current block height

    ***************************************************************************/

    public void setCurrentBlockHeight (ulong block_height) @safe nothrow
    {
        this.validator_set.setCurrentBlockHeight(block_height);
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
            preimage = will contain the PreimageInfo if exists

        Returns:
            true if the pre-image exists

    ***************************************************************************/

    public bool getNextPreimage (out PreimageInfo preimage) @safe
    {
        auto height = this.next_reveal_height + PreimageRevealPeriod * 2;
        if (height > ValidatorCycle - 1)
            height = ValidatorCycle - 1;
        return getPreimage(height, preimage);
    }

    /***************************************************************************

        Get a pre-image at a certain height

        Params:
            height = the number of the height at which the pre-image exists
            preimage = will contain the PreimageInfo if exists

        Returns:
            true if the pre-image exists

    ***************************************************************************/

    public bool getPreimage (ulong height, out PreimageInfo preimage) @safe
    {
        const start_height =
            this.validator_set.getEnrolledHeight(this.enroll_key) + 1;
        if (height < start_height ||
            (height - start_height) > ValidatorCycle - 1)
            return false;

        preimage.enroll_key = this.data.utxo_key;
        preimage.height = height;
        preimage.hash = this.preimages[height - start_height];
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
            result_image = will contain the PreimageInfo if exists

        Returns:
            true if getting pre-image is successfully processed

    ***************************************************************************/

    public bool getValidatorPreimage (const ref Hash enroll_key,
        out PreimageInfo result_image) @trusted nothrow
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

    public bool addPreimage (const ref PreimageInfo preimage) @safe nothrow
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
        if (height >= this.next_reveal_height)
            return true;
        else
            return false;
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

    /***************************************************************************

        Load pre-images from the storage

        Returns:
            an array of hashes of pre-images

    ***************************************************************************/

    version (unittest) public Hash[] loadPreimages () @safe
    {
        Hash[] preimages;
        () @trusted {
            auto results = this.db.execute("SELECT val FROM node_enroll_data " ~
                "WHERE key = ?", "preimages");
            if (!results.empty)
                preimages = results.oneValue!(ubyte[]).deserializeFull!(Hash[]);
        }();

        return preimages;
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

    Pair signature_noise = Pair.random;
    Pair fail_enroll_key_pair;
    fail_enroll_key_pair.v = secretKeyToCurveScalar(gen_key_pair.secret);
    fail_enroll_key_pair.V = fail_enroll_key_pair.v.toPoint();

    fail_enroll.utxo_key = utxo_hash;
    fail_enroll.random_seed = hashFull(Scalar.random());
    fail_enroll.cycle_length = 1008;
    fail_enroll.enroll_sig = sign(fail_enroll_key_pair.v, fail_enroll_key_pair.V,
        signature_noise.V, signature_noise.v, fail_enroll);

    assert(man.createEnrollment(utxo_hash, enroll));
    assert(!man.hasEnrollment(utxo_hash));
    assert(!man.add(0, &storage.findUTXO, fail_enroll));
    assert(man.add(0, &storage.findUTXO, enroll));
    assert(man.count() == 1);
    assert(man.hasEnrollment(utxo_hash));
    assert(!man.add(0, &storage.findUTXO, enroll));

    // create and add the second Enrollment object
    auto utxo_hash2 = utxo_hashes[1];
    assert(man.createEnrollment(utxo_hash2, enroll2));
    assert(man.add(0, &storage.findUTXO, enroll2));
    assert(man.count() == 2);

    auto utxo_hash3 = utxo_hashes[2];
    Enrollment enroll3;
    assert(man.createEnrollment(utxo_hash3, enroll3));
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

    // check if the pre-images have right value
    assert(equal!((a, b) => a.hashFull() == b) (man.preimages[1 .. $],
        man.preimages[0 .. $-1]));

    // test serialization/deserializetion for pre-images
    assert(man.preimages[] == man.loadPreimages());

    // get a pre-image at a certain height
    // A validation can start at the height of the enrolled height plus 1.
    // So, a pre-image can only be got from the start height.
    PreimageInfo preimage;
    assert(man.createEnrollment(utxo_hash, enroll));
    assert(man.updateEnrolledHeight(utxo_hash, 10));
    assert(!man.getPreimage(10, preimage));
    assert(man.getPreimage(11, preimage));
    assert(man.getPreimage(10 + EnrollmentManager.ValidatorCycle, preimage));
    assert(!man.getPreimage(11 + EnrollmentManager.ValidatorCycle, preimage));

    /// test for the functions about periodic revelation of a pre-image
    assert(man.needRevealPreimage(10));
    man.increaseNextRevealHeight();
    assert(man.needRevealPreimage(16));

    // test for getting validators
    Enrollment[] validators;

    // validator A with the `utxo_hash` and the enrolled height of 10.
    // validator B with the 'utxo_hash2' and the enrolled height of 11.
    // validator C with the 'utxo_hash3' and no enrolled height.
    assert(man.updateEnrolledHeight(utxo_hash2, 11));

    // current block height is 1017
    // So, valid validator are validator A and validator B
    man.setCurrentBlockHeight(1017);
    assert(man.getValidators(validators));
    assert(validators.length == 2);

    // change the block height to 1018, which means validator A is expired.
    man.setCurrentBlockHeight(1018);
    assert(man.getValidators(validators));
    assert(validators[0].utxo_key == utxo_hash2);

    // set an enrolled height for validator C
    // set the block height to 1019, which means validator B is expired.
    // there is only one validator in the middle of 1020th block being made.
    assert(man.updateEnrolledHeight(utxo_hash3, 12));
    man.setCurrentBlockHeight(1019);
    assert(man.getValidators(validators));
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
    assert(man.createEnrollment(utxo_hash, enroll));
    assert(man.add(0, &storage.findUTXO, enroll));
    assert(man.hasEnrollment(utxo_hash));

    PreimageInfo result_image;
    assert(man.getValidatorPreimage(utxo_hash, result_image));
    assert(result_image == PreimageInfo.init);
    auto preimage = PreimageInfo(utxo_hash, man.preimages[100], 1100);
    assert(man.addPreimage(preimage));
    assert(man.getValidatorPreimage(utxo_hash, result_image));
    assert(result_image.enroll_key == utxo_hash);
    assert(result_image.hash == man.preimages[100]);
    assert(result_image.height == 1100);
}
