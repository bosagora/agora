/*******************************************************************************

    Contains a transaction pool that is serializable to disk,
    using SQLite as a backing store.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.pool.Transaction;

import agora.common.Amount;
import agora.common.ManagedDatabase;
import agora.common.Types;
import agora.common.Set;
import agora.consensus.data.Transaction;
import agora.consensus.data.genesis.Test;
import agora.crypto.Hash;
import agora.serialization.Serializer;
import agora.utils.Log;

import d2sqlite3.library;
import d2sqlite3.results;
import d2sqlite3.sqlite3;

import std.algorithm;
import std.conv : to;
import std.exception : collectException, enforce;
import std.functional : toDelegate;
import std.range;
import std.string;

version (unittest)
{
    import agora.common.Amount;
    import agora.crypto.Key;
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

/// A delegate type to select one of the double spent TXs
public alias DoubleSpentSelector = size_t delegate(Transaction[] txs);

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

    /// A delegate to select one of the double spent TXs
    public DoubleSpentSelector selector;

    /***************************************************************************

        Params:
            db = Instance of the cache database

    ***************************************************************************/

    public this (ManagedDatabase db,
            DoubleSpentSelector double_spent_selector = toDelegate(&TransactionPool.defaultSelector))
    {
        this.db = db;

        // create the table if it doesn't exist yet
        this.db.execute("CREATE TABLE IF NOT EXISTS tx_pool " ~
            "(key TEXT PRIMARY KEY, val BLOB NOT NULL, fee INTEGER NOT NULL)");

        // populate the input set from the tx'es in the DB
        foreach (const ref Transaction tx; this)
            this.updateSpenderList(tx);

        // Set selector after rebuilding the spender list, so nothing gets
        // filtered out
        this.selector = double_spent_selector;
    }

    /// Used in unittests of this moduule only
    version (unittest) private this ()
    {
        this(new ManagedDatabase(":memory:"));
    }

    /***************************************************************************

        Add a transaction to the pool

        Params:
            tx = the transaction to add
            fee = fee_rate

        Returns:
            true if the transaction has been added to the pool

    ***************************************************************************/

    public bool add (in Transaction tx, in Amount fee) @safe
    {
        static ubyte[] buffer;

        // check double-spend
        if (!isValidTransaction(tx))
            return false;

        // insert each input information of the transaction
        this.updateSpenderList(tx);

        serializeToBuffer(tx, buffer);

        () @trusted {
            db.execute("INSERT INTO tx_pool (key, val, fee) VALUES (?, ?, ?)",
                hashFull(tx), buffer, fee);
        }();

        return true;
    }

    /***************************************************************************

        Remove the transaction with the given key from the pool

        Params:
            tx = the transaction to remove
            rm_double_spent = remove the TXs that use the same utxo

    ***************************************************************************/

    public void remove (in Transaction tx, bool rm_double_spent = true) @trusted
    {
        auto tx_hash = tx.hashFull();

        this.db.execute("DELETE FROM tx_pool WHERE key = ?", tx_hash);

        if (rm_double_spent)
        {
            // Incoming TX is accepted into the chain, so any other TXs in the pool
            // that use the same utxos are now invalid, remove them too
            Set!Hash inv_txs;

            this.gatherDoubleSpentTXs(tx, inv_txs);
            foreach (input; tx.inputs)
                this.spenders.remove(input.utxo);

            inv_txs.each!(inv_tx_hash => this.remove(inv_tx_hash, false));
        }
        else
            foreach (input; tx.inputs)
                if (auto list = input.utxo in this.spenders)
                    (*list).remove(tx_hash);
    }

    /// Ditto
    public void remove (in Hash tx_hash, bool rm_double_spent = true) @trusted
    {
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

    private void updateSpenderList (in Transaction tx) @safe
    {
        auto tx_hash = tx.hashFull();

        // insert each input information of the transaction
        foreach (const ref input; tx.inputs)
        {
            const utxo = input.utxo;
            // Update the spenders list
            if (utxo !in this.spenders)
                this.spenders[utxo] = Set!Hash();
            this.spenders[utxo].put(tx_hash);
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

    public bool gatherDoubleSpentTXs (in Transaction tx,
        ref Set!Hash double_spent_txs) @safe
    {
        () @trusted { double_spent_txs.clear(); }();

        const tx_hash = tx.hashFull();
        foreach (const ref input; tx.inputs)
        {
            const utxo = input.utxo;
            if (auto cur_spenders = utxo in this.spenders)
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
            is(DGT : int delegate(in Transaction)) ||
            is(DGT : int delegate(ref Hash, ref Transaction)))
    {
        () @trusted
        {
            // TXs that went through the "selection" process and should be
            // skipped
            bool[Hash] skip_txs;

            auto results = this.db.execute("SELECT key, val FROM tx_pool");

            foreach (ref row; results)
            {
                auto key = Hash(row.peek!(char[])(0));
                if (key in skip_txs)
                    continue;

                auto tx = deserializeFull!Transaction(row.peek!(ubyte[])(1));

                Set!Hash db_keys; // Gather double spent TX keys
                if (this.selector && this.gatherDoubleSpentTXs(tx, db_keys))
                {
                    db_keys.put(key);

                    // Filter out TXs already went through the selector
                    Hash[] db_keys_filtered;
                    foreach (db_key; db_keys)
                        if (db_key !in skip_txs)
                            db_keys_filtered ~= db_key;

                    // Fetch TXs
                    Transaction[] db_txs;
                    foreach (db_key; db_keys_filtered)
                    {
                        auto db_tx = deserializeFull!Transaction(this.db.execute(
                        "SELECT val FROM tx_pool WHERE key = ?", db_key)
                            .oneValue!(ubyte[]));
                        db_txs ~= db_tx;
                    }

                    auto selected_idx = this.selector(db_txs);
                    // Our new TX that we will return
                    tx = db_txs[selected_idx];
                    key = db_keys_filtered[selected_idx];

                    // Update the skip list
                    db_txs.each!(db_tx => skip_txs[db_tx.hashFull()] = true);
                    this.gatherDoubleSpentTXs(tx, db_keys);
                    db_keys.each!(db_key => skip_txs[db_key] = true);
                }

                // break
                int ret;
                static if (is(DGT : int delegate(ref Hash, ref Transaction)))
                    ret = dg(key, tx);
                else
                    ret = dg(tx);
                if (ret)
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
            Hash hash;
            static if (is(DGT : int delegate(ref Hash, ref Transaction)))
                dg(hash, tx);
            else
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

    private bool isValidTransaction (in Transaction tx) @trusted
    {
        // Transaction pool should never deal with CoinBase TXs
        assert(!tx.isCoinbase);
        return !this.hasTransactionHash(tx.hashFull());
    }

    /***************************************************************************

        Select first TX from double-spend set

        Params:
            tx = the transaction set

        Returns:
            Always selects first transaction

    ***************************************************************************/

    private static size_t defaultSelector (Transaction[])
    {
        return 0;
    }

    /***************************************************************************

        Get a transaction from pool by hash

        Params:
            tx = the transaction hash

        Returns:
            Transaction or Transaction.init

    ***************************************************************************/

    public Transaction getTransactionByHash (in Hash hash) @trusted nothrow
    {
        try
        {
            auto results =  this.db.execute("SELECT val FROM tx_pool WHERE key = ?",
                hash);
            if (!results.empty)
                return deserializeFull!Transaction(results.oneValue!(ubyte[])());
        }
        catch (Exception ex)
            log.error("ManagedDatabase operation error on getTransactionByHash");
        return Transaction.init;
    }

    /***************************************************************************

        Returns:
            average fee_rate of the transactions in the pool

    ***************************************************************************/

    public Amount getAverageFeeRate () @trusted nothrow
    {
        try
        {
            return Amount(this.db.execute("SELECT AVG(fee) FROM tx_pool").oneValue!ulong);
        }
        catch (Exception ex)
            log.error("ManagedDatabase operation error on getTransactionByHash");

        return 0.coins;
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

    /// Can be used in unit tests to prevent spending the same utxo
    version (unittest) public bool spending (in Hash utxo) @safe nothrow
    {
        return !!(utxo in this.spenders);
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
    auto pool = new TransactionPool();
    auto gen_key = WK.Keys.Genesis;
    auto txs = genesisSpendable().map!(txb => txb.sign()).array();

    txs.each!(tx => pool.add(tx, 0.coins));
    assert(pool.length == txs.length);

    foreach (const ref tx; txs)
    {
        const(Hash) hash = hashFull(tx);
        assert(pool.hasTransactionHash(hash));
        pool.remove(tx);
        assert(!pool.hasTransactionHash(hash));
    }

    txs.each!(tx => pool.add(tx, 0.coins));
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

    auto pool = new TransactionPool();
    auto gen_key = WK.Keys.Genesis;
    auto txs = genesisSpendable().map!(txb => txb.sign()).array();

    txs.each!(tx => pool.add(tx, 0.coins));
    assert(pool.length == txs.length);

    auto pool_txs = pool.take(txs.length);
    assert(pool.length == 0);
    assert(txs == pool_txs);

    txs.each!(tx => pool.add(tx, 0.coins));
    assert(pool.length == txs.length);

    auto half_txs = pool.take(txs.length / 2);
    assert(half_txs.length == txs.length / 2);
    assert(pool.length == txs.length / 2);

    // adding duplicate tx hash => return false
    pool.add(txs[0], 0.coins);
    assert(!pool.add(txs[0], 0.coins));
}

/// memory reclamation tests
unittest
{
    import agora.consensus.data.Block;
    import std.exception;
    import core.memory;

    auto pool = new TransactionPool();
    auto gen_key = WK.Keys.Genesis;
    auto txs = genesisSpendable().map!(txb => txb.sign()).array();

    txs.each!(tx => pool.add(tx, 0.coins));
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
    // create first transaction pool
    auto pool = new TransactionPool();

    // create first transaction
    Transaction tx1 = Transaction(
        [Input(Hash.init, 0)],
        [Output(Amount(0), WK.Keys.A.address)]);

    // create second transaction
    Transaction tx2 = Transaction(
        [Input(Hash.init, 0)],
        [Output(Amount(0), WK.Keys.C.address)]);

    // add txs to the pool
    assert(pool.add(tx1, 0.coins));
    assert(pool.add(tx2, 0.coins));

    assert(pool.length == 2);
    pool.remove(tx1);
    assert(pool.length == 0);

    assert(pool.add(tx1, 0.coins));
    assert(pool.add(tx2, 0.coins));
    assert(pool.length == 2);
    pool.remove(tx2);
    assert(pool.length == 0);
}

/// test double-spending on the Transaction pool with different unlock age
unittest
{
    // create first transaction pool
    auto pool = new TransactionPool();

    // create first transaction
    Transaction tx1 = Transaction(
        [Input(Hash.init, 0, 1)],
        [Output(Amount(0), WK.Keys.A.address)]);

    // create second transaction
    Transaction tx2 = Transaction(
        [Input(Hash.init, 0, 2)],
        [Output(Amount(0), WK.Keys.C.address)]);

    // add txs to the pool
    assert(pool.add(tx1, 0.coins));
    assert(pool.add(tx2, 0.coins));

    assert(pool.length == 2);
    pool.remove(tx1);
    assert(pool.length == 0);

    assert(pool.add(tx1, 0.coins));
    assert(pool.add(tx2, 0.coins));
    assert(pool.length == 2);
    pool.remove(tx2);
    assert(pool.length == 0);
}

// test addition and removal of double-spend txs
unittest
{
    auto pool = new TransactionPool();

    Transaction tx1 = Transaction(
        [Input(Hash.init, 0)],
        [Output(Amount(0), WK.Keys.FR.address)]);

    Transaction tx2 = Transaction(
        [Input(Hash.init, 1)],
        [Output(Amount(0), WK.Keys.UK.address)]);

    Transaction tx3 = Transaction(
        [Input(Hash.init, 1)],
        [Output(Amount(0), WK.Keys.NL.address)]);

    assert(pool.add(tx1, 0.coins));
    assert(pool.add(tx2, 0.coins));
    assert(pool.add(tx3, 0.coins));
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
    auto pool = new TransactionPool();

    Transaction tx1 = Transaction(
        [Input(Hash.init, 0)],
        [Output(Amount(0), WK.Keys.ZA.address)]);

    Transaction tx2 = Transaction(
        [Input(Hash.init, 0), Input(Hash.init, 1)],
        [Output(Amount(0), WK.Keys.ZC.address)]);

    Transaction tx3 = Transaction(
        [Input(Hash.init, 1)],
        [Output(Amount(0), WK.Keys.ZD.address)]);

    assert(pool.add(tx1, 0.coins));
    assert(pool.add(tx2, 0.coins));
    assert(pool.add(tx3, 0.coins));
    assert(tx1 == pool.getTransactionByHash(tx1.hashFull()));
    assert(tx2 == pool.getTransactionByHash(tx2.hashFull()));
    assert(tx3 == pool.getTransactionByHash(tx3.hashFull()));
    assert(pool.length == 3);
    // tx2 will be removed as well.
    pool.remove(tx1);
    assert(pool.length == 1);
    assert(Transaction.init == pool.getTransactionByHash(tx1.hashFull()));
    assert(Transaction.init == pool.getTransactionByHash(tx2.hashFull()));
    assert(tx3 == pool.getTransactionByHash(tx3.hashFull()));
    assert(pool.hasTransactionHash(tx3.hashFull()));
}

// test double-spend selection mechanism with max output selector
unittest
{
    // Pick the TX with max output value, assumes only one output
    size_t selector (Transaction[] txs)
    {
        size_t max_idx = 0;
        Amount max_amt = txs[max_idx].outputs[0].value;

        foreach (idx, tx; txs)
        {
            assert(tx.outputs.length == 1);
            if (tx.outputs[0].value > max_amt)
            {
                max_idx = idx;
                max_amt = tx.outputs[0].value;
            }
        }
        return max_idx;
    }

    auto pool = new TransactionPool(new ManagedDatabase(":memory:"), &selector);

    Transaction tx1 = Transaction(
        [Input(Hash.init, 0)],
        [Output(Amount(2), WK.Keys.US.address)]);

    Transaction tx2 = Transaction([Input(Hash.init, 0), Input(Hash.init, 1)],
        [Output(Amount(1), WK.Keys.KR.address)]);

    assert(pool.add(tx1, 0.coins));
    assert(pool.add(tx2, 0.coins));
    assert(pool.length == 2);

    ulong idx = 0;
    // only tx1 should be returned.
    foreach (ref Hash hash, ref Transaction tx; pool)
    {
        assert(tx.hashFull() == hash);
        assert(tx == tx1);
        assert(idx++ == 0);
    }

    pool.remove(tx1);
    assert(pool.length == 0);

    // Now tx1 has lower output value
    tx1.outputs[0].value.sub(Amount(2));
    assert(pool.add(tx1, 0.coins));
    assert(pool.add(tx2, 0.coins));
    assert(pool.length == 2);

    idx = 0;
    // only tx2 should be returned.
    foreach (ref Hash hash, ref Transaction tx; pool)
    {
        assert(tx.hashFull() == hash);
        assert(tx == tx2);
        assert(idx++ == 0);
    }
}

// test double-spend selection mechanism with maximum fee selector
unittest
{
    import agora.consensus.Fee;
    import agora.consensus.state.UTXOSet;

    auto utxo_set = new TestUTXOSet();
    auto fee_man = new FeeManager();
    DoubleSpentSelector selector =
        (Transaction[] txs)
        {
            return maxIndex!((a, b)
                {
                    Amount rate_a;
                    Amount rate_b;
                    fee_man.getTxFeeRate(a, &utxo_set.peekUTXO, rate_a);
                    fee_man.getTxFeeRate(b, &utxo_set.peekUTXO, rate_b);
                    return rate_a < rate_b;
                })(txs);
        };
    auto pool = new TransactionPool(new ManagedDatabase(":memory:"), selector);

    auto genesis_tx = GenesisBlock.txs.filter!(tx => tx.isPayment).array()[0];

    // parent transaction
    Transaction tx1 = Transaction([Input(genesis_tx.hashFull(), 0)],
        [Output(Amount(1000), WK.Keys.KR.address)]);

    utxo_set.put(tx1);

    // double spent transaction, transaction trying to spend parent
    Transaction tx2 = Transaction([Input(tx1.hashFull(), 0)],
        [Output(Amount(200), WK.Keys.NZ.address)]);

    // double spent transaction, trying to spend parent
    Transaction tx3 = Transaction([Input(tx1.hashFull(), 0)],
        [Output(Amount(100), WK.Keys.AU.address)]);

    assert(pool.add(tx2, 0.coins));
    assert(pool.add(tx3, 0.coins));
    assert(pool.length == 2);

    // only tx3 should be returned, as we filter double spend transactions
    // and tx3 has a higher fee than tx2
    ulong cnt = 0;
    foreach (ref Hash hash, ref Transaction tx; pool)
    {
        assert(tx == tx3);
        assert(hash == tx3.hashFull());
        cnt++;
    }
    assert(cnt == 1);

    pool.remove(tx3);
    assert(pool.length == 0);
}


unittest
{
    auto pool = new TransactionPool();

    Transaction tx1 = Transaction(
        [Input(Hash.init, 0)],
        [Output(Amount(2), WK.Keys.GE.address)]);

    Transaction tx2 = Transaction(
        [Input(Hash.init, 1)],
        [Output(Amount(1), WK.Keys.CA.address)]);

    assert(pool.getAverageFeeRate() == 0.coins);

    assert(pool.add(tx1, Amount(4)));
    assert(pool.add(tx2, Amount(12)));

    assert(pool.getAverageFeeRate() == Amount(8));

    foreach (ref Hash hash, ref Transaction tx; pool)
    {
        assert(tx.hashFull() == hash);
    }

    pool.remove(tx2);
    assert(pool.getAverageFeeRate() == Amount(4));
}
