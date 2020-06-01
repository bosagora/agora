/*******************************************************************************

    Various utilities for testing purpose

    Utilities in this module can be used in test code.
    There are currently multiple testing approaches:
    - Unittests in the various `agora` module, the most common, cheapest,
      and a way to do white box testing;
    - Unittests under `agora.test`: Those unittests rely on the LocalRest
      library to simulate a network where nodes are thread who communicate
      via message passing.
    - Unit integration tests in `${ROOT}/tests/unit/` which are similar to
      unittests but provide a way to test IO-using code.
    - System integration tests: those are fully fledged tests that spawns
      unmodified, real nodes within Docker containers and act as a client.

    Any symbol in this module can be used by any of those method,
    which is why this module is neither restricted by `package(agora):`
    nor `version(unittest):`.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.Test;

import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.crypto.Schnorr;
import agora.common.Hash;
import agora.common.Serializer;
import agora.common.Types;
import agora.consensus.data.Transaction;
import agora.consensus.data.genesis;

import std.algorithm;
import std.array;
import std.file;
import std.format;
import std.path;
import std.range;

import core.exception;
import core.time;

/*******************************************************************************

    Get a temporary directory for unit integration tests

    Tests that do IO usually write or read files from disk.
    We want our tests to be reliable, reproducible, and re-runnable.
    For this reason, this function returns a path which has been `mkdir`ed
    after having been cleaned, which is located in the temporary directory.
    Consistent usage of this allows unit integration tests to be run in parallel
    (however the same test cannot be run multiple times in parallel,
    unless a different postfix is specified each time).

    Params:
      postfix = A unique postfix for the calling test

    Returns:
      The path of a clean, empty directory

*******************************************************************************/

public string makeCleanTempDir (string postfix = __MODULE__)
{
    string path = tempDir().buildPath("agora_testing_framework", postfix);
    // Note: The following path is only triggered when rebuilding locally,
    // code coverage is run from a clean slate so the `rmdirRecurse`
    // is never tested, hence the single-line statement helps with code coverage.
    if (path.exists) rmdirRecurse(path);
    mkdirRecurse(path);
    return path;
}

/*******************************************************************************

    Keeps retrying the 'check' condition until it is true,
    or until the timeout expires. It will sleep the main
    thread for 100 msecs between each re-try.

    If the timeout expires, and the 'check' condition is still false,
    it throws an AssertError.

    Params:
        Exc = a custom exception type, in case we want to catch it
        check = the condition to check on
        timeout = time to wait for the check to succeed
        msg = optional AssertException message when the condition fails
              after the timeout expires
        file = file from the call site
        line = line from the call site

    Throws:
        AssertError if the timeout is reached and the condition still fails

*******************************************************************************/

public void retryFor (Exc : Throwable = AssertError) (lazy bool check,
    Duration timeout, lazy string msg = "",
    string file = __FILE__, size_t line = __LINE__)
{
    import core.thread;

    // wait 100 msecs between attempts
    const SleepTime = 100;
    auto attempts = timeout.total!"msecs" / SleepTime;
    const TotalAttempts = attempts;

    while (attempts--)
    {
        if (check)
            return;

        Thread.sleep(SleepTime.msecs);
    }

    auto message = format("Check condition failed after timeout of %s " ~
        "and %s attempts", timeout, TotalAttempts);

    if (msg.length)
        message ~= ": " ~ msg;

    throw new Exc(message, file, line);
}

///
unittest
{
    import std.exception;

    static bool willSucceed () { static int x; return ++x == 2; }
    willSucceed().retryFor(1.seconds);

    static bool willFail () { return false; }
    assertThrown!AssertError(willFail().retryFor(300.msecs));
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

public Transaction[] makeChainedTransactions (KeyPair key_pair,
    const(Transaction)[] prev_txs, size_t block_count,
    ulong spend_amount = 40_000_000)
    @safe
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
    const genesisTxHash = GenesisBlock.txs[1].hashFull();

    foreach (idx; 0 .. TxCount)
    {
        Input input;
        if (prev_txs.length == 0)  // refering to genesis tx's outputs
        {
            input = Input(genesisTxHash, idx.to!uint);
        }
        else  // refering to tx's in the previous block
        {
            input = Input(hashFull(prev_txs[idx % Block.TxsInBlock]), 0);
        }

        Transaction tx =
        {
            TxType.Payment,
            [input],
            [Output(AmountPerTx, key_pair.address)]  // send to the same address
        };

        auto signature = () @trusted { return key_pair.secret.sign(hashFull(tx)[]); }();
        tx.inputs[0].signature = signature;
        transactions ~= tx;

        // new transactions will refer to the just created transactions
        // which will be part of the previous block after the block is created
        if ((idx > 0 && ((idx + 1) % Block.TxsInBlock == 0)))
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

    auto gen_key = WK.Keys.Genesis;

    /// should spend genesis block's outputs
    auto txes = makeChainedTransactions(gen_key, null, 1);
    foreach (idx; 0 .. Block.TxsInBlock)
    {
        assert(txes[idx].inputs.length == 1);
        assert(txes[idx].inputs[0].index == idx);
        assert(txes[idx].inputs[0].previous == hashFull(GenesisBlock.txs[1]));
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

/// example of chaining
unittest
{
    import agora.consensus.data.Block;

    auto gen_key = WK.Keys.Genesis;
    const(Transaction)[] txes = makeChainedTransactions(gen_key, null, 1);
    txes = makeChainedTransactions(gen_key, txes, 1);
}

/*******************************************************************************

    A list of well-known (WK) values which can be used in tests

*******************************************************************************/

public struct WK
{
    /// This struct is used as a namespace only
    @disable public this ();

    /// Well known public keys (matching Seed and Key)
    public static struct Keys
    {
        /// Exposes all keys
        public import agora.utils.WellKnownKeys;

        /// This struct is used as a namespace only
        @disable public this ();

        /// Provides a range interface to keys
        public static auto byRange ()
        {
            static struct Range
            {
                nothrow @nogc @safe:

                private size_t lbound = 0;
                private const size_t hbound = 26 + 26 * 26 * 2;

                public size_t length () const
                {
                    return this.lbound < this.hbound ?
                        this.hbound - this.lbound : 0;
                }
                public bool empty () const { return this.lbound >= this.hbound; }
                public KeyPair front () const { return Keys[this.lbound]; }
                public void popFront () { this.lbound++; }
            }

            return Range(0);
        }

        /// Returns: The `KeyPair` matching this `pubkey`, or `KeyPair.init`
        public static KeyPair opIndex (PublicKey pubkey) @safe nothrow @nogc
        {
            if (pubkey == Genesis.address)
                return Genesis;

            if (pubkey == NODE2.address)
                return NODE2;
            if (pubkey == NODE3.address)
                return NODE3;
            if (pubkey == NODE4.address)
                return NODE4;
            if (pubkey == NODE5.address)
                return NODE5;
            if (pubkey == NODE6.address)
                return NODE6;
            if (pubkey == NODE7.address)
                return NODE7;

            auto result = this.byRange.find!(k => k.address == pubkey);
            return result.empty ? KeyPair.init : result.front();
        }

        /// Allow one to use indexes to address the keys
        public static KeyPair opIndex (size_t idx) @safe nothrow @nogc
        {
            return wellKnownKeyByIndex(idx);
        }
    }
}

/// Consistency checks
unittest
{
    import std.string: representation;
    import agora.common.crypto.ECC;
    import agora.common.crypto.Schnorr;

    static assert(WK.Keys[0] == WK.Keys.A);
    static assert(WK.Keys[16] == WK.Keys.Q);
    static assert(WK.Keys[25] == WK.Keys.Z);
    static assert(WK.Keys[26] == WK.Keys.AA);
    static assert(WK.Keys[701] == WK.Keys.ZZ);
    static assert(WK.Keys[702] == WK.Keys.AAA);
    static assert(WK.Keys[1377] == WK.Keys.AZZ);

    // Range interface
    static assert(WK.Keys.byRange.length == 1378);

    // Key from index
    static assert(WK.Keys[WK.Keys.A.address] == WK.Keys.A);
    static assert(WK.Keys[WK.Keys.Q.address] == WK.Keys.Q);
    static assert(WK.Keys[WK.Keys.Z.address] == WK.Keys.Z);

    /// Sign / Verify work
    const sa = WK.Keys.A.secret.sign("WK.Keys.A".representation);
    assert(WK.Keys.A.address.verify(sa, "WK.Keys.A".representation));
    const sq = WK.Keys.Q.secret.sign("WK.Keys.Q".representation);
    assert(WK.Keys.Q.address.verify(sq, "WK.Keys.Q".representation));
    const sz = WK.Keys.Z.secret.sign("WK.Keys.Z".representation);
    assert(WK.Keys.Z.address.verify(sz, "WK.Keys.Z".representation));

    // Also with the Schnorr functions
    {
        auto pa = Pair(WK.Keys.A.secret.secretKeyToCurveScalar());
        pa.V = pa.v.toPoint();
        assert(pa.V == Point(WK.Keys.A.address));
        const ssa = sign(pa, "WK.Keys.A".representation);
        assert(verify(pa.V, ssa, "WK.Keys.A".representation));
        assert(!verify(pa.V, ssa, "WK.Keys.a".representation));

        auto pq = Pair(WK.Keys.Q.secret.secretKeyToCurveScalar());
        pq.V = pq.v.toPoint();
        assert(pq.V == Point(WK.Keys.Q.address));
        const ssq = sign(pq, "WK.Keys.Q".representation);
        assert(verify(pq.V, ssq, "WK.Keys.Q".representation));
        assert(!verify(pq.V, ssq, "WK.Keys.q".representation));

        auto pz = Pair(WK.Keys.Z.secret.secretKeyToCurveScalar());
        pz.V = pz.v.toPoint();
        assert(pz.V == Point(WK.Keys.Z.address));
        const ssz = sign(pz, "WK.Keys.Z".representation);
        assert(verify(pz.V, ssz, "WK.Keys.Z".representation));
        assert(!verify(pz.V, ssz, "WK.Keys.z".representation));
    }

    /// Test that Genesis is found
    {
        auto genesisKP = WK.Keys.Genesis;
        assert(WK.Keys[genesisKP.address] == genesisKP);
        // Sanity check with `agora.consensus.Genesis`
        assert(WK.Keys.Genesis.address == GenesisBlock.txs[1].outputs[0].address);
    }
}

/*******************************************************************************

    A reference to an `Output` within a `Transaction`

    In order to reference an `Output` in an UTXO, one need to know the hash
    of the transaction, as well as the index. This structure holds both index
    and `Transaction` for convenience.

*******************************************************************************/

public struct OutputRef
{
    ///
    public Hash hash () const nothrow @safe
    {
        return hashFull(this.tx);
    }

    ///
    public const(Output) output () const @safe pure nothrow @nogc
    {
        return this.tx.outputs[index];
    }

    /// The `Transaction` with the `Output` being referenced
    public const(Transaction) tx;

    /// The index of the `Output` being referenced
    public uint index;
}

/*******************************************************************************

    An helper utility to build transactions

    This utility exposes a mutable transaction builder, used to simplify
    generating complex `Transaction`s, as well as ensuring that generated
    transactions are valid. Generating invalid `Transaction`s is not supported,
    however one can generate a valid `Transaction` and mutate it afterwards.

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

    Well_Known_addresses:
    This utility relies on the signing keys used for the inputs to be part
    of well-known address (see `WK.Keys`).

    Error_handling:
    Since this is an utility inteded purely for testing, passing invalid data
    or inability to perform an operation will result in an assertion failure.

    Chaining:
    As can be seen in the example, operations which modify the state will
    return a reference to the `TxBuilder` to allow for easy chaining.

    Note:
    This `struct` is currently not reusable as there is not yet a use case for
    it, but could be made so in the future. Currently, calling `sign` will
    invalidate the internal state.

*******************************************************************************/

public struct TxBuilder
{
    /***************************************************************************

        Construct a new transaction builder with the provided refund address

        Params:
            refundMe = The address to receive the funds by default.
            tx = The transaction to attach to. If the `index` overload is used,
                 only the specified `index` will be attached, and it will be
                 the refund address. Otherwise, the first output is used.
            index = Index of the sole output to use from the transaction.

    ***************************************************************************/

    public this (in PublicKey refundMe) @safe pure nothrow @nogc
    {
        this.leftover = Output(Amount(0), refundMe);
    }

    /// Ditto
    public this (const Transaction tx) @safe pure nothrow
    {
        this(tx.outputs[0].address);
        this.attach(tx);
    }

    /// Ditto
    public this (const Transaction tx, uint index) @safe pure nothrow
    {
        this(tx.outputs[index].address);
        this.attach(tx, index);
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
        @safe pure nothrow return
    {
        this.inputs ~= iota(tx.outputs.length)
            .map!(index => OutputRef(tx, cast(uint) index)).array;
        tx.outputs.each!(outp => this.leftover.value.mustAdd(outp.value));
        return this;
    }

    /// Ditto
    public ref typeof(this) attach (const Transaction tx, uint index)
        @safe pure nothrow return
    {
        this.inputs ~= OutputRef(tx, index);
        this.leftover.value.mustAdd(tx.outputs[index].value);
        return this;
    }

    /***************************************************************************

        Finalize the transaction, signing the input, and reset the builder

        Params:
            type = type of `Transaction`

        Returns:
            The finalized & signed `Transaction`.

    ***************************************************************************/

    public Transaction sign (TxType type = TxType.Payment) @safe
    {
        assert(this.inputs.length, "Cannot sign input-less transaction");
        assert(this.data.outputs.length || this.leftover.value > Amount(0),
               "Output-less transactions are not valid");

        this.data.type = type;

        // Finalize the transaction by adding inputs
        foreach (ref in_; this.inputs)
            this.data.inputs ~= Input(in_.hash(), in_.index);

        // Add the refund tx, if needed
        if (this.leftover.value > Amount(0))
            this.data.outputs ~= this.leftover;

        // Get the hash to sign
        const txHash = this.data.hashFull();
        // Sign all inputs using WK keys
        foreach (idx, ref in_; this.inputs)
        {
            auto ownerKP = WK.Keys[in_.output.address];
            assert(ownerKP !is KeyPair.init,
                    "Address not found in Well-Known keypairs: "
                    ~ in_.output.address.toString());
            this.data.inputs[idx].signature = () @trusted
                { return ownerKP.secret.sign(txHash[]); }();
        }

        // Return the result and reset this
        this.inputs = null;
        this.leftover = Output.init;
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

    public ref typeof(this) refund (scope const PublicKey toward)
        @safe return
    {
        assert(this.inputs.length > 0);

        this.leftover = Output(Amount(0), toward);
        this.inputs.each!(val => this.leftover.value.mustAdd(val.output.value));
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
        if (isInputRange!KeyRange && is(ElementType!KeyRange : PublicKey))
    {
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
            KeyRange = A range of `PublicKey`
            toward = Beneficiary to split the currently available amount between

        Returns:
            Reference to `this` for easy chaining

    ***************************************************************************/

    public ref typeof(this) split (KeyRange) (scope KeyRange toward)
        return
        if (isInputRange!KeyRange && is(ElementType!KeyRange : PublicKey))
    {
        assert(!toward.empty, "No beneficiary in `split` transaction");

        // Cannot reuse `draw` because we might have an input range only
        // So we append new outputs and act on them directly
        size_t oldLen = this.data.outputs.length;
        this.data.outputs ~= toward.map!(key => Output(Amount(0), key)).array;
        auto newOutputs = this.data.outputs[oldLen .. $];

        // Now we know by how much we can divide out leftover
        auto forEach = this.leftover.value;
        this.leftover.value = forEach.div(newOutputs.length);
        newOutputs.each!((ref output) { output.value = forEach; });
        assert(newOutputs.all!(output => output.value > Amount(0)));

        return this;
    }

    /// Refund output for the transaction
    private Output leftover;

    /// Stores the inputs to consume until `sign` is called
    private const(OutputRef)[] inputs;

    /// Transactions to be built and returned
    private Transaction data;
}

/// Returns:
///   A range of `TxBuilder`s which reference each Payment output of
///   the Genesis block
public auto genesisSpendable () @safe
{
    return GenesisBlock.txs
        .filter!(tx => tx.type == TxType.Payment)
        .map!(tx => iota(tx.outputs.length).map!(idx => TxBuilder(tx, cast(uint)idx)))
        .joiner();
}

///
@safe nothrow unittest
{
    auto spendable = genesisSpendable();
    assert(!genesisSpendable.empty);
    Amount total;
    genesisSpendable.each!(txb => total.mustAdd(txb.leftover.value));
    // Arbitrarily low value
    assert(total > Amount.MinFreezeAmount);
}

/// Test for a split with the same amount of outputs as inputs
/// Essentially doing an equality transformation
unittest
{
    immutable Number = GenesisBlock.txs[1].outputs.length;
    assert(Number == 8);

    const tx = TxBuilder(GenesisBlock.txs[1])
        .split(WK.Keys.byRange.map!(k => k.address).take(Number))
        .sign();

    // This transaction has 8 txs, hence it's just equality
    assert(tx.inputs.length == Number);
    assert(tx.outputs.length == Number);
    // Since the amount is evenly distributed in Genesis,
    // they all have the same value
    const ExpectedAmount = genesisSpendable().front().leftover.value;
    assert(tx.outputs.all!(val => val.value == ExpectedAmount));
}

/// Test with twice as many outputs as inputs
unittest
{
    immutable Number = GenesisBlock.txs[1].outputs.length * 2;
    assert(Number == 16);

    const resTx1 = TxBuilder(GenesisBlock.txs[1])
        .split(WK.Keys.byRange.map!(k => k.address).take(Number))
        .sign();

    // This transaction has 16 txs
    assert(resTx1.inputs.length == Number / 2);
    assert(resTx1.outputs.length == Number);

    // 488M / 16
    const Amount ExpectedAmount1 = Amount(30_500_000L * 10_000_000L);
    assert(resTx1.outputs.all!(val => val.value == ExpectedAmount1));

    // Test with multi input keys
    // Split into 32 outputs
    const resTx2 = TxBuilder(resTx1)
        .split(iota(Number * 2).map!(_ => KeyPair.random().address))
        .sign();

    // This transaction has 32 txs
    assert(resTx2.inputs.length == Number);
    assert(resTx2.outputs.length == Number * 2);

    // 500M / 32
    const Amount ExpectedAmount2 = Amount(15_250_000L * 10_000_000L);
    assert(resTx2.outputs.all!(val => val.value == ExpectedAmount2));
}

/// Test with remainder
unittest
{
    const result = TxBuilder(GenesisBlock.txs[1])
        .split(WK.Keys.byRange.map!(k => k.address).take(3))
        .sign();

    // This transaction has 4 txs (3 targets + 1 refund)
    assert(result.inputs.length == 8);
    assert(result.outputs.length == 4);

    // 488M / 3
    const Amount ExpectedAmount      = Amount(162_666_666_6666_666L);

    assert(result.outputs[0].value == ExpectedAmount);
    assert(result.outputs[1].value == ExpectedAmount);
    assert(result.outputs[2].value == ExpectedAmount);
    // The first output is the remainder
    assert(result.outputs[3].value == Amount(2));
}

/// Test with one output key
unittest
{
    const result = TxBuilder(GenesisBlock.txs[1])
        .split([WK.Keys.A.address])
        .sign();

    // This transaction has 1 txs
    assert(result.inputs.length == 8);
    assert(result.outputs.length == 1);

    // 500M
    const Amount ExpectedAmount = Amount(488_000_000L * 10_000_000L);
    assert(result.outputs[0].value == ExpectedAmount);
}

/// Test changing the refund address (and merging outputs by extension)
unittest
{
    const result = TxBuilder(GenesisBlock.txs[1])
        // Refund needs to be called first as it resets the outputs
        .refund(WK.Keys.Z.address)
        .split(WK.Keys.byRange.map!(k => k.address).take(3))
        .sign();

    // This transaction has 4 txs (3 targets + 1 refund)
    assert(result.inputs.length == 8);
    assert(result.outputs.length == 4);

    assert(equal!((in Output outp, in KeyPair b) => outp.address == b.address)(
               result.outputs, [ WK.Keys.A, WK.Keys.B, WK.Keys.C, WK.Keys.Z ]));
}
