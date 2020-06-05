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

import agora.common.ManagedDatabase;
import agora.common.Types;
import agora.common.Hash;
import agora.common.Serializer;
import agora.common.Set;
import agora.consensus.data.Transaction;
import agora.utils.Log;

import d2sqlite3.library;
import d2sqlite3.results;
import d2sqlite3.sqlite3;

import std.algorithm;
import std.conv : to;
import std.exception : collectException, enforce;
import std.file : exists;
import std.range;
import std.string;

version (unittest)
{
    import agora.utils.Test;
}

/*******************************************************************************

    Initialize the logger and the transaction pool

    Transaction pool initialization  should only be done once per process,
    but `loggerCallback` uses `log` which is a TLS variable that might not
    be initialized if `loggerCallback` was to be called immediately.

*******************************************************************************/

static this ()
{
    log = Logger(__MODULE__);
    TransactionPool.initialize();
}

static ~this ()
{
    destroy(log);
}

/// Logger instance
private Logger log;

/// A transaction pool that is serializable to disk, backed by SQLite
public class TransactionPool
{
    /***************************************************************************

        Initialization function

        Must be called once per process (not per thread!),
        before the class can be used.

    ***************************************************************************/

    public static void initialize ()
    {
        static import core.atomic;
        static shared bool initialized;
        if (core.atomic.cas(&initialized, false, true))
        {
            .config(SQLITE_CONFIG_MULTITHREAD);
            .config(SQLITE_CONFIG_LOG, &loggerCallback, null);
        }
    }

    /// SQLite db instance
    private ManagedDatabase db;

    /// Map for hashes for Input objects of each transaction in TX pool
    private Set!Hash input_set;

    /***************************************************************************

        Params:
            db_path = path to the database file, or in-memory storage if
                      :memory: was passed

    ***************************************************************************/

    public this (in string db_path)
    {
        const db_exists = db_path.exists;
        if (db_exists)
            log.info("Loading database from: {}", db_path);

        // note: can fail. we may want to just recover txes from the network instead.
        this.db = new ManagedDatabase(db_path);

        if (db_exists)
            log.info("Loaded database from: {}", db_path);

        // create the table if it doesn't exist yet
        this.db.execute("CREATE TABLE IF NOT EXISTS tx_pool " ~
            "(key BLOB PRIMARY KEY, val BLOB NOT NULL)");

        // populate the input set from the tx'es in the DB
        foreach (_, tx; this)
        {
            foreach (const ref input; tx.inputs)
                this.input_set.put(input.hashFull());
        }
    }

    /***************************************************************************

        Add a transaction to the pool

        Params:
            tx = the transaction to add

        Returns:
            true if the transaction has been added to the pool

    ***************************************************************************/

    public bool add (Transaction tx) @safe
    {
        static ubyte[] buffer;

        // check double-spend
        if (!isValidTransaction(tx))
            return false;

        // insert each input information of the transaction
        foreach (input; tx.inputs)
            this.input_set.put(input.hashFull());

        serializeToBuffer(tx, buffer);

        () @trusted {
            db.execute("INSERT INTO tx_pool (key, val) VALUES (?, ?)",
                hashFull(tx)[], buffer);
        }();

        return true;
    }

    /***************************************************************************

        Remove the transaction with the given key from the pool

        Params:
            tx = the transaction to remove

    ***************************************************************************/

    public void remove (const ref Transaction tx) @trusted
    {
        // delete inputs of transaction from the set of Input hashes
        foreach (ref input; tx.inputs)
            this.input_set.remove(input.hashFull());

        auto hash = tx.hashFull();
        this.db.execute("DELETE FROM tx_pool WHERE key = ?", hash[]);
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

        Walk over the transactions in the pool and call the provided delegate
        with each hash and transaction

        Params:
            dg = the delegate to call

        Returns:
            the status code of the delegate, or zero

    ***************************************************************************/

    public int opApply (scope int delegate(Hash hash, Transaction tx) dg) @trusted
    {
        auto results = this.db.execute("SELECT key, val FROM tx_pool");

        foreach (row; results)
        {
            auto hash = *cast(Hash*)row.peek!(ubyte[])(0).ptr;
            auto tx = deserializeFull!Transaction(row.peek!(ubyte[])(1));

            // break
            if (auto ret = dg(hash, tx))
                return ret;
        }

        return 0;
    }

    /***************************************************************************

        Check if a transaction hash exists in the transaction pool.

        Params:
            tx = the transaction hash

        Returns:
            true if the transaction pool has the transaction hash.

    ***************************************************************************/

    public bool hasTransactionHash (const ref Hash tx) @trusted
    {
        return this.db.execute("SELECT EXISTS(SELECT 1 FROM " ~
            "tx_pool WHERE key = ?)", tx[]).front.peek!bool(0);
    }

    /***************************************************************************

        Check if the input transaction has any double spending input.

        Params:
            tx = the transaction to validate

        Returns:
            true if the transaction has no double spending input.

    ***************************************************************************/

    private bool isValidTransaction (const ref Transaction tx) @trusted
    {
        auto txHash = tx.hashFull();

        if (this.hasTransactionHash(txHash))
            return false;  // double-spend

        foreach (input; tx.inputs)
        {
            auto hash = input.hashFull();
            if (hash in this.input_set)
                return false;
        }

        return true;
    }

    /***************************************************************************

        Take the specified number of transactions and remove them from the pool.

        Params:
            count = how many transactions to take from the pool

        Returns:
            an array of 'count' transactions

    ***************************************************************************/

    version (unittest) private Transaction[] take (size_t count) @safe
    {
        const len_prev = this.length();
        assert(len_prev >= count);
        Transaction[] txs;

        foreach (hash, tx; this)
        {
            txs ~= tx;
            if (txs.length == count)
                break;
        }

        txs.each!(tx => this.remove(tx));
        assert(this.length() == len_prev - count);
        return txs;
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
        log.error("SQLite error: ({}) {}", code, msg.fromStringz);
    }
}

/// hasTransactionHash tests
unittest
{
    import agora.consensus.Genesis;

    auto pool = new TransactionPool(":memory:");
    auto gen_key = getGenesisKeyPair();
    auto txs = makeChainedTransactions(gen_key, null, 1);

    txs.each!(tx => pool.add(tx));
    assert(pool.length == txs.length);

    foreach (tx; txs)
    {
        const(Hash) hash = hashFull(tx);
        assert(pool.hasTransactionHash(hash));
        pool.remove(tx);
        assert(!pool.hasTransactionHash(hash));
    }

    txs.each!(tx => pool.add(tx));
    assert(pool.length == txs.length);
    const(Hash) hash = Hash.init;
    assert(!pool.hasTransactionHash(hash));
    // 'or 1=1-- SQL Injection attack Check
    static immutable SqlInjectHash =
        "0x276f7220313d312d2d20"
        ~ "20202020202020202020"
        ~ "20202020202020202020"
        ~ "20202020202020202020"
        ~ "20202020202020202020"
        ~ "20202020202020202020"
        ~ "20202020";
    const(Hash) sql_inject_hash = Hash(SqlInjectHash);
    assert(!pool.hasTransactionHash(sql_inject_hash));
}

/// add & opApply / remove tests (through take())
unittest
{
    import agora.consensus.Genesis;
    import std.exception;

    auto pool = new TransactionPool(":memory:");
    auto gen_key = getGenesisKeyPair();
    auto txs = makeChainedTransactions(gen_key, null, 1);

    txs.each!(tx => pool.add(tx));
    assert(pool.length == txs.length);

    auto pool_txs = pool.take(txs.length);
    assert(pool.length == 0);
    assert(txs == pool_txs);

    txs.each!(tx => pool.add(tx));
    assert(pool.length == txs.length);

    auto half_txs = pool.take(txs.length / 2);
    assert(half_txs.length == txs.length / 2);
    assert(pool.length == txs.length / 2);

    // adding duplicate tx hash => return false
    pool.add(txs[0]);
    assert(!pool.add(txs[0]));
}

/// memory reclamation tests
unittest
{
    import agora.consensus.data.Block;
    import agora.consensus.Genesis;
    import std.exception;
    import core.memory;

    auto pool = new TransactionPool(":memory:");
    auto gen_key = getGenesisKeyPair();
    auto txs = makeChainedTransactions(gen_key, null, 1);

    txs.each!(tx => pool.add(tx));
    assert(pool.length == txs.length);

    // store the txes in serialized form
    ubyte[][] txs_bytes;
    txs.each!(tx => txs_bytes ~= serializeFull(tx));

    txs = null;

    // deserialize the transactions
    txs_bytes.each!((data)
        {
            scope DeserializeDg dg = (size) nothrow @safe
            {
                ubyte[] res = data[0 .. size];
                data = data[size .. $];
                return res;
            };

            txs ~= deserializeFull!Transaction(dg);
        });

    auto pool_txs = pool.take(txs.length);
    assert(pool.length == 0);
    assert(txs == pool_txs);
}

/// test double-spending on the Transaction pool
unittest
{
    import agora.common.Amount;
    import agora.common.crypto.Key;
    import agora.common.Hash;

    auto seed1 = "SCFPAX2KQEMBHCG6SJ77YTHVOYKUVHEFDROVFCKTZUG7Z6Q5IKSNG6NQ";
    auto seed2 = "SCTTRCMT7DVZHQS375GWIKYQYHKA3X4IC4EOBNPRGV7DFR3X6OM5VIWL";
    auto seed3 = "SAI4SRN2U6UQ32FXNYZSXA5OIO6BYTJMBFHJKX774IGS2RHQ7DOEW5SJ";
    auto key_pair1 = KeyPair.fromSeed(Seed.fromString(seed1));
    auto key_pair2 = KeyPair.fromSeed(Seed.fromString(seed2));
    auto key_pair3 = KeyPair.fromSeed(Seed.fromString(seed3));

    // create first transaction pool
    auto pool = new TransactionPool(":memory:");

    // create first transaction
    Transaction tx1 =
    {
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output(Amount(0), key_pair2.address)]
    };
    auto signature = key_pair1.secret.sign(hashFull(tx1)[]);
    tx1.inputs[0].signature = signature;

    // create second transaction
    Transaction tx2 =
    {
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output(Amount(0), key_pair3.address)]
    };
    signature = key_pair1.secret.sign(hashFull(tx2)[]);
    tx2.inputs[0].signature = signature;

    // add first tx to the pool
    assert(pool.add(tx1));

    // add duplicate tx => return false
    assert(!pool.add(tx2));

    // create second transaction pool
    auto pool2 = new TransactionPool(":memory:");

    // add duplicate tx into second pool => return true
    assert(pool2.add(tx2));

    // add first tx => return false
    assert(!pool2.add(tx1));
}
