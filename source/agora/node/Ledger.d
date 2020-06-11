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
import agora.common.Config;
import agora.common.crypto.Key;
import agora.common.Hash;
import agora.common.Set;
import agora.common.TransactionPool;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.ConsensusData;
import agora.consensus.data.Enrollment;
import agora.consensus.data.ConsensusParams;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXOSetValue;
import agora.consensus.UTXOSet;
import agora.consensus.EnrollmentManager;
import agora.consensus.Genesis;
import agora.consensus.validation;
import agora.node.BlockStorage;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

import std.algorithm;
import std.range;

mixin AddLogger!();

version (unittest)
{
    import agora.utils.Test;
}

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

    /// Enrollment manager
    private EnrollmentManager enroll_man;

    /// Node config
    private NodeConfig node_config;

    /// If not null call this delegate if the validator set changed after
    /// a block was externalized
    private void delegate () nothrow @safe onValidatorsChanged;

    /// Parameters for consensus-critical constants
    private immutable(ConsensusParams) params;

    /***************************************************************************

        Constructor

        Params:
            pool = the transaction pool
            utxo_set = the set of unspent outputs
            storage = the block storage
            enroll_man = the enrollmentManager
            node_config = the node config
            params = the consensus-critical constants
            onValidatorsChanged = optional delegate to call after the validator
                                  set changes when a block was externalized

    ***************************************************************************/

    public this (TransactionPool pool,
        UTXOSet utxo_set,
        IBlockStorage storage,
        EnrollmentManager enroll_man,
        NodeConfig node_config,
        immutable(ConsensusParams) params,
        void delegate () nothrow @safe onValidatorsChanged = null)
    {
        this.pool = pool;
        this.utxo_set = utxo_set;
        this.storage = storage;
        this.enroll_man = enroll_man;
        this.node_config = node_config;
        this.onValidatorsChanged = onValidatorsChanged;
        this.params = params;
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
                this.storage.readBlock(block, height);
                this.updateUTXOSet(block);
            }
        }

        // +1 because the genesis block counts as one
        const ulong block_count = this.last_block.header.height + 1;

        // we are only interested in the last 1008 blocks,
        // because that is the maximum length of an enrollment.
        const ulong min_height =
            block_count >= this.params.ValidatorCycle
            ? block_count - this.params.ValidatorCycle : 0;

        // restore validator set from the blockchain.
        // using block_count, as the range is inclusive
        foreach (block_idx; min_height .. block_count)
        {
            Block block;
            this.storage.readBlock(block, block_idx);
            this.enroll_man.restoreValidators(this.last_block.header.height,
                block, this.utxo_set.getUTXOFinder());
        }
    }

    /***************************************************************************

        Called when a consensus data set is externalized.

        This will create a new block and add it to the ledger.

        Params:
            data = the consensus data which was externalized

        Returns:
            true if the consensus data was accepted

    ***************************************************************************/

    public bool onExternalized (ConsensusData data)
        @trusted
    {
        auto block = makeNewBlock(this.last_block, data.tx_set.byKey(),
            data.enrolls);
        return this.acceptBlock(block);
    }

    /***************************************************************************

        Add a block to the ledger.

        If the block fails verification, it is not added to the ledger.

        Params:
            block = the block to add

        Returns:
            true if the block was accepted

    ***************************************************************************/

    public bool acceptBlock (const ref Block block) @safe
    {
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
        const expect_height = this.getBlockHeight() + 1;
        auto reason = tx.isInvalidReason(this.utxo_set.getUTXOFinder(),
            expect_height);

        if (reason !is null || !this.pool.add(tx))
        {
            log.info("Rejected tx. Reason: {}. Tx: {}",
                reason !is null ? reason : "double-spend", tx);
            return false;
        }

        return true;
    }

    /***************************************************************************

        Add a validated block to the Ledger,
        and add all of its outputs to the UTXO set.
        If there are any enrollments in the block,
        add enrollments to the validator set.

        Params:
            block = the block to add

    ***************************************************************************/

    private void addValidatedBlock (const ref Block block) @safe
    {
        this.updateUTXOSet(block);
        if (!this.storage.saveBlock(block))
            assert(0);

        auto old_count = this.enroll_man.validatorCount();
        this.enroll_man.clearExpiredValidators(block.header.height);

        // there was a change in the active validator set
        bool validators_changed = block.header.enrollments.length > 0
            || this.enroll_man.validatorCount() != old_count;

        foreach (idx, ref enrollment; block.header.enrollments)
        {
            if (auto r = this.enroll_man.addValidator(enrollment,
                block.header.height, this.utxo_set.getUTXOFinder()))
            {
                log.fatal("Error while adding a new validator: {}", r);
                log.fatal("Enrollment #{}: {}", idx, enrollment);
                log.fatal("Validated block: {}", block);
                assert(0);
            }
        }

        // read back and cache the last block
        if (!this.storage.readLastBlock(this.last_block))
            assert(0);

        if (this.onValidatorsChanged !is null && validators_changed)
            this.onValidatorsChanged();
    }

    /***************************************************************************

        Update the UTXO set based on the block's transactions

        Params:
            block = the block to update the UTXO set with

    ***************************************************************************/

    private void updateUTXOSet (const ref Block block) @safe
    {
        const ulong height = block.header.height;
        // add the new UTXOs
        block.txs.each!(tx => this.utxo_set.updateUTXOCache(tx, height));

        // remove the TXs from the Pool
        block.txs.each!(tx => this.pool.remove(tx));
    }

    /***************************************************************************

        Try to collect a set of transactions to nominate.

        Params:
            txs = will contain the transaction set to nominate,
                  or empty if not enough txs were found

    ***************************************************************************/

    public void prepareNominatingSet (ref ConsensusData data) @safe
    {
        assert(data.tx_set.length == 0);

        if (this.pool.length < Block.TxsInBlock)
            return;

        const ulong next_height = this.getBlockHeight() + 1;
        auto utxo_finder = this.utxo_set.getUTXOFinder();

        this.enroll_man.pool.getEnrollments(data.enrolls);
        foreach (hash, tx; this.pool)
        {
            if (auto reason = tx.isInvalidReason(utxo_finder, next_height))
                log.trace("Rejected invalid ('{}') tx: {}", reason, tx);
            else
                data.tx_set.put(tx);

            if (data.tx_set.length >= Block.TxsInBlock)
                return;
        }

        // not enough txs were found
        () @trusted {
            data = ConsensusData.init;
        }();
    }

    /***************************************************************************

        Check whether the consensus data is valid.

        Params:
            data = consensus data

        Returns:
            the error message if validation failed, otherwise null

    ***************************************************************************/

    public string validateConsensusData (ConsensusData data) @trusted
    {
        const ulong expect_height = this.getBlockHeight() + 1;
        auto utxo_finder = this.utxo_set.getUTXOFinder();

        foreach (tx; data.tx_set)
        {
            if (auto fail_reason = tx.isInvalidReason(utxo_finder, expect_height))
                return fail_reason;
        }

        foreach (enroll; data.enrolls)
        {
            if (auto fail_reason = enroll.isInvalidReason(utxo_finder))
            {
                return fail_reason;
            }
        }

        return null;
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
        return block.isInvalidReason(this.last_block.header.height,
            this.last_block.header.hashFull, this.utxo_set.getUTXOFinder());
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
            if (!this.storage.tryReadBlock(block, height))
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

    public Hash[] getMerklePath (ulong block_height, Hash hash) @safe nothrow
    {
        if (this.getBlockHeight() < block_height)
            return null;

        Block block;
        if (!this.storage.tryReadBlock(block, block_height))
            return null;

        size_t index = block.findHashIndex(hash);
        if (index >= block.txs.length)
            return null;
        return block.getMerklePath(index);
    }

    /***************************************************************************

        Check if a transaction hash exists in the transaction pool.

        Params:
            tx = the transaction hash

        Returns:
            true if the transaction pool has the transaction hash.

    ***************************************************************************/

    public bool hasTransactionHash (const ref Hash tx) @safe
    {
        return this.pool.hasTransactionHash(tx);
    }
}

/// simulate block creation as if a nomination and externalize round completed
version (unittest)
{
    private void forceCreateBlock (Ledger ledger)
    {
        ConsensusData data;
        ledger.prepareNominatingSet(data);
        assert(data.tx_set.length > 0);
        assert(ledger.onExternalized(data));
    }
}

///
unittest
{
    import agora.common.crypto.Key;
    import agora.common.Types;
    import agora.common.Hash;

    auto gen_key_pair = getGenesisKeyPair();

    auto storage = new MemBlockStorage();
    auto pool = new TransactionPool(":memory:");
    auto utxo_set = new UTXOSet(":memory:");
    auto config = new Config();
    auto params = new immutable(ConsensusParams)();
    auto enroll_man = new EnrollmentManager(":memory:", gen_key_pair, params);
    config.node.is_validator = true;
    scope ledger = new Ledger(pool, utxo_set, storage, enroll_man, config.node,
        params);
    assert(ledger.getBlockHeight() == 0);

    auto blocks = ledger.getBlocksFrom(0).take(10);
    assert(blocks[$ - 1] == GenesisBlock);

    Transaction[] last_txs;

    // generate enough transactions to form a block
    void genBlockTransactions (size_t count)
    {
        auto txes = makeChainedTransactions(gen_key_pair, last_txs, count);

        foreach (idx, tx; txes)
        {
            assert(ledger.acceptTransaction(tx));
            if ((idx + 1) % Block.TxsInBlock == 0)
                ledger.forceCreateBlock();
        }

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

// Reject a transaction whose output value is 0
unittest
{
    import agora.common.crypto.Key;

    auto gen_key_pair = getGenesisKeyPair();

    auto storage = new MemBlockStorage();
    auto pool = new TransactionPool(":memory:");
    auto utxo_set = new UTXOSet(":memory:");
    auto config = new Config();
    auto params = new immutable(ConsensusParams)();
    auto enroll_man = new EnrollmentManager(":memory:", gen_key_pair, params);
    config.node.is_validator = true;
    scope ledger = new Ledger(pool, utxo_set, storage, enroll_man, config.node,
        params);

    // Valid case
    auto txs = makeChainedTransactions(gen_key_pair, null, 1);
    foreach (ref tx; txs)
    {
        foreach (ref output; tx.outputs)
            output.value = Amount(1_000_000L);
        foreach (ref input; tx.inputs)
            input.signature = gen_key_pair.secret.sign(hashFull(tx)[]);
    }

    txs.each!(tx => assert(ledger.acceptTransaction(tx)));
    ledger.forceCreateBlock();
    auto blocks = ledger.getBlocksFrom(0).take(10);
    assert(blocks.length == 2);

    // Invalid case
    txs = makeChainedTransactions(gen_key_pair, txs, 1);
    foreach (ref tx; txs)
    {
        foreach (ref output; tx.outputs)
            output.value = Amount(0);
        foreach (ref input; tx.inputs)
            input.signature = gen_key_pair.secret.sign(hashFull(tx)[]);
    }

    txs.each!(tx => assert(!ledger.acceptTransaction(tx)));
    blocks = ledger.getBlocksFrom(0).take(10);
    assert(blocks.length == 2);
}

/// basic block verification
unittest
{
    import agora.common.crypto.Key;
    import agora.common.Types;
    import agora.common.Hash;

    auto gen_key_pair = getGenesisKeyPair();

    auto storage = new MemBlockStorage();
    auto pool = new TransactionPool(":memory:");
    auto utxo_set = new UTXOSet(":memory:");
    auto config = new Config();
    auto params = new immutable(ConsensusParams)();
    auto enroll_man = new EnrollmentManager(":memory:", gen_key_pair, params);
    config.node.is_validator = true;
    scope ledger = new Ledger(pool, utxo_set, storage, enroll_man, config.node,
        params);

    Block invalid_block;  // default-initialized should be invalid
    assert(!ledger.acceptBlock(invalid_block));

    auto txs = makeChainedTransactions(gen_key_pair, null, 1);

    auto valid_block = makeNewBlock(GenesisBlock, txs);
    assert(ledger.acceptBlock(valid_block));
}

/// Merkle Proof
unittest
{
    import agora.common.crypto.Key;

    auto gen_key_pair = getGenesisKeyPair();

    auto storage = new MemBlockStorage();
    auto pool = new TransactionPool(":memory:");
    auto utxo_set = new UTXOSet(":memory:");
    auto config = new Config();
    auto params = new immutable(ConsensusParams)();
    auto enroll_man = new EnrollmentManager(":memory:", gen_key_pair, params);
    config.node.is_validator = true;
    scope ledger = new Ledger(pool, utxo_set, storage, enroll_man, config.node,
        params);

    auto txs = makeChainedTransactions(gen_key_pair, null, 1);
    txs.each!(tx => assert(ledger.acceptTransaction(tx)));
    ledger.forceCreateBlock();

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

    auto gen_key = getGenesisKeyPair();
    auto storage = new MemBlockStorage();
    storage.load();

    // First block
    auto txs = makeChainedTransactions(gen_key, null, 1);
    auto block = makeNewBlock(GenesisBlock, txs);
    assert(storage.saveBlock(block));

    auto pool = new TransactionPool(":memory:");
    auto utxo_set = new UTXOSet(":memory:");
    auto config = new Config();
    auto params = new immutable(ConsensusParams)();
    auto enroll_man = new EnrollmentManager(":memory:", gen_key, params);
    config.node.is_validator = true;
    scope ledger = new Ledger(pool, utxo_set, storage, enroll_man, config.node,
        params);

    assert(utxo_set.length == 8);
    auto finder = utxo_set.getUTXOFinder();
    auto new_txs = makeChainedTransactions(gen_key, txs, 1);

    assert(new_txs.length > 0);
    UTXOSetValue _val;
    new_txs.each!(tx => assert(finder(tx.inputs[0].previous, tx.inputs[0].index,
        _val)));

    auto findUTXO = utxo_set.getUTXOFinder();
    Transaction find_tx = new_txs[0];
    Hash utxo_hash = UTXOSetValue.getHash(find_tx.inputs[0].previous,
        find_tx.inputs[0].index);
    UTXOSetValue value;
    assert(findUTXO(utxo_hash, size_t.max, value));
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
    const Amount AmountPerTx = Amount.MinFreezeAmount;

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

    auto gen_key_pair = getGenesisKeyPair();

    auto storage = new MemBlockStorage();
    auto pool = new TransactionPool(":memory:");
    auto utxo_set = new UTXOSet(":memory:");
    auto config = new Config();
    auto params = new immutable(ConsensusParams)();
    auto enroll_man = new EnrollmentManager(":memory:", gen_key_pair, params);
    config.node.is_validator = true;
    scope ledger = new Ledger(pool, utxo_set, storage, enroll_man, config.node,
        params);

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
            ledger.forceCreateBlock();

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

// Create freeze transactions and create enrollments to
// test if it is stored in a block.
unittest
{
    import agora.common.crypto.ECC;
    import agora.common.crypto.Key;
    import agora.common.crypto.Schnorr;
    import agora.common.Hash;
    import agora.common.Types;

    auto gen_key = getGenesisKeyPair();

    KeyPair[] splited_keys = getRandomKeyPairs();
    KeyPair[] in_key_pairs_normal;
    KeyPair[] out_key_pairs_normal;
    Transaction[] last_txs_normal;
    KeyPair[] in_key_pairs_freeze;
    KeyPair[] out_key_pairs_freeze;
    Transaction[] last_txs_freeze;

    auto validator_cycle = 10;
    auto storage = new MemBlockStorage();
    auto pool = new TransactionPool(":memory:");
    auto utxo_set = new UTXOSet(":memory:");
    auto config = new Config();
    auto params = new immutable(ConsensusParams)(validator_cycle);
    auto enroll_man = new EnrollmentManager(":memory:", gen_key, params);
    config.node.is_validator = true;
    scope ledger = new Ledger(pool, utxo_set, storage, enroll_man, config.node,
        params);

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
        ledger.forceCreateBlock();
    }

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
            ledger.forceCreateBlock();

            if (is_valid)
            {
                // keep track of last tx's to chain them to
                last_txs_normal = txes[$ - Block.TxsInBlock .. $];

                in_key_pairs_normal = out_key_pairs_normal;
                out_key_pairs_normal = getRandomKeyPairs();
            }
        }
    }

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
            ledger.forceCreateBlock();

            if (is_valid)
            {
                // keep track of last tx's to chain them to
                last_txs_freeze = txes[$ - Block.TxsInBlock .. $];

                in_key_pairs_freeze = out_key_pairs_freeze;
                out_key_pairs_freeze = getRandomKeyPairs();
            }
        }
    }

    splitGenesis();
    assert(ledger.getBlockHeight() == 1);

    genNormalBlockTransactions(1);
    assert(ledger.getBlockHeight() == 2);

    genBlockTransactionsFreeze(1, TxType.Freeze);
    assert(ledger.getBlockHeight() == 3);

    auto blocks = ledger.getBlocksFrom(0).take(10);

    // make enrollments
    KeyPair[] enroll_key_pair;
    foreach (txid, tx; blocks[3].txs)
        foreach (key_pair; in_key_pairs_freeze)
            if (tx.outputs[0].address == key_pair.address)
                enroll_key_pair ~= key_pair;

    auto utxo_hash_1 = UTXOSetValue.getHash(hashFull(blocks[3].txs[0]),0);
    auto utxo_hash_2 = UTXOSetValue.getHash(hashFull(blocks[3].txs[1]),0);
    auto utxo_hash_3 = UTXOSetValue.getHash(hashFull(blocks[3].txs[2]),0);

    Pair signature_noise = Pair.random;
    Pair node_key_pair_1;
    node_key_pair_1.v = secretKeyToCurveScalar(enroll_key_pair[0].secret);
    node_key_pair_1.V = node_key_pair_1.v.toPoint();

    Pair node_key_pair_2;
    node_key_pair_2.v = secretKeyToCurveScalar(enroll_key_pair[1].secret);
    node_key_pair_2.V = node_key_pair_2.v.toPoint();

    Pair node_key_pair_3;
    node_key_pair_3.v = secretKeyToCurveScalar(enroll_key_pair[2].secret);
    node_key_pair_3.V = node_key_pair_3.v.toPoint();

    Enrollment enroll_1;
    enroll_1.utxo_key = utxo_hash_1;
    enroll_1.random_seed = hashFull(Scalar.random());
    enroll_1.cycle_length = validator_cycle;
    enroll_1.enroll_sig = sign(node_key_pair_1, signature_noise, enroll_1);

    Enrollment enroll_2;
    enroll_2.utxo_key = utxo_hash_2;
    enroll_2.random_seed = hashFull(Scalar.random());
    enroll_2.cycle_length = validator_cycle;
    enroll_2.enroll_sig = sign(node_key_pair_2, signature_noise, enroll_2);

    Enrollment enroll_3;
    enroll_3.utxo_key = utxo_hash_3;
    enroll_3.random_seed = hashFull(Scalar.random());
    enroll_3.cycle_length = validator_cycle;
    enroll_3.enroll_sig = sign(node_key_pair_3, signature_noise, enroll_3);

    Enrollment[] enrollments ;
    enrollments ~= enroll_1;
    enrollments ~= enroll_2;
    enrollments ~= enroll_3;

    auto findUTXO = utxo_set.getUTXOFinder();
    assert(enroll_man.pool.add(enroll_1, findUTXO));
    assert(enroll_man.pool.add(enroll_2, findUTXO));
    assert(enroll_man.pool.add(enroll_3, findUTXO));
    Enrollment stored_enroll;
    enroll_man.pool.getEnrollment(utxo_hash_1, stored_enroll);
    assert(stored_enroll == enroll_1);
    enroll_man.pool.getEnrollment(utxo_hash_2, stored_enroll);
    assert(stored_enroll == enroll_2);
    enroll_man.pool.getEnrollment(utxo_hash_3, stored_enroll);
    assert(stored_enroll == enroll_3);
    genNormalBlockTransactions(1);
    assert(ledger.getBlockHeight() == 4);

    // Check if there are any unregistered enrollments
    Enrollment[] unreg_enrollments;
    assert(enroll_man.pool.getEnrollments(unreg_enrollments) is null);
    auto block_4 = ledger.getBlocksFrom(4);
    enrollments.sort!("a.utxo_key < b.utxo_key");
    assert(block_4[0].header.enrollments == enrollments);

    genNormalBlockTransactions(validator_cycle);
    Hash[] keys;
    assert(enroll_man.getEnrolledUTXOs(keys));
    assert(keys.length == 0);
    assert(ledger.getBlockHeight() == validator_cycle + 4);
}

version (unittest)
private Transaction[] splitGenesisTransaction (
    KeyPair[] in_key,
    KeyPair[] out_key, Amount amount = Amount.MinFreezeAmount)
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

    auto gen_key_pair = getGenesisKeyPair();

    auto storage = new MemBlockStorage();
    auto pool = new TransactionPool(":memory:");
    auto utxo_set = new UTXOSet(":memory:");
    auto config = new Config();
    auto params = new immutable(ConsensusParams)();
    auto enroll_man = new EnrollmentManager(":memory:", gen_key_pair, params);
    config.node.is_validator = true;
    scope ledger = new Ledger(pool, utxo_set, storage, enroll_man, config.node,
        params);

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
        ledger.forceCreateBlock();
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
            ledger.forceCreateBlock();

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
                ledger.forceCreateBlock();

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

/// test enrollments in the genesis block
unittest
{
    import agora.common.BitField;
    import agora.common.Serializer;
    import std.exception;

    // generate genesis with a freeze & payment tx, and 'count' number of
    // extra blocks
    const(Block)[] genBlocksToIndex ( KeyPair key_pair,
        EnrollmentManager enroll_man, size_t count)
    {
        // 1 payment and 1 freeze tx (must be a power of 2 due to #797)
        Transaction[] gen_txs;
        // need mutable
        gen_txs ~= GenesisTransaction().serializeFull.deserializeFull!Transaction;

        Transaction freeze_tx =
        {
            type : TxType.Freeze,
            outputs : [Output(Amount.MinFreezeAmount, key_pair.address)]
        };

        gen_txs ~= freeze_tx;
        Hash txhash = hashFull(freeze_tx);
        Hash utxo = UTXOSetValue.getHash(txhash, 0);

        Enrollment[] enrolls;
        Enrollment enroll;
        const StartHeight = 0;  // not important
        assert(enroll_man.createEnrollment(utxo, StartHeight, enroll));
        enrolls ~= enroll;

        gen_txs.sort;
        Hash[] merkle_tree;
        auto merkle_root = Block.buildMerkleTree(gen_txs, merkle_tree);

        auto genesis = immutable(Block)(
            immutable(BlockHeader)(
                Hash.init,   // prev
                0,           // height
                merkle_root,
                BitField!uint.init,
                Signature.init,
                enrolls.assumeUnique,
            ),
            gen_txs.assumeUnique,
            merkle_tree.assumeUnique
        );

        const(Block)[] blocks = [genesis];

        const(Transaction)[] prev_txs;
        foreach (_; 0 .. count)
        {
            auto txs = makeChainedTransactions(getGenesisKeyPair(),
                prev_txs, 1);

            const NoEnrollments = null;
            blocks ~= makeNewBlock(blocks[$ - 1], txs, NoEnrollments);
            prev_txs = txs;
        }

        return blocks.assumeUnique;
    }

    // only genesis loaded: validator is active
    {
        auto key_pair = KeyPair.random();
        auto params = new immutable(ConsensusParams)();
        scope enroll_man = new EnrollmentManager(":memory:", key_pair, params);
        const blocks = genBlocksToIndex(key_pair, enroll_man, 0);
        scope storage = new MemBlockStorage(blocks);
        scope pool = new TransactionPool(":memory:");
        scope utxo_set = new UTXOSet(":memory:");
        scope config = new Config();
        scope ledger = new Ledger(pool, utxo_set, storage, enroll_man,
            config.node, params);
        Hash[] keys;
        assert(enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 1);
    }

    // block 1007 loaded: validator is still active
    {
        auto validator_cycle = 10;
        auto key_pair = KeyPair.random();
        auto params = new immutable(ConsensusParams)(validator_cycle);
        scope enroll_man = new EnrollmentManager(":memory:", key_pair, params);
        const blocks = genBlocksToIndex(key_pair, enroll_man,
            validator_cycle - 1);
        scope storage = new MemBlockStorage(blocks);
        scope pool = new TransactionPool(":memory:");
        scope utxo_set = new UTXOSet(":memory:");
        scope config = new Config();
        scope ledger = new Ledger(pool, utxo_set, storage, enroll_man,
            config.node, params);
        Hash[] keys;
        assert(enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 1);
    }

    // block 1008 loaded: validator is inactive
    {
        auto validator_cycle = 20;
        auto key_pair = KeyPair.random();
        auto params = new immutable(ConsensusParams)(validator_cycle);
        scope enroll_man = new EnrollmentManager(":memory:", key_pair, params);
        const blocks = genBlocksToIndex(key_pair, enroll_man, validator_cycle);
        scope storage = new MemBlockStorage(blocks);
        scope pool = new TransactionPool(":memory:");
        scope utxo_set = new UTXOSet(":memory:");
        scope config = new Config();
        scope ledger = new Ledger(pool, utxo_set, storage, enroll_man,
            config.node, params);
        Hash[] keys;
        assert(enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 0);
    }
}
