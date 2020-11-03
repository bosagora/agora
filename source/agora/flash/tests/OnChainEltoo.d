/*******************************************************************************

    Contains an example set of steps for the on-chain version of the
    Eltoo protocol as described in the whitepaper.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.tests.OnChainEltoo;

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

    Create an Eltoo lock script based on Figure 2 from the whitepaper.

    Params:
        age = the age constraint for using the settlement keypair
        settle_X = the Schnorr sum of the multi-party public keys for the
                   age-constrained settlement branch
        update_X = the Schnorr sum of the multi-party public keys for the
                   non-constrained update branch

    Returns:
        a lock script which can be unlocked instantly with an update key-pair,
        or with a settlement key-pair if the age constraint of the input
        is satisfied.

*******************************************************************************/

public Lock createLockEltoo (uint age, Point settle_X, Point update_X)
    pure nothrow @safe
{
    /*
        Eltoo whitepaper Figure 2:

        Key pairs must be different for the if/else branch,
        otherwise an attacker could just steal the signature
        and use a different PUSH to evaluate the other branch.

        Differences to whitepaper:
        - we use naive schnorr multisig for simplicity
        - we use VERIFY_SIG rather than CHECK_SIG, it improves testing
          reliability by ensuring the right failure reason is emitted.
          We manually push OP.TRUE to the stack after the verify.

        OP.IF
            <age> OP.VERIFY_INPUT_LOCK
            <settle_pub_multi> OP.VERIFY_SIG OP.TRUE
        OP.ELSE
            <update_pub_multi> OP.VERIFY_SIG OP.TRUE
        OP.END_IF
    */
    const age_bytes = nativeToLittleEndian(age);

    return Lock(LockType.Script,
        [ubyte(OP.IF)]
            ~ toPushOpcode(age_bytes) ~ [ubyte(OP.VERIFY_INPUT_LOCK),
            ubyte(32)] ~ settle_X[] ~ [ubyte(OP.VERIFY_SIG), ubyte(OP.TRUE),
         ubyte(OP.ELSE),
            ubyte(32)] ~ update_X[] ~ [ubyte(OP.VERIFY_SIG), ubyte(OP.TRUE),
         ubyte(OP.END_IF)]);
}

/*******************************************************************************

    Create an unlock script for the settlement branch for Eltoo Figure 2.

    Params:
        sig = the signature

    Returns:
        an unlock script

*******************************************************************************/

public Unlock createUnlockSettleEltoo (Signature sig) pure nothrow @safe
{
    // remember it's LIFO when popping, TRUE goes last
    return Unlock([ubyte(65)] ~ sig[] ~ [ubyte(SigHash.All)]
        ~ [ubyte(OP.TRUE)]);
}

/*******************************************************************************

    Create an unlock script for the settlement branch for Eltoo Figure 2.

    Params:
        sig = the signature

    Returns:
        an unlock script

*******************************************************************************/

public Unlock createUnlockUpdateEltoo (Signature sig) pure nothrow @safe
{
    // remember it's LIFO when popping, FALSE goes last
    return Unlock([ubyte(65)] ~ sig[] ~ [ubyte(SigHash.All)]
        ~ [ubyte(OP.FALSE)]);
}

///
unittest
{
    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);

    const Input input_9 = Input(Hash.init, 0, 9 /* unlock_age */);
    const Transaction tx_9 = { inputs : [input_9] };
    const challenge_9 = getChallenge(tx_9, SigHash.All, 0);

    const Input input_10 = Input(Hash.init, 0, 10 /* unlock_age */);
    const Transaction tx_10 = { inputs : [input_10] };
    const challenge_10 = getChallenge(tx_10, SigHash.All, 0);

    const Pair kim_settle_kp = Pair.random();
    const Pair kim_update_kp = Pair.random();
    Pair kim_nonce = Pair.random();

    const Pair bob_settle_kp = Pair.random();
    const Pair bob_update_kp = Pair.random();
    Pair bob_nonce = Pair.random();

    // settle sigs for lock 9 (individual & multisig)
    const SX = kim_settle_kp.V + bob_settle_kp.V;
    auto SRX = kim_nonce.V + bob_nonce.V;
    const kim_settle_sig_9 = sign(kim_settle_kp.v, SX, SRX, kim_nonce.v,
        challenge_9);
    const bob_settle_sig_9 = sign(bob_settle_kp.v, SX, SRX, bob_nonce.v,
        challenge_9);
    const settle_multi_sig_9 = Sig(SRX,
          Sig.fromBlob(kim_settle_sig_9).s
        + Sig.fromBlob(bob_settle_sig_9).s).toBlob();
    assert(verify(SX, settle_multi_sig_9, challenge_9));

    // settle sigs for lock 10 (individual & multisig)
    const kim_settle_sig_10 = sign(kim_settle_kp.v, SX, SRX, kim_nonce.v,
        challenge_10);
    const bob_settle_sig_10 = sign(bob_settle_kp.v, SX, SRX, bob_nonce.v,
        challenge_10);
    const settle_multi_sig_10 = Sig(SRX,
          Sig.fromBlob(kim_settle_sig_10).s
        + Sig.fromBlob(bob_settle_sig_10).s).toBlob();
    assert(verify(SX, settle_multi_sig_10, challenge_10));

    // update sigs for lock 9 (individual & multisig)
    const UX = kim_update_kp.V + bob_update_kp.V;
    auto URX = kim_nonce.V + bob_nonce.V;
    const kim_update_sig_9 = sign(kim_update_kp.v, UX, URX, kim_nonce.v,
        challenge_9);
    const bob_update_sig_9 = sign(bob_update_kp.v, UX, URX, bob_nonce.v,
        challenge_9);
    const update_multi_sig_9 = Sig(URX,
          Sig.fromBlob(kim_update_sig_9).s
        + Sig.fromBlob(bob_update_sig_9).s).toBlob();
    assert(verify(UX, update_multi_sig_9, challenge_9));

    // update sigs for lock 10 (individual & multisig)
    const kim_update_sig_10 = sign(kim_update_kp.v, UX, URX, kim_nonce.v,
        challenge_10);
    const bob_update_sig_10 = sign(bob_update_kp.v, UX, URX, bob_nonce.v,
        challenge_10);
    const update_multi_sig_10 = Sig(URX,
          Sig.fromBlob(kim_update_sig_10).s
        + Sig.fromBlob(bob_update_sig_10).s).toBlob();
    assert(verify(UX, update_multi_sig_10, challenge_10));

    Lock lock_9 = createLockEltoo(9, SX, UX);
    Lock lock_10 = createLockEltoo(10, SX, UX);

    // only valid signatures, for lock 9
    Unlock unlock_settle_kp_settle_9 = createUnlockSettleEltoo(settle_multi_sig_9);
    Unlock unlock_update_kp_update_9 = createUnlockUpdateEltoo(update_multi_sig_9);

    // only valid signatures, for lock 10
    Unlock unlock_settle_kp_settle_10 = createUnlockSettleEltoo(settle_multi_sig_10);
    Unlock unlock_update_kp_update_10 = createUnlockUpdateEltoo(update_multi_sig_10);

    // invalid: settle kp w/ update branch, and vice-veras
    Unlock unlock_settle_kp_update_9 = createUnlockSettleEltoo(update_multi_sig_9);
    Unlock unlock_update_kp_settle_9 = createUnlockUpdateEltoo(settle_multi_sig_9);
    Unlock unlock_settle_kp_update_10 = createUnlockSettleEltoo(update_multi_sig_10);
    Unlock unlock_update_kp_settle_10 = createUnlockUpdateEltoo(settle_multi_sig_10);

    // invalid: partial signatures
    Unlock unlock_update_kp_kim_update_9 = createUnlockUpdateEltoo(kim_update_sig_9);
    Unlock unlock_update_kp_bob_update_9 = createUnlockUpdateEltoo(bob_update_sig_9);
    Unlock unlock_settle_kp_kim_settle_9 = createUnlockSettleEltoo(kim_settle_sig_9);
    Unlock unlock_settle_kp_bob_settle_9 = createUnlockSettleEltoo(bob_settle_sig_9);
    Unlock unlock_update_kp_kim_update_10 = createUnlockUpdateEltoo(kim_update_sig_10);
    Unlock unlock_update_kp_bob_update_10 = createUnlockUpdateEltoo(bob_update_sig_10);
    Unlock unlock_settle_kp_kim_settle_10 = createUnlockSettleEltoo(kim_settle_sig_10);
    Unlock unlock_settle_kp_bob_settle_10 = createUnlockSettleEltoo(bob_settle_sig_10);

    // update kp may be used for update branch (any age)
    test!("==")(engine.execute(lock_9, unlock_update_kp_update_9, tx_9, input_9),
        null);
    test!("==")(engine.execute(lock_9, unlock_update_kp_update_10, tx_10, input_10),
        null);
    test!("==")(engine.execute(lock_10, unlock_update_kp_update_9, tx_9, input_9),
        null);
    test!("==")(engine.execute(lock_10, unlock_update_kp_update_10, tx_10, input_10),
        null);

    // ditto but wrong signature used
    test!("==")(engine.execute(lock_9, unlock_update_kp_update_10, tx_9, input_9),
        "VERIFY_SIG signature failed validation");
    test!("==")(engine.execute(lock_9, unlock_update_kp_update_9, tx_10, input_10),
        "VERIFY_SIG signature failed validation");
    test!("==")(engine.execute(lock_10, unlock_update_kp_update_10, tx_9, input_9),
        "VERIFY_SIG signature failed validation");
    test!("==")(engine.execute(lock_10, unlock_update_kp_update_9, tx_10, input_10),
        "VERIFY_SIG signature failed validation");

    // partial sigs disallowed
    test!("==")(engine.execute(lock_9, unlock_update_kp_kim_update_9, tx_9, input_9),
        "VERIFY_SIG signature failed validation");
    test!("==")(engine.execute(lock_9, unlock_update_kp_bob_update_9, tx_9, input_9),
        "VERIFY_SIG signature failed validation");
    test!("==")(engine.execute(lock_9, unlock_settle_kp_kim_settle_9, tx_9, input_9),
        "VERIFY_SIG signature failed validation");
    test!("==")(engine.execute(lock_9, unlock_settle_kp_bob_settle_9, tx_9, input_9),
        "VERIFY_SIG signature failed validation");

    // update kp can't be used for settlement branch
    test!("==")(engine.execute(lock_9, unlock_settle_kp_update_9, tx_9, input_9),
        "VERIFY_SIG signature failed validation");
    test!("==")(engine.execute(lock_9, unlock_settle_kp_update_10, tx_10, input_10),
        "VERIFY_SIG signature failed validation");
    test!("==")(engine.execute(lock_10, unlock_settle_kp_update_9, tx_9, input_9),
        "VERIFY_INPUT_LOCK unlock age of input is too low");  // age too low
    test!("==")(engine.execute(lock_10, unlock_settle_kp_update_10, tx_10, input_10),
        "VERIFY_SIG signature failed validation");  // age ok, sig failed

    // settle kp only usable for settle branch (with age check)
    test!("==")(engine.execute(lock_9, unlock_settle_kp_settle_9, tx_9, input_9),
        null);  // matching age
    test!("==")(engine.execute(lock_9, unlock_settle_kp_settle_10, tx_10, input_10),
        null);  // 10 > 9, ok
    test!("==")(engine.execute(lock_10, unlock_settle_kp_settle_9, tx_9, input_9),
        "VERIFY_INPUT_LOCK unlock age of input is too low");  // age too low
    test!("==")(engine.execute(lock_10, unlock_settle_kp_settle_10, tx_10, input_10),
        null);  // matching age

    // ditto but wrong signatures used
    test!("==")(engine.execute(lock_9, unlock_settle_kp_settle_10, tx_9, input_9),
        "VERIFY_SIG signature failed validation");
    test!("==")(engine.execute(lock_9, unlock_settle_kp_settle_9, tx_10, input_10),
        "VERIFY_SIG signature failed validation");
    test!("==")(engine.execute(lock_10, unlock_settle_kp_settle_10, tx_9, input_9),
        "VERIFY_INPUT_LOCK unlock age of input is too low");
    test!("==")(engine.execute(lock_10, unlock_settle_kp_settle_9, tx_10, input_10),
        "VERIFY_SIG signature failed validation");

    // settle kp can't be used for update branch
    test!("==")(engine.execute(lock_9, unlock_update_kp_settle_9, tx_9, input_9),
        "VERIFY_SIG signature failed validation");
    test!("==")(engine.execute(lock_9, unlock_update_kp_settle_10, tx_10, input_10),
        "VERIFY_SIG signature failed validation");
    test!("==")(engine.execute(lock_10, unlock_update_kp_settle_9, tx_9, input_9),
        "VERIFY_SIG signature failed validation");
    test!("==")(engine.execute(lock_10, unlock_update_kp_settle_10, tx_10, input_10),
        "VERIFY_SIG signature failed validation");
}

// Example of the Eltoo whitepaper on-chain protocol from Figure 2
// note: throughout this code the R is never incremented, which makes
// the signature scheme itself insecure but helps simplify the tests.
// note: we will need to change our transaction filter in the consensus rules
// to always prefer tx's with outputs with a lower lock age. Otherwise a
// Settlement tx could override an Update tx during network outages.
// Settlement tx's could have outputs bound to HTLCs for multi-hop payments.
// If the two parties want to do a final settlement, they may either wait for
// the lock timeout, or create a new settlement transaction but with update
// keypairs, which is no longer encumbered by a lock but instead directly
// refunds the coins via two outputs, one to each party.
unittest
{
    import agora.common.Amount;
    import agora.consensus.data.UTXO;

    // used for the initial funding tx input spend
    const Pair kim_funding_kp = Pair.random();

    const Pair kim_settle_kp = Pair.random();
    const Pair kim_update_kp = Pair.random();
    Pair kim_nonce = Pair.random();

    const Pair bob_payment_kp = Pair.random();  // the channel's destination
    const Pair bob_settle_kp = Pair.random();
    const Pair bob_update_kp = Pair.random();
    Pair bob_nonce = Pair.random();

    const Transaction genesis = {
        type: TxType.Payment,
        outputs: [Output(Amount(61_000_000L * 10_000_000uL),
            PublicKey(kim_funding_kp.V[]))]
    };
    scope utxo_set = new TestUTXOSet();
    utxo_set.put(genesis);

    const SX = kim_settle_kp.V + bob_settle_kp.V;
    const UX = kim_update_kp.V + bob_update_kp.V;

    // step 0: setlement age and funding need to be collaboratively agreed upon
    // in this example there is only a single founder, but this is very easy
    // to extend to multi-party funding transactions.
    const FundingAmount = Amount(10L * 10_000_000uL);  // 10 BOA
    const SettleAge = 10;
    const FundingLock = createLockEltoo(SettleAge, SX, UX);

    // step 1: Kim creates the funding tx and *does not* sign it yet
    Transaction funding_tx = {
        type: TxType.Payment,
        inputs: [Input(genesis, 0 /* index */, 0 /* unlock age */)],
        outputs: [
            Output(FundingAmount,
                PublicKey.init,  // ignored, we use the lock instead
                FundingLock)]
    };
    // todo: need to sign this tx (with SigHash.All!)

    UTXO _utxo;  // verify we can accept funding tx
    assert(utxo_set.peekUTXO(funding_tx.inputs[0].utxo, _utxo));

    // step 2: before Kim signs the funding tx he needs Bob to sign a new
    // settlement tx. This is because if Kim prematurely published the
    // funding tx then the funds could be forever locked - as they require
    // multisig for both the update and settle branches.
    // Kim sends the unsigned funding tx to Bob so he can create & sign
    // a settlement tx which spends from the funding tx.

    // step 2.5: for Schnorr to work we need to agree on a sum R value,
    // so Kim will have to collaborate on this with Bob.
    // alternative: implement `OP.CHECK_MULTI_SIG`, or alternatively a
    // different N-of-M scheme that doesn't require so much interaction.
    // for simplifying the tests we re-use R for all signatures
    auto RX = kim_nonce.V + bob_nonce.V;

    // step 3: Bob creates a settlement spending the funding tx,
    // and partially signs it with only its own signature.
    // The input lock remains empty.
    // Bob sends this <settle_0, signature> tuple back to Kim.
    Transaction settle_0 = {
        type: TxType.Payment,
        inputs: [Input(funding_tx, 0 /* index */, SettleAge)],
        outputs: [
            Output(FundingAmount,
                PublicKey.init,  // ignored, we use the lock instead
                Lock(LockType.Key, kim_funding_kp.V[]))]
    };
    const challenge_settle_0 = getChallenge(settle_0, SigHash.All, 0);
    const bob_settle_0_sig = sign(bob_settle_kp.v, SX, RX, bob_nonce.v,
        challenge_settle_0);
    assert(!verify(SX, bob_settle_0_sig, challenge_settle_0));  // not valid yet

    // step 4: Kim received the <settlement, signature> tuple.
    // he signs it, and finishes the multisig.
    const kim_settle_0_sig = sign(kim_settle_kp.v, SX, RX, kim_nonce.v,
        challenge_settle_0);
    const settle_0_multi_sig = Sig(RX,
          Sig.fromBlob(kim_settle_0_sig).s
        + Sig.fromBlob(bob_settle_0_sig).s).toBlob();

    // step 5: the unlock settlement script is created
    const Unlock settle_0_unlock = createUnlockSettleEltoo(settle_0_multi_sig);
    settle_0.inputs[0].unlock = settle_0_unlock;

    // step 6: the settlement is checked for validity with the engine.
    // If the settlement tx is valid, it is now safe to publish the Funding
    // transaction to the blockchain. If validation has failed it means
    // the collaboration has failed, and Kim can proceed to try again or to
    // pick another partner to create a channel with.
    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    test!("==")(engine.execute(
        funding_tx.outputs[0].lock, settle_0_unlock, settle_0,
            settle_0.inputs[0]),
        null);

    // step 7: Funding tx was externalized, this signals the payment channel
    // has been created.
    assert(utxo_set.peekUTXO(funding_tx.inputs[0].utxo, _utxo));  // sanity check
    utxo_set.updateUTXOCache(funding_tx, Height(2));

    // The UTXO spent by the funding tx is now gone
    assert(!utxo_set.peekUTXO(funding_tx.inputs[0].utxo, _utxo));
    // settlement can refer to the new funding UTXO, however we will not add it
    // yet (it's encumbered by a time-lock anyway)
    assert(utxo_set.peekUTXO(settle_0.inputs[0].utxo, _utxo));

    // step 8: Kim shares his part of the signature to Bob, or alternatively
    // sends the entire settlement tx struct. This is not strictly necessary,
    // because Bob doesn't care about this first settlement transaction,
    // as it refunds everything back to Kim. Furthermore Bob doesn't need this
    // settlement for any future constructions. But for symmetry reasons we
    // might send it anyway.
    version (none) sendToKim(settle_0);

    // step 9: Kim wants to send 1 BOA to Bob. He needs to create an update tx,
    // however before signing it he should also create a new settlement which
    // will be able to attach to the update tx.
    // note: there is no `update_0`, and `update_1` will double-spend `settle_0`
    // this upate double-spends the settlement `settle_0`
    Transaction update_1 = {
        type: TxType.Payment,
        inputs: [Input(funding_tx, 0 /* index */, 0 /* no unlock age */)],
        outputs: [
            Output(FundingAmount,
                PublicKey.init,  // ignored, we use the lock instead
                FundingLock)]
    };
    const challenge_update_1 = getChallenge(update_1, SigHash.All, 0);
    // the input unlock will be signed later, after the settlement is created

    // step 10: Kim creates the settlement that spends `update_1` output
    // Kim wants to send 1 BOA to Bob. So the new settlement has two outputs
    // this time.
    Amount KimAmount = Amount(9L * 10_000_000uL);  // 9 BOA
    Amount BobAmount = Amount(1L * 10_000_000uL);  // 1 BOA
    Transaction settle_1 = {
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
    const challenge_settle_1 = getChallenge(settle_1, SigHash.All, 0);

    const bob_settle_1_sig = sign(bob_settle_kp.v, SX, RX, bob_nonce.v,
        challenge_settle_1);
    assert(!verify(SX, bob_settle_1_sig, challenge_settle_1));  // not valid yet

    // step 11 (4): Kim received the <settlement, signature> tuple.
    // he signs it, and finishes the multisig.
    const kim_settle_1_sig = sign(kim_settle_kp.v, SX, RX, kim_nonce.v,
        challenge_settle_1);
    const settle_1_multi_sig = Sig(RX,
          Sig.fromBlob(kim_settle_1_sig).s
        + Sig.fromBlob(bob_settle_1_sig).s).toBlob();

    // step 12 (5): the unlock settlement script is created
    // this step should be optimized because both Kim and Bob
    // need to verify the settlement signature
    const Unlock settle_1_unlock = createUnlockSettleEltoo(settle_1_multi_sig);
    settle_1.inputs[0].unlock = settle_1_unlock;

    // step 13 (6): the settlement is checked for validity with the engine,
    // both at Kim's and at Bob's side. If the settlement tx is valid,
    // it is now safe to sign the update transaction
    test!("==")(engine.execute(
        update_1.outputs[0].lock, settle_1_unlock, settle_1,
            settle_1.inputs[0]),
        null);

    // step 14: Kim & Bob sign the update tx
    const bob_update_1_sig = sign(bob_update_kp.v, UX, RX, bob_nonce.v,
        challenge_update_1);
    assert(!verify(UX, bob_update_1_sig, challenge_update_1));  // not valid yet

    // step 15: Kim received the <update, signature> tuple.
    // he signs it, and finishes the multisig.
    const kim_update_1_sig = sign(kim_update_kp.v, UX, RX, kim_nonce.v,
        challenge_update_1);
    const update_1_multi_sig = Sig(RX,
          Sig.fromBlob(kim_update_1_sig).s
        + Sig.fromBlob(bob_update_1_sig).s).toBlob();
    assert(verify(UX, update_1_multi_sig, challenge_update_1));

    const Unlock update_1_unlock = createUnlockUpdateEltoo(update_1_multi_sig);
    update_1.inputs[0].unlock = update_1_unlock;

    // validate that `update_1` can attach to funding tx
    test!("==")(engine.execute(
        funding_tx.outputs[0].lock, update_1_unlock, update_1,
            update_1.inputs[0]),
        null);

    // step 16: publish `update_1` to the blockchain, which enables
    // settlement 1 to attach to it. This is the on-chain protocol
    // as defined in Figure 2 in the Eltoo whitepaper.
    assert(utxo_set.peekUTXO(update_1.inputs[0].utxo, _utxo));  // both can spend
    assert(utxo_set.peekUTXO(settle_0.inputs[0].utxo, _utxo));  // ditto
    assert(!utxo_set.peekUTXO(settle_1.inputs[0].utxo, _utxo)); // settle 1 can't spend yet
    utxo_set.updateUTXOCache(update_1, Height(3));

    // settle_0 was double-spent by update_1
    assert(!utxo_set.peekUTXO(settle_0.inputs[0].utxo, _utxo));
    // settle_1 can spend update_1's UTXO
    assert(utxo_set.peekUTXO(settle_1.inputs[0].utxo, _utxo));
}
