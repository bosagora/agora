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
import agora.common.crypto.Key;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;

/// Delegate to find an unspent UTXO
public alias UTXOFinder = scope const(Output)* delegate (Hash hash, size_t index)
    @safe nothrow;

/*******************************************************************************

    Get result of transaction data and signature verification

    Params:
        tx = `Transaction`
        findUTXO = delegate for finding `Output`

    Return:
        Return true if this transaction is verified.

*******************************************************************************/

public bool isValid (const Transaction tx, UTXOFinder findUTXO)
    @safe nothrow
{
    if (tx.inputs.length == 0)
        return false;

    if (tx.outputs.length == 0)
        return false;

    // disallow negative amounts
    foreach (output; tx.outputs)
        if (!output.value.isValid())
            return false;

    Amount sum_unspent;

    const tx_hash = hashFull(tx);
    foreach (input; tx.inputs)
    {
        // all referenced outputs must be present
        auto output = findUTXO(input.previous, input.index);
        if (output is null)
            return false;

        if (!output.address.verify(input.signature, tx_hash[]))
            return false;

        if (!sum_unspent.add(output.value))
            return false;
    }

    Amount new_unspent;
    return tx.getSumOutput(new_unspent) && sum_unspent.sub(new_unspent);
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
        [
            Input(previousHash, 0)
        ],
        [
            Output(Amount(50), key_pairs[1].address)
        ]
    );

    // delegate for finding `Output`
    scope findUTXO = (Hash hash, size_t index)
    {
        if (auto tx = hash in storage)
            if (index < tx.outputs.length)
                return &tx.outputs[index];

            return null;
    };

    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It is validated. (the sum of `Output` < the sum of `Input`)
    assert(secondTx.isValid(findUTXO), format("Transaction data is not validated %s", secondTx));

    secondTx.outputs ~= Output(Amount(50), key_pairs[2].address);
    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It is validated. (the sum of `Output` == the sum of `Input`)
    assert(secondTx.isValid(findUTXO), format("Transaction data is not validated %s", secondTx));

    secondTx.outputs ~= Output(Amount(50), key_pairs[3].address);
    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It isn't validated. (the sum of `Output` > the sum of `Input`)
    assert(!secondTx.isValid(findUTXO), format("Transaction data is not validated %s", secondTx));
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
    scope findUTXO = (Hash hash, size_t index)
    {
        if (auto tx = hash in storage)
            if (index < tx.outputs.length)
                return &tx.outputs[index];
        return null;
    };

    // Creates the second transaction.
    Transaction tx_2 =
    {
        inputs  : [Input(tx_1_hash, 0)],
        // oops
        outputs : [Output(Amount.invalid(-400_000), key_pairs[1].address)]
    };

    tx_2.inputs[0].signature = key_pairs[0].secret.sign(hashFull(tx_2)[]);

    assert(!tx_2.isValid(findUTXO));
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
    scope findUTXO = (Hash hash, size_t index)
    {
        if (auto tx = hash in storage)
            if (index < tx.outputs.length)
                return &tx.outputs[index];

            return null;
    };

    // Create the first transaction.
    Transaction genesisTx = newCoinbaseTX(key_pairs[0].address, Amount(100_000));
    Hash genesisHash = hashFull(genesisTx);
    storage[genesisHash] = genesisTx;
    genesisTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(genesisTx)[]);

    // Create the second transaction.
    Transaction tx1 = Transaction(
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

    assert(tx1.isValid(findUTXO), format("Transaction signature is not validated %s", tx1));

    Transaction tx2 = Transaction(
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
    assert(!tx2.isValid(findUTXO), format("Transaction signature is not validated %s", tx2));
}

/*******************************************************************************

    Check the validity of a block.

    Currently only the height of the block is
    checked against the previous height.

    Params:
        block = the block to check
        prev_height = the height of the previous block which this
                      block should point to

    Returns:
        true if the block is considered valid

*******************************************************************************/

public bool isValid (const ref Block block, in ulong prev_height)
    pure nothrow @safe @nogc
{
    if (block.header.height != prev_height + 1)
        return false;

    return true;
}

///
unittest
{
    import agora.consensus.Genesis;
    auto gen_block = getGenesisBlock();
    Block block;
    block.header.prev_block = gen_block.header.hashFull();
    block.header.height = gen_block.header.height + 1;
    assert(block.isValid(gen_block.header.height));

    block.header.height = 100;
    assert(!block.isValid(gen_block.header.height));
}
