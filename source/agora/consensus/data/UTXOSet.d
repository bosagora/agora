/*******************************************************************************

    Contains an SQLite-backed UTXO transaction set class

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.UTXOSet;

import agora.common.Deserializer;
import agora.common.Hash;
import agora.common.Serializer;
import agora.common.Set;
import agora.consensus.data.Transaction;
import agora.consensus.Validation;
import agora.utils.Log;

import d2sqlite3.database;

import std.file;

mixin AddLogger!();

/// The structure of spendable transaction output
public struct UTXOSetValue
{
    /// Height of the block to be unlock
    ulong unlock_height;

    /// Transaction type
    TxType type;

    /// Unspend transaction output
    Output output;

    /***************************************************************************

        Input Serialization

        Params:
             dg = serialize function

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) const @safe
    {
        serializePart(this.unlock_height, dg);
        serializePart(this.type, dg);
        serializePart(this.output, dg);
    }

    /***************************************************************************

        Input deserialization

        Params:
             dg = deserialize function

    ***************************************************************************/

    public void deserialize (scope DeserializeDg dg) @safe
    {
        deserializePart(this.unlock_height, dg);
        deserializePart(this.type, dg);
        deserializePart(this.output, dg);
    }
}

/// ditto
public class UTXOSet
{
    /// Utxo cache backed by a database
    private UTXODB utxo_db;

    /// Keeps track of spent outputs during the validation of a Tx / Block
    private Set!Hash used_utxos;


    /***************************************************************************

        Constructor

        Params:
            utxo_db_path = path to the UTXO database

    ***************************************************************************/

    public this (in string utxo_db_path)
    {
        this.utxo_db = new UTXODB(utxo_db_path);
    }

    /***************************************************************************

        Shut down the utxo store

    ***************************************************************************/

    public void shutdown ()
    {
        this.utxo_db.shutdown();
    }

    /***************************************************************************

        Returns:
            the number of elements in the UTXO set

    ***************************************************************************/

    public size_t length () @safe
    {
        return this.utxo_db.length();
    }

    /***************************************************************************

        Add all of a transaction's outputs to the Utxo set,
        and remove the spent outputs in the transaction from the set.

        Params:
            tx = the transaction
            height = Height of the block where UTXO will be unlocked

    ***************************************************************************/

    public void updateUTXOCache (const ref Transaction tx, ulong height) @safe
    {
        import std.algorithm : any;

        // defaults to next block
        ulong unlock_height = height + 1;

        // for payments of frozen transactions, it will melt after 2016 blocks
        if ((tx.type == TxType.Payment)
            && tx.inputs.any!(input =>
                (
                    (input.previous != Hash.init) &&
                    (this.getUTXOSetValue(input.previous, input.index).type == TxType.Freeze)
                )
            )
        )
        {
            unlock_height = height + 2016;
        }

        foreach (const ref input; tx.inputs)
        {
            auto utxo_hash = getHash(input.previous, input.index);
            this.utxo_db.remove(utxo_hash);
        }

        Hash tx_hash = tx.hashFull();
        foreach (idx, output; tx.outputs)
        {
            auto utxo_hash = getHash(tx_hash, idx);
            auto utxo_value = UTXOSetValue(unlock_height, tx.type, output);
            this.utxo_db[utxo_hash] = utxo_value;
        }
    }

    /***************************************************************************

        get an UTXOSetValue in the UTXO set.

        Params:
            hash = the hash of transation
            index = the index of the output

        Return:
            Return UTXOSetValue

    ***************************************************************************/

    private UTXOSetValue getUTXOSetValue (Hash hash, size_t index)
        nothrow @safe
    {
        auto utxo_hash = getHash(hash, index);

        UTXOSetValue value;
        if (!this.utxo_db.find(utxo_hash, value))
            assert(0);
        return value;
    }

    /***************************************************************************

        Prepare tracking double-spent transactions and
        return the UTXOFinder delegate

        Returns:
            the UTXOFinder delegate

    ***************************************************************************/

    public UTXOFinder getUTXOFinder () @trusted nothrow
    {
        this.used_utxos.clear();
        return &this.findUTXO;
    }

    /***************************************************************************

        Find an UTXOSetValue in the UTXO set.

        Params:
            hash = the hash of transation
            index = the index of the output
            output = will contain the UTXOSetValue if found

        Return:
            Return true if the UTXO was found

    ***************************************************************************/

    private bool findUTXO (Hash hash, size_t index, out UTXOSetValue value)
        nothrow @safe
    {
        auto utxo_hash = getHash(hash, index);

        if (utxo_hash in this.used_utxos)
            return false;  // double-spend

        if (this.utxo_db.find(utxo_hash, value))
        {
            this.used_utxos.put(utxo_hash);
            return true;
        }

        return false;
    }

    /***************************************************************************

        Get the combined hash of the previous hash and index.
        This makes sure the index is always of the same type,
        as mixing different-sized uint/ulong would create different hashes.

        Returns:
            the combined hash of a previous hash and index

    ***************************************************************************/

    private static Hash getHash (Hash hash, ulong index) @safe nothrow
    {
        return hashMulti(hash, index);
    }
}

/*******************************************************************************

    Database of UTXOs using SQLite as the backing store

*******************************************************************************/

private class UTXODB
{
    /// SQLite db instance
    private Database db;


    /***************************************************************************

        Constructor

        Params:
            utxo_db_path = path to the UTXO database file

    ***************************************************************************/

    public this (string utxo_db_path)
    {
        const db_exists = utxo_db_path.exists;
        if (db_exists)
            log.info("Loading UTXO database from: {}", utxo_db_path);

        // todo: can fail. we would have to recover by either:
        // A) reconstructing it from our blockchain storage
        // B) requesting the UTXO set from our peers
        this.db = Database(utxo_db_path);

        if (db_exists)
            log.info("Loaded database from: {}", utxo_db_path);

        // create the table if it doesn't exist yet
        this.db.execute("CREATE TABLE IF NOT EXISTS utxo_map " ~
            "(key BLOB PRIMARY KEY, val BLOB NOT NULL)");
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

        Returns:
            the number of elements in the UTXO set

    ***************************************************************************/

    public size_t length () @safe
    {
        return () @trusted {
            return this.db.execute("SELECT count(*) FROM utxo_map")
                .oneValue!size_t;
        }();
    }

    /***************************************************************************

        Look up the UTXOSetValue in the map, and store it to 'output' if found

        Params:
            key = the key to find
            value = will contain the UTXOSetValue if found

        Returns:
            true if the value was found

    ***************************************************************************/

    public bool find (Hash key, out UTXOSetValue value) nothrow @trusted
    {
        scope (failure) assert(0);
        auto results = db.execute("SELECT val FROM utxo_map WHERE key = ?",
            key[]);

        foreach (row; results)
        {
            value = deserializeFull!UTXOSetValue(row.peek!(ubyte[])(0));
            return true;
        }

        return false;
    }

    /***************************************************************************

        Add an UTXOSetValue to the map

        Params:
            value = the UTXOSetValue to add
            key = the key to use

    ***************************************************************************/

    public void opIndexAssign (const ref UTXOSetValue value, Hash key) @safe
    {
        static ubyte[] buffer;
        buffer.length = 0;
        () @trusted { assumeSafeAppend(buffer); }();

        scope SerializeDg dg = (scope const(ubyte[]) data) @safe
        {
            buffer ~= data;
        };

        serializePart(value, dg);

        scope (failure) assert(0);
        () @trusted {
            db.execute("INSERT INTO utxo_map (key, val) VALUES (?, ?)",
                key[], buffer); }();
    }

    /***************************************************************************

        Remove an Output from the map

        Params:
            key = the key to remove

    ***************************************************************************/

    public void remove (Hash key) nothrow @safe
    {
        scope (failure) assert(0);
        () @trusted {
            db.execute("DELETE FROM utxo_map WHERE key = ?", key[]); }();
    }
}
