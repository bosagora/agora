/*******************************************************************************

    Contains supporting code for managing enrollments registered by nodes
    on the network to be a validator, which means the enrollment information
    needs to be confirmed on the consensus protocol to be a validator. The
    information is stored in a table of SQLite.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.EnrollmentPool;

import agora.common.ManagedDatabase;
import agora.common.Types;
import agora.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.state.UTXOCache;
import agora.consensus.state.ValidatorSet : EnrollmentFinder, EnrollmentState;
import agora.consensus.validation;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Schnorr;
import agora.serialization.Serializer;
import agora.utils.Log;
version (unittest) import agora.utils.Test;

import d2sqlite3.library;
import d2sqlite3.results;
import d2sqlite3.sqlite3;

/// Ditto
public class EnrollmentPool
{
    /// Logger instance
    protected Logger log;

    /// SQLite DB instance
    private ManagedDatabase db;

    /***************************************************************************

        Constructor

        Params:
            db = the managed database instance

    ***************************************************************************/

    public this (ManagedDatabase db)
    {
        this.db = db;
        this.log = Logger(__MODULE__);

        // create the table for enrollment pool if it doesn't exist yet
        this.db.execute("CREATE TABLE IF NOT EXISTS enrollment_pool " ~
            "(key TEXT PRIMARY KEY, val BLOB NOT NULL, " ~
            "avail_height INTEGER)");
    }

    /***************************************************************************

        Add a enrollment data to the enrollment pool

        Params:
            enroll = the enrollment data to add
            avail_height = height at which the enrollment is available
            finder = the delegate to find UTXOs with

        Returns:
            true if the enrollment data has been added to the enrollment pool

    ***************************************************************************/

    public bool add (const ref Enrollment enroll, Height avail_height,
        scope UTXOFinder finder, scope EnrollmentFinder findEnrollment) @safe nothrow
    {
        // check validity of the enrollment data
        if (auto reason = isInvalidReason(enroll, finder,
                                            avail_height, findEnrollment))
        {
            log.info("Invalid enrollment data: {}, Data was: {}, height: {}", reason, enroll, avail_height);
            return false;
        }

        // check if already exists
        if (this.hasEnrollment(enroll.utxo_key, avail_height))
        {
            log.trace("Skipping already existing enrollment, Data was: {}, for height {}",
                enroll, avail_height);
            return false;
        }

        static ubyte[] buffer;
        try
        {
            serializeToBuffer(enroll, buffer);
        }
        catch (Exception ex)
        {
            log.error("Serialization error: {}, Data was: {}", ex.msg,
                enroll);
            return false;
        }

        try
        {
            () @trusted {
                this.db.execute("REPLACE INTO enrollment_pool " ~
                    "(key, val, avail_height) VALUES (?, ?, ?)",
                    enroll.utxo_key.toString(), buffer, avail_height.value);
            }();
        }
        catch (Exception ex)
        {
            log.error("ManagedDatabase operation error: {}, Data was: {}", ex.msg, enroll);
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
            log.error("ManagedDatabase operation error on count");
            return 0;
        }
    }

    /***************************************************************************

        Remove the enrollment data with the given key from the enrollment pool

        Params:
            enroll_hash = key for an enrollment data to remove

    ***************************************************************************/

    public void remove (in Hash enroll_hash) @trusted nothrow
    {
        try
        {
            this.db.execute("DELETE FROM enrollment_pool WHERE key = ?",
                enroll_hash.toString());
        }
        catch (Exception ex)
        {
            log.error("ManagedDatabase operation error on remove");
        }
    }

    /***************************************************************************

        Remove the enrollment data which did not make it into the intended block
        from the enrollment pool

        Params:
            height = height of next block

    ***************************************************************************/

    public void removeExpired (in Height height) @trusted nothrow
    {
        try
        {
            this.db.execute("DELETE FROM enrollment_pool WHERE avail_height < ?",
                height);
        }
        catch (Exception ex)
        {
            log.error("ManagedDatabase operation error on removeExpired");
        }
    }

    /***************************************************************************

        Check if a enrollment data exists in the enrollment pool.

        Params:
            enroll_hash = key for an enrollment data which is hash of frozen UTXO
            avail_height = height at which the enrollment is available

        Returns:
            true if the validator set has the enrollment data

    ***************************************************************************/

    public bool hasEnrollment (in Hash enroll_hash, Height avail_height)
        @trusted nothrow
    {
        try
        {
            auto results = this.db.execute("SELECT EXISTS(SELECT 1 FROM " ~
                "enrollment_pool WHERE key = ? AND avail_height >= ?)",
                enroll_hash.toString(), avail_height.value);
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

        Get the enrollment with the key

        Params:
            enroll_hash = key for the enrollment which has the frozen UTXO

        Returns:
            Return an `Enrollment` if the enrollment is found, otherwise
                `Enrollment.init`

    ***************************************************************************/

    public Enrollment getEnrollment (in Hash enroll_hash)
        @trusted nothrow
    {
        try
        {
            auto results = this.db.execute("SELECT key, val FROM enrollment_pool " ~
                "WHERE key = ?", enroll_hash);

            foreach (row; results)
            {
                return deserializeFull!Enrollment(row.peek!(ubyte[])(1));
            }
        }
        catch (Exception ex)
        {
            log.error("Exception occured on getEnrollment: {}, " ~
                "Key for enrollment: {}", ex.msg, enroll_hash);
            return Enrollment.init;
        }

        return Enrollment.init;
    }

    /***************************************************************************

        Get the height when the enrollment will be available

        Params:
            enroll_hash = key for the available block height

        Returns:
            the available block height, or 0 if the enrollment isn't found

    ***************************************************************************/

    public Height getAvailableHeight (in Hash enroll_hash)
        @trusted nothrow
    {
        try
        {
            auto results = this.db.execute("SELECT avail_height " ~
                "FROM enrollment_pool WHERE key = ?", enroll_hash);
            if (results.empty)
                return Height(0);

            return Height(results.oneValue!(size_t));
        }
        catch (Exception ex)
        {
            log.error("ManagedDatabase operation error: {}", ex.msg);
            return Height(0);
        }
    }


    /***************************************************************************

        Get the unregistered enrollments from the pool
        And this is arranged in ascending order with the utxo_key

        Params:
            height = the height of proposed block

        Returns:
            The unregistered enrollments data that couild be added in the next
            block. (i.e. avail_height is only valid at a single height)

    ***************************************************************************/

    public Enrollment[] getEnrollments (in Height height)
        @trusted nothrow
    {
        Enrollment[] enrolls;
        try
        {
            auto results = this.db.execute("SELECT val FROM enrollment_pool " ~
                "WHERE ? = avail_height ORDER BY key ASC", height.value);

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

/// test for function of EnrollmentPool
unittest
{
    import agora.consensus.data.Params;
    import agora.consensus.data.Transaction;
    import agora.consensus.EnrollmentManager;
    import std.algorithm;

    auto params = new immutable(ConsensusParams)();
    scope storage = new TestUTXOSet;
    scope pool = new EnrollmentPool(new ManagedDatabase(":memory:"));
    KeyPair key_pair = KeyPair.random();
    Enrollment[] enrollments;
    Height avail_height;

    bool findEnrollment (in Hash enroll_key,
                            out EnrollmentState state) @trusted nothrow
    {
        return false;
    }

    genesisSpendable().map!(txb => txb.refund(key_pair.address).sign(TxType.Freeze))
        .each!(tx => storage.put(tx));

    // Add enrollments
    Hash[] utxo_hashes = storage.keys;
    foreach (index; 0 .. 3)
    {
        auto utxo_hash = utxo_hashes[index];
        avail_height = Height(params.ValidatorCycle);
        enrollments ~= EnrollmentManager.makeEnrollment(utxo_hash, key_pair, avail_height, params.ValidatorCycle);
        assert(pool.add(enrollments[$ - 1], avail_height,
                                storage.getUTXOFinder(), &findEnrollment));
        assert(pool.count() == index + 1);
        assert(pool.hasEnrollment(utxo_hash, avail_height));
        assert(!pool.add(enrollments[$ - 1], avail_height,
                                storage.getUTXOFinder(), &findEnrollment));
    }

    // check if enrolled heights are not set
    Enrollment[] enrolls = pool.getEnrollments(avail_height);
    assert(enrolls.length == 3);
    assert(enrolls.isStrictlyMonotonic!("a.utxo_key < b.utxo_key"));

    // get a specific enrollment object
    Enrollment stored_enroll;
    assert((stored_enroll = pool.getEnrollment(utxo_hashes[1])) !=
        Enrollment.init);
    assert(stored_enroll == enrollments[1]);

    // remove an enrollment
    pool.remove(utxo_hashes[1]);
    assert(pool.count() == 2);
    assert(pool.getEnrollment(utxo_hashes[1]) == Enrollment.init);

    // test for enrollment block height update
    enrolls = pool.getEnrollments(avail_height);
    assert(enrolls.length == 2);

    avail_height = Height(params.ValidatorCycle);
    assert(pool.hasEnrollment(utxo_hashes[0], avail_height));
    avail_height = Height(params.ValidatorCycle * 2);
    assert(!pool.hasEnrollment(utxo_hashes[0], avail_height));
    pool.remove(utxo_hashes[0]);
    assert(!pool.hasEnrollment(utxo_hashes[0], avail_height));
    pool.remove(utxo_hashes[1]);
    pool.remove(utxo_hashes[2]);
    assert(pool.getEnrollments(avail_height).length == 0);

    // Reverse ordering
    Enrollment[] ordered_enrollments = enrollments.dup;
    ordered_enrollments.sort!("a.utxo_key > b.utxo_key");
    foreach (ordered_enroll; ordered_enrollments)
        assert(pool.add(ordered_enroll, Height(1),
                        &storage.peekUTXO, &findEnrollment));
    enrolls = pool.getEnrollments(Height(1));
    assert(enrolls.length == 3);
    assert(enrolls.isStrictlyMonotonic!("a.utxo_key < b.utxo_key"));
}
