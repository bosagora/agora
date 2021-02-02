/*******************************************************************************

    Defines the data structure of a transaction

    A Transaction's Output contains the lock script, whereas the Input contains
    the unlock script.

    In case of simple payment transactions, the lock & unlock pairs are simple
    byte arrays containing the key and the signature.

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.Transaction;

import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Types;
import agora.common.Hash;
import agora.common.Serializer;
import agora.consensus.data.DataPayload;
import agora.script.Lock;

import std.algorithm;

/// Type of the transaction: defines the content that follows and the semantic of it
public enum TxType : ubyte
{
    Payment,
    Freeze,
    Coinbase,
}

/*******************************************************************************

    Represents a transaction (shortened as 'tx')

    Agora uses a UTXO model for transactions, so the transaction format is
    originally derived from that of Bitcoin.

*******************************************************************************/

public struct Transaction
{
    /// Transaction type
    public TxType type;

    /// The list of unspent `outputs` from previous transaction(s) that will be spent
    public Input[] inputs;

    /// The list of newly created outputs to put in the UTXO
    public Output[] outputs;

    /// The data to store
    public DataPayload payload;

    /// This transaction may only be included in a block with `height >= lock_height`.
    /// Note that another tx with a lower lock time could double-spend this tx.
    public Height lock_height = Height(0);

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

        serializePart(payload, dg);

        serializePart(this.lock_height, dg);
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

    /// The lock condition for this Output
    public Lock lock;

    /// Ctor
    public this (Amount value, inout(Lock) lock) inout pure nothrow @trusted
    {
        this.value = value;
        this.lock = lock;
    }

    /// Kept here for backwards-compatibility
    public this (Amount value, PublicKey key) inout pure nothrow @trusted
    {
        this.value = value;
        this.lock = genKeyLock(key);
    }

    /***************************************************************************

        Kept here for backwards compatibility with tests which do not expect
        lock scripts.

        Returns:
            the public key out of the output if the lock is a `LockType.Key`,
            else returns PublicKey.init

    ***************************************************************************/

    @property public PublicKey address () const pure nothrow @safe @nogc
    {
        import agora.common.crypto.ECC;

        if (this.lock.type != LockType.Key)
            return PublicKey.init;

        if (this.lock.bytes.length != Point.sizeof)
            return PublicKey.init;

        Point point = Point(this.lock.bytes);
        PublicKey key = PublicKey(point[]);
        return key;
    }
}

/// The input of the transaction, which spends a previously received `Output`
public struct Input
{
    /// The hash of the UTXO to be spent
    public Hash utxo;

    /// The unlock script, which will be ran together with the matching Input's
    /// lock script in the execution engine
    public Unlock unlock;

    /// The UTXO this `Input` references must be at least `unlock_age` older
    /// than the block height at which the spending transaction wants to be
    /// included in the block. Use for implementing relative time locks.
    public uint unlock_age = 0;

    /// Simple ctor
    public this (in Hash utxo_, Unlock unlock = Unlock.init, uint unlock_age = 0)
        inout pure nothrow @nogc @trusted
    {
        this.utxo = utxo_;
        this.unlock = cast(inout(Unlock))unlock; // cast: workaround for inout
        this.unlock_age = unlock_age;
    }

    /// Ctor which does hashing based on index
    public this (Hash txhash, ulong index, uint unlock_age = 0) nothrow @safe
    {
        this.utxo = hashMulti(txhash, index);
        this.unlock_age = unlock_age;
    }

    /// Ctor which does hashing based on the `Transaction` and index
    public this (in Transaction tx, ulong index, uint unlock_age = 0) nothrow @safe
    {
        this.utxo = hashMulti(tx.hashFull(), index);
        this.unlock_age = unlock_age;
    }

    /// Ctor to create dummy inputs for Coinbase TXs
    public this (Height height) nothrow @safe
    {
        this.utxo = hashFull(height);
    }

    /***************************************************************************

        Implements hashing support

        Params:
            dg = hashing function

    ***************************************************************************/

    public void computeHash (scope HashDg dg) const nothrow @safe @nogc
    {
        dg(this.utxo[]);
        hashPart(this.unlock_age, dg);
    }
}

/// Transaction type serialize & deserialize for unittest
unittest
{
    testSymmetry!Transaction();

    Transaction payment_tx = Transaction(
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output.init]
    );
    testSymmetry(payment_tx);

    Transaction freeze_tx = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output.init]
    );
    testSymmetry(freeze_tx);

    Transaction data_tx = Transaction(
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output.init],
        DataPayload([1,2,3])
    );
    testSymmetry(data_tx);

    Transaction cb_tx = Transaction(
        TxType.Coinbase,
        [Input(Height(0))],
        [Output.init],
        DataPayload([1,2,3])
    );
    testSymmetry(cb_tx);
}

unittest
{
    import agora.common.Set;
    auto tx_set = Set!Transaction.from([Transaction.init]);
    testSymmetry(tx_set);
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
        `0x7e1397f754c32d6cf25afe82da060bbbd0d4ed40bd0305d3ddbe3cdc9d27af052f603e7b8fd5c3d9a0e545e371d062fd6344967cfd1e05b8b38a66af808ad8a9`);
    const expected1 = payment_tx.hashFull();
    assert(expected1 == tx_payment_hash, expected1.toString());

    Transaction freeze_tx = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output.init]
    );

    const tx_freeze_hash = Hash(
        `0x7aad0c09d5eaa12a75da0977a3a87e88f39f12e3a6c538f9a499cd37298c80e8e855815a1f85b55a7a2ff9b3ca50f9c868c1c94c9ab9fa563c5ae796e1ebe000`);
    const expected2 = freeze_tx.hashFull();
    assert(expected2 == tx_freeze_hash, expected2.toString());
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

unittest
{
    import vibe.data.json;
    Transaction old_tx = Transaction(
        TxType.Payment,
        [Input(Hash.init, 0)],
        [Output.init],
        DataPayload([1,2,3])
    );
    auto json_str = old_tx.serializeToJsonString();

    Transaction new_tx = deserializeJson!Transaction(json_str);
    assert(new_tx.payload.data.length == old_tx.payload.data.length);
    assert(new_tx.payload.data == old_tx.payload.data);
}

// Check exact same Coinbase TXs for different heights generate different hashes
unittest
{
    Transaction h0_tx = Transaction(
        TxType.Coinbase,
        [Input(Height(0))],
        [Output.init],
        DataPayload([1,2,3])
    );

    Transaction h1_tx = Transaction(
        TxType.Coinbase,
        [Input(Height(1))],
        [Output.init],
        DataPayload([1,2,3])
    );

    assert(h0_tx.hashFull() != h1_tx.hashFull());
}
