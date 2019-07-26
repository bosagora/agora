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

import agora.common.crypto.Key;
import agora.common.Data;
import agora.common.Hash;
import agora.common.Serializer;

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


    /***************************************************************************

        Transactions Serialization

        Params:
            dg = Serialize function

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) pure const nothrow @safe
    {
        serializePart(this.inputs.length, dg);
        foreach (const ref input; this.inputs)
            serializePart(input, dg);

        serializePart(this.outputs.length, dg);
        foreach (const ref output; this.outputs)
            serializePart(output, dg);
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

    /***************************************************************************

        Output Serialization

        Params:
            dg = Serialize function

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) pure const nothrow @safe
    {
        serializePart(this.value, dg);
        serializePart(this.address, dg);
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

    /***************************************************************************

        Input Serialization

        Params:
             dg = serialize function

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) pure const nothrow @safe
    {
        serializePart(this.previous, dg);
        serializePart(this.index, dg);
        serializePart(this.signature, dg);
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

    Create a set of chained transactions, where each transaction spends the
    entire sum of the previous transaction.

    Useful for quickly generating transactions for use with unittests.

    Params:
        root = the first transaction in the chain will spend the output of
               this transaction
        count = the number of transactions to create
        key_pair = the key pair used to sign transactions and to send
                   the output to

*******************************************************************************/

version (unittest)
public Transaction[] getChainedTransactions (Transaction root, size_t count, KeyPair key_pair, size_t period = 1)
{
    Transaction[] transactions;
    Hash last_tx_hash;

    if (period > 1)
    {
        foreach (idx; 0 .. count)
        {
            if (idx < period)
                last_tx_hash = hashFull(root);
            else
                last_tx_hash = hashFull(transactions[idx-period]);

            Transaction tx =
            {
                [Input(last_tx_hash, 0)],
                [Output((idx%period + 1)*100, key_pair.address)]  // send to the same address
            };

            auto signature = key_pair.secret.sign(hashFull(tx)[]);
            tx.inputs[0].signature = signature;
            transactions ~= tx;
        }
    }
    else
    {
        last_tx_hash = hashFull(root);
        foreach (idx; 0 .. count)
        {
            Transaction tx =
            {
                [Input(last_tx_hash, 0)],
                [Output(40_000_000, key_pair.address)]  // send to the same address
            };

            auto signature = key_pair.secret.sign(hashFull(tx)[]);
            tx.inputs[0].signature = signature;
            last_tx_hash = hashFull(tx);
            transactions ~= tx;
        }
    }
    return transactions;
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
    scope Output* delegate (Hash hash, size_t index) @safe findOutput) @safe
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

    Get result of transaction data and signature verification

    Params:
        tx = `Transaction`
        findOutput = delegate for finding `Output`

    Return:
        Return true if this transaction is verified.

*******************************************************************************/

public bool verify (Transaction tx,
    scope Output* delegate (Hash hash, size_t index) @safe findOutput) @safe
{
    if (tx.inputs.length == 0)
        return false;

    if (tx.outputs.length == 0)
        return false;

    // disallow negative amounts
    foreach (output; tx.outputs)
        if (output.value < 0)
            return false;

    long sum_unspent;

    const tx_hash = hashFull(tx);
    foreach (input; tx.inputs)
    {
        // all referenced outputs must be present
        auto output = findOutput(input.previous, input.index);
        if (output is null)
            return false;

        if (!output.address.verify(input.signature, tx_hash[]))
            return false;

        sum_unspent += output.value;
    }

    return tx.getSumOutput() <= sum_unspent;
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
    scope findOutput = (Hash hash, size_t index)
    {
        if (auto tx = hash in storage)
            if (index < tx.outputs.length)
                return &tx.outputs[index];

            return null;
    };

    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It is validated. (the sum of `Output` < the sum of `Input`)
    assert(secondTx.verify(findOutput), format("Transaction data is not validated %s", secondTx));

    secondTx.outputs ~= Output(50, key_pairs[2].address);
    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It is validated. (the sum of `Output` == the sum of `Input`)
    assert(secondTx.verify(findOutput), format("Transaction data is not validated %s", secondTx));

    secondTx.outputs ~= Output(50, key_pairs[3].address);
    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It isn't validated. (the sum of `Output` > the sum of `Input`)
    assert(!secondTx.verify(findOutput), format("Transaction data is not validated %s", secondTx));
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
    scope findOutput = (Hash hash, size_t index)
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

    tx_2.inputs[0].signature = key_pairs[0].secret.sign(hashFull(tx_2)[]);

    assert(!tx_2.verify(findOutput));
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
    scope findOutput = (Hash hash, size_t index)
    {
        if (auto tx = hash in storage)
            if (index < tx.outputs.length)
                return &tx.outputs[index];

            return null;
    };

    // Create the first transaction.
    Transaction genesisTx = newCoinbaseTX(key_pairs[0].address, 100_000);
    Hash genesisHash = hashFull(genesisTx);
    storage[genesisHash] = genesisTx;
    genesisTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(genesisTx)[]);

    // Create the second transaction.
    Transaction tx1 = Transaction(
        [
            Input(genesisHash, 0)
        ],
        [
            Output(1_000, key_pairs[1].address)
        ]
    );

    // Signs the previous hash value.
    Hash tx1Hash = hashFull(tx1);
    tx1.inputs[0].signature = key_pairs[0].secret.sign(tx1Hash[]);
    storage[tx1Hash] = tx1;

    assert(tx1.verify(findOutput), format("Transaction signature is not validated %s", tx1));

    Transaction tx2 = Transaction(
        [
            Input(tx1Hash, 0)
        ],
        [
            Output(1_000, key_pairs[1].address)
        ]
    );

    Hash tx2Hash = hashFull(tx2);
    // Sign with incorrect key
    tx2.inputs[0].signature = key_pairs[2].secret.sign(tx2Hash[]);
    storage[tx2Hash] = tx2;
    // Signature verification must be error
    assert(!tx2.verify(findOutput), format("Transaction signature is not validated %s", tx2));
}
