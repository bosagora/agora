/*******************************************************************************

    Contains a transaction pool that is serializable to disk,
    using SQLite as a backing store.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.TransactionPool;

import agora.common.Data;
import agora.common.Deserializer;
import agora.common.Hash;
import agora.common.Serializer;
import agora.consensus.data.Transaction;

import d2sqlite3.database;
import d2sqlite3.library;
import d2sqlite3.results;
import d2sqlite3.sqlite3;

import vibe.core.log;

import std.algorithm;
import std.conv : to;
import std.exception : collectException, enforce;
import std.file : exists;
import std.range;

/// Ditto
public class TransactionPool
{
    /***************************************************************************

        Initialization function. Must be called once per-process
        (not per-thread!) before the class can be used.

    ***************************************************************************/

    shared static this()
    {
        .config(SQLITE_CONFIG_MULTITHREAD);
        version (unittest) {} else
            .config(SQLITE_CONFIG_LOG, &loggerCallback, null);
        .initialize();
    }

    /// SQLite db instance
    private Database db;


    /***************************************************************************

        Params:
            db_path = path to the database file, or in-memory storage if
                      :memory: was passed

    ***************************************************************************/

    public this (in string db_path)
    {
        const db_exists = db_path.exists;
        if (db_exists)
            logInfo("Loading database from: %s", db_path);

        this.db = Database(db_path);

        if (db_exists)
            logInfo("Loaded database from: %s", db_path);

        // create the table if it doesn't exist yet
        this.db.execute("CREATE TABLE IF NOT EXISTS tx_pool " ~
            "(key BLOB PRIMARY KEY, val BLOB NOT NULL)");
    }

    /***************************************************************************

        Callback used

        Params:
            arg = unused (null)
            code = the error code
            msg = the error message

    ***************************************************************************/

    private static extern(C) void loggerCallback (void *arg, int code,
        const(char)* msg) nothrow
    {
        try
        {
            logError("SQLite error: (%s) %s", code, msg.to!string);
        }
        catch (Exception ex)
        {
            // should not propagate exceptions to C code
        }
    }

    ~this ()
    {
        this.db.close();
    }

    /***************************************************************************

        Add a transaction to the pool

        Params:
            tx = the transaction to add

        Throws:
            SqliteException if the transaction failed to be added

    ***************************************************************************/

    public void add (Transaction tx) @safe
    {
        static ubyte[] buffer;
        buffer.length = 0;
        () @trusted { assumeSafeAppend(buffer); }();

        scope SerializeDg dg = (scope const(ubyte[]) data) nothrow @safe
        {
            buffer ~= data;
        };

        serializePart(tx, dg);

        () @trusted {
            db.execute("INSERT INTO tx_pool (key, val) VALUES (?, ?)",
                hashFull(tx)[], buffer);
        }();
    }

    /***************************************************************************

        Returns:
            the number of transactions in the pool

    ***************************************************************************/

    public size_t length () @safe
    {
        // todo: optimize / cache this
        return () @trusted {
            return db.execute("SELECT count(*) FROM tx_pool").oneValue!size_t;
        }();
    }

    /***************************************************************************

        Params:
            amount = how many transactions to return

        Returns:
            an array of 'amount' transactions

        Note:
            @trusted because most of the body executes non-@safe code,
            which is assumed to be safe

    ***************************************************************************/

    public Transaction[] take (size_t amount) @trusted
    {
        assert(amount <= this.length());

        Hash[] hashes;
        Transaction[] txs;

        auto results = db.execute("SELECT key, val FROM tx_pool LIMIT ?",
            amount);

        foreach (row; results)
        {
            hashes ~= *cast(Hash*)row.peek!(ubyte[])(0).ptr;
            txs ~= deserialize!Transaction(row.peek!(ubyte[])(1));
        }

        const len_prev = this.length();

        hashes.each!(hash => db.execute("DELETE FROM tx_pool WHERE key = ?",
            hash[]));

        enforce(this.length() == len_prev - amount, "Did not delete txs properly");

        return txs;
    }
}

/// add / take tests
unittest
{
    import agora.consensus.Genesis;
    import std.exception;

    auto pool = new TransactionPool(":memory:");
    scope(exit) destroy(pool);

    auto gen_key = getGenesisKeyPair();
    auto txs = makeChainedTransactions(gen_key, null, 1);

    txs.each!(tx => pool.add(tx));
    assert(pool.length == txs.length);

    auto pool_txs = pool.take(txs.length);
    assert(pool.length == 0);
    assert(txs == pool_txs);

    // adding duplicate tx hash => exception throw
    pool.add(txs[0]);
    assertThrown!SqliteException(pool.add(txs[0]));
}

/// memory reclamation tests
unittest
{
    import agora.common.Deserializer;
    import agora.common.Serializer;
    import agora.consensus.data.Block;
    import agora.consensus.Genesis;
    import std.exception;
    import core.memory;

    auto pool = new TransactionPool(":memory:");
    scope(exit) destroy(pool);

    auto gen_key = getGenesisKeyPair();
    auto txs = makeChainedTransactions(gen_key, null, 1);

    txs.each!(tx => pool.add(tx));
    assert(pool.length == txs.length);

    // store the txes in serialized form
    ubyte[][] txs_bytes;
    txs.each!(tx => txs_bytes ~= serializeFull(tx));

    txs = null;
    GC.collect();  // GC should not have collected the transactions

    // deserialize the transactions
    txs_bytes.each!((data)
        {
            Transaction tx;
            scope DeserializeDg dg = (size) nothrow @safe
            {
                ubyte[] res = data[0 .. size];
                data = data[size .. $];
                return res;
            };

            tx.deserialize(dg);
            txs ~= tx;
        });

    auto pool_txs = pool.take(txs.length);
    assert(pool.length == 0);
    assert(txs == pool_txs);
}
