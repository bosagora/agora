/*******************************************************************************

    Network tests for the execution engine scripts.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Script;

version (unittest):

import agora.api.Validator;
import agora.common.crypto.Key;
import agora.consensus.data.genesis.Test;
import agora.consensus.data.Transaction;
import agora.crypto.Schnorr;
import agora.script.Lock;
import agora.script.Opcodes;
import agora.script.Script;
import agora.test.Base;

import Schnorr = agora.crypto.Schnorr;

import std.bitmanip;

alias LockType = agora.script.Lock.LockType;

/// OP.VERIFY_LOCK_HEIGHT
unittest
{
    TestConf conf = TestConf.init;
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto target_height = Height(5);
    network.generateBlocks(target_height);
    network.assertSameBlocks(target_height);

    const block_5 = node_1.getBlocksFrom(5, 1)[0];

    auto kp = Pair(WK.Keys.Genesis.secret, WK.Keys.Genesis.secret.toPoint());

    const height_3 = nativeToLittleEndian(ulong(3));
    Lock lock = Lock(LockType.Script,
        toPushOpcode(height_3)
        ~ [ubyte(OP.VERIFY_LOCK_HEIGHT)]
        ~ [ubyte(32)] ~ kp.V[] ~ [ubyte(OP.CHECK_SIG)]);

    auto lock_txs = block_5.txs
        .filter!(tx => tx.type == TxType.Payment)
        .map!(tx => iota(tx.outputs.length)
            .map!(idx => TxBuilder(tx, cast(uint)idx, lock)))
        .joiner().map!(txb => txb.sign());

    lock_txs.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(6));

    Unlock keyUnlocker (in Transaction tx, in OutputRef out_ref) @safe nothrow
    {
        auto sig = Schnorr.sign(kp, tx);
        return Unlock([ubyte(64)] ~ sig[]);
    }

    const block_6 = node_1.getBlocksFrom(6, 1)[0];

    const lock_height_2 = Height(2);
    auto unlock_height_2 = block_6.spendable()
        .map!(txb => txb.sign(TxType.Payment, null, lock_height_2, 0,
            &keyUnlocker));

    const lock_height_3 = Height(3);
    auto unlock_height_3 = block_6.spendable()
        .map!(txb => txb.sign(TxType.Payment, null, lock_height_3, 0,
            &keyUnlocker)).array;

    // txs with unlock height 2 should be rejected by the lock script
    unlock_height_2.each!(tx => node_1.putTransaction(tx));
    // unlock height 3 accepted
    unlock_height_3.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(7));

    const block_7 = node_1.getBlocksFrom(7, 1)[0];
    unlock_height_3.sort();
    assert(block_7.txs == unlock_height_3);
}

/// OP.VERIFY_UNLOCK_AGE
unittest
{
    TestConf conf = TestConf.init;
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto txs = genesisSpendable().map!(txb => txb.split(
        WK.Keys.Genesis.address.repeat.take(8)).sign()).array;

    auto kp = Pair(WK.Keys.Genesis.secret, WK.Keys.Genesis.secret.toPoint());

    const age_3 = nativeToLittleEndian(uint(3));
    Lock key_lock = Lock(LockType.Script,
        toPushOpcode(age_3)
        ~ [ubyte(OP.VERIFY_UNLOCK_AGE)]
        ~ [ubyte(32)] ~ kp.V[] ~ [ubyte(OP.CHECK_SIG)]);

    // rewrite this tx's outputs to be encumbered by an age lock
    txs[3] = genesisSpendable().array[3]
        .split(key_lock.repeat.take(8)).sign();

    // height 1, many Outputs
    txs.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(1), network.blocks[0].header);

    auto split_up = txs
        .map!(tx => iota(tx.outputs.length)
            .map!(idx => TxBuilder(tx, cast(uint)idx))).array;

    // these parts are similar to the tests in UnlockAge.d
    auto txs_0 = split_up[0].map!(txb => txb.sign()).array;
    auto txs_1 = split_up[1].map!(txb => txb.sign()).array;
    auto txs_2 = split_up[2].map!(txb => txb.sign()).array;

    txs_0.each!(tx => node_1.putTransaction(tx));      // accepted
    network.expectBlock(Height(2), network.blocks[0].header);
    auto blocks = node_1.getBlocksFrom(2, 1);
    assert(blocks.length == 1);
    sort(txs_0);
    assert(blocks[0].txs == txs_0);

    txs_1.each!(tx => node_1.putTransaction(tx));      // accepted
    network.expectBlock(Height(3), network.blocks[0].header);
    blocks = node_1.getBlocksFrom(3, 1);
    assert(blocks.length == 1);
    sort(txs_1);
    assert(blocks[0].txs == txs_1);

    txs_2.each!(tx => node_1.putTransaction(tx));      // accepted
    network.expectBlock(Height(4), network.blocks[0].header);
    blocks = node_1.getBlocksFrom(4, 1);
    assert(blocks.length == 1);
    sort(txs_2);
    assert(blocks[0].txs == txs_2);

    Unlock keyUnlocker (in Transaction tx, in OutputRef out_ref) @safe nothrow
    {
        auto sig = Schnorr.sign(kp, tx);
        return Unlock([ubyte(64)] ~ sig[]);
    }

    // the protocol would allow both transactions (unlock time is fine),
    // however the transaction lock specifically requires unlock age 3.
    const uint UnlockAge_2 = 2;
    auto age_2_txs = iota(cast(uint)txs[3].outputs.length)
        .map!(idx => TxBuilder(txs[3], idx)
            .sign(TxType.Payment, null, Height(0), UnlockAge_2, &keyUnlocker))
        .array();

    const uint UnlockAge_3 = 3;
    auto age_3_txs = iota(cast(uint)txs[3].outputs.length)
        .map!(idx => TxBuilder(txs[3], idx)
            .sign(TxType.Payment, null, Height(0), UnlockAge_3, &keyUnlocker))
        .array();

    age_2_txs.each!(tx => node_1.putTransaction(tx));
    age_3_txs.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(5), network.blocks[0].header);
    blocks = node_1.getBlocksFrom(5, 1);
    assert(blocks.length == 1);
    sort(age_3_txs);
    assert(blocks[0].txs == age_3_txs);  // only txs with unlock age 3 accepted
}

// IF, ELSE, END_IF conditional logic
unittest
{
    TestConf conf = TestConf.init;
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    auto txs = genesisSpendable().map!(txb => txb.split(
        WK.Keys.Genesis.address.repeat.take(8)).sign()).array;

    auto kp = Pair(WK.Keys.Genesis.secret, WK.Keys.Genesis.secret.toPoint());

    /// using two different key pairs for the IF / ELSE branch
    auto kp_a = Pair(WK.Keys[42].secret, WK.Keys[42].secret.toPoint());
    auto kp_b = Pair(WK.Keys[69].secret, WK.Keys[69].secret.toPoint());

    Lock key_lock = Lock(LockType.Script,
        [ubyte(OP.IF)]
            ~ [ubyte(32)] ~ kp_a.V[] ~ [ubyte(OP.CHECK_SIG)]
        ~ [ubyte(OP.ELSE)]
            ~ [ubyte(32)] ~ kp_b.V[] ~ [ubyte(OP.CHECK_SIG)]
        ~ [ubyte(OP.END_IF)]);

    // rewrite these two tx's outputs to be encumbered by a script with a conditional
    txs[3] = genesisSpendable().array[3]
        .split(key_lock.repeat.take(8)).sign();
    txs[4] = genesisSpendable().array[4]
        .split(key_lock.repeat.take(8)).sign();

    // height 1, many Outputs
    txs.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(1), network.blocks[0].header);

    auto split_up = txs
        .map!(tx => iota(tx.outputs.length)
            .map!(idx => TxBuilder(tx, cast(uint)idx))).array;

    auto txs_0 = split_up[0].map!(txb => txb.sign()).array;

    txs_0.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(2), network.blocks[0].header);
    auto blocks = node_1.getBlocksFrom(2, 1);
    assert(blocks.length == 1);
    sort(txs_0);
    assert(blocks[0].txs == txs_0);

    // using IF branch
    auto true_a_txs = iota(cast(uint)txs[3].outputs.length)
        .map!(idx => TxBuilder(txs[3], idx)
            .sign(TxType.Payment, null, Height(0), 0,
                (in Transaction tx, in OutputRef out_ref) @safe nothrow
                {
                    auto sig = Schnorr.sign(kp_a, tx);
                    return Unlock([ubyte(64)] ~ sig[] ~ [ubyte(OP.TRUE)]);
                }))
        .array();

    // ditto, but different key-pair
    auto true_b_txs = iota(cast(uint)txs[3].outputs.length)
        .map!(idx => TxBuilder(txs[3], idx)
            .sign(TxType.Payment, null, Height(0), 0,
                (in Transaction tx, in OutputRef out_ref) @safe nothrow
                {
                    auto sig = Schnorr.sign(kp_b, tx);
                    return Unlock([ubyte(64)] ~ sig[] ~ [ubyte(OP.TRUE)]);
                }))
        .array();

    true_a_txs.each!(tx => node_1.putTransaction(tx));
    true_b_txs.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(3), network.blocks[0].header);
    blocks = node_1.getBlocksFrom(3, 1);
    assert(blocks.length == 1);
    sort(true_a_txs);
    assert(blocks[0].txs == true_a_txs);  // IF branch requires kp_a key-pair

    // using ELSE branch
    auto false_a_txs = iota(cast(uint)txs[4].outputs.length)
        .map!(idx => TxBuilder(txs[4], idx)
            .sign(TxType.Payment, null, Height(0), 0,
                (in Transaction tx, in OutputRef out_ref) @safe nothrow
                {
                    auto sig = Schnorr.sign(kp_a, tx);
                    return Unlock([ubyte(64)] ~ sig[] ~ [ubyte(OP.FALSE)]);
                }))
        .array();

    // ditto, but different key-pair
    auto false_b_txs = iota(cast(uint)txs[4].outputs.length)
        .map!(idx => TxBuilder(txs[4], idx)
            .sign(TxType.Payment, null, Height(0), 0,
                (in Transaction tx, in OutputRef out_ref) @safe nothrow
                {
                    auto sig = Schnorr.sign(kp_b, tx);
                    return Unlock([ubyte(64)] ~ sig[] ~ [ubyte(OP.FALSE)]);
                }))
        .array();

    false_a_txs.each!(tx => node_1.putTransaction(tx));
    false_b_txs.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(4), network.blocks[0].header);
    blocks = node_1.getBlocksFrom(4, 1);
    assert(blocks.length == 1);
    sort(false_b_txs);
    assert(blocks[0].txs == false_b_txs);  // ELSE branch requires kp_b key-pair
}
