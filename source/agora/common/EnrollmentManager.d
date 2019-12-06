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
            "(key BLOB PRIMARY KEY, val BLOB NOT NULL)");

        // create the table for enrollment data for a node itself
        this.db.execute("CREATE TABLE IF NOT EXISTS node_enroll_data " ~
            "(key CHAR(128) PRIMARY KEY, val BLOB NOT NULL)");

        // set node's KeyPair object
        this.key_pair.v = Scalar(key_pair.secret);
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

    public bool addEnrollment (Enrollment enroll) @safe
    {
        static ubyte[] buffer;
        buffer.length = 0;

        // check if already exists
        if (this.hasEnrollment(enroll.utxo_key))
        {
            log.info("Rejected already existing enrollment: {}", enroll);
            return false;
        }

        () @trusted { assumeSafeAppend(buffer); } ();

        scope SerializeDg dg = (scope const(ubyte[]) data) nothrow @safe
        {
            buffer ~= data;
        };

        serializePart(enroll, dg);

        () @trusted {
            this.db.execute("INSERT INTO validator_set (key, val) VALUES (?, ?)",
                enroll.utxo_key[], buffer);
        }();

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

        Make an enrollment data for enrollment process

        Params:
            frozen_utxo_hash = the hash of a frozen UTXO used to identify 
                                a validator and to generate a siging key

        Returns:
            an enrollment data

    ***************************************************************************/

    public ref const(Enrollment) createEnrollment (const ref Hash frozen_utxo_hash) @trusted
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

        serializePart(this.signature_noise, dg);
        
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

        // signature
        data.enroll_sig = sign(this.key_pair.v, this.key_pair.V, this.signature_noise.V,
            this.signature_noise.v, this.data);

        return this.data;
    }

    /***************************************************************************

        Check if the enrollment data exists in the validator set.

        Params:
            enroll_hash = key for an enrollment data which is hash of frozen UTXO 

        Returns:
            true if the enrollment manager has the enrollment data

    ***************************************************************************/

    public bool hasEnrollment (const ref Hash enroll_hash) @trusted
    {
        auto results = this.db.execute("SELECT EXISTS(SELECT 1 FROM validator_set " ~
            "WHERE key = ?)", enroll_hash[]);

        return results.front().peek!bool(0);
    }
    
    /***************************************************************************

        Check if the enrollment data exists in the validator set.

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
}

/// tests for member functions of EnrollmentManager
unittest
{
    import agora.common.Amount;
    import agora.consensus.data.Transaction;
    import agora.consensus.data.UTXOSet;
    import std.format;

    KeyPair[] key_pairs = [KeyPair.random];

    // create the first transaction
    Transaction firstTx = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount(100_000), key_pairs[0].address)]
    );
    Hash firstHash = hashFull(firstTx);

    // create the second transaction
    Transaction secondTx = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount(50_000), key_pairs[0].address)]
    );
    Hash secondHash = hashFull(secondTx);

    // create an EnrollmentManager object
    auto utxo_set = new UTXOSet(":memory:");
    scope (exit) utxo_set.shutdown();
    auto man = new EnrollmentManager(":memory:", key_pairs[0]);
    scope (exit) man.shutdown();

    // create and add the first Enrollment object
    auto utxo_hash = utxo_set.getHash(firstHash, 0);
    auto enroll = man.createEnrollment(utxo_hash);
    assert(man.hasEnrollment(utxo_hash) == false);
    man.addEnrollment(enroll);
    assert(man.getEnrollmentLength() == 1);
    assert(man.hasEnrollment(utxo_hash) == true);
    assert(man.addEnrollment(enroll) == false);

    // create and add the second Enrollment object
    auto utxo_hash2 = utxo_set.getHash(secondHash, 0);
    auto enroll2 = man.createEnrollment(utxo_hash2);
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
}
