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
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.Test;

import agora.common.Amount;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.data.genesis.Test;
import agora.consensus.state.Ledger;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr;
import agora.script.Lock;
import agora.serialization.Serializer;
public import agora.utils.TxBuilder;
public import agora.utils.Utility : retryFor;

import std.algorithm;
import std.array;
import std.file;
import std.format;
import std.functional;
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
                private enum size_t hbound = 23 + 23 * 23 * 2 - 1;

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
            if (pubkey == NODE8.address)
                return NODE8;
            if (pubkey == NODE9.address)
                return NODE9;
            if (pubkey == NODE10.address)
                return NODE10;
            if (pubkey == NODE11.address)
                return NODE11;
            if (pubkey == NODE12.address)
                return NODE12;
            if (pubkey == NODE13.address)
                return NODE13;

            auto result = this.byRange.find!(k => k.address == pubkey);
            return result.empty ? KeyPair.init : result.front();
        }

        /// Allow one to use indexes to address the keys
        public static KeyPair opIndex (size_t idx) @safe nothrow @nogc
        {
            return wellKnownKeyByIndex(idx);
        }
    }

    public static struct PreImages
    {
        import agora.consensus.PreImage;

        private static PreImageCycle[] cycles;
        private static ulong[PublicKey] publicKeyToIndex;

        public static ref PreImageCycle opIndex (KeyPair kp)
            @safe nothrow
        {
            const uint Cycle = 20;
            if (kp.address !in publicKeyToIndex)
            {
                publicKeyToIndex[kp.address] = cycles.length;
                cycles ~= PreImageCycle(kp.secret, Cycle);
            }
            return cycles[publicKeyToIndex[kp.address]];
        }

        public static Hash[] at (Keys)(Height height, Keys key_pairs)
            @safe nothrow
        in
        {
            static assert(isInputRange!Keys);
            static assert (is(ElementType!Keys : KeyPair));
        }
        do
        {
            return key_pairs.map!(kp => opIndex(kp)[height]).array;
        }
    }
}

/// Consistency checks
unittest
{
    import std.string: representation;
    import agora.crypto.ECC;

    enum Stride = 23;

    static assert(WK.Keys[0] == WK.Keys.A);
    static assert(WK.Keys[Stride - 1] == WK.Keys.Z);
    static assert(WK.Keys[Stride] == WK.Keys.AA);
    static assert(WK.Keys[Stride + (Stride * Stride) - 1] == WK.Keys.ZZ);
    static assert(WK.Keys[Stride + (Stride * Stride)] == WK.Keys.AAA);
    static assert(WK.Keys[1080] == WK.Keys.AZZ);

    // Range interface
    static assert(WK.Keys.byRange.length == 1080);

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

    // Test for valid ECC Scalar and Point for several keys
    static void assertValidECC (KeyPair[] keys...)
    {
        foreach (keypair; keys)
        {
            assert(keypair.address.isValid(),
                   format!"WK keypair (%s, %s) should have valid Point for PublicKey"
                   (keypair.address, keypair.secret.toString(PrintMode.Clear)));
            assert(keypair.secret.isValid(),
                   format!"WK keypair (%s, %s) should have valid Scalar for Secretkey"
                   (keypair.address, keypair.secret.toString(PrintMode.Clear)));
            assert(keypair.secret.toPoint() == keypair.address,
                   format!"WK secret %s should have Point as v.G: %s"
                   (keypair.secret.toString(PrintMode.Clear), keypair.secret.toPoint()));
        }
    }

    assertValidECC(WK.Keys.Genesis,
                   WK.Keys.CommonsBudget,
                   WK.Keys.NODE2,
                   WK.Keys.NODE3,
                   WK.Keys.NODE4,
                   WK.Keys.NODE5,
                   WK.Keys.NODE6,
                   WK.Keys.NODE7,
                   WK.Keys.A,
                   WK.Keys.Q,
                   WK.Keys.ZZ);

    // Also with the Schnorr functions
    {
        auto pa = Pair.fromScalar(WK.Keys.A.secret);
        assert(pa.V == WK.Keys.A.address);
        const ssa = sign(pa, "WK.Keys.A".representation);
        assert(verify(pa.V, ssa, "WK.Keys.A".representation));
        assert(!verify(pa.V, ssa, "WK.Keys.a".representation));

        auto pq = Pair.fromScalar(WK.Keys.Q.secret);
        assert(pq.V == WK.Keys.Q.address);
        const ssq = sign(pq, "WK.Keys.Q".representation);
        assert(verify(pq.V, ssq, "WK.Keys.Q".representation));
        assert(!verify(pq.V, ssq, "WK.Keys.q".representation));

        auto pz = Pair.fromScalar(WK.Keys.Z.secret);
        assert(pz.V == WK.Keys.Z.address);
        const ssz = sign(pz, "WK.Keys.Z".representation);
        assert(verify(pz.V, ssz, "WK.Keys.Z".representation));
        assert(!verify(pz.V, ssz, "WK.Keys.z".representation));
    }

    /// Test that Genesis is found
    {
        auto genesisKP = WK.Keys.Genesis;
        assert(WK.Keys[genesisKP.address] == genesisKP);
        // Sanity check with `agora.consensus.Genesis`
        GenesisBlock.payments
            .each!(tx => tx.outputs
                .each!(output => assert(WK.Keys.Genesis.address == output.address)));
    }
}

// Check that cached cycles can handle being used with previous cycle heights
unittest
{
    auto only_node2 = only(WK.Keys.NODE2);
    Hash[] preimages_height_0 = WK.PreImages.at(Height(0), only_node2);
    Hash[] preimages_height_1 = WK.PreImages.at(Height(1), only_node2);
    // fetch from previous height within the first cycle
    assert(WK.PreImages.at(Height(0), only_node2) == preimages_height_0);
    // preimage from second cycle
    Hash[] preimages_height_21 = WK.PreImages.at(Height(21), only_node2);
    // check we can fetch preimages from previous cycle
    assert(WK.PreImages.at(Height(1), only_node2) == preimages_height_1);
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
        .filter!(tx => tx.isPayment)
        .map!(tx => iota(tx.outputs.length).map!(idx => TxBuilder(tx, cast(uint)idx)))
        .joiner();
}

/// Convenience function for Genesis Block unittest
public auto genesisSpendable () @safe pure nothrow
{
    return GenesisBlock.spendable;
}

/*******************************************************************************

    A little utility to ensure a function is only called once

    Can be used in initialization functions to ensure no double initialization,
    and will produce a readable output on error.
    Note that while this is typically used within a function, it could be
    used to ensure a branch of a function is only executed once.

    Params:
      TLS = Whether the check should be thread-local or global (default: true)
      file = The file this is called from, used for deduplication
      line = The line this is called from, used for deduplication

*******************************************************************************/

public void ensureSingleCall (
    bool TLS = true, string file = __FILE__, int line = __LINE__) ()
{
    import core.atomic;
    import std.stdio;

    static if (TLS)
        static Exception isInitialized;
    else
        __gshared Exception isInitialized;

    if (isInitialized !is null)
    {
        writeln("==================== Double call ====================");
        writeln("Source: ", file, ":", line);
        writeln("\t\t", isInitialized);
        try
            throw new Exception("Duplicated call originated from here");
        catch (Exception e)
            writeln("\t\t", e);
        assert(0);
    }

    try
        throw new Exception("Initial call originated from here");
    catch (Exception e)
        isInitialized = e;
}

/*******************************************************************************

    Given two hash, where one is potentially the pre-image of the other,
    find by how much they actually differ.

    This utility was conceived to find off-by-one errors and the likes in code,
    and should only be used for debuggging, not for testing nor production.

    Params:
      h1 = A hash that is likely to be the pre-image of `h2`
      h2 = A hash that is likely an image of `h1`

*******************************************************************************/

public string preImageJitter (in Hash h1, in Hash h2, size_t max_jitter = 1000)
    @safe nothrow
{
    scope (failure) assert(0, "Format threw");

    // Get the obvious case out of the way
    if (h1 == h2)
        return "preImageJitter: Hashes h1 and h2 are the same";

    Hash h1p = h1, h2p = h2;
    foreach (idx; 0 .. max_jitter)
    {
        h1p = h1p.hashFull();
        if (h1p == h2)
            return format("h1 (%s) was a pre-image of h2 (%s) after %d computation",
                          h1, h2, idx + 1);
    }

    foreach (idx; 0 .. max_jitter)
    {
        h2p = h2p.hashFull();
        if (h2p == h1)
            return format("h2 (%s) was a pre-image of h1 (%s) after %d computation",
                          h2, h1, idx + 1);
    }

    return "preImageJitter: Couldn't find any match";
}

///
unittest
{
    Hash h1 = "Hello World".hashFull();
    Hash h2 = h1.hashFull.hashFull();

    assert(preImageJitter(h1, h2) ==
           format("h1 (%s) was a pre-image of h2 (%s) after 2 computation", h1, h2));
    assert(preImageJitter(h2, h1) ==
           format("h2 (%s) was a pre-image of h1 (%s) after 2 computation", h1, h2));
}

/*******************************************************************************

    Externalize pre-images for all validators (minus skipped ones) at `height`

    When generating blocks in unittests, a common need is to have pre-images
    externalized so that the signatures match.

    This can be done by this function, which will call `addPreimage` for each
    currently-enrolled validator with a value suitable for height `height`.

    Params:
      ledger = The Ledger to call `addPreimage` on
      height = The desired height for the pre-images
      skip_indexes = If not empty (the default), validators that are at the
                     provided index(es) will not have their pre-images added.
                     The index can be retrieved from `getValidators`.
                     This can be used to test slashing.

*******************************************************************************/

public void simulatePreimages (Ledger ledger, in Height height,
                               uint[] skip_indexes = null) @safe
{
    ledger.getValidators(height).enumerate.each!((idx, val)
    {
        if (!skip_indexes.canFind(idx))
            ledger.addPreimage(PreImageInfo(val.preimage.utxo,
                WK.PreImages[WK.Keys[val.address]][height], height));
    });
}
