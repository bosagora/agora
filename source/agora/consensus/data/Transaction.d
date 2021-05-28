/*******************************************************************************

    Defines the data structure of a transaction

    A Transaction's Output contains the lock script, whereas the Input contains
    the unlock script.

    In case of simple payment transactions, the lock & unlock pairs are simple
    byte arrays containing the key and the signature.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.Transaction;

import agora.common.Amount;
import agora.common.Types;
import agora.consensus.data.DataPayload;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.script.Lock;
import agora.serialization.Serializer;

import std.algorithm;
import std.array;

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
    @safe:

    /// ctor with only outputs
    public this (in TxType type, Output[] outputs) nothrow
    {
        this.type = type;
        outputs.sort;
        this.outputs = outputs;
    }

    /// ctor with only inputs
    public this (Input[] inputs) nothrow
    {
        this.type = TxType.Freeze;  // Can only be freeze
        inputs.sort;
        this.inputs = inputs;
    }

    /// ctor without DataPayload
    public this (in TxType type, Input[] inputs, Output[] outputs,
        in Height lock_height = Height(0)) nothrow
    {
        this(type, outputs);
        inputs.sort;
        this.inputs = inputs;
        this.lock_height = lock_height;
    }

    /// ctor with immutable fields so the inputs and outputs must be already sorted
    public this (in TxType type, inout Input[] inputs, inout Output[] outputs,
        inout DataPayload payload = DataPayload.init,
        in Height lock_height = Height(0)) inout nothrow
    {
        this.type = type;
        this.inputs = inputs;
        this.outputs = outputs;
        this.payload = payload;
        this.lock_height = lock_height;
        assert(this.inputs.dup.isStrictlyMonotonic!((a, b) => a < b));
        assert(this.outputs.dup.isSorted!((a, b) => a < b));
    }

    /// Used in some unit tests with only the lock_height set
    version (unittest)
    {
        public this (Height lock_height)
        {
            this.lock_height = Height(lock_height);
        }
    }

    /// Transaction type
    public TxType type;

    /// The list of unspent `outputs` from previous transaction(s) that will be spent
    public Input[] inputs;

    /// The list of newly created outputs to put in the UTXO
    public Output[] outputs;

    /// The data to store
    public DataPayload payload;

    /// The size of the Transaction object
    public ulong sizeInBytes () const nothrow pure @nogc
    {
        ulong size = this.type.sizeof + this.payload.sizeInBytes();
        foreach (const ref input; this.inputs)
            size += input.sizeInBytes();
        foreach (const ref output; this.outputs)
            size += output.sizeInBytes();
        return size;
    }

    /// This transaction may only be included in a block with `height >= lock_height`.
    /// Note that another tx with a lower lock time could double-spend this tx.
    public Height lock_height = Height(0);

    /***************************************************************************

        Transactions Serialization

        Params:
            dg = Serialize function

    ***************************************************************************/

    public void serialize (scope SerializeDg dg) const
    {
        serializePart(this.type, dg);

        serializePart(this.inputs.length, dg);
        foreach (const ref input; this.inputs)
            serializePart(input, dg);

        serializePart(this.outputs.length, dg);
        assert(this.outputs.isSorted!((a, b) => a < b));
        foreach (const ref output; this.outputs)
            serializePart(output, dg);

        serializePart(payload, dg);

        serializePart(this.lock_height, dg);
    }

    /// Support for sorting transactions
    public int opCmp (in Transaction other) const nothrow @nogc
    {
        return hashFull(this).opCmp(hashFull(other));
    }

    pure nothrow @nogc:

    /// A `Freeze` transaction
    public bool isFreeze () const
    {
        return this.type == TxType.Freeze;
    }

    /// A `Coinbase` transaction
    public bool isCoinbase () const
    {
        return this.type == TxType.Coinbase;
    }

    /// A `Payment` transaction
    public bool isPayment () const
    {
        return this.type == TxType.Payment;
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

    /// The size of the Output object
    public ulong sizeInBytes () const nothrow pure @safe @nogc
    {
        return this.value.sizeof + this.lock.sizeInBytes();
    }

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
        // Bug: Used to call `genLockKey` but `-preview=in` triggers:
        // source/agora/consensus/data/Transaction.d(142,31):
        // Error: cannot implicitly convert expression genKeyLock(key) of type Lock to inout(Lock)
        // source/agora/consensus/data/genesis/Test.d(107,23):
        // called from here: Output(Amount(0LU), Lock(LockType.Key, null)).this(Amount(0LU).this(20000000000000LU), NODE2.address)
        this.lock = Lock(LockType.Key, key[].dup);
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
        import agora.crypto.ECC;

        if (this.lock.type != LockType.Key)
            return PublicKey.init;

        if (this.lock.bytes.length != Point.sizeof)
            return PublicKey.init;

        Point point = Point(this.lock.bytes);
        PublicKey key = PublicKey(point[]);
        return key;
    }

    /// Support for sorting
    public int opCmp (in typeof(this) rhs) const nothrow @safe @nogc
    {
        if (this.lock != rhs.lock)
            return this.lock < rhs.lock ? -1 : 1;
        return this.value.opCmp(rhs.value);
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

    /// The size of the Input object
    public ulong sizeInBytes () const nothrow pure @safe @nogc
    {
        return this.unlock.sizeInBytes() + this.unlock_age.sizeof + this.utxo.sizeof;
    }

    /// Simple ctor
    public this (in Hash utxo_, Unlock unlock = Unlock.init, uint unlock_age = 0)
        inout pure nothrow @nogc @trusted
    {
        this.utxo = utxo_;
        this.unlock = cast(inout(Unlock))unlock; // cast: workaround for inout
        this.unlock_age = unlock_age;
    }

    /// Ctor which does hashing based on index
    public this (in Hash txhash, ulong index, uint unlock_age = 0) nothrow @safe
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
    public this (in Height height) nothrow @safe
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

    /// Support for sorting
    public int opCmp (in typeof(this) rhs) const nothrow @safe @nogc
    {
        return this.utxo.opCmp(rhs.utxo);
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
        `0xef5d99551a2d15e723f77a468fcd1d1a9635d0ff2eb6924445e8b005108e0c7007c60135014a46c4513bfaaa3c6e0ff826c28c86f63c8976f5c5527599d46bac`);
    const expected1 = payment_tx.hashFull();
    assert(expected1 == tx_payment_hash, expected1.toString());

    Transaction freeze_tx = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output.init]
    );

    const tx_freeze_hash = Hash(
        `0x9f7f610a6b2689b2c88ec3c62bbd7cf393737700f660793d6642b2852773de0abc2c0d4bb3a7d4a807dfd869f88e91e28471f6a4d2c990442b9c250585c25051`);
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

public bool getSumOutput (in Transaction tx, ref Amount acc)
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
    assert(new_tx.payload.bytes.length == old_tx.payload.bytes.length);
    assert(new_tx.payload.bytes == old_tx.payload.bytes);
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
