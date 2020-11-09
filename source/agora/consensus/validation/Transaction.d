
/*******************************************************************************

    Contains validation routines for transactions

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.validation.Transaction;

import agora.common.Amount;
import agora.common.Hash;
import agora.common.Types;
import agora.consensus.data.DataPayload;
import agora.consensus.data.Transaction;
import agora.consensus.Fee;
import agora.consensus.state.UTXOSet;

version (unittest)
{
    import agora.common.crypto.Key;
}

/*******************************************************************************

    Get result of transaction data and signature verification

    Params:
        tx = `Transaction`
        findUTXO = delegate for finding `Output`
        height = height of block
        checkFee = delegate for checking tx fee

    Return:
        `null` if the transaction is valid, a string explaining the reason it
        is invalid otherwise.

*******************************************************************************/

public string isInvalidReason (
    in Transaction tx, scope UTXOFinder findUTXO, in Height height,
    scope string delegate (in Transaction, Amount) @safe nothrow checkFee)
    @safe nothrow
{
    import std.conv;

    if (tx.type != TxType.Coinbase && tx.inputs.length == 0)
        return "Transaction: No input";

    if (tx.outputs.length == 0)
        return "Transaction: No output";

    if (tx.lock_height > height)
        return "Transaction: Not unlocked for this height";

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

    string isInvalidInput (const ref Input input, ref UTXO utxo_value,
        ref Amount sum_unspent)
    {
        if (!findUTXO(input.utxo, utxo_value))
            return "Transaction: Input ref not in UTXO";

        if (!utxo_value.output.address.verify(input.signature, tx_hash[]))
            return "Transaction: Input has invalid signature";

        if (!sum_unspent.add(utxo_value.output.value))
            return "Transaction: Input overflow";

        // note: this is strictly not necessary to be here, the Input's script
        // should be evaluated for validity and then the Input could be kept
        // until the unlock height becomes valid. Alternatively we could reject
        // it here right away and force the party to send it again at the right
        // time. However, we run into a risk if we ever implement caching of
        // rejecting them if they're submitted too early.
        if (height < utxo_value.unlock_height + input.unlock_age)
            return "Transanction: Input's unlock age cannot be used for this block height";

        return null;
    }

    Amount sum_unspent;

    if (tx.type == TxType.Freeze)
    {
        if (tx.payload.data.length != 0)
            return "Transaction: Freeze cannot have data payload";

        foreach (input; tx.inputs)
        {
            UTXO utxo_value;
            if (auto fail_reason = isInvalidInput(input, utxo_value, sum_unspent))
                return fail_reason;

            if (utxo_value.type == TxType.Freeze)
                return "Transaction: Can't freeze an already frozen transaction";
        }

        if (sum_unspent.integral() < Amount.MinFreezeAmount.integral())
            return "Transaction: available when the amount is at least 40,000 BOA";
    }
    else if (tx.type == TxType.Payment)
    {
        uint count_freeze = 0;
        foreach (input; tx.inputs)
        {
            UTXO utxo_value;
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
    else if (tx.type == TxType.Coinbase)
    {
        if (tx.inputs.length != 1)
            return "Transaction: Coinbase transactions must" ~
                "include a single Input";

        if (tx.inputs[0] != Input(height))
            return "Transaction: Coinbase transaction contains invalid input";

        if (tx.payload.data.length != 0)
            return "Transaction: Coinbase transactions can't include payload";
    }
    else
        return "Transaction: Invalid transaction type";

    Amount new_unspent;
    if (!tx.getSumOutput(new_unspent))
        return "Transaction: Referenced Output(s) overflow";
    if (tx.type != TxType.Coinbase && !sum_unspent.sub(new_unspent))
        return "Transaction: Output(s) are higher than Input(s)";
    // NOTE: Make sure fees are always checked last
    return checkFee(tx, sum_unspent);
}

/// Ditto but returns a bool, only used in unittests
version (unittest)
public bool isValid (in Transaction tx, scope UTXOFinder findUTXO,
    in Height height,
    scope string delegate (in Transaction, Amount) @safe nothrow checkFee)
    @safe nothrow
{
    return isInvalidReason(tx, findUTXO, height, checkFee) is null;
}

/// verify transaction data
unittest
{
    import std.format;

    scope storage = new TestUTXOSet;
    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random];

    scope payload_checker = new FeeManager();
    scope checker = &payload_checker.check;

    // Creates the first transaction.
    Transaction previousTx = { outputs: [ Output(Amount(100), key_pairs[0].address) ] };

    // Save
    Hash previousHash = hashFull(previousTx);
    storage.put(previousTx);

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

    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It is validated. (the sum of `Output` < the sum of `Input`)
    assert(secondTx.isValid(storage.getUTXOFinder(), Height(0), checker),
           format("Transaction data is not validated %s", secondTx));

    secondTx.outputs ~= Output(Amount(50), key_pairs[2].address);
    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It is validated. (the sum of `Output` == the sum of `Input`)
    assert(secondTx.isValid(storage.getUTXOFinder(), Height(0), checker),
           format("Transaction data is not validated %s", secondTx));

    secondTx.outputs ~= Output(Amount(50), key_pairs[3].address);
    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It isn't validated. (the sum of `Output` > the sum of `Input`)
    assert(!secondTx.isValid(storage.getUTXOFinder(), Height(0), checker),
           format("Transaction data is not validated %s", secondTx));
}

/// negative output amounts disallowed
unittest
{
    KeyPair[] key_pairs = [KeyPair.random(), KeyPair.random()];
    Transaction tx_1 = { outputs: [ Output(Amount(1000), key_pairs[0].address) ] };
    Hash tx_1_hash = hashFull(tx_1);

    scope payload_checker = new FeeManager();
    scope checker = &payload_checker.check;

    scope storage = new TestUTXOSet;
    storage.put(tx_1);

    // Creates the second transaction.
    Transaction tx_2 =
    {
        TxType.Payment,
        inputs  : [Input(tx_1_hash, 0)],
        // oops
        outputs : [Output(Amount.invalid(-400_000), key_pairs[1].address)]
    };

    tx_2.inputs[0].signature = key_pairs[0].secret.sign(hashFull(tx_2)[]);

    assert(!tx_2.isValid(storage.getUTXOFinder(), Height(0), checker));

    // Creates the third transaction.
    // Reject a transaction whose output value is zero
    Transaction tx_3 =
    {
        TxType.Payment,
        inputs  : [Input(tx_1_hash, 0)],
        outputs : [Output(Amount.invalid(0), key_pairs[1].address)]
    };

    tx_3.inputs[0].signature = key_pairs[0].secret.sign(hashFull(tx_3)[]);

    assert(!tx_3.isValid(storage.getUTXOFinder(), Height(0), checker));
}

/// This creates a new transaction and signs it as a publickey
/// of the previous transaction to create and validate the input.
unittest
{
    import std.format;

    scope storage = new TestUTXOSet;

    immutable(KeyPair)[] key_pairs;
    key_pairs ~= KeyPair.random();
    key_pairs ~= KeyPair.random();
    key_pairs ~= KeyPair.random();

    scope payload_checker = new FeeManager();
    scope checker = &payload_checker.check;

    // Create the first transaction.
    Transaction genesisTx = { outputs: [ Output(Amount(100_000), key_pairs[0].address) ] };
    Hash genesisHash = hashFull(genesisTx);
    storage.put(genesisTx);

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
    storage.put(tx1);

    assert(tx1.isValid(storage.getUTXOFinder(), Height(0), checker),
           format("Transaction signature is not validated %s", tx1));

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
    storage.put(tx2);
    // Signature verification must be error
    assert(!tx2.isValid(storage.getUTXOFinder(), Height(0), checker),
           format("Transaction signature is not validated %s", tx2));
}

/// verify transactions associated with freezing
unittest
{
    scope storage = new TestUTXOSet();
    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random];

    scope payload_checker = new FeeManager();
    scope checker = &payload_checker.check;

    Transaction secondTx;
    Hash previousHash;

    // When the privious transaction type is `Payment`, second transaction type is `Freeze`.
    // Second transaction is valid.
    {
        storage.clear;
        // Create the previous transaction with type `TxType.Payment`
        Transaction previousTx =
            { outputs: [ Output(Amount.MinFreezeAmount, key_pairs[0].address) ] };
        previousHash = hashFull(previousTx);
        foreach (idx, output; previousTx.outputs)
        {
            const Hash utxo_hash = hashMulti(previousHash, idx);
            const UTXO utxo_value = {
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
        assert(secondTx.isValid(storage.getUTXOFinder(), Height(0), checker));
    }

    // When the privious transaction type is `Freeze`, second transaction type is `Freeze`.
    // Second transaction is invalid.
    {
        storage.clear;
        // Create the previous transaction with type `TxType.Payment`
        Transaction previousTx = { outputs: [ Output(Amount.MinFreezeAmount, key_pairs[0].address) ] };
        previousHash = hashFull(previousTx);
        foreach (idx, output; previousTx.outputs)
        {
            const Hash utxo_hash = hashMulti(previousHash, idx);
            const UTXO utxo_value = {
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
        assert(!secondTx.isValid(storage.getUTXOFinder(), Height(0), checker));
    }

    // When the privious transaction with not enough amount at freezing.
    // Second transaction is invalid.
    {
        storage.clear;
        // Create the previous transaction with type `TxType.Payment`
        Transaction previousTx = { outputs: [ Output(Amount(100_000_000_000L), key_pairs[0].address) ] };
        previousHash = hashFull(previousTx);
        foreach (idx, output; previousTx.outputs)
        {
            const Hash utxo_hash = hashMulti(previousHash, idx);
            const UTXO utxo_value = {
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
        assert(!secondTx.isValid(storage.getUTXOFinder(), Height(0), checker));
    }

    // When the privious transaction with too many amount at freezings.
    // Second transaction is valid.
    {
        // Create the previous transaction with type `TxType.Payment`
        Transaction previousTx = { outputs: [ Output(Amount(500_000_000_000L), key_pairs[0].address) ] };
        previousHash = hashFull(previousTx);
        foreach (idx, output; previousTx.outputs)
        {
            const Hash utxo_hash = hashMulti(previousHash, idx);
            const UTXO utxo_value = {
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
        assert(secondTx.isValid(storage.getUTXOFinder(), Height(0), checker));
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
    scope storage = new TestUTXOSet;
    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random];

    scope payload_checker = new FeeManager();
    scope checker = &payload_checker.check;

    Height block_height;

    Transaction secondTx;
    Transaction thirdTx;
    Transaction fourthTx;
    Transaction fifthTx;

    Hash previousHash;
    Hash secondHash;
    Hash thirdHash;
    Hash fifthHash;

    // Create the previous transaction with type `TxType.Payment`
    // Expected height : 0
    // Expected Status : melted
    {
        block_height = 0;
        Transaction previousTx =
            { outputs: [ Output(Amount.MinFreezeAmount, key_pairs[0].address) ] };

        // Save to UTXOSet
        previousHash = hashFull(previousTx);
        foreach (idx, output; previousTx.outputs)
        {
            const Hash utxo_hash = hashMulti(previousHash, idx);
            const UTXO utxo_value = {
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
        assert(secondTx.isValid(storage.getUTXOFinder(), block_height, checker));

        // Save to UTXOSet
        secondHash = hashFull(secondTx);
        foreach (idx, output; secondTx.outputs)
        {
            const Hash utxo_hash = hashMulti(secondHash, idx);
            const UTXO utxo_value = {
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
        assert(thirdTx.isValid(storage.getUTXOFinder(), block_height, checker));

        // Save to UTXOSet
        thirdHash = hashFull(thirdTx);
        foreach (idx, output; thirdTx.outputs)
        {
            const Hash utxo_hash = hashMulti(thirdHash, idx);
            const UTXO utxo_value = {
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
        assert(!fourthTx.isValid(storage.getUTXOFinder(), block_height, checker));
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
        assert(fifthTx.isValid(storage.getUTXOFinder(), block_height, checker));

        // Save to UTXOSet
        fifthHash = hashFull(fifthTx);
        foreach (idx, output; fifthTx.outputs)
        {
            const Hash utxo_hash = hashMulti(fifthHash, idx);
            const UTXO utxo_value = {
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

    scope storage = new TestUTXOSet;
    KeyPair key_pair = KeyPair.random;

    scope payload_checker = new FeeManager();
    scope checker = &payload_checker.check;

    // create a transaction having no input
    Transaction oneTx = Transaction(
        TxType.Payment,
        [],
        [Output(Amount(50), key_pair.address)]
    );
    storage.put(oneTx);

    // test for Payment transaction having no input
    assert(canFind(toLower(oneTx.isInvalidReason(storage.getUTXOFinder(), Height(0), checker)), "no input"),
        format("Tx having no input should not pass validation. tx: %s", oneTx));

    // create a transaction
    Transaction firstTx = { outputs: [ Output(Amount(100_1000), key_pair.address) ] };
    Hash firstHash = hashFull(firstTx);
    storage.put(firstTx);

    // create a transaction having no output
    Transaction secondTx = Transaction(
        TxType.Payment,
        [Input(firstHash, 0)],
        []
    );
    storage.put(secondTx);

    // test for Freeze transaction having no output
    assert(canFind(toLower(secondTx.isInvalidReason(storage.getUTXOFinder(), Height(0), checker)), "no output"),
        format("Tx having no output should not pass validation. tx: %s", secondTx));
}

/// test for transaction having combined inputs
unittest
{
    import std.format;
    scope storage = new TestUTXOSet;
    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random];

    scope payload_checker = new FeeManager();
    scope checker = &payload_checker.check;

    // create the first transaction.
    Transaction firstTx = Transaction(
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output(Amount(100), key_pairs[0].address)]
    );
    Hash firstHash = hashFull(firstTx);
    storage.put(firstTx);

    // create the second transaction.
    Transaction secondTx = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount(100), key_pairs[0].address)]
    );
    Hash secondHash = hashFull(secondTx);
    storage.put(secondTx);

    // create the third transaction
    Transaction thirdTx = Transaction(
        TxType.Payment,
        [Input(firstHash, 0), Input(secondHash, 0)],
        [Output(Amount(100), key_pairs[1].address)]
    );
    Hash thirdHash = hashFull(thirdTx);
    storage.put(thirdTx);
    thirdTx.inputs[0].signature = key_pairs[0].secret.sign(thirdHash[]);
    thirdTx.inputs[1].signature = key_pairs[0].secret.sign(thirdHash[]);

    // test for transaction having combined inputs
    assert(!thirdTx.isValid(storage.getUTXOFinder(), Height(0), checker),
        format("Tx having combined inputs should not pass validation. tx: %s", thirdTx));
}

/// test for unknown transaction type
unittest
{
    import std.format;
    Transaction[Hash] storage;
    TxType unknown_type = cast(TxType)100; // any number is OK for test except 0 and 1
    KeyPair key_pair = KeyPair.random;

    scope payload_checker = new FeeManager();
    scope checker = &payload_checker.check;

    // create a transaction having unknown transaction type
    Transaction firstTx = Transaction(
        unknown_type,
        [Input(Hash.init, 0)],
        [Output(Amount(100), key_pair.address)]
    );
    Hash firstHash = hashFull(firstTx);
    storage[firstHash] = firstTx;

    // test for unknown transaction type
    assert(!firstTx.isValid(null, Height(0), checker),
        format("Tx having unknown type should not pass validation. tx: %s", firstTx));
}

/// test for checking input overflow for Payment and Freeze type transactions
unittest
{
    import std.format;
    scope storage = new TestUTXOSet();
    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random];

    scope payload_checker = new FeeManager();
    scope checker = &payload_checker.check;

    // create the first transaction
    auto firstTx = Transaction(
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output(Amount.MaxUnitSupply, key_pairs[0].address)]
    );
    storage.put(firstTx);
    const firstHash = UTXO.getHash(firstTx.hashFull(), 0);

    // create the second transaction
    auto secondTx = Transaction(
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output(Amount(100), key_pairs[0].address)]
    );
    storage.put(secondTx);
    const secondHash = UTXO.getHash(secondTx.hashFull(), 0);

    // create the third transaction
    auto thirdTx = Transaction(
        TxType.Payment,
        [Input(firstHash, 0), Input(secondHash, 0)],
        [Output(Amount(100), key_pairs[1].address)]
    );
    storage.put(thirdTx);
    auto thirdHash = hashFull(thirdTx);
    thirdTx.inputs[0].signature = key_pairs[0].secret.sign(thirdHash[]);
    thirdTx.inputs[1].signature = key_pairs[0].secret.sign(thirdHash[]);

    // test for input overflow in Payment transaction
    assert(!thirdTx.isValid(&storage.peekUTXO, Height(0), checker),
        format("Tx having input overflow should not pass validation. tx: %s", thirdTx));

    // create the fourth transaction
    auto fourthTx = Transaction(
        TxType.Freeze,
        [Input(firstHash, 0), Input(secondHash, 0)],
        [Output(Amount(100), key_pairs[1].address)]
    );
    storage.put(fourthTx);
    auto fourthHash = hashFull(fourthTx);
    fourthTx.inputs[0].signature = key_pairs[0].secret.sign(fourthHash[]);
    fourthTx.inputs[1].signature = key_pairs[0].secret.sign(fourthHash[]);

    // test for input overflow in Freeze transaction
    assert(!fourthTx.isValid(&storage.peekUTXO, Height(0), checker),
        format("Tx having input overflow should not pass validation. tx: %s", fourthTx));
}

/// test for checking output overflow for Payment type transaction
unittest
{
    import std.format;
    scope storage = new TestUTXOSet();
    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random];

    scope payload_checker = new FeeManager();
    scope checker = &payload_checker.check;

    // create the first transaction
    auto firstTx = Transaction(
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output(Amount(100), key_pairs[0].address)]
    );
    storage.put(firstTx);
    const firstHash = UTXO.getHash(firstTx.hashFull(), 0);

    // create the second transaction
    auto secondTx = Transaction(
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output(Amount(100), key_pairs[0].address)]
    );
    storage.put(secondTx);
    const secondHash = UTXO.getHash(secondTx.hashFull(), 0);

    // create the third transaction
    auto thirdTx = Transaction(
        TxType.Payment,
        [Input(firstHash, 0), Input(secondHash, 0)],
        [Output(Amount.MaxUnitSupply, key_pairs[1].address),
            Output(Amount(100), key_pairs[1].address)]
    );
    storage.put(thirdTx);
    auto thirdHash = hashFull(thirdTx);
    thirdTx.inputs[0].signature = key_pairs[0].secret.sign(thirdHash[]);
    thirdTx.inputs[1].signature = key_pairs[0].secret.sign(thirdHash[]);

    // test for output overflow in Payment transaction
    assert(!thirdTx.isValid(&storage.peekUTXO, Height(0), checker),
        format("Tx having output overflow should not pass validation. tx: %s", thirdTx));
}

/// test for transaction to store data
unittest
{
    import std.format;
    scope storage = new TestUTXOSet;
    KeyPair key_pair = KeyPair.random;

    scope payload_checker = new FeeManager();
    scope checker = &payload_checker.check;

    // create the payment transaction.
    Transaction paymentTx = Transaction(
        TxType.Payment,
        [Input(Hash.init)],
        [Output(Amount(80_000L * 10_000_000L), key_pair.address)]
    );
    storage.put(paymentTx);
    Hash payment_utxo = UTXO.getHash(paymentTx.hashFull(), 0);

    // create the frozen transaction.
    Transaction frozenTx = Transaction(
        TxType.Freeze,
        [Input(Hash.init)],
        [Output(Amount(80_000L * 10_000_000L), key_pair.address)]
    );
    storage.put(frozenTx);
    Hash frozen_utxo = UTXO.getHash(frozenTx.hashFull(), 0);

    // create data with nomal size
    ubyte[] normal_data;
    normal_data.length = payload_checker.params.TxPayloadMaxSize;
    foreach (idx; 0 .. normal_data.length)
        normal_data[idx] = cast(ubyte)(idx % 256);

    // create data with large size
    ubyte[] large_data;
    large_data ~= normal_data;
    large_data ~= cast(ubyte)(0);

    // calculate fee
    Amount normal_data_fee = calculateDataFee(normal_data.length,
        payload_checker.params.TxPayloadFeeFactor);
    Amount large_data_fee = calculateDataFee(large_data.length,
        payload_checker.params.TxPayloadFeeFactor);

    Transaction dataTx;
    Hash dataHash;


    // Test 1. Too large data
    // create a transaction with large data
    dataTx = Transaction(
        TxType.Payment,
        [Input(payment_utxo)],
        [
            Output(large_data_fee, payload_checker.params.CommonsBudgetAddress),
            Output(Amount(40_000L * 10_000_000L), key_pair.address)
        ],
        DataPayload(large_data)
    );
    dataHash = hashFull(dataTx);
    dataTx.inputs[0].signature = key_pair.secret.sign(dataHash[]);

    // test for the transaction with large data
    assert(!dataTx.isValid(&storage.peekUTXO, Height(0), checker),
        format("When storing data, tx with large data payload should not pass validation. tx: %s", dataTx));


    // Test 2. With not enough fee
    // create a transaction with not enough fee
    dataTx = Transaction(
        TxType.Payment,
        [Input(payment_utxo)],
        [Output(Amount(80_000L * 10_000_000L - normal_data_fee.integral + 1),
            key_pair.address)],
        DataPayload(normal_data)
    );
    dataHash = hashFull(dataTx);
    dataTx.inputs[0].signature = key_pair.secret.sign(dataHash[]);

    // test for transaction without commons budget
    assert(!dataTx.isValid(&storage.peekUTXO, Height(0), checker),
        format("When storing data, tx with not enough fee should not pass validation. tx: %s", dataTx));

    // Test 3. Nomal
    // create a transaction with enough fee
    Amount rem_amount = paymentTx.outputs[0].value;
    rem_amount.sub(normal_data_fee);
    dataTx = Transaction(
        TxType.Payment,
        [Input(payment_utxo)],
        [Output(rem_amount, key_pair.address)],
        DataPayload(normal_data)
    );
    dataHash = hashFull(dataTx);
    dataTx.inputs[0].signature = key_pair.secret.sign(dataHash[]);

    // test for the transaction with enough fee
    assert(dataTx.isValid(&storage.peekUTXO, Height(0), checker),
        format("When storing data, Transaction data is not validated. tx: %s", dataTx));


    // Test 5. Using frozen input
    // create the data transaction.
    dataTx = Transaction(
        TxType.Payment,
        [Input(frozen_utxo)],
        [
            Output(Amount(40_000L * 10_000_000L), key_pair.address)
        ],
        DataPayload(normal_data)
    );
    dataHash = hashFull(dataTx);
    dataTx.inputs[0].signature = key_pair.secret.sign(dataHash[]);

    // test for data storage using frozen input
    assert(dataTx.isValid(&storage.peekUTXO, Height(0), checker),
        format("When storing data, tx with frozen input should pass validation. tx: %s", dataTx));


    // Test 6. The transaction with the type of Freeze
    // create the data transaction.
    dataTx = Transaction(
        TxType.Freeze,
        [Input(payment_utxo)],
        [
            Output(Amount(40_000L * 10_000_000L), key_pair.address)
        ],
        DataPayload(normal_data)
    );
    dataHash = hashFull(dataTx);
    dataTx.inputs[0].signature = key_pair.secret.sign(dataHash[]);

    // test for data storage using frozen input
    assert(!dataTx.isValid(&storage.peekUTXO, Height(0), checker),
        format("When storing data, tx with type of Freeze should not pass validation. tx: %s", dataTx));
}

unittest
{
    scope storage = new TestUTXOSet;
    scope utxoFinder = storage.getUTXOFinder();

    const key_pair = KeyPair.random;

    scope payload_checker = new FeeManager();
    scope checker = &payload_checker.check;

    // Only output transaction
    auto tx = Transaction(
        TxType.Coinbase,
        [],
        [
            Output(Amount(2826), key_pair.address),
            Output(Amount(3895), key_pair.address),
        ],
    );

    // No input
    assert(!isValid(tx, utxoFinder, Height(0), checker));

    // Add the expected input, should validate
    tx.inputs ~= Input(Height(0));
    assert(isValid(tx, utxoFinder, Height(0), checker));

    // Add some data, should not validate
    ubyte[] data = [0xDE, 0xAD, 0xBE, 0xEF];
    tx.payload = DataPayload(data);
    assert(!isValid(tx, utxoFinder, Height(0), checker));

    // Remove the inputs, still should not validate
    tx.inputs.length = 0;
    assert(!isValid(tx, utxoFinder, Height(0), checker));
}

/// transaction-level absolute time lock
unittest
{
    import ocean.core.Test;
    scope storage = new TestUTXOSet;
    scope payload_checker = new FeeManager();
    scope checker = &payload_checker.check;

    KeyPair kp = KeyPair.random();

    Transaction prev_tx = { outputs: [Output(Amount(100), kp.address)] };
    storage.put(prev_tx);

    Transaction tx = Transaction(
        TxType.Payment, [Input(hashFull(prev_tx), 0)],
        [Output(Amount(50), kp.address)]);

    // effectively disabled lock
    tx.lock_height = Height(0);
    tx.inputs[0].signature = kp.secret.sign(hashFull(tx)[]);
    test!"=="(tx.isInvalidReason(storage.getUTXOFinder(), Height(0), checker), null);
    test!"=="(tx.isInvalidReason(storage.getUTXOFinder(), Height(1024), checker), null);

    tx.lock_height = Height(10);
    tx.inputs[0].signature = kp.secret.sign(hashFull(tx)[]);
    test!"=="(tx.isInvalidReason(storage.getUTXOFinder(), Height(0), checker),
        "Transaction: Not unlocked for this height");
    test!"=="(tx.isInvalidReason(storage.getUTXOFinder(), Height(9), checker),
        "Transaction: Not unlocked for this height");
    test!"=="(tx.isInvalidReason(storage.getUTXOFinder(), Height(10), checker),
        null);
    test!"=="(tx.isInvalidReason(storage.getUTXOFinder(), Height(1024), checker),
        null);
}
