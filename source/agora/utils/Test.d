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
import agora.consensus.Genesis;

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


    Params:
        toward = address of destination to be transferred.
        prev_txs = the previous transactions to refer to
        block_count = the number of blocks that will be created if the
            returned transactions are added to the ledger
        share = amount to be distributed to one address
        use_remainder = whether to use the remaining amount after distribution.
        type = type of `Transaction`
        unknowns = unknown `KeyPair`s.
            finds in `unknowns` first. If not, finds it in 'WK'.

    Returns:
        returns the `Transaction`.

*******************************************************************************/

public Transaction[] makeChainedTransactions (TxRange) (
    scope const(PublicKey)[] toward,
    TxRange prev_txs_range,
    scope const size_t block_count,
    scope const Amount share = Amount.MinFreezeAmount,
    TxType type = TxType.Payment) @safe
    if (isInputRange!(TxRange))
{
    import agora.consensus.data.Block;

    // https://issues.dlang.org/show_bug.cgi?id=20937
    const(Transaction)[] prev_txs = () @trusted { return prev_txs_range.array; }();

    // The number of prev_txs must be greater than zero and
    // less than or equal to Block.TxsInBlock.
    assert((prev_txs.length > 0) && (prev_txs.length <= Block.TxsInBlock));

    // If the number of prev_txs is less than Block.TxsInBlock,
    // then the number of all outputs are must be greater than or equal to Block.TxsInBlock.
    assert(
        (prev_txs.length == Block.TxsInBlock) ||
        (
            (prev_txs.length < Block.TxsInBlock) &&
            (prev_txs.map!(tx => tx.outputs.length).sum() >= Block.TxsInBlock)
        )
    );

    Transaction[] transactions;

    if (prev_txs.length == Block.TxsInBlock)
    {
        foreach (block_idx; 0 .. block_count)
        {
            foreach (tx_idx; 0 .. Block.TxsInBlock)
            {
                transactions ~= TxBuilder(
                    (block_idx == 0)
                        ? prev_txs[tx_idx]
                        : transactions[(block_idx - 1) * Block.TxsInBlock + tx_idx]
                    )
                    .draw(share, toward)
                    .sign(type);
            }
        }
    }
    else
    {
        TxBuilder[] builders;
        foreach (block_idx; 0 .. block_count)
        {
            uint[] offsets = new uint[](Block.TxsInBlock);

            int getAvableIndex (uint last)
            {
                foreach_reverse (idx; 0 .. last+1)
                    if ((idx < prev_txs.length) && (offsets[idx] < prev_txs[idx].outputs.length))
                        return idx;
                return -1;
            }

            // attach
            uint loop = 0;
            while (true)
            {
                auto tx_idx = loop++ % Block.TxsInBlock;
                auto avable_idx = getAvableIndex(tx_idx);

                if (avable_idx < 0)
                    break;

                if (builders.length <= tx_idx)
                    builders ~= TxBuilder(prev_txs[avable_idx], offsets[avable_idx]);
                else
                    builders[tx_idx].attach(prev_txs[avable_idx], offsets[avable_idx]);
                offsets[avable_idx]++;
            }

            assert(builders.length == Block.TxsInBlock);
            builders.each!(b => transactions ~= b.split(toward).sign(type));
            builders = null;

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
    import agora.consensus.Genesis;

    auto gen_key = WK.Keys.Genesis;

    /// should spend genesis block's outputs
    auto txes = makeChainedTransactions([WK.Keys.A.address],
        genesisSpendable(), 1);
    foreach (idx; 0 .. Block.TxsInBlock)
    {
        assert(txes[idx].inputs.length == 1);
        assert(txes[idx].inputs[0].index == idx);
        assert(txes[idx].inputs[0].previous == hashFull(GenesisBlock.txs[0]));
    }

    auto prev_txs = txes;
    // should spend the previous tx'es outputs
    txes = makeChainedTransactions([WK.Keys.A.address], txes, 1);

    foreach (idx; 0 .. Block.TxsInBlock)
    {
        assert(txes[idx].inputs.length == 1);
        assert(txes[idx].inputs[0].index == 0);  // always refers to only output in tx
        assert(txes[idx].inputs[0].previous == hashFull(prev_txs[idx]));
    }

    const share = Amount(20_000_000);
    txes = makeChainedTransactions([WK.Keys.A.address], prev_txs, 1, share);

    foreach (idx; 0 .. Block.TxsInBlock)
    {
        assert(txes[idx].inputs.length == 1);
        assert(txes[idx].inputs[0].index == 0);
        assert(txes[idx].inputs[0].previous == hashFull(prev_txs[idx]));
        assert(txes[idx].outputs[0].value == share);
    }
}

/// example of chaining
unittest
{
    import agora.consensus.data.Block;
    import agora.consensus.Genesis;

    auto gen_key = WK.Keys.Genesis;
    const(Transaction)[] txes = makeChainedTransactions([gen_key.address],
        genesisSpendable(), 1);
    txes = makeChainedTransactions([gen_key.address], txes, 1);
}

/// custom genesis tx
unittest
{
    import std.exception : assumeUnique;
    import core.thread;
    import agora.common.BitField;
    import agora.consensus.data.Block;
    import agora.consensus.Genesis;

    auto key_pair = WK.Keys.G;

    Transaction GenTx =
    {
        TxType.Payment,
        outputs: [
            Output(Amount(62_500_000L * 10_000_000L), key_pair.address),
            Output(Amount(62_500_000L * 10_000_000L), key_pair.address),
            Output(Amount(62_500_000L * 10_000_000L), key_pair.address),
            Output(Amount(62_500_000L * 10_000_000L), key_pair.address),
            Output(Amount(62_500_000L * 10_000_000L), key_pair.address),
            Output(Amount(62_500_000L * 10_000_000L), key_pair.address),
            Output(Amount(62_500_000L * 10_000_000L), key_pair.address),
            Output(Amount(62_500_000L * 10_000_000L), key_pair.address),
        ],
    };

    Transaction[] txs = [GenTx];
    Hash[] merkle_tree;
    auto merkle_root = Block.buildMerkleTree(txs, merkle_tree);

    immutable(BlockHeader) makeHeader ()
    {
        return immutable(BlockHeader)(
            Hash.init,   // prev
            Height(0),   // height
            merkle_root,
            BitField!uint.init,
            Signature.init,
            null,        // enrollments
        );
    }

    auto genesis_block = immutable(Block)(
        makeHeader(),
        txs.assumeUnique,
        merkle_tree.assumeUnique
    );

    auto txes = makeChainedTransactions([key_pair.address],
        [GenTx], 1, Amount.MinFreezeAmount);
    foreach (idx; 0 .. Block.TxsInBlock)
    {
        assert(txes[idx].inputs.length == 1);
        assert(txes[idx].inputs[0].index == idx);
        assert(txes[idx].inputs[0].previous == hashFull(genesis_block.txs[0]));
    }
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
        /// This struct is used as a namespace only
        @disable public this ();

        /// Provides a range interface to keys
        public static auto byRange ()
        {
            static struct Range
            {
                nothrow @nogc @safe:

                private size_t lbound = 0;
                private size_t hbound = 26;

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

            auto result = this.byRange.find!(k => k.address == pubkey);
            return result.empty ? KeyPair.init : result.front();
        }

        /// Given a keypair, return a name
        public static string opIndex (const KeyPair kp) @safe nothrow @nogc
        {
            if (auto name = kp in nameMap)
                return *name;
            return "Key.NONAME";
        }

        /// Allow one to use indexes to address the keys
        public static KeyPair opIndex (size_t idx) @safe nothrow @nogc
        {
            switch (idx)
            {
                static foreach (char c; 'A' .. 'Z' + 1)
                {
                case (c - 'A'):
                    return mixin(c);
                }
            default:
                assert(0, "There are only 26 well-known keys");
            }
        }

        static immutable string[immutable KeyPair] nameMap;
        shared static this ()
        {
            static foreach (char c; 'A' .. 'Z' + 1)
                mixin(`nameMap[`, c, `] = "WK.Keys.`, c, `";`);
            nameMap[Genesis] = "WK.Keys.Genesis";
        }

        /***********************************************************************

            Genesis KeyPair used in unittests

            In unittests, we need the genesis key pair to be known for us to be
            able to write tests. Hence the genesis block has a different value.

            Note that while this is a well-known keys, it is not part of the
            range returned by `byRange`, nor can it be indexed by `size_t`,
            to avoid it being mistakenly used.
            It is however accessible via `opIndex(PublicKey)`.

            Seed:    SCT4KKJNYLTQO4TVDPVJQZEONTVVW66YLRWAINWI3FZDY7U4JS4JJEI4
            Address: GCOQEOHAUFYUAC6G22FJ3GZRNLGVCCLESEJ2AXBIJ5BJNUVTAERPLRIJ


        ***********************************************************************/

        static immutable Genesis = KeyPair(
            PublicKey([157, 2, 56, 224, 161, 113, 64, 11, 198, 214, 138, 157, 155, 49, 106, 205, 81, 9, 100, 145, 19, 160, 92, 40, 79, 66, 150, 210, 179, 1, 34, 245]),
            SecretKey([167, 197, 41, 45, 194, 231, 7, 114, 117, 27, 234, 152, 100, 142, 108, 235, 91, 123, 216, 92, 108, 4, 54, 200, 217, 114, 60, 126, 156, 76, 184, 148, 157, 2, 56, 224, 161, 113, 64, 11, 198, 214, 138, 157, 155, 49, 106, 205, 81, 9, 100, 145, 19, 160, 92, 40, 79, 66, 150, 210, 179, 1, 34, 245]),
            Seed([167, 197, 41, 45, 194, 231, 7, 114, 117, 27, 234, 152, 100, 142, 108, 235, 91, 123, 216, 92, 108, 4, 54, 200, 217, 114, 60, 126, 156, 76, 184, 148]));


        /***********************************************************************

            All well-known keypairs

        ***********************************************************************/

        static immutable A = KeyPair(
            PublicKey([1, 163, 253, 17, 225, 20, 105, 206, 20, 194, 40, 152, 72, 132, 1, 148, 242, 87, 153, 89, 117, 13, 42, 214, 254, 174, 138, 226, 224, 81, 226, 130]),
            SecretKey([170, 236, 61, 133, 133, 159, 190, 231, 28, 51, 201, 146, 134, 37, 236, 18, 64, 212, 245, 228, 10, 116, 186, 238, 235, 103, 193, 3, 16, 143, 251, 10, 1, 163, 253, 17, 225, 20, 105, 206, 20, 194, 40, 152, 72, 132, 1, 148, 242, 87, 153, 89, 117, 13, 42, 214, 254, 174, 138, 226, 224, 81, 226, 130]),
            Seed([170, 236, 61, 133, 133, 159, 190, 231, 28, 51, 201, 146, 134, 37, 236, 18, 64, 212, 245, 228, 10, 116, 186, 238, 235, 103, 193, 3, 16, 143, 251, 10]));
        static immutable B = KeyPair(
            PublicKey([3, 172, 166, 195, 204, 86, 25, 28, 235, 194, 121, 24, 179, 99, 140, 131, 39, 179, 156, 108, 223, 5, 59, 147, 244, 104, 50, 12, 160, 29, 57, 198]),
            SecretKey([200, 40, 12, 158, 3, 177, 77, 236, 234, 215, 167, 88, 202, 104, 127, 222, 166, 4, 57, 119, 203, 174, 124, 247, 205, 211, 244, 196, 1, 94, 237, 235, 3, 172, 166, 195, 204, 86, 25, 28, 235, 194, 121, 24, 179, 99, 140, 131, 39, 179, 156, 108, 223, 5, 59, 147, 244, 104, 50, 12, 160, 29, 57, 198]),
            Seed([200, 40, 12, 158, 3, 177, 77, 236, 234, 215, 167, 88, 202, 104, 127, 222, 166, 4, 57, 119, 203, 174, 124, 247, 205, 211, 244, 196, 1, 94, 237, 235]));
        static immutable C = KeyPair(
            PublicKey([5, 175, 178, 142, 150, 86, 29, 102, 78, 89, 245, 145, 2, 246, 46, 181, 211, 164, 83, 94, 88, 10, 117, 124, 142, 134, 251, 148, 214, 170, 96, 165]),
            SecretKey([206, 112, 105, 235, 195, 63, 94, 63, 207, 254, 202, 4, 237, 106, 107, 126, 192, 11, 250, 74, 153, 30, 112, 115, 97, 115, 226, 149, 224, 85, 217, 43, 5, 175, 178, 142, 150, 86, 29, 102, 78, 89, 245, 145, 2, 246, 46, 181, 211, 164, 83, 94, 88, 10, 117, 124, 142, 134, 251, 148, 214, 170, 96, 165]),
            Seed([206, 112, 105, 235, 195, 63, 94, 63, 207, 254, 202, 4, 237, 106, 107, 126, 192, 11, 250, 74, 153, 30, 112, 115, 97, 115, 226, 149, 224, 85, 217, 43]));
        static immutable D = KeyPair(
            PublicKey([7, 172, 214, 250, 65, 165, 5, 77, 253, 63, 81, 50, 49, 84, 152, 99, 123, 156, 39, 142, 101, 46, 146, 106, 11, 227, 98, 36, 161, 186, 233, 16]),
            SecretKey([38, 240, 114, 199, 55, 117, 22, 52, 93, 117, 181, 79, 85, 241, 193, 75, 202, 254, 146, 150, 155, 181, 232, 53, 20, 29, 95, 128, 19, 69, 59, 100, 7, 172, 214, 250, 65, 165, 5, 77, 253, 63, 81, 50, 49, 84, 152, 99, 123, 156, 39, 142, 101, 46, 146, 106, 11, 227, 98, 36, 161, 186, 233, 16]),
            Seed([38, 240, 114, 199, 55, 117, 22, 52, 93, 117, 181, 79, 85, 241, 193, 75, 202, 254, 146, 150, 155, 181, 232, 53, 20, 29, 95, 128, 19, 69, 59, 100]));
        static immutable E = KeyPair(
            PublicKey([9, 172, 245, 103, 77, 146, 252, 108, 37, 2, 19, 46, 201, 105, 93, 151, 188, 155, 220, 246, 125, 93, 136, 97, 75, 91, 107, 176, 107, 158, 25, 209]),
            SecretKey([225, 118, 38, 158, 43, 1, 148, 154, 183, 154, 255, 113, 4, 140, 254, 255, 185, 187, 63, 225, 62, 216, 241, 110, 15, 234, 9, 198, 168, 144, 30, 27, 9, 172, 245, 103, 77, 146, 252, 108, 37, 2, 19, 46, 201, 105, 93, 151, 188, 155, 220, 246, 125, 93, 136, 97, 75, 91, 107, 176, 107, 158, 25, 209]),
            Seed([225, 118, 38, 158, 43, 1, 148, 154, 183, 154, 255, 113, 4, 140, 254, 255, 185, 187, 63, 225, 62, 216, 241, 110, 15, 234, 9, 198, 168, 144, 30, 27]));
        static immutable F = KeyPair(
            PublicKey([11, 166, 243, 151, 127, 4, 174, 224, 92, 103, 187, 130, 89, 217, 219, 195, 138, 237, 62, 146, 205, 80, 179, 161, 95, 70, 62, 59, 219, 67, 128, 223]),
            SecretKey([181, 164, 94, 86, 173, 162, 182, 45, 48, 214, 12, 150, 157, 169, 31, 20, 30, 70, 170, 55, 174, 186, 133, 199, 129, 99, 31, 38, 119, 107, 190, 167, 11, 166, 243, 151, 127, 4, 174, 224, 92, 103, 187, 130, 89, 217, 219, 195, 138, 237, 62, 146, 205, 80, 179, 161, 95, 70, 62, 59, 219, 67, 128, 223]),
            Seed([181, 164, 94, 86, 173, 162, 182, 45, 48, 214, 12, 150, 157, 169, 31, 20, 30, 70, 170, 55, 174, 186, 133, 199, 129, 99, 31, 38, 119, 107, 190, 167]));
        static immutable G = KeyPair(
            PublicKey([13, 175, 172, 135, 218, 27, 211, 94, 215, 221, 13, 40, 131, 113, 133, 107, 177, 199, 6, 124, 1, 116, 78, 52, 14, 249, 244, 202, 51, 137, 102, 35]),
            SecretKey([0, 18, 247, 112, 218, 14, 103, 104, 255, 142, 73, 118, 182, 9, 47, 144, 109, 95, 251, 43, 173, 9, 196, 17, 55, 179, 81, 207, 30, 60, 126, 233, 13, 175, 172, 135, 218, 27, 211, 94, 215, 221, 13, 40, 131, 113, 133, 107, 177, 199, 6, 124, 1, 116, 78, 52, 14, 249, 244, 202, 51, 137, 102, 35]),
            Seed([0, 18, 247, 112, 218, 14, 103, 104, 255, 142, 73, 118, 182, 9, 47, 144, 109, 95, 251, 43, 173, 9, 196, 17, 55, 179, 81, 207, 30, 60, 126, 233]));
        static immutable H = KeyPair(
            PublicKey([15, 165, 207, 237, 134, 82, 62, 248, 178, 113, 40, 29, 237, 8, 66, 204, 161, 192, 195, 253, 109, 137, 109, 138, 27, 207, 214, 89, 198, 199, 72, 55]),
            SecretKey([17, 11, 184, 26, 70, 225, 169, 18, 123, 101, 84, 190, 246, 175, 130, 232, 220, 239, 118, 22, 250, 25, 216, 109, 73, 91, 119, 226, 190, 112, 174, 190, 15, 165, 207, 237, 134, 82, 62, 248, 178, 113, 40, 29, 237, 8, 66, 204, 161, 192, 195, 253, 109, 137, 109, 138, 27, 207, 214, 89, 198, 199, 72, 55]),
            Seed([17, 11, 184, 26, 70, 225, 169, 18, 123, 101, 84, 190, 246, 175, 130, 232, 220, 239, 118, 22, 250, 25, 216, 109, 73, 91, 119, 226, 190, 112, 174, 190]));
        static immutable I = KeyPair(
            PublicKey([17, 170, 42, 253, 128, 13, 160, 100, 147, 200, 9, 109, 247, 148, 197, 40, 154, 232, 35, 173, 224, 23, 125, 164, 77, 213, 93, 211, 243, 139, 140, 132]),
            SecretKey([78, 80, 17, 115, 104, 60, 167, 205, 87, 156, 228, 164, 155, 82, 86, 44, 250, 83, 198, 177, 148, 99, 251, 217, 221, 0, 186, 240, 130, 85, 73, 113, 17, 170, 42, 253, 128, 13, 160, 100, 147, 200, 9, 109, 247, 148, 197, 40, 154, 232, 35, 173, 224, 23, 125, 164, 77, 213, 93, 211, 243, 139, 140, 132]),
            Seed([78, 80, 17, 115, 104, 60, 167, 205, 87, 156, 228, 164, 155, 82, 86, 44, 250, 83, 198, 177, 148, 99, 251, 217, 221, 0, 186, 240, 130, 85, 73, 113]));
        static immutable J = KeyPair(
            PublicKey([19, 163, 64, 24, 65, 168, 217, 229, 166, 99, 121, 146, 221, 16, 78, 219, 91, 52, 133, 48, 38, 65, 233, 25, 119, 59, 249, 159, 140, 209, 203, 63]),
            SecretKey([138, 31, 194, 65, 4, 142, 0, 14, 13, 10, 68, 254, 150, 75, 76, 11, 238, 146, 29, 222, 29, 71, 56, 13, 53, 239, 87, 213, 37, 213, 144, 80, 19, 163, 64, 24, 65, 168, 217, 229, 166, 99, 121, 146, 221, 16, 78, 219, 91, 52, 133, 48, 38, 65, 233, 25, 119, 59, 249, 159, 140, 209, 203, 63]),
            Seed([138, 31, 194, 65, 4, 142, 0, 14, 13, 10, 68, 254, 150, 75, 76, 11, 238, 146, 29, 222, 29, 71, 56, 13, 53, 239, 87, 213, 37, 213, 144, 80]));
        static immutable K = KeyPair(
            PublicKey([21, 171, 155, 173, 153, 125, 161, 215, 103, 255, 141, 199, 172, 238, 86, 196, 114, 161, 253, 59, 170, 129, 227, 22, 16, 36, 145, 217, 216, 28, 86, 184]),
            SecretKey([134, 231, 201, 23, 14, 246, 15, 68, 126, 221, 239, 247, 33, 59, 53, 129, 48, 98, 242, 113, 6, 44, 199, 175, 223, 44, 121, 139, 127, 59, 5, 201, 21, 171, 155, 173, 153, 125, 161, 215, 103, 255, 141, 199, 172, 238, 86, 196, 114, 161, 253, 59, 170, 129, 227, 22, 16, 36, 145, 217, 216, 28, 86, 184]),
            Seed([134, 231, 201, 23, 14, 246, 15, 68, 126, 221, 239, 247, 33, 59, 53, 129, 48, 98, 242, 113, 6, 44, 199, 175, 223, 44, 121, 139, 127, 59, 5, 201]));
        static immutable L = KeyPair(
            PublicKey([23, 160, 157, 1, 136, 32, 112, 40, 248, 6, 85, 37, 42, 106, 28, 55, 240, 160, 210, 51, 105, 60, 57, 15, 149, 114, 66, 64, 95, 30, 30, 220]),
            SecretKey([225, 81, 247, 192, 246, 166, 190, 254, 166, 109, 57, 45, 219, 212, 139, 63, 94, 162, 64, 54, 221, 68, 15, 120, 34, 231, 191, 170, 54, 169, 228, 226, 23, 160, 157, 1, 136, 32, 112, 40, 248, 6, 85, 37, 42, 106, 28, 55, 240, 160, 210, 51, 105, 60, 57, 15, 149, 114, 66, 64, 95, 30, 30, 220]),
            Seed([225, 81, 247, 192, 246, 166, 190, 254, 166, 109, 57, 45, 219, 212, 139, 63, 94, 162, 64, 54, 221, 68, 15, 120, 34, 231, 191, 170, 54, 169, 228, 226]));
        static immutable M = KeyPair(
            PublicKey([25, 172, 203, 53, 94, 75, 19, 111, 253, 178, 133, 110, 189, 106, 112, 74, 235, 120, 224, 83, 5, 230, 108, 230, 107, 255, 250, 0, 230, 213, 162, 23]),
            SecretKey([205, 7, 187, 220, 156, 133, 173, 76, 166, 45, 114, 164, 123, 2, 194, 89, 93, 210, 63, 249, 35, 103, 75, 189, 92, 184, 209, 65, 134, 65, 23, 61, 25, 172, 203, 53, 94, 75, 19, 111, 253, 178, 133, 110, 189, 106, 112, 74, 235, 120, 224, 83, 5, 230, 108, 230, 107, 255, 250, 0, 230, 213, 162, 23]),
            Seed([205, 7, 187, 220, 156, 133, 173, 76, 166, 45, 114, 164, 123, 2, 194, 89, 93, 210, 63, 249, 35, 103, 75, 189, 92, 184, 209, 65, 134, 65, 23, 61]));
        static immutable N = KeyPair(
            PublicKey([27, 171, 255, 100, 130, 238, 110, 32, 48, 252, 253, 112, 103, 104, 169, 36, 108, 236, 232, 124, 115, 197, 213, 154, 40, 227, 232, 41, 59, 244, 215, 181]),
            SecretKey([227, 204, 232, 142, 237, 85, 225, 218, 75, 99, 160, 1, 15, 22, 65, 203, 82, 80, 140, 48, 137, 75, 103, 28, 179, 144, 152, 213, 195, 195, 92, 220, 27, 171, 255, 100, 130, 238, 110, 32, 48, 252, 253, 112, 103, 104, 169, 36, 108, 236, 232, 124, 115, 197, 213, 154, 40, 227, 232, 41, 59, 244, 215, 181]),
            Seed([227, 204, 232, 142, 237, 85, 225, 218, 75, 99, 160, 1, 15, 22, 65, 203, 82, 80, 140, 48, 137, 75, 103, 28, 179, 144, 152, 213, 195, 195, 92, 220]));
        static immutable O = KeyPair(
            PublicKey([29, 173, 40, 7, 141, 90, 39, 145, 84, 130, 13, 209, 154, 134, 107, 40, 103, 209, 34, 177, 159, 234, 61, 237, 169, 118, 91, 222, 230, 152, 210, 124]),
            SecretKey([137, 151, 235, 177, 220, 243, 46, 228, 90, 138, 34, 167, 93, 128, 198, 82, 240, 134, 92, 175, 129, 133, 92, 56, 116, 74, 216, 22, 238, 97, 218, 150, 29, 173, 40, 7, 141, 90, 39, 145, 84, 130, 13, 209, 154, 134, 107, 40, 103, 209, 34, 177, 159, 234, 61, 237, 169, 118, 91, 222, 230, 152, 210, 124]),
            Seed([137, 151, 235, 177, 220, 243, 46, 228, 90, 138, 34, 167, 93, 128, 198, 82, 240, 134, 92, 175, 129, 133, 92, 56, 116, 74, 216, 22, 238, 97, 218, 150]));
        static immutable P = KeyPair(
            PublicKey([31, 174, 237, 180, 233, 51, 161, 160, 25, 139, 248, 189, 229, 31, 188, 201, 42, 253, 91, 4, 52, 219, 201, 23, 197, 90, 82, 149, 139, 38, 150, 240]),
            SecretKey([180, 82, 21, 12, 226, 42, 213, 252, 192, 86, 236, 233, 142, 1, 133, 139, 105, 102, 41, 240, 1, 139, 59, 234, 219, 229, 159, 37, 122, 144, 142, 247, 31, 174, 237, 180, 233, 51, 161, 160, 25, 139, 248, 189, 229, 31, 188, 201, 42, 253, 91, 4, 52, 219, 201, 23, 197, 90, 82, 149, 139, 38, 150, 240]),
            Seed([180, 82, 21, 12, 226, 42, 213, 252, 192, 86, 236, 233, 142, 1, 133, 139, 105, 102, 41, 240, 1, 139, 59, 234, 219, 229, 159, 37, 122, 144, 142, 247]));
        static immutable Q = KeyPair(
            PublicKey([33, 167, 183, 189, 171, 70, 236, 30, 241, 36, 47, 13, 193, 198, 12, 112, 134, 20, 73, 187, 166, 51, 130, 208, 8, 119, 173, 248, 46, 50, 100, 126]),
            SecretKey([95, 213, 207, 132, 98, 217, 15, 205, 216, 220, 134, 126, 231, 80, 54, 37, 131, 181, 38, 196, 7, 15, 187, 43, 232, 65, 159, 41, 4, 51, 197, 243, 33, 167, 183, 189, 171, 70, 236, 30, 241, 36, 47, 13, 193, 198, 12, 112, 134, 20, 73, 187, 166, 51, 130, 208, 8, 119, 173, 248, 46, 50, 100, 126]),
            Seed([95, 213, 207, 132, 98, 217, 15, 205, 216, 220, 134, 126, 231, 80, 54, 37, 131, 181, 38, 196, 7, 15, 187, 43, 232, 65, 159, 41, 4, 51, 197, 243]));
        static immutable R = KeyPair(
            PublicKey([35, 169, 193, 234, 255, 154, 5, 59, 114, 86, 119, 183, 157, 192, 192, 27, 15, 86, 254, 67, 53, 110, 107, 57, 172, 89, 41, 59, 157, 135, 228, 60]),
            SecretKey([166, 73, 151, 31, 196, 89, 88, 35, 29, 76, 67, 98, 234, 245, 71, 199, 85, 157, 242, 114, 92, 180, 22, 235, 214, 141, 192, 101, 192, 108, 245, 156, 35, 169, 193, 234, 255, 154, 5, 59, 114, 86, 119, 183, 157, 192, 192, 27, 15, 86, 254, 67, 53, 110, 107, 57, 172, 89, 41, 59, 157, 135, 228, 60]),
            Seed([166, 73, 151, 31, 196, 89, 88, 35, 29, 76, 67, 98, 234, 245, 71, 199, 85, 157, 242, 114, 92, 180, 22, 235, 214, 141, 192, 101, 192, 108, 245, 156]));
        static immutable S = KeyPair(
            PublicKey([37, 167, 173, 162, 23, 88, 224, 159, 86, 160, 97, 13, 95, 115, 127, 148, 215, 76, 9, 64, 161, 151, 218, 65, 163, 11, 209, 16, 124, 101, 81, 161]),
            SecretKey([98, 113, 20, 85, 149, 75, 111, 124, 48, 117, 161, 81, 240, 100, 120, 34, 161, 84, 185, 192, 209, 215, 112, 236, 115, 162, 39, 176, 219, 27, 133, 227, 37, 167, 173, 162, 23, 88, 224, 159, 86, 160, 97, 13, 95, 115, 127, 148, 215, 76, 9, 64, 161, 151, 218, 65, 163, 11, 209, 16, 124, 101, 81, 161]),
            Seed([98, 113, 20, 85, 149, 75, 111, 124, 48, 117, 161, 81, 240, 100, 120, 34, 161, 84, 185, 192, 209, 215, 112, 236, 115, 162, 39, 176, 219, 27, 133, 227]));
        static immutable T = KeyPair(
            PublicKey([39, 173, 3, 210, 221, 41, 83, 253, 40, 11, 90, 243, 206, 21, 68, 208, 128, 14, 128, 41, 172, 106, 252, 82, 229, 22, 21, 35, 91, 99, 188, 35]),
            SecretKey([145, 227, 188, 254, 118, 73, 190, 1, 77, 212, 122, 37, 148, 136, 57, 104, 27, 117, 20, 46, 137, 190, 60, 227, 76, 38, 146, 39, 35, 164, 250, 192, 39, 173, 3, 210, 221, 41, 83, 253, 40, 11, 90, 243, 206, 21, 68, 208, 128, 14, 128, 41, 172, 106, 252, 82, 229, 22, 21, 35, 91, 99, 188, 35]),
            Seed([145, 227, 188, 254, 118, 73, 190, 1, 77, 212, 122, 37, 148, 136, 57, 104, 27, 117, 20, 46, 137, 190, 60, 227, 76, 38, 146, 39, 35, 164, 250, 192]));
        static immutable U = KeyPair(
            PublicKey([41, 172, 122, 40, 82, 135, 95, 195, 219, 102, 160, 171, 134, 9, 197, 119, 197, 197, 54, 147, 224, 83, 61, 240, 240, 175, 219, 25, 230, 199, 32, 83]),
            SecretKey([61, 141, 89, 237, 26, 185, 24, 179, 169, 138, 184, 184, 234, 198, 75, 161, 56, 84, 62, 83, 100, 70, 253, 21, 186, 188, 144, 123, 219, 102, 93, 255, 41, 172, 122, 40, 82, 135, 95, 195, 219, 102, 160, 171, 134, 9, 197, 119, 197, 197, 54, 147, 224, 83, 61, 240, 240, 175, 219, 25, 230, 199, 32, 83]),
            Seed([61, 141, 89, 237, 26, 185, 24, 179, 169, 138, 184, 184, 234, 198, 75, 161, 56, 84, 62, 83, 100, 70, 253, 21, 186, 188, 144, 123, 219, 102, 93, 255]));
        static immutable V = KeyPair(
            PublicKey([43, 170, 200, 149, 196, 230, 74, 22, 192, 44, 184, 238, 141, 245, 245, 209, 164, 45, 142, 182, 96, 230, 75, 87, 7, 15, 110, 8, 149, 119, 124, 209]),
            SecretKey([9, 89, 83, 87, 233, 46, 223, 53, 182, 86, 129, 142, 80, 215, 82, 213, 142, 50, 84, 52, 154, 137, 166, 96, 202, 16, 173, 55, 120, 114, 104, 240, 43, 170, 200, 149, 196, 230, 74, 22, 192, 44, 184, 238, 141, 245, 245, 209, 164, 45, 142, 182, 96, 230, 75, 87, 7, 15, 110, 8, 149, 119, 124, 209]),
            Seed([9, 89, 83, 87, 233, 46, 223, 53, 182, 86, 129, 142, 80, 215, 82, 213, 142, 50, 84, 52, 154, 137, 166, 96, 202, 16, 173, 55, 120, 114, 104, 240]));
        static immutable W = KeyPair(
            PublicKey([45, 174, 8, 157, 15, 102, 141, 149, 4, 74, 112, 7, 191, 68, 68, 140, 57, 229, 114, 91, 34, 149, 37, 254, 224, 54, 141, 231, 46, 176, 243, 46]),
            SecretKey([58, 158, 102, 182, 77, 155, 91, 79, 35, 70, 139, 238, 106, 199, 96, 28, 107, 204, 167, 182, 51, 166, 184, 202, 21, 201, 192, 140, 78, 150, 126, 45, 45, 174, 8, 157, 15, 102, 141, 149, 4, 74, 112, 7, 191, 68, 68, 140, 57, 229, 114, 91, 34, 149, 37, 254, 224, 54, 141, 231, 46, 176, 243, 46]),
            Seed([58, 158, 102, 182, 77, 155, 91, 79, 35, 70, 139, 238, 106, 199, 96, 28, 107, 204, 167, 182, 51, 166, 184, 202, 21, 201, 192, 140, 78, 150, 126, 45]));
        static immutable X = KeyPair(
            PublicKey([47, 169, 193, 230, 87, 215, 19, 206, 13, 40, 52, 64, 141, 70, 89, 225, 195, 22, 206, 153, 195, 78, 122, 46, 216, 255, 17, 63, 160, 90, 2, 176]),
            SecretKey([130, 11, 231, 41, 24, 62, 67, 165, 232, 188, 144, 20, 154, 27, 208, 239, 130, 169, 235, 54, 148, 230, 155, 207, 87, 48, 204, 114, 144, 91, 245, 88, 47, 169, 193, 230, 87, 215, 19, 206, 13, 40, 52, 64, 141, 70, 89, 225, 195, 22, 206, 153, 195, 78, 122, 46, 216, 255, 17, 63, 160, 90, 2, 176]),
            Seed([130, 11, 231, 41, 24, 62, 67, 165, 232, 188, 144, 20, 154, 27, 208, 239, 130, 169, 235, 54, 148, 230, 155, 207, 87, 48, 204, 114, 144, 91, 245, 88]));
        static immutable Y = KeyPair(
            PublicKey([49, 169, 14, 77, 77, 152, 159, 177, 120, 130, 224, 30, 67, 70, 27, 88, 38, 230, 171, 161, 76, 233, 119, 95, 46, 186, 48, 75, 130, 51, 49, 121]),
            SecretKey([234, 172, 224, 221, 152, 224, 1, 88, 53, 171, 161, 242, 240, 158, 113, 0, 80, 100, 33, 8, 210, 67, 190, 164, 146, 97, 126, 207, 151, 211, 226, 178, 49, 169, 14, 77, 77, 152, 159, 177, 120, 130, 224, 30, 67, 70, 27, 88, 38, 230, 171, 161, 76, 233, 119, 95, 46, 186, 48, 75, 130, 51, 49, 121]),
            Seed([234, 172, 224, 221, 152, 224, 1, 88, 53, 171, 161, 242, 240, 158, 113, 0, 80, 100, 33, 8, 210, 67, 190, 164, 146, 97, 126, 207, 151, 211, 226, 178]));
        static immutable Z = KeyPair(
            PublicKey([51, 164, 176, 208, 41, 194, 54, 100, 117, 27, 62, 181, 147, 117, 202, 86, 11, 172, 24, 197, 191, 26, 171, 79, 107, 212, 224, 0, 65, 133, 64, 147]),
            SecretKey([74, 77, 172, 53, 11, 228, 71, 106, 164, 11, 70, 212, 207, 242, 201, 199, 225, 255, 226, 255, 109, 169, 39, 109, 189, 241, 103, 219, 52, 24, 10, 206, 51, 164, 176, 208, 41, 194, 54, 100, 117, 27, 62, 181, 147, 117, 202, 86, 11, 172, 24, 197, 191, 26, 171, 79, 107, 212, 224, 0, 65, 133, 64, 147]),
            Seed([74, 77, 172, 53, 11, 228, 71, 106, 164, 11, 70, 212, 207, 242, 201, 199, 225, 255, 226, 255, 109, 169, 39, 109, 189, 241, 103, 219, 52, 24, 10, 206]));
    }
}

/// Generate all the well-kwnon values, disabled but kept here for documentation
/// Note that we generate the binary data directly to limit CTFE overhead
version (none) unittest
{
    import std.stdio;

    Seed[size_t] kps;
    string name = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"; // Writefln is picky
    while (kps.length < 26)
    {
        auto tmp = KeyPair.random();
        const addr = tmp.address.toString();
        /* Addresses always start with G{A,B,C,D}
         * We pick the addresses that start with GA, then match our expected
         * char, and are followed by a `2`, so that we have an 'end marker'
         * in case we want more letters (e.g. AA or AAA).
         */

        // Check start
        if (addr[1] != 'A')
            continue;
        // Find match for letter(s)
        if (addr[2] < 'A' || addr[2] > 'Z')
            continue;
        // Check last character(s)
        if (addr[3] != '2')
            continue;
        if (addr[4] != '2')
            continue;

        // It's a match
        kps[addr[2] - 'A'] = tmp.seed;
    }

    writeln("==================== Well known KeyPair ====================");
    foreach (idx, ref seed; kps)
    {
        auto kp = KeyPair.fromSeed(seed);
        writefln("static immutable %c = KeyPair(PublicKey(%s), SecretKey(%s), Seed(%s));",
                 name[idx], kp.address[], kp.secret[], kp.seed[]);
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

    // Range interface
    static assert(WK.Keys.byRange.count() == 26);

    // Key from index
    static assert(WK.Keys[WK.Keys.A.address] == WK.Keys.A);
    static assert(WK.Keys[WK.Keys.Q.address] == WK.Keys.Q);
    static assert(WK.Keys[WK.Keys.Z.address] == WK.Keys.Z);

    // Not accessible at CT
    assert(WK.Keys[WK.Keys.A] == "WK.Keys.A");
    assert(WK.Keys[WK.Keys.Q] == "WK.Keys.Q");
    assert(WK.Keys[WK.Keys.Z] == "WK.Keys.Z");

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
        assert(WK.Keys[genesisKP] == "WK.Keys.Genesis");
        assert(WK.Keys[genesisKP.address] == genesisKP);
        // Sanity check with `agora.consensus.Genesis`
        assert(WK.Keys.Genesis.address == GenesisBlock.txs[0].outputs[0].address);
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

/// Returns: A range of Transactions which are spendable in the Genesis block
public auto genesisSpendable () @safe
{
    return GenesisBlock.txs.filter!(tx => tx.type == TxType.Payment);
}

///
@safe nothrow unittest
{
    auto spendable = genesisSpendable();
    assert(!genesisSpendable.empty);
    Amount total;
    genesisSpendable.each!(tx => tx.outputs.each!(o => total.mustAdd(o.value)));
    // Arbitrarily low value
    assert(total > Amount.MinFreezeAmount);
}

/// Test for a split with the same amount of outputs as inputs
/// Essentially doing an equality transformation
unittest
{
    auto first = genesisSpendable.front;
    immutable Number = first.outputs.length;
    assert(Number == 8);

    const tx = TxBuilder(first)
        .split(WK.Keys.byRange.map!(k => k.address).take(Number))
        .sign();

    // This transaction has 8 txs, hence it's just equality
    assert(tx.inputs.length == Number);
    assert(tx.outputs.length == Number);
    // Since the amount is evenly distributed in Genesis,
    // they all have the same value
    const ExpectedAmount = first.outputs[0].value;
    assert(tx.outputs.all!(val => val.value == ExpectedAmount));
}

/// Test with twice as many outputs as inputs
unittest
{
    auto first = genesisSpendable.front;
    immutable Number = first.outputs.length * 2;
    assert(Number == 16);

    const resTx1 = TxBuilder(first)
        .split(WK.Keys.byRange.map!(k => k.address).take(Number))
        .sign();

    // This transaction has 16 txs
    assert(resTx1.inputs.length == Number / 2);
    assert(resTx1.outputs.length == Number);

    // 500M / 16
    const Amount ExpectedAmount1 = Amount(31_250_000L * 10_000_000L);
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
    const Amount ExpectedAmount2 = Amount(15_625_000L * 10_000_000L);
    assert(resTx2.outputs.all!(val => val.value == ExpectedAmount2));
}

/// Test with remainder
unittest
{
    auto first = genesisSpendable.front;

    const result = TxBuilder(first)
        .split(WK.Keys.byRange.map!(k => k.address).take(3))
        .sign();

    // This transaction has 4 txs (3 targets + 1 refund)
    assert(result.inputs.length == 8);
    assert(result.outputs.length == 4);

    // 500M / 3
    const Amount ExpectedAmount      = Amount(166_666_666_6666_666L);

    assert(result.outputs[0].value == ExpectedAmount);
    assert(result.outputs[1].value == ExpectedAmount);
    assert(result.outputs[2].value == ExpectedAmount);
    // The first output is the remainder
    assert(result.outputs[3].value == Amount(2));
}

/// Test with one output key
unittest
{
    auto first = genesisSpendable.front;

    const result = TxBuilder(first)
        .split([WK.Keys.A.address])
        .sign();

    // This transaction has 1 txs
    assert(result.inputs.length == 8);
    assert(result.outputs.length == 1);

    // 500M
    const Amount ExpectedAmount = Amount(500_000_000L * 10_000_000L);
    assert(result.outputs[0].value == ExpectedAmount);
}

/// Test changing the refund address (and merging outputs by extension)
unittest
{
    const result = TxBuilder(genesisSpendable.front)
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
