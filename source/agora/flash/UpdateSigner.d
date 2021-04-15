/*******************************************************************************

    Contains the task which signs & shares the settlement & update transaction
    signatures for a given sequence ID.

    The `Channel` will run this task for the initial settlement & trigger
    transactions, as well as any subsequent channel balance updates.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.UpdateSigner;

import agora.common.ManagedDatabase;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Transaction;
import agora.crypto.ECC;
import agora.crypto.Key;
import agora.crypto.Schnorr;
import agora.flash.api.FlashAPI;
import agora.flash.Config;
import agora.flash.ErrorCode;
import agora.flash.Scripts;
import agora.flash.Types;
import agora.script.Engine;
import agora.script.Lock;
import agora.serialization.Serializer;
import agora.utils.Backoff;
import agora.utils.Log;

mixin AddLogger!();

import std.conv;
import std.datetime.systime;
import std.format;
import std.stdio;  // todo: remove
import std.traits;

import core.time;

/// Ditto
public class UpdateSigner
{
    /// All the update signer metadata
    mixin UpdateSignerMetadata!() meta;

    /// Global flash configuration (may change after restart)
    private FlashConfig flash_conf;

    /// Database to load from
    private ManagedDatabase db;

    /// Serialization buffer
    private ubyte[] serialize_buffer;

    /// Execution engine
    private Engine engine;

    /// Task manager
    private ITaskManager taskman;

    /// Retry delay algorithm
    private Backoff backoff;

    /***************************************************************************

        Constructor

        Params:
            flash_conf = global flash configuration
            conf = the channel configuration
            kp = the node's own key-pair
            peer_pk = public key of the counter-party
            engine = the execution engine
            taskman = the taskmanager to schedule tasks with

    ***************************************************************************/

    public this (FlashConfig flash_conf, ChannelConfig conf, KeyPair kp,
        Point peer_pk, Engine engine, ITaskManager taskman,
        ManagedDatabase db)
    {
        this.flash_conf = flash_conf;
        this.conf = conf;
        this.kp = kp;
        this.peer_pk = peer_pk;
        this.engine = engine;
        this.taskman = taskman;
        this.db = db;
        this.backoff = new Backoff(this.flash_conf.retry_multiplier,
            this.flash_conf.max_retry_delay.total!"msecs".to!uint);

        this.load();
    }

    /***************************************************************************

        Load any update signer metadata from the database.

    ***************************************************************************/

    public void load ()
    {
        auto results = this.db.execute(
            "SELECT update_signer FROM channels WHERE chan_id = ?",
            this.conf.chan_id);
        if (results.empty)
            return;  // nothing to load

        ubyte[] data = results.oneValue!(ubyte[]);

        scope DeserializeDg dg = (size) @safe
        {
            if (size > data.length)
                throw new Exception(
                    format("Requested %d bytes but only %d bytes available",
                        size, data.length));

            auto res = data[0 .. size];
            data = data[size .. $];
            return res;
        };

        foreach (name; __traits(allMembers, this.meta))
        {
            alias Type = typeof(__traits(getMember, this.meta, name));
            auto field = &__traits(getMember, this.meta, name);
            static if (isAssociativeArray!Type)
                *field = deserializeFull!(SerializeMap!Type)(dg)._map;
            else static if (is(Type == KeyPair))
            {
                // key-pair embeds const but compiler doesn't recognize
                // this as initialization rather than assignment
                auto val = deserializeFull!Type(dg);
                *cast(PublicKey*)&field.address = val.address;
                *cast(SecretKey*)&field.secret = val.secret;
            }
            else
                *field = deserializeFull!Type(dg);
        }
    }

    /***************************************************************************

        Serialize and dump the channel metadata to the database.

    ***************************************************************************/

    private void dump () @trusted
    {
        this.serialize_buffer.length = 0;
        () @trusted { assumeSafeAppend(this.serialize_buffer); }();
        scope SerializeDg dg = (in ubyte[] data) @safe
        {
            this.serialize_buffer ~= data;
        };

        foreach (name; __traits(allMembers, meta))
        {
            auto field = __traits(getMember, meta, name);
            static if (isAssociativeArray!(typeof(field)))
                serializePart(serializeMap(field), dg);
            else
                serializePart(field, dg);
        }

        this.db.execute(
            "REPLACE INTO channels (chan_id, update_signer) VALUES (?, ?)",
            this.conf.chan_id, this.serialize_buffer);
    }

    /***************************************************************************

        Returns:
            true if the signature collecting is currently in process

    ***************************************************************************/

    public bool isCollectingSignatures ()
    {
        return this.is_collecting;
    }

    /***************************************************************************

        Called when the peer has confirmed collecting signatures for this update

    ***************************************************************************/

    public void onConfirmedChannelUpdate ()
    {
        log.info("{}: Peer {} has confirmed collecting signatures for seq {}.",
                this.kp.address.flashPrettify, this.peer_pk.flashPrettify, seq_id);

        this.peer_confirmed_update = true;
    }

    /***************************************************************************

        Returns:
            The sequence ID of the currently running signer

    ***************************************************************************/

    public uint getSeqID ()
    {
        return this.seq_id;
    }

    /***************************************************************************

        Get the settlement transaction partial signature if it's ready.
        Called by counter-parties.

        It's always safe to share our settlement signature because
        it may only attach to the matching update tx which is signed later.

        Returns:
            our settlement signature,
            or an error if we haven't signed our settlement yet

    ***************************************************************************/

    public Result!Signature getSettleSig ()
    {
        if (this.pending_settle.our_sig != Signature.init)
            return Result!Signature(this.pending_settle.our_sig);
        else
            return Result!Signature(ErrorCode.SettleNotSigned);
    }

    /***************************************************************************

        Get the update transaction partial signature if it's ready.
        Called by counter-parties.

        Returns:
            our update signature,
            or an error if we haven't received all the signatures for the
            settlement transaction yet, or we haven't signed our update yet

    ***************************************************************************/

    public Result!Signature getUpdateSig ()
    {
        // sharing the update signature prematurely can lead to funds being
        // permanently locked if the settlement signature is missing and the
        // update transaction is externalized.
        if (!this.pending_settle.validated)
            return Result!Signature(ErrorCode.SettleNotReceived,
                "Cannot share update signature until the settlement "
                ~ "signature is received");

        if (this.pending_update.our_sig != Signature.init)
            return Result!Signature(this.pending_update.our_sig);
        else
            return Result!Signature(ErrorCode.UpdateNotSigned);
    }

    /***************************************************************************

        Start collecting signatures for a new seuqence ID and balance.
        The balance should have been agreed upon before calling this routine.

        Params:
            peer = the FlashAPI peer to communicate with
            seq_id = the new sequence ID. If zero, the signer will create the
                trigger transaction which spends from the funding transaction,
                and will also create the settlement spending from the trigger.
                If sequence is greater than zero  it will create update &
                settlement transactions which both spend from the trigger
                transaction.
            balance = the balance to use in the settlement transaction. Note
                that the update transaction always spends the entire funding
                amount and does not split the balances itself.
            priv_nonce = the private nonce pair the node will use for its part
                of the settlement & update signing. The actual nonce used is
                derived from this value, making sure that update & settlement
                transactions have different nonces.
            peer_nonce = the public nonce pair the counter-party will use for
                its part of the settlement & update signing.
            prev_tx = when `seq_id` is zero, this should be the funding
                transaction. If `seq_id` is greater than zero, it should be the
                signed trigger transaction created in the first call to
                `collectSignatures` where the `seq_id` was zero.
        Returns:
            a pair of signed settlement and update / trigger transactions,
            or an error if collaboration with the counter-party failed

    ***************************************************************************/

    public Result!UpdatePair collectSignatures (FlashAPI peer,
        uint seq_id, Output[] outputs, PrivateNonce priv_nonce,
        PublicNonce peer_nonce, Transaction prev_tx)
    {
        this.clearState();

        this.seq_id = seq_id;
        this.outputs = outputs;
        this.priv_nonce = priv_nonce;
        this.peer_nonce = peer_nonce;
        this.prev_tx = prev_tx;

        this.is_collecting = true;
        scope (exit) this.is_collecting = false;

        this.pending_update = this.createPendingUpdate(priv_nonce, peer_nonce,
            prev_tx);
        this.pending_settle = this.createPendingSettle(this.pending_update.tx,
            outputs, priv_nonce, peer_nonce);

        // todo: need to validate settlement against update, in case
        // balances are too big, etc.

        Result!Signature settle_res = Result!Signature(ErrorCode.Unknown);
        const settle_fail_time = Clock.currTime() + this.flash_conf.max_retry_time;
        foreach (attempt; 0 .. uint.max)
        {
            const WaitTime = this.backoff.getDelay(attempt).msecs;
            if (Clock.currTime() + WaitTime >= settle_fail_time)
                break;  // timeout

            this.taskman.wait(WaitTime);

            settle_res = peer.requestSettleSig(this.conf.chan_id, seq_id);
            if (settle_res.error)
            {
                // todo: retry?
                log.info("{}: Settlement signature {} request to {} rejected: {}",
                    this.kp.address.flashPrettify, seq_id, this.peer_pk.flashPrettify, settle_res);
                continue;
            }

            break;
        }

        if (settle_res.error)
            return Result!UpdatePair(settle_res.error, settle_res.message);

        log.info("{}: Settlement signature {} from {} received",
            this.kp.address.flashPrettify, seq_id, this.peer_pk.flashPrettify);

        if (auto error = this.isInvalidSettleMultiSig(this.pending_settle,
            settle_res.value, priv_nonce, peer_nonce))
        {
            // todo: inform? ban?
            log.info("{}: Error during validation: {}. For settle signature {}"
                ~ " from {}: {}",
                this.kp.address.flashPrettify, error, seq_id,
                this.peer_pk.flashPrettify, settle_res.value);
            return Result!UpdatePair(ErrorCode.InvalidSignature);
        }

        log.info("{}: Settlement signature {} from {} validated",
            this.kp.address.flashPrettify, seq_id, this.peer_pk.flashPrettify);

        this.pending_settle.peer_sig = settle_res.value;
        this.pending_settle.validated = true;

        Result!Signature update_res = Result!Signature(ErrorCode.Unknown);
        const update_fail_time = Clock.currTime()
            + this.flash_conf.max_retry_time;
        foreach (attempt; 0 .. uint.max)
        {
            const WaitTime = this.backoff.getDelay(attempt).msecs;
            if (Clock.currTime() + WaitTime >= update_fail_time)
                break;  // timeout

            this.taskman.wait(WaitTime);

            update_res = peer.requestUpdateSig(this.conf.chan_id, seq_id);
            if (update_res.error)
            {
                // todo: retry?
                log.info("{}: Update signature {} request to {} rejected: {}",
                    this.kp.address.flashPrettify, seq_id, this.peer_pk.flashPrettify, update_res);
                continue;
            }

            break;
        }

        log.info("{}: Update signature {} from {} received",
            this.kp.address.flashPrettify, seq_id, this.peer_pk.flashPrettify);

        if (update_res.error)
            return Result!UpdatePair(update_res.error, update_res.message);

        if (auto error = this.isInvalidUpdateMultiSig(this.pending_update,
            update_res.value, priv_nonce, peer_nonce, prev_tx))
        {
            // todo: inform? ban?
            log.info("{}: Error during validation: {}. For update "
                ~ "signature {} from {}: {}",
                this.kp.address.flashPrettify, error, seq_id,
                this.peer_pk.flashPrettify, update_res.value);

            return Result!UpdatePair(ErrorCode.InvalidSignature);
        }
        this.pending_update.peer_sig = update_res.value;
        this.pending_update.validated = true;

        log.info("{}: Update signature {} from {} validated",
            this.kp.address.flashPrettify, seq_id, this.peer_pk.flashPrettify);

        // confirm to the peer we're done, and await for peer's own confirmation
        while (1)
        {
            auto result = peer.confirmChannelUpdate(this.conf.chan_id, seq_id);
            if (result.error)
            {
                log.info("{}: confirmChannelUpdate rejected, trying again..: {}",
                    this.kp.address.flashPrettify, result.message);
                this.taskman.wait(100.msecs);
                continue;
            }

            break;
        }

        while (!this.peer_confirmed_update)
        {
            log.info("{}: Peer {} is still collecting signatures for seq {}. "
                ~ "Waiting before confirming update..",
                this.kp.address.flashPrettify, this.peer_pk.flashPrettify, seq_id,);
            this.taskman.wait(100.msecs);
        }

        UpdatePair pair =
        {
            seq_id : this.seq_id,
            settle_tx : this.pending_settle.tx,
            our_settle_sig : this.pending_settle.our_sig,
            update_tx : this.pending_update.tx,
            our_update_sig : this.pending_update.our_sig,
        };

        return Result!UpdatePair(pair);
    }

    /***************************************************************************

        Sign our part of the signature for the trigger / update transaction.

        Params:
            update_tx = the update transaction, or trigger transaction if
                the current `seq_id` is zero.
            priv_nonce = the private nonce to use for signing.
            peer_nonce = the counter-party's public nonce to use for signing.

        Returns:
            The partial Schnorr signature.

    ***************************************************************************/

    private Signature makeUpdateSig (in Transaction update_tx,
        in PrivateNonce priv_nonce, in PublicNonce peer_nonce)
    {
        const nonce_pair_pk = priv_nonce.update.V + peer_nonce.update;

        // if the current sequence is 0 then the update tx is a trigger tx that
        // only needs a multi-sig and does not require a sequence.
        // Note that we cannot use a funding tx hash derived update key because
        // the funding tx's key lock is part of the hash (cyclic dependency).
        // Therefore we instead treat the trigger tx as special and simply
        // use a multisig with the pair_pk.
        // Note that an update tx with seq 0 do not exist.
        if (this.seq_id == 0)
        {
            return sign(this.kp.secret, this.conf.pair_pk, nonce_pair_pk,
                priv_nonce.update.v, update_tx);
        }
        else
        {
            const update_key = getUpdateScalar(this.kp.secret,
                this.conf.funding_tx_hash);
            const challenge_update = getSequenceChallenge(update_tx,
                this.seq_id, 0);  // todo: should not be hardcoded
            return sign(update_key, this.conf.update_pair_pk, nonce_pair_pk,
                priv_nonce.update.v, challenge_update);
        }
    }

    /***************************************************************************

        Create a pending update / trigger transaction.

        The partial schnorr signature is stored in the `our_sig` field.
        The update's signature in the `unlock` field is left blank until
        we've collected all signatures and validated them.

        Params:
            priv_nonce = the private nonce to use for signing.
            peer_nonce = the counter-party's public nonce to use for signing.
            prev_tx = the transaction this update / trigger transaction is
                spending from.

        Returns:
            The pending update / trigger transaction.

    ***************************************************************************/

    private PendingUpdate createPendingUpdate (in PrivateNonce priv_nonce,
        in PublicNonce peer_nonce, in Transaction prev_tx)
    {
        auto update_tx = createUpdateTx(this.conf, seq_id, prev_tx);
        const sig = this.makeUpdateSig(update_tx, priv_nonce, peer_nonce);

        PendingUpdate update =
        {
            tx        : update_tx,
            our_sig   : sig,
            validated : false,
        };

        return update;
    }

    /***************************************************************************

        Create a pending settlement transaction.

        The partial schnorr signature is stored in the `our_sig` field.
        The settlement's signature in the `unlock` field is left blank until
        we've collected all signatures and validated them.

        Params:
            update_tx = the previous update / trigger transaction this
                settlement attaches to and spends from
            balance = the agreed-upon new balance ditribution.
            priv_nonce = the private nonce to use for signing.
            peer_nonce = the counter-party's public nonce to use for signing.

        Returns:
            The pending update / trigger transaction.

    ***************************************************************************/

    private PendingSettle createPendingSettle (in Transaction update_tx,
        in Output[] outputs, in PrivateNonce priv_nonce,
        in PublicNonce peer_nonce)
    {
        const settle_key = getSettleScalar(this.kp.secret, this.conf.funding_tx_hash,
            this.seq_id);
        const settle_pair_pk = getSettlePk(this.conf.pair_pk,
            this.conf.funding_tx_hash, this.seq_id, this.conf.num_peers);
        const nonce_pair_pk = priv_nonce.settle.V + peer_nonce.settle;

        const uint input_idx = 0; // todo: this should ideally not be hardcoded
        auto settle_tx = createSettleTx(update_tx, this.conf.settle_time,
            outputs);
        const challenge_settle = getSequenceChallenge(settle_tx, this.seq_id,
            input_idx);

        const sig = sign(settle_key, settle_pair_pk, nonce_pair_pk,
            priv_nonce.settle.v, challenge_settle);

        PendingSettle settle =
        {
            tx        : settle_tx,
            our_sig   : sig,
            validated : false,
        };

        return settle;
    }

    /***************************************************************************

        Checks the validity of the settlement multisig.

        Our partial schnorr signature is combined with the counter-party's
        signature and verified for validity.

        Params:
            settle = the pending settlement transaction which contains our
                own signature.
            peer_sig = the peer's signature which will be combined and validated.
            priv_nonce = the private nonce we've used for signing.
            peer_nonce = the counter-party's public nonce it used for signing.

        Returns:
            null if the signature is valid,
            or an error message if the signature was invalid

    ***************************************************************************/

    private string isInvalidSettleMultiSig (ref PendingSettle settle,
        in Signature peer_sig, in PrivateNonce priv_nonce,
        in PublicNonce peer_nonce)
    {
        const nonce_pair_pk = priv_nonce.settle.V + peer_nonce.settle;
        const settle_multi_sig = Signature(nonce_pair_pk,
              settle.our_sig.s + peer_sig.s);

        Transaction settle_tx
            = settle.tx.serializeFull().deserializeFull!Transaction;

        const Unlock settle_unlock = createUnlockSettle(settle_multi_sig,
            this.seq_id);
        settle_tx.inputs[0].unlock = settle_unlock;

        // note: must always use the execution engine to validate and never
        // try to validate the signatures manually.
        if (auto error = this.engine.execute(
            this.pending_update.tx.outputs[0].lock, settle_tx.inputs[0].unlock,
            settle_tx, settle_tx.inputs[0]))
            return error;

        settle.tx = settle_tx;
        return null;
    }

    /***************************************************************************

        Checks the validity of the update / trigger multisig.

        Our partial schnorr signature is combined with the counter-party's
        signature and verified for validity.

        Params:
            settle = the pending update / trigger transaction which contains
                our own signature.
            peer_sig = the peer's signature which will be combined and validated.
            priv_nonce = the private nonce we've used for signing.
            peer_nonce = the counter-party's public nonce it used for signing.

        Returns:
            null if the signature is valid,
            or an error message if the signature was invalid

    ***************************************************************************/

    private string isInvalidUpdateMultiSig (ref PendingUpdate update,
        in Signature peer_sig, in PrivateNonce priv_nonce,
        in PublicNonce peer_nonce, in Transaction prev_tx)
    {
        const nonce_pair_pk = priv_nonce.update.V + peer_nonce.update;
        const update_multi_sig = Signature(nonce_pair_pk,
              update.our_sig.s + peer_sig.s);

        Transaction update_tx
            = update.tx.serializeFull().deserializeFull!Transaction;

        const Unlock update_unlock = this.makeUpdateUnlock(update_multi_sig);
        update_tx.inputs[0].unlock = update_unlock;
        const lock = prev_tx.outputs[0].lock;

        // note: must always use the execution engine to validate and never
        // try to validate the signatures manually.
        if (auto error = this.engine.execute(lock, update_tx.inputs[0].unlock,
            update_tx, update_tx.inputs[0]))
            return error;

        update.tx = update_tx;
        return null;
    }

    /***************************************************************************

        Creates a trigger / update transaction's unlock script.

        For the trigger transaction the unlock script is a simple multisig,
        for the update transaction the unlock script must be a sequence
        signature which is verified with the `CHECK_SEQ_SIG` opcode in
        the previous trigger or update transaction's lock script.

        Params:
            update_multi_sig = the already validated multi-sig for this
                trigger / update transaction

        Returns:
            the unlock script

    ***************************************************************************/

    private Unlock makeUpdateUnlock (Signature update_multi_sig)
    {
        // if the current sequence is 0 then the update tx is a trigger tx that
        // only needs a multi-sig and does not require a sequence.
        // an update tx with seq 0 do not exist.
        if (this.seq_id == 0)
            return genKeyUnlock(update_multi_sig);
        else
            return createUnlockUpdate(update_multi_sig, this.seq_id);
    }

    /***************************************************************************

        Clear the internal state of the UpdateSigner to get ready for a new run.

    ***************************************************************************/

    private void clearState ()
    {
        this.pending_settle = PendingSettle.init;
        this.pending_update = PendingUpdate.init;
        this.peer_confirmed_update = false;
    }
}

/// Pending settlement transaction which must be singed by all parties
private struct PendingSettle
{
    /// The settlement transaction
    private Transaction tx;

    /// Our own signature
    private Signature our_sig;

    /// The counter-party's signature
    private Signature peer_sig;

    /// Whether the two signatures above are valid, which means we can
    /// proceed to signing the update transaction.
    private bool validated;
}

/// Pending update transaction which must be singed by all parties,
/// but should only be signed once the settlement transaction is signed.
private struct PendingUpdate
{
    /// The update transaction
    private Transaction tx;

    /// Our own signature
    private Signature our_sig;

    /// The counter-party's signature
    private Signature peer_sig;

    /// Whether the two signatures above are valid, which means we can
    /// proceed to updating the channel balance state.
    private bool validated;
}

/// All the update signer metadata which we keep in the DB for storage
private mixin template UpdateSignerMetadata ()
{
    /// Channel configuration
    private ChannelConfig conf;

    /// Key-pair used for signing and deriving update / settlement key-pairs
    public KeyPair kp;

    /// The public key of the peer (for logging)
    private Point peer_pk;

    /// Sequence ID we're trying to sign for
    /// Todo: we should also have some kind of incremental ID to be able to
    /// re-try the same sequence IDs
    private uint seq_id;

    /// Pending signatures for the settlement transaction.
    /// Contains our own settlement signature, which is shared
    /// when the counter-party requests it via `requestSettleSig()`.
    private PendingSettle pending_settle;

    /// Pending signatures for the update transaction.
    /// Contains our own update signature, which is only shared
    /// when counter-parties' settlement signatures are all received
    /// and the settlement signature's multi-sig is considered valid.
    private PendingUpdate pending_update;

    /// Whether there is an active signature collecting process.
    /// While there is an active uncancelled signature process,
    /// a new one should not be started.
    private bool is_collecting;

    /// Set when the peer has confirmed collecting signatures for this update
    private bool peer_confirmed_update;

    /// Outputs we're in the process of signing
    private Output[] outputs;

    /// the private nonce pair used for signing
    private PrivateNonce priv_nonce;

    /// the public nonce pair the counter-party will use for signing
    private PublicNonce peer_nonce;

    /// The tx from which to spend from
    private Transaction prev_tx;
}
