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

/// The Agora Transaction Type constans
public enum TxType : ubyte
{
    Payment,
    Freeze
}

/*******************************************************************************

    Represents a transaction (shortened as 'tx')

    Agora uses a UTXO model for transactions, so the transaction format is
    originally derived from that of Bitcoin.

*******************************************************************************/

public struct Transaction
{
    /// Transation type
    public TxType type;

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
        hashPart(this.type, dg);

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

    public void serialize (scope SerializeDg dg) const @safe
    {
        serializePart(this.type, dg);

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

    public void deserialize (scope DeserializeDg dg) @safe
    {
        deserializePart(this.type, dg);

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

    /// Support for sorting transactions
    public int opCmp (ref const(Transaction) other) const nothrow @safe @nogc
    {
        return hashFull(this).opCmp(hashFull(other));
    }

    /// Ditto
    public int opCmp (const(Transaction) other) const nothrow @safe @nogc
    {
        return this.opCmp(other);
    }
}

///
nothrow @safe @nogc unittest
{
    Transaction tx;
    auto hash = hashFull(tx);
    auto exp_hash = Hash("0x4b6e507a0519827d48792e6f27f3a0f5b4bc284c69c83a2a" ~
        "ebe35f11443e96364c90f780d4448320440efe68808fe4b6c7c4745d2e7c7e16956" ~
        "987df86f6a32f");
    assert(hash == exp_hash);
}

unittest
{
    import std.algorithm.sorting : isStrictlyMonotonic;
    static Transaction identity (ref Transaction tx) { return tx; }
    Transaction[] txs = [ Transaction.init, Transaction.init ];
    assert(!txs.isStrictlyMonotonic!((a, b) => identity(a) < identity(b)));
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

    public void serialize (scope SerializeDg dg) const @safe
    {
        serializePart(this.value, dg);
        serializePart(this.address, dg);
    }

    /***************************************************************************

        Output Deserialization

        Params:
            dg = deserialize function

    ***************************************************************************/

    public void deserialize (scope DeserializeDg dg) @safe
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

    public void serialize (scope SerializeDg dg) const @safe
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

    public void deserialize (scope DeserializeDg dg) @safe
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
        TxType.Payment,
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
        spend_amount = the total amount to spend (evenly distributed)

*******************************************************************************/

version (unittest)
public Transaction[] makeChainedTransactions (KeyPair key_pair,
    Transaction[] prev_txs, size_t block_count, ulong spend_amount = 40_000_000)
{
    import agora.consensus.data.Block;
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
    const Amount AmountPerTx = spend_amount / Block.TxsInBlock;

    foreach (idx; 0 .. TxCount)
    {
        Input input;
        if (prev_txs.length == 0)  // refering to genesis tx's outputs
            input = Input(hashFull(GenesisTransaction), idx.to!uint);
        else  // refering to tx's in the previous block
            input = Input(hashFull(prev_txs[idx % Block.TxsInBlock]), 0);

        Transaction tx =
        {
            TxType.Payment,
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
    import agora.consensus.data.Block;
    import std.format;
    auto gen_key = getGenesisKeyPair();

    /// should spend genesis block's outputs
    auto txes = makeChainedTransactions(gen_key, null, 1);
    foreach (idx; 0 .. Block.TxsInBlock)
    {
        assert(txes[idx].inputs.length == 1);
        assert(txes[idx].inputs[0].index == idx);
        assert(txes[idx].inputs[0].previous == hashFull(GenesisBlock.txs[0]));
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

    const TotalSpend = 20_000_000;
    txes = makeChainedTransactions(gen_key, prev_txs, 1, TotalSpend);
    auto SpendPerTx = TotalSpend / Block.TxsInBlock;
    foreach (idx; 0 .. Block.TxsInBlock)
    {
        assert(txes[idx].inputs.length == 1);
        assert(txes[idx].inputs[0].index == 0);
        assert(txes[idx].inputs[0].previous == hashFull(prev_txs[idx]));
        assert(txes[idx].outputs[0].value == Amount(SpendPerTx));
    }
}

/// Transaction type serialize & deserialize for unittest
unittest
{
    Transaction payment_tx = Transaction(
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output.init]
    );
    assert(agora.common.Deserializer.deserializeFull!Transaction(serializeFull(payment_tx)) == payment_tx);

    Transaction freeze_tx = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output.init]
    );
    assert(agora.common.Deserializer.deserializeFull!Transaction(serializeFull(freeze_tx)) == freeze_tx);
}

/// Transaction type hashing for unittest
unittest
{
    Transaction payment_tx = Transaction(
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output.init]
    );

    const tx_payment_hash = Hash(
    "0x9a87d86f702cd0f519efba81cf379f2a06907f34df6546f93c8619af113d0d774" ~
    "041b8e45f7975890b98890c7f5b0c062f6dae88ac1ec8d2c25dcf88b9aa01c9");
    assert(hashFull(payment_tx) == tx_payment_hash);

    Transaction freeze_tx = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output.init]
    );

    const tx_freeze_hash = Hash(
    "0x7c8f238f70318aae788487e57eb6f4793e3b0e48fbe017c1829ec269d07a76661" ~
    "5173e9a33739e916b1d40248a48add0296b2a8e51d0f8e1a87bf7acc7c4f136");
    assert(hashFull(freeze_tx) == tx_freeze_hash);
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

public bool getSumOutput (const Transaction tx, ref Amount acc)
    nothrow pure @safe @nogc
{
    foreach (ref o; tx.outputs)
        if (!acc.add(o.value))
            return false;
    return true;
}
