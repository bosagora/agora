/*******************************************************************************

    Contains all the Flash-layer scripting support.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.Scripts;

import agora.common.Amount;
import agora.common.crypto.ECC;
import agora.common.crypto.Schnorr;
import agora.common.Hash;
import agora.common.Types;
import agora.consensus.data.Transaction;
import agora.flash.Config;
import agora.flash.Types;
import agora.script.Lock;
import agora.script.Opcodes;
import agora.script.Script;

import std.bitmanip;

/*******************************************************************************

    Create a Flash lock script.

    This lock is based on the Eltoo protocol, with some security modifications.

    Params:
        age = the age constraint for using the settlement keypair
        first_utxo = the first input's UTXO of the funding transaction.
                     used to be able to derive unique update & settlement
                     keypairs by using the UTXO as an offset.
        pair_pk = the Schnorr sum of the multi-party public keys.
                  The update an settlement keys will be derived from this
                  origin.
        seq_id = the sequence ID to use for the settlement branch. For the
            update branch `seq_id + 1` will be used.
        num_peers = the number of counter-parties in the channel. This number
            is used to be able to make multi-party channels where the number
            of peers is greater than two. It's used for peer nonce derivation.

    Returns:
        a lock script which can be unlocked instantly with an update key-pair,
        or with a settlement key-pair if the age constraint of the input
        is satisfied.

*******************************************************************************/

public Lock createFlashLock (uint age, Hash first_utxo, Point pair_pk,
    ulong seq_id, uint num_peers)
    @safe nothrow
{
    /*
        Eltoo whitepaper Figure 4:

        Key pairs must be different for the if/else branch,
        otherwise an attacker could just steal the signature
        and use a different PUSH to evaluate the other branch.

        To force only a specific settlement tx to be valid we need to make
        the settle key derived for each sequence ID. That way an attacker
        cannot attach any arbitrary settlement to any other update.

        Differences to whitepaper:
        - we use naive schnorr multisig for simplicity
        - we use VERIFY_SIG rather than CHECK_SIG, it improves testing
          reliability by ensuring the right failure reason is emitted.
          We manually push OP.TRUE to the stack after the verify. (temporary)
        - VERIFY_SEQ_SIG expects a push of the sequence on the stack by
          the unlock script, and hashes the sequence to produce a signature.

        Explanation:
        [sig] - signature pushed by the unlock script.
        [spend_seq] - sequence ID pushed by the unlock script in the spending tx.
        <seq + 1> - minimum sequence ID as set by the lock script. It's +1
            to allow binding of the next update tx (or any future update tx).
        OP.VERIFY_SEQ_SIG - verifies that [spend_seq] >= <seq + 1>.
            Hashes the blanked Input together with the [spend_seq] that was
            pushed to the stack and then verifies the signature.

        OP.IF
            [sig] [spend_seq] <seq + 1> <update_pub_multi> OP.VERIFY_SEQ_SIG OP.TRUE
        OP_ELSE
            <age> OP.VERIFY_UNLOCK_AGE
            [sig] [spend_seq] <seq> <settle_pub_multi[spend_seq]> OP.VERIFY_SEQ_SIG OP.TRUE
        OP_ENDIF
    */

    const update_pair_pk = getUpdatePk(pair_pk, first_utxo, num_peers);
    const settle_pair_pk = getSettlePk(pair_pk, first_utxo, seq_id, num_peers);
    const age_bytes = nativeToLittleEndian(age);
    const ubyte[8] seq_id_bytes = nativeToLittleEndian(seq_id);
    const ubyte[8] next_seq_id_bytes = nativeToLittleEndian(seq_id + 1);

    return Lock(LockType.Script,
        [ubyte(OP.IF)]
            ~ [ubyte(32)] ~ update_pair_pk[] ~ toPushOpcode(next_seq_id_bytes)
            ~ [ubyte(OP.VERIFY_SEQ_SIG), ubyte(OP.TRUE),
         ubyte(OP.ELSE)]
             ~ toPushOpcode(age_bytes) ~ [ubyte(OP.VERIFY_UNLOCK_AGE)]
            ~ [ubyte(32)] ~ settle_pair_pk[] ~ toPushOpcode(seq_id_bytes)
                ~ [ubyte(OP.VERIFY_SEQ_SIG), ubyte(OP.TRUE),
         ubyte(OP.END_IF)]);
}

/*******************************************************************************

    Create an unlock script for the update branch.

    Params:
        sig = the signature
        seq_id = the sequence ID

    Returns:
        the unlock script

*******************************************************************************/

public Unlock createUnlockUpdate (Signature sig, in ulong seq_id)
    @safe nothrow
{
    // remember it's LIFO when popping, TRUE is pushed last
    const seq_bytes = nativeToLittleEndian(seq_id);
    return Unlock([ubyte(64)] ~ sig[] ~ toPushOpcode(seq_bytes)
        ~ [ubyte(OP.TRUE)]);
}

/*******************************************************************************

    Create an unlock script for the settlement branch.

    Params:
        sig = the signature
        seq_id = the sequence ID

    Returns:
        the unlock script

*******************************************************************************/

public Unlock createUnlockSettle (Signature sig, in ulong seq_id)
    @safe nothrow
{
    // remember it's LIFO when popping, FALSE is pushed last
    const seq_bytes = nativeToLittleEndian(seq_id);
    return Unlock([ubyte(64)] ~ sig[] ~ toPushOpcode(seq_bytes)
        ~ [ubyte(OP.FALSE)]);
}

/*******************************************************************************

    Create a simple funding transaction which spends from the given UTXO
    and outputs it to a multisig key address from which either the trigger
    transaction or the closing transaction will spend from.

    Params:
        prev_tx = the previous transaction.
        settle_age = the relative unlock age that the settlement will be
            encumbered by.
        outputs = the balance distribution.

    Returns:
        the funding transaction

*******************************************************************************/

public Transaction createFundingTx (in Hash utxo, in Amount funding_amount,
    in Point pair_pk) @safe nothrow
{
    Transaction funding_tx = {
        type: TxType.Payment,
        inputs: [Input(utxo)],
        outputs: [
            Output(funding_amount,
                Lock(LockType.Key, pair_pk[].dup))]
    };

    return funding_tx;
}

/*******************************************************************************

    Create a closing transaction which spends directly from the funding
    transactions. Collaborative nodes should prefer using a closing
    transaction when closing the channel, as it reduces the number of
    transactions they have to publish to the blockchain to just two: the
    funding and the closing transaction.

    Params:
        utxo = the utxo of the funding transaction
        balance = the final balance distribution of the channel.

    Returns:
        the closing transaction

*******************************************************************************/

public Transaction createClosingTx (in Hash utxo, in Balance balance)
    @safe nothrow
{
    Transaction closing_tx = {
        type: TxType.Payment,
        inputs: [Input(utxo)],
        outputs: balance.outputs.dup,
    };

    return closing_tx;
}

/*******************************************************************************

    Create a settlement transaction spending from a previous trigger / update
    transaction.

    Params:
        prev_tx = the previous transaction.
        settle_age = the relative unlock age that the settlement will be
            encumbered by.
        outputs = the balance distribution.

    Returns:
        the settlement transaction

*******************************************************************************/

public Transaction createSettleTx (in Transaction prev_tx,
    in uint settle_age, in Output[] outputs) @safe nothrow
{
    Transaction settle_tx = {
        type: TxType.Payment,
        inputs: [Input(prev_tx, 0 /* index */, settle_age)],
        outputs: outputs.dup,
    };

    return settle_tx;
}

/*******************************************************************************

    Create an update / trigger transaction which spends from a previous
    trigger / update transaction. The output of the transaction can only
    be spent by either another update transaction, or a relative time-locked
    settlement transaction, based on the branching used when spending this
    update transaction.

    Params:
        chan_conf = the channel configuration.
        seq_id = the sequence ID.
        prev_tx = the previous update / trigger transaction.

    Returns:
        the updeate transaction.

*******************************************************************************/

public Transaction createUpdateTx (in ChannelConfig chan_conf,
    in uint seq_id, in Transaction prev_tx) @safe nothrow
{
    const Lock = createFlashLock(chan_conf.settle_time,
        chan_conf.funding_tx_hash, chan_conf.pair_pk, seq_id,
        chan_conf.num_peers);

    Transaction update_tx = {
        type: TxType.Payment,
        inputs: [Input(prev_tx, 0 /* index */, 0 /* unlock age */)],
        outputs: [
            Output(chan_conf.funding_amount, Lock)]
    };

    return update_tx;
}

/*******************************************************************************

    Create the scalar to be used for signing the update transaction.
    The key is derived from the combination of the node's own private key
    and the funding transaction's UTXO.

    Note that key cancellation attacks are not possible (e.g. using fake UTXO),
    this function is only used with update transaction and not the trigger
    transaction. It will not be called until the funding transaction's UTXO
    was externalized, which by definition cannot be manipulated to cause
    key cancellation attacks.

    Params:
        origin = the node's own private key.
        utxo = the funding transaction's UTXO.

    Returns:
        the private key to use for signing the update transaction.

*******************************************************************************/

public Scalar getUpdateScalar (in Scalar origin, in Hash utxo)
    @safe nothrow
{
    const update_offset = Scalar(hashFull("update"));
    const seq_scalar = update_offset + Scalar(utxo);  // todo: use hashing instead?
    const derived = origin + seq_scalar;
    return derived;
}

/*******************************************************************************

    Derive the public key to be used for validating the update transaction.
    This routine is similar to `getUpdateScalar` except it only works on
    public data - such as the counter-parties public keys.

    Params:
        origin = the counter-party's public key.
        utxo = the funding transaction's UTXO.
        num_peers = the number of counter-parties in the channel. This number
            is used to be able to make multi-party channels where the number
            of peers is greater than two. It's used for peer nonce derivation.

    Returns:
        the derived public key the counter-party used for signing the update tx.

*******************************************************************************/

public Point getUpdatePk (in Point origin, in Hash utxo, uint num_peers)
    @safe nothrow
{
    const update_offset = Scalar(hashFull("update"));
    const seq_scalar = update_offset + Scalar(utxo);  // todo: use hashing instead?

    Scalar sum_scalar = seq_scalar;
    while (--num_peers)  // add N-1 additional times
        sum_scalar = sum_scalar + seq_scalar;

    const derived = origin + sum_scalar.toPoint();
    return derived;
}

/*******************************************************************************

    Create the scalar to be used for signing the settlement transaction.
    The key is derived from the combination of the node's own private key
    and the funding transaction's UTXO, as well as the sequence ID.

    Note that key cancellation attacks should not be feasible because we use
    hashing to derive the key from its origin.
    - todo: verify this assumption

    Params:
        origin = the node's own private key.
        utxo = the funding transaction's UTXO.

    Returns:
        the private key to use for signing the update transaction.

*******************************************************************************/

public Scalar getSettleScalar (in Scalar origin, in Hash utxo, in ulong seq_id)
    @safe nothrow
{
    const settle_offset = Scalar(hashFull("settle"));
    const seq_scalar = Scalar(hashMulti(seq_id, utxo, settle_offset));
    const derived = origin + seq_scalar;
    return derived;
}

/*******************************************************************************

    Derive the public key to be used for validating the settlement transaction.
    This routine is similar to `getSettleScalar` except it only works on
    public data - such as the counter-parties public keys.

    Params:
        origin = the counter-party's public key.
        utxo = the funding transaction's UTXO.
        num_peers = the number of counter-parties in the channel. This number
            is used to be able to make multi-party channels where the number
            of peers is greater than two. It's used for peer nonce derivation.

    Returns:
        the derived public key the counter-party used for signing the settle tx.

*******************************************************************************/

public Point getSettlePk (in Point origin, in Hash utxo, in ulong seq_id,
    uint num_peers) @safe nothrow
{
    const settle_offset = Scalar(hashFull("settle"));
    const seq_scalar = Scalar(hashMulti(seq_id, utxo, settle_offset));

    Scalar sum_scalar = seq_scalar;
    while (--num_peers)  // add N-1 additional times
        sum_scalar = sum_scalar + seq_scalar;

    const derived = origin + sum_scalar.toPoint();
    return derived;
}

/*******************************************************************************

    Generate a random pair of private nonces to be used for the
    settlement & update transactions.

    Returns:
        the pair of private nonces.

*******************************************************************************/

public PrivateNonce genPrivateNonce ()
{
    PrivateNonce priv_nonce =
    {
        settle : Pair.random(),
        update : Pair.random(),
    };

    return priv_nonce;
}

/*******************************************************************************

    Derive the pair of public nonces from the given pair of privaten onces.

    Params:
        priv_nonce = the pair of private nonces.

    Returns:
        the pair of public nonces.

*******************************************************************************/

public PublicNonce getPublicNonce (in PrivateNonce priv_nonce)
{
    PublicNonce pub_nonce =
    {
        settle : priv_nonce.settle.V,
        update : priv_nonce.update.V,
    };

    return pub_nonce;
}
