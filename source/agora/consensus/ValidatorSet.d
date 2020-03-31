/*******************************************************************************

    Contains supporting code for managing validators' information
    using SQLite as a backing store, including the enrolled height
    which means enrollment process is confirmed as part of consensus.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.ValidatorSet;

import agora.common.crypto.ECC;
import agora.common.crypto.Key;
import agora.common.crypto.Schnorr;
import agora.common.Hash;
import agora.common.Serializer;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreimageInfo;
import agora.consensus.data.UTXOSet;
import agora.consensus.Validation;
import agora.utils.Log;

import d2sqlite3.database;
import d2sqlite3.library;
import d2sqlite3.results;
import d2sqlite3.sqlite3;

mixin AddLogger!();

/// Ditto
public class ValidatorSet
{
    /// SQLite db instance
    private Database db;

    /// The cycle length for a validator
    public static immutable uint ValidatorCycle = 1008; // freezing period / 2

    /***************************************************************************

        Constructor

        Params:
            db_path = path to the database file, or in-memory storage if
                        :memory: was passed

    ***************************************************************************/

    public this (string db_path)
    {
        this.db = Database(db_path);

        // create the table for validator set if it doesn't exist yet
        this.db.execute("CREATE TABLE IF NOT EXISTS validator_set " ~
            "(key TEXT PRIMARY KEY, val BLOB NOT NULL, " ~
            "enrolled_height INTEGER, preimage BLOB)");
    }

    /***************************************************************************

        Shut down the database

        Note: this method must be called explicitly, and not inside of
        a destructor.

    ***************************************************************************/

    public void shutdown ()
    {
        this.db.close();
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
        static ubyte[] buffer;

        // check validity of the enrollment data
        if (auto reason = isInvalidEnrollmentReason(enroll, block_height + 1,
            finder))
        {
            log.info("Invalid enrollment data: {}, Data was: {}", reason, enroll);
            return false;
        }

        // check if already exists
        if (this.hasEnrollment(enroll.utxo_key))
        {
            log.info("Rejected already existing enrollment, Data was: {}",
                enroll);
            return false;
        }

        try
        {
            serializeToBuffer(enroll, buffer);
        }
        catch (Exception ex)
        {
            log.error("Serialization error: {}, Data was: {}", ex.msg, enroll);
            return false;
        }

        try
        {
            () @trusted {
                this.db.execute("INSERT INTO validator_set (key, val) VALUES (?, ?)",
                    enroll.utxo_key.toString(), buffer);
            }();

        }
        catch (Exception ex)
        {
            log.error("Database operation error: {}, Data was: {}", ex.msg, enroll);
            return false;
        }

        return true;
    }

    /***************************************************************************

        Returns:
            the number of enrollments being managed by this EnrollmentManager,
            which includes both registered and un-registered enrollments.

    ***************************************************************************/

    public size_t count () @trusted
    {
        return this.db.execute("SELECT count(*) FROM validator_set").
            oneValue!size_t;
    }

    /***************************************************************************

        Remove the enrollment data with the given key from the validator set

        Params:
            enroll_hash = key for an enrollment data to remove

    ***************************************************************************/

    public void remove (const ref Hash enroll_hash) @trusted
    {
        this.db.execute("DELETE FROM validator_set WHERE key = ?",
            enroll_hash.toString());
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
        try
        {
            auto results = this.db.execute("SELECT enrolled_height FROM validator_set" ~
                " WHERE key = ?", enroll_hash.toString());
            if (results.empty)
                return size_t.init;

            return results.oneValue!(size_t);
        }
        catch (Exception ex)
        {
            log.error("Database operation error: {}", ex.msg);
            return size_t.init;
        }
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
        try
        {
            if (this.getEnrolledHeight(enroll_hash) > 0)
                return false;

            () @trusted {
                this.db.execute(
                    "UPDATE validator_set SET enrolled_height = ? WHERE key = ?",
                    block_height, enroll_hash.toString());
            }();
        }
        catch (Exception ex)
        {
            log.error("Database operation error on updateEnrolledHeight: {}, " ~
                "Key for enrollment: {}", ex.msg, enroll_hash);
            return false;
        }

        return true;
    }

    /***************************************************************************

        Check if a enrollment data exists in the validator set.

        Params:
            enroll_hash = key for an enrollment data which is hash of frozen UTXO

        Returns:
            true if the validator set has the enrollment data

    ***************************************************************************/

    public bool hasEnrollment (const ref Hash enroll_hash) @trusted nothrow
    {
        try
        {
            auto results = this.db.execute("SELECT EXISTS(SELECT 1 FROM " ~
                "validator_set WHERE key = ?)", enroll_hash.toString());
            return results.front().peek!bool(0);
        }
        catch (Exception ex)
        {
            log.error("Exception occured on hasEnrollment: {}, " ~
                "Key for enrollment: {}", ex.msg, enroll_hash);
            return false;
        }
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
        auto results = this.db.execute("SELECT key, val FROM validator_set " ~
            "WHERE key = ?", enroll_hash.toString());

        foreach (row; results)
        {
            enroll = deserializeFull!Enrollment(row.peek!(ubyte[])(1));
            return true;
        }

        return false;
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
        try
        {
            () @trusted {
                auto results = this.db.execute("SELECT val FROM validator_set" ~
                    " WHERE enrolled_height is not null");
                foreach (row; results)
                {
                    validators ~=
                        deserializeFull!Enrollment(row.peek!(ubyte[])(0));
                }
            }();
        }
        catch (Exception ex)
        {
            log.error("Database operation error: {}", ex.msg);
            return false;
        }

        return true;
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
        // the smallest enrolled height would be 1, so the passed block height
        // should be greater than the validator cycle for deleting validators.
        if (block_height > ValidatorCycle)
        {
            try
            {
                () @trusted {
                    this.db.execute("DELETE FROM validator_set WHERE " ~
                        "enrolled_height <= ?", block_height - ValidatorCycle);

                }();
            }
            catch (Exception ex)
            {
                log.error("Database operation error: {}", ex.msg);
            }
        }
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
        enrolls.length = 0;
        assumeSafeAppend(enrolls);
        auto results = this.db.execute("SELECT val FROM validator_set" ~
            " WHERE enrolled_height is null ORDER BY key ASC");

        foreach (row; results)
            enrolls ~= deserializeFull!Enrollment(row.peek!(ubyte[])(0));

        return enrolls;
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
        bool result = false;
        try
        {
            () @trusted {
                auto results = this.db.execute("SELECT preimage from " ~
                        "validator_set WHERE key = ?", enroll_key.toString());
                if (!results.empty && results.oneValue!(byte[]).length != 0)
                {
                    PreimageInfo loaded_image = results.
                        oneValue!(ubyte[]).deserializeFull!(PreimageInfo);
                    if (height <= loaded_image.height)
                        result = true;
                }
            }();
        }
        catch (Exception ex)
        {
            log.error("Exception occured on hasPreimage: {}, " ~
                "Key for enrollment: {}", ex.msg, enroll_key);
            return false;
        }
        return result;
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

    public bool getPreimage (const ref Hash enroll_key,
        out PreimageInfo result_image) @trusted nothrow
    {
        try
        {
            auto results = this.db.execute("SELECT preimage from validator_set" ~
                        " WHERE key = ?", enroll_key.toString());
            if (!results.empty && results.oneValue!(byte[]).length != 0)
            {
                result_image =
                    results.oneValue!(ubyte[]).deserializeFull!(PreimageInfo);
            }
        }
        catch (Exception ex)
        {
            log.error("Exception occured on getPreimage: {}, " ~
                "Key for enrollment: {}", ex.msg, enroll_key);
            return false;
        }

        return true;
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
        static ubyte[] buffer;

        // check if the enrollment data exists
        Enrollment stored_enroll;
        try
        {
            if (!this.getEnrollment(preimage.enroll_key, stored_enroll))
            {
                log.info("Rejected adding a pre-image for non-existing " ~
                    "enrollment, Preimage: {}", preimage);
                return false;
            }
        }
        catch (Exception ex)
        {
            log.error("Database operation error on addPreimage: {}, " ~
                "Preimage: {}", ex.msg, preimage);
            return false;
        }

        // check if already exists
        try
        {
            if (this.hasPreimage(preimage.enroll_key, preimage.height))
            {
                log.info("Rejected already existing pre-image, Preimage: {}",
                    preimage);
                return false;
            }
        }
        catch (Exception ex)
        {
            log.error("Database operation error on addPreimage: {}, " ~
                "Preimage: {}", ex.msg, preimage);
            return false;
        }

        // insert the pre-image into the table
        try
        {
            serializeToBuffer(preimage, buffer);
        }
        catch (Exception ex)
        {
            log.error("Serialization error on addPreimage: {}, Preimage: {}",
                ex.msg, preimage);
            return false;
        }

        try
        {
            () @trusted {
                this.db.execute("UPDATE validator_set SET preimage = ? " ~
                    "WHERE key = ?", buffer, preimage.enroll_key.toString());
            }();
        }
        catch (Exception ex)
        {
            log.error("Database operation error on addPreimage: {}, Preimage: {}",
                ex.msg, preimage);
            return false;
        }

        return true;
    }
}

version (unittest)
private Enrollment createEnrollment(const ref Hash utxo_key,
    const ref KeyPair key_pair, ref Scalar random_seed_src)
{
    import std.algorithm;

    Pair pair;
    pair.v = secretKeyToCurveScalar(key_pair.secret);
    pair.V = pair.v.toPoint();

    Hash random_seed;
    Hash[] preimages;
    auto enroll = Enrollment();
    auto signature_noise = Pair.random();

    enroll.utxo_key = utxo_key;
    enroll.cycle_length = ValidatorSet.ValidatorCycle;
    preimages ~= hashFull(random_seed_src);
    foreach (i; 0 ..  enroll.cycle_length-1)
        preimages ~= hashFull(preimages[i]);
    reverse(preimages);
    enroll.random_seed = preimages[0];
    enroll.enroll_sig = sign(pair.v, pair.V, signature_noise.V,
        signature_noise.v, enroll);
    return enroll;
}

/// test for functions of ValidatorSet
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
    ValidatorSet set = new ValidatorSet(":memory:");
    scope (exit) set.shutdown();
    Hash[] utxo_hashes = storage.keys;

    // add enrollments
    Scalar[Hash] seed_sources;
    auto utxo_hash = utxo_hashes[0];
    seed_sources[utxo_hash] = Scalar.random();
    auto enroll = createEnrollment(utxo_hash, key_pair, seed_sources[utxo_hash]);
    assert(set.add(0, &storage.findUTXO, enroll));
    assert(set.count() == 1);
    assert(set.hasEnrollment(utxo_hash));
    assert(!set.add(0, &storage.findUTXO, enroll));

    auto utxo_hash2 = utxo_hashes[1];
    seed_sources[utxo_hash2] = Scalar.random();
    auto enroll2 = createEnrollment(utxo_hash2, key_pair, seed_sources[utxo_hash2]);
    assert(set.add(0, &storage.findUTXO, enroll2));
    assert(set.count() == 2);

    auto utxo_hash3 = utxo_hashes[2];
    seed_sources[utxo_hash3] = Scalar.random();
    auto enroll3 = createEnrollment(utxo_hash3, key_pair, seed_sources[utxo_hash3]);
    assert(set.add(0, &storage.findUTXO, enroll3));
    assert(set.count() == 3);

    // check if enrolled heights are not set
    Enrollment[] enrolls;
    set.getUnregistered(enrolls);
    assert(enrolls.length == 3);
    assert(enrolls.isStrictlyMonotonic!("a.utxo_key < b.utxo_key"));

    // get a specific enrollment object
    Enrollment stored_enroll;
    assert(set.getEnrollment(utxo_hash2, stored_enroll));
    assert(stored_enroll == enroll2);

    // remove an enrollment
    set.remove(utxo_hash2);
    assert(set.count() == 2);
    assert(!set.getEnrollment(utxo_hash2, stored_enroll));

    // test for enrollment block height update
    assert(!set.getEnrolledHeight(utxo_hash));
    assert(set.updateEnrolledHeight(utxo_hash, 9));
    assert(set.getEnrolledHeight(utxo_hash) == 9);
    assert(!set.updateEnrolledHeight(utxo_hash, 9));
    assert(set.getEnrolledHeight(utxo_hash2) == 0);
    set.getUnregistered(enrolls);
    assert(enrolls.length == 1);
    assert(set.count() == 2);  // has not changed

    assert(set.hasEnrollment(utxo_hash));
    set.remove(utxo_hash);
    assert(!set.hasEnrollment(utxo_hash));
    set.remove(utxo_hash2);
    set.remove(utxo_hash3);
    assert(set.getUnregistered(enrolls).length == 0);

    Enrollment[] ordered_enrollments;
    ordered_enrollments ~= enroll;
    ordered_enrollments ~= enroll2;
    ordered_enrollments ~= enroll3;

    // Reverse ordering
    ordered_enrollments.sort!("a.utxo_key > b.utxo_key");
    foreach (ordered_enroll; ordered_enrollments)
        assert(set.add(0, &storage.findUTXO, ordered_enroll));
    set.getUnregistered(enrolls);
    assert(enrolls.length == 3);
    assert(enrolls.isStrictlyMonotonic!("a.utxo_key < b.utxo_key"));

    // test for getting validators
    Enrollment[] validators;
    assert(set.updateEnrolledHeight(utxo_hash, 9));
    assert(set.getValidators(validators));
    assert(validators.length == 1);
    assert(validators[0].utxo_key == utxo_hash);

    // test for adding and getting preimage
    PreimageInfo result_image;
    assert(!set.hasPreimage(utxo_hash, 10));
    assert(set.getPreimage(utxo_hash, result_image));
    assert(result_image == PreimageInfo.init);
    auto preimage = PreimageInfo(utxo_hash, enroll.random_seed, 10);
    assert(set.addPreimage(preimage));
    assert(set.hasPreimage(utxo_hash, 10));
    assert(set.getPreimage(utxo_hash, result_image));
    assert(result_image.enroll_key == preimage.enroll_key);
    assert(result_image.hash == preimage.hash);
    assert(result_image.height == preimage.height);
}
