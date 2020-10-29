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
import agora.consensus.protocol.Data;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Params;
import agora.consensus.data.Transaction;
import agora.consensus.state.UTXODB;
import agora.consensus.EnrollmentManager;
import agora.consensus.validation;
import agora.node.BlockStorage;
import agora.stats.Block;
import agora.stats.Tx;
import agora.stats.Utils;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

import std.algorithm;
import std.conv : to;
import std.exception;
import std.format;
import std.range;

mixin AddLogger!();

version (unittest)
{
    //import agora.consensus.data.genesis.Test;
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

    /// If not null call this delegate
    /// A block was externalized
    private void delegate (const ref Block, bool) @safe onAcceptedBlock;

    /// Parameters for consensus-critical constants
    private immutable(ConsensusParams) params;

    /// Transaction stats
    private TxStats tx_stats;

    /// Block stats
    private BlockStats block_stats;

    /***************************************************************************

        Constructor

        Params:
            params = the consensus-critical constants
            utxo_set = the set of unspent outputs
            storage = the block storage
            enroll_man = the enrollmentManager
            pool = the transaction pool
            onAcceptedBlock = optional delegate to call
                              when a block was added to the ledger

    ***************************************************************************/

    public this (immutable(ConsensusParams) params,
        UTXOSet utxo_set, IBlockStorage storage,
        EnrollmentManager enroll_man, TransactionPool pool,
        void delegate (const ref Block, bool) @safe onAcceptedBlock = null)
    {
        this.params = params;
        this.utxo_set = utxo_set;
        this.storage = storage;
        this.enroll_man = enroll_man;
        this.pool = pool;
        this.onAcceptedBlock = onAcceptedBlock;
        if (!this.storage.load(params.Genesis))
            assert(0);

        // ensure latest checksum can be read
        if (!this.storage.readLastBlock(this.last_block))
            assert(0);

        Block gen_block;
        this.storage.readBlock(gen_block, Height(0));
        if (gen_block != cast()params.Genesis)
            throw new Exception("Genesis block loaded from disk is " ~
                "different from the one in the config file");

        // need to rebuild the UTXO set and Validator set,
        // starting from the genesis block
        if (this.utxo_set.length == 0)
        {
            ManagedDatabase.beginBatch();
            scope (failure) ManagedDatabase.rollback();

            // clear validator set
            this.enroll_man.removeAllValidators();

            Block last_read_block = gen_block;
            foreach (height; 0 .. this.last_block.header.height + 1)
            {
                Block block;
                this.storage.readBlock(block, Height(height));
                if (height == 0)
                {
                    if (auto reason = block.isGenesisBlockInvalidReason())
                        throw new Exception(
                            "Genesis block loaded from disk is invalid: " ~
                            reason);
                }
                else
                {
                    const active_enrollments = enroll_man.getValidatorCount(
                        block.header.height);

                    if (auto fail_reason = block.isInvalidReason(
                        last_read_block.header.height,
                        last_read_block.header.hashFull,
                        this.utxo_set.getUTXOFinder(),
                        active_enrollments,
                        this.params))
                        throw new Exception(
                            "A block loaded from disk is invalid: " ~
                            fail_reason);
                }
                this.updateUTXOSet(block);
                this.updateValidatorSet(block);
                last_read_block = block;
            }
            ManagedDatabase.commitBatch();
        }
        else
        {
            // +1 because the genesis block counts as one
            const ulong block_count = this.last_block.header.height + 1;

            // we are only interested in the last 1008 blocks,
            // because that is the maximum length of an enrollment.
            const Height min_height =
                block_count >= this.params.ValidatorCycle
                ? Height(block_count - this.params.ValidatorCycle) : Height(0);

            PublicKey pubkey = this.enroll_man.getEnrollmentPublicKey();
            UTXO[Hash] utxos = this.utxo_set.getUTXOs(pubkey);

            // restore validator set from the blockchain.
            // using block_count, as the range is inclusive
            foreach (block_idx; min_height .. block_count)
            {
                Block block;
                this.storage.readBlock(block, block_idx);
                this.enroll_man.restoreValidators(this.last_block.header.height,
                    block, this.utxo_set.getUTXOFinder(), utxos);
            }
        }

        Utils.getCollectorRegistry().addCollector(&this.collectTxStats);
        Utils.getCollectorRegistry().addCollector(&this.collectBlockStats);
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
        this.block_stats.increaseMetricBy!"agora_block_txs_amount_total"(
            getUnspentAmount(block.txs));
        this.block_stats.increaseMetricBy!"agora_block_txs_total"(
            block.txs.length);
        this.block_stats.increaseMetricBy!"agora_block_externalized_total"(1);
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
        this.tx_stats.increaseMetricBy!"agora_transactions_received_total"(1);
        const Height expected_height = Height(this.getBlockHeight() + 1);
        auto reason = tx.isInvalidReason(this.utxo_set.getUTXOFinder(),
            expected_height, this.params);

        if (reason !is null || !this.pool.add(tx))
        {
            log.info("Rejected tx. Reason: {}. Tx: {}",
                reason !is null ? reason : "double-spend", tx);
            this.tx_stats.increaseMetricBy!"agora_transactions_rejected_total"(1);
            return false;
        }

        this.tx_stats.increaseMetricBy!"agora_transactions_accepted_total"(1);
        return true;
    }

    /***************************************************************************

        Add a validated block to the Ledger,
        and add all of its outputs to the UTXO set.
        If there are any enrollments in the block,
        add enrollments to the validator set.
        If not null call the `onAcceptedBlock` delegate.

        Params:
            block = the block to add

    ***************************************************************************/

    private void addValidatedBlock (const ref Block block) @safe
    {
        if (!this.storage.saveBlock(block))
            assert(0, format!"Failed to save block: %s"(prettify(block)));

        auto old_count = this.enroll_man.validatorCount();

        ManagedDatabase.beginBatch();
        {
            // rollback on failure within the scope of the db transactions
            scope (failure) ManagedDatabase.rollback();
            this.updateUTXOSet(block);
            this.updateValidatorSet(block);
            ManagedDatabase.commitBatch();
        }

        this.block_stats.setMetricTo!"agora_block_enrollments_gauge"(
            this.enroll_man.validatorCount());
        // there was a change in the active validator set
        bool validators_changed = block.header.enrollments.length > 0
            || this.enroll_man.validatorCount() != old_count;

        // read back and cache the last block
        if (!this.storage.readLastBlock(this.last_block))
            assert(0, format!"Failed to read last block: %s"(prettify(this.last_block)));

        if (this.onAcceptedBlock !is null)
            this.onAcceptedBlock(block, validators_changed);
    }

    mixin DefineCollectorForStats!("block_stats", "collectBlockStats");

    /***************************************************************************

        Collect all ledger & mempool stats into the collector

        Params:
            collector = the Collector to collect the stats into

    ***************************************************************************/

    private void collectTxStats (Collector collector)
    {
        this.tx_stats.setMetricTo!"agora_transactions_poolsize_gauge"(
            this.pool.length());
        this.tx_stats.setMetricTo!"agora_transactions_amount_gauge"(
            getUnspentAmount(this.pool));
        foreach (stat; this.tx_stats.getStats())
            collector.collect(stat.value);
    }

    /// Stats helper: return the total unspent amount
    private ulong getUnspentAmount (TxRange)(ref TxRange transactions)
    {
        Amount tx_amount;
        foreach (const ref Transaction tx; transactions)
            getSumOutput(tx, tx_amount);
        return to!ulong(tx_amount.toString());
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
            this.enroll_man.removeEnrollment(enrollment.utxo_key);

            PublicKey pubkey = this.enroll_man.getEnrollmentPublicKey();
            UTXO[Hash] utxos = this.utxo_set.getUTXOs(pubkey);
            if (auto r = this.enroll_man.addValidator(enrollment,
                block.header.height, this.utxo_set.getUTXOFinder(), utxos))
            {
                log.fatal("Error while adding a new validator: {}", r);
                log.fatal("Enrollment #{}: {}", idx, enrollment);
                log.fatal("Validated block: {}", block);
                assert(0);
            }
        }
    }

    /***************************************************************************

        Collect up to a maximum number of transactions to nominate

        Params:
            txs = will contain the transaction set to nominate,
                  or empty if not enough txs were found
            max_txs = the maximum number of transactions to prepare.

    ***************************************************************************/

    public void prepareNominatingSet (ref ConsensusData data, ulong max_txs)
        @safe
    {
        data = ConsensusData.init;
        const next_height = Height(this.getBlockHeight() + 1);
        auto utxo_finder = this.utxo_set.getUTXOFinder();

        this.enroll_man.getEnrollments(data.enrolls,
            Height(this.getBlockHeight()));
        foreach (ref Transaction tx; this.pool)
        {
            if (auto reason = tx.isInvalidReason(utxo_finder, next_height, this.params))
                log.trace("Rejected invalid ('{}') tx: {}", reason, tx);
            else
                data.tx_set ~= tx;

            if (data.tx_set.length >= max_txs)
            {
                data.tx_set.sort();
                return;
            }
        }
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

        foreach (const ref tx; data.tx_set)
        {
            if (auto fail_reason = tx.isInvalidReason(utxo_finder, expect_height, this.params))
                return fail_reason;
        }

        size_t active_enrollments = enroll_man.getValidatorCount(expect_height);

        if (data.enrolls.length + active_enrollments < Enrollment.MinValidatorCount)
            return "Enrollment: Insufficient number of active validators";

        foreach (const ref enroll; data.enrolls)
        {
            if (auto fail_reason = this.enroll_man.isInvalidCandidateReason(
                enroll, expect_height, utxo_finder))
                return fail_reason;
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
            active_enrollments,
            this.params);
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

    public Hash[] getMerklePath (Height block_height, in Hash hash) @safe nothrow
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

        Generate the random seed reduced from the preimages for the provided
        block height.

        Params:
            height = the desired block height to look up the images for

        Returns:
            the random seed

    ***************************************************************************/

    public Hash getValidatorRandomSeed (Height height) nothrow
    {
        Hash[] keys;
        if (!this.enroll_man.getEnrolledUTXOs(keys) || keys.length == 0)
        {
            log.fatal("Could not retrieve enrollments / no enrollments found");
            assert(0);
        }

        return this.enroll_man.getRandomSeed(keys, height);
    }
}

/// Note: these unittests historically assume a block always contains
/// 8 transactions - hence the use of `TxsInTestBlock` appearing everywhere.
version (unittest)
{
    /// simulate block creation as if a nomination and externalize round completed
    private void forceCreateBlock (Ledger ledger)
    {
        ConsensusData data;
        ledger.prepareNominatingSet(data, Block.TxsInTestBlock);
        assert(data.tx_set.length == Block.TxsInTestBlock);
        assert(ledger.onExternalized(data));
    }

    /// A `Ledger` with sensible defaults for `unittest` blocks
    private final class TestLedger : Ledger
    {
        public this (KeyPair key_pair,
            const(Block)[] blocks = null,
            immutable(ConsensusParams) params_ = null)
        {
            const params = (params_ !is null)
                ? params_
                : (blocks.length > 0
                   // Use the provided Genesis block
                   ? new immutable(ConsensusParams)(cast(immutable)blocks[0], WK.Keys.CommonsBudget.address)
                   // Use the unittest genesis block
                   : new immutable(ConsensusParams)());

            super(params, new UTXOSet(":memory:"),
                new MemBlockStorage(blocks),
                new EnrollmentManager(":memory:", key_pair, params),
                new TransactionPool(":memory:"));
        }
    }
}

///
unittest
{
    scope ledger = new TestLedger(WK.Keys.NODE2);
    assert(ledger.getBlockHeight() == 0);

    auto blocks = ledger.getBlocksFrom(Height(0)).take(10);
    assert(blocks[$ - 1] == ledger.params.Genesis);

    // generate enough transactions to form a block
    Transaction[] last_txs;
    void genBlockTransactions (size_t count)
    {
        assert(count > 0);

        // Special case for genesis
        if (!last_txs.length)
        {
            last_txs = genesisSpendable().take(Block.TxsInTestBlock).enumerate()
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
    assert(blocks[0] == ledger.params.Genesis);
    assert(blocks.length == 3);  // two blocks + genesis block

    /// now generate 98 more blocks to make it 100 + genesis block (101 total)
    genBlockTransactions(98);
    assert(ledger.getBlockHeight() == 100);

    blocks = ledger.getBlocksFrom(Height(0)).takeExactly(10);
    assert(blocks[0] == ledger.params.Genesis);
    assert(blocks.length == 10);

    /// lower limit
    blocks = ledger.getBlocksFrom(Height(0)).takeExactly(5);
    assert(blocks[0] == ledger.params.Genesis);
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
    scope ledger = new TestLedger(WK.Keys.Genesis);

    // Valid case
    auto txs = genesisSpendable().map!(txb => txb.sign()).array();
    txs.each!(tx => assert(ledger.acceptTransaction(tx)));
    ledger.forceCreateBlock();
    auto blocks = ledger.getBlocksFrom(Height(0)).take(10);
    assert(blocks.length == 2);

    // Invalid case
    txs = txs.map!(tx => TxBuilder(tx).sign()).array();
    foreach (ref tx; txs)
    {
        foreach (ref output; tx.outputs)
            output.value = Amount(0);
        foreach (ref input; tx.inputs)
            input.signature = WK.Keys.Genesis.secret.sign(hashFull(tx)[]);
    }

    txs.each!(tx => assert(!ledger.acceptTransaction(tx)));
    blocks = ledger.getBlocksFrom(Height(0)).take(10);
    assert(blocks.length == 2);
}

/// basic block verification
unittest
{
    scope ledger = new TestLedger(WK.Keys.NODE2);

    Block invalid_block;  // default-initialized should be invalid
    assert(!ledger.acceptBlock(invalid_block));

    auto txs = genesisSpendable().map!(txb => txb.sign()).array();
    auto valid_block = makeNewBlock(ledger.params.Genesis, txs);
    assert(ledger.acceptBlock(valid_block));
}

/// Merkle Proof
unittest
{
    scope ledger = new TestLedger(WK.Keys.NODE2);

    auto txs = genesisSpendable().map!(txb => txb.sign()).array();
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
    import agora.consensus.data.genesis.Test;

    // Cannot use literals: https://issues.dlang.org/show_bug.cgi?id=20938
    const(Block)[] blocks = [ GenesisBlock ];
    auto txs = GenesisBlock.spendable().map!(txb => txb.sign()).array();
    blocks ~= makeNewBlock(blocks[$ - 1], txs);
    // Make 3 more blocks to put in storage
    foreach (idx; 2 .. 5)
    {
        txs = blocks[$ - 1].spendable().map!(txb => txb.sign()).array();
        blocks ~= makeNewBlock(blocks[$ - 1], txs);
    }

    // And provide it to the ledger
    scope ledger = new TestLedger(WK.Keys.NODE2, blocks);

    assert(ledger.utxo_set.length
           == /* Genesis, Frozen */ 6 + 8 /* Block #1 Payments*/);

    // Ensure that all previously-generated outputs are in the UTXO set
    {
        auto findUTXO = ledger.utxo_set.getUTXOFinder();
        UTXO utxo;
        assert(
            txs.all!(
                tx => iota(tx.outputs.length).all!(
                    (idx) {
                        return findUTXO(UTXO.getHash(tx.hashFull(), idx), utxo) &&
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

    assert(in_key_pair.length == Block.TxsInTestBlock);
    assert(out_key_pair.length == Block.TxsInTestBlock);

    assert(prev_txs.length == 0 || prev_txs.length == Block.TxsInTestBlock);
    const TxCount = Block.TxsInTestBlock;

    Transaction[] transactions;

    // always use the same amount, for simplicity
    const Amount AmountPerTx = Amount.MinFreezeAmount;

    foreach (idx; 0 .. TxCount)
    {
        Input input;
        if (prev_txs.length == 0)  // refering to genesis tx's outputs
            input = Input(hashFull(default_tx), idx.to!uint);
        else  // refering to tx's in the previous block
            input = Input(hashFull(prev_txs[idx % Block.TxsInTestBlock]), 0);

        Transaction tx =
        {
            tx_type,
            [input],
            [Output(AmountPerTx, out_key_pair[idx % Block.TxsInTestBlock].address)]  // send to the same address
        };

        auto signature = in_key_pair[idx % Block.TxsInTestBlock].secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        transactions ~= tx;

        // new transactions will refer to the just created transactions
        // which will be part of the previous block after the block is created
        if (Block.TxsInTestBlock == 1 ||  // special case
            (idx > 0 && ((idx + 1) % Block.TxsInTestBlock == 0)))
        {
            // refer to tx'es which will be in the previous block
            prev_txs = transactions[$ - Block.TxsInTestBlock .. $];
        }
    }
    return transactions;
}

version (unittest)
private KeyPair[] getRandomKeyPairs ()
{
    KeyPair[] res;
    foreach (idx; 0 .. Block.TxsInTestBlock)
        res ~= KeyPair.random;
    return res;
}

/// Situation : Create two blocks, one containing only `Payment` transactions,
///             the other containing only `Freeze` ones
/// Expectation: Block creation succeeds
unittest
{
    scope ledger = new TestLedger(WK.Keys.NODE2);

    // Generate payment transactions to the first 8 well-known keypairs
    auto txs = genesisSpendable().enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array();
    txs.each!(tx => assert(ledger.acceptTransaction(tx)));
    ledger.forceCreateBlock();
    assert(ledger.getBlockHeight() == 1);
    auto blocks = ledger.getBlocksFrom(Height(0)).take(10).array;
    assert(blocks.length == 2);
    assert(blocks[1].header.height == 1);

    // Now generate a block with only freezing transactions
    txs.enumerate()
        .map!(en => TxBuilder(en.value)
              .refund(WK.Keys[Block.TxsInTestBlock + en.index].address)
              .sign(TxType.Freeze))
        .each!(tx => assert(ledger.acceptTransaction(tx)));
    ledger.forceCreateBlock();
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
    scope ledger = new TestLedger(WK.Keys.NODE2);

    KeyPair[] splited_keys = getRandomKeyPairs();
    KeyPair[] in_key_pairs_normal;
    KeyPair[] out_key_pairs_normal;
    Transaction[] last_txs_normal;
    KeyPair[] in_key_pairs_freeze;
    KeyPair[] out_key_pairs_freeze;
    Transaction[] last_txs_freeze;

    Transaction[] splited_txex;

    in_key_pairs_normal.length = 0;
    foreach (idx; 0 .. Block.TxsInTestBlock)
        in_key_pairs_normal ~= splited_keys[0];

    out_key_pairs_normal = getRandomKeyPairs();

    // generate normal transactions to form a block
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
                last_txs_normal = txes[$ - Block.TxsInTestBlock .. $];

                in_key_pairs_normal = out_key_pairs_normal;
                out_key_pairs_normal = getRandomKeyPairs();
            }
        }
    }

    in_key_pairs_freeze.length = 0;
    foreach (idx; 0 .. Block.TxsInTestBlock)
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
                last_txs_freeze = txes[$ - Block.TxsInTestBlock .. $];

                in_key_pairs_freeze = out_key_pairs_freeze;
                out_key_pairs_freeze = getRandomKeyPairs();
            }
        }
    }

    // Divide 8 'Outputs' that are included in Genesis Block by 40,000
    // It generates eight addresses and eight transactions,
    // and one transaction has eight Outputs with a value of 40,000 values.
    splited_txex = () {
        Transaction[] txs;
        foreach (idx; 0 .. Block.TxsInTestBlock)
        {
            txs ~= TxBuilder(params.Genesis.txs[1], idx)
                .split(splited_keys[idx].address.repeat(Block.TxsInTestBlock))
                .sign();
        }
        return txs;
    }();
    splited_txex.each!(tx => assert(ledger.acceptTransaction(tx)));
    ledger.forceCreateBlock();
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

    const utxo_hashes = [
        UTXO.getHash(hashFull(blocks[3].txs[0]), 0),
        UTXO.getHash(hashFull(blocks[3].txs[1]), 0),
        UTXO.getHash(hashFull(blocks[3].txs[2]), 0),
    ];

    Enrollment[] enrollments ;
    foreach (index; 0 .. 3)
        enrollments ~= EnrollmentManager.makeEnrollment(
            enroll_key_pair[index], utxo_hashes[index], params.ValidatorCycle);

    auto findUTXO = ledger.utxo_set.getUTXOFinder();
    foreach (const ref e; enrollments)
        assert(ledger.enroll_man.addEnrollment(e, Height(3), findUTXO));

    Enrollment stored_enroll;
    foreach (idx, hash; utxo_hashes)
    {
        stored_enroll = ledger.enroll_man.getEnrollment(hash);
        assert(stored_enroll == enrollments[idx]);
    }

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

// Return Genesis block plus 'count' number of blocks
version (unittest)
private immutable(Block)[] genBlocksToIndex (
    KeyPair key_pair, size_t count, scope immutable(ConsensusParams) params)
{
    const(Block)[] blocks = [ params.Genesis ];

    foreach (_; 0 .. count)
    {
        auto txs = blocks[$ - 1].spendable().map!(txb => txb.sign());

        const NoEnrollments = null;
        blocks ~= makeNewBlock(blocks[$ - 1], txs, NoEnrollments);
    }

    return blocks.assumeUnique;
}

/// test enrollments in the genesis block
unittest
{
    import agora.common.BitField;
    import agora.common.Serializer;
    import std.exception;

    // Default test genesis block has 6 validators
    {
        scope ledger = new TestLedger(WK.Keys.A);
        Hash[] keys;
        assert(ledger.enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 6);
    }

    // One block before `ValidatorCycle`, validator is still active
    {
        const ValidatorCycle = 10;
        auto key_pair = KeyPair.random();
        auto params = new immutable(ConsensusParams)(ValidatorCycle);
        const blocks = genBlocksToIndex(key_pair, ValidatorCycle - 1, params);
        scope ledger = new TestLedger(WK.Keys.A, blocks, params);
        Hash[] keys;
        assert(ledger.enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 6);
    }

    // Past `ValidatorCycle`, validator is inactive
    {
        const ValidatorCycle = 20;
        auto key_pair = KeyPair.random();
        auto params = new immutable(ConsensusParams)(ValidatorCycle);
        const blocks = genBlocksToIndex(key_pair, ValidatorCycle, params);
        // Enrollment: Insufficient number of active validators
        assertThrown!Exception(new TestLedger(WK.Keys.A, blocks, params));
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

    static class ThrowingLedger : Ledger
    {
        bool throw_in_update_utxo;
        bool throw_in_update_validators;

        public this (KeyPair kp, const(Block)[] blocks, immutable(ConsensusParams) params)
        {
            super(params, new UTXOSet(":memory:"),
                new MemBlockStorage(blocks),
                new EnrollmentManager(":memory:", kp, params),
                new TransactionPool(":memory:"));
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

    const params = new immutable(ConsensusParams)();

    // normal test: UTXO set and Validator set updated
    {
        auto key_pair = KeyPair.random();
        const blocks = genBlocksToIndex(key_pair, params.ValidatorCycle, params);
        assert(blocks.length == params.ValidatorCycle + 1);  // +1 for genesis

        scope ledger = new ThrowingLedger(
            key_pair, blocks.takeExactly(params.ValidatorCycle), params);
        Hash[] keys;
        assert(ledger.enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 6);
        auto utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == params.ValidatorCycle));

        auto next_block = blocks[$ - 1];
        ledger.addValidatedBlock(next_block);
        assert(ledger.last_block == cast()next_block);
        utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == 1009));
        assert(ledger.enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 0);
    }

    // throws in updateUTXOSet() => rollback() called, UTXO set reverted,
    // Validator set was not modified
    {
        auto key_pair = KeyPair.random();
        const blocks = genBlocksToIndex(key_pair, params.ValidatorCycle, params);
        assert(blocks.length == params.ValidatorCycle + 1);  // +1 for genesis

        scope ledger = new ThrowingLedger(
            key_pair, blocks.takeExactly(params.ValidatorCycle), params);
        Hash[] keys;
        assert(ledger.enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 6);
        auto utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == params.ValidatorCycle));

        ledger.throw_in_update_utxo = true;
        auto next_block = blocks[$ - 1];
        assertThrown!Exception(ledger.addValidatedBlock(next_block));
        assert(ledger.last_block == cast()blocks[$ - 2]);  // not updated
        utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == params.ValidatorCycle));  // reverted
        assert(ledger.enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 6);  // not updated
    }

    // throws in updateValidatorSet() => rollback() called, UTXO set and
    // Validator set reverted
    {
        auto key_pair = KeyPair.random();
        const blocks = genBlocksToIndex(key_pair, params.ValidatorCycle, params);
        assert(blocks.length == 1009);  // +1 for genesis

        scope ledger = new ThrowingLedger(
            key_pair, blocks.takeExactly(params.ValidatorCycle), params);
        Hash[] keys;
        assert(ledger.enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 6);
        auto utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == params.ValidatorCycle));

        ledger.throw_in_update_validators = true;
        auto next_block = blocks[$ - 1];
        assertThrown!Exception(ledger.addValidatedBlock(next_block));
        assert(ledger.last_block == cast()blocks[$ - 2]);  // not updated
        utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == params.ValidatorCycle));  // reverted
        assert(ledger.enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 6);  // reverted
    }
}

/// throw if the gen block in block storage is different to the configured one
unittest
{
    import agora.common.Serializer;
    import agora.consensus.data.genesis.Test;
    import std.conv;

    immutable gen_block_hex = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000549228136441128130986753d019a3ebe69cb8f4718e4848746d55bb81bf56a80baa95dec7e13b7b189d7a3de78e0302688ec38657729f5d6565b5629d158c78000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006aca35270c439c31dc5c009dad44cf57f216e3697f95f5a76067891c3447abce9c709b87675e1993fcd01805aaceaef6d1b1a6efdcf5fa940d6818477833e8846389a02af9bc0aed7c2aa25db36dd9a3c2329db292b3c0e68c23ac007616f070e1419df629c9a522725fd37735c39e44d68fc4a1690a46ebc0ac73f4ac921a7e5fdf003227414c27024c8ac13e31159ab2d8b1bc463b7bdb915289edff5e35f13898bdcf36a2652577f8533ffb50be9dca0290f1586ce5f8eede7a9ec8ecedefb6c4c03efe69bf0533530da5632469962923165e4de89d98156771851d3c4f07b37396acf630c5671b1ed94bb8d08db4fa636a301abde46afda5b9d7f36092e6d80de4d4328bd27e179f22a84dde3eacb12fe1b1f53cbf47bc1879b282ee617e4ce2a14143842f52975efa75aba24f7d26fbeee89be01bfd7d47d8eaf9bf3d4b1b609d4fdf003015c257522778ac4a2a2d85753583e7cd7331d4b9a161647a33341b0b8d09226fee61623635804212e070f9ac9e81efee0663e34ac5de7473a90aedbb4ff6a04e07056beb7f356866f57f38f92df9e723c31c60f0a2914ab1c6fee0acd8ed437f5bcfae0b769ce037b0f616c2bd8b1d48a678a1fda3008fa2af45d47a461158c4239737339b1716c243f1523ff4e0aa9fc76105ca19d954b42c404918bdf3017d067ecf8745df77c0d77af1a1222416a5e56048760c8c72deddb9d60b8e13ed8fdf00304130031a6489ffb577ad2a13c43b8b7835e19e44b86c235dbccb4b653473d7e770d1ecbf1ad5aec55985b371e9c7665bf19bf9b9326a06cb2fb4f923c079b0bb085e09f3b11826e6279366ef28d73df4ae163d1ad81fb21126cf42a570c183d2dbac8a9aced837d2398340f09c3d7b5e01ce305b6878ebb54cf6698c78e9094daac16cde886d550b1a1642f4d3bab975e612d32533ac827f1d6275ce5dd102eb17e4a664d93ea115a65dba3b42af2ab3d885efcfa81a05dc6b74071fbe2fd34fdf00334663a1d39cf6fe86b79c21f63ca2aac57d5410776a373edb98ab718457c78fd084052c574e797f6731b71039febccef14ad076e557666db5209ebfdd963ac03eb08ae4bfee5f00da15985c13921b7fd65e3b6df5a2702a4d6e0bc9ebb871e63719b7970e5f9cd974a99e848792ff1ea7f67cdab5ef573f5f371a9bdcfa90db2db6cbecf5bc854ab2ea8b97be64b1df686a9056873e23174f99031c73ccd55197ff964270459582c5c8d361ad1b4d3ea5c09c41edba6508ee798a47e7629df52fdf003316b74aa2693c0d531692c82c840f9bd83fc39899b00dc697809d3e4ac369ad722338f1370db15986c2dec3a88ea813e5b940e388852765f6476472a9bb4050b852dfe9f69ab65820cae78a23cbc3ced9160e54ad66f86e6c38ea34aa7126dd7035ac60083bd69330c7970558eec4fc5365e0abe823d5397a0ced287bd3139db8e08cb1d1e962766812b28869730a5663e1a5ee36ce4806ab1b877f84881c3d3207081909b4844c466a20cc6544fde8cfe50232f1956222332ffb8885930dc23fdf003e24fa71a72f492a50ac73556ded7ec14cfe36f30b0324d647e4ba28243e7715c355537c97c7f1ccc7f45027ca5131f9733587c81f3b50561bd6416c7271a250e02010006ff0040e59c30120000dae1934864c67fcb27bd872d70991330222591cd83b970eb8a28ff51a6556a55ff0040e59c30120000dae19364b4145dee6f56fa30436ab831274f84e00437552c1e603aa9fef21892ff0040e59c30120000dae1938a993f5850f50aee830ff52171dfdf97af79f7ff43dfe4337e8477d967ff0040e59c30120000dae193b3fcec9d4b9484a6cfa867a68f038934b970b7e463c1ae80d007dd36f4ff0040e59c30120000dae193d9bdb4d6b9d0419bae3024cc5ddd6bcb930e68036ca019884a69ac7f79ff0040e59c30120000dae193e9e928afcfc7591da28e81b6497adce977c5c017b5c8159234d0e5a3b400000008ff002050b1ca2a02009d0238e0a171400bc6d68a9d9b316acd5109649113a05c284f4296d2b30122f5ff002050b1ca2a02009d0238e0a171400bc6d68a9d9b316acd5109649113a05c284f4296d2b30122f5ff002050b1ca2a02009d0238e0a171400bc6d68a9d9b316acd5109649113a05c284f4296d2b30122f5ff002050b1ca2a02009d0238e0a171400bc6d68a9d9b316acd5109649113a05c284f4296d2b30122f5ff002050b1ca2a02009d0238e0a171400bc6d68a9d9b316acd5109649113a05c284f4296d2b30122f5ff002050b1ca2a02009d0238e0a171400bc6d68a9d9b316acd5109649113a05c284f4296d2b30122f5ff002050b1ca2a02009d0238e0a171400bc6d68a9d9b316acd5109649113a05c284f4296d2b30122f5ff002050b1ca2a02009d0238e0a171400bc6d68a9d9b316acd5109649113a05c284f4296d2b30122f50003bc75f96f82a6ebf8c9776ac315fa1da5e9e1f26af3bf631385a359e27c12835c7129db46aee9c5c1db3d4e4c713b61d74746823d3a9c30985b7f1ac49bce14635cf9f0b2d9962d874079ee7c154c7e8c5f99201664459f6a182bce732aec0afe0677f4a407c3b84a30661c4a4da89ed53deae3ffa7b97c37faae9c6fb9fe5b7a549228136441128130986753d019a3ebe69cb8f4718e4848746d55bb81bf56a80baa95dec7e13b7b189d7a3de78e0302688ec38657729f5d6565b5629d158c78";

    // hex => bin
    auto block_bytes = gen_block_hex.chunks(2).map!(
        twoDigits => twoDigits.parse!ubyte(16)).array();
    immutable new_gen_block = block_bytes.deserializeFull!(immutable(Block));

    // ConsensusParams is instantiated by default with the test genesis block
    immutable params = new immutable(ConsensusParams)();
    assert(new_gen_block != params.Genesis);

    try
    {
        scope ledger = new TestLedger(WK.Keys.A, [new_gen_block], params);
        assert(0);
    }
    catch (Exception ex)
    {
        assert(ex.msg == "Genesis block loaded from disk is different from the one in the config file");
    }

    immutable good_params = new immutable(ConsensusParams)(new_gen_block, WK.Keys.CommonsBudget.address);
    // will not fail
    scope ledger = new TestLedger(WK.Keys.A, [new_gen_block], good_params);
    // Neither will the default
    scope other_ledger = new TestLedger(WK.Keys.A, [new_gen_block]);
}
