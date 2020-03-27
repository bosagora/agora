/*******************************************************************************

    Contains an SQLite-backed UTXO transaction set class

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.UTXOSet;

import agora.common.crypto.Key;
import agora.common.Hash;
import agora.common.Serializer;
import agora.common.Set;
import agora.common.Types;
import agora.consensus.data.Transaction;
import agora.utils.Log;

import d2sqlite3.database;

import std.file;

mixin AddLogger!();

/// Delegate to find an unspent UTXO
public alias UTXOFinder = scope bool delegate (Hash hash, size_t index,
    out UTXOSetValue) @safe nothrow;

/// The structure of spendable transaction output
public struct UTXOSetValue
{
    /// Height of the block to be unlock
    ulong unlock_height;

    /// Transaction type
    TxType type;

    /// Unspend transaction output
    Output output;
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
        this.utxo_db = null;
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

        Get UTXOs from the UTXO set

        Params:
            pubkey = the key by which the UTXO set search UTXOs

        Returns:
            the associative array for UTXOs

    ***************************************************************************/

    public UTXOSetValue[Hash] getUTXOs (const ref PublicKey pubkey) @safe nothrow
    {
        return this.utxo_db.getUTXOs(pubkey);
    }

    /***************************************************************************

        Find an UTXOSetValue in the UTXO set.

        Params:
            hash = the hash of transation
            index = the index of the output
                If size_t.max, find the hash parameter by UTXO Hash.
            output = will contain the UTXOSetValue if found

        Return:
            Return true if the UTXO was found

    ***************************************************************************/

    private bool findUTXO (Hash hash, size_t index, out UTXOSetValue value)
        nothrow @safe
    {
        Hash utxo_hash;

        if (index == size_t.max)
            utxo_hash = hash;
        else
            utxo_hash = getHash(hash, index);

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

    public static Hash getHash (Hash hash, ulong index) @safe nothrow
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
            "(key BLOB PRIMARY KEY, val BLOB NOT NULL, pubkey_hash BLOB NOT NULL)");
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

        Get UTXOs from the UTXO set

        Params:
            pubkey = the key by which the UTXO set search UTXOs

        Returns:
            the associative array for UTXOs

    ***************************************************************************/

    public UTXOSetValue[Hash] getUTXOs (const ref PublicKey pubkey) nothrow @trusted
    {
        scope (failure) assert(0);

        UTXOSetValue[Hash] utxos;
        auto results = db.execute("SELECT key, val FROM utxo_map WHERE pubkey_hash = ?",
            pubkey[]);

        foreach (row; results)
        {
            auto hash = *cast(Hash*)row.peek!(ubyte[])(0).ptr;
            auto value = deserializeFull!UTXOSetValue(row.peek!(ubyte[])(1));
            utxos[hash] = value;
        }

        return utxos;
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
        serializeToBuffer(value, buffer);

        scope (failure) assert(0);
        () @trusted {
            db.execute("INSERT INTO utxo_map (key, val, pubkey_hash) VALUES (?, ?, ?)",
                key[], buffer, value.output.address[]); }();
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

/// test for get UTXOs with a node's public key
unittest
{
    import agora.common.Amount;
    import agora.consensus.data.Transaction;
    import agora.consensus.data.UTXOSet;

    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random];

    auto utxo_set = new UTXOSet(":memory:");
    scope (exit) utxo_set.shutdown();

    // create the first transaction
    Transaction tx1 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount.MinFreezeAmount, key_pairs[0].address)]
    );
    utxo_set.updateUTXOCache(tx1, 0);
    Hash hash1 = hashFull(tx1);
    auto utxo_hash = utxo_set.getHash(hash1, 0);

    // test for getting UTXOs
    auto utxos = utxo_set.getUTXOs(key_pairs[0].address);
    assert(utxos[utxo_hash].output.address == key_pairs[0].address);

    // create the second transaction
    Transaction tx2 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount(100_000 * 10_000_000L), key_pairs[0].address)]
    );
    utxo_set.updateUTXOCache(tx2, 0);

    // create the third transaction
    Transaction tx3 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount.MinFreezeAmount, key_pairs[1].address)]
    );
    utxo_set.updateUTXOCache(tx3, 0);

    // test for getting UTXOs for the first KeyPair
    utxos = utxo_set.getUTXOs(key_pairs[0].address);
    assert(utxos.length == 2);

    // test for getting UTXOs for the second KeyPair
    utxos = utxo_set.getUTXOs(key_pairs[1].address);
    assert(utxos.length == 1);
}

/*******************************************************************************

    This is a simple UTXOSet, used when the AA behavior is desired

    Most unittestsdo not need a full-fledged UTXOSet with all the DB and
    serialization that comes with it, instead relying on an associative array
    and a delegate.

    Since this pattern is so common, this class is offered as a mean to achieve
    this without code duplication. See issue #501 for history.

    Note that this should *NOT* be used to replace the above UTXOSet,
    when for example doing integration tests with LocalRest.

*******************************************************************************/

version (unittest) public class TestUTXOSet
{
    ///
    public UTXOSetValue[Hash] storage;

    ///
    alias storage this;

    ///
    public bool findUTXO (Hash hash, size_t index, out UTXOSetValue value)
        nothrow @safe
    {
        // Note: Keep this in sync with the real `findUTXO`
        Hash utxo_hash = (index == size_t.max) ?
            hash : UTXOSet.getHash(hash, index);
        // Note: Does not expose double-spend prevention property
        if (auto ptr = utxo_hash in this.storage)
        {
            value = *ptr;
            return true;
        }
        return false;
    }

    /// Short hand to add a transaction
    public void put (const Transaction tx)
    {
        Hash txhash = hashFull(tx);
        foreach (size_t idx, ref output_; tx.outputs)
        {
            Hash h = UTXOSet.getHash(txhash, idx);
            UTXOSetValue v = {
                type: tx.type,
                output: output_
            };
            this.storage[h] = v;
        }
    }

    /// Workaround 20559...
    public void clear ()
    {
        this.storage.clear();
    }
}

unittest
{
    testSymmetry!UTXOSetValue();
}
