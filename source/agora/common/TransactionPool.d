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

mixin AddLogger!();

static this ()
{
    TransactionPool.initialize();
}

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

    /// Keeps track of which TXs spend which inputs
    private Set!Hash[Hash] spenders;

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
            "(key TEXT PRIMARY KEY, val BLOB NOT NULL)");

        // populate the input set from the tx'es in the DB
        foreach (const ref Transaction tx; this)
            this.updateSpenderList(tx);
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
        this.updateSpenderList(tx);

        serializeToBuffer(tx, buffer);

        () @trusted {
            db.execute("INSERT INTO tx_pool (key, val) VALUES (?, ?)",
                hashFull(tx), buffer);
        }();

        return true;
    }

    /***************************************************************************

        Remove the transaction with the given key from the pool

        Params:
            tx = the transaction to remove
            rm_double_spent = remove the TXs that use the same inputs

    ***************************************************************************/

    public void remove (const ref Transaction tx,
        bool rm_double_spent = true) @trusted
    {
        auto tx_hash = tx.hashFull();
        if (!this.hasTransactionHash(tx_hash))
            return;

        this.db.execute("DELETE FROM tx_pool WHERE key = ?", tx_hash);

        if (rm_double_spent)
        {
            // Incoming TX is accepted into the chain, so any other TXs in the pool
            // that use the same inputs are now invalid, remove them too
            Set!Hash inv_txs;

            this.gatherDoubleSpentTXs(tx, inv_txs);
            foreach (input; tx.inputs)
                this.spenders.remove(input.hashFull());

            inv_txs.each!(inv_tx_hash => this.remove(inv_tx_hash, false));
        }
        else
            foreach (input; tx.inputs)
                if (auto list = input.hashFull() in this.spenders)
                    (*list).remove(tx_hash);
    }

    /// Ditto
    public void remove (Hash tx_hash,
        bool rm_double_spent = true) @trusted
    {
        if (!this.hasTransactionHash(tx_hash))
            return;

        auto results = this.db.execute("SELECT val FROM tx_pool " ~
            "WHERE key = ?", tx_hash);
        if (!results.empty)
        {
            auto tx = deserializeFull!Transaction(results
                .front.peek!(ubyte[])(0));
            this.remove(tx, rm_double_spent);
        }
    }

    /***************************************************************************

        Add the given TX to `spenders` list

        Params:
            tx = the transaction to add

    ***************************************************************************/

    private void updateSpenderList (const ref Transaction tx) @safe
    {
        auto tx_hash = tx.hashFull();

        // insert each input information of the transaction
        foreach (const ref input; tx.inputs)
        {
            const in_hash = input.hashFull();
            // Update the spenders list
            if (in_hash !in this.spenders)
                this.spenders[in_hash] = Set!Hash();
            this.spenders[in_hash].put(tx_hash);
        }
    }

    /***************************************************************************

        Gather TXs that share inputs with the given TX

        Params:
            tx = a transaction
            double_spent_txs = container to write the double-spend TXs

        Returns:
            true if double-spend TXs where found, false otherwise

    ***************************************************************************/

    private bool gatherDoubleSpentTXs (const ref Transaction tx,
        ref Set!Hash double_spent_txs)
    {
        double_spent_txs.clear();

        const tx_hash = tx.hashFull();
        foreach (const ref input; tx.inputs)
        {
            const in_hash = input.hashFull();
            if (auto cur_spenders = in_hash in this.spenders)
                foreach (spender; *cur_spenders)
                    if (spender != tx_hash)
                        double_spent_txs.put(spender);
        }

        return double_spent_txs.length > 0;
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

    public int opApply (DGT) (scope DGT dg)
        if (is(DGT : int delegate(Transaction)) ||
            is(DGT : int delegate(ref Transaction)) ||
            is(DGT : int delegate(const Transaction)) ||
            is(DGT : int delegate(const ref Transaction)) ||
            is(DGT : int delegate(in Transaction)))
    {
        () @trusted
        {
            auto results = this.db.execute("SELECT val FROM tx_pool");

            foreach (ref row; results)
            {
                auto tx = deserializeFull!Transaction(row.peek!(ubyte[])(0));

                // break
                if (auto ret = dg(tx))
                    return ret;
            }
            return 0;
        }();

        // HACK: We don't want this code to ever execute and the dg should never
        // be `null` (it would have segfaulted in the iteration).
        // However, we want the delegate attributes to determine the `opApply`'s
        // attribute, hence this block.
        // Remove when the SQLite binding is `@safe` and the `@trusted` delegate
        // can be removed
        if (dg is null)
        {
            Transaction tx;
            dg(tx);
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

    public bool hasTransactionHash (in Hash tx) @trusted
    {
        return this.db.execute("SELECT EXISTS(SELECT 1 FROM " ~
            "tx_pool WHERE key = ?)", tx).front.peek!bool(0);
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
        return !this.hasTransactionHash(tx.hashFull());
    }

    /***************************************************************************

        Take the specified number of transactions and remove them from the pool.

        Params:
            count = how many transactions to take from the pool

        Returns:
            an array of 'count' transactions

    ***************************************************************************/

    version (unittest) private const(Transaction)[] take (size_t count) @safe
    {
        const len_prev = this.length();
        assert(len_prev >= count);
        const(Transaction)[] txs;

        foreach (const ref Transaction tx; this)
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
    auto pool = new TransactionPool(":memory:");
    auto gen_key = WK.Keys.Genesis;
    auto txs = genesisSpendable().map!(txb => txb.sign()).array();

    txs.each!(tx => pool.add(tx));
    assert(pool.length == txs.length);

    foreach (const ref tx; txs)
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
    import std.exception;

    auto pool = new TransactionPool(":memory:");
    auto gen_key = WK.Keys.Genesis;
    auto txs = genesisSpendable().map!(txb => txb.sign()).array();

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
    import std.exception;
    import core.memory;

    auto pool = new TransactionPool(":memory:");
    auto gen_key = WK.Keys.Genesis;
    auto txs = genesisSpendable().map!(txb => txb.sign()).array();

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

    // add txs to the pool
    assert(pool.add(tx1));
    assert(pool.add(tx2));

    assert(pool.length == 2);
    pool.remove(tx1);
    assert(pool.length == 0);

    assert(pool.add(tx1));
    assert(pool.add(tx2));
    assert(pool.length == 2);
    pool.remove(tx2);
    assert(pool.length == 0);
}

// test addition and removal of double-spend txs
unittest
{
    import agora.common.Amount;
    import agora.common.crypto.Key;
    import agora.common.Hash;

    auto pool = new TransactionPool(":memory:");

    Transaction tx1 =
    {
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output(Amount(0), KeyPair.random.address)]
    };

    Transaction tx2 =
    {
        TxType.Payment,
        [Input(Hash.init, 1)],
        [Output(Amount(0), KeyPair.random.address)]
    };

    Transaction tx3 =
    {
        TxType.Payment,
        [Input(Hash.init, 1)],
        [Output(Amount(0), KeyPair.random.address)]
    };

    assert(pool.add(tx1));
    assert(pool.add(tx2));
    assert(pool.add(tx3));
    assert(pool.length == 3);
    // tx3 should be removed as well.
    pool.remove(tx2);
    assert(pool.length == 1);
    assert(pool.hasTransactionHash(tx1.hashFull()));
}

// test addition and removal of double-spend txs
// with a more complex relation betwween double-spend txs
unittest
{
    import agora.common.Amount;
    import agora.common.crypto.Key;
    import agora.common.Hash;

    auto pool = new TransactionPool(":memory:");

    Transaction tx1 =
    {
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output(Amount(0), KeyPair.random.address)]
    };

    Transaction tx2 =
    {
        TxType.Payment,
        [Input(Hash.init, 0), Input(Hash.init, 1)],
        [Output(Amount(0), KeyPair.random.address)]
    };

    Transaction tx3 =
    {
        TxType.Payment,
        [Input(Hash.init, 1)],
        [Output(Amount(0), KeyPair.random.address)]
    };

    assert(pool.add(tx1));
    assert(pool.add(tx2));
    assert(pool.add(tx3));
    assert(pool.length == 3);
    // tx2 will be removed as well.
    pool.remove(tx1);
    assert(pool.length == 1);
    assert(pool.hasTransactionHash(tx3.hashFull()));
}
