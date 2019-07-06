/*******************************************************************************

    Defines the data structure of a transaction

    The current design is heavily influenced by Bitcoin: as we have a UTXO,
    starting with a simple input/output approach seems to make the most sense.
    Script is not implemented: instead, we currently only have a simple signature
    verification step.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Transaction;

import agora.common.Data;
import agora.common.Hash;
import agora.common.crypto.Key;

import std.algorithm;


/*******************************************************************************

    Currency amount type to use

    This is simply an alias to `long` at the moment, and should be made smarter.
    Currently this has two major drawbacks:
    - It does not do any overflow / underflow checks (over the total amount)
    - It can go negative
    We should probably wrap this in a smarter type to do currency operations,
    and move it to a shared location, as currency operations might be performed
    independently of `Transaction`.

*******************************************************************************/

public alias Amount = long;

/*******************************************************************************

    Represents a transaction (shortened as 'tx')

    Agora uses a UTXO model for transactions, so the transaction format is
    originally derived from that of Bitcoin.

*******************************************************************************/

public struct Transaction
{
    /// The list of unspent `outputs` from previous transaction(s) that will be spent
    public Input[] inputs;

    /// The list of newly created outputs to put in the UTXO
    public Output[] outputs;


    /***************************************************************************

        Implements hashing support

        Params:
            dg = hashing function

    ***************************************************************************/

    public void computeHash (scope HashDg dg) const nothrow @safe @nogc
    {
        foreach (input; this.inputs)
            hashPart(input, dg);

        foreach (output; this.outputs)
            hashPart(output, dg);
    }
}

///
nothrow @safe @nogc unittest
{
    Transaction tx;
    auto hash = hashFull(tx);
    auto exp_hash = Hash("0xcee29bfe1a706fd555b748145b683a904bb04e9344648913" ~
        "5358eeaf31105ed219541ff717e2868a614758e140472f9172d2522585fdc6c6035" ~
        "90142f7026a78");
    assert(hash == exp_hash);
}

/*******************************************************************************

    Represents an entry in the UTXO

    This is created by a valid `Transaction` and is added to the UTXO after
    a transaction is confirmed.

*******************************************************************************/

public struct Output
{
    /// The monetary value of this output, in 1/10^7
    public Amount value;

    /// The public key that can redeem this output (A = pubkey)
    /// Note that in Bitcoin, this is an address (the double hash of a pubkey)
    public PublicKey address;


    /***************************************************************************

        Implements hashing support

        Params:
            dg = hashing function

    ***************************************************************************/

    public void computeHash (scope HashDg dg) const nothrow @safe @nogc
    {
        hashPart(this.value, dg);
        hashPart(this.address, dg);
    }
}

/// The input of the transaction, which spends a previously received `Output`
public struct Input
{
    /// The hash of a previous transaction containing the `Output` to spend
    public Hash previous;

    /// Index of the `Output` in the `previous` `Transaction`
    public uint index;

    /// A signature that should be verified using the `previous[index].address` public key
    public Signature signature;


    /***************************************************************************

        Implements hashing support

        Params:
            dg = hashing function

    ***************************************************************************/

    public void computeHash (scope HashDg dg) const nothrow @safe @nogc
    {
        hashPart(this.previous, dg);
        hashPart(this.index, dg);
    }
}

/*******************************************************************************

    Checks whether the transaction is coinbase

    Params:
        tx = Type of `Transaction`

    Return:
        Return true if this transaction is a coinbase

*******************************************************************************/

public bool isCoinbaseTx (Transaction tx) nothrow pure @safe @nogc
{
    return tx.inputs.length == 1 && tx.inputs[0] == Input.init;
}

/*******************************************************************************

    Creates a new coinbase transaction

    Params:
        address = The public key that can redeem this output
        value = The initial value

    Return:
        Return coinbase transation

*******************************************************************************/

public Transaction newCoinbaseTX (PublicKey address, Amount value = 0)
{
    return Transaction(
        [Input(Hash.init, 0)],
        [Output(value, address)]
    );
}

/*******************************************************************************

    Get sum of `Input`

    Params:
        tx = `Transaction`
        findOutput = delegate for finding `Output`

    Return:
        Sum of `Input` in the `Transaction`

*******************************************************************************/

public Amount getSumInput (Transaction tx,
    Output* delegate (Hash hash, size_t index) @safe findOutput) @safe
{
    return tx.inputs
        .map!(a => findOutput(a.previous, a.index))
        .filter!(a => a !is null)
        .map!(a => a.value).sum();
}

/*******************************************************************************

    Get sum of `Output`

    Params:
        tx = `Transaction`

    Return:
        Sum of `Output` in the `Transaction`

*******************************************************************************/

public Amount getSumOutput (Transaction tx) nothrow pure @safe @nogc
{
    return tx.outputs.map!(a => a.value).sum();
}

/*******************************************************************************

    Get result of transaction data verification

    Params:
        tx = `Transaction`
        findOutput = delegate for finding `Output`

    Return:
        Return true if this transaction is verified.

*******************************************************************************/

public bool verifyData (Transaction tx,
    Output* delegate (Hash hash, size_t index) @safe findOutput) @safe
{
    if (tx.inputs.length == 0)
        return false;

    if (tx.outputs.length == 0)
        return false;

    // disallow negative amounts
    foreach (output; tx.outputs)
        if (output.value < 0)
            return false;

    return tx.getSumOutput() <= tx.getSumInput(findOutput);
}

/// verify transaction data
unittest
{
    import std.format;

    Transaction[Hash] storage;
    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random];

    // Creates the first transaction.
    Transaction previousTx = newCoinbaseTX(key_pairs[0].address, 100);

    // Save
    Hash previousHash = hashFull(previousTx);
    storage[previousHash] = previousTx;

    // Creates the second transaction.
    Transaction secondTx = Transaction(
        [
            Input(previousHash, 0)
        ],
        [
            Output(50, key_pairs[1].address)
        ]
    );

    // delegate for finding `Output`
    auto findOutput = (Hash hash, size_t index)
    {
        if (auto tx = hash in storage)
            if (index < tx.outputs.length)
                return &tx.outputs[index];

            return null;
    };

    // It is validated. (the sum of `Output` < the sum of `Input`)
    assert(secondTx.verifyData(findOutput), format("Transaction data is not validated %s", secondTx));

    secondTx.outputs ~= Output(50, key_pairs[2].address);

    // It is validated. (the sum of `Output` == the sum of `Input`)
    assert(secondTx.verifyData(findOutput), format("Transaction data is not validated %s", secondTx));

    secondTx.outputs ~= Output(50, key_pairs[3].address);

    // It isn't validated. (the sum of `Output` > the sum of `Input`)
    assert(!secondTx.verifyData(findOutput), format("Transaction data is not validated %s", secondTx));
}

/// negative output amounts disallowed
unittest
{
    KeyPair[] key_pairs = [KeyPair.random(), KeyPair.random()];
    Transaction tx_1 = newCoinbaseTX(key_pairs[0].address, 1000);
    Hash tx_1_hash = hashFull(tx_1);

    Transaction[Hash] storage;
    storage[tx_1_hash] = tx_1;

    // delegate for finding `Output`
    auto findOutput = (Hash hash, size_t index)
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
        outputs : [Output(-400_000, key_pairs[1].address)]  // oops
    };

    assert(!tx_2.verifyData(findOutput));
}
