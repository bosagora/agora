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

module agora.consensus.data.Transaction;

import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Data;
import agora.common.Deserializer;
import agora.common.Hash;
import agora.common.Serializer;
import agora.consensus.Genesis;

import std.algorithm;


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

    public void serialize (scope SerializeDg dg) const nothrow @safe
    {
        serializePart(this.inputs.length, dg);
        foreach (const ref input; this.inputs)
            serializePart(input, dg);

        serializePart(this.outputs.length, dg);
        foreach (const ref output; this.outputs)
            serializePart(output, dg);
    }

    /***************************************************************************

        Transactions deserialization

        Params:
            dg = Deserialize function

    ***************************************************************************/

    public void deserialize (scope DeserializeDg dg) nothrow @safe
    {
        size_t input_size;
        deserializePart(input_size, dg);
        this.inputs.length = input_size;

        // deserialize and generate inputs
        foreach (ref input; this.inputs)
            deserializePart(input , dg);

        size_t output_size;
        deserializePart(output_size, dg);
        this.outputs.length = output_size;

        // deserialize and generate outputs
        foreach (ref output; this.outputs)
            deserializePart(output, dg);
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

    public void serialize (scope SerializeDg dg) const nothrow @safe
    {
        serializePart(this.value, dg);
        serializePart(this.address, dg);
    }

    /***************************************************************************

        Output Deserialization

        Params:
            dg = deserialize function

    ***************************************************************************/

    public void deserialize (scope DeserializeDg dg) nothrow @safe
    {
        deserializePart(this.value, dg);
        this.address = PublicKey.fromBinary(dg);
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

    public void serialize (scope SerializeDg dg) const nothrow @safe
    {
        serializePart(this.previous, dg);
        serializePart(this.index, dg);
        serializePart(this.signature, dg);
    }

    /***************************************************************************

        Input deserialization

        Params:
             dg = deserialize function

    ***************************************************************************/

    public void deserialize (scope DeserializeDg dg) nothrow @safe
    {
        this.previous = Hash(dg(Hash.sizeof));
        deserializePart(this.index, dg);
        this.signature = Hash(dg(Hash.sizeof));
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

public Transaction newCoinbaseTX (PublicKey address, Amount value = Amount(0))
{
    return Transaction(
        [Input(Hash.init, 0)],
        [Output(value, address)]
    );
}

/*******************************************************************************

    Create a set of transactions, where each newly created transaction
    spends the entire sum of each provided transaction's output as
    set in the parameters.

    If prev_txs is null, the first set of transactions that fill a block will
    spend the genesis transaction's outputs.

    Params:
        prev_txs = the previous transactions to refer to
        key_pair = the key pair used to sign transactions and to send
                   the output to
        block_count = the number of blocks that will be created if the
                      returned transactions are added to the ledger

*******************************************************************************/

version (unittest)
public Transaction[] makeChainedTransactions (KeyPair key_pair,
    Transaction[] prev_txs, size_t block_count)
{
    import agora.common.Block;
    import std.conv;

    assert(prev_txs.length == 0 || prev_txs.length == Block.TxsInBlock);
    const TxCount = block_count * Block.TxsInBlock;

    // in unittests we use the following blockchain layout:
    //
    // genesis => 8 outputs
    // txs[0] => spend gen_tx.outputs[0]
    // txs[1] => spend gen_tx.outputs[1]...
    // ..
    // tx[9] => spend tx[0].outputs[0]
    // tx[10] => spend tx[1].outputs[0]
    // ..
    // tx[17] => spend tx[9].outputs[0]
    // tx[18] => spend tx[10].outputs[0]
    // ..
    // therefore the genesis block and the 1st block are unique here,
    // as the 1st block spends all the genesis outputs via separate
    // transactions, and subsequent blocks have transactions which
    // spend the only outputs in the transaction from the previous block

    Transaction[] transactions;

    // always use the same amount, for simplicity
    const Amount AmountPerTx = 40_000_000 / Block.TxsInBlock;

    foreach (idx; 0 .. TxCount)
    {
        Input input;
        if (prev_txs.length == 0)  // refering to genesis tx's outputs
            input = Input(hashFull(getGenesisTx()), idx.to!uint);
        else  // refering to tx's in the previous block
            input = Input(hashFull(prev_txs[idx % Block.TxsInBlock]), 0);

        Transaction tx =
        {
            [input],
            [Output(AmountPerTx, key_pair.address)]  // send to the same address
        };

        auto signature = key_pair.secret.sign(hashFull(tx)[]);
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

///
unittest
{
    import agora.common.Block;
    import std.format;
    auto gen_key = getGenesisKeyPair();
    auto gen_block = getGenesisBlock();

    /// should spend genesis block's outputs
    auto txes = makeChainedTransactions(gen_key, null, 1);
    foreach (idx; 0 .. Block.TxsInBlock)
    {
        assert(txes[idx].inputs.length == 1);
        assert(txes[idx].inputs[0].index == idx);
        assert(txes[idx].inputs[0].previous == hashFull(gen_block.txs[0]));
    }

    auto prev_txs = txes;
    // should spend the previous tx'es outputs
    txes = makeChainedTransactions(gen_key, txes, 1);

    foreach (idx; 0 .. Block.TxsInBlock)
    {
        assert(txes[idx].inputs.length == 1);
        assert(txes[idx].inputs[0].index == 0);  // always refers to only output in tx
        assert(txes[idx].inputs[0].previous == hashFull(prev_txs[idx]));
    }
}

/*******************************************************************************

    Get sum of `Output`

    Params:
        tx = `Transaction`
        acc = Accumulator value. Pass a default-initialized value to get this
              transaction's sum of output.

    Return:
        `true` if the sum returned is correct. `false` if there was an overflow.

*******************************************************************************/

public bool getSumOutput (Transaction tx, ref Amount acc) nothrow pure @safe @nogc
{
    foreach (ref o; tx.outputs)
        if (!acc.add(o.value))
            return false;
    return true;
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
    scope const(Output)* delegate (Hash hash, size_t index) @safe findOutput) @safe
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
        auto output = findOutput(input.previous, input.index);
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

    secondTx.outputs ~= Output(Amount(50), key_pairs[2].address);
    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It is validated. (the sum of `Output` == the sum of `Input`)
    assert(secondTx.verify(findOutput), format("Transaction data is not validated %s", secondTx));

    secondTx.outputs ~= Output(Amount(50), key_pairs[3].address);
    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It isn't validated. (the sum of `Output` > the sum of `Input`)
    assert(!secondTx.verify(findOutput), format("Transaction data is not validated %s", secondTx));
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
        // oops
        outputs : [Output(Amount.invalid(-400_000), key_pairs[1].address)]
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

    assert(tx1.verify(findOutput), format("Transaction signature is not validated %s", tx1));

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
    assert(!tx2.verify(findOutput), format("Transaction signature is not validated %s", tx2));
}
