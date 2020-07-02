/*******************************************************************************

    The `Ledger` class binds together other components to provide a consistent
    view of the state of the node.

    The Ledger acts as a bridge between other components, e.g. the `UTXOSet`,
    `EnrollmentManager`, `IBlockStorage`, etc...
    While the `Node` is the main object in Agora, the `Ledger` is the second
    most important class, handling all business logic, relying on the the `Node`
    for anything related to network communicatiion.

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.Ledger;

import agora.common.Amount;
import agora.common.BitField;
import agora.common.Config;
import agora.common.crypto.Key;
import agora.common.Hash;
import agora.common.ManagedDatabase;
import agora.common.Serializer;
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
import std.exception;
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
            node_config = the node config
            params = the consensus-critical constants
            utxo_set = the set of unspent outputs
            storage = the block storage
            enroll_man = the enrollmentManager
            pool = the transaction pool
            onValidatorsChanged = optional delegate to call after the validator
                                  set changes when a block was externalized

    ***************************************************************************/

    public this (
        NodeConfig node_config, immutable(ConsensusParams) params,
        UTXOSet utxo_set, IBlockStorage storage,
        EnrollmentManager enroll_man, TransactionPool pool,
        void delegate () nothrow @safe onValidatorsChanged = null)
    {
        this.node_config = node_config;
        this.params = params;
        this.utxo_set = utxo_set;
        this.storage = storage;
        this.enroll_man = enroll_man;
        this.pool = pool;
        this.onValidatorsChanged = onValidatorsChanged;
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
                this.storage.readBlock(block, Height(height));
                this.updateUTXOSet(block);
            }
        }

        // +1 because the genesis block counts as one
        const ulong block_count = this.last_block.header.height + 1;

        // we are only interested in the last 1008 blocks,
        // because that is the maximum length of an enrollment.
        const Height min_height =
            block_count >= this.params.ValidatorCycle
            ? Height(block_count - this.params.ValidatorCycle) : Height(0);

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
        auto block = makeNewBlock(this.last_block, data.tx_set, data.enrolls);
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
        const Height expected_height = Height(this.getBlockHeight() + 1);
        auto reason = tx.isInvalidReason(this.utxo_set.getUTXOFinder(),
            expected_height);

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
        if (!this.storage.saveBlock(block))
            assert(0);

        ManagedDatabase.beginBatch();
        scope (failure) ManagedDatabase.rollback();

        auto old_count = this.enroll_man.validatorCount();
        this.updateUTXOSet(block);
        this.updateValidatorSet(block);
        ManagedDatabase.commitBatch();

        // there was a change in the active validator set
        bool validators_changed = block.header.enrollments.length > 0
            || this.enroll_man.validatorCount() != old_count;

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

    protected void updateUTXOSet (const ref Block block) @safe
    {
        const height = block.header.height;
        // add the new UTXOs
        block.txs.each!(tx => this.utxo_set.updateUTXOCache(tx, height));

        // remove the TXs from the Pool
        block.txs.each!(tx => this.pool.remove(tx));
    }

    /***************************************************************************

        Update the active validator set

        Params:
            block = the block to update the Validator set with

    ***************************************************************************/

    protected void updateValidatorSet (const ref Block block) @safe
    {
        this.enroll_man.clearExpiredValidators(block.header.height);

        foreach (idx, ref enrollment; block.header.enrollments)
        {
            this.enroll_man.pool.remove(enrollment.utxo_key);

            if (auto r = this.enroll_man.addValidator(enrollment,
                block.header.height, this.utxo_set.getUTXOFinder()))
            {
                log.fatal("Error while adding a new validator: {}", r);
                log.fatal("Enrollment #{}: {}", idx, enrollment);
                log.fatal("Validated block: {}", block);
                assert(0);
            }
        }
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

        const next_height = Height(this.getBlockHeight() + 1);
        auto utxo_finder = this.utxo_set.getUTXOFinder();

        this.enroll_man.getEnrollments(data.enrolls,
            Height(this.getBlockHeight()));
        foreach (hash, tx; this.pool)
        {
            if (auto reason = tx.isInvalidReason(utxo_finder, next_height))
                log.trace("Rejected invalid ('{}') tx: {}", reason, tx);
            else
                data.tx_set ~= tx;

            if (data.tx_set.length >= Block.TxsInBlock)
            {
                data.tx_set.sort();
                return;
            }
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
        const expect_height = Height(this.getBlockHeight() + 1);
        auto utxo_finder = this.utxo_set.getUTXOFinder();

        foreach (tx; data.tx_set)
        {
            if (auto fail_reason = tx.isInvalidReason(utxo_finder, expect_height))
                return fail_reason;
        }

        size_t active_enrollments = enroll_man.getValidatorCount(expect_height);

        if (data.enrolls.length + active_enrollments < Enrollment.MinValidatorCount)
            return "Enrollment: Insufficient number of active validators";

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
        size_t active_enrollments = enroll_man.getValidatorCount(
                block.header.height);

        return block.isInvalidReason(this.last_block.header.height,
            this.last_block.header.hashFull,
            this.utxo_set.getUTXOFinder(),
            active_enrollments);
    }

    /***************************************************************************

        Returns:
            latest block height

    ***************************************************************************/

    public Height getBlockHeight () @safe nothrow
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

    public auto getBlocksFrom (Height start_height) @safe nothrow
    {
        start_height = min(start_height, this.getBlockHeight() + 1);

        const(Block) readBlock (Height height)
        {
            Block block;
            if (!this.storage.tryReadBlock(block, height))
                assert(0);
            return block;
        }

        return iota(start_height, this.getBlockHeight() + 1)
            .map!(idx => readBlock(Height(idx)));
    }

    /***************************************************************************

        Get the array of hashs the merkle path.

        Params:
            block_height = block height with transaction hash
            hash         = transaction hash

        Returns:
            the array of hashs the merkle path

    ***************************************************************************/

    public Hash[] getMerklePath (Height block_height, Hash hash) @safe nothrow
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

version (unittest)
{
    /// simulate block creation as if a nomination and externalize round completed
    private void forceCreateBlock (Ledger ledger)
    {
        ConsensusData data;
        ledger.prepareNominatingSet(data);
        assert(data.tx_set.length > 0);
        assert(ledger.onExternalized(data));
    }

    /// A `Ledger` with sensible defaults for `unittest` blocks
    private final class TestLedger : Ledger
    {
        public this (
            NodeConfig config,
            const(Block)[] blocks = null,
            immutable(ConsensusParams) params = new immutable(ConsensusParams)())
        {
            super(config, params, new UTXOSet(":memory:"),
                new MemBlockStorage(blocks),
                new EnrollmentManager(":memory:", config.key_pair, params),
                new TransactionPool(":memory:"));
        }
    }
}

///
unittest
{
    NodeConfig config = {
        is_validator: true,
        key_pair:     WK.Keys.NODE2,
    };
    scope ledger = new TestLedger(config);
    assert(ledger.getBlockHeight() == 0);

    auto blocks = ledger.getBlocksFrom(Height(0)).take(10);
    assert(blocks[$ - 1] == GenesisBlock);

    // generate enough transactions to form a block
    Transaction[] last_txs;
    void genBlockTransactions (size_t count)
    {
        assert(count > 0);

        // Special case for genesis
        if (!last_txs.length)
        {
            last_txs = genesisSpendable().take(Block.TxsInBlock).enumerate()
                .map!(en => en.value.refund(WK.Keys.A.address).sign())
                .array();
            last_txs.each!(tx => ledger.acceptTransaction(tx));
            ledger.forceCreateBlock();
            count--;
        }

        foreach (_; 0 .. count)
        {
            last_txs = last_txs.map!(tx => TxBuilder(tx).sign()).array();
            last_txs.each!(tx => assert(ledger.acceptTransaction(tx)));
            ledger.forceCreateBlock();
        }
    }

    genBlockTransactions(2);
    blocks = ledger.getBlocksFrom(Height(0)).take(10);
    assert(blocks[0] == GenesisBlock);
    assert(blocks.length == 3);  // two blocks + genesis block

    /// now generate 98 more blocks to make it 100 + genesis block (101 total)
    genBlockTransactions(98);
    assert(ledger.getBlockHeight() == 100);

    blocks = ledger.getBlocksFrom(Height(0)).takeExactly(10);
    assert(blocks[0] == GenesisBlock);
    assert(blocks.length == 10);

    /// lower limit
    blocks = ledger.getBlocksFrom(Height(0)).takeExactly(5);
    assert(blocks[0] == GenesisBlock);
    assert(blocks.length == 5);

    /// different indices
    blocks = ledger.getBlocksFrom(Height(1)).takeExactly(10);
    assert(blocks[0].header.height == 1);
    assert(blocks.length == 10);

    blocks = ledger.getBlocksFrom(Height(50)).takeExactly(10);
    assert(blocks[0].header.height == 50);
    assert(blocks.length == 10);

    blocks = ledger.getBlocksFrom(Height(95)).take(10);  // only 6 left from here (block 100 included)
    assert(blocks.front.header.height == 95);
    assert(blocks.walkLength() == 6);

    blocks = ledger.getBlocksFrom(Height(99)).take(10);  // only 2 left from here (ditto)
    assert(blocks.front.header.height == 99);
    assert(blocks.walkLength() == 2);

    blocks = ledger.getBlocksFrom(Height(100)).take(10);  // only 1 block available
    assert(blocks.front.header.height == 100);
    assert(blocks.walkLength() == 1);

    // over the limit => return up to the highest block
    assert(ledger.getBlocksFrom(Height(0)).take(1000).walkLength() == 101);

    // higher index than available => return nothing
    assert(ledger.getBlocksFrom(Height(1000)).take(10).walkLength() == 0);
}

// Reject a transaction whose output value is 0
unittest
{
    NodeConfig config = {
        is_validator: true,
        key_pair:     WK.Keys.Genesis,
    };
    scope ledger = new TestLedger(config);

    // Valid case
    auto txs = makeChainedTransactions(config.key_pair, null, 1);
    txs.each!(tx => assert(ledger.acceptTransaction(tx)));
    ledger.forceCreateBlock();
    auto blocks = ledger.getBlocksFrom(Height(0)).take(10);
    assert(blocks.length == 2);

    // Invalid case
    txs = makeChainedTransactions(config.key_pair, txs, 1);
    foreach (ref tx; txs)
    {
        foreach (ref output; tx.outputs)
            output.value = Amount(0);
        foreach (ref input; tx.inputs)
            input.signature = config.key_pair.secret.sign(hashFull(tx)[]);
    }

    txs.each!(tx => assert(!ledger.acceptTransaction(tx)));
    blocks = ledger.getBlocksFrom(Height(0)).take(10);
    assert(blocks.length == 2);
}

/// basic block verification
unittest
{
    NodeConfig config = {
        is_validator: true,
        key_pair:     WK.Keys.NODE2,
    };
    scope ledger = new TestLedger(config);

    Block invalid_block;  // default-initialized should be invalid
    assert(!ledger.acceptBlock(invalid_block));

    auto txs = makeChainedTransactions(WK.Keys.Genesis, null, 1);
    auto valid_block = makeNewBlock(GenesisBlock, txs);
    assert(ledger.acceptBlock(valid_block));
}

/// Merkle Proof
unittest
{
    NodeConfig config = {
        is_validator: true,
        key_pair:     WK.Keys.NODE2,
    };
    scope ledger = new TestLedger(config);

    auto txs = makeChainedTransactions(WK.Keys.Genesis, null, 1);
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
    merkle_path = ledger.getMerklePath(Height(1), hc);
    assert(merkle_path.length == 3);
    assert(merkle_path[0] == hd);
    assert(merkle_path[1] == hab);
    assert(merkle_path[2] == hefgh);
    assert(habcdefgh == Block.checkMerklePath(hc, merkle_path, 2));
    assert(habcdefgh != Block.checkMerklePath(hd, merkle_path, 2));

    merkle_path = ledger.getMerklePath(Height(1), he);
    assert(merkle_path.length == 3);
    assert(merkle_path[0] == hf);
    assert(merkle_path[1] == hgh);
    assert(merkle_path[2] == habcd);
    assert(habcdefgh == Block.checkMerklePath(he, merkle_path, 4));
    assert(habcdefgh != Block.checkMerklePath(hf, merkle_path, 4));

    merkle_path = ledger.getMerklePath(Height(1), Hash.init);
    assert(merkle_path.length == 0);
}

/// Situation: Ledger is constructed with blocks present in storage
/// Expectation: The UTXOSet is populated with all up-to-date UTXOs
unittest
{
    // Cannot use literals: https://issues.dlang.org/show_bug.cgi?id=20938
    const(Block)[] blocks = [ GenesisBlock ];
    auto txs = makeChainedTransactions(WK.Keys.Genesis, null, 1);
    // Make a block to put in storage
    // TODO: Make this more than one block (e.g. 5)
    //       Currently due to the design of `makeChainedTransactions`,
    //       we can't do that.
    blocks ~= makeNewBlock(GenesisBlock, txs);

    // And provide it to the ledger
    NodeConfig config = {
        is_validator: true,
        key_pair:     WK.Keys.NODE2,
    };
    scope ledger = new TestLedger(config, blocks);

    assert(ledger.utxo_set.length
           == /* Genesis, Frozen */ 6 + 8 /* Block #1 Payments*/);

    // Ensure that all previously-generated outputs are in the UTXO set
    {
        auto findUTXO = ledger.utxo_set.getUTXOFinder();
        UTXOSetValue utxo;
        assert(
            txs.all!(
                tx => iota(tx.outputs.length).all!(
                    (idx) {
                        return findUTXO(tx.hashFull(), idx, utxo) &&
                            utxo.output == tx.outputs[idx];
                    }
                )
            )
        );
    }
}

version (unittest)
private Transaction[] makeTransactionForFreezing (
    const(KeyPair)[] in_key_pair,
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
    NodeConfig config = {
        is_validator: true,
        key_pair:     WK.Keys.NODE2,
    };
    scope ledger = new TestLedger(config);

    const(KeyPair)[] in_key_pairs =
        iota(Block.TxsInBlock).map!(_ => WK.Keys.Genesis).array();
    KeyPair[] out_key_pairs;
    Transaction[] last_txs;

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
    auto blocks = ledger.getBlocksFrom(Height(0)).take(10).array;
    assert(blocks.length == 2);
    assert(blocks[1].header.height == 1);

    genBlockTransactions(1, TxType.Freeze);
    assert(ledger.getBlockHeight() == 2);
    blocks = ledger.getBlocksFrom(Height(0)).take(10).array;
    assert(blocks.length == 3);
    assert(blocks[2].header.height == 2);
}

// Create freeze transactions and create enrollments to
// test if it is stored in a block.
unittest
{
    import agora.common.crypto.ECC;
    import agora.common.crypto.Schnorr;

    auto validator_cycle = 10;
    auto params = new immutable(ConsensusParams)(validator_cycle);
    NodeConfig config = {
        is_validator: true,
        key_pair:     WK.Keys.NODE2,
    };
    scope ledger = new TestLedger(config);

    KeyPair[] splited_keys = getRandomKeyPairs();
    KeyPair[] in_key_pairs_normal;
    KeyPair[] out_key_pairs_normal;
    Transaction[] last_txs_normal;
    KeyPair[] in_key_pairs_freeze;
    KeyPair[] out_key_pairs_freeze;
    Transaction[] last_txs_freeze;

    Transaction[] splited_txex;
    // Divide 8 'Outputs' that are included in Genesis Block by 40,000
    // It generates eight addresses and eight transactions,
    // and one transaction has eight Outputs with a value of 40,000 values.
    void splitGenesis ()
    {
        splited_txex = splitGenesisTransaction(splited_keys);
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

    auto blocks = ledger.getBlocksFrom(Height(0)).take(10);

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

    auto findUTXO = ledger.utxo_set.getUTXOFinder();
    assert(ledger.enroll_man.pool.add(enroll_1, findUTXO));
    assert(ledger.enroll_man.pool.add(enroll_2, findUTXO));
    assert(ledger.enroll_man.pool.add(enroll_3, findUTXO));
    Enrollment stored_enroll;
    ledger.enroll_man.pool.getEnrollment(utxo_hash_1, stored_enroll);
    assert(stored_enroll == enroll_1);
    ledger.enroll_man.pool.getEnrollment(utxo_hash_2, stored_enroll);
    assert(stored_enroll == enroll_2);
    ledger.enroll_man.pool.getEnrollment(utxo_hash_3, stored_enroll);
    assert(stored_enroll == enroll_3);
    genNormalBlockTransactions(1);
    assert(ledger.getBlockHeight() == 4);

    // Check if there are any unregistered enrollments
    Enrollment[] unreg_enrollments;
    assert(ledger.enroll_man.getEnrollments(unreg_enrollments,
        ledger.getBlockHeight()) is null);
    auto block_4 = ledger.getBlocksFrom(Height(4));
    enrollments.sort!("a.utxo_key < b.utxo_key");
    assert(block_4[0].header.enrollments == enrollments);

    genNormalBlockTransactions(validator_cycle - 1);
    Hash[] keys;
    assert(ledger.enroll_man.getEnrolledUTXOs(keys));
    assert(keys.length == /* Genesis */ 6 + 3 /* New ones */);
    assert(ledger.getBlockHeight() == validator_cycle + 4 - 1);
}

version (unittest)
private Transaction[] splitGenesisTransaction (
    KeyPair[] out_key, Amount amount = Amount.MinFreezeAmount)
{
    Transaction[] txes;
    foreach (idx; 0 .. Block.TxsInBlock)
    {
        Transaction tx = {TxType.Payment, [], []};
        tx.inputs ~= Input(hashFull(GenesisTransaction), idx);
        foreach (idx2; 0 .. Block.TxsInBlock)
            tx.outputs ~= Output(amount, out_key[idx].address);

        auto signature = WK.Keys.Genesis.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        txes ~= tx;
    }

    return txes;
}

// generate genesis with a freeze & payment tx, and 'count' number of
// extra blocks
version (unittest)
private const(Block)[] genBlocksToIndex ( KeyPair key_pair,
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
    const StartHeight = Height(0);  // not important
    assert(enroll_man.createEnrollment(utxo, StartHeight, enroll));
    enrolls ~= enroll;

    gen_txs.sort;
    Hash[] merkle_tree;
    auto merkle_root = Block.buildMerkleTree(gen_txs, merkle_tree);

    auto genesis = immutable(Block)(
        immutable(BlockHeader)(
            Hash.init,   // prev
            Height(0),   // height
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
        auto txs = makeChainedTransactions(WK.Keys.Genesis,
            prev_txs, 1);

        const NoEnrollments = null;
        blocks ~= makeNewBlock(blocks[$ - 1], txs, NoEnrollments);
        prev_txs = txs;
    }

    return blocks.assumeUnique;
}

/// test enrollments in the genesis block
unittest
{
    import agora.common.BitField;
    import agora.common.Serializer;
    import std.exception;

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
        scope ledger = new Ledger(config.node, params, utxo_set, storage,
                                  enroll_man, pool);
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
        scope ledger = new Ledger(config.node, params, utxo_set, storage,
                                  enroll_man, pool);
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
        scope ledger = new Ledger(config.node, params, utxo_set, storage,
                                  enroll_man, pool);
        Hash[] keys;
        assert(enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 0);
    }
}

/// test atomicity of adding blocks and rolling back
unittest
{
    import agora.common.crypto.Key;
    import agora.common.Types;
    import agora.common.Hash;
    import std.conv;
    import std.exception;
    import std.range;

    class ThrowingLedger : Ledger
    {
        bool throw_in_update_utxo;
        bool throw_in_update_validators;

        this (NodeConfig node_config, immutable(ConsensusParams) params,
            UTXOSet utxo_set, IBlockStorage storage,
            EnrollmentManager enroll_man, TransactionPool pool,
            void delegate () nothrow @safe onValidatorsChanged = null)
        {
            super(node_config, params, utxo_set, storage, enroll_man, pool,
                onValidatorsChanged);
        }

        override void updateUTXOSet (const ref Block block) @safe
        {
            super.updateUTXOSet(block);
            if (this.throw_in_update_utxo)
                throw new Exception("");
        }

        override void updateValidatorSet (const ref Block block) @safe
        {
            super.updateValidatorSet(block);
            if (this.throw_in_update_validators)
                throw new Exception("");
        }
    }

    // normal test: UTXO set and Validator set updated
    {
        auto key_pair = KeyPair.random();
        auto params = new immutable(ConsensusParams)();
        scope enroll_man = new EnrollmentManager(":memory:", key_pair, params);
        const blocks = genBlocksToIndex(key_pair, enroll_man, 1008);
        assert(blocks.length == 1009);  // +1 for genesis

        scope storage = new MemBlockStorage(blocks.takeExactly(1008));
        scope pool = new TransactionPool(":memory:");
        scope utxo_set = new UTXOSet(":memory:");
        scope config = new Config();
        scope ledger = new ThrowingLedger(config.node, params, utxo_set,
            storage, enroll_man, pool, null);
        Hash[] keys;
        assert(enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 1);
        auto utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == 1008));

        auto next_block = blocks[$ - 1];
        ledger.addValidatedBlock(next_block);
        assert(ledger.last_block == next_block);
        utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == 1009));
        assert(enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 0);
    }

    // throws in updateUTXOSet() => rollback() called, UTXO set reverted,
    // Validator set was not modified
    {
        auto key_pair = KeyPair.random();
        auto params = new immutable(ConsensusParams)();
        scope enroll_man = new EnrollmentManager(":memory:", key_pair, params);
        const blocks = genBlocksToIndex(key_pair, enroll_man, 1008);
        assert(blocks.length == 1009);  // +1 for genesis

        scope storage = new MemBlockStorage(blocks.takeExactly(1008));
        scope pool = new TransactionPool(":memory:");
        scope utxo_set = new UTXOSet(":memory:");
        scope config = new Config();
        scope ledger = new ThrowingLedger(config.node, params, utxo_set,
            storage, enroll_man, pool, null);
        Hash[] keys;
        assert(enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 1);
        auto utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == 1008));

        ledger.throw_in_update_utxo = true;
        auto next_block = blocks[$ - 1];
        assertThrown!Exception(ledger.addValidatedBlock(next_block));
        assert(ledger.last_block == blocks[$ - 2]);  // not updated
        utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == 1008));  // reverted
        assert(enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 1);  // not updated
    }

    // throws in updateValidatorSet() => rollback() called, UTXO set and
    // Validator set reverted
    {
        auto key_pair = KeyPair.random();
        auto params = new immutable(ConsensusParams)();
        scope enroll_man = new EnrollmentManager(":memory:", key_pair, params);
        const blocks = genBlocksToIndex(key_pair, enroll_man, 1008);
        assert(blocks.length == 1009);  // +1 for genesis

        scope storage = new MemBlockStorage(blocks.takeExactly(1008));
        scope pool = new TransactionPool(":memory:");
        scope utxo_set = new UTXOSet(":memory:");
        scope config = new Config();
        scope ledger = new ThrowingLedger(config.node, params, utxo_set,
            storage, enroll_man, pool, null);
        Hash[] keys;
        assert(enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 1);
        auto utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == 1008));

        ledger.throw_in_update_validators = true;
        auto next_block = blocks[$ - 1];
        assertThrown!Exception(ledger.addValidatedBlock(next_block));
        assert(ledger.last_block == blocks[$ - 2]);  // not updated
        utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == 1008));  // reverted
        assert(enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 1);  // reverted
    }
}
