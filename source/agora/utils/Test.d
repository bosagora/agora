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
import agora.consensus.data.Block;
import agora.consensus.data.DataPayload;
import agora.consensus.data.Transaction;
import agora.consensus.data.genesis.Test;
import agora.script.Lock;
public import agora.utils.Utility : retryFor;

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
                private enum size_t hbound = 26 + 26 * 26 * 2;

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

            if (pubkey == CommonsBudget.address)
                return CommonsBudget;

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
        auto pa = Pair.fromScalar(WK.Keys.A.secret.secretKeyToCurveScalar());
        assert(pa.V == Point(WK.Keys.A.address));
        const ssa = sign(pa, "WK.Keys.A".representation);
        assert(verify(pa.V, ssa, "WK.Keys.A".representation));
        assert(!verify(pa.V, ssa, "WK.Keys.a".representation));

        auto pq = Pair.fromScalar(WK.Keys.Q.secret.secretKeyToCurveScalar());
        assert(pq.V == Point(WK.Keys.Q.address));
        const ssq = sign(pq, "WK.Keys.Q".representation);
        assert(verify(pq.V, ssq, "WK.Keys.Q".representation));
        assert(!verify(pq.V, ssq, "WK.Keys.q".representation));

        auto pz = Pair.fromScalar(WK.Keys.Z.secret.secretKeyToCurveScalar());
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
    (derived from the transaction and the index).
    This structure holds both the hash and the `Output` for further reference.

*******************************************************************************/

public struct OutputRef
{
    /// The `Output` being referenced
    public const Output output;

    /// The hash of the Output, to build the transaction
    public const Hash hash;
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

    public this (in PublicKey refundMe) @safe pure nothrow
    {
        this.leftover = Output(Amount(0), refundMe);
    }

    /// Ditto
    public this (const Transaction tx) @safe nothrow
    {
        this(tx.outputs[0].address);
        this.attach(tx);
    }

    /// Ditto
    public this (const Transaction tx, uint index) @safe nothrow
    {
        this(tx.outputs[index].address);
        this.attach(tx, index);
    }

    /// Convenience constructor that calls `this.attach(Output, Hash)`
    public this (in Output utxo, in Hash hash) @safe nothrow
    {
        this(utxo.address);
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
        tx.outputs.each!(outp => this.leftover.value.mustAdd(outp.value));
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

    public ref typeof(this) attach (in Output utxo, in Hash hash)
        @safe pure nothrow return
    {
        this.inputs ~= OutputRef(utxo, hash);
        this.leftover.value.mustAdd(utxo.value);
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

    // Uses a random nonce when signing (non-determenistic signature),
    // and defaults to LockType.Key
    private Unlock keyUnlocker (in Transaction tx, in OutputRef out_ref)
        @safe nothrow
    {
        auto ownerKP = WK.Keys[out_ref.output.address];
        assert(ownerKP !is KeyPair.init,
                "Address not found in Well-Known keypairs: "
                ~ out_ref.output.address.toString());

        import Schnorr = agora.common.crypto.Schnorr;
        auto pk = () @trusted { return secretKeyToCurveScalar(ownerKP.secret); }();
        Pair pair = Pair(pk, pk.toPoint());
        auto sig = Schnorr.sign(pair, tx);
        return genKeyUnlock(sig);
    }

    /***************************************************************************

        Finalize the transaction, signing the input, and reset the builder

        Params:
            type = type of `Transaction`
            data = data payload of `Transaction`
            lock_height = the transaction-level height lock
            unlock_age = the unlock age for each input in the transaction
            unlocker = optional delegate to generate the unlock script.
                If one is not provided then a LockType.Key unlock script
                is automatically generated.

        Returns:
            The finalized & signed `Transaction`.

    ***************************************************************************/

    public Transaction sign (TxType type = TxType.Payment, const(ubyte)[] data = [],
        Height lock_height = Height(0), uint unlock_age = 0,
        Unlock delegate (in Transaction tx, in OutputRef out_ref) @safe nothrow
            unlocker = null) @safe nothrow
    {
        assert(this.inputs.length, "Cannot sign input-less transaction");
        assert(this.data.outputs.length || this.leftover.value > Amount(0),
               "Output-less transactions are not valid");

        if (unlocker is null)
            unlocker = &this.keyUnlocker;
        this.data.type = type;
        this.data.lock_height = lock_height;

        // Finalize the transaction by adding inputs
        foreach (ref in_; this.inputs)
            this.data.inputs ~= Input(in_.hash, Unlock.init, unlock_age);

        // Add the refund tx, if needed
        if (this.leftover.value > Amount(0))
            this.data.outputs ~= this.leftover;

        this.data.payload = DataPayload(data);

        // Get the hash to sign
        const txHash = this.data.hashFull();
        // Sign all inputs using WK keys
        foreach (idx, ref in_; this.inputs)
            this.data.inputs[idx].unlock = unlocker(this.data, in_);

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
            KeyRange = A range of `PublicKey`
            toward = Beneficiary to split the currently available amount between

        Returns:
            Reference to `this` for easy chaining

    ***************************************************************************/

    public ref typeof(this) split (KeyRange) (scope KeyRange toward) return
    {
        static assert (isInputRange!KeyRange);
        static assert (is(ElementType!KeyRange : PublicKey));

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

    /***************************************************************************

        Takes a block object and filters the payment outputs
        into a range of `TxBuilder` objects.

        Note that the outputs may not be spendable anymore if other
        blocks have been externalized after this block.

        Params:
            block = a `Block` object

        Returns:
            A range of `TxBuilder`s which reference each Payment output of
            the input block

    ***************************************************************************/

public auto spendable (const ref Block block) @safe pure nothrow
{
    return block.txs
        .filter!(tx => tx.type == TxType.Payment)
        .map!(tx => iota(tx.outputs.length).map!(idx => TxBuilder(tx, cast(uint)idx)))
        .joiner();
}

/// Convenience function for Genesis Block unittest
public auto genesisSpendable () @safe pure nothrow
{
    return GenesisBlock.spendable;
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

/// Test with a range of tuples
unittest
{
    Output[4] outs = [
        Output(Amount(100), WK.Keys.A.address),
        Output(Amount(200), WK.Keys.B.address),
        Output(Amount(300), WK.Keys.C.address),
        Output(Amount(400), WK.Keys.D.address),
    ];

    auto tup_rng = outs[].zip(iota(outs.length).map!(_ => Hash.init));
    auto result = TxBuilder(WK.Keys.E.address).attach(tup_rng).sign();

    assert(result.inputs.length == 4);
    assert(result.outputs.length == 1);
    assert(result.outputs[0].value == Amount(1000));
}
