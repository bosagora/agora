/*******************************************************************************

    The `Ledger` class binds together other components to provide a consistent
    view of the state of the node.

    The Ledger acts as a bridge between other components, e.g. the `UTXOSet`,
    `EnrollmentManager`, `IBlockStorage`, etc...

    The most basic class, `Ledger`, is found in this module. Other derived
    classes might provide more advanced features, e.g. nodes use either
    `NodeLedger` or a class derived from it, which includes pools,
    allowing to reduce network communication and/or perform validation.

    Copyright:
        Copyright (c) 2019-2022 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.state.Ledger;

import agora.common.Amount;
import agora.common.Ensure;
import agora.common.ManagedDatabase;
import agora.common.Types;
import agora.consensus.BlockStorage;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.Fee;
import agora.consensus.Reward;
import agora.consensus.state.UTXOSet;
import agora.consensus.state.ValidatorSet;
import agora.consensus.validation;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.script.Engine;
import agora.serialization.Serializer;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

import std.algorithm;
import std.format;
import std.range;

version (unittest)
{
    import agora.utils.Test;
}

/// Ditto
public class Ledger
{
    /// Logger instance
    protected Logger log;

    /// Script execution engine
    protected Engine engine;

    /// The database in which the Ledger state is stored
    protected ManagedDatabase stateDB;

    /// data storage for all the blocks
    protected IBlockStorage storage;

    /// The last block in the ledger
    protected Block last_block;

    /// UTXO set
    protected UTXOCache utxo_set;

    /// The object controlling the validator set
    protected ValidatorSet validator_set;

    /// The checker of transaction data payload
    protected FeeManager fee_man;

    /// Block rewards calculator
    protected Reward rewards;

    /// Cache for Coinbase tx to be used during payout height
    protected struct CachedCoinbase
    {
        ///
        protected Height height;

        ///
        protected Transaction tx;
    }

    /// Ditto
    protected CachedCoinbase cached_coinbase;

    /***************************************************************************

        Consensus-critical constants used by this Ledger

        Expose the `ConsensusParams` the `Ledger` is instantiated with.
        In the main BOSAGORA network, this should be the default-constructed
        consensus params. However, alternative network (such as TestNet) may
        use a different set of parameters to achieve different outcome
        (e.g. different externalization time or staking requirements).

    ***************************************************************************/

    public immutable(ConsensusParams) params;

    /***************************************************************************

        Constructor

        Params:
            params = the consensus-critical constants
            database = State database
            storage = the block storage
            engine = script execution engine
            validator_set = object managing the set of validators

    ***************************************************************************/

    public this (immutable(ConsensusParams) params, ManagedDatabase database,
        IBlockStorage storage, ValidatorSet validator_set)
    {
        this.log = Logger(__MODULE__);
        this.params = params;
        this.stateDB = database;
        this.storage = storage;
        this.utxo_set = new UTXOSet(database);
        this.fee_man = new FeeManager(database, params);
        this.validator_set = validator_set;
        this.storage.load(params.Genesis);
        this.rewards = new Reward(this.params.PayoutPeriod, this.params.BlockInterval);
        this.engine = new Engine();

        // ensure latest checksum can be read
        this.last_block = this.storage.readLastBlock();
        log.info("Last known block: #{} ({})", this.last_block.header.height,
                 this.last_block.header.hashFull());

        Block gen_block = this.storage.readBlock(Height(0));
        ensure(gen_block.hashFull() == params.Genesis.hashFull(),
                "Genesis block loaded from disk ({}) is different from the one in the config file ({})",
                gen_block.hashFull(), params.Genesis.hashFull());

        if (this.utxo_set.length == 0
            || this.validatorCount(this.last_block.header.height + 1) == 0)
        {
            this.utxo_set.clear();
            this.validator_set.removeAll();

            // Calling `addValidatedBlock` will reset this value
            const HighestHeight = this.last_block.header.height;
            foreach (height; 0 .. HighestHeight + 1)
            {
                this.replayStoredBlock(this.storage.readBlock(Height(height)));
            }
        }
    }

    /// Create an instance of the Ledger suitable for unittests
    version (unittest) public this ()
    {
        auto params = new immutable(ConsensusParams)();
        auto stateDB = new ManagedDatabase(":memory:");
        auto storage = new MemBlockStorage();
        auto vset = new ValidatorSet(stateDB, params);
        this(params, stateDB, storage, vset);
    }

    /***************************************************************************

        Returns a reference to the last block in the `Ledger`

        The last block is made available mostly for convenience. In general,
        users should rely on the various other functions which provide a view
        of the UTXO set and the validator sets, the two main output of the
        consensus process.

        Returns:
            last block in the `Ledger`

    ***************************************************************************/

    public ref const(Block) lastBlock () const scope @safe @nogc nothrow pure
    {
        return this.last_block;
    }

    /***************************************************************************

        Returns the height at which this `Ledger` is currently at

        The value returned by this method will only ever increase or stall,
        and shall never decrease. If the need arrive to compare `Ledger` state,
        use `ledger.lastBlock().hashFull()`.

        Returns:
            The highest block height known to this Ledger

    ***************************************************************************/

    public Height height () const scope @safe @nogc nothrow pure
    {
        return this.last_block.header.height;
    }

    /***************************************************************************

        Expose the list of validators at a given height

        The `ValidatorInfo` struct contains the validator's UTXO hash, address,
        stake and currently highest known pre-image.
        It always returns valid historical data (although the pre-image might
        be the current one).

        Callers expecting the pre-image at a given height should first check
        that the `height` is above or equal their expectation, then use
        the `opIndex` method to get the correct value for the height they
        are interested in. This method doesn't expose a mean to do so directly
        because it would then need to filter out missing validators,
        which would give the caller wrong indexes for validators.

        Params:
          height = Height at which to query the validator set.
                   Accurate results are only guaranteed for
                   `height <= this.height() + 1`.
          empty = Whether to allow an empty return value.
                  By default, this function will throw if there is no validators
                  at `height`. If `true` is passed, it will not.

        Throws:
          If no validators are present at height `height` and `empty` is `false`.

        Returns:
            A list of validators that are active at `height`

    ***************************************************************************/

    public ValidatorInfo[] getValidators (in Height height, bool empty = false)
        scope @safe
    {
        // There are no validators at Genesis, and no one able to sign the block
        // This is by design, and to allow calling code to work correctly without
        // special-casing height == 0, we just return `null`.
        if (height == 0) return null;

        auto result = this.validator_set.getValidators(height);
        ensure(empty || result.length > 0,
               "Ledger.getValidators didn't find any validator at height {}", height);
        return result;
    }

    /***************************************************************************

        Get the count of active validators at a given height.

        This function is more efficient than checking the length of the array
        returned by `getValidators` as it avoids any intermediate allocation.
        An 'active' validator is one that hasn't been slashed,
        and may sign a block. A validator that enrolls, reveal all its
        pre-images but never sign a block will still be counted as 'active'.

        Params:
          height = Height at which to query the validator set.
                   Accurate results are only guaranteed for
                   `height <= this.height() + 1`.

        Returns:
          Number of active validators at `height`.

    ***************************************************************************/

    public size_t validatorCount (in Height height) scope @safe nothrow
    {
        return this.validator_set.countActive(height);
    }

    /***************************************************************************

        Expose an object that interacts with the UTXO set

        The UTXO set is the main output of the consensus protocol: it contains
        all outstanding balances in the network, and as a consequence
        may be large. Consequently, the returned `UTXOCache` allows to interact
        with it in an efficient manner, for example allowing to iterate over
        the whole set without allocating it as an array.

        Returns:
          An object implementing the `UTXOCache` interface

    ***************************************************************************/

    public UTXOCache utxos () return @safe pure nothrow @nogc
    {
        return this.utxo_set;
    }

    /***************************************************************************

        Add a pre-image information to the validator data

        The `Ledger` keeps track of "pre-image", which are hashes that
        validators need to periodically reveal in order to avoid getting
        financially penalized (slashed).

        Two Ledgers at the same height may have different knowledge
        of pre-images, however they have the same knowledge of pre-images
        at the height they are at.

        Params:
            preimage = the pre-image information to add

        Returns:
            true if the pre-image information has been accepted by the Ledger

    ***************************************************************************/

    public bool addPreimage (in PreImageInfo preimage) @safe nothrow
    {
        return this.validator_set.addPreimage(preimage);
    }

    /***************************************************************************

        Attempt to add a block to the `Ledger`.

        The block should have a majority of signature to be added,
        and will then be validated (via `validateBlock`) before being
        externalized. If validation failes, the reason will be returned,
        and the `Ledger` will not be modifed.

        Params:
            block = the block to add

        Returns:
            an error message if the block is not accepted, otherwise null

    ***************************************************************************/

    public string acceptBlock (in Block block) @safe
    {
        // Make the Ledger tolerant to externalization of already-known block,
        // but only of the latest height.
        if (this.last_block.header.height == block.header.height)
            return (this.last_block.hashFull() == block.hashFull())
                ? null
                : "Trying to externalize a different block for the latest height";

        if (auto fail_reason = this.validateBlock(block))
        {
            log.trace("Rejected block: {}: {}", fail_reason, block.prettify());
            return fail_reason;
        }

        this.addValidatedBlock(block);
        this.storage.saveBlock(block);

        return null;
    }

    /***************************************************************************

        Update the Schnorr multi-signature for an externalized block
        in the Ledger.

        Params:
            header = block header to be updated

    ***************************************************************************/

    public void updateBlockMultiSig (in BlockHeader header) @safe
    {
        this.storage.updateBlockSig(header.height, header.hashFull(),
            header.signature, header.validators);

        if (header.height == this.last_block.header.height)
            this.last_block = this.storage.readLastBlock();
    }

    /***************************************************************************

        Add a validated block to the Ledger.

        This will add all of the block's outputs to the UTXO set, as well as
        any enrollments that may be present in the block to the validator set.

        This internal method can be overriden in derived class to catch `Block`
        externalization event.

        Params:
            block = the block to add

    ***************************************************************************/

    protected void addValidatedBlock (in Block block) @safe
    {
        log.info("Beginning externalization of block #{} (block signatures: {})",
            block.header.height, this.last_block.header.validators);
        log.info("Transactions: {} - Enrollments: {}",
            block.txs.length, block.header.enrollments.length);
        log.info("Validators: Active: {} - Signing: {} - Slashed: {}",
            this.validatorCount(block.header.height + 1),
            block.header.validators,
            block.header.preimages.count!(h => h is Hash.init));
        // Keep track of the fees generated by this block, before updating the
        // validator set

        () @trusted { this.stateDB.begin(); }();
        {
            // rollback on failure within the scope of the db transactions
            scope (failure) () @trusted { this.stateDB.rollback(); }();
            // Store the fees for this block if not Genesis
            if (block.header.height > 0)
                this.fee_man.storeValidatedBlockFees(block, this.utxo_set.getUTXOFinder,
                    &this.getPenaltyDeposit);
            this.applySlashing(block.header);
            this.updateUTXOSet(block);
            this.updateValidatorSet(block);
            () @trusted { this.stateDB.commit(); }();
        }

        // if this was a block with fees payout
        if (block.header.height >= 2 * this.params.PayoutPeriod
            && block.header.height % this.params.PayoutPeriod == 0)
        {
            // Clear out paid fees
            this.fee_man.clearBlockFeesBefore(Height(block.header.height - this.params.PayoutPeriod));
        }
        // Update the known "last block"
        this.last_block = deserializeFull!Block(serializeFull(block));
        log.info("Completed externalization of block #{}(block signatures: {})",
            block.header.height, this.last_block.header.validators);
    }

    /***************************************************************************

        Update the ledger state from a block which was read from storage

        Called from the constructor with the content of the disk storage in
        case the validator set or UTXO set is invalid.

        Params:
            block = block to update the state from

    ***************************************************************************/

    protected void replayStoredBlock (in Block block) @safe
    {
        // Make sure our data on disk is valid
        if (auto fail_reason = this.validateBlock(block))
            ensure(false, "A block loaded from disk is invalid: {}", fail_reason);

        this.addValidatedBlock(block);
    }

    /***************************************************************************

        Apply slashing to the current state

        When a node is slashed, two actions are taken:
        - First, it is "removed" from the validator set;
          In practice, we store the height at which a node is slashed.
        - Second, its stake is consumed: One refund is created to the key
          controlling the stake, and a penalty is sent to the commons budget.

        This is the first action that happens during block externalization,
        so that slashed UTXOs are not spent by transactions.

        Params:
            header = The `BlockHeader` containing the slashing information

    ***************************************************************************/

    protected void applySlashing (in BlockHeader header) @safe
    {
        // In the most common case, there should be no slashing information.
        // In this case, we should avoid calling `getValidators`, as it allocates,
        // and doesn't handle Genesis.
        auto slashed = header.preimages.enumerate
            .filter!(en => en.value is Hash.init).map!(en => en.index);
        if (slashed.empty)
            return;

        auto validators = this.getValidators(header.height);

        foreach (idx; slashed)
        {
            const validator = validators[idx];
            UTXO utxo_value;
            if (!this.utxo_set.peekUTXO(validator.utxo, utxo_value))
                assert(0, "UTXO for the slashed validator not found!");

            log.warn("Slashing validator {} at height {}: {} (UTXO: {})",
                     idx, header.height, validator, utxo_value);
            this.validator_set.slashValidator(validator.utxo, header.height);
        }
    }

    /***************************************************************************

        Update the UTXO set based on the block's transactions

        Params:
            block = the block to update the UTXO set with

    ***************************************************************************/

    protected void updateUTXOSet (in Block block) @safe
    {
        const height = block.header.height;
        // add the new UTXOs
        block.txs.each!(tx => this.utxo_set.updateUTXOCache(tx, height,
            this.params.CommonsBudgetAddress));
    }

    /***************************************************************************

        Update the active validator set

        Params:
            block = the block to update the Validator set with

    ***************************************************************************/

    protected void updateValidatorSet (in Block block) @safe
    {
        foreach (idx, ref enrollment; block.header.enrollments)
        {
            UTXO utxo;
            if (!this.utxo_set.peekUTXO(enrollment.utxo_key, utxo))
                assert(0);

            if (auto r = this.validator_set.add(block.header.height,
                    &this.utxo_set.peekUTXO, &this.getPenaltyDeposit,
                    enrollment, utxo.output.address))
            {
                log.fatal("Error while adding a new validator: {}", r);
                log.fatal("Enrollment #{}: {}", idx, enrollment);
                log.fatal("Validated block: {}", block);
                assert(0);
            }
            this.utxo_set.updateUTXOLock(enrollment.utxo_key, block.header.height + this.params.ValidatorCycle);
        }
    }

    /***************************************************************************

        Create the `Coinbase transaction` for this payout block and append it
        to the `transaction set`

        Params:
            height = block height
            tot_fee = Total fee amount (incl. data)
            tot_data_fee = Total data fee amount

        Returns:
            `Coinbase transaction`

    ***************************************************************************/

    protected Transaction getCoinbaseTX (in Height height) nothrow @safe
    {
        assert(height >= 2 * this.params.PayoutPeriod);

        if (cached_coinbase.height == height)
            return cached_coinbase.tx;

        Output[] coinbase_tx_outputs;

        Amount[PublicKey] payouts;

        // pay the Validators and Commons Budget for the blocks in the penultimate payout period
        const firstPayoutHeight = Height(1 + height - 2 * this.params.PayoutPeriod);
        try
        {
            this.getBlocksFrom(firstPayoutHeight)
                .takeExactly(this.params.PayoutPeriod)
                .map!(block => block.header)
                .each!((BlockHeader header)
                    {
                        // Fetch validators at this height and filter out those who did not sign
                        // the block as they will not get paid for this block
                        auto validators = this.getValidators(header.height)
                            .enumerate.filter!(en => header.validators[en.index]).map!(en => en.value);

                        // penalty for utxos slashed on this height
                        auto slashed_penaly = this.params.SlashPenaltyAmount *
                            header.preimages.enumerate.filter!(en => en.value is Hash.init).walkLength;
                        payouts.update(this.params.CommonsBudgetAddress,
                            { return slashed_penaly; },
                            (ref Amount so_far)
                            {
                                so_far += slashed_penaly;
                                return so_far;
                            }
                        );

                        // Calculate the block rewards using the percentage of validators who signed
                        auto rewards = this.rewards.calculateBlockRewards(header.height, header.validators.percentage());

                        // Divide up the validator fees and rewards based on stakes
                        auto val_payouts = this.fee_man.getValidatorPayouts(header.height, rewards, validators);

                        // Update the payouts that will be included in the Coinbase tx for each validator
                        val_payouts.zip(validators).each!((Amount payout, ValidatorInfo validator) =>
                            payouts.update(validator.address,
                                { return payout; }, // if first for this validator use this payout
                                    (ref Amount so_far) // otherwise use delegate to keep running total
                                    {
                                        so_far += payout; // Add this payout to sum so far
                                        return so_far;
                                    }));
                        auto commons_payout = this.fee_man.getCommonsBudgetPayout(header.height, rewards, val_payouts);
                        payouts.update(this.params.CommonsBudgetAddress,
                            { return commons_payout; },
                                (ref Amount so_far)
                                    {
                                        so_far += commons_payout;
                                        return so_far;
                                    });
                    });
            assert(payouts.length > 0);
            foreach (pair; payouts.byKeyValue())
            {
                if (pair.value > Amount(0))
                    coinbase_tx_outputs ~= Output(pair.value, pair.key, OutputType.Coinbase);
                else
                    log.error("Zero valued Coinbase output for key {}\npayouts={}", pair.key, payouts);
            }
            assert(coinbase_tx_outputs.length > 0, format!"payouts=%s"(payouts));
            coinbase_tx_outputs.sort;

            cached_coinbase.height = height;
            cached_coinbase.tx = Transaction([Input(height)], coinbase_tx_outputs);
            return cached_coinbase.tx;
        }
        catch (Exception e)
        {
            assert(0, format!"getCoinbaseTX: Exception thrown:%s"(e.msg));
        }
    }

    /// Returns: Whether the `utxo` can be used as a stake for a validator
    public bool isStake (in Hash hash, in Output utxo) scope @safe
    {
        if (utxo.type != OutputType.Freeze)
            return false;
        if (utxo.value < Amount.MinFreezeAmount)
            return false;
        EnrollmentState last_enrollment;
        if (this.validator_set.findRecentEnrollment(hash, last_enrollment))
            return last_enrollment.slashed_height == 0;
        return true;
    }

    ///
    public Amount getPenaltyDeposit (Hash utxo) @safe nothrow
    {
        UTXO utxo_val;
        if (!this.peekUTXO(utxo, utxo_val) || utxo_val.output.type != OutputType.Freeze)
            return 0.coins;
        EnrollmentState last_enrollment;
        if (this.validator_set.findRecentEnrollment(utxo, last_enrollment) && last_enrollment.slashed_height != 0)
            return 0.coins;
        return this.params.SlashPenaltyAmount;
    }

    /***************************************************************************

        Check whether the block is valid.

        Params:
            block = the block to check

        Returns:
            an error message if the block validation failed, otherwise null

    ***************************************************************************/

    public string validateBlock (in Block block) nothrow @safe
    {
        // If it's the genesis block, we only need to validate it for syntactic
        // correctness, no need to check signatures.
        if (block.header.height == 0)
            return block.isGenesisBlockInvalidReason();

        // Validate the block syntactically first, so we weed out obviously-wrong
        // blocks without complex computation.
        if (auto reason = block.isInvalidReason(
                this.engine, this.last_block.header.height,
                this.last_block.header.hashFull,
                this.utxo_set.getUTXOFinder(),
                &this.fee_man.check,
                &this.validator_set.findRecentEnrollment,
                &this.getPenaltyDeposit,
                block.header.validators.count))
            return reason;

        // At this point we know it is the next block and also that it isn't Genesis
        try
        {
            const validators = this.getValidators(block.header.height);
            if (validators.length != block.header.preimages.length)
                return "Block: Number of preimages does not match active validators";
            foreach (idx, const ref hash; block.header.preimages)
            {
                if (hash is Hash.init) // Slashed
                    continue;
                // We don't have this pre-image yet
                if (validators[idx].preimage.height < block.header.height)
                {
                    PreImageInfo pi = validators[idx].preimage;
                    pi.height = block.header.height;
                    pi.hash = hash;
                    if (!this.addPreimage(pi))
                        return "Block: Preimages include an invalid non-revealed pre-image";
                }
                else
                {
                    // TODO: By caching the 'current' hash, we can prevent a semi
                    // DoS if a node reveal a pre-image far in the future and then
                    // keep on submitting wrong blocks.
                    const expected = validators[idx].preimage[Height(block.header.height)];
                    if (hash !is expected)
                    {
                        log.error("Validator: {} - Index: {} - Expected: {} - Got: {}",
                                  validators[idx], idx, expected, hash);
                        return "Block: One of the pre-image is invalid";
                    }
                }
            }
        }
        catch (Exception exc)
        {
            log.error("Exception thrown while validating block: {}", exc);
            return "Block: Internal error while validating";
        }

        auto incoming_cb_txs = block.txs.filter!(tx => tx.isCoinbase);
        const cbTxCount = incoming_cb_txs.count;
        // If it is a payout block then a single Coinbase transaction is included
        if (block.header.height >= 2 * this.params.PayoutPeriod
            && block.header.height % this.params.PayoutPeriod == 0)
        {
            if (cbTxCount == 0)
                return "Missing expected Coinbase transaction in payout block";
            if (cbTxCount > 1)
                return "There should only be one Coinbase transaction in payout block";
        }
        else if (cbTxCount != 0)
            return "Found Coinbase transaction in a non payout block";

        // Finally, validate the signatures
        return this.validateBlockSignature(block.header);
    }

    /***************************************************************************

        Validate the signature of a block

        This validate that the signature in a block header is consistent with
        the enrolled validators, and cryptographically correct.
        Note that since this requires to know which nodes are validators,
        this method is contextful and can only guarantee the signature
        of the next block, as the validator set might change after that.

        Implementation_details:
          A block signature is an Schnorr signature. Schnorr signatures are
          usually a pair `(R, s)`, consisting of a point `R` and a scalar `s`.

          The signature is done on the block header, with the two fields
          used to store signatures (`validators` and `signature`) excluded.

          To allow for nodes to independently generate compatible signatures
          without an additional protocol, nodes need to know the set of signers
          and their `R`, which we refer to as signature noise.

          The set of signers is defined as all the validators having revealed
          a pre-image. For this reason, pre-images are allowed and encouraged
          to be revealed earlier than they are needed (although not too early).

          With the set of signers known, we derive the block-specific `R`
          by adding the `R` used in the enrollment to `p * B`, where `p` is
          the pre-image reduced to a scalar and `B` is Curve25519 base point.

          Hence, the signature present in the block is actually just the
          aggregated `s`. To verify this signature, we need to store which
          nodes actually signed, this is stored in the header's
          `validators` field.

        Params:
            block = the block to verify the signature of

        Returns:
            the error message if block validation failed, otherwise null

    ***************************************************************************/

    public string validateBlockSignature (in BlockHeader header) @safe nothrow
    {
        import agora.crypto.ECC;

        Point sum_K;
        Scalar sum_s;
        const Scalar challenge = hashFull(header);
        ValidatorInfo[] validators;
        try
            validators = this.getValidators(header.height);
        catch (Exception exc)
        {
            this.log.error("Exception thrown by getActiveValidatorPublicKey while externalizing valid block: {}", exc);
            return "Internal error: Could not list active validators at current height";
        }

        // Check that more than half have signed
        if (!this.hasMajoritySignature(header))
            if (auto fail_msg = this.handleNotSignedByMajority(header, validators))
                return fail_msg;

        log.trace("Checking signature, participants: {}/{}", header.validators.setCount, validators.length);
        foreach (idx, validator; validators)
        {
            const K = validator.address;
            assert(K != PublicKey.init, "Could not find the public key associated with a validator");

            if (!header.validators[idx])
            {
                // This is not an error, we might just receive the signature later
                log.trace("Block#{}: Validator {} (idx: {}) has not yet signed",
                          header.height, K, idx);
                continue;
            }

            const pi = header.preimages[idx];
            // TODO: Currently we consider that validators slashed at this height
            // can sign the block (e.g. they have a space in the bit field),
            // however without their pre-image they can't sign the block.
            if (pi is Hash.init)
                continue;

            sum_K = sum_K + K;
            sum_s = sum_s + Scalar(pi);
        }

        assert(sum_K != Point.init, "Block has validators but no signature");

        // If this doesn't match, the block is not self-consistent
        if (sum_s != header.signature.s)
        {
            log.error("Block#{}: Signature's `s` mismatch: Expected {}, got {}",
                      header.height, sum_s, header.signature.s);
            return "Block: Invalid schnorr signature (s)";
        }
        if (!BlockHeader.verify(sum_K, sum_s, header.signature.R, challenge))
        {
            log.error("Block#{}: Invalid signature: {}", header.height,
                      header.signature);
            return "Block: Invalid signature";
        }

        return null;
    }

    /***************************************************************************

        Used to handle behaviour when less than half the validators have signed
        the block. This is overridden in the `ValidatingLedger`

        Params:
            header = header of block we checked
            validators = validator info for the ones that did sign

    ***************************************************************************/

    protected string handleNotSignedByMajority (in BlockHeader header,
        in ValidatorInfo[] validators) @safe nothrow
    {
        log.info("Block#{}: Signatures are not majority: {}/{}, signers: {}",
            header.height, header.validators.setCount, header.validators.count,
            validators.map!(v => v.address));
        return "The majority of validators hasn't signed this block";
    }

    /***************************************************************************

        Params:
            header = header to check the signatures of
            validators = validator info for the active validators

        Returns:
            If the signatures have reached majority

    ***************************************************************************/

    public bool hasMajoritySignature (in BlockHeader header) @safe nothrow
    {
        if (header.height == 0)  // Genesis block is not signed
            return true;
        // Check that more than half have signed
        return  header.validators.percentage > 50;
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
        start_height = min(start_height, this.height() + 1);

        // Call to `Height.value` to work around
        // https://issues.dlang.org/show_bug.cgi?id=21583
        return iota(start_height.value, this.height() + 1)
            .map!(idx => this.storage.readBlock(Height(idx)));
    }

    /***************************************************************************

        Create a new block based on the current previous block.

        This function only builds a block and will not externalize it.
        See `acceptBlock` for this.

        Params:
          txs = An `InputRange` of `Transaction`s
          enrollments = New enrollments for this block (can be `null`)
          missing_validators = Indices of slashed validators (may be `null`)

        Returns:
          A newly created block based on the current block
          (See `Ledger.lastBlock()` and `Ledger.height()`)

    ***************************************************************************/

    public Block buildBlock (Transactions) (Transactions txs,
        Enrollment[] enrollments, uint[] missing_validators)
        @safe
    {
        const height = this.height() + 1;
        const validators = this.getValidators(height);

        Hash[] preimages = validators.enumerate.map!(
            (in entry)
            {
                if (missing_validators.canFind(entry.index))
                    return Hash.init;

                if (entry.value.preimage.height < height)
                {
                    ensure(false,
                           "buildBlock: Missing pre-image ({} < {}) for index {} ('{}') " ~
                           "but index is not in missing_validators ({})",
                           entry.value.preimage.height, height,
                           entry.index, entry.value.utxo, missing_validators);
                }

                return entry.value.preimage[height];
            }).array;

        return this.last_block.makeNewBlock(txs, preimages, enrollments);
    }

    /// return the last paid out block before the current block
    public Height getLastPaidHeight () const scope @safe @nogc nothrow pure
    {
        return lastPaidHeight(this.height, this.params.PayoutPeriod);
    }

    /***************************************************************************

        Get an UTXO, no double-spend protection.

        Params:
            hash = the hash of the UTXO (`hashMulti(tx_hash, index)`)
            value = the UTXO

        Returns:
            true if the UTXO was found

    ***************************************************************************/

    public bool peekUTXO (in Hash utxo, out UTXO value) nothrow @safe
    {
        return this.utxo_set.peekUTXO(utxo, value);
    }

    /// Returns: UTXOs for validator active at the given height
    public UTXO[Hash] getEnrolledUTXOs (in Height height) @safe nothrow
    {
        UTXO[Hash] utxos;
        Hash[] keys;
        if (this.validator_set.getEnrolledUTXOs(height, keys))
            foreach (key; keys)
            {
                UTXO val;
                assert(this.peekUTXO(key, val));
                utxos[key] = val;
            }
        return utxos;
    }

    /// Ditto
    public UTXO[Hash] getEnrolledUTXOs () @safe nothrow
    {
        return this.getEnrolledUTXOs(this.height() + 1);
    }

    /***************************************************************************

        Prepare tracking double-spent transactions and
        return the UTXOFinder delegate

        Returns:
            the UTXOFinder delegate

    ***************************************************************************/

    public UTXOFinder getUTXOFinder () nothrow @trusted
    {
        return this.utxo_set.getUTXOFinder();
    }

    version (unittest):

}

/// This is the last block height that has had fees and rewards paid before the current block
private Height lastPaidHeight(in Height height, uint payout_period) @safe @nogc nothrow pure
{
    // We return 1 before the first payout is made as we use this for block signature catchup and Genesis is never updated
    if (height < 2 * payout_period)
        return  Height(1);
    return Height(height - (height % payout_period) - payout_period);
}

// expected is the height of last block that has had fees and rewards paid
unittest
{
    import std.range;
    import std.typecons;

    const uint paymentPeriod = 3;
    only(tuple(0,1), tuple(1,1), tuple(4,1), tuple(5,1), // test before first fee and reward block is externalized
        tuple(6,3), tuple(7,3), tuple(8,3), // test before second is externalized
        tuple(9,6), tuple(10,6)).each!( // last we test after second
        (height, expected) => assert(lastPaidHeight(Height(height), paymentPeriod) == expected));
}

/*******************************************************************************

    Tracks a set of UTXO according to an inclusion criteria

    An abstract base class that can be used to track UTXOs,
    e.g. to track UTXOs belonging to a set of keys, or matching a certain value.

*******************************************************************************/

public abstract class UTXOTracker
{
    import agora.common.Set;
    import std.typecons;

    /// Type of data we keep track of
    public struct Tracked
    {
        /// Hash of the UTXO
        public Hash hash;

        /// Output itself
        public Output output;

        /// Used by Set
        public hash_t toHash () const scope @trusted pure nothrow @nogc
        {
            return *(cast(hash_t*) this.hash[].ptr);
        }

        /// Ditto
        public bool opEquals (in Tracked other) const scope @safe pure nothrow @nogc
        {
            return this.hash == other.hash;
        }

        public int opCmp (in Tracked other) const scope @safe pure nothrow @nogc
        {
            return this.hash.opCmp(other.hash);
        }
    }

    /// The underlying data
    protected Set!Tracked data_;

    /// Returns: The currently tracked set
    /// Note: Should be `const` but `Set` can't iterate on `const` delegates
    public Set!Tracked data () scope @safe pure nothrow @nogc
    {
        return this.data_;
    }

    /// Implement this as the inclusion criteria
    public abstract bool include (in Hash hash, in Output utxo) scope @safe;

    /// Process all transactions in this `Block`
    public void externalize (in Block block) @safe
    {
        block.txs.each!((in tx) => this.externalize(tx));
    }

    /// Process all inputs and outputs in this `Transaction`
    public void externalize (in Transaction tx) @safe
    {
        tx.inputs.each!((in inp) => this.data_.remove(Tracked(inp.utxo)));
        const txHash = tx.hashFull();
        tx.outputs.enumerate
            .map!((in tup) => tuple(UTXO.getHash(txHash, tup.index), tup.value))
            .each!((in hash, in utxo) => this.externalize(hash, utxo));
    }

    /// Process a single `Output`
    public void externalize (in Hash hash, in Output output) @safe
    {
        if (this.include(hash, output))
            this.data_.put(Tracked(hash, output));
    }
}

// Test that externalizing an already-known block is a no-op
unittest
{
    scope ledger = new Ledger();
    assert(ledger.height() == 0);
    // This used to throw because `validateBlock` would pass and the Ledger
    // was attempting to re-add the same block.
    assert(ledger.acceptBlock(ledger.lastBlock()) is null);
    assert(ledger.height() == 0);
}
