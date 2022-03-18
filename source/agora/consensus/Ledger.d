/*******************************************************************************

    The `Ledger` class binds together other components to provide a consistent
    view of the state of the node.

    The Ledger acts as a bridge between other components, e.g. the `UTXOSet`,
    `EnrollmentManager`, `IBlockStorage`, etc...
    While the `Node` is the main object in Agora, the `Ledger` is the second
    most important class, handling all business logic, relying on the the `Node`
    for anything related to network communicatiion.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.Ledger;

import agora.common.Amount;
import agora.common.Ensure;
import agora.common.ManagedDatabase;
import agora.common.Set;
import agora.common.Types;
import agora.consensus.BlockStorage;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.Fee;
import agora.consensus.pool.Transaction;
import agora.consensus.protocol.Data;
import agora.consensus.Reward;
import agora.consensus.state.UTXOSet;
import agora.consensus.validation;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.script.Lock;
import agora.serialization.Serializer;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

import std.algorithm;
import std.conv : to;
import std.format;
import std.range;
import std.typecons : Nullable, nullable;

version (unittest)
{
    import agora.consensus.data.genesis.Test: genesis_validator_keys;
    import agora.utils.Test;
}
/// Expose the base Ledger class
public import agora.consensus.state.Ledger : UTXOTracker, Ledger;

/// The Ledger class held by a node
public class NodeLedger : Ledger
{
    /// Error message describing the reason of validation failure
    public static enum InvalidConsensusDataReason : string
    {
        NotEnoughValidators = "Enrollment: Insufficient number of active validators",
        MayBeValid = "May be valid",
        TooManyMPVs = "More MPVs than active enrollments",
        NoUTXO = "Couldn't find UTXO for one or more Enrollment",
        NotInPool = "Transaction is not in the pool",
        MisMatchingCoinbase = "Missing matching Coinbase transaction",
    }

    /// A delegate to be called when a block was externalized (unless `null`)
    protected void delegate (in Block, bool) @safe onAcceptedBlock;

    /// Pool of transactions to pick from when generating blocks
    protected TransactionPool pool;

    /// Hashes of transactions the Ledger encountered but doesn't have in the pool
    protected Set!Hash unknown_txs;

    /// The list of frozen UTXOs known to this Ledger
    protected UTXOTracker frozen_utxos;

    /// Enrollment manager
    protected EnrollmentManager enroll_man;

    /// Hashes of Values we fully validated for a slot
    private Set!Hash fully_validated_value;

    /***************************************************************************

        Constructor

        Params:
            params = the consensus-critical constants
            database = State database
            storage = the block storage
            enroll_man = the enrollmentManager
            pool = the transaction pool
            onAcceptedBlock = optional delegate to call
                              when a block was added to the ledger

    ***************************************************************************/

    public this (immutable(ConsensusParams) params,
        ManagedDatabase database, IBlockStorage storage,
        EnrollmentManager enroll_man, TransactionPool pool,
        void delegate (in Block, bool) @safe onAcceptedBlock)
    {
        // Note: Those properties need to be set before calling the `super` ctor,
        // as `Ledger`'s ctor will call `replayStoredBlock`, which would call
        // a SEGV if the pool wasn't set.
        this.onAcceptedBlock = onAcceptedBlock;
        this.pool = pool;
        this.enroll_man = enroll_man;
        this.frozen_utxos = new FrozenUTXOTracker(this);
        super(params, database, storage, enroll_man.validator_set);

        // Rebuild tracker frozen UTXO set
        foreach (const ref Hash hash, const ref UTXO utxo; this.utxo_set)
            this.frozen_utxos.externalize(hash, utxo.output);
    }

    /// See `Ledger.acceptBlock`
    public override string acceptBlock (in Block block) @safe
    {
        const old_count = (this.onAcceptedBlock !is null) ?
            this.validatorCount(block.header.height) : 0;

        if (auto err = super.acceptBlock(block))
            return err;

        if (this.onAcceptedBlock !is null)
        {
            const new_count = this.validatorCount(block.header.height + 1);
            // there was a change in the active validator set
            const bool validators_changed = block.header.enrollments.length > 0
                || new_count != old_count;
            this.onAcceptedBlock(block, validators_changed);
        }

        () @trusted { this.fully_validated_value.clear(); }();
        return null;
    }

    /// See Ledger.addValidatedBlock`
    protected override void addValidatedBlock (in Block block) @safe
    {
        super.addValidatedBlock(block);

        // Clear the unknown TXs every round (clear() is not @safe)
        this.unknown_txs = Set!Hash.init;
    }

    /// See `Ledger.updateUTXOSet`
    protected override void updateUTXOSet (in Block block) @safe
    {
        super.updateUTXOSet(block);
        this.frozen_utxos.externalize(block, (Hash stake_hash) @safe {
            this.enroll_man.removeEnrollment(stake_hash);
        });
        this.pool.remove(block.txs, true);
    }

    /// See `Ledger.updateValidatorSet`
    protected override void updateValidatorSet (in Block block) @safe
    {
        PublicKey pubkey = this.enroll_man.getEnrollmentPublicKey();
        UTXO[Hash] utxos = this.utxo_set.getUTXOs(pubkey);

        foreach (idx, ref enrollment; block.header.enrollments)
        {
            UTXO utxo;
            if (!this.utxo_set.peekUTXO(enrollment.utxo_key, utxo))
                assert(0);

            if (auto r = this.enroll_man.addValidator(enrollment, utxo.output.address,
                    block.header.height, &this.utxo_set.peekUTXO, &this.getPenaltyDeposit, utxos))
            {
                log.fatal("Error while adding a new validator: {}", r);
                log.fatal("Enrollment #{}: {}", idx, enrollment);
                log.fatal("Validated block: {}", block);
                assert(0);
            }
            this.utxo_set.updateUTXOLock(enrollment.utxo_key, block.header.height + this.params.ValidatorCycle);
            this.pool.removeSpenders(enrollment.utxo_key);
        }
    }

    /***************************************************************************

        Called when a new transaction is received.

        If the transaction is accepted it will be added to
        the transaction pool.

        If the transaction is invalid, it's rejected and false is returned.

        Params:
            tx = the received transaction
            double_spent_threshold_pct =
                          See `Config.node.double_spent_threshold_pct`
            min_fee_pct = See `Config.node.min_fee_pct`

        Returns:
            reason why invalid or null if the transaction is valid and was added
            to the pool

    ***************************************************************************/

    public string acceptTransaction (in Transaction tx,
        in ubyte double_spent_threshold_pct = 0,
        in ushort min_fee_pct = 0) @safe
    {
        const Height expected_height = this.height() + 1;
        auto tx_hash = hashFull(tx);

        // If we were looking for this TX, stop
        this.unknown_txs.remove(tx_hash);

        if (tx.isCoinbase)
            return "Coinbase transaction";
        if (this.pool.hasTransactionHash(tx_hash))
            return "Transaction already in the pool";

        if (auto reason = tx.isInvalidReason(this.engine,
                this.utxo_set.getUTXOFinder(),
                expected_height, &this.fee_man.check,
                &this.getPenaltyDeposit))
            return reason;

        auto min_fee = this.pool.getAverageFeeRate();
        if (!min_fee.percentage(min_fee_pct))
            assert(0);

        Amount fee_rate;
        if (auto err = this.fee_man.getTxFeeRate(tx, this.utxo_set.getUTXOFinder(),
            &this.getPenaltyDeposit, fee_rate))
            return err;
        const size_limit = this.params.MaxTxSetSize * 1024;
        if (fee_rate < min_fee && this.pool.getPoolSize() >= size_limit) // If pool is sparsely populated, accept any fee.
            return "Fee rate is lower than this node's configured relative threshold (min_fee_pct)";
        if (!this.isAcceptableDoubleSpent(tx, double_spent_threshold_pct))
            return "Double spend comes with a less-than-acceptable fee increase";

        return this.pool.add(tx, fee_rate) ? null : "Rejected by storage";
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

        Get a set of TX Hashes that Ledger is missing

        Returns:
            set of TX Hashes that Ledger is missing

    ***************************************************************************/

    public Set!Hash getUnknownTXHashes () @safe nothrow
    {
        return this.unknown_txs;
    }

    /***************************************************************************

        Params:
            hashes = set of tx hashes

        Returns:
            Transactions in the pool that match one of the hashes in the list

     ***************************************************************************/

    public auto getUnknownTXsFromSet (Set!Hash hashes) @trusted nothrow
    {
        return this.pool.getUnknownTXsFromSet(hashes);
    }

    /***************************************************************************

        Get a set of all the stakes currently active at this height

        Returns:
            A set of stakes

    ***************************************************************************/

    public Set!(UTXOTracker.Tracked) getStakes () @safe nothrow @nogc pure
    {
        return this.frozen_utxos.data();
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

    public string getValidTXSet(in ConsensusData data, ref Transaction[] tx_set)  @safe nothrow
    {
        if (auto reason = this.isValidTXSet(data))
            return reason;

        auto coinbase_tx = this.getCoinbaseTX(this.height() + 1);
        auto coinbase_tx_hash = coinbase_tx.hashFull();
        auto not_cb_filter = (Hash h) => coinbase_tx == Transaction.init || h != coinbase_tx_hash;

        foreach (const ref tx_hash; data.tx_set)
        {
            if (!not_cb_filter(tx_hash))
                continue;
            auto tx = this.pool.getTransactionByHash(tx_hash);
            assert(tx != Transaction.init);
            tx_set ~= tx;
        }
        if (coinbase_tx != Transaction.init)
            tx_set ~= coinbase_tx;

        return null;
    }

    /// Ditto
    public string isValidTXSet (in ConsensusData data) @safe nothrow
    {
        auto coinbase_tx = this.getCoinbaseTX(this.height() + 1);
        Hash coinbase_tx_hash = coinbase_tx.hashFull();
        if (coinbase_tx != Transaction.init)
        {
            log.trace("isValidTxSet: Coinbase hash={}, tx={}", coinbase_tx_hash, coinbase_tx.prettify);
            if (!data.tx_set.canFind(coinbase_tx_hash))
                return InvalidConsensusDataReason.MisMatchingCoinbase;
        }

        auto enrolled_utxos = Set!Hash.from(data.enrolls.map!(enroll => enroll.utxo_key));
        auto not_cb_filter = (Hash h) => coinbase_tx == Transaction.init || h != coinbase_tx_hash;
        if (auto reason = this.pool.isValidTxSet(data.tx_set.filter!(not_cb_filter), enrolled_utxos))
            return reason;

        return null;
    }

    /***************************************************************************

        Check whether the consensus data is valid.

        Params:
            data = consensus data
            initial_missing_validators = missing validators at the beginning of
               the nomination round

        Returns:
            the error message if validation failed, otherwise null

    ***************************************************************************/

    public string validateConsensusData (in ConsensusData data,
        in uint[] initial_missing_validators) @trusted nothrow
    {
        const validating = this.height() + 1;
        auto utxo_finder = this.utxo_set.getUTXOFinder();

        auto idx_value_hash = hashMulti(validating, data);
        if (idx_value_hash in this.fully_validated_value)
            return null;

        if (auto fail_reason = this.isValidTXSet(data))
            return fail_reason;

        // av   == active validators (this block)
        // avnb == active validators next block
        // The consensus data is for the creation of the next block,
        // so 'this block' means "current height + 1". While the ConsensusData
        // does not contain information about what block we are validating,
        // we assume that it's the block after the currently externalized one.
        size_t av   = this.validatorCount(validating);
        size_t avnb = this.validatorCount(validating + 1);

        // First we make sure that we do not slash too many validators,
        // as slashed validators cannot sign a block.
        // If there are 6 validators, and we're slashing 5 of them,
        // av = 6, missing_validators.length = 5, and `6 < 5 + 1` is still `true`.
        if (av < (data.missing_validators.length + Enrollment.MinValidatorCount))
        {
            log.dbg("validateConsensusData: Active validators:{} < {}",
                av, data.missing_validators.length + Enrollment.MinValidatorCount);
            return InvalidConsensusDataReason.NotEnoughValidators;
        }

        // We're trying to slash more validators that there are next block
        // FIXME: this check isn't 100% correct: we should check which validators
        // we are slashing. It could be that our of 5 validators, 3 are expiring
        // this round, and none of them have revealed their pre-image, in which
        // case the 3 validators we slash should not block externalization.
        if (avnb < data.missing_validators.length)
        {
            log.dbg("validateConsensusData: Active validators next block:{} < {}",
                avnb, data.missing_validators.length);
            return InvalidConsensusDataReason.TooManyMPVs;
        }

        // FIXME: See above comment
        avnb -= data.missing_validators.length;

        // We need to make sure that we externalize a block that allows for the
        // chain to make progress, otherwise we'll be stuck forever.
        if ((avnb + data.enrolls.length) < Enrollment.MinValidatorCount)
        {
            log.dbg("validateConsensusData: Active validators next block:{} + enrolls:{} < {}",
                avnb, data.enrolls.length, data.missing_validators.length + Enrollment.MinValidatorCount);
            return InvalidConsensusDataReason.NotEnoughValidators;
        }

        foreach (const ref enroll; data.enrolls)
        {
            UTXO utxo_value;
            if (!this.utxo_set.peekUTXO(enroll.utxo_key, utxo_value))
                return InvalidConsensusDataReason.NoUTXO;
            if (auto fail_reason = this.enroll_man.isInvalidCandidateReason(
                enroll, utxo_value.output.address, validating, utxo_finder, &this.getPenaltyDeposit))
                return fail_reason;
        }

        try if (auto fail_reason = this.validateSlashingData(validating, data, initial_missing_validators))
                return fail_reason;

        catch (Exception exc)
        {
            log.error("Caught Exception while validating slashing data: {}", exc);
            return "Internal error while validating slashing data";
        }

        this.fully_validated_value.put(idx_value_hash);
        return null;
    }

    /***************************************************************************

        Checks whether the `tx` is an acceptable double spend transaction.

        If `tx` is not a double spend transaction, then returns true.
        If `tx` is a double spend transaction, and its fee is considerable higher
        than the existing double spend transactions, then returns true.
        Otherwise this function returns false.

        Params:
            tx = transaction
            threshold_pct = percentage by which the fee of the new transaction has
              to be higher, than the previously highest double spend transaction

        Returns:
            whether the `tx` is an acceptable double spend transaction

    ***************************************************************************/

    public bool isAcceptableDoubleSpent (in Transaction tx, ubyte threshold_pct) @safe
    {
        Amount rate;
        if (this.fee_man.getTxFeeRate(tx, &utxo_set.peekUTXO, &this.getPenaltyDeposit, rate).length)
            return false;

        // only consider a double spend transaction, if its fee is
        // considerably higher than the current highest fee
        auto fee_threshold = getDoubleSpentHighestFee(tx);

        // if the fee_threshold is null, it means there won't be any double
        // spend transactions, after this transaction is added to the pool
        if (!fee_threshold.isNull())
            fee_threshold.get().percentage(threshold_pct + 100);

        if (!fee_threshold.isNull() &&
            (!rate.isValid() || rate < fee_threshold.get()))
            return false;

        return true;
    }

    /***************************************************************************

        Forwards to `FeeManager.getTxFeeRate`, using this Ledger's UTXO.

    ***************************************************************************/

    public string getTxFeeRate (in Transaction tx, out Amount rate) @safe nothrow
    {
        return this.fee_man.getTxFeeRate(tx, &this.utxo_set.peekUTXO, &this.getPenaltyDeposit, rate);
    }

    /***************************************************************************

        Looks up transaction with hash `tx_hash`, then forwards to
        `FeeManager.getTxFeeRate`, using this Ledger's UTXO.

    ***************************************************************************/

    public string getTxFeeRate (in Hash tx_hash, out Amount rate) nothrow @safe
    {
        auto tx = this.pool.getTransactionByHash(tx_hash);
        if (tx == Transaction.init)
            return InvalidConsensusDataReason.NotInPool;
        return this.getTxFeeRate(tx, rate);
    }

    /***************************************************************************

        Returns the highest fee among all the transactions which would be
        considered as a double spent, if `tx` transaction was in the transaction
        pool.

        If adding `tx` to the transaction pool would not result in double spent
        transaction, then the return value is Nullable!Amount().

        Params:
            tx = transaction

        Returns:
            the highest fee among all the transactions which would be
            considered as a double spend, if `tx` transaction was in the
            transaction pool.

    ***************************************************************************/

    public Nullable!Amount getDoubleSpentHighestFee (in Transaction tx) @safe
    {
        Set!Hash tx_hashes;
        pool.gatherDoubleSpentTXs(tx, tx_hashes);

        const(Transaction)[] txs;
        foreach (const tx_hash; tx_hashes)
        {
            const tx_ret = this.pool.getTransactionByHash(tx_hash);
            if (tx_ret != Transaction.init)
                txs ~= tx_ret;
        }

        if (!txs.length)
            return Nullable!Amount();

        return nullable(txs.map!((tx)
            {
                Amount rate;
                this.fee_man.getTxFeeRate(tx, &utxo_set.peekUTXO, &this.getPenaltyDeposit, rate);
                return rate;
            }).maxElement());
    }

    /***************************************************************************

        Returns: A list of Enrollments that can be used for the next block

    ***************************************************************************/

    public Enrollment[] getCandidateEnrollments (in Height height,
        scope UTXOFinder utxo_finder) @safe
    {
        return this.enroll_man.getEnrollments(height, &this.utxo_set.peekUTXO,
            &this.getPenaltyDeposit, utxo_finder);
    }

    /***************************************************************************

        Check whether the slashing data is valid.

        Params:
            height = height
            data = consensus data
            initial_missing_validators = missing validators at the beginning of
               the nomination round
            utxo_finder = UTXO finder with double spent protection

        Returns:
            the error message if validation failed, otherwise null

    ***************************************************************************/

    public string validateSlashingData (in Height height, in ConsensusData data,
        in uint[] initial_missing_validators) @safe
    {
        return this.isInvalidPreimageRootReason(height, data.missing_validators,
            initial_missing_validators);
    }

    /***************************************************************************

        Check if information for pre-images and slashed validators is valid

        Params:
            height = the height of proposed block
            missing_validators = list of indices to the validator UTXO set
                which have not revealed the preimage
            missing_validators_higher_bound = missing validators at the beginning of
               the nomination round
            utxo_finder = UTXO finder with double spent protection

        Returns:
            `null` if the information is valid at the proposed height,
            otherwise a string explaining the reason it is invalid.

    ***************************************************************************/

    private string isInvalidPreimageRootReason (in Height height,
        in uint[] missing_validators, in uint[] missing_validators_higher_bound) @safe
    {
        import std.algorithm.setops : setDifference;

        auto validators = this.getValidators(height);
        assert(validators.length <= uint.max);

        uint[] missing_validators_lower_bound = validators.enumerate
            .filter!(kv => kv.value.preimage.height < height)
            .map!(kv => cast(uint) kv.index).array();

        // NodeA will check the candidate from NodeB in the following way:
        //
        // Current missing validators in NodeA(=sorted_missing_validators_lower_bound) ⊆
        // missing validators in the candidate from NodeB(=sorted_missing_validators) ⊆
        // missing validators in NodeA before the nomination round started
        // (=sorted_missing_validators_higher_bound)
        //
        // If both of those conditions true, then NodeA will accept the candidate.

        auto sorted_missing_validators = missing_validators.dup().sort();
        auto sorted_missing_validators_lower_bound = missing_validators_lower_bound.dup().sort();
        auto sorted_missing_validators_higher_bound = missing_validators_higher_bound.dup().sort();

        if (!setDifference(sorted_missing_validators_lower_bound, sorted_missing_validators).empty())
            return format!("Lower bound violation - Missing validator mismatch %s is not a subset of %s")
                (sorted_missing_validators_lower_bound, sorted_missing_validators);

        if (!setDifference(sorted_missing_validators, sorted_missing_validators_higher_bound).empty())
            return format!("Higher bound violation - Missing validator mismatch %s is not a subset of %s")
                (sorted_missing_validators, sorted_missing_validators_higher_bound);

        if (missing_validators.any!(idx => idx >= validators.length))
            return "Slashing non existing index";
        UTXO utxo;

        return null;
    }
}

/*******************************************************************************

    A ledger that participate in the consensus protocol

    This ledger is held by validators, as they need to do additional bookkeeping
    when e.g. proposing transactions.

*******************************************************************************/

public class ValidatingLedger : NodeLedger
{
    /// See parent class
    public this (immutable(ConsensusParams) params,
        ManagedDatabase database, IBlockStorage storage,
        EnrollmentManager enroll_man, TransactionPool pool,
        void delegate (in Block, bool) @safe onAcceptedBlock)
    {
        super(params, database, storage, enroll_man, pool, onAcceptedBlock);
    }

    /***************************************************************************

        Collect up to a maximum number of transactions to nominate

        Params:
            txs = will contain the transaction set to nominate,
                  or empty if not enough txs were found
            max_txs = the maximum number of transactions to prepare.

    ***************************************************************************/

    public void prepareNominatingSet (out ConsensusData data)
        @safe
    {
        const next_height = this.height() + 1;

        auto utxo_finder = this.utxo_set.getUTXOFinder();
        data.enrolls = this.getCandidateEnrollments(next_height, utxo_finder);
        data.missing_validators = this.getCandidateMissingValidators(next_height, utxo_finder);
        data.tx_set = this.getCandidateTransactions(next_height, utxo_finder);
        if (this.isCoinbaseBlock(next_height))
            {
                auto coinbase_tx = this.getCoinbaseTX(next_height);
                auto coinbase_hash = coinbase_tx.hashFull();
                log.info("prepareNominatingSet: Coinbase hash={}, tx={}", coinbase_hash, coinbase_tx.prettify);
                data.tx_set ~= coinbase_hash;
            }
    }

    /// Validate slashing data, including checking if the node is slef slashing
    public override string validateSlashingData (in Height height, in ConsensusData data,
        in uint[] initial_missing_validators) @safe
    {
        if (auto res = super.validateSlashingData(height, data, initial_missing_validators))
            return res;

        const self = this.enroll_man.getEnrollmentKey();
        foreach (index, const ref validator; this.getValidators(height))
        {
            if (self != validator.utxo())
                continue;

            return data.missing_validators.find(index).empty ? null
                : "Node is attempting to slash itself";
        }
        return null;
    }

    /***************************************************************************

        Returns:
            A list of Validators that have not yet revealed their PreImage for
            height `height` (based on the current Ledger's knowledge).

    ***************************************************************************/

    public uint[] getCandidateMissingValidators (in Height height,
        scope UTXOFinder findUTXO) @safe
    {
        UTXO utxo;
        return this.getValidators(height).enumerate()
            .filter!(en => en.value.preimage.height < height)
            .filter!(en => findUTXO(en.value.preimage.utxo, utxo))
            .map!(en => cast(uint) en.index)
            .array();
    }

    /***************************************************************************

        Returns:
            A list of Transaction hash that can be included in the next block

    ***************************************************************************/

    public Hash[] getCandidateTransactions (in Height height,
        scope UTXOFinder utxo_finder) @safe
    {
        Hash[] result;
        size_t size_budget = this.params.MaxTxSetSize * 1024; // cant overflow
        foreach (ref Hash hash, ref Transaction tx; this.pool)
        {
            auto size = tx.sizeInBytes();
            if (size_budget >= size)
            {
                result ~= hash;
                size_budget -= size;
            }
            else
                break;
        }
        result.sort();
        return result;
    }

    version (unittest):

    private string externalize (ConsensusData data, size_t signed = genesis_validator_keys.length) @trusted
    {
        const height = Height(this.last_block.header.height + 1);

        Transaction[] externalized_tx_set;
        if (auto fail_reason = this.getValidTXSet(data, externalized_tx_set))
        {
            log.info("Ledger.externalize: can not create new block at Height {} : {}. Fail reason : {}",
                height, data.prettify, fail_reason);
            return fail_reason;
        }

        auto block = this.buildBlock(externalized_tx_set,
            data.enrolls, data.missing_validators);

        this.getValidators(height).take(signed).enumerate.each!((i, v)
        {
            if (!data.missing_validators.canFind(i))
            {
                block.header.validators[i] = true;
                auto tmp = block.header.sign(WK.Keys[v.address].secret, block.header.preimages[i]);
                block.header.signature.R += tmp.R;
                block.header.signature.s += tmp.s;
            }
        });
        return this.acceptBlock(block);
    }

    /// simulate block creation as if a nomination and externalize round completed
    public void forceCreateBlock ()
    {
        const next_block = this.height() + 1;
        this.simulatePreimages(next_block);
        ConsensusData data;
        this.prepareNominatingSet(data);

        // If the user provided enrollments, do not re-enroll automatically
        // If they didn't, check to see if the next block needs them
        // In which case, we simply re-enroll the validators already enrolled
        if (data.enrolls.length == 0 && this.validatorCount(next_block + 1) == 0)
        {
            auto validators = this.getValidators(this.height());
            foreach (v; validators)
            {
                auto kp = WK.Keys[v.address];
                auto enroll = EnrollmentManager.makeEnrollment(
                    v.utxo, kp, next_block, this.params.ValidatorCycle);
                data.enrolls ~= enroll;
            }
        }

        if (auto reason = this.externalize(data))
        {
            assert(0, format!"Failure in unit test. Block %s should have been externalized: %s"(
                       this.height() + 1, reason));
        }
    }

    /// Generate a new block by creating transactions, then calling `forceCreateBlock`
    private Transaction[] makeTestBlock (Transaction[] last_txs)
    {
        // Special case for genesis
        if (!last_txs.length)
        {
            assert(this.height() == 0);

            last_txs = genesisSpendable().enumerate()
                .map!(en => en.value.refund(WK.Keys.A.address).sign())
                .array();
            last_txs.each!(tx => this.acceptTransaction(tx));
            this.forceCreateBlock();
            return last_txs;
        }

        last_txs = last_txs.map!(tx => TxBuilder(tx).sign()).array();
        last_txs.each!(tx => assert(this.acceptTransaction(tx) is null));
        this.forceCreateBlock();
        return last_txs;
    }
}

/// A class that tracks frozen UTXOs
private final class FrozenUTXOTracker : UTXOTracker
{
    /// Ledger instance
    private Ledger ledger;

    /// Constructor
    public this (Ledger ledger) @safe pure nothrow @nogc
    {
        this.ledger = ledger;
    }

    ///
    public override bool include (in Hash hash, in Output utxo) scope @safe
    {
        return this.ledger.isStake(hash, utxo);
    }

    /// Process all transactions in this `Block`
    public override void externalize (in Block block, void delegate (Hash) @safe onRemoved = null) @safe
    {
        super.externalize(block, onRemoved);
        auto slashed = block.header.preimages.enumerate
            .filter!(en => en.value is Hash.init).map!(en => en.index);
        if (!slashed.empty)
        {
            auto validators = this.ledger.getValidators(block.header.height);
            foreach (idx; slashed)
            {
                if (onRemoved)
                    onRemoved(validators[idx].utxo);
                this.data_.remove(Tracked(validators[idx].utxo));
            }
        }
    }
}

version (unittest)
{
    import agora.consensus.PreImage;
    import agora.node.Config;
    import core.stdc.time : time;

    /// A `Ledger` with sensible defaults for `unittest` blocks
    public final class TestLedger : ValidatingLedger
    {
        public this (KeyPair key_pair,
            const(Block)[] blocks = null,
            immutable(ConsensusParams) params_ = null,
            void delegate (in Block, bool) @safe onAcceptedBlock = null)
        {
            const params = (params_ !is null)
                ? params_
                : (blocks.length > 0
                   // Use the provided Genesis block
                   ? new immutable(ConsensusParams)(
                       cast(immutable)blocks[0], WK.Keys.CommonsBudget.address,
                       ConsensusConfig(ConsensusConfig.init.genesis_timestamp))
                   // Use the unittest genesis block
                   : new immutable(ConsensusParams)());

            ValidatorConfig vconf = ValidatorConfig(true, key_pair);
            getCycleSeed(key_pair, params.ValidatorCycle, vconf.cycle_seed, vconf.cycle_seed_height);
            assert(vconf.cycle_seed != Hash.init);
            assert(vconf.cycle_seed_height != Height(0));

            auto stateDB = new ManagedDatabase(":memory:");
            auto cacheDB = new ManagedDatabase(":memory:");
            super(params,
                stateDB,
                new MemBlockStorage(blocks),
                new EnrollmentManager(stateDB, cacheDB, vconf, params),
                new TransactionPool(cacheDB),
                onAcceptedBlock);
        }

        ///
        protected override void replayStoredBlock (in Block block) @safe
        {
            if (block.header.height > 0)
                this.simulatePreimages(block.header.height);
            super.replayStoredBlock(block);
        }

        /// Property for Enrollment manager
        @property public EnrollmentManager enrollment_manager () @safe nothrow
        {
            return this.enroll_man;
        }

        /// Expose the UTXO set to this module
        @property public UTXOCache utxo_set () @safe pure nothrow @nogc
        {
            return super.utxo_set;
        }
    }
}

///
unittest
{
    scope ledger = new TestLedger(WK.Keys.NODE3);
    assert(ledger.height() == 0);

    auto blocks = ledger.getBlocksFrom(Height(0)).take(10).array;
    assert(blocks[$ - 1] == ledger.params.Genesis);

    Transaction[] last_txs;
    void genBlockTransactions (size_t count)
    {
        foreach (_; 0 .. count)
            last_txs = ledger.makeTestBlock(last_txs);
    }

    genBlockTransactions(2);
    blocks = ledger.getBlocksFrom(Height(0)).take(10).array;
    assert(blocks[0] == ledger.params.Genesis);
    assert(blocks.length == 3);  // two blocks + genesis block

    /// now generate 98 more blocks to make it 100 + genesis block (101 total)
    genBlockTransactions(98);
    assert(ledger.height() == 100);

    blocks = ledger.getBlocksFrom(Height(0)).takeExactly(10).array;
    assert(blocks[0] == ledger.params.Genesis);
    assert(blocks.length == 10);

    /// lower limit
    blocks = ledger.getBlocksFrom(Height(0)).takeExactly(5).array;
    assert(blocks[0] == ledger.params.Genesis);
    assert(blocks.length == 5);

    /// different indices
    blocks = ledger.getBlocksFrom(Height(1)).takeExactly(10).array;
    assert(blocks[0].header.height == 1);
    assert(blocks.length == 10);

    blocks = ledger.getBlocksFrom(Height(50)).takeExactly(10).array;
    assert(blocks[0].header.height == 50);
    assert(blocks.length == 10);

    blocks = ledger.getBlocksFrom(Height(95)).take(10).array;  // only 6 left from here (block 100 included)
    assert(blocks.front.header.height == 95);
    assert(blocks.walkLength() == 6);

    blocks = ledger.getBlocksFrom(Height(99)).take(10).array;  // only 2 left from here (ditto)
    assert(blocks.front.header.height == 99);
    assert(blocks.walkLength() == 2);

    blocks = ledger.getBlocksFrom(Height(100)).take(10).array;  // only 1 block available
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
    scope ledger = new TestLedger(genesis_validator_keys[0]);

    Block invalid_block;  // default-initialized should be invalid
    assert(ledger.acceptBlock(invalid_block));
}

/// Situation: Ledger is constructed with blocks present in storage
/// Expectation: The UTXOSet is populated with all up-to-date UTXOs
unittest
{
    import agora.consensus.data.genesis.Test;

    const(Block)[] blocks = [
        GenesisBlock,
        makeNewTestBlock(GenesisBlock, GenesisBlock.spendable().map!(txb => txb.sign()))
    ];
    // Make 3 more blocks to put in storage
    foreach (idx; 2 .. 5)
    {
        blocks ~= makeNewTestBlock(
            blocks[$ - 1],
            blocks[$ - 1].spendable().map!(txb => txb.sign()));
    }

    // And provide it to the ledger
    scope ledger = new TestLedger(genesis_validator_keys[0], blocks);

    assert(ledger.utxo_set.length
           == /* Genesis, Frozen */ 12 + 8 /* Block #1 Payments*/);

    // Ensure that all previously-generated outputs are in the UTXO set
    {
        auto findUTXO = ledger.getUTXOFinder();
        UTXO utxo;
        assert(
            blocks[$ - 1].txs.all!(
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

// Return Genesis block plus 'count' number of blocks
version (unittest)
private immutable(Block)[] genBlocksToIndex (
    size_t count, scope immutable(ConsensusParams) params)
{
    import std.exception : assumeUnique;

    const(Block)[] blocks = [ params.Genesis ];
    scope ledger = new TestLedger(genesis_validator_keys[0]);
    foreach (_; 0 .. count)
    {
        auto txs = blocks[$ - 1].spendable().map!(txb => txb.sign());
        blocks ~= makeNewTestBlock(blocks[$ - 1], txs);
    }
    if (blocks)
    {
        ledger.simulatePreimages(blocks[$ - 1].header.height);
    }
    return blocks.assumeUnique;
}

/// test enrollments in the genesis block
unittest
{
    import std.exception : assertThrown;

    // Default test genesis block has 6 validators
    {
        scope ledger = new TestLedger(WK.Keys.A);
        assert(ledger.getValidators(Height(1)).length == 6);
    }

    // One block before `ValidatorCycle`, validator is still active
    {
        const ValidatorCycle = 20;
        auto params = new immutable(ConsensusParams)(ValidatorCycle);
        const blocks = genBlocksToIndex(ValidatorCycle - 1, params);
        scope ledger = new TestLedger(WK.Keys.A, blocks, params);
        Hash[] keys;
        assert(ledger.getValidators(Height(ValidatorCycle)).length == 6);
    }

    // Past `ValidatorCycle`, validator is inactive
    {
        const ValidatorCycle = 20;
        auto params = new immutable(ConsensusParams)(ValidatorCycle);
        const blocks = genBlocksToIndex(ValidatorCycle, params);
        // Enrollment: Insufficient number of active validators
        auto ledger = new TestLedger(WK.Keys.A, blocks, params);
        assertThrown(ledger.getValidators(Height(ValidatorCycle + 1)));
    }
}

/// test atomicity of adding blocks and rolling back
unittest
{
    import std.conv;
    import std.exception : assertThrown;
    import core.stdc.time : time;

    static class ThrowingLedger : Ledger
    {
        bool throw_in_update_utxo;
        bool throw_in_update_validators;

        public this (KeyPair kp, const(Block)[] blocks, immutable(ConsensusParams) params)
        {
            auto stateDB = new ManagedDatabase(":memory:");
            ValidatorConfig vconf = ValidatorConfig(true, kp);
            super(params,
                stateDB,
                new MemBlockStorage(blocks),
                new ValidatorSet(stateDB, params));
        }

        ///
        protected override void replayStoredBlock (in Block block) @safe
        {
            if (block.header.height > 0)
                this.simulatePreimages(block.header.height);
            super.replayStoredBlock(block);
        }

        override void updateUTXOSet (in Block block) @safe
        {
            super.updateUTXOSet(block);
            if (this.throw_in_update_utxo)
                throw new Exception("");
        }

        override void updateValidatorSet (in Block block) @safe
        {
            super.updateValidatorSet(block);
            if (this.throw_in_update_validators)
                throw new Exception("");
        }

        /// Expose the UTXO set to this module
        @property public UTXOCache utxo_set () @safe pure nothrow @nogc
        {
            return super.utxo_set;
        }
    }

    const params = new immutable(ConsensusParams)();

    // throws in updateUTXOSet() => rollback() called, UTXO set reverted,
    // Validator set was not modified
    {
        const blocks = genBlocksToIndex(params.ValidatorCycle, params);
        assert(blocks.length == params.ValidatorCycle + 1);  // +1 for genesis

        scope ledger = new ThrowingLedger(
            WK.Keys.A, blocks.takeExactly(params.ValidatorCycle), params);
        assert(ledger.getValidators(Height(params.ValidatorCycle)).length == 6);
        auto utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == params.ValidatorCycle));

        ledger.throw_in_update_utxo = true;
        auto next_block = blocks[$ - 1];
        assertThrown!Exception(assert(ledger.acceptBlock(next_block) is null));
        assert(ledger.lastBlock() == blocks[$ - 2]);  // not updated
        utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == params.ValidatorCycle));  // reverted
        // not updated
        assert(ledger.getValidators(Height(params.ValidatorCycle)).length == 6);
    }

    // throws in updateValidatorSet() => rollback() called, UTXO set and
    // Validator set reverted
    {
        const blocks = genBlocksToIndex(params.ValidatorCycle, params);
        assert(blocks.length == 21);  // +1 for genesis

        scope ledger = new ThrowingLedger(
            WK.Keys.A, blocks.takeExactly(params.ValidatorCycle), params);
        assert(ledger.getValidators(Height(params.ValidatorCycle)).length == 6);
        auto utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == params.ValidatorCycle));

        ledger.throw_in_update_validators = true;
        auto next_block = blocks[$ - 1];
        assertThrown!Exception(assert(ledger.acceptBlock(next_block) is null));
        assert(ledger.lastBlock() == blocks[$ - 2]);  // not updated
        utxos = ledger.utxo_set.getUTXOs(WK.Keys.Genesis.address);
        assert(utxos.length == 8);
        utxos.each!(utxo => assert(utxo.unlock_height == params.ValidatorCycle));  // reverted
        assert(ledger.getValidators(ledger.lastBlock().header.height).length == 6);
    }
}

/// throw if the gen block in block storage is different to the configured one
unittest
{
    import agora.consensus.data.genesis.Test;
    import agora.consensus.data.genesis.Coinnet : CoinGenesis = GenesisBlock;

    // ConsensusParams is instantiated by default with the test genesis block
    immutable params = new immutable(ConsensusParams)(CoinGenesis, WK.Keys.CommonsBudget.address);

    try
    {
        scope ledger = new TestLedger(WK.Keys.A, [GenesisBlock], params);
        assert(0);
    }
    catch (Exception ex)
    {
        assert(ex.message ==
               "Genesis block loaded from disk " ~
               "(0x8365f069fe37ee02f2c4dc6ad816702088fab5fc875c3c67b01f82c285aa" ~
               "2d90b605f57e068139eba1f20ce20578d712f75be4d8568c8f3a7a34604e72aa3175) "~
               "is different from the one in the config file " ~
               "(0x70c39bda1082ff0715afecd942650bca1773ce4a2fe83fc206234141b8c0e" ~
               "a5199c5c46f1705c48cb717bea633e5d5c3b6dba08e4fc9e1aa28b09e3bf268eaaa)");
    }

    immutable good_params = new immutable(ConsensusParams)();
    // will not fail
    scope ledger = new TestLedger(WK.Keys.A, [GenesisBlock], good_params);
    // Neither will the default
    scope other_ledger = new TestLedger(WK.Keys.A, [GenesisBlock]);
}

unittest
{
    scope ledger = new TestLedger(genesis_validator_keys[0]);
    scope fee_man = new FeeManager();

    // Generate payment transactions to the first 8 well-known keypairs
    auto txs = genesisSpendable().enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
        .array;
    txs.each!(tx => assert(ledger.acceptTransaction(tx) is null));
    ledger.forceCreateBlock();
    assert(ledger.height() == 1);

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
              .payload(data)
              .sign())
              .array;
    txs.each!(tx => assert(ledger.acceptTransaction(tx) is null));
    ledger.forceCreateBlock();
    assert(ledger.height() == 2);
    auto blocks = ledger.getBlocksFrom(Height(0)).take(10).array;
    assert(blocks.length == 3);
    assert(blocks[2].header.height == 2);

    auto not_coinbase_txs = blocks[2].txs.filter!(tx => tx.isPayment).array;
    foreach (ref tx; not_coinbase_txs)
    {
        assert(tx.outputs.any!(o => o.type != OutputType.Coinbase));
        assert(tx.outputs.length > 0);
        assert(tx.payload == data);
    }

    // Generate a block to reuse transactions used for data storage
    txs = txs.enumerate()
        .map!(en => TxBuilder(en.value)
              .refund(WK.Keys[en.index].address)
              .sign())
              .array;
    txs.each!(tx => assert(ledger.acceptTransaction(tx) is null));
    ledger.forceCreateBlock();
    assert(ledger.height() == 3);
    blocks = ledger.getBlocksFrom(Height(0)).take(10).array;
    assert(blocks.length == 4);
    assert(blocks[3].header.height == 3);
}

// create slashing data and check validity for that
unittest
{
    import agora.consensus.data.genesis.Test;
    import agora.consensus.PreImage;

    auto params = new immutable(ConsensusParams)(20);
    const(Block)[] blocks = [ GenesisBlock ];
    scope ledger = new TestLedger(genesis_validator_keys[0], blocks, params);

    Transaction[] genTransactions (Transaction[] txs)
    {
        return txs.enumerate()
            .map!(en => TxBuilder(en.value).refund(WK.Keys[en.index].address)
                .sign())
            .array;
    }

    Transaction[] genGeneralBlock (Transaction[] txs)
    {
        auto new_txs = genTransactions(txs);
        new_txs.each!(tx => assert(ledger.acceptTransaction(tx) is null));
        ledger.forceCreateBlock();
        return new_txs;
    }

    // generate payment transaction to the first 8 well-known keypairs
    auto genesis_txs = genesisSpendable().array;
    auto txs = genesis_txs[0 .. 4].enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign()).array;
    txs ~= genesis_txs[4 .. 8].enumerate()
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign()).array;
    txs.each!(tx => assert(ledger.acceptTransaction(tx) is null));
    ledger.forceCreateBlock();
    assert(ledger.height() == 1);

    // generate a block with only freezing transactions
    auto new_txs = txs[0 .. 4].enumerate()
        .map!(en => TxBuilder(en.value).refund(WK.Keys[en.index].address)
            .sign(OutputType.Freeze)).array;
    new_txs ~= txs[4 .. 7].enumerate()
        .map!(en => TxBuilder(en.value).refund(WK.Keys[en.index].address).sign())
        .array;
    new_txs ~= TxBuilder(txs[$ - 1]).split(WK.Keys[0].address.repeat(8)).sign();
    new_txs.each!(tx => assert(ledger.acceptTransaction(tx) is null));
    ledger.forceCreateBlock();
    assert(ledger.height() == 2);

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
    new_txs.each!(tx => assert(ledger.acceptTransaction(tx) is null));
    ledger.forceCreateBlock();
    assert(ledger.height() == 3);

    foreach (height; 4 .. params.ValidatorCycle)
    {
        new_txs = genGeneralBlock(new_txs);
        assert(ledger.height() == Height(height));
    }

    // add four new enrollments
    Enrollment[] enrollments;
    auto pairs = iota(4).map!(idx => WK.Keys[idx]).array;
    foreach (idx, kp; pairs)
    {
        auto enroll = EnrollmentManager.makeEnrollment(
            utxos[idx], kp, Height(params.ValidatorCycle), params.ValidatorCycle);
        assert(ledger.enrollment_manager.addEnrollment(enroll, kp.address,
            Height(params.ValidatorCycle),
            &ledger.peekUTXO, &ledger.getPenaltyDeposit));
        enrollments ~= enroll;
    }

    foreach (idx, hash; utxos)
    {
        Enrollment stored_enroll = ledger.enrollment_manager.enroll_pool.getEnrollment(hash);
        assert(stored_enroll == enrollments[idx]);
    }

    // create the last block of the cycle to make the `Enrollment`s enrolled
    new_txs = genGeneralBlock(new_txs);
    assert(ledger.height() == Height(20));
    auto b20 = ledger.getBlocksFrom(Height(20)).front;
    assert(b20.header.enrollments.length == 4);

    // block 21
    new_txs = genGeneralBlock(new_txs);
    assert(ledger.height() == Height(21));

    // check missing validators not revealing pre-images.
    auto temp_txs = genTransactions(new_txs);
    temp_txs.each!(tx => assert(ledger.acceptTransaction(tx) is null));

    // Add preimages for validators at height 22 but skip for a couple
    uint[] skip_indexes = [ 1, 3 ];
    ledger.simulatePreimages(Height(22), skip_indexes);

    ConsensusData data;
    ledger.prepareNominatingSet(data);
    assert(data.missing_validators.length == 2);
    assert(data.missing_validators == skip_indexes);

    // check validity of slashing information
    assert(ledger.validateSlashingData(Height(22), data, skip_indexes) == null);
    ConsensusData forged_data = data;
    forged_data.missing_validators = [3, 2, 1];
    assert(ledger.validateSlashingData(Height(22), forged_data, skip_indexes) != null);

    // Now reveal for all active validators at height 22
    ledger.simulatePreimages(Height(22));

    // there's no missing validator at the height of 22
    // after revealing preimages
    ledger.pool.remove(temp_txs);
    temp_txs = genTransactions(new_txs);
    temp_txs.each!(tx => assert(ledger.acceptTransaction(tx) is null));

    ledger.prepareNominatingSet(data);
    assert(data.missing_validators.length == 0);
}

unittest
{
    import agora.consensus.data.genesis.Test;
    import agora.consensus.PreImage;
    import agora.utils.WellKnownKeys : CommonsBudget;

    ConsensusConfig config = { validator_cycle: 20, payout_period: 5 };
    auto params = new immutable(ConsensusParams)(GenesisBlock,
        CommonsBudget.address, config);

    const(Block)[] blocks = [ GenesisBlock ];
    scope ledger = new TestLedger(genesis_validator_keys[0], blocks, params);

    // Add preimages for all validators (except for two of them) till end of cycle
    uint[] skip_indexes = [ 2, 5 ];

    ledger.simulatePreimages(Height(params.ValidatorCycle), skip_indexes);

    // Block with no fee
    auto no_fee_txs = blocks[$-1].spendable.map!(txb => txb.sign()).array();
    no_fee_txs.each!(tx => assert(ledger.acceptTransaction(tx) is null));

    ConsensusData data;
    ledger.prepareNominatingSet(data);

    assert(data.missing_validators == skip_indexes);
    assert(ledger.validateConsensusData(data, [2]) == "Higher bound violation - Missing validator mismatch [2, 5] is not a subset of [2]");
    assert(ledger.validateConsensusData(data, skip_indexes) is null);

    data.missing_validators = [2,3,5];
    assert(ledger.validateConsensusData(data, [2,3,5,7,9]) is null);

    data.missing_validators = [5];
    assert(ledger.validateConsensusData(data, [2]) == "Lower bound violation - Missing validator mismatch [2, 5] is not a subset of [5]");
}

/// Testing accumulated fees paid to Commons Budget and non slashed Validators
unittest
{
    import agora.consensus.data.genesis.Test;
    import agora.consensus.PreImage;
    import agora.utils.WellKnownKeys : CommonsBudget;

    const testPayoutPeriod = 5;
    ConsensusConfig config = { validator_cycle: 20, payout_period: testPayoutPeriod };
    auto params = new immutable(ConsensusParams)(GenesisBlock,
        CommonsBudget.address, config);
    assert(params.PayoutPeriod == testPayoutPeriod);
    const(Block)[] blocks = [ GenesisBlock ];
    scope ledger = new TestLedger(genesis_validator_keys[0], blocks, params);

    // Add preimages for all validators (except for two of them) till end of cycle
    uint[] skip_indexes = [ 2, 5 ];

    auto validators = ledger.getValidators(Height(1));
    UTXO[] mpv_stakes;
    foreach (skip; skip_indexes)
        assert(ledger.utxo_set.peekUTXO(validators[skip].utxo, mpv_stakes[(++mpv_stakes.length) - 1]));

    ledger.simulatePreimages(Height(params.ValidatorCycle), skip_indexes);

    assert(ledger.params.BlockInterval.total!"seconds" == 600);
    Amount allocated_validator_rewards = Amount.UnitPerCoin * 27 * (600 / 5);
    assert(allocated_validator_rewards == 3_240.coins);
    Amount commons_reward = Amount.UnitPerCoin * 50 * (600 / 5);
    assert(commons_reward == 6_000.coins);
    Amount total_rewards = (allocated_validator_rewards + commons_reward) * testPayoutPeriod;

    auto tx_set_fees = Amount(0);
    auto total_fees = Amount(0);
    Amount[] next_payout_total;
    // Create blocks from height 1 to 11 (only block 5 and 10 should have a coinbase tx)
    foreach (height; 1..11)
    {
        auto txs = blocks[$-1].spendable.map!(txb => txb.sign()).array();
        txs.each!(tx => assert(ledger.acceptTransaction(tx) is null));
        tx_set_fees = txs.map!(tx => tx.getFee(&ledger.utxo_set.peekUTXO, &ledger.getPenaltyDeposit)).reduce!((a,b) => a + b);

        // Add the fees for this height
        total_fees += tx_set_fees;

        auto data = ConsensusData.init;
        ledger.prepareNominatingSet(data);

        // Do some Coinbase tests with the data tx_set
        if (height >= 2 * testPayoutPeriod && height % testPayoutPeriod == 0)
        {
            // Remove the coinbase TX
            data.tx_set = data.tx_set[0 .. $ - 1];
            assert(ledger.validateConsensusData(data, skip_indexes) == "Missing matching Coinbase transaction");
            // Add different hash to tx_set
            data.tx_set ~= "Not Coinbase tx".hashFull();
            assert(ledger.validateConsensusData(data, skip_indexes) == "Missing matching Coinbase transaction");
        }

        // Now externalize the block
        ledger.prepareNominatingSet(data);

        total_fees += ledger.params.SlashPenaltyAmount * data.missing_validators.length;
        if (height % testPayoutPeriod == 0)
        {
            next_payout_total ~= total_fees + total_rewards;
            total_fees = Amount(0);
        }

        assert(ledger.externalize(data) is null);
        assert(ledger.height() == blocks.length);
        blocks ~= ledger.getBlocksFrom(Height(blocks.length)).front;

        auto cb_txs = blocks[$-1].txs.filter!(tx => tx.isCoinbase).array;
        if (height >= 2 * testPayoutPeriod && height % testPayoutPeriod == 0)
        {
            assert(cb_txs.length == 1);
            // Payout block should pay the CommonsBudget + all validators (excluding slashed validators)
            assert(cb_txs[0].outputs.length == 1 + genesis_validator_keys.length - skip_indexes.length);
            assert(cb_txs[0].outputs.map!(o => o.value).reduce!((a,b) => a + b) == next_payout_total[0]);
            next_payout_total = next_payout_total[1 .. $];
            // Slashed validators should never be paid
            mpv_stakes.each!((mpv_stake)
            {
                assert(cb_txs[0].outputs.filter!(output => output.address ==
                    mpv_stake.output.address).array.length == 0);
            });
        }
        else
            assert(cb_txs.length == 0);
    }
}

unittest
{
    import agora.consensus.data.genesis.Test;
    import agora.consensus.PreImage;

    {
        auto params = new immutable(ConsensusParams)(20, 80, Amount(10));
        const(Block)[] blocks = [ GenesisBlock ];
        scope ledger = new TestLedger(genesis_validator_keys[0], blocks, params);

        ushort min_fee_pct = 80;

        auto no_fee_tx = genesisSpendable().front().refund(WK.Keys[0].address).feeRate(0.coins).sign();
        assert(ledger.acceptTransaction(no_fee_tx, 0, min_fee_pct) !is null);

        auto average_tx = genesisSpendable().front().refund(WK.Keys[0].address).deduct(10.coins).sign();
        assert(ledger.acceptTransaction(average_tx, 0, min_fee_pct) is null);

        // switch to a different input, even with low fees this should be accepted since pool is almost empty
        auto different_tx = genesisSpendable().dropOne().front().refund(WK.Keys[0].address).deduct(1.coins).sign();
        assert(ledger.acceptTransaction(different_tx, 0, min_fee_pct) is null);

        // lower than average, but enough
        auto enough_fee_tx = genesisSpendable().dropOne().front().refund(WK.Keys[0].address).deduct(9.coins).sign();
        assert(ledger.acceptTransaction(enough_fee_tx, 0, min_fee_pct) is null);

        // overwrite the old TX
        auto high_fee_tx = genesisSpendable().dropOne().front().refund(WK.Keys[0].address).deduct(11.coins).sign();
        assert(ledger.acceptTransaction(high_fee_tx, 0, min_fee_pct) is null);
    }

    {
        auto params = new immutable(ConsensusParams)(20, 80, 0.coins, 0); // 0 max size, thus force average fee check on every TX
        const(Block)[] blocks = [ GenesisBlock ];
        scope ledger = new TestLedger(genesis_validator_keys[0], blocks, params);

        ushort min_fee_pct = 80;

        auto average_tx = genesisSpendable().front().refund(WK.Keys[0].address).deduct(10.coins).sign();
        assert(ledger.acceptTransaction(average_tx, 0, min_fee_pct) is null);

        // switch to a different input, with low fees this should be rejected because of average of fees in the pool
        auto different_tx = genesisSpendable().dropOne().front().refund(WK.Keys[0].address).deduct(1.coins).sign();
        assert(ledger.acceptTransaction(different_tx, 0, min_fee_pct) !is null);

        // lower than average, but enough
        auto enough_fee_tx = genesisSpendable().dropOne().front().refund(WK.Keys[0].address).deduct(9.coins).sign();
        assert(ledger.acceptTransaction(enough_fee_tx, 0, min_fee_pct) is null);

        // overwrite the old TX
        auto high_fee_tx = genesisSpendable().dropOne().front().refund(WK.Keys[0].address).deduct(11.coins).sign();
        assert(ledger.acceptTransaction(high_fee_tx, 0, min_fee_pct) is null);
    }
}

unittest
{
    import std.stdio;
    import agora.consensus.data.genesis.Test;
    import agora.consensus.PreImage;

    auto params = new immutable(ConsensusParams)(20);
    const(Block)[] blocks = [ GenesisBlock ];
    scope ledger = new TestLedger(genesis_validator_keys[0], blocks, params);

    auto missing_validator = 0;

    ledger.simulatePreimages(Height(params.ValidatorCycle), [missing_validator]);
    assert(ledger.getPenaltyDeposit(GenesisBlock.header.enrollments[missing_validator].utxo_key) != 0.coins);

    ConsensusData data;
    ledger.prepareNominatingSet(data);
    assert(data.missing_validators.canFind(missing_validator));
    assert(UTXOTracker.Tracked(GenesisBlock.header.enrollments[missing_validator].utxo_key) in ledger.getStakes());
    assert(ledger.externalize(data) is null);
    // slashed stake should not have penalty deposit
    assert(ledger.getPenaltyDeposit(GenesisBlock.header.enrollments[missing_validator].utxo_key) == 0.coins);
    assert(UTXOTracker.Tracked(GenesisBlock.header.enrollments[missing_validator].utxo_key) !in ledger.getStakes());
}

unittest
{
    import agora.consensus.data.genesis.Test;

    auto params = new immutable(ConsensusParams)();
    const(Block)[] blocks = [ GenesisBlock ];
    scope ledger = new TestLedger(genesis_validator_keys[0], blocks, params);
    ledger.simulatePreimages(Height(params.ValidatorCycle));

    auto freeze_tx = GenesisBlock.txs.find!(tx => tx.isFreeze).front();
    auto melting_tx = TxBuilder(freeze_tx, 0).sign();

    // enrolled stake can't be spent
    assert(ledger.acceptTransaction(melting_tx) !is null);
}

unittest
{
    import agora.consensus.data.genesis.Test;

    auto params = new immutable(ConsensusParams)();
    const(Block)[] blocks = [ GenesisBlock ];
    scope ledger = new TestLedger(genesis_validator_keys[0], blocks, params);
    ledger.simulatePreimages(Height(params.ValidatorCycle));

    KeyPair kp = WK.Keys.A;
    auto freeze_tx = genesisSpendable().front().refund(kp.address).sign(OutputType.Freeze);
    assert(ledger.acceptTransaction(freeze_tx) is null);
    ledger.forceCreateBlock();

    auto melting_tx = TxBuilder(freeze_tx, 0).sign();
    assert(ledger.acceptTransaction(melting_tx) is null);

    ConsensusData data;
    ledger.prepareNominatingSet(data);
    assert(data.tx_set.canFind(melting_tx.hashFull()));
    assert(ledger.validateConsensusData(data, []) is null);

    // can't enroll and spend the stake at the same height
    data.enrolls ~= EnrollmentManager.makeEnrollment(UTXO.getHash(freeze_tx.hashFull, 0), kp, Height(1), params.ValidatorCycle);

    import std.stdio;
    assert(ledger.validateConsensusData(data, []) !is null);
}

/// throw if the gen block in block storage is for a different chain id
unittest
{
    import agora.consensus.data.genesis.Test;

    immutable params = new immutable(ConsensusParams)();
    try
    {
        setHashMagic(0x44); // Test GenesisBlock is signed for ChainID=0
        scope ledger = new TestLedger(WK.Keys.A, [GenesisBlock], params);
        assert(0);
    } catch (Exception ex) {}

    setHashMagic(0); // should work just fine
    scope ledger = new TestLedger(WK.Keys.A, [GenesisBlock], params);
}

// test block is only externalized with a majority of block signatures
unittest
{
    import agora.consensus.data.genesis.Test;

    auto params = new immutable(ConsensusParams)();
    const(Block)[] blocks = [ GenesisBlock ];
    scope ledger = new TestLedger(genesis_validator_keys[0], blocks, params);
    ledger.simulatePreimages(Height(params.ValidatorCycle));

    auto expected_height = 0;
    // if less than 4 out of 6 validators sign it should not externalize
    iota(4).each!((signed)
    {
        assert(ledger.externalize(ConsensusData.init, signed)
            == "The majority of validators hasn't signed this block");
        assert(ledger.height == expected_height);
    });

    // if at least 4 out of 6 validators sign it should externalize
    iota(4, 7).each!((signed)
    {
        assert(!ledger.externalize(ConsensusData.init, signed));
        assert(ledger.height == ++expected_height);
    });
}

// test enrollment sigs and request for a future height
unittest
{
    import agora.consensus.data.genesis.Test;

    auto params = new immutable(ConsensusParams)();
    const(Block)[] blocks = [ GenesisBlock ];
    scope ledger = new TestLedger(genesis_validator_keys[0], blocks, params);
    ledger.simulatePreimages(Height(params.ValidatorCycle));

    KeyPair kp = WK.Keys.NODE10;
    assert(GenesisBlock.txs[1].outputs[1].address == WK.Keys.NODE10.address);
    auto stake = UTXO.getHash(GenesisBlock.txs[1].hashFull, 1);

    auto enrollment = EnrollmentManager.makeEnrollment(stake, kp, Height(5), 20);
    // wrong height, rejected
    assert(!ledger.enrollment_manager.addEnrollment(enrollment, kp.address,
        Height(4), &ledger.peekUTXO, &ledger.getPenaltyDeposit));

    assert(ledger.enrollment_manager.addEnrollment(enrollment, kp.address,
        Height(5), &ledger.peekUTXO, &ledger.getPenaltyDeposit));

    while (ledger.height() != Height(5))
        ledger.forceCreateBlock();
    assert(ledger.lastBlock.header.height == Height(5));
    assert(ledger.lastBlock.header.enrollments.canFind(enrollment));
}

// Test max TX size is respected while validating and nominating values
unittest
{
    import agora.consensus.data.genesis.Test;

    {
        auto params = new immutable(ConsensusParams)(20, 80, 0.coins, 1); // 1 KB Tx set size
        assert(params.MaxTxSetSize == 1);
        const(Block)[] blocks = [ GenesisBlock ];
        scope ledger = new TestLedger(genesis_validator_keys[0], blocks, params);
        ledger.simulatePreimages(Height(params.ValidatorCycle));

        // Generate payment transactions to the first 8 well-known keypairs
        auto txs = genesisSpendable().enumerate()
            .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
            .array;
        auto total_size = txs.map!(tx => tx.sizeInBytes()).sum();
        assert(total_size > params.MaxTxSetSize * 1024);
        txs.each!(tx => assert(ledger.acceptTransaction(tx) is null));

        ledger.forceCreateBlock();
        assert(ledger.lastBlock().txs.length < txs.length);
    }

    {
        auto params = new immutable(ConsensusParams)(20, 80, 0.coins); // default Tx set size
        const(Block)[] blocks = [ GenesisBlock ];
        scope ledger = new TestLedger(genesis_validator_keys[0], blocks, params);
        ledger.simulatePreimages(Height(params.ValidatorCycle));

        // Generate payment transactions to the first 8 well-known keypairs
        auto txs = genesisSpendable().enumerate()
            .map!(en => en.value.refund(WK.Keys[en.index].address).sign())
            .array;
        auto total_size = txs.map!(tx => tx.sizeInBytes()).sum();
        assert(total_size < params.MaxTxSetSize * 1024);
        txs.each!(tx => assert(ledger.acceptTransaction(tx) is null));
        ledger.forceCreateBlock();
        assert(ledger.lastBlock().txs.length >= txs.length);
    }
}

// test enrollments whose stake is spent is cleared from the pool
unittest
{
    import agora.consensus.data.genesis.Test;

    auto params = new immutable(ConsensusParams)();
    const(Block)[] blocks = [ GenesisBlock ];
    scope ledger = new TestLedger(genesis_validator_keys[0], blocks, params);
    ledger.simulatePreimages(Height(params.ValidatorCycle));

    KeyPair kp = WK.Keys.NODE10;
    assert(GenesisBlock.txs[1].outputs[1].address == WK.Keys.NODE10.address);
    auto stake = UTXO.getHash(GenesisBlock.txs[1].hashFull, 1);

    auto enrollment = EnrollmentManager.makeEnrollment(stake, kp, Height(5), 20);
    assert(ledger.enrollment_manager.addEnrollment(enrollment, kp.address,
        Height(5), &ledger.peekUTXO, &ledger.getPenaltyDeposit));
    assert(ledger.enrollment_manager.enroll_pool.hasEnrollment(stake, Height(5)));

    auto melting_tx = TxBuilder(GenesisBlock.txs[1], 1).sign();
    assert(ledger.acceptTransaction(melting_tx) is null);

    ledger.forceCreateBlock();
    assert(ledger.lastBlock.txs.canFind(melting_tx));
    assert(!ledger.enrollment_manager.enroll_pool.hasEnrollment(stake, Height(5)));
}
