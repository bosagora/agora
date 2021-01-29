/*******************************************************************************

    Contains a SQLite-backed UTXO set class.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.state.UTXODB;

import agora.common.crypto.Key;
import agora.common.Hash;
import agora.common.ManagedDatabase;
import agora.common.Serializer;
import agora.common.Set;
import agora.common.Types;
import agora.consensus.data.Transaction;
public import agora.consensus.state.UTXOSet;
import agora.utils.Log;

import std.file;

mixin AddLogger!();

///
public class UTXOSet : UTXOCache
{
    /// UTXO cache backed by a database
    private UTXODB utxo_db;

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

        Get UTXOs from the UTXO set

        Params:
            pubkey = the key by which to search UTXOs in UTXOSet

        Returns:
            the associative array for UTXOs

    ***************************************************************************/

    public UTXO[Hash] getUTXOs (const ref PublicKey pubkey) nothrow @safe
    {
        return this.utxo_db.getUTXOs(pubkey);
    }

    ///
    public override bool peekUTXO (in Hash utxo, out UTXO value) nothrow @safe
    {
        return this.utxo_db.find(utxo, value);
    }

    ///
    protected override void remove (in Hash utxo) @safe
    {
        this.utxo_db.remove(utxo);
    }

    ///
    protected override void add (in Hash utxo, UTXO value) @safe
    {
        this.utxo_db[utxo] = value;
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

        Look up the UTXO in the map, and store it to 'output' if found

        Params:
            key = the key to find
            value = will contain the UTXO if found

        Returns:
            true if the value was found

    ***************************************************************************/

    public bool find (in Hash key, out UTXO value) nothrow @trusted
    {
        scope (failure) assert(0);
        auto results = db.execute("SELECT val FROM utxo_map WHERE key = ?",
            key[]);

        foreach (row; results)
        {
            value = deserializeFull!UTXO(row.peek!(ubyte[])(0));
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

    public UTXO[Hash] getUTXOs (const ref PublicKey pubkey) nothrow @trusted
    {
        scope (failure) assert(0);

        UTXO[Hash] utxos;
        auto results = db.execute("SELECT key, val FROM utxo_map WHERE pubkey_hash = ?",
            pubkey[]);

        foreach (row; results)
        {
            auto hash = *cast(Hash*)row.peek!(ubyte[])(0).ptr;
            auto value = deserializeFull!UTXO(row.peek!(ubyte[])(1));
            utxos[hash] = value;
        }

        return utxos;
    }

    /***************************************************************************

        Add an UTXO to the map

        Params:
            value = the UTXO to add
            key = the key to use

    ***************************************************************************/

    public void opIndexAssign (const ref UTXO value, in Hash key) @safe
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

    public void remove (in Hash key) nothrow @safe
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
    import agora.consensus.data.UTXO;

    import TESTNET = agora.consensus.data.genesis.Test;

    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random];

    auto utxo_set = new UTXOSet(":memory:");

    // create the first transaction
    Transaction tx1 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount.MinFreezeAmount, key_pairs[0].address)]
    );
    utxo_set.updateUTXOCache(tx1, Height(0), TESTNET.CommonsBudgetAddress);
    Hash hash1 = hashFull(tx1);
    auto utxo_hash = UTXO.getHash(hash1, 0);

    // test for getting UTXOs
    auto utxos = utxo_set.getUTXOs(key_pairs[0].address);
    assert(utxos[utxo_hash].output.address == key_pairs[0].address);

    // create the second transaction
    Transaction tx2 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount(100_000 * 10_000_000L), key_pairs[0].address)]
    );
    utxo_set.updateUTXOCache(tx2, Height(0), TESTNET.CommonsBudgetAddress);

    // create the third transaction
    Transaction tx3 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount.MinFreezeAmount, key_pairs[1].address)]
    );
    utxo_set.updateUTXOCache(tx3, Height(0), TESTNET.CommonsBudgetAddress);

    // test for getting UTXOs for the first KeyPair
    utxos = utxo_set.getUTXOs(key_pairs[0].address);
    assert(utxos.length == 2);

    // test for getting UTXOs for the second KeyPair
    utxos = utxo_set.getUTXOs(key_pairs[1].address);
    assert(utxos.length == 1);
}
