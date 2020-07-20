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

    /// If not null call this delegate when a new block was added to the ledger
    private void delegate () nothrow @safe onValidatorsChanged;

    /// If not null call this delegate
    /// A block was externalized
    private void delegate (const Block) @safe onAcceptedBlock;

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
            onAcceptedBlock = optional delegate to call
                              when a block was added to the ledger
            onValidatorsChanged = optional delegate to call after the validator
                                  set changes when a block was externalized

    ***************************************************************************/

    public this (
        NodeConfig node_config, immutable(ConsensusParams) params,
        UTXOSet utxo_set, IBlockStorage storage,
        EnrollmentManager enroll_man, TransactionPool pool,
        void delegate (const Block) @safe onAcceptedBlock = null,
        void delegate () nothrow @safe onValidatorsChanged = null)
    {
        this.node_config = node_config;
        this.params = params;
        this.utxo_set = utxo_set;
        this.storage = storage;
        this.enroll_man = enroll_man;
        this.pool = pool;
        this.onAcceptedBlock = onAcceptedBlock;
        this.onValidatorsChanged = onValidatorsChanged;
        if (!this.storage.load(GenesisBlock))
            assert(0);

        // ensure latest checksum can be read
        if (!this.storage.readLastBlock(this.last_block))
            assert(0);

        Block gen_block;
        this.storage.readBlock(gen_block, Height(0));
        if (gen_block != cast()GenesisBlock)
            throw new Exception("Genesis block loaded from disk is " ~
                "different from the one in the config file");

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

        PublicKey pubkey = this.enroll_man.getEnrollmentPublicKey();
        UTXOSetValue[Hash] utxos = this.utxo_set.getUTXOs(pubkey);

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
        If not null call the `onAcceptedBlock` delegate.

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

        if (this.onAcceptedBlock !is null)
            this.onAcceptedBlock(block);
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
            UTXOSetValue[Hash] utxos = this.utxo_set.getUTXOs(pubkey);
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

/// Situation : Create two blocks, one containing only `Payment` transactions,
///             the other containing only `Freeze` ones
/// Expectation: Block creation succeeds
unittest
{
    NodeConfig config = {
        is_validator: true,
        key_pair:     WK.Keys.NODE2,
    };
    scope ledger = new TestLedger(config);

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
              .refund(WK.Keys[Block.TxsInBlock + en.index].address)
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

    // Divide 8 'Outputs' that are included in Genesis Block by 40,000
    // It generates eight addresses and eight transactions,
    // and one transaction has eight Outputs with a value of 40,000 values.
    splited_txex = () {
        Transaction[] txs;
        foreach (idx; 0 .. Block.TxsInBlock)
        {
            txs ~= TxBuilder(GenesisBlock.txs[1], idx)
                .split(splited_keys[idx].address.repeat(Block.TxsInBlock))
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
        UTXOSetValue.getHash(hashFull(blocks[3].txs[0]), 0),
        UTXOSetValue.getHash(hashFull(blocks[3].txs[1]), 0),
        UTXOSetValue.getHash(hashFull(blocks[3].txs[2]), 0),
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

// generate genesis with a freeze & payment tx, and 'count' number of
// extra blocks
version (unittest)
private const(Block)[] genBlocksToIndex (
    KeyPair key_pair, uint ValidatorCycle, size_t count)
{
    // 1 payment and 1 freeze tx (must be a power of 2 due to #797)
    Transaction[] gen_txs;
    // need mutable
    gen_txs ~= GenesisBlock.txs[1].serializeFull.deserializeFull!Transaction;

    Transaction freeze_tx =
    {
        type : TxType.Freeze,
        outputs : [Output(Amount.MinFreezeAmount, key_pair.address)]
    };

    gen_txs ~= freeze_tx;
    gen_txs.sort;

    const Hash utxo = UTXOSetValue.getHash(freeze_tx.hashFull(), 0);
    Enrollment[] enrolls = [
        EnrollmentManager.makeEnrollment(key_pair, utxo, ValidatorCycle, 0)
    ];

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
        const blocks = genBlocksToIndex(key_pair, params.ValidatorCycle, 0);
        auto old_gen = &GenesisBlock();
        setGenesisBlock(cast(immutable(Block)*)&blocks[0]);
        scope (exit) setGenesisBlock(old_gen);  // must reset it for other tests
        scope ledger = new TestLedger(NodeConfig.init, blocks, params);
        Hash[] keys;
        assert(ledger.enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 1);
    }

    // block 1007 loaded: validator is still active
    {
        const ValidatorCycle = 10;
        auto key_pair = KeyPair.random();
        auto params = new immutable(ConsensusParams)(ValidatorCycle);
        const blocks = genBlocksToIndex(key_pair, ValidatorCycle, ValidatorCycle - 1);
        auto old_gen = &GenesisBlock();
        setGenesisBlock(cast(immutable(Block)*)&blocks[0]);
        scope (exit) setGenesisBlock(old_gen);  // must reset it for other tests
        scope ledger = new TestLedger(NodeConfig.init, blocks, params);
        Hash[] keys;
        assert(ledger.enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 1);
    }

    // block 1008 loaded: validator is inactive
    {
        const ValidatorCycle = 20;
        auto key_pair = KeyPair.random();
        auto params = new immutable(ConsensusParams)(ValidatorCycle);
        const blocks = genBlocksToIndex(key_pair, ValidatorCycle, ValidatorCycle);
        auto old_gen = &GenesisBlock();
        setGenesisBlock(cast(immutable(Block)*)&blocks[0]);
        scope (exit) setGenesisBlock(old_gen);  // must reset it for other tests
        scope ledger = new TestLedger(NodeConfig.init, blocks, params);
        Hash[] keys;
        assert(ledger.enroll_man.getEnrolledUTXOs(keys));
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

    static class ThrowingLedger : Ledger
    {
        bool throw_in_update_utxo;
        bool throw_in_update_validators;

        public this (KeyPair kp, const(Block)[] blocks, immutable(ConsensusParams) params)
        {
            super(NodeConfig.init, params, new UTXOSet(":memory:"),
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
        const blocks = genBlocksToIndex(key_pair, params.ValidatorCycle, params.ValidatorCycle);
        assert(blocks.length == params.ValidatorCycle + 1);  // +1 for genesis
        auto old_gen = &GenesisBlock();
        setGenesisBlock(cast(immutable(Block)*)&blocks[0]);
        scope (exit) setGenesisBlock(old_gen);  // must reset it for other tests

        scope ledger = new ThrowingLedger(
            key_pair, blocks.takeExactly(params.ValidatorCycle), params);
        Hash[] keys;
        assert(ledger.enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 1);
        auto utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == params.ValidatorCycle));

        auto next_block = blocks[$ - 1];
        ledger.addValidatedBlock(next_block);
        assert(ledger.last_block == next_block);
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
        const blocks = genBlocksToIndex(key_pair, params.ValidatorCycle, params.ValidatorCycle);
        assert(blocks.length == params.ValidatorCycle + 1);  // +1 for genesis
        auto old_gen = &GenesisBlock();
        setGenesisBlock(cast(immutable(Block)*)&blocks[0]);
        scope (exit) setGenesisBlock(old_gen);  // must reset it for other tests

        scope ledger = new ThrowingLedger(
            key_pair, blocks.takeExactly(params.ValidatorCycle), params);
        Hash[] keys;
        assert(ledger.enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 1);
        auto utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == params.ValidatorCycle));

        ledger.throw_in_update_utxo = true;
        auto next_block = blocks[$ - 1];
        assertThrown!Exception(ledger.addValidatedBlock(next_block));
        assert(ledger.last_block == blocks[$ - 2]);  // not updated
        utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == params.ValidatorCycle));  // reverted
        assert(ledger.enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 1);  // not updated
    }

    // throws in updateValidatorSet() => rollback() called, UTXO set and
    // Validator set reverted
    {
        auto key_pair = KeyPair.random();
        const blocks = genBlocksToIndex(key_pair, params.ValidatorCycle, params.ValidatorCycle);
        assert(blocks.length == 1009);  // +1 for genesis
        auto old_gen = &GenesisBlock();
        setGenesisBlock(cast(immutable(Block)*)&blocks[0]);
        scope (exit) setGenesisBlock(old_gen);  // must reset it for other tests

        scope ledger = new ThrowingLedger(
            key_pair, blocks.takeExactly(params.ValidatorCycle), params);
        Hash[] keys;
        assert(ledger.enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 1);
        auto utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == params.ValidatorCycle));

        ledger.throw_in_update_validators = true;
        auto next_block = blocks[$ - 1];
        assertThrown!Exception(ledger.addValidatedBlock(next_block));
        assert(ledger.last_block == blocks[$ - 2]);  // not updated
        utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == params.ValidatorCycle));  // reverted
        assert(ledger.enroll_man.getEnrolledUTXOs(keys));
        assert(keys.length == 1);  // reverted
    }
}

/// throw if the gen block in block storage is different to the configured one
unittest
{
    import agora.common.Serializer;
    import std.conv;

    immutable gen_block_hex = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000A616EC13FA34826266C933B65A05D96F4C31A63F29CA477DCF63EB8C0DAECA7DFACABE8C2569A88E843314D768A7BF47D0919FAA6E11E8A8FDF05A9280107E74000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004617531F2DFAEEA395683F65ED5681C16B0BB83F767AFF02597872CBCDA07AF4B2A914197407E0759085CED981D0790B65B9E6D679DE3212E97F1D95024D10D1978D8A787058C14F005545167710F92E3C108D2EABE4A55805731AE369DE2FC71B10C1651E16D39F39156BA3F2C91925C698DF0683F3A9B489B5F11F6174F93C9FDF003FCCCBD842DF1CE7A144A18F95D21B700F26FA87F6C5ABACE9C956419023E2976EC9175C5269D93B0D266A0277302A6583F06BFBDA6BB22DAC7B6FB5BF910C00B70017B4D4FD401A1C26404078B80E8FF68BD0FE0AAB3F4B1B4D56649EF404F9167A96D199BB3DC2F6DD393E6A35976BCDE1C3A608CCFE4666A5608745B9628404CFBD2A497FFC5534F140F9392DDE0C1844CD3353975562822C3E612AAFC897B5F81C3059E607A3A6DAE0EB78F37515F9E616B1B81302CEF33312239B80DE0EBFDF003812C59722A897D54A04EB86DE77D346C07288FC1114F81F0D3A8FAB9D6403348D14631A046D32061CB729C2161F16A81FBE6C9784F9210C2E16E9BFDC8D0560A97741C0642FE1DBC466B19B807F4DD702D6BC64E8494785E779B224C641FBE60BBF4ADDAC2BCF76C578DC2DA7E14E604306156252A7A51323C0090A7AF26A3817E2C4392725D258A3470A61D5E7AB8027FA37D4EFAEEBD1F1C9E5616A6503DA98D4EABCA2C0987BD097902F33740F7312DB45177EF5BB029DC9680A542D70B11FDF003A4058C8B05200EF9E56BD1E55E93613179D1D9AF9A98791099B34E64F89A604E2D750BA2ED29AE789DDCF0001DB2C4829717F56977A7C038CE0F5CD382BB41089A21B3D312AD46F2EA7BB2987BAC43D3AFC78A24CB0133D365368BC1BCFEA4AA096C76DD65F3128C9CD76C0F4C9FB6B8F879161E1F9DC504982EAF1067B92CB898850F7B2F3CFE55050EC8AF3C4029D6DC231B7F917DEE226A2A19A8B590972FEB4E51745AD41BA03E368C32FC06869B14B907D0C0364A6D1544873824C6936BFDF00337CB08432BD8E4283F46518994E0502E13D1DC02EF43AFFCE66410EB155433EC3DCFBE9A6778900085AF974901545FDE9046B7E43811E91A802146F5D0F5F10806010001FF00A0DB215D000000C5AD08A5507996C7347F88C8A0D5CCA047C9A7D082CB2E9D32CCA26FCCDAAFDC010006FF0040E59C30120000DAE1934864C67FCB27BD872D70991330222591CD83B970EB8A28FF51A6556A55FF0040E59C30120000DAE19364B4145DEE6F56FA30436AB831274F84E00437552C1E603AA9FEF21892FF0040E59C30120000DAE1938A993F5850F50AEE830FF52171DFDF97AF79F7FF43DFE4337E8477D967FF0040E59C30120000DAE193B3FCEC9D4B9484A6CFA867A68F038934B970B7E463C1AE80D007DD36F4FF0040E59C30120000DAE193D9BDB4D6B9D0419BAE3024CC5DDD6BCB930E68036CA019884A69AC7F79FF0040E59C30120000DAE193E9E928AFCFC7591DA28E81B6497ADCE977C5C017B5C8159234D0E5A3B4000008FF002050B1CA2A02009D0238E0A171400BC6D68A9D9B316ACD5109649113A05C284F4296D2B30122F5FF002050B1CA2A02009D0238E0A171400BC6D68A9D9B316ACD5109649113A05C284F4296D2B30122F5FF002050B1CA2A02009D0238E0A171400BC6D68A9D9B316ACD5109649113A05C284F4296D2B30122F5FF002050B1CA2A02009D0238E0A171400BC6D68A9D9B316ACD5109649113A05C284F4296D2B30122F5FF002050B1CA2A02009D0238E0A171400BC6D68A9D9B316ACD5109649113A05C284F4296D2B30122F5FF002050B1CA2A02009D0238E0A171400BC6D68A9D9B316ACD5109649113A05C284F4296D2B30122F5FF002050B1CA2A02009D0238E0A171400BC6D68A9D9B316ACD5109649113A05C284F4296D2B30122F5FF002050B1CA2A02009D0238E0A171400BC6D68A9D9B316ACD5109649113A05C284F4296D2B30122F5010001FF00A0DB215D000000C1AD7626170CE154129019174AC9919AECDF4833EF93774490E4A85B556FA892010001FF00A0DB215D000000C7AD1F93344D2E91ADD8CE1331829648B53A2A2667C9655351F2494EB0639B12010001FF00A0DB215D000000C3AD413C69DC77B8D6C9B58EA0B755BC310485BFA0D0C7CD90A7E27C58A7BC810F0F1F249A96BE6AFDB2B77033331177BC8C9C54159E958DB9A71F64460025AB86422717F7F9F3B692F35F487FCBD87B367B483DE70D99E201B1FAE310BB028E38BC75F96F82A6EBF8C9776AC315FA1DA5E9E1F26AF3BF631385A359E27C12835C7129DB46AEE9C5C1DB3D4E4C713B61D74746823D3A9C30985B7F1AC49BCE14635CF9F0B2D9962D874079EE7C154C7E8C5F99201664459F6A182BCE732AEC0AFE0677F4A407C3B84A30661C4A4DA89ED53DEAE3FFA7B97C37FAAE9C6FB9FE5B7AE4D18FE7609377496975FBC3CDBA97CD3E491E9F78B541ED9894B26624D9C9710D9797202EF1300F4AA3E5FB095B8135AD447F2B078A0A22BE522B1ADD67A0ADCD1B7B4FEFF9BB56708724114962A9769BE95FCD4E7BED82EBDE799D0463219650573483BA9E0F3F25EA621EDF5232775BB006A39510551D11C3B7920A727BC5927F58D11EC16EA0F4BBBDFEE4122D769FE019C83AE4BB8F1D89832F936747DB39190D9AAAF18A9A8584E563C4457225FD2142681AEDAD9CC76B2C236F69F3FE927F58D11EC16EA0F4BBBDFEE4122D769FE019C83AE4BB8F1D89832F936747DB39190D9AAAF18A9A8584E563C4457225FD2142681AEDAD9CC76B2C236F69F3FE927F58D11EC16EA0F4BBBDFEE4122D769FE019C83AE4BB8F1D89832F936747DB39190D9AAAF18A9A8584E563C4457225FD2142681AEDAD9CC76B2C236F69F3FE91AC2FAECA424AC35C7ECB794630CC4B8C2789A742182D462E07FB02B9939B6040239D3C7E037DE2906F9696D4C56CE18C3B386D687D12CF2FD78520F0765D70EAB756C2E11BD33FBCCDC3ABA51D0F4D7853297AF037663F1D45C693CE9DA36DD7D1C4C778B584A18B838DAE59AE147D4C2D3F4CBAD42F67DA36BE1B7944AD8B3C6D701D94CEC9D571C4486906BD0472D3A78560F5F858DE96E18323F83DC175795FA4C4C8B2873703C02647AE14AFA3D5278A2D63B35F2848E14DACE60ACD37816EDFE6949282AE81712A44AF125C12436FF243948A69303F3E5AE794EC3CB8E4738328CA0C405A42499CB840AA201CB6ECC68FF6D53AE6B84D6FA113CB5E1E65C75DD9F56DBD01437B9C1BE45473EF64DA9F67B9E442FFC68D9A57237696E00E66A35F771A9DC8F1288E1970B576DB780FDFF15793C3B1E3322E5F328ABA9C3448969C98CB86F8C301041D0E1B75D153D73CD97FAB1C3A0364F1890333999C83E06D1534E5CE79C36ACF91175CA2BAF5A87DC37D76C7A4D5346E6AB304EC74A616EC13FA34826266C933B65A05D96F4C31A63F29CA477DCF63EB8C0DAECA7DFACABE8C2569A88E843314D768A7BF47D0919FAA6E11E8A8FDF05A9280107E74";

    // hex => bin
    auto block_bytes = gen_block_hex.chunks(2).map!(
        twoDigits => twoDigits.parse!ubyte(16)).array();
    immutable new_gen_block = block_bytes.deserializeFull!(immutable(Block));
    assert(new_gen_block != GenesisBlock);

    NodeConfig config;
    config.is_validator = true;

    try
    {
        scope ledger = new TestLedger(config, [new_gen_block]);
        assert(0);
    }
    catch (Exception ex)
    {
        assert(ex.msg == "Genesis block loaded from disk is different from the one in the config file");
    }

    auto old_gen = &GenesisBlock();
    setGenesisBlock(&new_gen_block);
    scope (exit) setGenesisBlock(old_gen);  // must reset it for other tests
    scope ledger = new TestLedger(config, [new_gen_block]);  // will not fail
}
