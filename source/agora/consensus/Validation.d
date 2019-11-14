/*******************************************************************************

    Contains validation routines for all data types required for consensus.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.Validation;

import agora.common.Amount;
import agora.common.Config;
import agora.common.crypto.ECC;
import agora.common.crypto.Key;
import agora.common.crypto.Schnorr;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXOSet;
import agora.consensus.Genesis;
import agora.node.Ledger;

import std.conv;

/// Node ID => Block #index => Preimage
public alias PreimagesMap = Hash[ulong][ushort];

/// Node ID => Block #Index => Expected R value
/// (based on R2 = R1 + X1, where X1 is the preimage for block #1)
public alias PubRMap = Point[ulong][ushort];

/*******************************************************************************

    Check the validation of the block header's signature

    Params:
        header = the block header to validate
        preimage_map = the currently revealed preimage_map of all the nodes
        pub_R_map = the map of the expected R's based on the revealed preimage_map
                      (e.g. R2 = R1 + X1, a map of R2 for each validator node)
        pub_keys = public keys of all validators, sorted alphabetically
                   to enable bitmask index lookup

    Return:
        `null` if the block is valid, otherwise a string explaining the
        reason it is invalid.

*******************************************************************************/

public string isInvalidSignatureReason (BlockHeader header,
    PreimagesMap preimages_map, PubRMap pub_R_map, Point[] pub_keys)
    nothrow @safe
{
    import agora.common.crypto.Schnorr : verify;

    Point P;  // sum of P for the validators which signed
    Point R;  // ditto for R
    size_t num_signers;

    foreach (idx, has_signed; header.validators)
    {
        if (!has_signed)
            continue;

        /// node indices are ushort
        assert(idx < ushort.max);
        const node_idx = cast(ushort)idx;

        /// verification: the pubkeys & preimages are known and the R's were calculated
        if (node_idx >= pub_keys.length)
            return "Validator is not enrolled";

        auto preimages = node_idx in preimages_map;
        if (preimages is null)
            return "Validator has not revealed any preimages";

        if (header.height !in *preimages)
            return "Validator has not revealed the preimage for this block height";

        // sanity checks: if preimages exist then the R values should have been calculated
        auto rand_map = node_idx in pub_R_map;
        assert(rand_map !is null);
        auto rand_val = header.height in *rand_map;
        assert(rand_val !is null);

        /// Add the validator's P
        if (P == Point.init)  // note: Point.init + Point != Point, must use assignment here
            P = pub_keys[idx];
        else
            P = P + pub_keys[idx];

        /// Add the validator's R
        const Point node_R = *rand_val;
        if (R == Point.init)  // note: Point.init + Point != Point, must use assignment here
            R = node_R;
        else
            R = R + node_R;

        num_signers++;
    }

    // todo: could have a rule: at least 50% + 1 must have signed the block
    // in order for the signature to be considered valid
    if (num_signers == 0)
        return "Not enough validators signed this block";

    // this avoids a signature check if R has been manipulated
    if (header.signature.R != R)
        return "Signature.R does not match expected R";

    if (!verify(P, header.signature, header))
        return "Signature is invalid";

    return null;
}

/// Ditto but returns `bool`, only usable in unittests
version (unittest)
public bool isValidSignature (BlockHeader header, PreimagesMap preimage_map,
    PubRMap pub_R_map, Point[] pub_keys) nothrow @safe
{
    return isInvalidSignatureReason(header, preimage_map, pub_R_map, pub_keys) is null;
}

/*******************************************************************************

    Get result of transaction data and signature verification

    Params:
        tx = `Transaction`
        findUTXO = delegate for finding `Output`
        height = height of block

    Return:
        `null` if the transaction is valid, a string explaining the reason it
        is invalid otherwise.

*******************************************************************************/

public string isInvalidReason (const Transaction tx, UTXOFinder findUTXO,
    const ulong height)
    @safe nothrow
{
    import std.conv;

    if (tx.inputs.length == 0)
        return "Transaction: No input";

    if (tx.outputs.length == 0)
        return "Transaction: No output";

    foreach (output; tx.outputs)
    {
        // disallow negative amounts
        if (!output.value.isValid())
            return "Transaction: Output(s) overflow or underflow";

        // disallow 0 amount
        if (output.value == Amount(0))
            return "Transaction: Value of output is 0";
    }

    const tx_hash = hashFull(tx);

    string isInvalidInput (const ref Input input, ref UTXOSetValue utxo_value,
        ref Amount sum_unspent)
    {
        if (!findUTXO(input.previous, input.index, utxo_value))
            return "Transaction: Input ref not in UTXO";

        if (!utxo_value.output.address.verify(input.signature, tx_hash[]))
            return "Transaction: Input has invalid signature";

        if (!sum_unspent.add(utxo_value.output.value))
            return "Transaction: Input overflow";

        return null;
    }

    Amount sum_unspent;

    if (tx.type == TxType.Freeze)
    {
        foreach (input; tx.inputs)
        {
            UTXOSetValue utxo_value;
            if (auto fail_reason = isInvalidInput(input, utxo_value, sum_unspent))
                return fail_reason;

            if (utxo_value.type != TxType.Payment)
                return "Transaction: Can only freeze a Payment transaction";
        }

        if (sum_unspent.integral() < Amount.MinFreezeAmount.integral())
            return "Transaction: available when the amount is at least 40,000 BOA";
    }
    else if (tx.type == TxType.Payment)
    {
        uint count_freeze = 0;
        foreach (input; tx.inputs)
        {
            UTXOSetValue utxo_value;
            if (auto fail_reason = isInvalidInput(input, utxo_value, sum_unspent))
                return fail_reason;

            // when status is frozen, it will begin to melt
            // In this case, all inputs must be frozen.
            if (utxo_value.type == TxType.Freeze)
                count_freeze++;

            // when status is (frozen->melting->melted) or (frozen->melting)
            if (utxo_value.type == TxType.Payment)
            {
                // when status is still melting
                if (height < utxo_value.unlock_height)
                    return "Transaction: Not available when melting UTXO";
            }
        }

        // current limitation: if any UTXO is frozen, they all must be frozen
        if ((count_freeze > 0) && (count_freeze != tx.inputs.length))
            return "Transaction: Rejected combined inputs (freeze & payment)";
    }
    else
        return "Transaction: Invalid transaction type";

    Amount new_unspent;
    if (!tx.getSumOutput(new_unspent))
        return "Transaction: Referenced Output(s) overflow";
    if (!sum_unspent.sub(new_unspent))
        return "Transaction: Output(s) are higher than Input(s)";
    return null;
}

/// Ditto but returns a bool, only used in unittests
version (unittest)
public bool isValid (const Transaction tx, UTXOFinder findUTXO, ulong height)
    @safe nothrow
{
    return isInvalidReason(tx, findUTXO, height) is null;
}

/// verify transaction data
unittest
{
    import std.format;

    Transaction[Hash] storage;
    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random];

    // Creates the first transaction.
    Transaction previousTx = newCoinbaseTX(key_pairs[0].address, Amount(100));

    // Save
    Hash previousHash = hashFull(previousTx);
    storage[previousHash] = previousTx;

    // Creates the second transaction.
    Transaction secondTx = Transaction(
        TxType.Payment,
        [
            Input(previousHash, 0)
        ],
        [
            Output(Amount(50), key_pairs[1].address)
        ]
    );

    // delegate for finding `UTXOSetValue`
    scope findUTXO = (Hash hash, size_t index, out UTXOSetValue value)
    {
        if (auto tx = hash in storage)
        {
            if (index < tx.outputs.length)
            {
                value.unlock_height = 0;
                value.type = TxType.Payment;
                value.output = tx.outputs[index];
                return true;
            }
        }

        return false;
    };

    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It is validated. (the sum of `Output` < the sum of `Input`)
    assert(secondTx.isValid(findUTXO, 0), format("Transaction data is not validated %s", secondTx));

    secondTx.outputs ~= Output(Amount(50), key_pairs[2].address);
    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It is validated. (the sum of `Output` == the sum of `Input`)
    assert(secondTx.isValid(findUTXO, 0), format("Transaction data is not validated %s", secondTx));

    secondTx.outputs ~= Output(Amount(50), key_pairs[3].address);
    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It isn't validated. (the sum of `Output` > the sum of `Input`)
    assert(!secondTx.isValid(findUTXO, 0), format("Transaction data is not validated %s", secondTx));
}

/// negative output amounts disallowed
unittest
{
    KeyPair[] key_pairs = [KeyPair.random(), KeyPair.random()];
    Transaction tx_1 = newCoinbaseTX(key_pairs[0].address, Amount(1000));
    Hash tx_1_hash = hashFull(tx_1);

    Transaction[Hash] storage;
    storage[tx_1_hash] = tx_1;

    // delegate for finding `Output`
    scope findUTXO = (Hash hash, size_t index, out UTXOSetValue value)
    {
        if (auto tx = hash in storage)
        {
            if (index < tx.outputs.length)
            {
                value.unlock_height = 0;
                value.type = TxType.Payment;
                value.output = tx.outputs[index];
                return true;
            }
        }

        return false;
    };

    // Creates the second transaction.
    Transaction tx_2 =
    {
        TxType.Payment,
        inputs  : [Input(tx_1_hash, 0)],
        // oops
        outputs : [Output(Amount.invalid(-400_000), key_pairs[1].address)]
    };

    tx_2.inputs[0].signature = key_pairs[0].secret.sign(hashFull(tx_2)[]);

    assert(!tx_2.isValid(findUTXO, 0));

    // Creates the third transaction.
    // Reject a transaction whose output value is zero
    Transaction tx_3 =
    {
        TxType.Payment,
        inputs  : [Input(tx_1_hash, 0)],
        outputs : [Output(Amount.invalid(0), key_pairs[1].address)]
    };

    tx_3.inputs[0].signature = key_pairs[0].secret.sign(hashFull(tx_3)[]);

    assert(!tx_3.isValid(findUTXO, 0));
}

/// This creates a new transaction and signs it as a publickey
/// of the previous transaction to create and validate the input.
unittest
{
    import std.format;

    Transaction[Hash] storage;

    immutable(KeyPair)[] key_pairs;
    key_pairs ~= KeyPair.random();
    key_pairs ~= KeyPair.random();
    key_pairs ~= KeyPair.random();

    // delegate for finding `Output`
    scope findUTXO = (Hash hash, size_t index, out UTXOSetValue value)
    {
        if (auto tx = hash in storage)
        {
            if (index < tx.outputs.length)
            {
                value.unlock_height = 0;
                value.type = TxType.Payment;
                value.output = tx.outputs[index];
                return true;
            }
        }

        return false;
    };

    // Create the first transaction.
    Transaction genesisTx = newCoinbaseTX(key_pairs[0].address, Amount(100_000));
    Hash genesisHash = hashFull(genesisTx);
    storage[genesisHash] = genesisTx;
    genesisTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(genesisTx)[]);

    // Create the second transaction.
    Transaction tx1 = Transaction(
        TxType.Payment,
        [
            Input(genesisHash, 0)
        ],
        [
            Output(Amount(1_000), key_pairs[1].address)
        ]
    );

    // Signs the previous hash value.
    Hash tx1Hash = hashFull(tx1);
    tx1.inputs[0].signature = key_pairs[0].secret.sign(tx1Hash[]);
    storage[tx1Hash] = tx1;

    assert(tx1.isValid(findUTXO, 0), format("Transaction signature is not validated %s", tx1));

    Transaction tx2 = Transaction(
        TxType.Payment,
        [
            Input(tx1Hash, 0)
        ],
        [
            Output(Amount(1_000), key_pairs[1].address)
        ]
    );

    Hash tx2Hash = hashFull(tx2);
    // Sign with incorrect key
    tx2.inputs[0].signature = key_pairs[2].secret.sign(tx2Hash[]);
    storage[tx2Hash] = tx2;
    // Signature verification must be error
    assert(!tx2.isValid(findUTXO, 0), format("Transaction signature is not validated %s", tx2));
}

/// verify transactions associated with freezing
unittest
{
    UTXOSetValue[Hash] storage;
    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random];

    Transaction previousTx;
    Transaction secondTx;
    Hash previousHash;

    // delegate for finding `UTXOSetValue`
    scope findUTXO = (Hash hash, size_t index, out UTXOSetValue value)
    {
        const Hash utxo_hash = hashMulti(hash, index);
        if (auto utxo = utxo_hash in storage)
        {
            value = *utxo;
            return true;
        }

        return false;
    };

    // When the privious transaction type is `Payment`, second transaction type is `Freeze`.
    // Second transaction is valid.
    {
        storage.clear;
        // Create the previous transaction with type `TxType.Payment`
        previousTx = newCoinbaseTX(key_pairs[0].address, Amount.MinFreezeAmount);
        previousHash = hashFull(previousTx);
        foreach (idx, output; previousTx.outputs)
        {
            const Hash utxo_hash = hashMulti(previousHash, idx);
            const UTXOSetValue utxo_value = {
                unlock_height: 0,
                type: TxType.Payment,
                output: output
            };
            storage[utxo_hash] = utxo_value;
        }

        // Creates the freezing transaction.
        secondTx = Transaction(
            TxType.Freeze,
            [Input(previousHash, 0)],
            [Output(Amount.MinFreezeAmount, key_pairs[1].address)]
        );
        secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

        // Second Transaction is valid.
        assert(secondTx.isValid(findUTXO, 0));
    }

    // When the privious transaction type is `Freeze`, second transaction type is `Freeze`.
    // Second transaction is invalid.
    {
        storage.clear;
        // Create the previous transaction with type `TxType.Payment`
        previousTx = newCoinbaseTX(key_pairs[0].address, Amount.MinFreezeAmount);
        previousHash = hashFull(previousTx);
        foreach (idx, output; previousTx.outputs)
        {
            const Hash utxo_hash = hashMulti(previousHash, idx);
            const UTXOSetValue utxo_value = {
                unlock_height: 0,
                type: TxType.Freeze,
                output: output
            };
            storage[utxo_hash] = utxo_value;
        }

        // Creates the freezing transaction.
        secondTx = Transaction(
            TxType.Freeze,
            [Input(previousHash, 0)],
            [Output(Amount.MinFreezeAmount, key_pairs[1].address)]
        );
        secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

        // Second Transaction is invalid.
        assert(!secondTx.isValid(findUTXO, 0));
    }

    // When the privious transaction with not enough amount at freezing.
    // Second transaction is invalid.
    {
        storage.clear;
        // Create the previous transaction with type `TxType.Payment`
        previousTx = newCoinbaseTX(key_pairs[0].address, Amount(100_000_000_000L));
        previousHash = hashFull(previousTx);
        foreach (idx, output; previousTx.outputs)
        {
            const Hash utxo_hash = hashMulti(previousHash, idx);
            const UTXOSetValue utxo_value = {
                unlock_height: 0,
                type: TxType.Payment,
                output: output
            };
            storage[utxo_hash] = utxo_value;
        }

        // Creates the freezing transaction.
        secondTx = Transaction(
            TxType.Freeze,
            [Input(previousHash, 0)],
            [Output(Amount(100_000_000_000L), key_pairs[1].address)]
        );
        secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

        // Second Transaction is invalid.
        assert(!secondTx.isValid(findUTXO, 0));
    }

    // When the privious transaction with too many amount at freezings.
    // Second transaction is valid.
    {
        // Create the previous transaction with type `TxType.Payment`
        previousTx = newCoinbaseTX(key_pairs[0].address, Amount(500_000_000_000L));
        previousHash = hashFull(previousTx);
        foreach (idx, output; previousTx.outputs)
        {
            const Hash utxo_hash = hashMulti(previousHash, idx);
            const UTXOSetValue utxo_value = {
                unlock_height: 0,
                type: TxType.Payment,
                output: output
            };
            storage[utxo_hash] = utxo_value;
        }

        // Creates the freezing transaction.
        secondTx = Transaction(
            TxType.Freeze,
            [Input(previousHash, 0)],
            [Output(Amount(500_000_000_000L), key_pairs[1].address)]
        );
        secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

        // Second Transaction is valid.
        assert(secondTx.isValid(findUTXO, 0));
    }
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
    UTXOSetValue[Hash] storage;
    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random];

    ulong block_height = 0;

    Transaction previousTx;
    Transaction secondTx;
    Transaction thirdTx;
    Transaction fourthTx;
    Transaction fifthTx;

    Hash previousHash;
    Hash secondHash;
    Hash thirdHash;
    Hash fifthHash;

    // delegate for finding `UTXOSetValue`
    scope findUTXO = (Hash hash, size_t index, out UTXOSetValue value)
    {
        const Hash utxo_hash = hashMulti(hash, index);
        if (auto utxo = utxo_hash in storage)
        {
            value = *utxo;
            return true;
        }

        return false;
    };

    // Create the previous transaction with type `TxType.Payment`
    // Expected height : 0
    // Expected Status : melted
    {
        block_height = 0;
        previousTx = newCoinbaseTX(key_pairs[0].address, Amount.MinFreezeAmount);

        // Save to UTXOSet
        previousHash = hashFull(previousTx);
        foreach (idx, output; previousTx.outputs)
        {
            const Hash utxo_hash = hashMulti(previousHash, idx);
            const UTXOSetValue utxo_value = {
                unlock_height: block_height+1,
                type: TxType.Payment,
                output: output
            };
            storage[utxo_hash] = utxo_value;
        }
    }

    // Creates the second freezing transaction
    // Current height  : 0
    // Current Status  : melted
    // Expected height : 1
    // Expected Status : frozen
    {
        block_height = 1;
        secondTx = Transaction(
            TxType.Freeze,
            [Input(previousHash, 0)],
            [Output(Amount.MinFreezeAmount, key_pairs[1].address)]
        );
        secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

        // Second Transaction is VALID.
        assert(secondTx.isValid(findUTXO, block_height));

        // Save to UTXOSet
        secondHash = hashFull(secondTx);
        foreach (idx, output; secondTx.outputs)
        {
            const Hash utxo_hash = hashMulti(secondHash, idx);
            const UTXOSetValue utxo_value = {
                unlock_height: block_height+1,
                type: TxType.Freeze,
                output: output
            };
            storage[utxo_hash] = utxo_value;
        }
    }

    // Creates the third payment transaction
    // Current height  : 1
    // Current Status  : frozen
    // Expected height : 2
    // Expected Status : melting
    {
        block_height = 2;
        thirdTx = Transaction(
            TxType.Payment,
            [Input(secondHash, 0)],
            [Output(Amount.MinFreezeAmount, key_pairs[2].address)]
        );
        thirdTx.inputs[0].signature = key_pairs[1].secret.sign(hashFull(thirdTx)[]);

        // Third Transaction is VALID.
        assert(thirdTx.isValid(findUTXO, block_height));

        // Save to UTXOSet
        thirdHash = hashFull(thirdTx);
        foreach (idx, output; thirdTx.outputs)
        {
            const Hash utxo_hash = hashMulti(thirdHash, idx);
            const UTXOSetValue utxo_value = {
                unlock_height: block_height+2016,
                type: TxType.Payment,
                output: output
            };
            storage[utxo_hash] = utxo_value;
        }
    }

    // Creates the fourth payment transaction : didn't change to melted not yet
    // Current height  : 2+2014
    // Current Status  : melting
    // Expected height : 2+2015
    // Expected Status : melting
    {
        block_height = 2+2015;  //  this is melting, not melted
        fourthTx = Transaction(
            TxType.Payment,
            [Input(thirdHash, 0)],
            [Output(Amount.MinFreezeAmount, key_pairs[3].address)]
        );
        fourthTx.inputs[0].signature = key_pairs[2].secret.sign(hashFull(fourthTx)[]);

        // Third Transaction is INVALID.
        assert(!fourthTx.isValid(findUTXO, block_height));
    }

    // Creates the fifth payment transaction
    // Current height  : 2+2015
    // Current Status  : melting
    // Expected height : 2+2016
    // Expected Status : melted
    {
        block_height = 2+2016;  //  this is melted
        fifthTx = Transaction(
            TxType.Payment,
            [Input(thirdHash, 0)],
            [Output(Amount.MinFreezeAmount, key_pairs[3].address)]
        );
        fifthTx.inputs[0].signature = key_pairs[2].secret.sign(hashFull(fourthTx)[]);

        // Third Transaction is VALID.
        assert(fifthTx.isValid(findUTXO, block_height));

        // Save to UTXOSet
        fifthHash = hashFull(fifthTx);
        foreach (idx, output; fifthTx.outputs)
        {
            const Hash utxo_hash = hashMulti(fifthHash, idx);
            const UTXOSetValue utxo_value = {
                unlock_height: block_height+1,
                type: TxType.Payment,
                output: output
            };
            storage[utxo_hash] = utxo_value;
        }
    }
}

/// test for transactions having no input or no output
unittest
{
    import std.format;
    import std.string;
    import std.algorithm.searching;

    Transaction[Hash] storage;
    KeyPair key_pair = KeyPair.random;

    // delegate for finding `Output`
    scope findUTXO = (Hash hash, size_t index, out UTXOSetValue value)
    {
        if (auto tx = hash in storage)
        {
            if (index < tx.outputs.length)
            {
                value.unlock_height = 0;
                value.type = TxType.Payment;
                value.output = tx.outputs[index];
                return true;
            }
        }
        return false;
    };

    // create a transaction having no input
    Transaction oneTx = Transaction(
        TxType.Payment,
        [],
        [Output(Amount(50), key_pair.address)]
    );
    Hash oneHash = hashFull(oneTx);
    storage[oneHash] = oneTx;

    // test for Payment transaction having no input
    assert(canFind(toLower(oneTx.isInvalidReason(findUTXO, 0)), "no input"),
        format("Tx having no input should not pass validation. tx: %s", oneTx));

    // create a transaction
    Transaction firstTx = newCoinbaseTX(key_pair.address, Amount(100_1000));
    Hash firstHash = hashFull(firstTx);
    storage[firstHash] = firstTx;
    firstTx.inputs[0].signature = key_pair.secret.sign(firstHash[]);

    // create a transaction having no output
    Transaction secondTx = Transaction(
        TxType.Payment,
        [Input(firstHash, 0)],
        []
    );
    Hash secondHash = hashFull(secondTx);
    storage[secondHash] = secondTx;

    // test for Freeze transaction having no output
    assert(canFind(toLower(secondTx.isInvalidReason(findUTXO, 0)), "no output"),
        format("Tx having no output should not pass validation. tx: %s", secondTx));
}

/// test for transaction having combined inputs
unittest
{
    import std.format;
    Transaction[Hash] storage;
    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random];

    // delegate for finding `UTXOSetValue`
    scope findUTXO = (Hash hash, size_t index, out UTXOSetValue value)
    {
        if (auto tx = hash in storage)
        {
            if (index < tx.outputs.length)
            {
                value.unlock_height = 0;
                value.type = tx.type;
                value.output = tx.outputs[index];
                return true;
            }
        }
        return false;
    };

    // create the first transaction.
    Transaction firstTx = Transaction(
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output(Amount(100), key_pairs[0].address)]
    );
    Hash firstHash = hashFull(firstTx);
    storage[firstHash] = firstTx;

    // create the second transaction.
    Transaction secondTx = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount(100), key_pairs[0].address)]
    );
    Hash secondHash = hashFull(secondTx);
    storage[secondHash] = secondTx;

    // create the third transaction
    Transaction thirdTx = Transaction(
        TxType.Payment,
        [Input(firstHash, 0), Input(secondHash, 0)],
        [Output(Amount(100), key_pairs[1].address)]
    );
    Hash thirdHash = hashFull(thirdTx);
    storage[thirdHash] = thirdTx;
    thirdTx.inputs[0].signature = key_pairs[0].secret.sign(thirdHash[]);
    thirdTx.inputs[1].signature = key_pairs[0].secret.sign(thirdHash[]);

    // test for transaction having combined inputs
    assert(!thirdTx.isValid(findUTXO, 0),
        format("Tx having combined inputs should not pass validation. tx: %s", thirdTx));
}

/// test for unknown transaction type
unittest
{
    import std.format;
    Transaction[Hash] storage;
    TxType unknown_type = cast(TxType)100; // any number is OK for test except 0 and 1
    KeyPair key_pair = KeyPair.random;

    // create a transaction having unknown transaction type
    Transaction firstTx = Transaction(
        unknown_type,
        [Input(Hash.init, 0)],
        [Output(Amount(100), key_pair.address)]
    );
    Hash firstHash = hashFull(firstTx);
    storage[firstHash] = firstTx;

    // test for unknown transaction type
    assert(!firstTx.isValid(null, 0),
        format("Tx having unknown type should not pass validation. tx: %s", firstTx));
}

/// test for checking input overflow for Payment and Freeze type transactions
unittest
{
    import std.format;
    Transaction[Hash] storage;
    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random];

    // delegate for finding `UTXOSetValue`
    scope findUTXO = (Hash hash, size_t index, out UTXOSetValue value)
    {
        if (auto tx = hash in storage)
        {
            if (index < tx.outputs.length)
            {
                value.unlock_height = 0;
                value.type = tx.type;
                value.output = tx.outputs[index];
                return true;
            }
        }
        return false;
    };

    // create the first transaction
    auto firstTx = Transaction(
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output(Amount.MaxUnitSupply, key_pairs[0].address)]
    );
    auto firstHash = hashFull(firstTx);
    storage[firstHash] = firstTx;

    // create the second transaction
    auto secondTx = Transaction(
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output(Amount(100), key_pairs[0].address)]
    );
    auto secondHash = hashFull(secondTx);
    storage[secondHash] = secondTx;

    // create the third transaction
    auto thirdTx = Transaction(
        TxType.Payment,
        [Input(firstHash, 0), Input(secondHash, 0)],
        [Output(Amount(100), key_pairs[1].address)]
    );
    auto thirdHash = hashFull(thirdTx);
    storage[thirdHash] = thirdTx;
    thirdTx.inputs[0].signature = key_pairs[0].secret.sign(thirdHash[]);
    thirdTx.inputs[1].signature = key_pairs[0].secret.sign(thirdHash[]);

    // test for input overflow in Payment transaction
    assert(!thirdTx.isValid(findUTXO, 0),
        format("Tx having input overflow should not pass validation. tx: %s", thirdTx));

    // create the fourth transaction
    auto fourthTx = Transaction(
        TxType.Freeze,
        [Input(firstHash, 0), Input(secondHash, 0)],
        [Output(Amount(100), key_pairs[1].address)]
    );
    auto fourthHash = hashFull(fourthTx);
    storage[fourthHash] = fourthTx;
    fourthTx.inputs[0].signature = key_pairs[0].secret.sign(fourthHash[]);
    fourthTx.inputs[1].signature = key_pairs[0].secret.sign(fourthHash[]);

    // test for input overflow in Freeze transaction
    assert(!fourthTx.isValid(findUTXO, 0),
        format("Tx having input overflow should not pass validation. tx: %s", fourthTx));
}

/// test for checking output overflow for Payment type transaction
unittest
{
    import std.format;
    Transaction[Hash] storage;
    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random];

    // delegate for finding `UTXOSetValue`
    scope findUTXO = (Hash hash, size_t index, out UTXOSetValue value)
    {
        if (auto tx = hash in storage)
        {
            if (index < tx.outputs.length)
            {
                value.unlock_height = 0;
                value.type = tx.type;
                value.output = tx.outputs[index];
                return true;
            }
        }
        return false;
    };

    // create the first transaction
    auto firstTx = Transaction(
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output(Amount(100), key_pairs[0].address)]
    );
    auto firstHash = hashFull(firstTx);
    storage[firstHash] = firstTx;

    // create the second transaction
    auto secondTx = Transaction(
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output(Amount(100), key_pairs[0].address)]
    );
    auto secondHash = hashFull(secondTx);
    storage[secondHash] = secondTx;

    // create the third transaction
    auto thirdTx = Transaction(
        TxType.Payment,
        [Input(firstHash, 0), Input(secondHash, 0)],
        [Output(Amount.MaxUnitSupply, key_pairs[1].address),
            Output(Amount(100), key_pairs[1].address)]
    );
    auto thirdHash = hashFull(thirdTx);
    storage[thirdHash] = thirdTx;
    thirdTx.inputs[0].signature = key_pairs[0].secret.sign(thirdHash[]);
    thirdTx.inputs[1].signature = key_pairs[0].secret.sign(thirdHash[]);

    // test for output overflow in Payment transaction
    assert(!thirdTx.isValid(findUTXO, 0),
        format("Tx having output overflow should not pass validation. tx: %s", thirdTx));
}

/*******************************************************************************

    Check the validity of a block.

    A block is considered valid if:
        - its height is the previous block height + 1
        - its prev_hash is the previous block header's hash
        - the number of transactions in the block are equal to Block.TxsInBlock
        - the merkle root in the header matches the re-built merkle tree root
          based on the included transactions in the block
        - Transactions are ordered by their hash value
        - all the the transactions pass validation, which implies:
            - signatures are authentic
            - the inputs spend an output which must be found with the
              findUTXO() delegate

    Note that checking for transactions which double-spend is the responsibility
    of the findUTXO() delegate. During validation, whenever this delegate is
    called it should also keep track of the used UTXOs, thereby marking
    it as a spent output. See the `findNonSpent` function in the
    unittest for an example.

    Params:
        block = the block to check
        prev_height = the height of the direct ancestor of this block
        prev_hash = the hash of the direct ancestor of this block
        findUTXO = delegate to find the referenced unspent UTXOs with

    Returns:
        `null` if the block is valid, a string explaining the reason it
        is invalid otherwise.

*******************************************************************************/

public string isInvalidReason (const ref Block block, in ulong prev_height,
    in Hash prev_hash, UTXOFinder findUTXO) nothrow @safe
{
    import std.algorithm;

    // special case for the genesis block
    if (block.header.height == 0)
        return block == GenesisBlock ?
            null : "Block: Height 0 but not Genesis block";

    if (block.header.height > prev_height + 1)
        return "Block: Height is above expected height";
    if (block.header.height < prev_height + 1)
        return "Block: Height is under expected height";

    if (block.header.prev_block != prev_hash)
        return "Block: Header.prev_block does not match previous block";

    if (block.txs.length != Block.TxsInBlock)
        return "Block: Number of transaction mismatch";

    if (!block.txs.isSorted())
        return "Block: Transactions are not sorted";

    foreach (const ref tx; block.txs)
    {
        if (auto fail_reason = tx.isInvalidReason(findUTXO, block.header.height))
            return fail_reason;
    }

    Hash[] merkle_tree;
    if (block.header.merkle_root != Block.buildMerkleTree(block.txs, merkle_tree))
        return "Block: Merkle root does not match header's";

    return null;
}

/*******************************************************************************

    Check the validity of an enrollment.

    A Validator's enrollment is considered valid if:
        - UTXO is unspent frozen utxo
        - Signatures are authentic
        - The frozen amount must be equal to or greater than 40,000 BOA
        - The block height must be at least unlock_height or greater of the UTXO.

    Params:
        block_height = the height at which the enrollment wants to be
        added to the block
        enrollment = The enrollment of the target to be verified
        findUTXO = delegate to find the referenced unspent UTXOs with

    Returns:
        `null` if the validator's UTXO is valid, otherwise a string
        explaining the reason it is invalid.

*******************************************************************************/

public string isInvalidEnrollmentReason (const ulong block_height,
    const ref Enrollment enrollment, UTXOFinder findUTXO) nothrow @safe
{
    UTXOSetValue utxo_set_value;
    if (!findUTXO(enrollment.utxo_key, size_t.max, utxo_set_value))
        return "Unspent frozen UTXO not found for the validator.";

    if (utxo_set_value.type != TxType.Freeze)
        return "UTXO is not frozen.";

    Point address;
    try
    {
        address = Point(utxo_set_value.output.address);
    }
    catch (Exception ex)
    {
        return "Error converting address to point";
    }

    if (!verify(address, enrollment.enroll_sig, enrollment))
        return "Enrollment signature verification has an error.";

    if (utxo_set_value.output.value.integral() < Amount.MinFreezeAmount.integral())
    {
        static immutable Message = "The frozen amount must be equal to or greater than " ~
            Amount.MinFreezeAmount.integral().to!string ~ " BOA.";
        return Message;
    }

    if (block_height < utxo_set_value.unlock_height)
        return "The UTXO is not unlocked.";

    return null;
}

/// Ditto but returns `bool`, only usable in unittests
version (unittest)
public bool isValidEnrollment (const ulong block_height,
    const ref Enrollment enrollment, UTXOFinder findUTXO) nothrow @safe
{
    return isInvalidEnrollmentReason(block_height, enrollment, findUTXO) is null;
}

/// Ditto but returns `bool`, only usable in unittests
version (unittest)
public bool isValid (const ref Block block, ulong prev_height,
    Hash prev_hash, UTXOFinder findUTXO) nothrow @safe
{
    return isInvalidReason(block, prev_height, prev_hash, findUTXO) is null;
}

///
unittest
{
    import agora.consensus.Genesis;
    import std.algorithm;
    import std.range;

    // note: using array as a workaround to be able to store const Transactions
    const(Transaction)[][Hash] tx_map;
    scope findUTXO = (Hash hash, size_t index, out UTXOSetValue value)
    {
        if (auto tx = hash in tx_map)

        {
            if (index < (*tx).front.outputs.length)
            {
                value.unlock_height = 0;
                value.type = TxType.Payment;
                value.output = (*tx).front.outputs[index];
                return true;
            }
        }

        return false;
    };

    auto gen_key = getGenesisKeyPair();
    assert(GenesisBlock.isValid(GenesisBlock.header.height, Hash.init, null));
    auto gen_hash = GenesisBlock.header.hashFull();

    tx_map[GenesisTransaction.hashFull()] = [GenesisTransaction];
    auto txs = makeChainedTransactions(gen_key, null, 1).sort.array;
    auto block = makeNewBlock(GenesisBlock, txs);

    // height check
    assert(block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    block.header.height = 100;
    assert(!block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    block.header.height = GenesisBlock.header.height + 1;
    assert(block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    /// .prev_block check
    block.header.prev_block = block.header.hashFull();
    assert(!block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    block.header.prev_block = gen_hash;
    assert(block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    /// .txs length check
    block.txs = txs[0 .. $ - 1];
    assert(!block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    block.txs = (txs ~ txs).sort.array;
    assert(!block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    block.txs = txs;
    assert(block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    /// Txs sorting check
    block.txs = txs.reverse;
    assert(!block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    block.txs = txs.reverse;
    assert(block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    /// no matching utxo => fail
    tx_map.clear();
    assert(!block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    tx_map[GenesisTransaction.hashFull()] = [GenesisTransaction];
    assert(block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    tx_map.clear();  // genesis is spent
    auto prev_txs = txs;
    prev_txs.each!(tx => tx_map[tx.hashFull()] = [tx]);  // these will be spent

    auto prev_block = block;
    txs = makeChainedTransactions(gen_key, prev_txs, 1);
    block = makeNewBlock(prev_block, txs);
    assert(block.isValid(prev_block.header.height, prev_block.header.hashFull(),
        findUTXO));

    assert(prev_txs.length > 0);  // sanity check
    foreach (tx; prev_txs)
    {
        // one utxo missing from the set => fail
        tx_map.remove(tx.hashFull);
        assert(!block.isValid(prev_block.header.height, prev_block.header.hashFull(),
            findUTXO));

        tx_map[tx.hashFull] = [tx];
        assert(block.isValid(prev_block.header.height, prev_block.header.hashFull(),
            findUTXO));
    }

    // the key is hashMulti(hash(prev_tx), index)
    Output[Hash] utxo_set;

    foreach (idx, ref output; GenesisTransaction.outputs)
        utxo_set[hashMulti(GenesisTransaction.hashFull, idx)] = output;

    assert(utxo_set.length != 0);
    const utxo_set_len = utxo_set.length;

    // contains the used set of UTXOs during validation (to prevent double-spend)
    Output[Hash] used_set;
    UTXOFinder findNonSpent = (Hash hash, size_t index, out UTXOSetValue value)
    {
        auto utxo_hash = hashMulti(hash, index);

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
    txs = makeChainedTransactions(gen_key, null, 1).sort.array;
    block = makeNewBlock(GenesisBlock, txs);
    assert(block.isValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
            findNonSpent));

    assert(used_set.length == utxo_set_len);  // consumed all utxos

    // reset state
    used_set.clear();

    // consumed same utxo twice => fail
    txs[$ - 1] = txs[$ - 2];
    block = makeNewBlock(GenesisBlock, txs);
    assert(!block.isValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
            findNonSpent));

    // we stopped validation due to a double-spend
    assert(used_set.length == txs.length - 1);

    txs = makeChainedTransactions(gen_key, prev_txs, 1);
    block = makeNewBlock(GenesisBlock, txs);
    assert(block.isValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
        findUTXO));

    // modify the last hex byte of the merkle root
    block.header.merkle_root[][$ - 1]++;

    assert(!block.isValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
        findUTXO));

    // now restore it back to what it was
    block.header.merkle_root[][$ - 1]--;
    assert(block.isValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
        findUTXO));
    const last_root = block.header.merkle_root;

    // txs with a different amount
    txs = makeChainedTransactions(gen_key, prev_txs, 1, 20_000_000);
    block = makeNewBlock(GenesisBlock, txs);
    assert(block.isValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
        findUTXO));

    // the previous merkle root should not match the new txs
    block.header.merkle_root = last_root;
    assert(!block.isValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
        findUTXO));
}

///
unittest
{
    import agora.common.Amount;
    import agora.consensus.data.Enrollment;
    import agora.consensus.data.Transaction;
    import agora.consensus.data.UTXOSet;
    import agora.consensus.Validation;

    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random];

    auto utxo_set = new UTXOSet(":memory:");
    scope (exit) utxo_set.shutdown();
    UTXOFinder utxoFinder = utxo_set.getUTXOFinder();

    // normal frozen transaction
    Transaction tx1 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount.MinFreezeAmount, key_pairs[0].address)]
    );

    // payment transaction
    Transaction tx2 = Transaction(
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output(Amount.MinFreezeAmount, key_pairs[1].address)]
    );

    // Insufficient freeze amount transaction
    Transaction tx3 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount(1), key_pairs[2].address)]
    );

    // normal freeze amount transaction
    Transaction tx4 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount.MinFreezeAmount, key_pairs[3].address)]
    );

    auto utxo_hash1 = utxo_set.getHash(hashFull(tx1), 0);
    auto utxo_hash2 = utxo_set.getHash(hashFull(tx2), 0);
    auto utxo_hash3 = utxo_set.getHash(hashFull(tx3), 0);
    auto utxo_hash4 = utxo_set.getHash(hashFull(tx4), 0);

    Pair signature_noise = Pair.random;

    Pair node_key_pair_1;
    node_key_pair_1.v = secretKeyToCurveScalar(key_pairs[0].secret);
    node_key_pair_1.V = node_key_pair_1.v.toPoint();

    Enrollment enroll1;
    enroll1.utxo_key = utxo_hash1;
    enroll1.random_seed = hashFull(Scalar.random());
    enroll1.cycle_length = 1008;
    enroll1.enroll_sig = sign(node_key_pair_1.v, node_key_pair_1.V, signature_noise.V,
        signature_noise.v, enroll1);

    Pair node_key_pair_2;
    node_key_pair_2.v = secretKeyToCurveScalar(key_pairs[1].secret);
    node_key_pair_2.V = node_key_pair_2.v.toPoint();

    Enrollment enroll2;
    enroll2.utxo_key = utxo_hash2;
    enroll2.random_seed = hashFull(Scalar.random());
    enroll2.cycle_length = 1008;
    enroll2.enroll_sig = sign(node_key_pair_2.v, node_key_pair_2.V, signature_noise.V,
        signature_noise.v, enroll2);

    Pair node_key_pair_3;
    node_key_pair_3.v = secretKeyToCurveScalar(key_pairs[2].secret);
    node_key_pair_3.V = node_key_pair_3.v.toPoint();

    Enrollment enroll3;
    enroll3.utxo_key = utxo_hash3;
    enroll3.random_seed = hashFull(Scalar.random());
    enroll3.cycle_length = 1008;
    enroll3.enroll_sig = sign(node_key_pair_3.v, node_key_pair_3.V, signature_noise.V,
        signature_noise.v, enroll3);

    Pair node_key_pair_4;
    // Invalid secret key
    node_key_pair_4.v = secretKeyToCurveScalar(key_pairs[1].secret);
    node_key_pair_4.V = node_key_pair_4.v.toPoint();

    Enrollment enroll4;
    enroll4.utxo_key = utxo_hash4;
    enroll4.random_seed = hashFull(Scalar.random());
    enroll4.cycle_length = 1008;
    enroll4.enroll_sig = sign(node_key_pair_4.v, node_key_pair_4.V, signature_noise.V,
        signature_noise.v, enroll4);

    assert(!isValidEnrollment(1, enroll1, utxoFinder));
    assert(!isValidEnrollment(1, enroll2, utxoFinder));
    assert(!isValidEnrollment(1, enroll3, utxoFinder));
    assert(!isValidEnrollment(1, enroll4, utxoFinder));

    utxo_set.updateUTXOCache(tx1, 0);
    utxo_set.updateUTXOCache(tx2, 0);
    utxo_set.updateUTXOCache(tx3, 0);
    utxo_set.updateUTXOCache(tx4, 0);

    auto utxos1 = utxo_set.getUTXOs(key_pairs[0].address);
    assert(utxos1[utxo_hash1].output.address == key_pairs[0].address);
    auto utxos2 = utxo_set.getUTXOs(key_pairs[1].address);
    assert(utxos2[utxo_hash2].output.address == key_pairs[1].address);
    auto utxos3 = utxo_set.getUTXOs(key_pairs[2].address);
    assert(utxos3[utxo_hash3].output.address == key_pairs[2].address);
    auto utxos4 = utxo_set.getUTXOs(key_pairs[3].address);
    assert(utxos4[utxo_hash4].output.address == key_pairs[3].address);

    // Nomal
    assert(isValidEnrollment(1, enroll1, utxoFinder));

    // Unspent frozen UTXO not found for the validator.
    assert(!isValidEnrollment(1, enroll1, utxoFinder));

    // UTXO is not frozen.
    assert(!isValidEnrollment(1, enroll2, utxoFinder));

    // The frozen amount must be equal to or greater than 40,000 BOA.
    assert(!isValidEnrollment(1, enroll3, utxoFinder));

    // Enrollment signature verification has an error.
    assert(!isValidEnrollment(1, enroll4, utxoFinder));
}

/// isInvalidSignatureReason tests
unittest
{
    import agora.consensus.data.Block;
    import agora.consensus.Genesis;
    import agora.common.Deserializer;
    import agora.common.Serializer;
    import agora.common.BitField;
    import agora.common.crypto.Schnorr;
    import agora.consensus.data.Enrollment;
    import agora.consensus.data.Transaction;

    import std.algorithm;
    import std.format;
    import std.range;
    import std.stdio;

    Point[] pub_keys;

    /// Return the index of the key into the public key array.
    /// The index is 'ushort' to match the validators bitfield array
    ushort getKeyIndex (Point key)
    {
        assert(pub_keys.isSorted(), "Keys must be sorted!");
        auto res = pub_keys.countUntil(key);
        assert(res >= 0);
        assert(res < ushort.max);
        return cast(ushort)res;
    }

    /// A simplified example of a node which signs blocks
    class Node
    {
        /// these should be calculated by other validating nodes, here for convenience
        public Point[ulong] pub_R_map;

        /// preimages of this node, which the node openly shares (could also share subset, as per YP)
        public Hash[ulong] preimage_map;

        /// note: not signed, used only for testing
        public Enrollment enroll;

        /// Key pair of this node
        private Pair pair;

        /// A Node's private map of r's for each block height which it wants to sign
        private Scalar[ulong] priv_r_map;

        this ()
        {
            auto v = KeyPair.random().secret.secretKeyToCurveScalar();
            this.pair = Pair(v, v.toPoint());

            this.enroll.cycle_length = 1008;
            auto rand_src = Scalar.random();

            Hash[] preimages;
            preimages ~= hashFull(rand_src);
            foreach (idx; 0 .. this.enroll.cycle_length - 1)
                preimages ~= hashFull(preimages[idx]);

            auto r = Pair.random().v;
            foreach (idx, preimage; preimages.retro.enumerate)
            {
                this.preimage_map[idx] = preimage;

                r = r + Scalar(preimage);
                this.priv_r_map[idx] = r;

                this.pub_R_map[idx] = r.toPoint();
            }
        }

        ///
        void signBlock (ref Block block, Point[] pub_keys, Point P, Point R)
        {
            this.signBlock(getKeyIndex(this.pair.V), block, pub_keys, P, R);
        }

        /// overload which can be called with a different signer index to test signature forgery
        void signBlock (ushort signer_index, ref Block block, Point[] pub_keys, Point P, Point R)
        {
            auto r = this.priv_r_map[block.header.height];
            auto sig = sign(this.pair.v, P, R, r, block.header);
            block.header.signature.s = block.header.signature.s + sig.s;
            block.header.validators[signer_index] = true;  // mark that we signed this block
        }
    }

    // the public preimage data, and the R's calculated from the preimage data
    PreimagesMap preimages_map;
    PubRMap pub_R_map;

    scope node_1 = new Node();
    scope node_2 = new Node();

    // validator keys should be sorted in some defined order
    pub_keys = [node_1.pair.V, node_2.pair.V];
    sort(pub_keys);

    // populate the preimages and public R's (calculated)
    preimages_map[getKeyIndex(node_1.pair.V)] = node_1.preimage_map;
    preimages_map[getKeyIndex(node_2.pair.V)] = node_2.preimage_map;
    pub_R_map[getKeyIndex(node_1.pair.V)] = node_1.pub_R_map;
    pub_R_map[getKeyIndex(node_2.pair.V)] = node_2.pub_R_map;

    // prepare block 1 containing enrollment data (this should actually be genesis block)
    auto gen_key = getGenesisKeyPair();
    auto txs = makeChainedTransactions(gen_key, null, 1).sort.array;
    auto block_1 = makeNewBlock(GenesisBlock, txs);
    block_1.header.enrollments ~= node_1.enroll;  // validate blocks #2+
    block_1.header.enrollments ~= node_2.enroll;  // ditto

    // introduce node 3, which will validate Block #3+
    scope node_3 = new Node();

    // prepare block 2 which will be signed by nodes 1 & 2
    auto txs_2 = makeChainedTransactions(gen_key, txs, 1).sort.array;
    auto block_2 = makeNewBlock(block_1, txs_2);
    block_2.header.validators = BitField(2);  // two validators
    block_2.header.enrollments ~= node_3.enroll;  // validate blocks #3+

    // P is the sum of all validators' public keys for block #2
    Point P = pub_keys[0] + pub_keys[1];

    // R is the sum of all the validators' Rs
    Point R = pub_R_map[getKeyIndex(node_1.pair.V)][block_2.header.height] +
              pub_R_map[getKeyIndex(node_2.pair.V)][block_2.header.height];
    block_2.header.signature.R = R;

    // none of the nodes signed
    assert(isInvalidSignatureReason(block_2.header, preimages_map, pub_R_map, pub_keys)
        == "Not enough validators signed this block");

    // not all nodes which agreed signed => Fail
    node_1.signBlock(block_2, pub_keys, P, R);
    assert(isInvalidSignatureReason(block_2.header, preimages_map, pub_R_map, pub_keys)
        == "Signature.R does not match expected R");

    // all nodes signed => Ok
    node_2.signBlock(block_2, pub_keys, P, R);
    assert(isInvalidSignatureReason(block_2.header, preimages_map, pub_R_map, pub_keys) is null);

    // forge test: node 3 tried to add a forged signature to the block
    auto backup = block_2.serializeFull.deserializeFull!Block;
    auto validators = BitField(3);
    validators[0] = block_2.header.validators[0];
    validators[1] = block_2.header.validators[1];
    block_2.header.validators = validators;
    node_3.signBlock(2, block_2, pub_keys, P, R);  // additional signature at index #2
    assert(isInvalidSignatureReason(block_2.header, preimages_map, pub_R_map, pub_keys)
        == "Validator is not enrolled");

    // forge test: node 3 tried to replace a signature of an existing node with its own
    block_2 = backup;
    assert(isInvalidSignatureReason(block_2.header, preimages_map, pub_R_map, pub_keys) is null);  // sanity check
    node_3.signBlock(0, block_2, pub_keys, P, R);  // fake signature at index #0
    assert(isInvalidSignatureReason(block_2.header, preimages_map, pub_R_map, pub_keys)
        == "Signature is invalid");

    block_2 = backup;  // restore good block
    assert(isInvalidSignatureReason(block_2.header, preimages_map, pub_R_map, pub_keys) is null);  // sanity check

    // prepare block 3
    auto txs_3 = makeChainedTransactions(gen_key, txs_2, 1).sort.array;
    auto block_3 = makeNewBlock(block_2, txs_3);
    block_3.header.validators = BitField(3);  // three validators

    // update the list of public keys and preimages
    pub_keys = [node_1.pair.V, node_2.pair.V, node_3.pair.V];
    sort(pub_keys);

    // populate the preimages and public R's (calculated)
    preimages_map[getKeyIndex(node_1.pair.V)] = node_1.preimage_map;
    preimages_map[getKeyIndex(node_2.pair.V)] = node_2.preimage_map;
    preimages_map[getKeyIndex(node_3.pair.V)] = node_3.preimage_map;
    pub_R_map[getKeyIndex(node_1.pair.V)] = node_1.pub_R_map;
    pub_R_map[getKeyIndex(node_2.pair.V)] = node_2.pub_R_map;
    pub_R_map[getKeyIndex(node_3.pair.V)] = node_3.pub_R_map;

    // P is the sum of all validators' public keys
    P = pub_keys[0] + pub_keys[1] + pub_keys[2];

    // R is the sum of all the validators' Rs
    R = pub_R_map[getKeyIndex(node_1.pair.V)][block_3.header.height] +
        pub_R_map[getKeyIndex(node_2.pair.V)][block_3.header.height] +
        pub_R_map[getKeyIndex(node_3.pair.V)][block_3.header.height];
    block_3.header.signature.R = R;

    // 1 / 3 signed => Fail
    node_1.signBlock(block_3, pub_keys, P, R);
    assert(isInvalidSignatureReason(block_3.header, preimages_map, pub_R_map, pub_keys)
        == "Signature.R does not match expected R");

    // 2 / 3 signed => Fail
    node_2.signBlock(block_3, pub_keys, P, R);
    assert(isInvalidSignatureReason(block_3.header, preimages_map, pub_R_map, pub_keys)
        == "Signature.R does not match expected R");

    // 3 / 3 signed => Ok
    node_3.signBlock(block_3, pub_keys, P, R);
    assert(isInvalidSignatureReason(block_3.header, preimages_map, pub_R_map, pub_keys) is null);

    // test-case: validator 3 did not provide the preimage for this block height
    preimages_map[getKeyIndex(node_3.pair.V)].remove(block_3.header.height);
    assert(isInvalidSignatureReason(block_3.header, preimages_map, pub_R_map, pub_keys)
        == "Validator has not revealed the preimage for this block height");

    // test-case: validator 3 did not provide any preimages
    preimages_map.remove(getKeyIndex(node_3.pair.V));
    assert(isInvalidSignatureReason(block_3.header, preimages_map, pub_R_map, pub_keys)
        == "Validator has not revealed any preimages");
}
