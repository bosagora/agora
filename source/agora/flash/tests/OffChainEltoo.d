/*******************************************************************************

    Contains an example set of steps for the off-chain version of the
    Eltoo protocol.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.OffChainEltoo;

import agora.common.crypto.Key;
import agora.common.Types;
import agora.consensus.data.Transaction;
import agora.script.Engine;
import agora.script.Lock;
import agora.script.Opcodes;
import agora.script.Script;
import agora.script.Signature;

import std.bitmanip;

version (unittest)
{
    import agora.common.crypto.ECC;
    import agora.common.crypto.Schnorr;
    import agora.common.Hash;
    import agora.consensus.state.UTXOSet;
    import agora.consensus.validation.Transaction;
    import agora.utils.Test;
    import ocean.core.Test;
    import std.stdio : writefln, writeln;  // avoid importing LockType
}

version (unittest)
{
    // reasonable defaults
    private const TestStackMaxTotalSize = 16_384;
    private const TestStackMaxItemSize = 512;
}

/*******************************************************************************

    Create an Eltoo lock script based on Figure 4 from the whitepaper.

    Params:
        age = the age constraint for using the settlement keypair
        settle_X = the Schnorr sum of the multi-party public keys for the
                   age-constrained settlement branch
        update_X = the Schnorr sum of the multi-party public keys for the
                   sequence-constrained update branch
        next_seq_id = the sequence ID to lock to for the update spend branch

    Returns:
        a lock script which can be unlocked instantly with an update key-pair,
        or with a settlement key-pair if the age constraint of the input
        is satisfied.

*******************************************************************************/

public Lock createLockEltoo (uint age, Point settle_X, Point update_X,
    uint next_seq_id) pure nothrow @safe
{
    /*
        Eltoo whitepaper Figure 4:

        Key pairs must be different for the if/else branch,
        otherwise an attacker could just steal the signature
        and use a different PUSH to evaluate the other branch.

        To force only a specific settlement tx to be valid, we need to make
        the settle key derived for each sequence ID. That way an attacker
        cannot attach any arbitrary settlement to any other update.

        Differences to whitepaper:
        - we use naive schnorr multisig for simplicity
        - we use VERIFY_SIG rather than CHECK_SIG, it improves testing
          reliability by ensuring the right failure reason is emitted.
          We manually push OP.TRUE to the stack after the verify.

        OP.IF
            <age> OP.VERIFY_INPUT_LOCK
            <settle_pub_multi[seq]> OP.VERIFY_SIG OP.TRUE
        OP_ELSE
            <seq + 1> OP.VERIFY_TX_SEQ
            <update_pub_multi> OP.VERIFY_SIG OP.TRUE
        OP_ENDIF
    */
    const age_bytes = nativeToLittleEndian(age);
    const ubyte[4] seq_id_bytes = nativeToLittleEndian(next_seq_id);

    return Lock(LockType.Script,
        [ubyte(OP.IF)]
            ~ toPushOpcode(age_bytes) ~ [ubyte(OP.VERIFY_INPUT_LOCK),
            ubyte(32)] ~ settle_X[] ~ [ubyte(OP.VERIFY_SIG), ubyte(OP.TRUE),
         ubyte(OP.ELSE)]
            ~ toPushOpcode(seq_id_bytes) ~ [ubyte(OP.VERIFY_TX_SEQ)]
            ~ [ubyte(32)] ~ update_X[] ~ [ubyte(OP.VERIFY_SIG), ubyte(OP.TRUE),
         ubyte(OP.END_IF)]);
}

/*******************************************************************************

    Create an unlock script for the settlement branch for Eltoo Figure 4.

    Params:
        sig = the signature

    Returns:
        an unlock script

*******************************************************************************/

public Unlock createUnlockSettleEltoo (Signature sig)
    pure nothrow @safe
{
    // remember it's LIFO when popping, TRUE goes last
    return Unlock([ubyte(65)] ~ sig[] ~ [ubyte(SigHash.NoInput)]
        ~ [ubyte(OP.TRUE)]);
}

/*******************************************************************************

    Create an unlock script for the settlement branch for Eltoo Figure 4.

    Params:
        sig = the signature

    Returns:
        an unlock script

*******************************************************************************/

public Unlock createUnlockUpdateEltoo (Signature sig) pure nothrow @safe
{
    // remember it's LIFO when popping, FALSE goes last
    return Unlock([ubyte(65)] ~ sig[] ~ [ubyte(SigHash.NoInput)]
        ~ [ubyte(OP.FALSE)]);
}

// note: the implementation here is naive and is not secure,
// it's simplified for tests but should not be used in production.
private Pair getDerivedPair (in Pair origin, in uint seq_id)
{
    assert(seq_id > 0);
    const seq_scalar = Scalar(hashFull(seq_id));
    const derived = origin.v + seq_scalar;
    return Pair(derived, derived.toPoint());
}

// Example of the Eltoo whitepaper on-chain protocol from Figure 4
// note: throughout this code the R is never incremented, which makes
// the signature scheme itself insecure but helps simplify the tests.
//
// Diagram:
//
// Note the arrows signal how each tx's output can be spent (two ways).
//
// funding   =>   trigger   ->   update_1   ->   update_2
//                   |              |               |
//                   -> settle_0    -> settle_1     -> settle_2
//
// In this case 'trigger' can really be just called 'update_0'
//
// Publishing funding begins the channel.
// Publishing trigger begins the countdown for channel closure,
// co-operative parties should only send this tx when they're ready to close.
// An un-cooperative party may send it prematurely, in which case the other
// party has enough time to react to it by publishing the latest update tx.
//
// When update_1 spends trigger's output, settle_0 is invalidated.
// Each settlement can only attach to its associated update tx,
// whereas newer update tx can bind and replace older update transactions,
// but not vice-versa (cannot replace newer update with older).
//
// The settlement is encumbered by an input time lock. Meaning this transaction
// can only be externalized if its associated update tx has been externalized
// by at least N blocks, where N is set in the `unlock_age` of the Input.
// The value of `unlock_age` is verified by the lock script of the tx
// which the settlement is spending.
unittest
{
    import agora.common.Amount;
    import agora.consensus.data.UTXO;

    UTXO _utxo;

    // defining these as constants to make tests easier to read
    const seq_id_0 = 0;
    const seq_id_1 = 1;
    const seq_id_2 = 2;
    const seq_id_3 = 3;
    const seq_id_4 = 4;

    // always signing the transaction with the
    // lone Input blanked with SigHash.NoInput
    const Input0 = 0;

    // used for the initial funding tx input spend
    const Pair kim_funding_kp = Pair.random();

    // the channel's destination. in dual (2) or multi-party (3+) channels
    // there would be multiple destination keys. Note that these destinations
    // should not be related to the Settle / Update key pairs!
    // in the 1-party funding channel we use two destinations:
    // the initial funding key, and the channel destination's key
    const Pair bob_payment_kp = Pair.random();

    // update keypairs remain the same, they are not derived
    const Pair kim_update_kp = Pair.random();
    const Pair bob_update_kp = Pair.random();

    // settlement keypairs are derived based on the sequence ID
    const Pair kim_settle_kp_0 = Pair.random();
    const Pair kim_settle_kp_1 = getDerivedPair(kim_settle_kp_0, 1);
    const Pair kim_settle_kp_2 = getDerivedPair(kim_settle_kp_0, 2);
    const Pair kim_settle_kp_3 = getDerivedPair(kim_settle_kp_0, 3);
    const Pair kim_settle_kp_4 = getDerivedPair(kim_settle_kp_0, 4);
    const Pair bob_settle_kp_0 = Pair.random();
    const Pair bob_settle_kp_1 = getDerivedPair(bob_settle_kp_0, 1);
    const Pair bob_settle_kp_2 = getDerivedPair(bob_settle_kp_0, 2);
    const Pair bob_settle_kp_3 = getDerivedPair(bob_settle_kp_0, 3);
    const Pair bob_settle_kp_4 = getDerivedPair(bob_settle_kp_0, 4);

    // these obviously need to be unique for every signing,
    // but are kept constant here to simplify tests
    const Pair kim_nonce = Pair.random();
    const Pair bob_nonce = Pair.random();

    const Transaction genesis = {
        type: TxType.Payment,
        outputs: [Output(Amount(61_000_000L * 10_000_000uL),
            PublicKey(kim_funding_kp.V[]))]
    };
    scope utxo_set = new TestUTXOSet();
    utxo_set.put(genesis);

    // these are the X, the sum of public keys for each settlement sequence
    const SX_0 = kim_settle_kp_0.V + bob_settle_kp_0.V;
    const SX_1 = kim_settle_kp_1.V + bob_settle_kp_1.V;
    const SX_2 = kim_settle_kp_2.V + bob_settle_kp_2.V;
    const SX_3 = kim_settle_kp_3.V + bob_settle_kp_3.V;
    const SX_4 = kim_settle_kp_4.V + bob_settle_kp_4.V;

    // and the only X for the update keys
    const UX = kim_update_kp.V + bob_update_kp.V;

    // setlement age and funding need to be collaboratively agreed upon
    // in this example there is only a single founder, but this is very easyß
    // to extend to multi-party funding transactions.
    const FundingAmount = Amount(10L * 10_000_000uL);  // 10 BOA
    const SettleAge = 10;

    // notice that the signature matches SX0 first, and seq_1 for the update
    // predefining them to make tests easier to read
    const FundingLockSeq_1 = createLockEltoo(SettleAge, SX_0, UX, seq_id_1);
    const FundingLockSeq_2 = createLockEltoo(SettleAge, SX_1, UX, seq_id_2);
    const FundingLockSeq_3 = createLockEltoo(SettleAge, SX_2, UX, seq_id_3);
    const FundingLockSeq_4 = createLockEltoo(SettleAge, SX_3, UX, seq_id_4);

    // Kim creates funding tx, does not share it.
    // He will publish it to the blockchain once the trigger and funding tx's
    // are both signed.
    Transaction funding_tx = {
        type: TxType.Payment,
        inputs: [Input(genesis, 0 /* index */, 0 /* unlock age */)],
        outputs: [
            Output(FundingAmount,
                PublicKey.init,  // ignored, we use the lock instead
                Lock(LockType.Key, UX[]))]  // using update key-pairs
    };
    const challenge_funding = getChallenge(funding_tx, SigHash.All, 0);
    const kim_funding_sig = sign(kim_funding_kp.v, kim_funding_kp.V,
        kim_nonce.V, kim_nonce.v, challenge_funding);
    assert(verify(kim_funding_kp.V, kim_funding_sig, challenge_funding)); // ok
    //funding_tx.inputs.unlock = ...  // here we would set the signature

    // verify we can accept funding tx
    assert(utxo_set.peekUTXO(funding_tx.inputs[0].utxo, _utxo));

    // Kim creates the trigger tx and *does not* sign it yet.
    // the trigger can be spent with a settlement encumbered by an age or
    // an update tx that has a bigger sequence ID.
    Transaction trigger_tx = {
        seq_id: 0,
        type: TxType.Payment,
        inputs: [Input(funding_tx, 0 /* index */, 0 /* unlock age */)],
        outputs: [
            Output(FundingAmount,
                PublicKey.init,  // ignored, we use the lock instead
                FundingLockSeq_1)]  // bind to next sequence
    };

    // funding is not externalized yet
    assert(!utxo_set.peekUTXO(trigger_tx.inputs[0].utxo, _utxo));

    // before Kim signs the trigger tx he needs Bob to sign a new
    // settlement tx. This is because if Kim prematurely published the
    // trigger tx then the funds could be forever locked - as they require
    // multisig for both the update and settle branches.
    // Kim sends the unsigned trigger tx to Bob so he can create & sign
    // a settlement tx which spends from the trigger tx.

    // for Schnorr to work we need to agree on a sum R value,
    // so Kim will have to collaborate on this with Bob.
    // alternative: implement `OP.CHECK_MULTI_SIG`, or alternatively a
    // different N-of-M scheme that doesn't require so much interaction.
    // for simplifying the tests we re-use R for all signatures
    auto RX = kim_nonce.V + bob_nonce.V;

    // Bob creates a settlement spending the trigger tx,
    // and partially signs it with only its own signature.
    // The input lock remains empty.
    // Bob sends this <settle_0, signature> tuple back to Kim.
    Transaction settle_0 = {
        // seq_id: seq_id_0,  // todo: in my proposal we would use seq ID in settle
        type: TxType.Payment,
        inputs: [Input(trigger_tx, 0 /* index */, SettleAge)],
        outputs: [
            Output(FundingAmount,
                PublicKey.init,  // ignored, we use the lock instead
                Lock(LockType.Key, kim_funding_kp.V[]))]
    };
    const challenge_settle_0 = getChallenge(settle_0, SigHash.NoInput, Input0);
    const bob_settle_0_sig = sign(bob_settle_kp_0.v, SX_0, RX, bob_nonce.v,
        challenge_settle_0);
    assert(!verify(SX_0, bob_settle_0_sig, challenge_settle_0));  // not valid yet

    // Kim received the <settlement, signature> tuple.
    // he signs it, and finishes the multisig.
    const kim_settle_0_sig = sign(kim_settle_kp_0.v, SX_0, RX, kim_nonce.v,
        challenge_settle_0);
    const settle_0_multi_sig = Sig(RX,
          Sig.fromBlob(kim_settle_0_sig).s
        + Sig.fromBlob(bob_settle_0_sig).s).toBlob();
    assert(verify(SX_0, settle_0_multi_sig, challenge_settle_0));

    // the unlock settlement script is created
    const Unlock settle_0_unlock = createUnlockSettleEltoo(settle_0_multi_sig);
    settle_0.inputs[0].unlock = settle_0_unlock;

    // the settlement is checked for validity with the engine.
    // If the settlement tx is valid, we proceed with signing the trigger
    // transaction.
    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    test!("==")(engine.execute(
        trigger_tx.outputs[0].lock, settle_0_unlock, settle_0,
            settle_0.inputs[0]),
        null);

    // Kim & Bob sign the trigger transaction and exchange signatures
    const challenge_trigger = getChallenge(trigger_tx, SigHash.All, 0);
    const bob_trigger_sig = sign(bob_update_kp.v, UX, RX, bob_nonce.v,
        challenge_trigger);
    assert(!verify(UX, bob_trigger_sig, challenge_trigger));  // not valid yet

    const kim_trigger_sig = sign(kim_update_kp.v, UX, RX, kim_nonce.v,
        challenge_trigger);
    const trigger_multi_sig = Sig(RX,
          Sig.fromBlob(kim_trigger_sig).s
        + Sig.fromBlob(bob_trigger_sig).s).toBlob();
    // both parties verify the trigger is correct
    assert(verify(UX, trigger_multi_sig, challenge_trigger));

    // Kim shares his part of the settle signature to Bob, or alternatively
    // sends the entire settlement tx struct. This is not strictly necessary
    // because Bob doesn't care about this first settlement transaction
    // as it refunds everything back to Kim. Furthermore Bob doesn't need this
    // settlement for any future constructions. But for symmetry reasons we
    // might send it anyway.
    version (none) sendToKim(settle_0);

    // Kim can now publish the funding transaction
    utxo_set.updateUTXOCache(funding_tx, Height(2));

    // Funding tx was externalized, this signals the payment channel
    // has been created.
    assert(utxo_set.peekUTXO(trigger_tx.inputs[0].utxo, _utxo));  // sanity check
    utxo_set.updateUTXOCache(trigger_tx, Height(2));

    // The UTXO spent by the trigger tx is now gone
    assert(!utxo_set.peekUTXO(trigger_tx.inputs[0].utxo, _utxo));
    // settlement can refer to the new trigger UTXO, however we will not add it
    // yet (it's encumbered by a time-lock anyway)
    assert(utxo_set.peekUTXO(settle_0.inputs[0].utxo, _utxo));

    // Kim wants to send 1 BOA to Bob. He needs to create an update tx,
    // however before signing it he should also create a new settlement which
    // will be able to attach to the update tx.
    // note: there is no `update_0`, and `update_1` will double-spend `settle_0`
    // this upate double-spends the settlement `settle_0`
    Transaction update_1 = {
        seq_id: seq_id_1,  // may attach to seq_id 0
        type: TxType.Payment,
        inputs: [Input(trigger_tx, 0 /* index */, 0 /* no unlock age */)],
        outputs: [
            Output(FundingAmount,
                PublicKey.init,  // ignored, we use the lock instead
                FundingLockSeq_2)]  // only update with sequence 2 may spend
    };
    const challenge_update_1 = getChallenge(update_1, SigHash.NoInput, Input0);
    // the input unlock will be signed later, after the settlement is created

    // Kim creates the settlement that spends `update_1` output
    // Kim wants to send 1 BOA to Bob. So the new settlement has two outputs
    // this time.
    Amount KimAmount = Amount(9L * 10_000_000uL);  // 9 BOA
    Amount BobAmount = Amount(1L * 10_000_000uL);  // 1 BOA
    Transaction settle_1 = {
        // seq_id: seq_id_0,  // todo: in my proposal we would use seq ID in settle
        type: TxType.Payment,
        inputs: [Input(update_1, 0 /* index */, SettleAge)],
        outputs: [
            Output(KimAmount,
                PublicKey.init,  // ignored, we use the lock instead
                Lock(LockType.Key, kim_funding_kp.V[])),
            Output(BobAmount,
                PublicKey.init,  // ignored, we use the lock instead
                Lock(LockType.Key, bob_payment_kp.V[])),
            ]
    };
    const challenge_settle_1 = getChallenge(settle_1, SigHash.NoInput, Input0);

    // note that we use the derived key for sequence 1
    // todo: test that the sigs are rejected for seq 0, but accepted for seq 2
    // todo: test also what happens when SX is changed here to be wrong
    const bob_settle_1_sig = sign(bob_settle_kp_1.v, SX_1, RX, bob_nonce.v,
        challenge_settle_1);
    assert(!verify(SX_1, bob_settle_1_sig, challenge_settle_1));  // not valid yet

    // Kim received the <settlement, signature> tuple.
    // he signs it, and finishes the multisig.
    const kim_settle_1_sig = sign(kim_settle_kp_1.v, SX_1, RX, kim_nonce.v,
        challenge_settle_1);
    const settle_1_multi_sig = Sig(RX,
          Sig.fromBlob(kim_settle_1_sig).s
        + Sig.fromBlob(bob_settle_1_sig).s).toBlob();
    assert(verify(SX_1, settle_1_multi_sig, challenge_settle_1));

    // the unlock settlement script is created
    const Unlock settle_1_unlock = createUnlockSettleEltoo(settle_1_multi_sig);
    settle_1.inputs[0].unlock = settle_1_unlock;

    // the settlement is checked for validity with the engine,
    // both at Kim's and at Bob's side. If the settlement tx is valid,
    // it is now safe to sign the update transaction
    test!("==")(engine.execute(
        update_1.outputs[0].lock, settle_1_unlock, settle_1, settle_1.inputs[0]),
        null);

    // Kim & Bob sign the update tx
    const bob_update_1_sig = sign(bob_update_kp.v, UX, RX, bob_nonce.v,
        challenge_update_1);
    assert(!verify(UX, bob_update_1_sig, challenge_update_1));  // not valid yet

    // Kim received the <update, signature> tuple.
    // he signs it, and finishes the multisig.
    const kim_update_1_sig = sign(kim_update_kp.v, UX, RX, kim_nonce.v,
        challenge_update_1);
    const update_1_multi_sig = Sig(RX,
          Sig.fromBlob(kim_update_1_sig).s
        + Sig.fromBlob(bob_update_1_sig).s).toBlob();
    assert(verify(UX, update_1_multi_sig, challenge_update_1));

    const Unlock update_1_unlock = createUnlockUpdateEltoo(update_1_multi_sig);
    update_1.inputs[0].unlock = update_1_unlock;

    // validate that `update_1` can attach to trigger tx
    test!("==")(engine.execute(
        trigger_tx.outputs[0].lock, update_1_unlock, update_1,
            update_1.inputs[0]),
        null);

    /////////////////////////////////
    // UPDATE START
    /////////////////////////////////

    Transaction update_2 = {
        seq_id: seq_id_2,  // may attach to seq_id <= 1
        type: TxType.Payment,
        inputs: [Input(trigger_tx, 0 /* index */, 0 /* no unlock age */)],
        outputs: [
            Output(FundingAmount,
                PublicKey.init,  // ignored, we use the lock instead
                FundingLockSeq_3)]  // bind to next sequence
    };
    const challenge_update_2 = getChallenge(update_2, SigHash.NoInput, Input0);

    // new amounts
    KimAmount = Amount(8L * 10_000_000uL);  // 8 BOA
    BobAmount = Amount(2L * 10_000_000uL);  // 2 BOA

    Transaction settle_2 = {
        // seq_id: seq_id_2,  // todo: in my proposal we would use seq ID in settle
        type: TxType.Payment,
        inputs: [Input(update_2, 0 /* index */, SettleAge)],
        outputs: [
            Output(KimAmount,
                PublicKey.init,  // ignored, we use the lock instead
                Lock(LockType.Key, kim_funding_kp.V[])),
            Output(BobAmount,
                PublicKey.init,  // ignored, we use the lock instead
                Lock(LockType.Key, bob_payment_kp.V[])),
            ]
    };
    const challenge_settle_2 = getChallenge(settle_2, SigHash.NoInput, Input0);

    // note that we use the derived key for sequence 1
    // todo: test that the sigs are rejected for seq 0, but accepted for seq 2
    // todo: test also what happens when SX is changed here to be wrong
    const bob_settle_2_sig = sign(bob_settle_kp_2.v, SX_2, RX, bob_nonce.v,
        challenge_settle_2);
    assert(!verify(SX_2, bob_settle_2_sig, challenge_settle_2));  // not valid yet

    // Kim received the <settlement, signature> tuple.
    // he signs it, and finishes the multisig.
    const kim_settle_2_sig = sign(kim_settle_kp_2.v, SX_2, RX, kim_nonce.v,
        challenge_settle_2);
    const settle_2_multi_sig = Sig(RX,
          Sig.fromBlob(kim_settle_2_sig).s
        + Sig.fromBlob(bob_settle_2_sig).s).toBlob();

    // the unlock settlement script is created
    const Unlock settle_2_unlock = createUnlockSettleEltoo(settle_2_multi_sig);
    settle_2.inputs[0].unlock = settle_2_unlock;

    // the unlock settlement script is created
    // this the settlement is checked for validity with the engine,
    // both at Kim's and at Bob's side. If the settlement tx is valid,
    // it is now safe to sign the update transaction
    test!("==")(engine.execute(
        update_2.outputs[0].lock, settle_2_unlock, settle_2, settle_2.inputs[0]),
        null);

    // Kim & Bob sign the update tx
    const bob_update_2_sig = sign(bob_update_kp.v, UX, RX, bob_nonce.v,
        challenge_update_2);
    assert(!verify(UX, bob_update_2_sig, challenge_update_2));  // not valid yet

    // Kim received the <update, signature> tuple.
    // he signs it, and finishes the multisig.
    const kim_update_2_sig = sign(kim_update_kp.v, UX, RX, kim_nonce.v,
        challenge_update_2);
    const update_2_multi_sig = Sig(RX,
          Sig.fromBlob(kim_update_2_sig).s
        + Sig.fromBlob(bob_update_2_sig).s).toBlob();
    assert(verify(UX, update_2_multi_sig, challenge_update_2));

    const Unlock update_2_unlock = createUnlockUpdateEltoo(update_2_multi_sig);
    update_2.inputs[0].unlock = update_2_unlock;

    // `update_2` can attach to trigger tx
    test!("==")(engine.execute(
        trigger_tx.outputs[0].lock, update_2_unlock, update_2,
            update_2.inputs[0]),
        null);

    // `update_2` can attach to `update_1`
    test!("==")(engine.execute(
        update_1.outputs[0].lock, update_2_unlock, update_2,
            update_2.inputs[0]),
        null);

    // but `update_1` cannot attach to `update_2`
    test!("==")(engine.execute(
        update_2.outputs[0].lock, update_1_unlock, update_1,
            update_1.inputs[0]),
        "VERIFY_TX_SEQ sequence ID of transaction is too low");

    // settlement 2 cannot attach to update 1,
    // we would need to publish update 1 first
    test!("==")(engine.execute(
        update_1.outputs[0].lock, settle_2_unlock, settle_2, settle_2.inputs[0]),
        "VERIFY_SIG signature failed validation");

    // settlement 1 cannot attack to update 2
    test!("==")(engine.execute(
        update_2.outputs[0].lock, settle_1_unlock, settle_1, settle_1.inputs[0]),
        "VERIFY_SIG signature failed validation");

    /////////////////////////////////
    // UPDATE END
    /////////////////////////////////

    // all of these still refer to the trigger utxo
    assert(utxo_set.peekUTXO(update_1.inputs[0].utxo, _utxo));
    assert(utxo_set.peekUTXO(update_2.inputs[0].utxo, _utxo));
    assert(utxo_set.peekUTXO(settle_0.inputs[0].utxo, _utxo));

    // settle 1 refers to update_1 utxo, which was not published or externalized
    assert(!utxo_set.peekUTXO(settle_1.inputs[0].utxo, _utxo));
    // settle 2 refers to update_2 utxo, ditto
    assert(!utxo_set.peekUTXO(settle_2.inputs[0].utxo, _utxo));

    // however the input can be rebinded to the trigger utxo which exists..
    Transaction settle_1_rebinded = settle_1;
    settle_1_rebinded.inputs[0] = Input(trigger_tx, 0 /* index */, SettleAge);
    assert(utxo_set.peekUTXO(settle_1_rebinded.inputs[0].utxo, _utxo));

    // ..but it's not a problem because the unlock script will fail
    test!("==")(engine.execute(
        trigger_tx.outputs[0].lock, settle_2_unlock, settle_1_rebinded,
            settle_1_rebinded.inputs[0]),
        "VERIFY_SIG signature failed validation");
}
