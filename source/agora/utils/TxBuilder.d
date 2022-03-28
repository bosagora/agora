/*******************************************************************************

    An helper utility to build transactions

    This utility exposes a mutable transaction builder, used to simplify
    generating complex `Transaction`s, as well as ensuring that generated
    transactions are valid. Generating invalid `Transaction`s is not supported,
    however one can generate a valid `Transaction` and mutate it afterwards.

    Usage_recommendation:
    The `TransactionBuilder` needs to access keys (more precisely, unlocker)
    in order to generate valid transaction. However, supplying those keys
    every time the `TransactionBuilder` is to be instantiated greatly reduce
    usability. For this reason, we recommmend something along the following:
    ```
    private KeyPair[PublicKey] allKeys;
    private Unlock keyUnlocker (in Transaction tx, in OutputRef out_ref)
        @safe nothrow
    {
        auto ownerKP = allKeys[out_ref.output.address];
        assert(ownerKP !is KeyPair.init)
        return genKeyUnlock(ownerKP.sign(tx.getChallenge()));
    }

    /// Publicly exposed alias used by other modules
    public alias TxBuilder = StaticTransactionBuilder!keyUnlocker;
    ```
    The following sections assume such a usage and thus reference `TxBuilder`.

    Basics:
    When building a transaction, one must first attach an `Output`,
    or a `Transaction`, using either the constructors or `attach`.
    All attached outputs are contributed towards a "refund" `Output`.
    Operations will draw from this refund transactions and create new `Output`s.

    In order to finalize the `Transaction`, one must call `sign`, which will
    return the signed `Transaction`. If there is any fund left, the refund
    `Output` will be the last output in the transaction.

    An example would be:
    ---
    auto tx1 = TxBuilder(myTx).split(addr1, addr2)
                              .attach(otherTx).split(addr3, addr4)
                              .sign();
    // Equivalent to:
    auto tx2 = TxBuilder(myTx.outputs[0].address)
                   .attach(myTx).split(addr1, addr2)
                   .attach(otherTx).split(addr3, addr4)
                   .sign();
    ---
    This will create 4 or 5 outputs, depending on the amounts. The first two
    will split `myTx` evenly towards `addr1` and `addr2`, the next two will
    split `otherTx` evenly between `addr3` and `addr4`. If either transaction
    has an uneven amount, a refund transaction towards the owner of the first
    output of `myTx` will be created.

    Refund_Address:
    When making a `TxBuilder`, the minimum requirement is to provide a refund
    address. If an output is provided, the address which owns this output
    will be the refund address, and if a `Transaction` is provided, the owner
    of the first output will be the refund address.

    Chaining:
    As can be seen in the example, operations which modify the state will
    return a reference to the `TxBuilder` to allow for easy chaining.

    Note:
    This `struct` is currently not reusable as there is not yet a use case for
    it, but could be made so in the future. Currently, calling `sign` will
    invalidate the internal state.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.TxBuilder;

import agora.common.Amount;
import agora.common.Types;
version (unittest) import agora.consensus.data.genesis.Test;
import agora.consensus.data.Params: ConsensusConfig;
import agora.consensus.data.Transaction;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.script.Lock;
import agora.script.Opcodes;
import agora.script.Script: toPushOpcode;
import agora.script.Signature;
version (unittest) import agora.utils.Test;

import std.algorithm;
import std.format;
import std.range;

/// Ditto
public struct StaticTransactionBuilder (alias KeyUnlocker)
{
    static assert(is(typeof(&KeyUnlocker) : TransactionBuilder.Unlocker),
                  "Expected `KeyUnlocker` template argument to `TransactionBuilder` " ~
                  "to be of type `" ~ TransactionBuilder.Unlocker.stringof ~ "`, not `" ~
                  typeof(&KeyUnlocker).stringof ~ "`");

    /// Actual object
    public TransactionBuilder builder;

    ///
    public alias builder this;

    /***************************************************************************

        Construct a new transaction builder with the provided refund address

        Params:
            refundMe = The address to receive the funds by default.
            lock = the lock to use in place of an address
            tx = The transaction to attach to. If the `index` overload is used,
                 only the specified `index` will be attached, and it will be
                 the refund address. Otherwise, the first output is used.
            index = Index of the sole output to use from the transaction.

    ***************************************************************************/

    public this (in PublicKey refundMe) @safe pure nothrow
    {
        this.builder = TransactionBuilder(&KeyUnlocker, refundMe);
    }

    /// Ditto
    public this (in Lock lock) @safe pure nothrow
    {
        this.builder = TransactionBuilder(&KeyUnlocker, lock);
    }

    /// Ditto
    public this (const Transaction tx) @safe nothrow
    {
        this.builder = TransactionBuilder(&KeyUnlocker, tx);
    }

    /// Ditto
    public this (const Transaction tx, uint index) @safe nothrow
    {
        this.builder = TransactionBuilder(&KeyUnlocker, tx, index);
    }

    /// Ditto
    public this (const Transaction tx, uint index, in Lock lock)
        @safe nothrow
    {
        this.builder = TransactionBuilder(&KeyUnlocker, tx, index, lock);
    }

    /// Convenience constructor that calls `this.attach(Output, Hash)`
    public this (in Output utxo, in Hash hash) @safe nothrow
    {
        this.builder = TransactionBuilder(&KeyUnlocker, utxo, hash);
    }
}

///
public struct TransactionBuilder
{
    /// Define Unlocker function to sign the inputs
    public alias Unlocker = Unlock function (in Transaction tx, in OutputRef out_ref)
        @safe nothrow;

    /***************************************************************************

        Construct a new transaction builder with the provided refund address

        Params:
            unlocker = The function to use for unlocking
            refundMe = The address to receive the funds by default.
            lock = the lock to use in place of an address
            tx = The transaction to attach to. If the `index` overload is used,
                 only the specified `index` will be attached, and it will be
                 the refund address. Otherwise, the first output is used.
            index = Index of the sole output to use from the transaction.

    ***************************************************************************/

    public this (Unlocker unlocker, in PublicKey refundMe) @safe pure nothrow
    {
        this.unlocker = unlocker;
        this.leftover = Output(Amount(0), refundMe);
    }

    /// Ditto
    public this (Unlocker unlocker, in Lock lock) @safe pure nothrow
    {
        this.unlocker = unlocker;
        this.leftover = Output(Amount(0), lock);
    }

    /// Ditto
    public this (Unlocker unlocker, const Transaction tx) @safe nothrow
    {
        this(unlocker, tx.outputs[0].lock);
        this.attach(tx);
    }

    /// Ditto
    public this (Unlocker unlocker, const Transaction tx, uint index) @safe nothrow
    {
        this(unlocker, tx.outputs[index].lock);
        this.attach(tx, index);
    }

    /// Ditto
    public this (Unlocker unlocker, const Transaction tx, uint index, in Lock lock)
        @safe nothrow
    {
        this(unlocker, lock);
        this.attach(tx, index);
    }

    /// Convenience constructor that calls `this.attach(Output, Hash)`
    public this (Unlocker unlocker, in Output utxo, in Hash hash) @safe nothrow
    {
        this(unlocker, utxo.address);
        this.attach(utxo, hash);
    }

    /***************************************************************************

        Attaches all or one output(s) of a transaction to this builder

        Params:
            tx = The transaction to consume
            index = If present, the index of the `Output` to use.
                    Otherwise all outputs from `tx` will be used.

        Returns:
            A reference to `this` to allow for chaining

    ***************************************************************************/

    public ref typeof(this) attach (const Transaction tx)
        @safe nothrow return
    {
        this.inputs ~= iota(tx.outputs.length)
            .map!(index => OutputRef(tx.outputs[index], Input(tx, index).utxo))
            .array;
        if (tx.outputs.any!(outp => !this.leftover.value.add(outp.value)))
            assert(0, "Adding a transaction led to overflow");
        return this;
    }

    /// Ditto
    public ref typeof(this) attach (const Transaction tx, uint index)
        @safe nothrow return
    {
        return this.attach(tx.outputs[index], Input(tx, index).utxo);
    }

    /***************************************************************************

        Attaches to an `Output` according to a hash

        Params:
            utxo = The `Output` to attach to
            hash = The hash that correspond to UTXO (`hashMulti(txhash, index)`)

        Returns:
            A reference to `this` to allow for chaining

    ***************************************************************************/

    public ref typeof(this) attach (in Output utxo, in Hash hash, Amount freeze_fee = 10_000.coins)
        @safe pure nothrow return
    {
        this.inputs ~= OutputRef(utxo, hash);
        if (!this.leftover.value.add(utxo.value))
            assert(0, "Adding utxo/hash led to overflow");
        if (utxo.type == OutputType.Freeze && !this.leftover.value.add(freeze_fee))
            assert(0, "Adding utxo/hash led to overflow");
        return this;
    }

    /***************************************************************************

        Attaches to a range of tuples.

        The tuple should have an `Output` and a `Hash` as its first and
        second element, respectively.

        Params:
            rng = the range of tuple

        Returns:
            A reference to `this` to allow for chaining

    ***************************************************************************/

    public ref typeof(this) attach (RNG) (scope RNG rng)
        @safe pure nothrow return
    {
        alias ET = ElementType!RNG;

        static assert(isInputRange!RNG);
        static assert(ET.length == 2, "Parameter must be a range of tuple with
            2 elements");
        static assert(is(typeof(ET[0]) : const Output),
            "Tuple's first element should be convertible to `Output`, not: `" ~
            typeof(ET[0]).stringof ~ "`");
        static assert(is(typeof(ET[1]) : const Hash),
            "Tuple's second element should be convertible to `Hash`, not: `" ~
            typeof(ET[1]).stringof ~ "`");

        rng.each!(tup => this.attach(tup[0], tup[1]));

        return this;
    }

    /***************************************************************************

        Sets the unlocker function to sign the inputs

        Params:
            unlocker = function to sign the inputs of the transaction

        Returns:
            A reference to `this` to allow for chaining

    ***************************************************************************/

    public ref typeof(this) unlockSigner (Unlocker unlocker) return scope
        @safe nothrow @nogc pure
    {
        this.unlocker = unlocker;
        return this;
    }

    /// Sign with a given key and append ubytes if given
    public Unlock signWithSpecificKey (KeyPair key, ubyte[] append = null) (in Transaction tx, in OutputRef)
        @safe nothrow
    {
        auto pair = SigPair(key.sign(tx.getChallenge()), SigHash.All);
        if (append)
            return Unlock(toPushOpcode(pair[]) ~ append);
        return Unlock(toPushOpcode(pair[]));
    }

    /***************************************************************************

        Set the payload used by the Transaction

    ***************************************************************************/

    public ref typeof(this) payload (ubyte[] data) return scope
        @safe nothrow @nogc pure
    {
        this.data.payload = data;
        return this;
    }


    /***************************************************************************

        Set the `lock_height` property of the resulting transaction

    ***************************************************************************/

    public ref typeof(this) lock (in Height height) return scope
        @safe nothrow @nogc pure
    {
        this.data.lock_height = height;
        return this;
    }

    /***************************************************************************

        Set the `feeRate` property of the resulting transaction

        This is the fee per byte of tx size

    ***************************************************************************/

    public ref typeof(this) feeRate (in Amount fee_rate) return scope
        @safe nothrow @nogc pure
    {
        this.fee_rate = fee_rate;
        return this;
    }

    /***************************************************************************

        Finalize the transaction, signing the input, and reset the builder

        Params:
            outputs_type = sets the outputs to `Payment` (default), `Freeze` or
                `Coinbase`. In case of `Freeze` a single refund `Payment` output
                will be created with any leftover.
            unlock_age = the unlock age for each input in the transaction

        Returns:
            The finalized & signed `Transaction`.

    ***************************************************************************/

    public Transaction sign (
        in OutputType outputs_type = OutputType.Payment, uint unlock_age = 0,
        Amount freeze_fee = 10_000.coins) @safe nothrow
    {
        assert(this.inputs.length, "Cannot sign input-less transaction");
        assert(this.data.outputs.length || this.leftover.value > Amount(0),
               "Output-less transactions are not valid");

        // First we sort the OutputRefs as later we set the unlock by index
        this.inputs.sort;
        // Add the inputs with just their unlocks to be added
        // (unlock is not part of Transaction hash but we need transaction hash to create the unlock)
        this.inputs.each!(o => this.data.inputs ~= Input(o.hash, Unlock.init, unlock_age));

        assert(this.data.inputs.isStrictlyMonotonic);

        foreach (ref o; this.data.outputs)
            o.type = outputs_type;

        auto total_fees = this.minFees();
        auto freeze_outputs = this.data.outputs.count!(o => o.type == OutputType.Freeze);
        if (outputs_type == OutputType.Freeze && this.data.outputs.length == 0) // Single freeze output must be frozen
            freeze_outputs++;
        freeze_fee.mul(freeze_outputs);
        assert(total_fees.add(freeze_fee));
        assert(this.leftover.value >= total_fees);
        if (this.leftover.value.sub(total_fees) && this.leftover.value > this.MinRefundAmount)
        {
            if (outputs_type == OutputType.Freeze && this.data.outputs.length == 0) // Single freeze output must be frozen
                this.data.outputs = [ Output(this.leftover.value, this.leftover.lock, OutputType.Freeze) ];
            else
                this.data.outputs = [ Output(this.leftover.value, this.leftover.lock, OutputType.Payment) ] ~ this.data.outputs;
        }
        this.data.outputs.sort;

        // Sign all inputs using unlocker now we have transaction outputs updated
        foreach (idx, ref in_; this.inputs)
            this.data.inputs[idx].unlock = this.unlocker(this.data, in_);

        // Reset ready for next time
        this.inputs = null;
        this.leftover = Output.init;
        // Reset transaction if it is returned successfully
        scope (success) this.data = Transaction.init;
        return this.data;
    }

    /***************************************************************************

        Resets the state and changes the address of the refund transaction

        Ideally one should provide the correct address for the refund
        transaction in the constructor, however if for some reason it is not
        known in advance, or if the `Output` or `Transaction` overload is used,
        this function provides a convenient mean to change the refund address.

        Params:
            toward = Refund address to use for the transaction being built

        Returns:
            Reference to `this` for easy chaining

    ***************************************************************************/

    public ref typeof(this) refund (in PublicKey toward)
        return @safe nothrow
    {
        assert(this.inputs.length > 0);

        this.leftover = Output(Amount(0), toward, OutputType.Payment);
        if (this.inputs.any!(val => !this.leftover.value.add(val.output.value)))
            assert(0, "Resetting the refund address led to an overflow");
        this.data.outputs = null;

        return this;
    }

    /***************************************************************************

        Splits the attached input into multiple outputs of the given amounts.

        Any leftover will remain in the refund transaction.
        The value drawn (`amount * toward.length`) must be lesser or equal
        to the fund currently attached and in the refund transaction.

        Params:
            KeyRange = A range of `PublicKey`
            amount = `Amount` to distribute to each `PublicKey`
            toward = Array of `PublicKey` to give `amount` to

        Returns:
            Reference to `this` for easy chaining

    ***************************************************************************/

    public ref typeof(this) draw (KeyRange) (Amount amount, scope KeyRange toward)
        return
    {
        static assert (isInputRange!KeyRange);
        static assert (is(ElementType!KeyRange : PublicKey));

        assert(!toward.empty, "No beneficiary in `draw` transaction");
        assert(amount > Amount(0), "Cannot have outputs of value `0`");

        toward.each!((key)
        {
            this.data.outputs ~= Output(amount, key);
            // Provide friendlier error message for developers
            if (!this.leftover.value.sub(amount))
                assert(0, format("Error: Withdrawing %d times %s BOA underflown",
                                 toward.length, amount));
        });

        return this;
    }

    /***************************************************************************

        Similar to `draw(Amount, PublicKey[])`, but uses all available funds

        Note that if the available funds are not a multiple of `toward.length`,
        the refund `Output` will holds the leftovers.

        Params:
            KeyRange = A range of `PublicKey` or `Lock`
            toward = Beneficiary to split the currently available amount between

        Returns:
            Reference to `this` for easy chaining

    ***************************************************************************/

    public ref typeof(this) split (KeyRange) (scope KeyRange toward) return
    {
        static assert (isInputRange!KeyRange);
        static assert (is(ElementType!KeyRange : PublicKey)
            || is(ElementType!KeyRange : Lock));

        assert(!toward.empty, "No beneficiary in `split` transaction");

        // Cannot reuse `draw` because we might have an input range only
        // So we append new outputs and act on them directly
        size_t oldLen = this.data.outputs.length;
        this.data.outputs ~= toward.map!(key => Output(Amount(0), key)).array;
        auto newOutputs = this.data.outputs[oldLen .. $];

        // Now we know by how much we can divide out leftover
        Amount forEach = this.leftover.value;
        Amount total_fees = this.minFees();
        assert(forEach >= total_fees);
        if (!forEach.sub(total_fees))
            assert(0, "Insufficient fees");
        forEach.div(newOutputs.length); // We ignore any remainder so it will become extra fees
        newOutputs.each!((ref output)
        {
            output.value = forEach;
            this.leftover.value.sub(forEach);
        });
        assert(this.leftover.value >= total_fees);
        this.data.inputs = null; // reset as they are added in sign with the unlock age
        assert(newOutputs.all!(output => output.value > Amount(0)));
        return this;
    }

    /***************************************************************************

        Deduct a certain amount

        Useful when trying to deduct fees from outputs

        Params:
            amount = Amount to deduct

        Returns:
            Reference to `this` for easy chaining

    ***************************************************************************/

    public ref typeof(this) deduct (Amount amount) @safe nothrow
        return
    {
        if (!this.leftover.value.sub(amount))
            assert(0, format("Error: Withdrawing %s BOA underflown", amount));

        return this;
    }

    /// The actual function that will sign the inputs
    private Unlocker unlocker;

    /// Any refund less than this amount will not create a refund output but be
    /// left to be included as fees.
    private const MinRefundAmount = Amount(500_000);

    /// Refund output for the transaction
    private Output leftover;

    /// fee per byte rate to be paid for the tx
    private auto fee_rate = ConsensusConfig.init.min_fee;

    /// Stores the inputs to consume until `sign` is called
    private OutputRef[] inputs;

    /// Transactions to be built and returned
    private Transaction data;


    /// Calculate the minimum fees based on the size of the transaction
    private Amount minFees () nothrow @safe
    {
        // Sum the size of all inputs after signing with unlocker
        auto tx_size = this.data.payload.length;
        this.inputs.each!((OutputRef input)
        {
            tx_size += Input(input.hash, this.unlocker(this.data, input), 0).sizeInBytes;
        });
        this.data.outputs.each!((output)
        {
            tx_size += output.sizeInBytes;
        });
        Amount total_fees = this.fee_rate;
        total_fees.mul(tx_size);
        // Just in case there results in a refund output we add the fee based on the byte size
        if (this.leftover.value > total_fees)
        {
            auto refund_output_fee = this.fee_rate;
            if (!refund_output_fee.mul(Output(Amount(0), this.leftover.lock, OutputType.Payment).sizeInBytes))
                assert(0);
            if (!total_fees.add(refund_output_fee))
                assert(0);
        }
        return total_fees;
    }
}

version (unittest)
{
    private Amount sumOfGenesisFirstTxOutputs ()
    {
        return genesisSpendable().front().leftover.value * 8;
    }
    private const fee_rate = ConsensusConfig.init.min_fee;
}

/// Test for a split with the same amount of outputs as inputs
/// Essentially doing an equality transformation
unittest
{
    immutable Number = GenesisBlock.payments.front.outputs.length;
    assert(Number == 8);

    const tx = TxBuilder(GenesisBlock.payments.front)
        .split(WK.Keys.byRange.map!(k => k.address).take(Number))
        .sign();

    // This transaction splits to 8 outputs
    assert(tx.inputs.length == Number);
    assert(tx.outputs.length == Number);
    // Since the amount is evenly distributed in Genesis,
    // they all have the same value
    auto implied_fees = tx.outputs.map!(o => o.value).fold!((a,b) => a - b)(sumOfGenesisFirstTxOutputs());
    assert(implied_fees >= fee_rate * tx.sizeInBytes);
    assert(tx.outputs == [
        Output(Amount(59_499_999_9871_462L), WK.Keys.A.address),
        Output(Amount(59_499_999_9871_462L), WK.Keys.C.address),
        Output(Amount(59_499_999_9871_462L), WK.Keys.D.address),
        Output(Amount(59_499_999_9871_462L), WK.Keys.E.address),
        Output(Amount(59_499_999_9871_462L), WK.Keys.F.address),
        Output(Amount(59_499_999_9871_462L), WK.Keys.G.address),
        Output(Amount(59_499_999_9871_462L), WK.Keys.H.address),
        Output(Amount(59_499_999_9871_462L), WK.Keys.J.address),
    ].sort.array);
    // check we have not lost any coin
    assert((Amount(59_499_999_9871_462L) * 8) + implied_fees == Amount(59_500_000_0000_000L) * 8);
}

/// Test with twice as many outputs as inputs
unittest
{
    immutable Number = GenesisBlock.payments.front.outputs.length * 2;
    assert(Number == 16);

    const resTx1 = TxBuilder(GenesisBlock.payments.front)
        .split(WK.Keys.byRange.map!(k => k.address).take(Number))
        .sign();

    // This transaction has 8 inputs
    assert(resTx1.inputs.length == GenesisBlock.payments.front.outputs.length);
    // The transaction splits to 16 outputs
    assert(resTx1.outputs.length == Number);

    // 488M / 16
    const totalInputs = sumOfGenesisFirstTxOutputs();
    auto outputs_1 = resTx1.outputs.map!(o => o.value).reduce!((a,b) => a + b);
    auto implied_fees = totalInputs - outputs_1;
    assert(implied_fees >= fee_rate * resTx1.sizeInBytes);
    auto outputs = outputs_1;
    auto refund = outputs.div(Number);
    assert(refund == Amount(0));
    assert(resTx1.outputs.map!(o => o.value).reduce!(max) == outputs);
    assert(resTx1.outputs.count!(o => o.value == outputs) == Number);

    // Test with multi input keys
    // Split into 32 outputs
    const resTx2 = TxBuilder(resTx1)
        .split(iota(Number * 2).map!(_ => KeyPair.random().address))
        .sign();

    // This transaction has 32 txs
    assert(resTx2.inputs.length == Number);
    assert(resTx2.outputs.length == Number * 2);
    auto outputs_2 = resTx2.outputs.map!(o => o.value).reduce!((a,b) => a + b);
    auto implied_fees_2 = outputs_1 - outputs_2;
    assert(implied_fees_2 >= fee_rate * resTx2.sizeInBytes);
    auto refund_2 = outputs_2.div(Number * 2);
    assert(refund_2 == Amount(0));
    assert(resTx2.outputs.map!(o => o.value).reduce!(max) == outputs_2);
    assert(resTx2.outputs.count!(o => o.value == outputs_2) == Number * 2);
}

/// Test with small remainder
unittest
{
    immutable Number = 3;
    auto fee_rate = Amount(700);

    const result = TxBuilder(GenesisBlock.payments.front)
        .split(WK.Keys.byRange.map!(k => k.address).take(Number))
        .sign();

    assert(result.outputs.length == Number);
    const totalInputs = sumOfGenesisFirstTxOutputs();
    auto outputs = result.outputs.map!(o => o.value).reduce!((a,b) => a + b);
    auto implied_fees = totalInputs - outputs;
    assert(implied_fees >= fee_rate * result.sizeInBytes);
    auto refund = outputs.div(Number);
    assert(refund == Amount(0));
    assert(result.outputs.map!(o => o.value).reduce!(max) == outputs);
    assert(result.outputs.count!(o => o.value == outputs) == Number);

    // This transaction has 3 outputs
    assert(result.inputs.length == 8);
    assert(result.inputs.isSorted);
    assert(result.outputs.length == 3);
    assert(result.outputs.isSorted);
}

/// Test with one output key
unittest
{
    const result = TxBuilder(GenesisBlock.payments.front)
        .split([WK.Keys.A.address])
        .sign();

    // This transaction has 1 txs
    assert(result.inputs.length == 8);
    assert(result.outputs.length == 1);

    const totalInputs = sumOfGenesisFirstTxOutputs();
    auto implied_fees = totalInputs - result.outputs[0].value;
    assert(implied_fees >= fee_rate * result.sizeInBytes);
}

/// Test changing the refund address (and merging outputs by extension)
unittest
{
    immutable Number = 3;
    const result = TxBuilder(GenesisBlock.payments.front)
        // Refund needs to be called first as it resets the outputs
        .refund(WK.Keys.Z.address)
        .draw(Amount(100_000_000_0000_000L), WK.Keys.byRange.map!(k => k.address).take(Number))
        .sign();

    // This transaction has 4 outputs (3 draw and 1 refund)
    assert(result.inputs.length == 8);
    assert(result.outputs.length == Number + 1);

    const totalInputs = sumOfGenesisFirstTxOutputs();
    auto outputs = result.outputs.map!(o => o.value).reduce!((a,b) => a + b);
    auto implied_fees = totalInputs - outputs;
    assert(implied_fees >= fee_rate * result.sizeInBytes);
    assert(result.outputs == [
        Output(totalInputs - implied_fees - Amount(100_000_000_0000_000L) * 3, WK.Keys.Z.address),
        Output(Amount(100_000_000_0000_000L), WK.Keys.A.address),
        Output(Amount(100_000_000_0000_000L), WK.Keys.C.address),
        Output(Amount(100_000_000_0000_000L), WK.Keys.D.address),
    ].sort.array);
}

/// Test with a range of tuples
unittest
{
    Output[4] outs = [
        Output(Amount(1_000_000), WK.Keys.A.address),
        Output(Amount(2_000_000), WK.Keys.C.address),
        Output(Amount(3_000_000), WK.Keys.D.address),
        Output(Amount(4_000_000), WK.Keys.E.address),
    ];

    // The hash is incorrect (it's not a proper UTXO hash)
    // but TxBuilder only care about strictly monotonic hashes
    auto tup_rng = outs[].zip(outs[].map!(o => o.hashFull()));
    auto result = TxBuilder(WK.Keys.F.address).attach(tup_rng).sign();

    auto fees = fee_rate * result.sizeInBytes;
    Amount total;
    outs.each!(o => total += o.value);
    auto expectedAmount = total - fees;

    assert(result.inputs.length == 4);
    assert(result.outputs.length == 1);
    assert(result.outputs[0] == Output(expectedAmount, WK.Keys.F.address));
}

///
@safe unittest
{
    auto spendable = genesisSpendable();
    assert(!genesisSpendable.empty);
    Amount total;
    genesisSpendable.each!(txb => total += txb.leftover.value);
    // Arbitrarily low value
    assert(total > Amount.MinFreezeAmount);
}

/// Test with unfrozen remainder
unittest
{
    const result = TxBuilder(GenesisBlock.payments.front)
        .draw(Amount.UnitPerCoin * 50_000, WK.Keys.byRange.map!(k => k.address).take(3))
        .sign(OutputType.Freeze, 0, 10_000.coins);

    // This transaction has 4 outputs (3 freeze + 1 refund)
    assert(result.inputs.length == 8);
    assert(result.outputs.length == 4);

    // 488M / 3
    assert(result.outputs == [
        Output(Amount(50_000_0000_000L), WK.Keys.A.address, OutputType.Freeze),
        Output(Amount(50_000_0000_000L), WK.Keys.C.address, OutputType.Freeze),
        Output(Amount(50_000_0000_000L), WK.Keys.D.address, OutputType.Freeze),
        Output(Amount(475_819_999_9129_200L), WK.Keys.Genesis.address),
    ].sort.array);
}

/// Test with unfrozen remainder with different fee rate
unittest
{
    auto fee_rate = Amount(900);    // Using higher than min fee rate
    const freezeAmount = 50_000.coins;
    const result = TxBuilder(GenesisBlock.payments.front)
        .feeRate(fee_rate)
        .draw(freezeAmount, WK.Keys.byRange.map!(k => k.address).takeExactly(1))
        .sign(OutputType.Freeze, 0, 10_000.coins);

    // This transaction has 2 outputs (1 freeze + 1 refund)
    assert(result.inputs.length == 8);
    assert(result.outputs.length == 2);

    auto fees = (fee_rate * result.sizeInBytes) + 10_000.coins;
    assert(result.outputs.count!(o => o.value == freezeAmount && o.type == OutputType.Freeze) == 1);
    auto refund = sumOfGenesisFirstTxOutputs() - freezeAmount - fees;
    assert(result.outputs.count!(o => o.value == refund && o.type == OutputType.Payment) == 1);
}

/*******************************************************************************

    A reference to an `Output` within a `Transaction`

    In order to reference an `Output` in an UTXO, one need to know the hash
    (derived from the transaction and the index).
    This structure holds both the hash and the `Output` for further reference.

*******************************************************************************/

public struct OutputRef
{
    /// The `Output` being referenced
    public Output output;

    /// The hash of the Output, to build the transaction
    public Hash hash;

    public int opCmp (in typeof(this) rhs) const nothrow @safe @nogc
    {
        return this.hash.opCmp(rhs.hash);
    }
}
