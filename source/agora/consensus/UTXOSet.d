/*******************************************************************************

    Contains an SQLite-backed UTXO transaction set class

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.UTXOSet;

import agora.common.crypto.Key;
import agora.common.Hash;
import agora.common.ManagedDatabase;
import agora.common.Serializer;
import agora.common.Set;
import agora.common.Types;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXOSetValue;
import agora.utils.Log;

import std.file;

mixin AddLogger!();

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

    public void updateUTXOCache (const ref Transaction tx, Height height) @safe
    {
        import std.algorithm : any;

        // defaults to next block
        Height unlock_height = Height(height + 1);

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
            unlock_height = Height(height + 2016);
        }

        foreach (const ref input; tx.inputs)
        {
            auto utxo_hash = UTXOSetValue.getHash(input.previous, input.index);
            this.utxo_db.remove(utxo_hash);
        }

        Hash tx_hash = tx.hashFull();
        foreach (idx, output; tx.outputs)
        {
            auto utxo_hash = UTXOSetValue.getHash(tx_hash, idx);
            auto utxo_value = UTXOSetValue(unlock_height, tx.type, output);
            this.utxo_db[utxo_hash] = utxo_value;
        }
    }

    /***************************************************************************

        get an UTXOSetValue in the UTXO set.

        Params:
            hash = the hash of the transaction introducing the `Output`
            index = the index of the output

        Return:
            Return UTXOSetValue

    ***************************************************************************/

    private UTXOSetValue getUTXOSetValue (Hash hash, size_t index)
        nothrow @safe
    {
        auto utxo_hash = UTXOSetValue.getHash(hash, index);

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
            hash = the hash of the UTXO (`hashFull(tx_hash, index)`)
            output = will contain the UTXOSetValue if found

        Return:
            Return true if the UTXO was found

    ***************************************************************************/

    private bool findUTXO (Hash utxo, out UTXOSetValue value)
        nothrow @safe
    {
        if (utxo in this.used_utxos)
        {
            log.trace("findUTXO: utxo_hash {} found in used_utxos: {}", utxo, used_utxos);
            return false;  // double-spend
        }

        if (this.utxo_db.find(utxo, value))
        {
            this.used_utxos.put(utxo);
            return true;
        }
        log.trace("findUTXO: utxo_hash {} not found", utxo);
        return false;
    }
}

/*******************************************************************************

    ManagedDatabase of UTXOs using SQLite as the backing store

*******************************************************************************/

private class UTXODB
{
    /// SQLite db instance
    private ManagedDatabase db;


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
        this.db = new ManagedDatabase(utxo_db_path);

        if (db_exists)
            log.info("Loaded database from: {}", utxo_db_path);

        // create the table if it doesn't exist yet
        this.db.execute("CREATE TABLE IF NOT EXISTS utxo_map " ~
            "(key BLOB PRIMARY KEY, val BLOB NOT NULL, pubkey_hash BLOB NOT NULL)");
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
    import agora.consensus.data.UTXOSetValue;

    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random];

    auto utxo_set = new UTXOSet(":memory:");

    // create the first transaction
    Transaction tx1 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount.MinFreezeAmount, key_pairs[0].address)]
    );
    utxo_set.updateUTXOCache(tx1, Height(0));
    Hash hash1 = hashFull(tx1);
    auto utxo_hash = UTXOSetValue.getHash(hash1, 0);

    // test for getting UTXOs
    auto utxos = utxo_set.getUTXOs(key_pairs[0].address);
    assert(utxos[utxo_hash].output.address == key_pairs[0].address);

    // create the second transaction
    Transaction tx2 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount(100_000 * 10_000_000L), key_pairs[0].address)]
    );
    utxo_set.updateUTXOCache(tx2, Height(0));

    // create the third transaction
    Transaction tx3 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount.MinFreezeAmount, key_pairs[1].address)]
    );
    utxo_set.updateUTXOCache(tx3, Height(0));

    // test for getting UTXOs for the first KeyPair
    utxos = utxo_set.getUTXOs(key_pairs[0].address);
    assert(utxos.length == 2);

    // test for getting UTXOs for the second KeyPair
    utxos = utxo_set.getUTXOs(key_pairs[1].address);
    assert(utxos.length == 1);
}
