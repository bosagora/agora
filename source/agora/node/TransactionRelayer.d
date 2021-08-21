/*******************************************************************************

    TransactionRelayer is responsible for storing transactions, and relaying
    some of them to all known network clients periodically. The current
    implementation relays transactions with the highest fees.

    The class contains several optimizations
    $(UL
        $(LI Transaction hashes are stored in a RedBlackTree sorted by the
             transaction fee. By doing so, getting the N transactions with
             the highest fees can be done quickly.)
        $(LI Transaction fee is calculated, and stored as part of the key
             to avoid the expensive fee recalculation every time an addition/remove
             operation is done on the RedBlackTree)
        $(LI Separate hash set is used to be able to quickly decide whether a
             transaction is in the RedBlackTree or not)
        $(LI Only the transaction hash(and not the entire transaction) is
             stored in the RedBlackTree to reduce memory usage)
        $(LI There is a periodic cleanup of old entries in the Hash set and in
             the RedBlackTree to reduce memory usage)
    )

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.TransactionRelayer;

import agora.common.Amount;
import agora.common.Task;
import agora.common.Types;
import agora.common.Set;
import agora.consensus.data.Transaction;
import agora.consensus.state.UTXOSet;
import agora.crypto.Hash;
import agora.utils.Log;
import agora.network.Client;
import agora.network.Clock;
import agora.network.Manager;
import agora.node.Config;
import agora.node.TransactionPool;

import std.algorithm;
import std.array : array;
import std.container : DList, RedBlackTree;

import core.time;

///
private alias SinkT = void delegate(scope const(char)[] v);
///
private alias SafeSinkT = void delegate(scope const(char)[] v) @safe;
///
private alias NodeConnInfo = NetworkManager.NodeConnInfo;

/// Returns the total fee for a transaction adjusted to its size in bytes.
public alias GetAdjustedFeeDg = string delegate(in Transaction tx, out Amount total_fee) nothrow @safe;

/// Transaction relayer interface, that accepts transactions and relays
/// them to known network clients.
public interface TransactionRelayer
{
    /***************************************************************************

        Adds a transaction to the relay queue. This function should only be
        called, after the transaction was succesfully added to the
        transaction pool.

        Params:
            tx = transaction to be added to the relay queue

        Returns:
            null, if there was no error, otherwise string detailing the error

    ***************************************************************************/

    public string addTransaction (in Transaction tx) @safe;

    /// Called during node shutdown.
    public void shutdown () @safe;

    /// Called during node startup.
    public void start ();
}

/// Transaction relayer implementation, that relays transactions with the highest
/// fees first.
public class TransactionRelayerFeeImp : TransactionRelayer
{
    ///
    private TransactionPool pool;

    ///
    private immutable Config config;

    ///
    private DList!NodeConnInfo* clients;

    ///
    private ITaskManager taskman;

    ///
    private Clock clock;

    ///
    private GetAdjustedFeeDg getAdjustedTXFee;

    /// Stores the transactions that needs to be relayed.
    private RedBlackTree!(TxHolder, TxHolder.cmpFeeLess, true) txs;

    /// Stores transaction hashes of transactions in the `txs` variable
    /// for fast lookups.
    private Set!Hash tx_hashes;

    ///
    private Logger log;

    ///
    private ITimer[] timers;

    ///
    private bool start_timers;

    ///
    version (unittest) public TestUTXOSet utxo_set;


    /***************************************************************************

        Constructor

        Params:
            pool = transaction pool
            config = config
            clients = network clients
            taskman = task manager
            clock = clock
            getAdjustedTXFee = delegate calculating transaction fee
            start_timers = controls whether the timers for relaying transactions
                and cleaning relay queues are started

    ***************************************************************************/

    public this (TransactionPool pool, immutable Config config, DList!NodeConnInfo* clients,
          ITaskManager taskman, Clock clock, GetAdjustedFeeDg getAdjustedTXFee, bool start_timers = true)
    {
        this.pool = pool;
        this.config = config;
        this.clients = clients;
        this.taskman = taskman;
        this.clock = clock;
        this.getAdjustedTXFee = getAdjustedTXFee;
        this.txs = new RedBlackTree!(TxHolder, TxHolder.cmpFeeLess, true)();
        this.log = Logger(__MODULE__);
        this.start_timers = start_timers;
    }

    /// Called during node startup.
    public void start ()
    {
        if (this.start_timers)
        {
            // if relay_tx_interval == 0, then we immediately relay the transaction
            if (this.config.node.relay_tx_interval != 0.seconds)
                this.timers ~= this.taskman.setTimer(config.node.relay_tx_interval, &this.relayTransactions, Periodic.Yes);
            this.timers ~= this.taskman.setTimer(1.minutes, &this.cleanRelayQueue, Periodic.Yes);
        }
    }

    /// Called during node shutdown.
    public void shutdown () @safe
    {
        foreach (timer; this.timers)
            if (timer !is null)
                timer.stop();
        this.timers = null;
    }

    /***************************************************************************

        Returns an array of transactions ordered by fee, that needs to be
        relayed to known network clients. The returned array might just be a
        subset of all the transactions in the relay queue.

        Returns:
            an array of transactions ordered by fee

    ***************************************************************************/

    private Transaction[] getRelayTransactions () @safe nothrow
    {
        immutable now = this.clock.networkTime();
        Transaction[] txs_gathered;
        reserve(txs_gathered, this.config.node.relay_tx_max_num);

        while (!this.txs.empty() &&
                ((this.config.node.relay_tx_max_num == 0) ||
                 (txs_gathered.length < this.config.node.relay_tx_max_num)))
        {
            TxHolder tx_holder = this.txs.front();
            if (tx_holder.expiry >= now)
            {
                Transaction tx = this.pool.getTransactionByHash(tx_holder.hash);
                if (tx != Transaction.init)
                    txs_gathered ~= tx;
            }

            this.tx_hashes.remove(tx_holder.hash);
            this.txs.removeFront();
        }
        return txs_gathered;
    }

    /// Sends an array of transactions ordered by fee to known network clients.
    public void relayTransactions () @safe nothrow
    {
        if ((*this.clients)[].canFind!(client => client.isValidator()))
            this.getRelayTransactions().each!(tx => (*this.clients).each!(node_info => node_info.client.sendTransaction(tx)));
    }

    /// Cleans expired entries from the internal datastructures.
    private void cleanRelayQueue () @safe
    {
        immutable now = this.clock.networkTime();

        // Cannot iterate through a RedBlackTree, and delete its elements at the
        // same time, so this is done in 2 steps.
        auto tx_holders = this.txs[].filter!(tx_holder => tx_holder.expiry < now).array();
        tx_holders.each!((tx_holder)
        {
            this.tx_hashes.remove(tx_holder.hash);
            this.txs.removeKey(tx_holder);
        });
    }

    /***************************************************************************

        Adds a transaction to the relay queue.

        Params:
            tx = transaction to be added to the relay queue

        Returns:
            null, if there was no error, otherwise string detailing the error

    ***************************************************************************/

    private string addTransactionImp (in Transaction tx) @safe nothrow
    {
        auto tx_hash = tx.hashFull();
        if (tx_hash in this.tx_hashes)
            return TransactionRelayError.TxAlreadyAdded;

        Amount fee;
        if (auto fee_err = this.getAdjustedTXFee(tx, fee))
            return fee_err;
        else if (!fee.isValid())
            return TransactionRelayError.TxFeeInvalid;

        if (fee < this.config.node.relay_tx_min_fee)
            return TransactionRelayError.TxFeeTooLow;

        this.txs.insert(TxHolder(fee, tx_hash,
            this.clock.networkTime() + this.config.node.relay_tx_cache_exp.total!"seconds"));
        this.tx_hashes.put(tx_hash);

        return null;
    }

    /***************************************************************************

        Adds a transaction to the relay queue.

        Unlike addTransactionImp, this method can have stronger side-effects
        like logging or even triggering transaction relay.
        This function should only be called, after the transaction was
        succesfully added to the transaction pool.

        Params:
            tx = transaction to be added to the relay queue

        Returns:
            null, if there was no error, otherwise string detailing the error

    ***************************************************************************/

    public override string addTransaction (in Transaction tx)  @safe nothrow
    {
        string res = this.addTransactionImp(tx);
        if (res)
            this.log.trace(res);
        else if (this.config.node.relay_tx_interval == 0.seconds)
            this.relayTransactions();
        return res;
    }

    ///
    public static enum TransactionRelayError : string
    {
        TxAlreadyAdded = "Transaction has already been added to the relay queue",
        TxFeeInvalid = "Transaction fee is invalid",
        TxFeeTooLow = "Transaction fee is too low",
    }

    ///
    private static struct TxHolder
    {
        /// Transaction fee.
        public Amount fee;

        /// Hash of the transaction.
        public Hash hash;

        /// The time when this entry should be removed from cache.
        public TimePoint expiry;

        ///
        public static bool cmpFeeLess (in TxHolder tx_holder1, in TxHolder tx_holder2) @safe nothrow
        {
            return tx_holder1.fee > tx_holder2.fee;
        }

        ///
        public void toString (scope SinkT dg) const @trusted
        {
            import std.format;

            // Workaround for missing @safe on the delegate passed to RedBlackTree.toString().
            auto safe_dg = cast(SafeSinkT) dg;

            formattedWrite(safe_dg, "{ amount: %s, hash: %s, expiry: %d }", this.fee, this.hash, this.expiry);
        }

        ///
        public string toString () const @safe
        {
            string ret;
            scope SinkT dg = (scope v) {ret ~= v;};
            this.toString(dg);
            return ret;
        }
    }

    /***************************************************************************

        Constructor used in tests

        Params:
            config = config

    ***************************************************************************/

    version (unittest)
    private this (immutable Config config)
    {
        import agora.common.ManagedDatabase;
        import agora.consensus.Fee;
        import agora.consensus.data.Params;

        this.utxo_set = new TestUTXOSet();
        auto stateDB = new ManagedDatabase(":memory:");
        auto cacheDB = new ManagedDatabase(":memory:");
        immutable params = new immutable(ConsensusParams)();
        auto fee_man = new FeeManager(stateDB, params);
        DList!NodeConnInfo clients;
        GetAdjustedFeeDg getAdjustedTXFee = (in Transaction tx, out Amount tot_fee)
        {
            return fee_man.getAdjustedTXFee(tx, &utxo_set.peekUTXO, tot_fee);
        };

        this(new TransactionPool(cacheDB), config, &clients, null, new MockClock(0), getAdjustedTXFee, false);
    }

    /***************************************************************************

        Utility method to create a transaction with a fee.

        Params:
            gen_out_ind = output index of the first Genesis payment transaction
            fee = the required fee in the transaction

        Returns:
            transaction with the desired fee

    ***************************************************************************/

    version (unittest)
    static Transaction getTX (ushort gen_out_ind, Amount fee)
    {
        import agora.consensus.data.genesis.Test;
        import agora.crypto.Key;
        import agora.utils.Test;
        import std.array;

        auto genesis_tx = GenesisBlock.txs.filter!(tx => tx.isPayment).front;
        Amount amount = genesis_tx.outputs[gen_out_ind].value;
        amount -= fee;
        Transaction tx = Transaction(
                [Input(genesis_tx.hashFull(), gen_out_ind)],
            [Output(amount, WK.Keys.AA.address)]);

        return tx;
    }

    unittest
    {
        import agora.consensus.data.genesis.Test;
        import agora.crypto.Key;

        import std.algorithm.comparison;
        import std.array;

        NodeConfig node_config =
        {
            relay_tx_max_num: 2,
            relay_tx_interval: 5.seconds,
            relay_tx_min_fee: Amount(3),
            relay_tx_cache_exp: 12.seconds,
        };
        Config config = {node: node_config};
        auto transaction_relayer = new TransactionRelayerFeeImp(config);

        transaction_relayer.utxo_set.put(GenesisBlock.txs.filter!(tx => tx.isPayment).array()[0]);
        auto tx_size = getTX(0, Amount(0)).sizeInBytes();

        // transaction fee too low
        assert(transaction_relayer.addTransactionImp(getTX(0, Amount(3 * tx_size - 1))) == TransactionRelayError.TxFeeTooLow);

        // adding a valid transaction with the smalles possible fee
        auto tx1 = getTX(0, Amount(3 * tx_size));
        assert(transaction_relayer.addTransactionImp(tx1) is null);

        // trying to add the same valid transaction again
        assert(transaction_relayer.addTransactionImp(tx1) == TransactionRelayError.TxAlreadyAdded);

        // adding 3 more valid
        auto tx2 = getTX(1, Amount(9 * tx_size));
        assert(transaction_relayer.addTransactionImp(tx2) is null);
        auto tx3 = getTX(2, Amount(10 * tx_size));
        assert(transaction_relayer.addTransactionImp(tx3) is null);
        auto tx4 = getTX(3, Amount(4 * tx_size));
        assert(transaction_relayer.addTransactionImp(tx4) is null);

        // adding tx1 .. tx4 to the transaction pool
        [tx1, tx2, tx3, tx4].each!(tx => transaction_relayer.pool.add(tx));

        assert(transaction_relayer.tx_hashes.length == 4);
        assert(transaction_relayer.txs.length == 4);

        // tx2 and tx3 has the highest fee among all the transactions, so they are
        // the ones that are returned
        assert(isPermutation(transaction_relayer.getRelayTransactions(), [tx2, tx3]));

        assert(transaction_relayer.tx_hashes.length == 2);
        assert(transaction_relayer.txs.length == 2);

        // clean up the relay queue without changing the clock
        transaction_relayer.cleanRelayQueue();
        assert(transaction_relayer.tx_hashes.length == 2);
        assert(transaction_relayer.txs.length == 2);

        // clean up the relay queue after changing the clock
        (cast(MockClock) transaction_relayer.clock).setTime(TimePoint.max - 1);
        transaction_relayer.cleanRelayQueue();
        assert(transaction_relayer.tx_hashes.length == 0);
        assert(transaction_relayer.txs.length == 0);
    }
}
