/*******************************************************************************

    Contains supporting code for enrollment process.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.EnrollmentManager;

import agora.common.crypto.ECC;
import agora.common.crypto.Key;
import agora.common.crypto.Schnorr;
import agora.common.Deserializer;
import agora.common.Hash;
import agora.common.Serializer;
import agora.consensus.data.Enrollment;
import agora.consensus.data.UTXOSet;
import agora.utils.Log;

import d2sqlite3.database;
import d2sqlite3.library;
import d2sqlite3.results;
import d2sqlite3.sqlite3;

import std.algorithm;
import std.file;
import std.path;

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

    /// Random seed
    private Scalar random_seed_src;

    /// Random key for enrollment
    private Pair signature_noise;

    /// Enrollment data object
    private Enrollment data;

    /***************************************************************************

        Constructor

        Params:
            db_path = path to the database file, or in-memory storage if
                        :memory: was passed
            key_pair = the keypair of the owner node

    ***************************************************************************/

    public this (string db_path, KeyPair key_pair)
    {
        this.db = Database(db_path);

        // create the table for validator set if it doesn't exist yet
        this.db.execute("CREATE TABLE IF NOT EXISTS validator_set " ~
            "(key BLOB PRIMARY KEY, val BLOB NOT NULL, enrolled_height INTEGER)");

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
            enroll = the enrollment data to add

        Returns:
            true if the enrollment data has been added to the validator set

    ***************************************************************************/

    public bool addEnrollment (const ref Enrollment enroll) @safe nothrow
    {
        static ubyte[] buffer;

        // check if already exists
        try
        {
            if (this.hasEnrollment(enroll.utxo_key))
            {
                this.logMessage("Rejected already existing enrollment",
                    enroll);
                return false;
            }
        }
        catch (Exception ex)
        {
            this.logMessage("Exception occured in checking if " ~
                "the enrollment data exists", enroll, ex);
            return false;
        }

        buffer.length = 0;
        () @trusted { assumeSafeAppend(buffer); } ();

        scope SerializeDg dg = (scope const(ubyte[]) data) nothrow @safe
        {
            buffer ~= data;
        };

        try
        {
            serializePart(enroll, dg);
        }
        catch (Exception ex)
        {
            this.logMessage("Serialization error", enroll, ex);
            return false;
        }

        try
        {
            () @trusted {
                this.db.execute("INSERT INTO validator_set (key, val) VALUES (?, ?)",
                    enroll.utxo_key[], buffer);
            }();

        }
        catch (Exception ex)
        {
            this.logMessage("Database operation error", enroll, ex);
            return false;
        }

        return true;
    }

    /***************************************************************************

        Returns:
            the number of validators in the validator set

    ***************************************************************************/

    public size_t getEnrollmentLength () @safe
    {
        return () @trusted {
            return this.db.execute("SELECT count(*) FROM validator_set").oneValue!size_t;
        }();
    }

    /***************************************************************************

        Remove the enrollment data with the given key from the validator set

        Params:
            enroll_hash = key for an enrollment data to remove

    ***************************************************************************/

    public void removeEnrollment (const ref Hash enroll_hash) @trusted
    {
        this.db.execute("DELETE FROM validator_set WHERE key = ?", enroll_hash[]);
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
                " WHERE key = ?", enroll_hash[]);
            if (results.empty)
                return size_t.init;

            return results.oneValue!(size_t);
        }
        catch (Exception ex)
        {
            log.error("Database operation error {}", ex);
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
                    block_height, enroll_hash[]);
            }();
        }
        catch (Exception ex)
        {
            log.error("Database operation error, updateEnrolledHeight:{}, exception:{}",
                enroll_hash, ex);
            return false;
        }
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

        // K, frozen UTXO hash
        this.data.utxo_key = frozen_utxo_hash;

        // N, cycle length
        this.data.cycle_length = 1008; // freezing period / 2

        // generate random seed value
        this.random_seed_src = Scalar.random();

        // X, nth image of random seed
        this.data.random_seed = hashFull(this.random_seed_src);
        foreach (i; 0 .. this.data.cycle_length-1)
            this.data.random_seed = hashFull(this.data.random_seed);

        // R, signature noise
        this.signature_noise = Pair.random();
        () @trusted { assumeSafeAppend(buffer); }();

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
        auto results = this.db.execute("SELECT EXISTS(SELECT 1 FROM validator_set " ~
            "WHERE key = ?)", enroll_hash[]);

        return results.front().peek!bool(0);
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
            "WHERE key = ?", enroll_hash[]);

        foreach (row; results)
        {
            enroll = deserializeFull!Enrollment(row.peek!(ubyte[])(1));
            return true;
        }

        return false;
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
    import agora.consensus.data.UTXOSet;
    import std.format;

    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random];

    // create the first transaction
    Transaction tx1 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount.MinFreezeAmount, key_pairs[0].address)]
    );

    // create the second transaction
    Transaction tx2 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount(100_000 * 10_000_000L), key_pairs[0].address)]
    );

    // create the third transaction
    Transaction tx3 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount.MinFreezeAmount, key_pairs[1].address)]
    );

    // create and UTXO set and an EnrollmentManager object
    auto utxo_set = new UTXOSet(":memory:");
    scope (exit) utxo_set.shutdown();
    auto man = new EnrollmentManager(":memory:", key_pairs[0]);
    scope (exit) man.shutdown();

    utxo_set.updateUTXOCache(tx1, 1);
    utxo_set.updateUTXOCache(tx2, 1);
    utxo_set.updateUTXOCache(tx3, 1);

    // find UTXOs to use in making enrollment data
    Hash[] utxo_hashes;
    auto utxos = utxo_set.getUTXOs(key_pairs[0].address);
    foreach (key, value; utxos) {
        utxo_hashes ~= key;
    }

    // create and add the first Enrollment object
    auto utxo_hash = utxo_hashes[0];
    Enrollment enroll;
    man.createEnrollment(utxo_hash, enroll);
    assert(man.hasEnrollment(utxo_hash) == false);
    man.addEnrollment(enroll);
    assert(man.getEnrollmentLength() == 1);
    assert(man.hasEnrollment(utxo_hash) == true);
    assert(man.addEnrollment(enroll) == false);

    // create and add the second Enrollment object
    auto utxo_hash2 = utxo_hashes[1];
    Enrollment enroll2;
    man.createEnrollment(utxo_hash2, enroll2);
    man.addEnrollment(enroll2);
    assert(man.getEnrollmentLength() == 2);

    // get a stored Enrollment object
    Enrollment stored_enroll;
    assert(man.getEnrollment(utxo_hash2, stored_enroll));
    assert(stored_enroll == enroll2);

    // remove an Enrollment object
    man.removeEnrollment(utxo_hash2);
    assert(man.getEnrollmentLength() == 1);

    // test for getEnrollment with removed enrollment
    assert(!man.getEnrollment(utxo_hash2, stored_enroll));

    // test for enrollment block height update
    assert(!man.getEnrolledHeight(utxo_hash));
    assert(man.updateEnrolledHeight(utxo_hash, 9));
    assert(man.getEnrolledHeight(utxo_hash) == 9);
    assert(!man.updateEnrolledHeight(utxo_hash, 9));
    assert(man.getEnrolledHeight(utxo_hash2) == 0);
}
