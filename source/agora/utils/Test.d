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

import agora.common.crypto.Key;
import agora.consensus.data.Transaction;
import agora.consensus.Genesis;

import std.file;
import std.path;

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
        check = the condition to check on
        timeout = time to wait for the check to succeed
        msg = optional AssertException message when the condition fails
              after the timeout expires
        file = file from the call site
        line = line from the call site

    Throws:
        AssertError if the timeout is reached and the condition still fails

*******************************************************************************/

public void retryFor (lazy bool check, Duration timeout,
    lazy string msg = "", string file = __FILE__, size_t line = __LINE__)
{
    import core.exception;
    import core.thread;
    import std.format;

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

    auto assert_msg = format("Check condition failed after timeout of %s " ~
        "and %s attempts", timeout, TotalAttempts);

    if (msg.length)
        assert_msg ~= ": " ~ msg;

    throw new AssertError(assert_msg, file, line);
}

///
unittest
{
    import core.exception;
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
        gen_tx = the genesis transaction to refer to for the first set of
                 transactions. If none set, the one returned by
                 GenesisTransaction() is used.

*******************************************************************************/

public Transaction[] makeChainedTransactions (KeyPair key_pair,
    const(Transaction)[] prev_txs, size_t block_count,
    ulong spend_amount = 40_000_000, in Transaction gen_tx = GenesisTransaction)
{
    import agora.common.Amount;
    import agora.common.Hash;
    import agora.consensus.data.Block;
    import agora.consensus.Genesis;
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
        {
            input = Input(hashFull(gen_tx), idx.to!uint);
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

        auto signature = key_pair.secret.sign(hashFull(tx)[]);
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
    import agora.consensus.Genesis;
    import agora.common.Amount;
    import agora.common.Hash;
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

/// example of chaining
unittest
{
    import agora.consensus.data.Block;
    import agora.consensus.Genesis;
    import agora.common.Amount;
    import agora.common.Hash;

    auto gen_key = getGenesisKeyPair();
    const(Transaction)[] txes = makeChainedTransactions(gen_key, null, 1);
    txes = makeChainedTransactions(gen_key, txes, 1);
}

/// custom genesis tx
unittest
{
    import std.algorithm;
    import std.exception : assumeUnique;
    import std.range;
    import core.thread;
    import agora.common.Amount;
    import agora.common.BitField;
    import agora.common.Hash;
    import agora.consensus.data.Block;
    import agora.consensus.Genesis;

    auto key_pair = KeyPair.random();

    Transaction GenTx =
    {
        TxType.Payment,
        inputs: [ Input.init ],
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
            0,           // height
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

    auto txes = makeChainedTransactions(key_pair, null, 1, 40_000_000, GenTx);
    foreach (idx; 0 .. Block.TxsInBlock)
    {
        assert(txes[idx].inputs.length == 1);
        assert(txes[idx].inputs[0].index == idx);
        assert(txes[idx].inputs[0].previous == hashFull(genesis_block.txs[0]));
    }
}
