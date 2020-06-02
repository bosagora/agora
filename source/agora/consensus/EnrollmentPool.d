/*******************************************************************************

    Contains supporting code for managing enrollments registered by nodes
    on the network to be a validator, which means the enrollment information
    needs to be confirmed on the consensus protocol to be a validator. The
    information is stored in a table of SQLite.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.EnrollmentPool;

import agora.common.crypto.ECC;
import agora.common.crypto.Key;
import agora.common.crypto.Schnorr;
import agora.common.Hash;
import agora.common.Serializer;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.UTXOSet;
import agora.consensus.validation;
import agora.utils.Log;

import d2sqlite3.database;
import d2sqlite3.library;
import d2sqlite3.results;
import d2sqlite3.sqlite3;

mixin AddLogger!();

/// Ditto
public class EnrollmentPool
{
    /// SQLite DB instance
    private Database db;

    /***************************************************************************

        Constructor

        Params:
            db_path = path to the database file, or in-memory storage if
                        :memory: was passed

    ***************************************************************************/

    public this (string db_path)
    {
        this.db = Database(db_path);

        // create the table for enrollment pool if it doesn't exist yet
        this.db.execute("CREATE TABLE IF NOT EXISTS enrollment_pool " ~
            "(key TEXT PRIMARY KEY, val BLOB NOT NULL)");
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

        Add a enrollment data to the enrollment pool

        Params:
            enroll = the enrollment data to add
            finder = the delegate to find UTXOs with

        Returns:
            true if the enrollment data has been added to the enrollment pool

    ***************************************************************************/

    public bool add (const ref Enrollment enroll, scope UTXOFinder finder)
        @safe nothrow
    {
        // check validity of the enrollment data
        if (auto reason = isInvalidReason(enroll, finder))
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

        static ubyte[] buffer;
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
                this.db.execute("INSERT INTO enrollment_pool (key, val) VALUES (?, ?)",
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
            the number of enrollments being managed by the enrollment pool,
            which are un-registered enrollments.

    ***************************************************************************/

    public size_t count () @trusted nothrow
    {
        try
        {
            return this.db.execute("SELECT count(*) FROM enrollment_pool").
                oneValue!size_t;
        }
        catch (Exception ex)
        {
            log.error("Database operation error on count");
            return 0;
        }
    }

    /***************************************************************************

        Remove the enrollment data with the given key from the enrollment pool

        Params:
            enroll_hash = key for an enrollment data to remove

    ***************************************************************************/

    public void remove (const ref Hash enroll_hash) @trusted nothrow
    {
        try
        {
            this.db.execute("DELETE FROM enrollment_pool WHERE key = ?",
                enroll_hash.toString());
        }
        catch (Exception ex)
        {
            log.error("Database operation error on remove");
        }
    }

    /***************************************************************************

        Check if a enrollment data exists in the enrollment pool.

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
                "enrollment_pool WHERE key = ?)", enroll_hash.toString());
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
        out Enrollment enroll) @trusted nothrow
    {
        try
        {
            auto results = this.db.execute("SELECT key, val FROM enrollment_pool " ~
                "WHERE key = ?", enroll_hash.toString());

            foreach (row; results)
            {
                enroll = deserializeFull!Enrollment(row.peek!(ubyte[])(1));
                return true;
            }
        }
        catch (Exception ex)
        {
            log.error("Exception occured on getEnrollment: {}, " ~
                "Key for enrollment: {}", ex.msg, enroll_hash);
            return false;
        }

        return false;
    }

    /***************************************************************************

        Get the unregistered enrollments in the block
        And this is arranged in ascending order with the utxo_key

        Params:
            enrolls = will contain the unregistered enrollments data if found

        Returns:
            The unregistered enrollments data

    ***************************************************************************/

    public Enrollment[] getEnrollments (ref Enrollment[] enrolls)
        @trusted nothrow
    {
        enrolls.length = 0;
        assumeSafeAppend(enrolls);

        try
        {
            auto results = this.db.execute("SELECT val FROM enrollment_pool " ~
                "ORDER BY key ASC");

            foreach (row; results)
                enrolls ~= deserializeFull!Enrollment(row.peek!(ubyte[])(0));
        }
        catch (Exception ex)
        {
            log.error("Exception occured on getEnrollments: {}", ex.msg);
        }

        return enrolls;
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
    enroll.cycle_length = Enrollment.ValidatorCycle;
    preimages ~= hashFull(random_seed_src);
    foreach (i; 0 ..  enroll.cycle_length-1)
        preimages ~= hashFull(preimages[i]);
    reverse(preimages);
    enroll.random_seed = preimages[0];
    enroll.enroll_sig = sign(pair, signature_noise, enroll);
    return enroll;
}

/// test for function of EnrollmentPool
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
    EnrollmentPool pool = new EnrollmentPool(":memory:");
    scope (exit) pool.shutdown();
    Hash[] utxo_hashes = storage.keys;

    // add enrollments
    Scalar[Hash] seed_sources;
    auto utxo_hash = utxo_hashes[0];
    seed_sources[utxo_hash] = Scalar.random();
    auto enroll = createEnrollment(utxo_hash, key_pair, seed_sources[utxo_hash]);
    assert(pool.add(enroll, &storage.findUTXO));
    assert(pool.count() == 1);
    assert(pool.hasEnrollment(utxo_hash));
    assert(!pool.add(enroll, &storage.findUTXO));

    auto utxo_hash2 = utxo_hashes[1];
    seed_sources[utxo_hash2] = Scalar.random();
    auto enroll2 = createEnrollment(utxo_hash2, key_pair, seed_sources[utxo_hash2]);
    assert(pool.add(enroll2, &storage.findUTXO));
    assert(pool.count() == 2);

    auto utxo_hash3 = utxo_hashes[2];
    seed_sources[utxo_hash3] = Scalar.random();
    auto enroll3 = createEnrollment(utxo_hash3, key_pair, seed_sources[utxo_hash3]);
    assert(pool.add(enroll3, &storage.findUTXO));
    assert(pool.count() == 3);

    // check if enrolled heights are not set
    Enrollment[] enrolls;
    pool.getEnrollments(enrolls);
    assert(enrolls.length == 3);
    assert(enrolls.isStrictlyMonotonic!("a.utxo_key < b.utxo_key"));

    // get a specific enrollment object
    Enrollment stored_enroll;
    assert(pool.getEnrollment(utxo_hash2, stored_enroll));
    assert(stored_enroll == enroll2);

    // remove an enrollment
    pool.remove(utxo_hash2);
    assert(pool.count() == 2);
    assert(!pool.getEnrollment(utxo_hash2, stored_enroll));

    // test for enrollment block height update
    pool.getEnrollments(enrolls);
    assert(enrolls.length == 2);

    assert(pool.hasEnrollment(utxo_hash));
    pool.remove(utxo_hash);
    assert(!pool.hasEnrollment(utxo_hash));
    pool.remove(utxo_hash2);
    pool.remove(utxo_hash3);
    assert(pool.getEnrollments(enrolls).length == 0);

    Enrollment[] ordered_enrollments;
    ordered_enrollments ~= enroll;
    ordered_enrollments ~= enroll2;
    ordered_enrollments ~= enroll3;

    // Reverse ordering
    ordered_enrollments.sort!("a.utxo_key > b.utxo_key");
    foreach (ordered_enroll; ordered_enrollments)
        assert(pool.add(ordered_enroll, &storage.findUTXO));
    pool.getEnrollments(enrolls);
    assert(enrolls.length == 3);
    assert(enrolls.isStrictlyMonotonic!("a.utxo_key < b.utxo_key"));
}
