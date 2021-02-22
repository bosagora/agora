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
import agora.common.ManagedDatabase;
import agora.common.Serializer;
import agora.common.Set;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.protocol.Data;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.state.UTXODB;
import agora.consensus.EnrollmentManager;
import agora.consensus.Fee;
import agora.consensus.SlashPolicy;
import agora.consensus.validation;
import agora.consensus.validation.Block : validateBlockTimestamp;
import agora.consensus.Fee;
import agora.crypto.Hash;
import agora.network.Clock;
import agora.node.BlockStorage;
import agora.node.TransactionPool;
import agora.script.Lock;
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

import core.time : Duration, seconds;

mixin AddLogger!();

version (unittest)
{
    //import agora.consensus.data.genesis.Test;
    import agora.utils.Test;
}

/// Ditto
public class Ledger
{
    import agora.crypto.ECC : Point;

    /// data storage for all the blocks
    private IBlockStorage storage;

    /// Pool of transactions to pick from when generating blocks
    private TransactionPool pool;

    /// TX Hashes Ledger encountered but dont have in the pool
    private Set!Hash unknown_txs;

    /// The last block in the ledger
    private Block last_block;

    /// UTXO set
    private UTXOSet utxo_set;

    // Clock instance
    private Clock clock;

    /// Enrollment manager
    private EnrollmentManager enroll_man;

    /// Property for Enrollment manager
    @property public EnrollmentManager enrollment_manager() @safe
    {
        return this.enroll_man;
    }

    /// Slashing policy manager
    private SlashPolicy slash_man;

    /// If not null call this delegate
    /// A block was externalized
    private void delegate (const ref Block, bool) @safe onAcceptedBlock;

    /// Parameters for consensus-critical constants
    private immutable(ConsensusParams) params;

    /// Transaction stats
    private TxStats tx_stats;

    /// Block stats
    private BlockStats block_stats;

    /// The checker of transaction data payload
    private FeeManager fee_man;

    /// The new block timestamp has to be greater than the previous block timestamp,
    /// but less than current time + block_timestamp_tolerance
    public Duration block_timestamp_tolerance;

    /***************************************************************************

        Constructor

        Params:
            params = the consensus-critical constants
            utxo_set = the set of unspent outputs
            storage = the block storage
            enroll_man = the enrollmentManager
            pool = the transaction pool
            fee_man = the checker of data payload
            clock = the clock instance
            block_timestamp_tolerance = the proposed block timestamp should be less
                than curr_timestamp + block_timestamp_tolerance
            onAcceptedBlock = optional delegate to call
                              when a block was added to the ledger

    ***************************************************************************/

    public this (immutable(ConsensusParams) params,
        UTXOSet utxo_set, IBlockStorage storage,
        EnrollmentManager enroll_man, TransactionPool pool,
        FeeManager fee_man, Clock clock,
        Duration block_timestamp_tolerance = 60.seconds,
        void delegate (const ref Block, bool) @safe onAcceptedBlock = null)
    {
        this.params = params;
        this.utxo_set = utxo_set;
        this.storage = storage;
        this.enroll_man = enroll_man;
        this.slash_man = new SlashPolicy(this.enroll_man, params);
        this.pool = pool;
        this.onAcceptedBlock = onAcceptedBlock;
        this.fee_man = fee_man;
        this.clock = clock;
        this.block_timestamp_tolerance = block_timestamp_tolerance;
        this.storage.load(params.Genesis);

        // ensure latest checksum can be read
        this.last_block = this.storage.readLastBlock();
        log.info("Last known block: #{} ({})", this.last_block.header.height,
                 this.last_block.header.hashFull());
        this.block_stats.setMetricTo!"agora_block_height_counter"(
            this.last_block.header.height.value);

        Block gen_block = this.storage.readBlock(Height(0));
        if (gen_block != cast()params.Genesis)
            throw new Exception("Genesis block loaded from disk is " ~
                "different from the one in the config file");

        if (this.utxo_set.length == 0)
        {
            // clear validator set
            this.enroll_man.removeAllValidators();

            foreach (height; 0 .. this.last_block.header.height + 1)
            {
                Block block = this.storage.readBlock(Height(height));

                // Make sure our data on disk is valid
                if (auto fail_reason = this.validateBlock(block))
                    throw new Exception(
                        "A block loaded from disk is invalid: " ~
                        fail_reason);

                this.addValidatedBlock(block);
            }
        }
        else if (this.enroll_man.validatorCount() == 0)
        {
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
                Block block = this.storage.readBlock(block_idx);
                this.updateValidatorSet(block);
            }
        }

        Utils.getCollectorRegistry().addCollector(&this.collectTxStats);
        Utils.getCollectorRegistry().addCollector(&this.collectBlockStats);
    }

    /***************************************************************************

        Returns the last block in the `Ledger`

        Returns:
            last block in the `Ledger`

    ***************************************************************************/

    public const(Block) getLastBlock () const @safe @nogc nothrow pure
    {
        return last_block;
    }

    /***************************************************************************

        Returns:
            The highest block height known to this Ledger

    ***************************************************************************/

    public Height getBlockHeight () @safe nothrow
    {
        return this.last_block.header.height;
    }

    version (unittest)
    private bool externalize (ConsensusData data,
        string file = __FILE__, size_t line = __LINE__)
        @trusted
    {
        import agora.utils.Test : WK;

        Hash random_seed = this.getExternalizedRandomSeed(this.getBlockHeight(),
            data.missing_validators);

        auto next_block = Height(this.last_block.header.height + 1);
        KeyPair[] public_keys = iota(0, this.enroll_man.getCountOfValidators(next_block))
            .map!(idx => PublicKey(this.enroll_man.getValidatorAtIndex(next_block, idx)[]))
            .map!(K => WK.Keys[K])
            .array();

        Transaction[] externalized_tx_set;
        if (auto fail_reason = this.getValidTXSet(data, externalized_tx_set))
        {
            log.info("Missing TXs, can not create new block at Height {} : {}",
                this.getBlockHeight() + 1, prettify(data));
            return false;
        }

        const block = makeNewTestBlock(this.last_block,
            externalized_tx_set, random_seed, data.enrolls,
            data.missing_validators, public_keys,
            (PublicKey pubkey)
            {
                return 0;   // This is the number of re-enrollments (currently always 0 in these tests)
            },
            data.timestamp);
        return this.acceptBlock(block, file, line);
    }

    /***************************************************************************

        Add a block to the ledger.

        If the block fails verification, it is not added to the ledger.

        Params:
            block = the block to add

        Returns:
            true if the block was accepted

    ***************************************************************************/

    public bool acceptBlock (const ref Block block,
        string file = __FILE__, size_t line = __LINE__) @safe
    {
        if (auto fail_reason = this.validateBlock(block, file, line))
        {
            log.trace("Rejected block: {}: {}", fail_reason, block.prettify());
            return false;
        }

        const old_count = this.enroll_man.validatorCount();

        this.storage.saveBlock(block);
        this.addValidatedBlock(block);

        const new_count = this.enroll_man.validatorCount();
        // there was a change in the active validator set
        const bool validators_changed = block.header.enrollments.length > 0
            || new_count != old_count;
        if (this.onAcceptedBlock !is null)
            this.onAcceptedBlock(block, validators_changed);

        this.block_stats.setMetricTo!"agora_block_enrollments_gauge"(new_count);
        this.block_stats.increaseMetricBy!"agora_block_txs_amount_total"(
            getUnspentAmount(block.txs));
        this.block_stats.increaseMetricBy!"agora_block_txs_total"(
            block.txs.length);
        this.block_stats.increaseMetricBy!"agora_block_externalized_total"(1);
        this.block_stats.setMetricTo!"agora_block_height_counter"(
            block.header.height.value);
        return true;
    }

    /***************************************************************************

        Update the Schnorr multi-signature for an externalized block
        in the Ledger.

        Params:
            header = block header to be updated

        Returns:
            true if the block was updated

    ***************************************************************************/

    public void updateBlockMultiSig (const ref BlockHeader header) @safe
    {
        this.storage.updateBlockSig(header.height, header.hashFull(),
            header.signature, header.validators);

        if (header.height == this.last_block.header.height)
            this.last_block = this.storage.readLastBlock();
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
        const Height expected_height = this.getBlockHeight() + 1;
        string reason;

        if (tx.type == TxType.Coinbase ||
            (reason = tx.isInvalidReason(this.utxo_set.getUTXOFinder(),
                expected_height, &this.fee_man.check)) !is null ||
            !this.pool.add(tx))
        {
            log.info("Rejected tx. Reason: {}. Tx: {}",
                reason !is null ? reason : "double-spend/coinbase", tx);
            this.tx_stats.increaseMetricBy!"agora_transactions_rejected_total"(1);
            return false;
        }
        // If we were looking for this TX, stop
        this.unknown_txs.remove(tx.hashFull());

        this.tx_stats.increaseMetricBy!"agora_transactions_accepted_total"(1);
        return true;
    }

    /***************************************************************************

        Add a validated block to the Ledger.

        This will add all of the block's outputs to the UTXO set, as well as
        any enrollments that may be present in the block to the validator set.

        If not null call the `onAcceptedBlock` delegate.

        Params:
            block = the block to add

    ***************************************************************************/

    private void addValidatedBlock (const ref Block block) @safe
    {
        // Keep track of the fees generated by this block, before updating the
        // validator set
        this.accumulateFees(block);

        ManagedDatabase.beginBatch();
        {
            // rollback on failure within the scope of the db transactions
            scope (failure) ManagedDatabase.rollback();
            this.updateUTXOSet(block);
            this.updateValidatorSet(block);
            ManagedDatabase.commitBatch();
        }

        // Prepare maps for next block with maybe new enrollments
        log.trace("Storing active validators for next block using height {}.", block.header.height);
        this.enroll_man.updateValidatorIndexMaps(Height(block.header.height + 1));

        // Clear the unknown TXs every round (clear() is not @safe)
        this.unknown_txs = Set!Hash.init;

        // Update the known "last block"
        this.last_block = deserializeFull!Block(serializeFull(block));
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
        block.txs.each!(tx => this.utxo_set.updateUTXOCache(tx, height,
            this.params.CommonsBudgetAddress));

        // remove the TXs from the Pool
        block.txs.each!(tx => this.pool.remove(tx));

        this.updateSlashedUTXOSet(block);
    }

    /***************************************************************************

        Update the UTXOs of validators that are to be slashed

        Params:
            block = the block to update the UTXO set with

    ***************************************************************************/

    protected void updateSlashedUTXOSet (const ref Block block) @safe
    {
        Hash[] validator_utxos;
        this.slash_man.getMissingValidatorsUTXOs(validator_utxos,
            block.header.missing_validators);
        foreach (utxo; validator_utxos)
        {
            UTXO utxo_value;
            if (!this.utxo_set.peekUTXO(utxo, utxo_value))
                assert(0, "UTXO for the slashed validator not found!");

            auto remain_amount = Amount(utxo_value.output.value);
            remain_amount.sub(this.slash_man.penalty_amount);
            Transaction slashing_tx =
            {
                TxType.Payment,
                inputs: [Input(utxo)],
                outputs: [
                    Output(this.slash_man.penalty_amount,
                        this.slash_man.penalty_address),
                    Output(remain_amount, utxo_value.output.address),
                ],
            };
            this.utxo_set.updateUTXOCache(slashing_tx, block.header.height,
                this.params.CommonsBudgetAddress);
        }
    }

    /***************************************************************************

        Update the active validator set

        Params:
            block = the block to update the Validator set with

    ***************************************************************************/

    protected void updateValidatorSet (const ref Block block) @safe
    {
        this.enroll_man.clearExpiredValidators(block.header.height);
        PublicKey pubkey = this.enroll_man.getEnrollmentPublicKey();
        UTXO[Hash] utxos = this.utxo_set.getUTXOs(pubkey);
        foreach (idx, ref enrollment; block.header.enrollments)
        {
            UTXO utxo;
            if (!this.utxo_set.peekUTXO(enrollment.utxo_key, utxo))
                assert(0);

            if (auto r = this.enroll_man.addValidator(enrollment, utxo.output.address,
                block.header.height, &this.utxo_set.peekUTXO, utxos))
            {
                log.fatal("Error while adding a new validator: {}", r);
                log.fatal("Enrollment #{}: {}", idx, enrollment);
                log.fatal("Validated block: {}", block);
                assert(0);
            }
        }

        this.updateSlashedValidatorSet(block);
    }

    /***************************************************************************

        Update the validators that are to be slashed

        Params:
            block = the block to update the Validator set with

    ***************************************************************************/

    protected void updateSlashedValidatorSet (const ref Block block) @safe
    {
        if (block.header.height == 0)
            return;

        Hash[] validators_utxos;
        this.slash_man.getMissingValidatorsUTXOs(validators_utxos,
            block.header.missing_validators);
        foreach (utxo; validators_utxos)
        {
            this.enroll_man.unenrollValidator(utxo);
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
        data.timestamp = max(clock.networkTime(), this.last_block.header.timestamp + 1);
        log.trace("Going to nominate current timestamp [{}] or newer", clock.networkTime());
        const next_height = this.getBlockHeight() + 1;
        auto utxo_finder = this.utxo_set.getUTXOFinder();

        this.enroll_man.getEnrollments(data.enrolls, this.getBlockHeight(),
                                                    &this.utxo_set.peekUTXO);

        // get information about validators not revealing a preimage timely
        this.slash_man.getMissingValidators(data.missing_validators,
            this.getBlockHeight());

        Amount tot_fee, tot_data_fee;
        foreach (ref Hash hash, ref Transaction tx; this.pool)
        {
            scope checkAndAcc = (in Transaction tx, Amount sum_unspent) {
                const err = this.fee_man.check(tx, sum_unspent);
                if (!err)
                {
                    tot_fee.add(sum_unspent);
                    tot_data_fee.add(
                        this.fee_man.getDataFee(tx.payload.data.length));
                }
                return err;
            };

            if (auto reason = tx.isInvalidReason(utxo_finder, next_height,
                    checkAndAcc))
                log.trace("Rejected invalid ('{}') tx: {}", reason, tx);
            else
                data.tx_set ~= hash;

            if (data.tx_set.length >= max_txs)
            {
                data.tx_set.sort();
                return;
            }
        }

        const pre_cb_len = data.tx_set.length;
        // Dont append a CB TX to an empty TX set
        if (pre_cb_len > 0)
            data.tx_set ~= this.getCoinbaseTX(tot_fee, tot_data_fee,
                data.missing_validators).map!(tx => tx.hashFull()).array;
        // No more than 1 CB per block
        assert(data.tx_set.length - pre_cb_len <= 1);
    }

    /***************************************************************************

        Create the Coinbase TX for this nomination round and append it to the
        tx_set

        Params:
            tot_fee = Total fee amount (incl. data)
            tot_data_fee = Total data fee amount
            missing_validators = MPVs

        Returns:
            List of expected Coinbase TXs

    ***************************************************************************/

    public Transaction[] getCoinbaseTX (Amount tot_fee, Amount tot_data_fee,
        const ref uint[] missing_validators) nothrow @safe
    {
        const next_height = this.getBlockHeight() + 1;

        UTXO[] stakes;
        this.enroll_man.getValidatorStakes(&this.utxo_set.peekUTXO, stakes,
            missing_validators);
        const commons_fee = this.fee_man.getCommonsBudgetFee(tot_fee,
            tot_data_fee, stakes);

        // An empty coinbase TX
        auto coinbase_tx = Transaction(
            TxType.Coinbase,
            [Input(next_height)],
            [],
        );

        // pay the commons budget
        if (commons_fee > Amount(0))
            coinbase_tx.outputs ~= Output(commons_fee,
                this.params.CommonsBudgetAddress);

        // pay the validator for the past blocks
        if (auto payouts = this.fee_man.getAccumulatedFees(next_height))
            foreach (pair; payouts.byKeyValue())
                if (pair.value > Amount(0))
                    coinbase_tx.outputs ~= Output(pair.value, pair.key);

        return coinbase_tx.outputs.length > 0 ? [coinbase_tx] : [];
    }

    /// Error message describing the reason of validation failure
    public static enum InvalidConsensusDataReason : string
    {
        NoTransactions = "Transaction set doesn't contain any transactions",
        NotEnoughValidators = "Enrollment: Insufficient number of active validators",
        MayBeValid = "May be valid",
        OnlyCoinbaseTX = "Transaction set only includes a Coinbase transaction",
    }

    /***************************************************************************

        Create the Coinbase TX for this nomination round

        Params:
            tx_set = Transaction set to generate the CoinBase TX for
            missing_validators = MPVs

        Returns:
            List of expected Coinbase TXs

    ***************************************************************************/

    public Transaction[] getCoinbaseTX (const ref Transaction[] tx_set,
        const ref uint[] missing_validators) nothrow @safe
    {
        Amount tot_fee, tot_data_fee;
        this.fee_man.getTXSetFees(tx_set, &this.utxo_set.peekUTXO, tot_fee,
            tot_data_fee);
        return this.getCoinbaseTX(tot_fee, tot_data_fee, missing_validators);
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
        const expect_height = this.getBlockHeight() + 1;
        auto utxo_finder = this.utxo_set.getUTXOFinder();

        if (!data.tx_set.length)
            return InvalidConsensusDataReason.NoTransactions;

        Transaction[] tx_set;
        if (auto fail_reason = this.getValidTXSet(data, tx_set))
            return fail_reason;

        size_t active_enrollments = enroll_man.getValidatorCount(expect_height);
        assert(active_enrollments >= data.missing_validators.length);
        active_enrollments -= data.missing_validators.length;

        if (data.enrolls.length + active_enrollments < Enrollment.MinValidatorCount)
            return InvalidConsensusDataReason.NotEnoughValidators;

        foreach (const ref enroll; data.enrolls)
        {
            UTXO utxo_value;
            assert(this.utxo_set.peekUTXO(enroll.utxo_key, utxo_value));
            if (auto fail_reason = this.enroll_man.isInvalidCandidateReason(
                enroll, utxo_value.output.address, expect_height, utxo_finder))
                return fail_reason;
        }

        return validateBlockTimestamp(last_block.header.timestamp, data.timestamp,
            clock.networkTime(), block_timestamp_tolerance);
    }

    /***************************************************************************

        Check whether the slashing data is valid.

        Params:
            data = consensus data

        Returns:
            the error message if validation failed, otherwise null

    ***************************************************************************/

    public string validateSlashingData (in ConsensusData data) @safe
    {
        if (checkSelfSlashing(data))
        {
            log.fatal("The node is slashing itself.");
            assert(0);
        }

        return this.slash_man.isInvalidPreimageRootReason(this.getBlockHeight(),
                data.missing_validators);
    }

    /***************************************************************************

        Check if the consensus data has the information that is slashing
        a node itself

        Params:
            data = consensus data

        Returns:
            true if the consensus data has the information that is slashing
            a node itself.

    ***************************************************************************/

    public bool checkSelfSlashing(in ConsensusData data) @safe nothrow
    {
        auto enroll_index = this.enroll_man.getIndexOfEnrollment();
        if (enroll_index != ulong.max &&
            !data.missing_validators.find(enroll_index).empty)
        {
            return true;
        }
        return false;
    }

    /***************************************************************************

        Check whether the block is valid.

        Params:
            block = the block to check

        Returns:
            the error message if block validation failed, otherwise null

    ***************************************************************************/

    public string validateBlock (const ref Block block,
        string file = __FILE__, size_t line = __LINE__) nothrow @safe
    {
        if (block.header.height == 0)
            return block.isGenesisBlockInvalidReason();

        size_t active_enrollments = enroll_man.getValidatorCount(
                block.header.height);

        return block.isInvalidReason(this.last_block.header.height,
            this.last_block.header.hashFull,
            this.utxo_set.getUTXOFinder(),
            &this.fee_man.check,
            this.enroll_man.getEnrollmentFinder(),
            this.enroll_man.getValidatorCount(block.header.height),
            this.enroll_man.getCountOfValidators(block.header.height),
            this.getRandomSeed(),
            &this.enroll_man.getValidatorAtIndex,
            (const ref Point key, const Height height) @safe nothrow
            {
                const PK = PublicKey(key[]);
                return this.enroll_man.getCommitmentNonce(PK, block.header.height);
            },
            this.last_block.header.timestamp,
            cast(ulong) this.clock.networkTime(),
            block_timestamp_tolerance,
            &this.getCoinbaseTX,
            file, line);
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

        // Call to `Height.value` to work around
        // https://issues.dlang.org/show_bug.cgi?id=21583
        return iota(start_height.value, this.getBlockHeight() + 1)
            .map!(idx => this.storage.readBlock(Height(idx)));
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

    /***************************************************************************

        Get the random seed reduced from the preimages of validators
        except the provided 'missing_validators'.

        Params:
            height = the desired block height to look up the hash for
            missing_validators = the validators that did not reveal their
                preimages for the height

        Returns:
            the random seed if there are one or more valid preimages,
            otherwise Hash.init.

    ***************************************************************************/

    public Hash getExternalizedRandomSeed (in Height height,
        const ref uint[] missing_validators) @safe nothrow
    {
        return this.slash_man.getExternalizedRandomSeed(height,
            missing_validators);
    }

    /***************************************************************************

        Calculate and accumulate fees that will be paid to Validators from this
        block

        Params:
            block = new block

    ***************************************************************************/

    public void accumulateFees (const ref Block block) nothrow @safe
    {
        if (block.header.height == Height(0))
        {
            this.fee_man.clearAccumulatedFees();
            return;
        }

        UTXO[] stakes;
        this.enroll_man.getValidatorStakes(&this.utxo_set.peekUTXO, stakes,
            block.header.missing_validators);
        this.fee_man.accumulateFees(block, stakes, &this.utxo_set.peekUTXO);
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
        return this.pool.getTransactionByHash(hash);
    }

    /***************************************************************************

        Get the valid TX set that `data` is representing

        Params:
            data = consensus value
            tx_set = buffer to write the found TXs

        Returns:
            `null` if node can build a valid TX set, a string explaining
            the reason otherwise.

    ***************************************************************************/

    public string getValidTXSet (ConsensusData data, ref Transaction[]
        tx_set) @safe nothrow
    {
        const expect_height = this.getBlockHeight() + 1;
        auto utxo_finder = this.utxo_set.getUTXOFinder();
        bool[Hash] local_unknown_txs;

        Amount tot_fee, tot_data_fee;
        scope checkAndAcc = (in Transaction tx, Amount sum_unspent) {
            const err = this.fee_man.check(tx, sum_unspent);
            if (!err && tx.type != TxType.Coinbase)
            {
                tot_fee.add(sum_unspent);
                tot_data_fee.add(
                    this.fee_man.getDataFee(tx.payload.data.length));
            }
            return err;
        };

        foreach (const ref tx_hash; data.tx_set)
        {
            auto tx = this.getTransactionByHash(tx_hash);
            if (tx == Transaction.init)
                local_unknown_txs[tx_hash] = true;
            else if (auto fail_reason = tx.isInvalidReason(utxo_finder,
                expect_height, checkAndAcc))
                return fail_reason;
            else
                tx_set ~= tx;
        }

        auto expected_cb_txs = this.getCoinbaseTX(tot_fee,
            tot_data_fee, data.missing_validators);
        auto excepted_cb_hashes = expected_cb_txs.map!(tx => tx.hashFull());
        assert(expected_cb_txs.length <= 1);

        // Because CB TXs are never in the pool, they will always end up in
        // local_unknown_txs. There should be atleast expected_cb_txs.length
        // number of unknown txs.
        if (!expected_cb_txs.empty()
                && local_unknown_txs.length <= expected_cb_txs.length)
            foreach (tx_hash; excepted_cb_hashes)
                if (tx_hash !in local_unknown_txs)
                    return "Invalid Coinbase transaction";

        // If we met our CB expectations, remove them.
        excepted_cb_hashes.each!(tx => local_unknown_txs.remove(tx));
        expected_cb_txs.each!(tx => tx_set ~= tx);

        if (local_unknown_txs.length > 0)
        {
            local_unknown_txs.byKey.each!(tx => this.unknown_txs.put(tx));
            return InvalidConsensusDataReason.MayBeValid;
        }

        // Check if we have any real TXs
        foreach (tx; tx_set)
            if (tx.type != TxType.Coinbase)
                return null;
        return InvalidConsensusDataReason.OnlyCoinbaseTX;
    }

    /***************************************************************************

        Get a set of TX Hashes that Ledger is missing

        Returns:
            set of TX Hashes that Ledger is missing

    ***************************************************************************/

    public Set!Hash getUnknownTXHashes () @safe nothrow
    {
        return this.unknown_txs;
    }

    /***************************************************************************

        Generate the random seed reduced from the preimages for the current
        height

        Returns:
            the random seed if there are one or more valid preimages,
            otherwise Hash.init.

    ***************************************************************************/

    public Hash getRandomSeed() nothrow @safe
    {
        return this.slash_man.getRandomSeed(this.last_block.header.height);
    }
}

/// Note: these unittests historically assume a block always contains
/// 8 transactions - hence the use of `TxsInTestBlock` appearing everywhere.
version (unittest)
{
    import core.stdc.time : time;

    /// simulate block creation as if a nomination and externalize round completed
    private void forceCreateBlock (Ledger ledger, ulong max_txs = Block.TxsInTestBlock,
        string file = __FILE__, size_t line = __LINE__)
    {
        ConsensusData data;
        ledger.prepareNominatingSet(data, max_txs);
        assert(data.tx_set.length >= max_txs);
        if (!ledger.externalize(data, file, line))
        {
            assert(0, format!"Failure in unit test. Block %s should have been externalized!"(ledger.getBlockHeight() + 1));
        }
    }

    /// A `Ledger` with sensible defaults for `unittest` blocks
    private final class TestLedger : Ledger
    {
        public this (KeyPair key_pair,
            const(Block)[] blocks = null,
            immutable(ConsensusParams) params_ = null,
            Duration block_timestamp_tolerance_dur = 600.seconds,
            Clock mock_clock = new MockClock(time(null)))
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
                new TransactionPool(":memory:"),
                new FeeManager(":memory:", params),
                mock_clock,
                block_timestamp_tolerance_dur);
        }

        ///
        protected override void updateSlashedUTXOSet (const ref Block block)
            @safe
        {
            return;
        }

        ///
        protected override void updateSlashedValidatorSet (const ref Block block)
            @safe
        {
            return;
        }

        ///
        public override Hash getExternalizedRandomSeed (in Height height,
            const ref uint[] missing_validators) @safe nothrow
        {
            return getTestRandomSeed();
        }

        ///
        public override Hash getRandomSeed() nothrow @safe
        {
            return getTestRandomSeed();
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

/// basic block verification
unittest
{
    scope ledger = new TestLedger(WK.Keys.NODE2);

    Block invalid_block;  // default-initialized should be invalid
    assert(!ledger.acceptBlock(invalid_block));

    auto txs = genesisSpendable().map!(txb => txb.sign()).array();
    const block = makeNewTestBlock(ledger.params.Genesis, txs);
    assert(ledger.acceptBlock(block));
}

/// Situation: Ledger is constructed with blocks present in storage
/// Expectation: The UTXOSet is populated with all up-to-date UTXOs
unittest
{
    import agora.consensus.data.genesis.Test;

    // Cannot use literals: https://issues.dlang.org/show_bug.cgi?id=20938
    const(Block)[] blocks = [ GenesisBlock ];
    auto txs = GenesisBlock.spendable().map!(txb => txb.sign()).array();
    blocks ~= makeNewTestBlock(blocks[$ - 1], txs);
    // Make 3 more blocks to put in storage
    foreach (idx; 2 .. 5)
    {
        txs = blocks[$ - 1].spendable().map!(txb => txb.sign()).array();
        blocks ~= makeNewTestBlock(blocks[$ - 1], txs);
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

unittest
{
    import agora.consensus.data.genesis.Test;
    ConsensusData data;
    auto genesis_ts = GenesisBlock.header.timestamp;
    MockClock mock_clock = new MockClock(time(null));

    auto getLedger (Clock clock)
    {
        auto ledger = new TestLedger(WK.Keys.NODE2, null, null, 600.seconds, clock);
        auto txs = genesisSpendable().enumerate()
            .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
            .array();
        txs.each!(tx => assert(ledger.acceptTransaction(tx)));
        return ledger;
    }

    // no matter how far the clock is ahead, we still accept blocks as long as
    // the clock has a time greater than the time in the latest block header
    auto ledger = getLedger(mock_clock);
    ledger.prepareNominatingSet(data, Block.TxsInTestBlock);
    data.timestamp = genesis_ts + 1;
    mock_clock.setTime(genesis_ts + 2000);
    assert(ledger.externalize(data));

    // if the clock is behind of the timestamp of the new block and
    // ahead of the timestamp of the last block and
    // and within the tolerance interval,
    // then we accept block
    ledger = getLedger(mock_clock);
    data.timestamp = genesis_ts + 1000;
    mock_clock.setTime(genesis_ts + 500);
    assert(ledger.externalize(data));

    // if the clock is behind of the timestamp of the new block and
    // ahead of the timestamp of the last block and
    // and NOT within the tolerance interval,
    // then we reject block
    ledger = getLedger(mock_clock);
    data.timestamp = genesis_ts + 1000;
    mock_clock.setTime(genesis_ts + 100);
    assert(!ledger.externalize(data));
    // if the time passes by and now we are within the tolerance interval, then
    // we will accept block
    mock_clock.setTime(genesis_ts + 900);
    assert(ledger.externalize(data));

    // if the clock is behind of the timestamp of the latest accepted block, then
    // we reject the block regardless of the current time
    ledger = getLedger(mock_clock);
    data.timestamp = genesis_ts -1;
    mock_clock.setTime(genesis_ts + 100);
    assert(!ledger.externalize(data));
}

// Return Genesis block plus 'count' number of blocks
version (unittest)
private immutable(Block)[] genBlocksToIndex (
    size_t count, scope immutable(ConsensusParams) params)
{
    const(Block)[] blocks = [ params.Genesis ];

    foreach (_; 0 .. count)
    {
        auto txs = blocks[$ - 1].spendable().map!(txb => txb.sign());

        auto cycle = blocks[$ - 1].header.height / params.ValidatorCycle;
        blocks ~= makeNewTestBlock(blocks[$ - 1], txs);
    }

    return blocks.assumeUnique;
}

/// test enrollments in the genesis block
unittest
{
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
        const blocks = genBlocksToIndex(ValidatorCycle - 1, params);
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
        const blocks = genBlocksToIndex(ValidatorCycle, params);
        // Enrollment: Insufficient number of active validators
        assertThrown!Exception(new TestLedger(WK.Keys.A, blocks, params));
    }
}

/// test atomicity of adding blocks and rolling back
unittest
{
    import std.conv;
    import core.stdc.time : time;

    static class ThrowingLedger : Ledger
    {
        bool throw_in_update_utxo;
        bool throw_in_update_validators;

        public this (KeyPair kp, const(Block)[] blocks, immutable(ConsensusParams) params)
        {
            super(params, new UTXOSet(":memory:"),
                new MemBlockStorage(blocks),
                new EnrollmentManager(":memory:", kp, params),
                new TransactionPool(":memory:"),
                new FeeManager(),
                new MockClock(time(null)));
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

        ///
        public override Hash getExternalizedRandomSeed (in Height height,
            const ref uint[] missing_validators) @safe nothrow
        {
            return getTestRandomSeed();
        }

        ///
        public override Hash getRandomSeed() nothrow @safe
        {
            return getTestRandomSeed();
        }
    }

    const params = new immutable(ConsensusParams)();

    // normal test: UTXO set and Validator set updated
    {
        auto key_pair = KeyPair.random();
        const blocks = genBlocksToIndex(params.ValidatorCycle, params);
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
        const blocks = genBlocksToIndex(params.ValidatorCycle, params);
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
        const blocks = genBlocksToIndex(params.ValidatorCycle, params);
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
    import agora.consensus.data.genesis.Test;
    import agora.consensus.data.genesis.Coinnet : CoinGenesis = GenesisBlock;

    // ConsensusParams is instantiated by default with the test genesis block
    immutable params = new immutable(ConsensusParams)();
    assert(CoinGenesis != params.Genesis);

    try
    {
        scope ledger = new TestLedger(WK.Keys.A, [CoinGenesis], params);
        assert(0);
    }
    catch (Exception ex)
    {
        assert(ex.msg == "Genesis block loaded from disk is different from the one in the config file");
    }

    immutable good_params = new immutable(ConsensusParams)(CoinGenesis, WK.Keys.CommonsBudget.address);
    // will not fail
    scope ledger = new TestLedger(WK.Keys.A, [CoinGenesis], good_params);
    // Neither will the default
    scope other_ledger = new TestLedger(WK.Keys.A, [CoinGenesis]);
}

unittest
{
    scope ledger = new TestLedger(WK.Keys.NODE2);
    scope fee_man = new FeeManager();

    // Generate payment transactions to the first 8 well-known keypairs
    auto txs = genesisSpendable().enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array;
    txs.each!(tx => assert(ledger.acceptTransaction(tx)));
    ledger.forceCreateBlock();
    assert(ledger.getBlockHeight() == 1);

    // Create data with nomal size
    ubyte[] data;
    data.length = 64;
    foreach (idx; 0 .. data.length)
        data[idx] = cast(ubyte)(idx % 256);

    // Calculate fee
    Amount data_fee = fee_man.getDataFee(data.length);

    // Generate a block with data stored transactions
    txs = txs.enumerate()
        .map!(en => TxBuilder(en.value)
              .deduct(data_fee)
              .sign(TxType.Payment, data))
              .array;
    txs.each!(tx => assert(ledger.acceptTransaction(tx)));
    ledger.forceCreateBlock();
    assert(ledger.getBlockHeight() == 2);
    auto blocks = ledger.getBlocksFrom(Height(0)).take(10).array;
    assert(blocks.length == 3);
    assert(blocks[2].header.height == 2);

    auto not_coinbase_txs = blocks[2].txs.filter!(tx =>
        tx.type != TxType.Coinbase).array;
    foreach (ref tx; not_coinbase_txs)
    {
        assert(tx.type == TxType.Payment);
        assert(tx.outputs.length > 0);
        assert(tx.payload.data == data);
    }

    // Generate a block to reuse transactions used for data storage
    txs = txs.enumerate()
        .map!(en => TxBuilder(en.value)
              .refund(WK.Keys[Block.TxsInTestBlock + en.index].address)
              .sign())
              .array;
    txs.each!(tx => assert(ledger.acceptTransaction(tx)));
    ledger.forceCreateBlock();
    assert(ledger.getBlockHeight() == 3);
    blocks = ledger.getBlocksFrom(Height(0)).take(10).array;
    assert(blocks.length == 4);
    assert(blocks[3].header.height == 3);
}

// create slashing data and check validity for that
unittest
{
    import agora.consensus.data.genesis.Test;
    import agora.consensus.PreImage;
    import agora.crypto.Schnorr;

    auto params = new immutable(ConsensusParams)(10);
    const(Block)[] blocks = [ GenesisBlock ];
    scope ledger = new TestLedger(WK.Keys.NODE2, blocks, params);

    Transaction[] genTransactions (Transaction[] txs)
    {
        return txs.enumerate()
            .map!(en => TxBuilder(en.value).refund(WK.Keys[en.index].address)
                .sign())
            .array;
    }

    Transaction[] genGeneralBlock (Transaction[] txs,
        string file = __FILE__, size_t line = __LINE__)
    {
        auto new_txs = genTransactions(txs);
        new_txs.each!(tx => assert(ledger.acceptTransaction(tx)));
        ledger.forceCreateBlock(Block.TxsInTestBlock, file, line);
        return new_txs;
    }

    // generate payment transaction to the first 8 well-known keypairs
    auto genesis_txs = genesisSpendable().array;
    auto txs = genesis_txs[0 .. 4].enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign()).array;
    txs ~= genesis_txs[4 .. 8].enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign()).array;
    txs.each!(tx => assert(ledger.acceptTransaction(tx)));
    ledger.forceCreateBlock();
    assert(ledger.getBlockHeight() == 1);

    // generate a block with only freezing transactions
    auto new_txs = txs[0 .. 4].enumerate()
        .map!(en => TxBuilder(en.value).refund(WK.Keys[en.index].address)
            .sign(TxType.Freeze)).array;
    new_txs ~= txs[4 .. 7].enumerate()
        .map!(en => TxBuilder(en.value).refund(WK.Keys[en.index].address).sign())
        .array;
    new_txs ~= TxBuilder(txs[$ - 1]).split(WK.Keys[0].address.repeat(8)).sign();
    new_txs.each!(tx => assert(ledger.acceptTransaction(tx)));
    ledger.forceCreateBlock();
    assert(ledger.getBlockHeight() == 2);

    // UTXOs for enrollments
    Hash[] utxos = [
        UTXO.getHash(hashFull(new_txs[0]), 0),
        UTXO.getHash(hashFull(new_txs[1]), 0),
        UTXO.getHash(hashFull(new_txs[2]), 0),
        UTXO.getHash(hashFull(new_txs[3]), 0)
    ];

    new_txs = iota(new_txs[$ - 1].outputs.length).enumerate
        .map!(en => TxBuilder(new_txs[$ - 1], cast(uint)en.index)
            .refund(WK.Keys[en.index].address).sign())
        .array;
    new_txs.each!(tx => assert(ledger.acceptTransaction(tx)));
    ledger.forceCreateBlock();
    assert(ledger.getBlockHeight() == 3);

    foreach (height; 4 .. 10)
    {
        new_txs = genGeneralBlock(new_txs);
        assert(ledger.getBlockHeight() == Height(height));
    }

    // add four new enrollments
    Enrollment[] enrollments;
    PreImageCache[] caches;
    auto pairs = iota(4).map!(idx => WK.Keys[idx]).array;
    foreach (idx, kp; pairs)
    {
        auto pair = Pair.fromScalar(secretKeyToCurveScalar(kp.secret));
        auto cycle = PreImageCycle(
                0, 0,
                PreImageCache(PreImageCycle.NumberOfCycles, params.ValidatorCycle),
                PreImageCache(params.ValidatorCycle, 1));
        const seed = cycle.populate(pair.v, true);
        caches ~= cycle.preimages;
        auto enroll = EnrollmentManager.makeEnrollment(
            pair, utxos[idx], params.ValidatorCycle,
            seed, 0);
        assert(ledger.enroll_man.addEnrollment(enroll, kp.address, Height(1),
                &ledger.utxo_set.peekUTXO));
        enrollments ~= enroll;
    }

    foreach (idx, hash; utxos)
    {
        Enrollment stored_enroll = ledger.enroll_man.getEnrollment(hash);
        assert(stored_enroll == enrollments[idx]);
    }

    // create the 10th block to make the `Enrollment`s enrolled
    new_txs = genGeneralBlock(new_txs);
    assert(ledger.getBlockHeight() == Height(10));
    ledger.enroll_man.clearExpiredValidators(Height(10));
    ledger.enroll_man.updateValidatorIndexMaps(Height(11));
    auto b10 = ledger.getBlocksFrom(Height(10))[0];
    assert(b10.header.enrollments.length == 4);

    // block 11
    new_txs = genGeneralBlock(new_txs);
    assert(ledger.getBlockHeight() == Height(11));

    // check missing validators not revealing pre-images.
    // there are three missing validators at the height of 11.
    auto temp_txs = genTransactions(new_txs);
    temp_txs.each!(tx => assert(ledger.acceptTransaction(tx)));

    auto preimage = PreImageInfo(
        enrollments[0].utxo_key,
        caches[0][$ - 2],
        1);
    ledger.enroll_man.addPreimage(preimage);
    auto gotten_image =
        ledger.enroll_man.getValidatorPreimage(enrollments[0].utxo_key);
    assert(gotten_image == preimage);

    ConsensusData data;
    ledger.prepareNominatingSet(data, Block.TxsInTestBlock);
    assert(data.missing_validators.length == 3);
    assert(data.missing_validators == [0, 1, 3]);

    // check validity of slashing information
    assert(ledger.validateSlashingData(data) == null);
    ConsensusData forged_data = data;
    forged_data.missing_validators = [1, 2, 3];
    assert(ledger.validateSlashingData(forged_data) != null);

    // reveal preimages of all the validators
    foreach (idx, cache; caches[1 .. $])
    {
        preimage = PreImageInfo(
            enrollments[idx + 1].utxo_key,
            cache[$ - 2],
            1);
        ledger.enroll_man.addPreimage(preimage);
        gotten_image =
            ledger.enroll_man.getValidatorPreimage(enrollments[idx + 1].utxo_key);
        assert(gotten_image == preimage);
    }

    // there's no missing validator at the height of 11
    // after revealing preimages
    temp_txs.each!(tx => ledger.pool.remove(tx));
    temp_txs = genTransactions(new_txs);
    temp_txs.each!(tx => assert(ledger.acceptTransaction(tx)));

    ledger.prepareNominatingSet(data, Block.TxsInTestBlock);
    assert(data.missing_validators.length == 0);
}

unittest
{
    import agora.consensus.data.genesis.Test;
    import agora.consensus.PreImage;
    import agora.crypto.Schnorr;
    import agora.utils.WellKnownKeys : CommonsBudget;

    ConsensusConfig config = { validator_cycle: 20, payout_period: 5 };
    auto params = new immutable(ConsensusParams)(GenesisBlock,
        CommonsBudget.address, config);

    const(Block)[] blocks = [ GenesisBlock ];
    scope ledger = new TestLedger(WK.Keys.NODE2, blocks, params);

    Hash[] genesisEnrollKeys;
    ledger.enroll_man.getEnrolledUTXOs(genesisEnrollKeys);

    // Reveal preimages for all validators but 1
    foreach (idx, key; genesisEnrollKeys[0..$-1])
    {
        UTXO stake;
        assert(ledger.utxo_set.peekUTXO(key, stake));
        KeyPair kp = WK.Keys[stake.output.address];
        auto pair = Pair.fromScalar(secretKeyToCurveScalar(kp.secret));
        auto cycle = PreImageCycle(
            0, 0,
            PreImageCache(PreImageCycle.NumberOfCycles, params.ValidatorCycle),
            PreImageCache(params.ValidatorCycle, 1));
        const preimage = PreImageInfo(key,
            cycle.getPreImage(pair.v, Height(params.ValidatorCycle)),
                cast (ushort) (params.ValidatorCycle));

        ledger.enroll_man.addPreimage(preimage);
    }

    // Block with no fee
    auto no_fee_txs = blocks[$-1].spendable.map!(txb => txb.sign()).array();
    no_fee_txs.each!(tx => assert(ledger.acceptTransaction(tx)));

    ConsensusData data;
    ledger.prepareNominatingSet(data, Block.TxsInTestBlock);
    // This is a block with no fees, a ConsensusData with Coinbase TXs should
    // fail validation. But since the Ledger does not know about the hash, it will
    // think someone else may validate it.
    data.tx_set ~= Transaction(TxType.Coinbase, [Input(Height(blocks.length))],
        [Output(Amount(1), CommonsBudgetAddress)]).hashFull();
    assert(ledger.validateConsensusData(data) ==
        Ledger.InvalidConsensusDataReason.MayBeValid);

    ledger.forceCreateBlock();
    assert(ledger.getBlockHeight() == blocks.length);
    blocks ~= ledger.getBlocksFrom(Height(blocks.length))[0];

    // No Coinbase TX
    assert(blocks[$-1].txs.filter!(tx => tx.type == TxType.Coinbase)
        .array.length == 0);

    // Create blocks from height 2 to 6, with fees
    foreach (height; 2..7)
    {
        Amount per_tx_fee = Amount.UnitPerCoin;
        auto txs = blocks[$-1].spendable.map!(txb =>
            txb.deduct(per_tx_fee).sign()).array();
        txs.each!(tx => assert(ledger.acceptTransaction(tx)));

        data = ConsensusData.init;
        ledger.prepareNominatingSet(data, Block.TxsInTestBlock);

        // Remove the coinbase TX
        data.tx_set = data.tx_set[0 .. $ - 1];
        assert(ledger.validateConsensusData(data) == "Invalid Coinbase transaction");
        // Add Invalid coinbase TX
        data.tx_set ~= Transaction(TxType.Coinbase).hashFull();
        assert(ledger.validateConsensusData(data) == "Invalid Coinbase transaction");

        ledger.forceCreateBlock();
        assert(ledger.getBlockHeight() == blocks.length);
        blocks ~= ledger.getBlocksFrom(Height(blocks.length))[0];

        auto cb_txs = blocks[$-1].txs.filter!(tx => tx.type == TxType.Coinbase)
            .array;
        assert(cb_txs.length == 1);
        // Payout block should pay the CommonsBudget + all validators (excl MPV)
        // other blocks should only pay CommonsBudget
        assert(cb_txs[0].outputs.length == (blocks[$-1].header.height == params.PayoutPeriod
            ? genesisEnrollKeys.length : 1));

        // MPV should never be paid
        UTXO mpv_stake;
        assert(ledger.utxo_set.peekUTXO(genesisEnrollKeys[$-1], mpv_stake));
        assert(cb_txs[0].outputs.filter!(output => output.address ==
            mpv_stake.output.address).array.length == 0);
    }
}

// Coinbase only ConsensusData and blocks should not be validated
unittest
{
    import agora.utils.WellKnownKeys : CommonsBudget;
    import agora.consensus.data.genesis.Test;

    ConsensusConfig config = { validator_cycle: 20, payout_period: 1 };
    auto params = new immutable(ConsensusParams)(GenesisBlock,
        CommonsBudget.address, config);

    const(Block)[] blocks = [ GenesisBlock ];
    scope ledger = new TestLedger(WK.Keys.NODE2, blocks, params);

    auto txs = blocks[$-1].spendable.map!(txb =>
        txb.deduct(Amount.UnitPerCoin).sign()).array();
    assert(ledger.acceptTransaction(txs[0]));
    ledger.forceCreateBlock(1);

    ConsensusData data;
    ledger.prepareNominatingSet(data, 1);
    // Coinbase TX should not be nominated.
    assert(data.tx_set.length == 0);

    const Transaction[] empty_tx_set;
    const uint[] empty_mpvs;

    auto cb_tx_set = ledger.getCoinbaseTX(empty_tx_set, empty_mpvs);
    data.tx_set ~= cb_tx_set.map!(tx => tx.hashFull()).array;
    assert(data.tx_set.length == 1);
    // Coinbase only nomination, Should not validate
    assert(ledger.validateConsensusData(data) ==
        Ledger.InvalidConsensusDataReason.OnlyCoinbaseTX);
    assert(!ledger.externalize(data));

    auto last_block = ledger.getLastBlock();
    const block = makeNewBlock(last_block, cb_tx_set, data.timestamp, getTestRandomSeed());
    assert(ledger.validateBlock(block) == "Block: Must contain other transactions than Coinbase");
}
