/*******************************************************************************

    Contains supporting code for tracking the current ledger.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.Ledger;

import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Hash;
import agora.common.TransactionPool;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXOSet;
import agora.consensus.Genesis;
import agora.consensus.Validation;
import agora.node.API;
import agora.node.BlockStorage;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

import std.algorithm;
import std.range;

mixin AddLogger!();

/// Ditto
public class Ledger
{
    /// data storage for all the blocks
    private IBlockStorage storage;

    /// Pool of transactions to pick from when generating blocks
    private TransactionPool pool;

    /// The last block in the ledger
    private Block last_block;

    /// UTXO set
    private UTXOSet utxo_set;


    /***************************************************************************

        Constructor

        Params:
            pool = the transaction pool
            utxo_set = the set of unspent outputs
            storage = the block storage

    ***************************************************************************/

    public this (TransactionPool pool, UTXOSet utxo_set, IBlockStorage storage)
    {
        this.pool = pool;
        this.utxo_set = utxo_set;
        this.storage = storage;
        if (!this.storage.load())
            assert(0);

        // ensure latest checksum can be read
        if (!this.storage.readLastBlock(this.last_block))
            assert(0);

        // need to regenerate the UTXO set, starting from the genesis block
        if (this.utxo_set.length == 0)
        {
            Block block;
            foreach (height; 0 .. this.last_block.header.height + 1)
            {
                if (!this.storage.readBlock(block, height))
                    assert(0);

                this.updateUTXOSet(block);
            }
        }
    }

    /***************************************************************************

        Add a block to the ledger.

        If the block fails verification, it is not added to the ledger.

        Params:
            block = the block to add

        Returns:
            true if the block was accepted

    ***************************************************************************/

    public bool acceptBlock (const ref Block block) nothrow @safe
    {
        scope (failure) assert(0);

        if (auto fail_reason = this.validateBlock(block))
        {
            log.trace("Rejected block: {}: {}", fail_reason, block.prettify());
            return false;
        }

        this.addValidatedBlock(block);
        return true;
    }

    /***************************************************************************

        Called when a new transaction is received.

        If the transaction is accepted it will be added to
        the transaction pool. If there are enough valid transactions
        in the pool, a block will be created.

        If the transaction is invalid, it's rejected and false is returned.

        Params:
            tx = the received transaction

        Returns:
            true if the transaction is valid and was added to the pool

    ***************************************************************************/

    public bool acceptTransaction (Transaction tx) @safe
    {
        if (!this.isValidTransaction(tx) || !this.pool.add(tx))
        {
            log.info("Rejected tx: {}", tx);
            return false;
        }

        if (this.pool.length >= Block.TxsInBlock)
            this.tryCreateBlock();

        return true;
    }

    /***************************************************************************

        Add a validated block to the Ledger,
        and add all of its outputs to the UTXO set.

        Params:
            block = the block to add

    ***************************************************************************/

    private void addValidatedBlock (const ref Block block) nothrow @safe
    {
        scope (failure) assert(0);

        this.updateUTXOSet(block);
        if (!this.storage.saveBlock(block))
            assert(0);

        // read back and cache the last block
        if (!this.storage.readLastBlock(this.last_block))
            assert(0);
    }

    /***************************************************************************

        Update the UTXO set based on the block's transactions

        Params:
            block = the block to update the UTXO set with

    ***************************************************************************/

    private void updateUTXOSet (const ref Block block) nothrow @safe
    {
        scope (failure) assert(0);

        const ulong height = block.header.height;
        // add the new UTXOs
        block.txs.each!(tx => this.utxo_set.updateUTXOCache(tx, height));

        // remove the TXs from the Pool
        block.txs.each!(tx => this.pool.remove(tx));
    }

    /***************************************************************************

        Try making a new block if there are enough valid and non double-spending
        transactions in the pool

        Double-spending transactions will be skipped over while iterating
        over the pool. If there are not enough valid transactions,
        a block will not be created.

    ***************************************************************************/

    private void tryCreateBlock () @safe
    {
        Hash[] hashes;
        Transaction[] txs;
        ulong expect_height = this.getBlockHeight() + 1;

        auto utxo_finder = this.utxo_set.getUTXOFinder();
        foreach (hash, tx; this.pool)
        {
            if (auto reason = tx.isInvalidReason(utxo_finder, expect_height))
                log.trace("Rejected invalid ('{}') tx: {}", reason, tx);
            else
            {
                hashes ~= hash;
                txs ~= tx;
            }

            if (txs.length >= Block.TxsInBlock)
                break;
        }

        if (txs.length != Block.TxsInBlock)
            return;  // not enough valid txs

        auto block = makeNewBlock(this.last_block, txs);
        if (!this.acceptBlock(block))  // txs should be valid
            assert(0);
    }

    /***************************************************************************

        Check whether the transaction is valid and may be added to the pool.

        A transaction is valid if it references a previous UTXO in the
        blockchain. Note that double-spend transactions are not tracked here,
        they are only tracked during the creation of a block.

        Params:
            transaction = the transaction to validate

        Returns:
            true if the transaction may be added to the pool

    ***************************************************************************/

    public bool isValidTransaction (const ref Transaction tx) nothrow @safe
    {
        const ulong expect_height = this.getBlockHeight() + 1;
        return tx.isInvalidReason(this.utxo_set.getUTXOFinder(), expect_height) is null;
    }

    /***************************************************************************

        Check whether the block is valid.

        Params:
            block = the block to check

        Returns:
            the error message if block validation failed, otherwise null

    ***************************************************************************/

    public string validateBlock (const ref Block block) nothrow @safe
    {
        return block.isInvalidReason(last_block.header.height,
            last_block.header.hashFull, this.utxo_set.getUTXOFinder());
    }

    /***************************************************************************

        Returns:
            latest block height

    ***************************************************************************/

    public ulong getBlockHeight () @safe nothrow
    {
        return this.last_block.header.height;
    }

    /***************************************************************************

        Get a range of blocks, starting from the provided block height.

        Params:
            start_height = the starting block height to begin retrieval from

        Returns:
            the range of blocks starting from start_height

    ***************************************************************************/

    public auto getBlocksFrom (size_t start_height) @safe nothrow
    {
        start_height = min(start_height, this.getBlockHeight() + 1);

        const(Block) readBlock (size_t height)
        {
            Block block;
            if (!this.storage.readBlock(block, height))
                assert(0);
            return block;
        }

        return iota(start_height, this.getBlockHeight() + 1)
            .map!(idx => readBlock(idx));
    }

    /***************************************************************************

        Get the array of hashs the merkle path.

        Params:
            block_height = block height with transaction hash
            hash         = transaction hash

        Returns:
            the array of hashs the merkle path

    ***************************************************************************/

    public Hash[] getMerklePath (ulong block_height, Hash hash) @safe
    {
        if (this.getBlockHeight() < block_height)
            return null;

        Block block;
        if (!this.storage.readBlock(block, block_height))
            assert(0);
        size_t index = block.findHashIndex(hash);
        if (index >= block.txs.length)
            return null;
        return block.getMerklePath(index);
    }
}

///
unittest
{
    import agora.common.crypto.Key;
    import agora.common.Types;
    import agora.common.Hash;

    auto storage = new MemBlockStorage();
    auto pool = new TransactionPool(":memory:");
    scope(exit) pool.shutdown();
    auto utxo_set = new UTXOSet(":memory:");
    scope (exit) utxo_set.shutdown();
    scope ledger = new Ledger(pool, utxo_set, storage);
    assert(ledger.getBlockHeight() == 0);

    auto blocks = ledger.getBlocksFrom(0).take(10);
    assert(blocks[$ - 1] == GenesisBlock);

    auto gen_key_pair = getGenesisKeyPair();
    Transaction[] last_txs;

    // generate enough transactions to form a block
    void genBlockTransactions (size_t count)
    {
        auto txes = makeChainedTransactions(gen_key_pair, last_txs, count);
        txes.each!((tx)
            {
                assert(ledger.acceptTransaction(tx));
            });

        // keep track of last tx's to chain them to
        last_txs = txes[$ - Block.TxsInBlock .. $];
    }

    genBlockTransactions(2);
    blocks = ledger.getBlocksFrom(0).take(10);
    assert(blocks[0] == GenesisBlock);
    assert(blocks[0].header.height == 0);
    assert(blocks.length == 3);  // two blocks + genesis block

    /// now generate 98 more blocks to make it 100 + genesis block (101 total)
    genBlockTransactions(98);
    assert(ledger.getBlockHeight() == 100);

    blocks = ledger.getBlocksFrom(0).takeExactly(10);
    assert(blocks[0] == GenesisBlock);
    assert(blocks[0].header.height == 0);
    assert(blocks.length == 10);

    /// lower limit
    blocks = ledger.getBlocksFrom(0).takeExactly(5);
    assert(blocks[0] == GenesisBlock);
    assert(blocks[0].header.height == 0);
    assert(blocks.length == 5);

    /// different indices
    blocks = ledger.getBlocksFrom(1).takeExactly(10);
    assert(blocks[0].header.height == 1);
    assert(blocks.length == 10);

    blocks = ledger.getBlocksFrom(50).takeExactly(10);
    assert(blocks[0].header.height == 50);
    assert(blocks.length == 10);

    blocks = ledger.getBlocksFrom(95).take(10);  // only 6 left from here (block 100 included)
    assert(blocks.front.header.height == 95);
    assert(blocks.walkLength() == 6);

    blocks = ledger.getBlocksFrom(99).take(10);  // only 2 left from here (ditto)
    assert(blocks.front.header.height == 99);
    assert(blocks.walkLength() == 2);

    blocks = ledger.getBlocksFrom(100).take(10);  // only 1 block available
    assert(blocks.front.header.height == 100);
    assert(blocks.walkLength() == 1);

    // over the limit => return up to the highest block
    assert(ledger.getBlocksFrom(0).take(1000).walkLength() == 101);

    // higher index than available => return nothing
    assert(ledger.getBlocksFrom(1000).take(10).walkLength() == 0);
}

/// basic block verification
unittest
{
    import agora.common.crypto.Key;
    import agora.common.Types;
    import agora.common.Hash;

    auto storage = new MemBlockStorage();
    auto pool = new TransactionPool(":memory:");
    scope(exit) pool.shutdown();
    auto utxo_set = new UTXOSet(":memory:");
    scope (exit) utxo_set.shutdown();
    scope ledger = new Ledger(pool, utxo_set, storage);

    Block invalid_block;  // default-initialized should be invalid
    assert(!ledger.acceptBlock(invalid_block));

    auto gen_key_pair = getGenesisKeyPair();
    auto txs = makeChainedTransactions(gen_key_pair, null, 1);

    auto valid_block = makeNewBlock(GenesisBlock, txs);
    assert(ledger.acceptBlock(valid_block));
}

/// Merkle Proof
unittest
{
    import agora.common.crypto.Key;

    auto storage = new MemBlockStorage();
    auto pool = new TransactionPool(":memory:");
    scope(exit) pool.shutdown();
    auto utxo_set = new UTXOSet(":memory:");
    scope (exit) utxo_set.shutdown();
    scope ledger = new Ledger(pool, utxo_set, storage);

    auto gen_key_pair = getGenesisKeyPair();
    auto txs = makeChainedTransactions(gen_key_pair, null, 1);
    txs.each!(tx => assert(ledger.acceptTransaction(tx)));

    Hash[] hashes;
    hashes.reserve(txs.length);
    foreach (ref e; txs)
        hashes ~= hashFull(e);

    // transactions are ordered lexicographically by hash in the Merkle tree
    hashes.sort!("a < b");

    const Hash ha = hashes[0];
    const Hash hb = hashes[1];
    const Hash hc = hashes[2];
    const Hash hd = hashes[3];
    const Hash he = hashes[4];
    const Hash hf = hashes[5];
    const Hash hg = hashes[6];
    const Hash hh = hashes[7];

    const Hash hab = hashMulti(ha, hb);
    const Hash hcd = hashMulti(hc, hd);
    const Hash hef = hashMulti(he, hf);
    const Hash hgh = hashMulti(hg, hh);

    const Hash habcd = hashMulti(hab, hcd);
    const Hash hefgh = hashMulti(hef, hgh);

    const Hash habcdefgh = hashMulti(habcd, hefgh);

    Hash[] merkle_path;
    merkle_path = ledger.getMerklePath(1, hc);
    assert(merkle_path.length == 3);
    assert(merkle_path[0] == hd);
    assert(merkle_path[1] == hab);
    assert(merkle_path[2] == hefgh);
    assert(habcdefgh == Block.checkMerklePath(hc, merkle_path, 2));
    assert(habcdefgh != Block.checkMerklePath(hd, merkle_path, 2));

    merkle_path = ledger.getMerklePath(1, he);
    assert(merkle_path.length == 3);
    assert(merkle_path[0] == hf);
    assert(merkle_path[1] == hgh);
    assert(merkle_path[2] == habcd);
    assert(habcdefgh == Block.checkMerklePath(he, merkle_path, 4));
    assert(habcdefgh != Block.checkMerklePath(hf, merkle_path, 4));

    merkle_path = ledger.getMerklePath(1, Hash.init);
    assert(merkle_path.length == 0);
}

/// test that the UTXO set is rebuilt if it's empty when the block storage has blocks
unittest
{
    import agora.common.crypto.Key;
    import agora.common.Types;
    import agora.common.Hash;

    auto storage = new MemBlockStorage();
    auto gen_key = getGenesisKeyPair();
    auto txs = makeChainedTransactions(gen_key, null, 1);
    auto block = makeNewBlock(GenesisBlock, txs);
    assert(storage.saveBlock(block));

    txs = makeChainedTransactions(gen_key, txs, 1);
    block = makeNewBlock(block, txs);
    assert(storage.saveBlock(block));

    auto pool = new TransactionPool(":memory:");
    scope(exit) pool.shutdown();
    auto utxo_set = new UTXOSet(":memory:");
    scope (exit) utxo_set.shutdown();
    scope ledger = new Ledger(pool, utxo_set, storage);

    assert(utxo_set.length == 8);
    auto finder = utxo_set.getUTXOFinder();
    auto new_txs = makeChainedTransactions(gen_key, txs, 1);

    assert(new_txs.length > 0);
    UTXOSetValue _val;
    new_txs.each!(tx => assert(finder(tx.inputs[0].previous, tx.inputs[0].index,
        _val)));
}

version (unittest)
private Transaction[] makeTransactionForFreezing (
    KeyPair[] in_key_pair,
    KeyPair[] out_key_pair,
    TxType tx_type,
    Transaction[] prev_txs,
    const Transaction default_tx)
{
    import std.conv;

    assert(in_key_pair.length == Block.TxsInBlock);
    assert(out_key_pair.length == Block.TxsInBlock);

    assert(prev_txs.length == 0 || prev_txs.length == Block.TxsInBlock);
    const TxCount = Block.TxsInBlock;

    Transaction[] transactions;

    // always use the same amount, for simplicity
    const Amount AmountPerTx = Amount.FreezeAmount;

    foreach (idx; 0 .. TxCount)
    {
        Input input;
        if (prev_txs.length == 0)  // refering to genesis tx's outputs
            input = Input(hashFull(default_tx), idx.to!uint);
        else  // refering to tx's in the previous block
            input = Input(hashFull(prev_txs[idx % Block.TxsInBlock]), 0);

        Transaction tx =
        {
            tx_type,
            [input],
            [Output(AmountPerTx, out_key_pair[idx % Block.TxsInBlock].address)]  // send to the same address
        };

        auto signature = in_key_pair[idx % Block.TxsInBlock].secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        transactions ~= tx;

        // new transactions will refer to the just created transactions
        // which will be part of the previous block after the block is created
        if (Block.TxsInBlock == 1 ||  // special case
            (idx > 0 && ((idx + 1) % Block.TxsInBlock == 0)))
        {
            // refer to tx'es which will be in the previous block
            prev_txs = transactions[$ - Block.TxsInBlock .. $];
        }
    }
    return transactions;
}

version (unittest)
private KeyPair[] getGenKeyPairs ()
{
    KeyPair[] res;
    foreach (idx; 0 .. Block.TxsInBlock)
        res ~= getGenesisKeyPair();
    return res;
}

version (unittest)
private KeyPair[] getRandomKeyPairs ()
{
    KeyPair[] res;
    foreach (idx; 0 .. Block.TxsInBlock)
        res ~= KeyPair.random;
    return res;
}

// Use a transaction with the type 'TxType.Freeze' to create a block and test UTXOSet.
unittest
{
    import agora.common.crypto.Key;
    import agora.common.Hash;
    import agora.common.Types;

    auto storage = new MemBlockStorage();
    auto pool = new TransactionPool(":memory:");
    scope(exit) pool.shutdown();

    auto utxo_set = new UTXOSet(":memory:");
    scope (exit) utxo_set.shutdown();

    scope ledger = new Ledger(pool, utxo_set, storage);

    KeyPair[] in_key_pairs;
    KeyPair[] out_key_pairs;
    Transaction[] last_txs;

    in_key_pairs = getGenKeyPairs();
    out_key_pairs = getRandomKeyPairs();

    // generate transactions to form a block
    void genBlockTransactions (size_t count, TxType tx_type)
    {
        foreach (idx; 0 .. count)
        {
            auto txes = makeTransactionForFreezing (
                in_key_pairs,
                out_key_pairs,
                tx_type,
                last_txs,
                GenesisTransaction);

            txes.each!((tx)
                {
                    assert(ledger.acceptTransaction(tx));
                });

            // keep track of last tx's to chain them to
            last_txs = txes[$ - Block.TxsInBlock .. $];

            in_key_pairs = out_key_pairs;
            out_key_pairs = getRandomKeyPairs();
        }
    }

    genBlockTransactions(1, TxType.Payment);
    assert(ledger.getBlockHeight() == 1);
    auto blocks = ledger.getBlocksFrom(0).take(10).array;
    assert(blocks.length == 2);
    assert(blocks[1].header.height == 1);

    genBlockTransactions(1, TxType.Freeze);
    assert(ledger.getBlockHeight() == 2);
    blocks = ledger.getBlocksFrom(0).take(10).array;
    assert(blocks.length == 3);
    assert(blocks[2].header.height == 2);
}

version (unittest)
private Transaction[] splitGenesisTransaction (
    KeyPair[] in_key,
    KeyPair[] out_key, Amount amount = Amount.FreezeAmount)
{
    Transaction[] txes;
    foreach (idx; 0 .. Block.TxsInBlock)
    {
        Transaction tx = {TxType.Payment, [], []};
        tx.inputs ~= Input(hashFull(GenesisTransaction), idx);
        foreach (idx2; 0 .. Block.TxsInBlock)
            tx.outputs ~= Output(amount, out_key[idx].address);

        auto signature = in_key[idx].secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        txes ~= tx;
    }

    return txes;
}

/// Test validation of transactions associated with freezing
///
/// Table of freezing status changes over time
/// ---------------------------------------------------------------------------
/// freezing status     / melted     / frozen     / melting    / melted
/// ---------------------------------------------------------------------------
/// block height        / N1         / N2         / N3         / N4
/// ---------------------------------------------------------------------------
/// condition to use    /            / N2 >= N1+1 / N3 >= N2+1 / N4 >= N3+2016
/// ---------------------------------------------------------------------------
/// utxo unlock height  / N1+1       / N2+1       / N3+2016    / N4+1
/// ---------------------------------------------------------------------------
/// utxo type           / Payment    / Freeze     / Payment    / Payment
/// ---------------------------------------------------------------------------
unittest
{
    import agora.common.crypto.Key;
    import agora.common.Hash;
    import agora.common.Types;

    auto storage = new MemBlockStorage();
    auto pool = new TransactionPool(":memory:");
    scope(exit) pool.shutdown();

    auto utxo_set = new UTXOSet(":memory:");
    scope (exit) utxo_set.shutdown();

    scope ledger = new Ledger(pool, utxo_set, storage);

    KeyPair[] splited_keys = getRandomKeyPairs();

    Transaction[] splited_txex;

    // Divide 8 'Outputs' that are included in Genesis Block by 40,000
    // It generates eight addresses and eight transactions,
    // and one transaction has eight Outputs with a value of 40,000 values.
    void splitGenesis ()
    {
        splited_txex = splitGenesisTransaction(getGenKeyPairs(), splited_keys);
        splited_txex.each!((tx)
        {
            assert(ledger.acceptTransaction(tx));
        });
    }

    KeyPair[] in_key_pairs_normal;
    KeyPair[] out_key_pairs_normal;
    Transaction[] last_txs_normal;

    in_key_pairs_normal.length = 0;
    foreach (idx; 0 .. Block.TxsInBlock)
        in_key_pairs_normal ~= splited_keys[0];

    out_key_pairs_normal = getRandomKeyPairs();

    // generate nomal transactions to form a block
    void genNormalBlockTransactions (size_t count, bool is_valid = true)
    {
        foreach (idx; 0 .. count)
        {
            auto txes = makeTransactionForFreezing (
                in_key_pairs_normal,
                out_key_pairs_normal,
                TxType.Payment,
                last_txs_normal,
                splited_txex[0]);

            txes.each!((tx)
                {
                    assert(ledger.acceptTransaction(tx) == is_valid);
                });

            if (is_valid)
            {
                // keep track of last tx's to chain them to
                last_txs_normal = txes[$ - Block.TxsInBlock .. $];

                in_key_pairs_normal = out_key_pairs_normal;
                out_key_pairs_normal = getRandomKeyPairs();
            }
        }
    }

    KeyPair[] in_key_pairs_freeze;
    KeyPair[] out_key_pairs_freeze;
    Transaction[] last_txs_freeze;

    in_key_pairs_freeze.length = 0;
    foreach (idx; 0 .. Block.TxsInBlock)
        in_key_pairs_freeze ~= splited_keys[1];

    out_key_pairs_freeze = getRandomKeyPairs();

    // generate freezing transactions to form a block
    void genBlockTransactionsFreeze (size_t count, TxType tx_type, bool is_valid = true)
    {
        foreach (idx; 0 .. count)
        {
            auto txes = makeTransactionForFreezing (
                in_key_pairs_freeze,
                out_key_pairs_freeze,
                tx_type,
                last_txs_freeze,
                splited_txex[1]);

            txes.each!((tx)
                {
                    assert(ledger.acceptTransaction(tx) == is_valid);
                });

            if (is_valid)
            {
                // keep track of last tx's to chain them to
                last_txs_freeze = txes[$ - Block.TxsInBlock .. $];

                in_key_pairs_freeze = out_key_pairs_freeze;
                out_key_pairs_freeze = getRandomKeyPairs();
            }
        }
    }

    // -------------------------------------------------------------------------
    // Split Genesis Transaction
    // Current height  : 0
    // Current Status  : melted
    // Expected height : 1
    // Expected Status : melted
    // Progress        : melted
    // -------------------------------------------------------------------------
    splitGenesis();
    assert(ledger.getBlockHeight() == 1);

    // -------------------------------------------------------------------------
    // Create Payment block (Number of transactions Block.TxsInBlock)
    // Current height  : 1
    // Current Status  : melted
    // Expected height : 2
    // Expected Status : melted
    // Result          : Success
    // Progress        : melted
    // -------------------------------------------------------------------------
    genNormalBlockTransactions(1);
    assert(ledger.getBlockHeight() == 2);

    // -------------------------------------------------------------------------
    // Creates freezing block (Number of transactions Block.TxsInBlock)
    // Current height  : 2
    // Current Status  : melted
    // Expected height : 3
    // Expected Status : frozen
    // Result          : Success
    // Progress        : melted -> frozen
    // -------------------------------------------------------------------------
    genBlockTransactionsFreeze(1, TxType.Freeze);
    assert(ledger.getBlockHeight() == 3);

    // -------------------------------------------------------------------------
    // Creates 7 dummy payment blocks (Number of transactions Block.TxsInBlock * 7)
    // Not related to previously frozen UTXO
    // Current height  : 3
    // Current Status  : frozen
    // Expected height : 10
    // Expected Status : frozen
    // Result          : Success
    // Progress        : melted -> frozen
    // -------------------------------------------------------------------------
    genNormalBlockTransactions(7);
    assert(ledger.getBlockHeight() == 10);

    // -------------------------------------------------------------------------
    // Creates the payment transaction with frozen UTXO
    // Current height  : 10
    // Current Status  : frozen
    // Expected height : 11
    // Expected Status : melting
    // Result          : Success
    // Progress        : melted -> frozen -> melting
    // -------------------------------------------------------------------------
    genBlockTransactionsFreeze(1, TxType.Payment);
    assert(ledger.getBlockHeight() == 11);

    ulong melting_start = 11;
    ulong melting_block_count;

    // -------------------------------------------------------------------------
    // Creates the payment transaction with melting UTXO
    // Current height  : 11
    // Current Status  : melting
    // Expected height : 11
    // Expected Status : melting
    // Result          : Didn't change to melted not yet
    // Progress        : melted -> frozen -> melting
    // -------------------------------------------------------------------------
    genBlockTransactionsFreeze(1, TxType.Payment, false);
    assert(ledger.getBlockHeight() == 11);

    // -------------------------------------------------------------------------
    // Creates 2014 dummy payment blocks (Number of transactions Block.TxsInBlock * 2014)
    // Not related to previously melting UTXO
    // Current height  : 11
    // Current Status  : melting
    // Expected height : 11 + 2014
    // Expected Status : melting
    // Result          : Success
    // Progress        : melted -> frozen -> melting
    // -------------------------------------------------------------------------
    genNormalBlockTransactions(2014);
    assert(ledger.getBlockHeight() == 11 + 2014);

    melting_block_count = ledger.getBlockHeight() - melting_start + 1;
    assert(melting_block_count == 2015);

    // -------------------------------------------------------------------------
    // Creates the payment transaction with melting UTXO
    // Current height  : 11 + 2014
    // Current Status  : melting
    // Expected height : 11 + 2014
    // Expected Status : melting
    // Result          : Didn't change to melted not yet
    // Progress        : melted -> frozen -> melting
    // -------------------------------------------------------------------------
    genBlockTransactionsFreeze(1, TxType.Payment, false);
    assert(ledger.getBlockHeight() == 11 + 2014);

    // -------------------------------------------------------------------------
    // Creates 1 dummy payment block (Number of transactions Block.TxsInBlock)
    // Not related to previously melting UTXO
    // Current height  : 11 + 2014
    // Current Status  : melting
    // Expected height : 11 + 2015
    // Expected Status : melting
    // Result          : Success
    // Progress        : melted -> frozen -> melting
    // -------------------------------------------------------------------------
    genNormalBlockTransactions(1);
    assert(ledger.getBlockHeight() == 11 + 2015);

    melting_block_count = ledger.getBlockHeight() - melting_start + 1;
    assert(melting_block_count == 2016);

    // -------------------------------------------------------------------------
    // Creates the payment transaction with melting UTXO
    // Current height  : 11 + 2015
    // Current Status  : melting
    // Expected height : 11 + 2016
    // Expected Status : melted
    // Result          : Success, change to melted
    // Progress        : melted -> frozen -> melting -> melted
    // -------------------------------------------------------------------------
    genBlockTransactionsFreeze(1, TxType.Payment);
    assert(ledger.getBlockHeight() == 11 + 2016);
}
