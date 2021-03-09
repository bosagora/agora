/*******************************************************************************

    Contains validation routines for blocks

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.validation.Block;

import agora.common.Amount;
import agora.common.Set;
import agora.common.Types;
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.data.DataPayload;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.Fee;
import agora.consensus.state.UTXOSet;
import agora.consensus.state.ValidatorSet : EnrollmentFinder, EnrollmentState,
                                            EnrollmentStatus;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Schnorr;
import agora.script.Lock;
import VEn = agora.consensus.validation.Enrollment;
import VTx = agora.consensus.validation.Transaction;
import agora.utils.Log;

import std.algorithm;

import core.time : Duration, seconds;

mixin AddLogger!();

version (unittest)
{
    import agora.consensus.data.genesis.Test;
    import agora.utils.Test;
}

/*******************************************************************************

    Check the validity of a block.

    A block is considered valid if:
        - its height is the previous block height + 1
        - its prev_hash is the previous block header's hash
        - the number of transactions in the block is at least 1
        - the merkle root in the header matches the re-built merkle tree root
          based on the included transactions in the block
        - Transactions are ordered by their hash value
        - all the transactions pass validation, which implies:
            - signatures are authentic
            - the inputs spend an output which must be found with the
              findUTXO() delegate

    Note that checking for transactions which double-spend is the responsibility
    of the findUTXO() delegate. During validation, whenever this delegate is
    called it should also keep track of the used UTXOs, thereby marking
    it as a spent output. See the `findNonSpent` function in the
    unittest for an example.

    As a special case, the genesis block is rejected by this function.
    Validation of a genesis block should be done through the
    `isGenesisBlockInvalidReason` function.

    Params:
        block = the block to check
        prev_height = the height of the direct ancestor of this block
        prev_hash = the hash of the direct ancestor of this block
        findUTXO = delegate to find the referenced unspent UTXOs with
        checkPayload = delegate for checking data payload
        active_enrollments = the number of enrollments that do not expire
            at the next block height (prev_height + 1).
        enrolled_validators = the number of validators enrolled at this height
        random_seed = Hash of random seed of the preimages
        getValidatorAtIndex = delegate to provide validator Point K for
            given height and index into map
        getCommitmentNonce = delegate to provide the commitment Nonce of the
            validator given by it's Point K
        prev_time_offset = the time offset of the of the direct ancestor of this block
        curr_time_offset = the current time offset
        block_time_tolerance = the proposed block time offset should be less
                than curr_time_offset + block_time_tolerance
        getCoinbaseTX = delegate to get the expected Coinbase TX for a given TX
            set

    Returns:
        `null` if the block is valid, a string explaining the reason it
        is invalid otherwise.

*******************************************************************************/

public string isInvalidReason (in Block block, Height prev_height,
    in Hash prev_hash, scope UTXOFinder findUTXO, scope FeeChecker checkFee,
    scope EnrollmentFinder findEnrollment, size_t active_enrollments,
    size_t enrolled_validators, in Hash random_seed,
    Point delegate (in Height, ulong) nothrow @safe getValidatorAtIndex,
    Point delegate (in Point, in Height) nothrow @safe getCommitmentNonce,
    ulong prev_time_offset, ulong curr_time_offset, Duration block_time_tolerance,
    Transaction[] delegate (in Transaction[] tx_set, in uint[] missing_validators)
                               nothrow @safe getCoinbaseTX,
    string file = __FILE__, size_t line = __LINE__) nothrow @safe
{
    import std.algorithm;
    import std.string;
    import std.conv;
    import std.range;

    if (block.header.height == 0)
        return "Block: Genesis block should be validated using isGenesisBlockInvalidReason";

    if (block.header.height != prev_height + 1)
        return "Block: Height is not one more than previous block";

    if (block.header.prev_block != prev_hash)
        return "Block: Header.prev_block does not match previous block";

    if (block.txs.length == 0)
        return "Block: Must contain at least one transaction";

    log.trace("Number of validators still active next block will be {}. New enrollments this block {}",
        active_enrollments, block.header.enrollments.length);
    if (block.header.enrollments.length + active_enrollments < Enrollment.MinValidatorCount)
        return "Block: Insufficient number of active validators";

    if (!block.txs.isSorted())
        return "Block: Transactions are not sorted";

    bool only_coinbase = true;
    foreach (const ref tx; block.txs)
    {
        only_coinbase &= tx.type == TxType.Coinbase;
        if (auto fail_reason = VTx.isInvalidReason(tx, findUTXO,
            block.header.height, checkFee))
            return fail_reason;
    }

    if (only_coinbase)
        return "Block: Must contain other transactions than Coinbase";

    auto expected_cb_txs = getCoinbaseTX(block.txs,
        block.header.missing_validators);
    auto incoming_cb_txs = block.txs.filter!(
            tx => tx.type == TxType.Coinbase);
    if (!isPermutation(expected_cb_txs, incoming_cb_txs))
        return "Invalid Coinbase transaction";

    Hash[] merkle_tree;
    if (block.header.merkle_root != Block.buildMerkleTree(block.txs, merkle_tree))
        return "Block: Merkle root does not match header's";

    if (!isStrictlyMonotonic!"a.utxo_key < b.utxo_key"(block.header.enrollments))
        return "Block: The enrollments are not sorted in ascending order";


    /// FIXME: Use a proper type and sensible memory allocation pattern
    version (all)
    {
        scope extraSet = new TestUTXOSet();
        foreach (const ref tx; block.txs)
            extraSet.put(tx);
        scope extraFinder = extraSet.getUTXOFinder();
        scope UTXOFinder enrollmentsUTXOFinder =
            (in Hash utxo, out UTXO val)
            {
                if (findUTXO(utxo, val))
                    return true;
                return extraFinder(utxo, val);
            };
    }

    foreach (const ref enrollment; block.header.enrollments)
    {
        if (auto fail_reason = VEn.isInvalidReason(enrollment, enrollmentsUTXOFinder,
                                            block.header.height, findEnrollment))
            return fail_reason;
    }

    if (block.header.random_seed == Hash.init
        || block.header.random_seed != random_seed)
    {
        return "Block: Header's random seed does not match that of known pre-images";
    }

    Point sum_K;
    Point sum_R;
    const Scalar challenge = hashFull(block);

    log.trace("Validators expected to sign this block is {}", enrolled_validators);
    // Check that more than half have signed
    auto signed = iota(0, enrolled_validators).filter!(i => block.header.validators[i]).count();
    if (signed <= enrolled_validators / 2)
    {
        log.error("Only {} signed. Require more than {} out of {} validators to sign for externalizing slot height {}.",
                signed, enrolled_validators / 2, enrolled_validators, block.header.height);
        return "Only " ~ to!string(signed) ~ " signed the block. Require more than " ~ to!string(enrolled_validators);
        }
    foreach (idx; 0 .. enrolled_validators)
    {
        const K = getValidatorAtIndex(block.header.height, idx);
        log.trace("idx {} PublicKey: {}", idx, PublicKey(K[]));
        if (K == Point.init)
        {
            log.error("[{}:{}] idx #{}: Validator {} not found for height {}",
                file, line, idx, PublicKey(K[]), block.header.height);
            return "Block: Couldn't find a Validator for the given index "
                ~ to!string(idx) ~ " at height " ~ to!string(block.header.height.value);
        }
        if (!block.header.validators[idx])
        {
            log.trace("[{}:{}] idx #{}: Validator {} has not yet signed block height {}",
                file, line, idx, PublicKey(K[]), block.header.height);
            continue;  // this validator hasn't signed yet
        }

        const CR = getCommitmentNonce(K, block.header.height);  // commited R
        log.trace("Block.isInvalidReason: Enrollment commitment CR for validator {} is {}", PublicKey(K[]), CR);
        if (CR == Point.init)
            return "Block: Couldn't find commitment for this validator";
        Point R = CR + challenge.toPoint();
        log.trace("Block.isInvalidReason: Block signing commitment R for validator {} is {}", PublicKey(K[]), R);
        sum_K = sum_K == Point.init ? K : (sum_K + K);
        sum_R = sum_R == Point.init ? R : (sum_R + R);
    }
    if (sum_K == Point.init)
    {
        log.error("[{}:{}] Block: Not able to check the multi sig schnorr signature for any of the {} active validators at height {}",
            file, line, active_enrollments, block.header.height);
        return "Block: Not enough info to verify schnorr signature at height " ~ to!string(block.header.height.value);
    }
    Sig sig = Sig.fromBlob(block.header.signature);
    if (sum_R != sig.R)
    {
        log.error("[{}:{}] Block: Invalid schnorr signature for {} active validators. Sum of R mismatch",
            file, line, enrolled_validators);
        return "Block: Invalid schnorr signature";
    }
    if (!multiSigVerify(sig, sum_K, challenge))
    {
        log.error("[{}:{}] Block: Invalid schnorr signature for {} active validators. Multisig failed verification",
            file, line, enrolled_validators);
        return "Block: Invalid schnorr signature";
    }
    return validateBlockTimeOffset(prev_time_offset, block.header.time_offset, curr_time_offset, block_time_tolerance);
}

/*******************************************************************************

    Check the validity of the `time offset` for a block

    new_block_offset is valid if and only if
    prev_block_offset < new_block_offset <= curr_time_offset + block_time_offset_tolerance_secs

    Params:
        prev_block_offset = the timestam of the block preceding the new block
        new_block_offset  = the time offset of the block we are trying to validate
        curr_time_offset = the current time offset in seconds
        block_time_tolerance = the proposed block new_block_offset should be less
                than curr_time_offset + block_time_tolerance

    Returns:
        `null` if the new_block_offset is valid, otherwise a string explaining
        the reason it is invalid.

*******************************************************************************/

public string validateBlockTimeOffset (ulong prev_block_offset, ulong new_block_offset, ulong curr_time_offset,
        Duration block_time_tolerance) @safe nothrow
{
    import std.format;
    string res;
    try
    {
        import std.conv : to;
        const block_time_offset_tolerance_secs = block_time_tolerance.total!"seconds";

        if (new_block_offset <= prev_block_offset)
            res = format!"Proposed block time offset: [%s] is not greater than the time offset in the last block: [%s]"
            (new_block_offset, prev_block_offset);
        else if (new_block_offset > curr_time_offset + block_time_offset_tolerance_secs)
            res =  format!"Proposed block time offset: [%s] is greater than current time offset: [%s] plus tolerance of %s secs"
            (new_block_offset, curr_time_offset, block_time_offset_tolerance_secs);
    }
    catch (Exception e)
    {
        return "Exception happened while validating block time offset";
    }
    if (res !is null)
        log.warn("validateBlockTimeOffset(): {}", res);
    return res;
}

/*******************************************************************************

    Check the validity of a genesis block

    Follow the same rules as for `Block` except for the following:
        - Block height must be 0
        - The previous block hash of the block must be empty
        - The block must contain at least 1 transaction
        - Transactions must have no input
        - Transactions must have at least one output
        - All the enrollments pass validation, which implies:
            - The enrollments refer to freeze tx's in this block
            - The signature for the Enrollment is valid

    Params:
        block = The genesis block to check

    Returns:
        `null` if the genesis block is valid, otherwise a string explaining
        the reason it is invalid.

*******************************************************************************/

public string isGenesisBlockInvalidReason (in Block block) nothrow @safe
{
    if (block.header.height != 0)
        return "GenesisBlock: The height of the block is not 0";

    if (block.header.prev_block != Hash.init)
        return "GenesisBlock: Header.prev_block is not empty";

    if (block.txs.length == 0)
        return "GenesisBlock: Transaction(s) are empty";

    if (block.txs.length == 0)
        return "GenesisBlock: Must contain at least one transaction";

    if (!block.txs.isSorted())
        return "GenesisBlock: Transactions are not sorted";

    UTXO[Hash] utxo_set;
    foreach (const ref tx; block.txs)
    {
        if (!(tx.type == TxType.Payment || tx.type == TxType.Freeze))
            return "GenesisBlock: Invalid enum value for type field";

        if (tx.inputs.length != 0)
             return "GenesisBlock: Transactions must not have input";

        if (tx.outputs.length == 0)
            return "GenesisBlock: No output(s) in the transaction";

        if (tx.payload.data.length != 0)
            return "GenesisBlock: The data payload cannot be stored";

        Hash tx_hash = tx.hashFull();
        foreach (idx, const ref output; tx.outputs)
        {
            // disallow negative amounts
            if (!output.value.isValid())
                return "GenesisBlock: Output(s) overflow or underflow"
                    ~ "in the transaction";

            // disallow 0 amount
            if (output.value == Amount(0))
                return "GenesisBlock: Value of output is 0"
                    ~ "in the transaction";

            const UTXO utxo_value = {
                unlock_height: 0,
                type: tx.type,
                output: output
            };
            utxo_set[UTXO.getHash(tx_hash, idx)] = utxo_value;
        }
    }

    Hash[] merkle_tree;
    if (block.header.merkle_root !=
        Block.buildMerkleTree(block.txs, merkle_tree))
        return "GenesisBlock: Merkle root does not match header's";

    if (block.header.enrollments.length == 0)
        return "GenesisBlock: No enrollments in the block";

    if (!isStrictlyMonotonic!"a.utxo_key < b.utxo_key"
        (block.header.enrollments))
        return "GenesisBlock: The enrollments should be arranged in "
            ~ "ascending order by the utxo_key";

    Set!Hash used_utxos;
    bool findUTXO (in Hash utxo, out UTXO value) nothrow @safe
    {
        if (utxo in used_utxos)
            return false;  // double-spend

        if (auto ptr = utxo in utxo_set)
        {
            value = *ptr;
            used_utxos.put(utxo);
            return true;
        }
        return false;
    }

    bool findEnrollment (in Hash enroll_key, out EnrollmentState state) @trusted nothrow
    {
        return false;
    }

    foreach (const ref enrollment; block.header.enrollments)
    {
        if (auto fail_reason = VEn.isInvalidReason(enrollment, &findUTXO, Height(0), &findEnrollment))
            return fail_reason;
    }

    return null;
}

/// Genesis block validation fail test
unittest
{
    import agora.serialization.Serializer;

    Block block = GenesisBlock.serializeFull.deserializeFull!Block;
    assert(block.isGenesisBlockValid());

    scope fee_man = new FeeManager();
    scope checker = &fee_man.check;
    scope findGenesisEnrollments = getGenesisEnrollmentFinder();

    // don't accept block height 0 from the network
    block.header.height = 0;
    block.assertValid!false(Height(0), Hash.init, null,
        Enrollment.MinValidatorCount, Enrollment.MinValidatorCount, checker, findGenesisEnrollments);

    // height check
    block.header.height = 1;
    assert(!block.isGenesisBlockValid());

    block.header.height = 0;
    assert(block.isGenesisBlockValid());

    // .prev_block check
    block.header.prev_block = block.header.hashFull();
    assert(!block.isGenesisBlockValid());

    block.header.prev_block = Hash.init;
    assert(block.isGenesisBlockValid());

    // enrollments length check
    block.header.enrollments = null;
    assert(!block.isGenesisBlockValid());

    block = GenesisBlock.serializeFull.deserializeFull!Block;
    assert(block.isGenesisBlockValid());

    Transaction[] txs =
        GenesisBlock.txs.serializeFull.deserializeFull!(Transaction[]);

    void checkValidity (in Block block)
    {
        auto reason = block.isGenesisBlockInvalidReason();
        assert(reason is null, reason);
    }

    void buildMerkleTree (ref Block block, bool shouldSort = true)
    {
        Hash[] merkle_tree;
        if (shouldSort) block.txs.sort;
        block.header.merkle_root =
            Block.buildMerkleTree(block.txs, merkle_tree);
    }

    Transaction makeNewTx ()
    {
        Transaction new_tx =
        {
            TxType.Payment,
            inputs: [],
            outputs: [Output(Amount(100), KeyPair.random().address)]
        };
        return new_tx;
    }

    // Check consistency of `txs` field
    {
        // Txs length check
        block.txs = null;
        assert(!block.isGenesisBlockValid());

        // at least 1 tx needed (todo: relax this?)
        block.txs ~= txs[0];
        buildMerkleTree(block);
        checkValidity(block);

        block = GenesisBlock.serializeFull.deserializeFull!Block;
        foreach (_; 0 .. 6)
            block.txs ~= makeNewTx();
        assert(block.txs.length == 8);
        buildMerkleTree(block);
        checkValidity(block);

        block = GenesisBlock.serializeFull.deserializeFull!Block;
        // Txs sorting check
        block.txs.reverse;
        buildMerkleTree(block, false);
        assert(!block.isGenesisBlockValid());

        block.txs.reverse;
        buildMerkleTree(block, false);
        checkValidity(block);

        // there may be any number of txs, does not need to be power of 2
        block.txs ~= makeNewTx();
        buildMerkleTree(block);
        assert(block.txs.length == 3);
        checkValidity(block);

        block = GenesisBlock.serializeFull.deserializeFull!Block;

        // Txs type check
        auto pre_type_change_txs = block.txs.dup;
        block.txs[0].type = cast(TxType)2;
        buildMerkleTree(block);
        assert(block.isGenesisBlockInvalidReason()
               .canFind("Invalid enum value"));

        block.txs = pre_type_change_txs;
        buildMerkleTree(block);
        checkValidity(block);

        assert(block.txs.any!(tx => tx.type == TxType.Payment));
        assert(block.txs.any!(tx => tx.type == TxType.Freeze));

        // Input empty check
        block.txs[0].inputs ~= Input.init;
        buildMerkleTree(block);
        assert(!block.isGenesisBlockValid());

        block.txs = txs;
        buildMerkleTree(block);
        checkValidity(block);

        // Output not empty check
        block.txs[0].outputs = null;
        buildMerkleTree(block);
        assert(!block.isGenesisBlockValid());

        // disallow 0 amount
        Output zeroOutput =
            Output(Amount.invalid(0), WK.Keys[0].address);
        block.txs[0].outputs ~= zeroOutput;
        buildMerkleTree(block);
        assert(!block.isGenesisBlockValid());
    }

    block = GenesisBlock.serializeFull.deserializeFull!Block;

    // enrollments validation test
    Enrollment[] enrolls;
    enrolls ~= Enrollment.init;
    block.header.enrollments = enrolls;
    assert(!block.isGenesisBlockValid());

    block = GenesisBlock.serializeFull.deserializeFull!Block;

    // modify the last hex byte of the merkle root
    block.header.merkle_root[][$ - 1]++;
    assert(!block.isGenesisBlockValid());

    // now restore it back to what it was
    block.header.merkle_root[][$ - 1]--;
    checkValidity(block);
    const last_root = block.header.merkle_root;

    // the previous merkle root should not match the new txs
    block.txs ~= makeNewTx();
    block.header.merkle_root = last_root;
    assert(!block.isGenesisBlockValid());
}

/// Genesis block with transaction data is a test that fails validation
unittest
{
    import agora.serialization.Serializer;

    KeyPair key_pair = KeyPair.random;

    scope fee_man = new FeeManager();
    scope checker = &fee_man.check;

    Block block = GenesisBlock.serializeFull.deserializeFull!Block;

    // create data with nomal size
    ubyte[] normal_data;
    normal_data.length = fee_man.params.TxPayloadMaxSize;
    foreach (idx; 0 .. normal_data.length)
        normal_data[idx] = cast(ubyte)(idx % 256);

    // calculate fee
    Amount normal_data_fee = calculateDataFee(normal_data.length,
        fee_man.params.TxPayloadFeeFactor);

    // create a transaction with data payload and enough fee
    Transaction dataTx = Transaction(
        TxType.Payment,
        [],
        [
            Output(normal_data_fee, fee_man.params.CommonsBudgetAddress),
            Output(Amount(40_000L * 10_000_000L), key_pair.address)
        ],
        DataPayload(normal_data)
    );

    // add a new transaction with data payload to block
    block.txs ~= dataTx;
    block.txs.sort;

    // build merkle tree
    block.header.merkle_root =
        Block.buildMerkleTree(block.txs, block.merkle_tree);

    assert(!block.isGenesisBlockValid(),
        "Genesis block should not have any transaction with data payload.");
}

/// Ditto but returns `bool`, only usable in unittests
/// Only the genesis block Validation
version (unittest)
public bool isGenesisBlockValid (in Block genesis_block)
    nothrow @safe
{
    return isGenesisBlockInvalidReason(genesis_block) is null;
}


version (unittest)
{
    SecretKey lookupSecretKeyFromPoint (Point point) @trusted nothrow
    {
        return genesis_validator_keys
            .find!(key => key.address == PublicKey(point[]))[0].secret;
    }

    public string isValidcheck (in Block block, Height prev_height,
        Hash prev_hash, scope UTXOFinder findUTXO,
        size_t active_enrollments, size_t enrolled_validators, scope FeeChecker checkFee,
        scope EnrollmentFinder findEnrollment, Hash random_seed = Hash.init,
        ulong enrollment_cycle = 0, ulong prev_time_offset = 0, ulong curr_time_offset = ulong.max,
        Duration block_time_tolerance = 100.seconds,
        string file = __FILE__, size_t line = __LINE__) nothrow @safe
    {
        if (random_seed == Hash.init)
            random_seed = getTestRandomSeed();

        return isInvalidReason(block, prev_height, prev_hash, findUTXO,
            checkFee, findEnrollment, active_enrollments, enrolled_validators,
            random_seed, (in Height h, ulong i) @safe nothrow
            {
                return Point(genesis_validator_keys[i].address[]);
            },
            (in Point key, in Height height) @trusted nothrow
            {
                return Scalar(hashMulti(
                    lookupSecretKeyFromPoint(key),
                    "consensus.signature.noise", enrollment_cycle))
                    .toPoint();
            },
            prev_time_offset, (curr_time_offset == ulong.max) ? block.header.time_offset : curr_time_offset,
            block_time_tolerance,
            (in Transaction[] tx_set, in uint[] missing_validators)
            {
                return (Transaction[]).init;
            });
    }

    /// Helper function that will log the reason if the block turns out
    /// not to be valid
    public void assertValid (bool mustBeValid = true)
        (in Block block, Height prev_height, Hash prev_hash, scope UTXOFinder findUTXO,
        size_t active_enrollments, size_t enrolled_validators, scope FeeChecker checkFee,
        scope EnrollmentFinder findEnrollment, Hash random_seed = Hash.init,
        ulong enrollment_cycle = 0, ulong prev_time_offset = 0, ulong curr_time_offset = ulong.max,
        Duration block_time_tolerance = 100.seconds,
        string file = __FILE__, size_t line = __LINE__) nothrow @safe
    {
        string reason = isValidcheck(block, prev_height, prev_hash, findUTXO,
            active_enrollments, enrolled_validators, checkFee, findEnrollment,
            random_seed, enrollment_cycle, prev_time_offset, curr_time_offset,
            block_time_tolerance);

        bool success = mustBeValid ? (reason is null) : (reason !is null);
        if (!success)
        {
            log.error("{} block: {}", mustBeValid ? "Invalid" : "Valid", block);
            log.error("prev: {} ({}), active: {}, enrolled: {}, random_seed: {}, " ~
                      "cycle: {}, prev_time_offset: {}, curr_time_offset: {}, tolerance: {}",
                      prev_height, prev_hash, active_enrollments, enrolled_validators,
                      random_seed, enrollment_cycle, prev_time_offset,
                      curr_time_offset, block_time_tolerance);
            log.error("Called from: {}:{}", file, line);
            assert(0, mustBeValid ?
                   reason : "Block expected to be invalid but passed `isValid`");
        }
    }
}

/// Returns: EnrollmentFinder for GenesisBlock, a delegate to query enrollments
/// in GenesisBlock
public EnrollmentFinder getGenesisEnrollmentFinder () nothrow @trusted
{
    import std.array;
    import agora.consensus.data.genesis.Test : GenesisBlock;

    return (in Hash enroll_key, out EnrollmentState state)
    {
        auto enrolls = GenesisBlock.header.enrollments
                        .filter!(enroll => enroll.utxo_key == enroll_key).array;
        assert(enrolls.length <= 1);

        if (!enrolls.empty)
        {
            state.status = EnrollmentStatus.Active;
            state.enrolled_height = Height(0);
            state.cycle_length = enrolls[0].cycle_length;
            state.last_image = enrolls[0].random_seed;
            state.distance = 0;
        }

        return enrolls.length != 0;
    };
}

///
unittest
{
    import std.algorithm;
    import std.range;

    scope utxos = new TestUTXOSet();
    scope findUTXO = &utxos.peekUTXO;

    scope fee_man = new FeeManager();
    scope checker = &fee_man.check;
    scope findGenesisEnrollments = getGenesisEnrollmentFinder();

    auto gen_key = WK.Keys.Genesis;
    assert(GenesisBlock.isGenesisBlockValid());
    auto gen_hash = GenesisBlock.header.hashFull();

    GenesisBlock.txs.each!(tx => utxos.put(tx));
    auto block = GenesisBlock.makeNewTestBlock(genesisSpendable().map!(txb => txb.sign()));

    // height check
    block.assertValid(GenesisBlock.header.height, gen_hash, findUTXO,
        Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

    block.header.height = 100;
    block.assertValid!false(GenesisBlock.header.height, gen_hash, findUTXO,
        Enrollment.MinValidatorCount, genesis_validator_keys.length,  checker, findGenesisEnrollments);

    block.header.height = GenesisBlock.header.height + 1;
    block.assertValid(GenesisBlock.header.height, gen_hash, findUTXO,
        Enrollment.MinValidatorCount, genesis_validator_keys.length,  checker, findGenesisEnrollments);

    /// .prev_block check
    block.header.prev_block = block.header.hashFull();
    block.assertValid!false(GenesisBlock.header.height, gen_hash, findUTXO,
        Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

    block.header.prev_block = gen_hash;
    block.assertValid(GenesisBlock.header.height, gen_hash, findUTXO,
        Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

    /// Check consistency of `txs` field
    {
        auto saved_txs = block.txs;

        block.txs = saved_txs[0 .. $ - 1];
        block.assertValid!false(GenesisBlock.header.height, gen_hash, findUTXO,
            Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

        block.txs = (saved_txs ~ saved_txs).sort.array;
        block.assertValid!false(GenesisBlock.header.height, gen_hash, findUTXO,
            Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

        block.txs = saved_txs;
        block.assertValid(GenesisBlock.header.height, gen_hash, findUTXO,
            Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

        /// Txs sorting check
        block.txs.reverse;
        block.assertValid!false(GenesisBlock.header.height, gen_hash, findUTXO,
            Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

        block.txs.reverse;
        block.assertValid(GenesisBlock.header.height, gen_hash, findUTXO,
            Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);
    }

    /// no matching utxo => fail
    utxos.clear();
    block.assertValid!false(GenesisBlock.header.height, gen_hash, findUTXO,
        Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

    GenesisBlock.txs.each!(tx => utxos.put(tx));
    block.assertValid(GenesisBlock.header.height, gen_hash, findUTXO,
        Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

    utxos.clear();  // genesis is spent
    auto prev_txs = block.txs;
    prev_txs.each!(tx => utxos.put(tx));  // these will be spent

    auto prev_block = block;
    block = block.makeNewTestBlock(prev_txs.map!(tx => TxBuilder(tx).sign()));
    block.assertValid(prev_block.header.height, prev_block.header.hashFull(),
        findUTXO, Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

    assert(prev_txs.length > 0);  // sanity check
    foreach (tx; prev_txs)
    {
        // one utxo missing from the set => fail
        utxos.storage.remove(UTXO.getHash(tx.hashFull(), 0));
        block.assertValid!false(prev_block.header.height, prev_block.header.hashFull(),
            findUTXO, Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

        utxos.put(tx);
        block.assertValid(prev_block.header.height, prev_block.header.hashFull(),
            findUTXO, Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);
    }

    // the key is hashMulti(hash(prev_tx), index)
    Output[Hash] utxo_set;

    foreach (tx; GenesisBlock.txs)
        foreach (idx, ref output; tx.outputs)
            utxo_set[hashMulti(tx.hashFull, idx)] = output;

    assert(utxo_set.length != 0);
    const utxo_set_len = utxo_set.length;

    // contains the used set of UTXOs during validation (to prevent double-spend)
    Output[Hash] used_set;
    scope UTXOFinder findNonSpent = (in Hash utxo_hash, out UTXO value)
    {
        if (utxo_hash in used_set)
            return false;  // double-spend

        if (auto utxo = utxo_hash in utxo_set)
        {
            used_set[utxo_hash] = *utxo;
            value.unlock_height = 0;
            value.type = TxType.Payment;
            value.output = *utxo;
            return true;
        }

        return false;
    };

    // consumed all utxo => fail
    block = GenesisBlock.makeNewTestBlock(genesisSpendable().map!(txb => txb.sign()));
    block.assertValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
        findNonSpent, Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

    // All `payment` utxos have been consumed
    assert(GenesisBlock.txs[0].type == TxType.Freeze);
    assert(used_set.length + GenesisBlock.txs[0].outputs.length == utxo_set_len);

    // reset state
    used_set.clear();

    // Double spend => fail
    auto double_spend = block.txs.dup;
    double_spend[$ - 1] = double_spend[$ - 2];
    block = makeNewTestBlock(GenesisBlock, double_spend);
    block.assertValid!false(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
            findNonSpent, Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

    // we stopped validation due to a double-spend
    assert(used_set.length == double_spend.length - 1);

    block = GenesisBlock.makeNewTestBlock(prev_txs.map!(tx => TxBuilder(tx).sign()));
    block.assertValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
        findUTXO, Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

    // modify the last hex byte of the merkle root
    block.header.merkle_root[][$ - 1]++;

    block.assertValid!false(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
        findUTXO, Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

    // now restore it back to what it was
    block.header.merkle_root[][$ - 1]--;
    block.assertValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
        findUTXO, Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);
    const last_root = block.header.merkle_root;

    block = GenesisBlock.makeNewTestBlock(prev_txs.enumerate.map!(en =>
        TxBuilder(en.value).split(WK.Keys.byRange().take(en.index + 1).map!(k => k.address)).sign()));

    block.assertValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
        findUTXO, Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

    // the previous merkle root should not match the new txs
    block.header.merkle_root = last_root;
    block.assertValid!false(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
        findUTXO, Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);
}

///
unittest
{
    import agora.common.Amount;
    import agora.consensus.data.Enrollment;
    import agora.consensus.data.Transaction;

    import std.algorithm;
    import std.range;

    scope utxo_set = new TestUTXOSet();
    UTXOFinder findUTXO = utxo_set.getUTXOFinder();

    scope fee_man = new FeeManager();
    scope checker = &fee_man.check;
    scope findGenesisEnrollments = getGenesisEnrollmentFinder();

    auto gen_key = WK.Keys.Genesis;
    assert(GenesisBlock.isGenesisBlockValid());
    auto gen_hash = GenesisBlock.header.hashFull();
    foreach (ref tx; GenesisBlock.txs)
        utxo_set.put(tx);

    auto txs_1 = genesisSpendable().map!(txb => txb.sign()).array();

    auto block1 = makeNewTestBlock(GenesisBlock, txs_1);
    block1.assertValid(GenesisBlock.header.height, gen_hash, findUTXO,
        genesis_validator_keys.length, genesis_validator_keys.length, checker, findGenesisEnrollments);

    foreach (ref tx; txs_1)
        utxo_set.put(tx);

    KeyPair keypair = KeyPair.random();
    Transaction[] txs_2;
    foreach (idx, pre_tx; txs_1)
    {
        Input input = Input(hashFull(pre_tx), 0);

        Transaction tx =
        {
            TxType.Freeze,
            [input],
        };
        if (idx > 3)
            tx.type = TxType.Payment;

        if (idx == 7)
        {
            foreach (_; 0 .. 8)
            {
                Output output;
                output.value = Amount(100);
                output.lock = genKeyLock(keypair.address);
                tx.outputs ~= output;
            }
        }
        else
        {
            Output output;
            output.value = Amount.MinFreezeAmount;
            output.lock = genKeyLock(keypair.address);
            tx.outputs ~= output;
        }

        tx.inputs[0].unlock = genKeyUnlock(gen_key.secret.sign(hashFull(tx)[]));
        txs_2 ~= tx;
    }

    auto block2 = makeNewTestBlock(block1, txs_2);
    block2.assertValid(block1.header.height, hashFull(block1.header), findUTXO,
        genesis_validator_keys.length, genesis_validator_keys.length, checker, findGenesisEnrollments);
    foreach (ref tx; txs_2)
        utxo_set.put(tx);

    KeyPair keypair2 = KeyPair.random();
    Transaction[] txs_3;
    foreach (idx; 0 .. 8)
    {
        Input input = Input(hashFull(txs_2[7]), idx);

        Transaction tx =
        {
            TxType.Payment,
            [input],
            [Output(Amount(1), keypair2.address)]
        };
        tx.inputs[0].unlock = genKeyUnlock(keypair.secret.sign(hashFull(tx)[]));
        txs_3 ~= tx;
    }

    Pair signature_noise = Pair.random;
    Pair node_key_pair = Pair.fromScalar(keypair.secret);

    auto utxo_hash1 = UTXO.getHash(hashFull(txs_2[0]), 0);
    Enrollment enroll1;
    enroll1.utxo_key = utxo_hash1;
    enroll1.random_seed = hashFull(Scalar.random());
    enroll1.cycle_length = 1008;
    enroll1.enroll_sig = sign(node_key_pair.v, node_key_pair.V, signature_noise.V,
        signature_noise.v, enroll1);

    auto utxo_hash2 = UTXO.getHash(hashFull(txs_2[1]), 0);
    Enrollment enroll2;
    enroll2.utxo_key = utxo_hash2;
    enroll2.random_seed = hashFull(Scalar.random());
    enroll2.cycle_length = 1008;
    enroll2.enroll_sig = sign(node_key_pair.v, node_key_pair.V, signature_noise.V,
        signature_noise.v, enroll2);

    Enrollment[] enrollments;
    enrollments ~= enroll1;
    enrollments ~= enroll2;
    enrollments.sort!("a.utxo_key < b.utxo_key");

    auto preimage_root = Hash("0x47c993d409aa7d77651ecaa5a5d29e47a7aee609c7" ~
                              "cb376f5f8ff2a868c738233a2df5ba11d635c8576a47" ~
                              "3864fc1c8fd1469f4be80b853764da53f6a5b41661");
    uint[] missing_validators = [];

    auto block3 = makeNewTestBlock(block2, txs_3, preimage_root, enrollments,
        missing_validators);
    block3.assertValid(block2.header.height, hashFull(block2.header), findUTXO,
        Enrollment.MinValidatorCount, genesis_validator_keys.length, checker,
        findGenesisEnrollments, preimage_root);
    enrollments.sort!("a.utxo_key > b.utxo_key");
    findUTXO = utxo_set.getUTXOFinder();
    // Block: The enrollments are not sorted in ascending order
    block3.assertValid!false(block2.header.height, hashFull(block2.header), findUTXO,
        Enrollment.MinValidatorCount, Enrollment.MinValidatorCount, checker,
        findGenesisEnrollments, preimage_root);
}

/// test that there must always exist active validators
unittest
{
    import agora.common.Amount;
    import agora.consensus.data.Enrollment;
    import agora.consensus.data.Transaction;

    import std.algorithm;
    import std.range;

    scope utxo_set = new TestUTXOSet();
    UTXOFinder findUTXO = utxo_set.getUTXOFinder();

    scope fee_man = new FeeManager();
    scope checker = &fee_man.check;
    scope findGenesisEnrollments = getGenesisEnrollmentFinder();

    auto gen_key = WK.Keys.Genesis;
    assert(GenesisBlock.isGenesisBlockValid());
    auto gen_hash = GenesisBlock.header.hashFull();
    foreach (ref tx; GenesisBlock.txs)
        utxo_set.put(tx);

    auto txs_1 = genesisSpendable().map!(txb => txb.sign()).array();

    auto block1 = makeNewTestBlock(GenesisBlock, txs_1);
    block1.assertValid(GenesisBlock.header.height, gen_hash, findUTXO,
        Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);

    foreach (ref tx; txs_1)
        utxo_set.put(tx);

    KeyPair keypair = KeyPair.random();
    Transaction[] txs_2;
    foreach (idx, pre_tx; txs_1)
    {
        Transaction tx =
        {
            TxType.Freeze,
            [Input(hashFull(pre_tx), 0)],
        };

        if (idx <= 2)
        {
            tx.outputs ~= Output(Amount.MinFreezeAmount, keypair.address);
            tx.outputs ~= Output(Amount.MinFreezeAmount, keypair.address);
            tx.outputs ~= Output(Amount.MinFreezeAmount, keypair.address);
        }
        else
        {
            tx.type = TxType.Payment;
            foreach (_; 0 .. 8)
                tx.outputs ~= Output(Amount(100), keypair.address);
        }

        tx.inputs[0].unlock = genKeyUnlock(gen_key.secret.sign(hashFull(tx)[]));
        txs_2 ~= tx;
    }

    auto block2 = makeNewTestBlock(block1, txs_2);
    block2.assertValid(block1.header.height, hashFull(block1.header), findUTXO,
        Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);
    foreach (ref tx; txs_2)
        utxo_set.put(tx);

    // When all existing validators expire at the new block height and the number of enrollments
    // in the new block is 0, the block is considered invalid.
    {
        KeyPair keypair2 = KeyPair.random();
        Transaction[] txs_3;
        foreach (idx; 0 .. 8)
        {
            Transaction tx =
            {
                TxType.Payment,
                [Input(hashFull(txs_2[$-4]), idx)],
                [Output(Amount(1), keypair2.address)]
            };
            tx.inputs[0].unlock = genKeyUnlock(keypair.secret.sign(hashFull(tx)[]));
            txs_3 ~= tx;
        }

        Pair signature_noise = Pair.random;
        Pair node_key_pair = Pair.fromScalar(keypair.secret);

        auto block3 = makeNewTestBlock(block2, txs_3);
        assert(block3.header.enrollments.length == 0);
        block3.assertValid!false(block2.header.height, hashFull(block2.header),
            findUTXO, 0, 0, checker, findGenesisEnrollments);
    }

    // When all existing validators expire at the new block height but the number of enrollments
    // in the new block is at least 1, the block may be considered valid.
    {
        KeyPair keypair2 = KeyPair.random();
        Transaction[] txs_3;
        foreach (idx; 0 .. 8)
        {
            Transaction tx =
            {
                TxType.Payment,
                [Input(hashFull(txs_2[$-3]), idx)],
                [Output(Amount(1), keypair2.address)]
            };
            tx.inputs[0].unlock = genKeyUnlock(keypair.secret.sign(hashFull(tx)[]));
            txs_3 ~= tx;
        }

        Pair signature_noise = Pair.random;
        Pair node_key_pair = Pair.fromScalar(keypair.secret);

        auto utxo_hash1 = UTXO.getHash(hashFull(txs_2[1]), 0);
        Enrollment enroll1;
        enroll1.utxo_key = utxo_hash1;
        enroll1.random_seed = hashFull(Scalar.random());
        enroll1.cycle_length = 1008;
        enroll1.enroll_sig = sign(node_key_pair.v, node_key_pair.V, signature_noise.V,
            signature_noise.v, enroll1);

        Enrollment[] enrollments;
        enrollments ~= enroll1;
        enrollments.sort!("a.utxo_key < b.utxo_key");

        auto preimage_root = Hash("0x47c993d409aa7d77651ecaa5a5d29e47a7aee609c7" ~
                                  "cb376f5f8ff2a868c738233a2df5ba11d635c8576a47" ~
                                  "3864fc1c8fd1469f4be80b853764da53f6a5b41661");
        uint[] missing_validators = [];

        auto block3 = makeNewTestBlock(block2, txs_3, preimage_root, enrollments,
            missing_validators);
        assert(block3.header.enrollments.length == Enrollment.MinValidatorCount);
        block3.assertValid(block2.header.height, hashFull(block2.header),
            findUTXO, 0, genesis_validator_keys.length, checker, findGenesisEnrollments,
            preimage_root);
    }

    // When there are still active validators at the new block height,
    // then new block does not need to contain new enrollments to be considered valid
    {
        KeyPair keypair2 = KeyPair.random();
        Transaction[] txs_3;
        foreach (idx; 0 .. 8)
        {
            Transaction tx =
            {
                TxType.Payment,
                [Input(hashFull(txs_2[$-1]), idx)],
                [Output(Amount(1), keypair2.address)]
            };
            tx.inputs[0].unlock = genKeyUnlock(keypair.secret.sign(hashFull(tx)[]));
            txs_3 ~= tx;
        }

        auto block3 = makeNewTestBlock(block2, txs_3);
        assert(block3.header.enrollments.length == 0);

        block3.assertValid!false(block2.header.height, hashFull(block2.header),
            findUTXO, 0, Enrollment.MinValidatorCount, checker, findGenesisEnrollments);

        findUTXO = utxo_set.getUTXOFinder();
        block3.assertValid(block2.header.height, hashFull(block2.header), findUTXO,
            Enrollment.MinValidatorCount, genesis_validator_keys.length, checker, findGenesisEnrollments);
    }
}
