/*******************************************************************************

    Contains the Flash Channel definition.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.Channel;

import agora.flash.API;
import agora.flash.Config;
import agora.flash.ErrorCode;
import agora.flash.OnionPacket;
import agora.flash.Scripts;
import agora.flash.Types;
import agora.flash.UpdateSigner;

import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Serializer;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.UTXO;
import agora.consensus.data.Transaction;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Schnorr;
import agora.script.Engine;
import agora.script.Lock;

import std.array;
import std.algorithm;
import std.format;
import std.stdio;  // todo: remove
import std.typecons;

import core.time;

alias LockType = agora.script.Lock.LockType;

/// Ditto
public class Channel
{
    /// The static information about this channel
    public const ChannelConfig conf;

    /// Key-pair used for signing and deriving update / settlement key-pairs
    public const Pair kp;

    /// Whether we are the funder of this channel (`funder_pk == this.kp.V`)
    public const bool is_owner;

    /// Used to publish funding / trigger / update / settlement txs to blockchain
    public const void delegate (Transaction) txPublisher;

    /// The execution engine, used to validate all flash-layer transactions.
    private Engine engine;

    /// Task manager to spawn fibers with
    public TaskManager taskman;

    /// The peer of the other end of the channel
    public FlashAPI peer;

    /// The public key of the counter-party (for logging)
    public Point peer_pk;

    /// Current state of the channel
    private ChannelState state;

    /// Stored when the funding transaction is signed.
    /// For peers they receive this from the blockchain.
    public Transaction funding_tx_signed;

    /// The signer for an update / settle pair
    private UpdateSigner update_signer;

    /// The list of any off-chain updates which happened on this channel
    private UpdatePair[] channel_updates;

    /// Unresolved payment hashes which are part of existing HTLCs
    private Set!Hash payment_hashes;

    /// Valid when `channel_updates` is not empty, used for the watchtower
    private Hash trigger_utxo;

    /// The current sequence ID
    private uint cur_seq_id;

    /// The current balance of the channel. Initially empty until the
    /// funding tx is externalized.
    private Balance cur_balance;

    /// The closing transaction can spend from the funding transaction when
    /// the channel parties want to collaboratively close the channel.
    /// It requires both of the parties signatures. For safety reasons,
    /// the closing transaction should only be signed once the node marks
    /// the channel as 'PendingClose'.
    private static struct PendingClose
    {
        /// The pending close transaction
        private Transaction tx;

        /// Our part of the multisig
        private Signature our_sig;

        /// The peer's part of the multisig
        private Signature peer_sig;

        /// True if the multisig has been validated
        private bool validated;
    }

    /// Ditto
    private PendingClose pending_close;

    /// Route payments to another channel
    private PaymentRouter paymentRouter;

    /// Called when the channel has been open
    /// (the funding transaction has been externalized)
    private void delegate (ChannelConfig conf) onChannelOpen;

    /// When a payment has been completed we need to check whether we know
    /// the matching secret of the payment hash. Then we can propose a new
    /// channel update for the channel which uses this payment hash.
    private void delegate (Hash chan_id, Hash payment_hash) onPaymentComplete;

    /// Called when a channel update has been completed.
    private void delegate (in Hash[] secrets) onUpdateComplete;


    /***************************************************************************

        Constructor.

        Params:
            conf = the static channel configuration.
            kp = the node's key-pair.
            priv_nonce = the nonce that is used for signing the first
                settle & trigger transactions.
            peer_nonce = the peer's public nonce for the first
                settle & trigger transactions.
            peer = a Flash API client instance
            engine = the execution engine
            taskman = used to spawn tasks
            txPublisher = used to publish transactions to the Agora network.
            paymentRouter = used to forward HTLCs to the next hop
            onUpdateComplete = called when a channel update has completed

    ***************************************************************************/

    public this (in ChannelConfig conf, in Pair kp, in PrivateNonce priv_nonce,
        in PublicNonce peer_nonce, FlashAPI peer, Engine engine,
        TaskManager taskman, void delegate (Transaction) txPublisher,
        PaymentRouter paymentRouter,
        void delegate (ChannelConfig conf) onChannelOpen,
        void delegate (Hash, Hash) onPaymentComplete,
        void delegate (in Hash[]) onUpdateComplete)
    {
        this.conf = conf;
        this.kp = kp;
        this.is_owner = conf.funder_pk == kp.V;
        this.peer = peer;
        this.peer_pk = this.is_owner ? conf.peer_pk : conf.funder_pk;
        this.engine = engine;
        this.taskman = taskman;
        this.txPublisher = txPublisher;
        this.update_signer = new UpdateSigner(this.conf, this.kp, this.peer,
            this.peer_pk, this.engine, this.taskman);
        this.paymentRouter = paymentRouter;
        this.onChannelOpen = onChannelOpen;
        this.onPaymentComplete = onPaymentComplete;
        this.onUpdateComplete = onUpdateComplete;
        this.taskman.setTimer(0.seconds,
            { this.start(priv_nonce, peer_nonce); });
    }

    /***************************************************************************

        Returns:
            true if the channel is funded and is open

    ***************************************************************************/

    public bool isOpen ()
    {
        return this.state == ChannelState.Open;
    }

    /***************************************************************************

        Returns:
            true if the channel is currently in the process of collecting
            a signature. During that time new balance updates will not be
            accepted.

    ***************************************************************************/

    public bool isCollectingSignatures ()
    {
        return this.update_signer.isCollectingSignatures();
    }

    /***************************************************************************

        Returns:
            the current state of the channel

    ***************************************************************************/

    public ChannelState getState ()
    {
        return this.state;
    }

    /***************************************************************************

        Returns:
            our balance in the channel (HTLCs excluded as they're locked)

    ***************************************************************************/

    public Amount getOurBalance ()
    {
        return this.is_owner
            ? this.cur_balance.refund_amount
            : this.cur_balance.payment_amount;
    }

    /***************************************************************************

        Returns:
            the balance of the owner of the channel
            (HTLCs excluded as they're locked)

    ***************************************************************************/

    public Amount getOwnerBalance ()
    {
        return this.cur_balance.refund_amount;
    }

    /***************************************************************************

        Called to check if this channel has any payment hashes for which
        the provided secrets hash to. If they do, a new update will be
        requested with the counter-party.

    ***************************************************************************/

    public void learnSecrets (in Hash[] secrets, in Height height)
    {
        writefln("%s: learnSecrets(%s, hashes: %s, known: %s, %s)",
            this.kp.V.prettify,
            secrets.map!(s => s.prettify),
            secrets.map!(s => s.hashFull.prettify),
            this.payment_hashes[].map!(s => s.prettify),
            height);

        Hash[] matching_secrets;
        foreach (secret; secrets)
            if (secret.hashFull() in this.payment_hashes)
                matching_secrets ~= secret;

        writefln("%s: learnSecrets matching: %s",
            this.kp.V.prettify,
            matching_secrets.map!(s => s.prettify));

        if (matching_secrets.length == 0)
            return;

        this.proposeNewUpdate(matching_secrets, height);
    }

    /***************************************************************************

        Start the setup stage of the channel. Should only be called once.

        A signing task will be spawned which attempts to collect the settlement
        and trigger transaction signatures from the counterparty. Additionally,
        the counter-party will request our own settlement & update signatures
        in the process.

        Once the signatures are collected and are validated on our side,
        the channel will be in `WaitingForFunding` state and will await for the
        funding transaction to be externalized before marking the channel
        as `Open`.

        Params:
            priv_nonce = the private nonce pair of this node for signing the
                initial settlement & trigger transactions
            peer_nonce = the public nonce pair which the counter-party will use
                to sign the initial settlement & trigger transactions

    ***************************************************************************/

    private void start (in PrivateNonce priv_nonce, in PublicNonce peer_nonce)
    {
        assert(this.state == ChannelState.None);
        this.state = ChannelState.SettingUp;
        assert(this.cur_seq_id == 0);

        // initial output allocates all the funds back to the channel creator
        const seq_id = 0;
        const Balance balance = { refund_amount : this.conf.capacity };
        const Output[] outputs = this.buildBalanceOutputs(balance);

        auto pair = this.update_signer.collectSignatures(seq_id, outputs,
            priv_nonce, peer_nonce, this.conf.funding_tx);
        this.onSetupComplete(pair);
    }

    /***************************************************************************

        Called when the setup stage of the channel has been completed.

        If this node is the initial funder of the channel, the funding
        transaction will be signed and published to the blockchain.

        When the funding transaction is detected as being externalized,
        the channel state will be changed to `ChannelState.Open`.

        Params:
            update_pair = the signed initial settlement & trigger transactions.
                These will only be published to the blockchain in case of an
                un-cooperative or one-sided close of a channel.
                In the ideal case, the peers in the channel would agree to
                create a spend from the funding transaction and await until
                it's externalized to ensure the `update_pair` can no longer
                be accepted into the blockchain.

    ***************************************************************************/

    private void onSetupComplete (UpdatePair update_pair)
    {
        assert(this.state == ChannelState.SettingUp);

        // this is not technically an error, but it would be very strange
        // that a funding tx was published before signing was complete,
        // as the funding party carries the risk of having their funds locked.
        // in this case we skip straight to the open state.
        if (this.funding_tx_signed != Transaction.init)
            this.state = ChannelState.Open;
        else
            this.state = ChannelState.WaitingForFunding;

        // if we're the funder then it's time to publish the funding tx
        if (this.is_owner)
        {
            this.funding_tx_signed = this.conf.funding_tx.clone();
            this.funding_tx_signed.inputs[0].unlock
                = genKeyUnlock(sign(this.kp, this.conf.funding_tx));

            writeln("Publishing funding tx..");
            this.txPublisher(this.funding_tx_signed);
        }

        this.trigger_utxo = UTXO.getHash(update_pair.update_tx.hashFull(), 0);
        this.channel_updates ~= update_pair;

        if (this.state == ChannelState.Open)
            this.onChannelOpen(cast()this.conf);
    }

    /***************************************************************************

        Called when the funding transaction of this channel has been
        externalized in the blockchain.

        The state of this channel will change to `Open`, which will make make
        the channel open to receiving new balance update requests - which it
        may accept or deny based on whether all the channel parties agree
        to the new balance update request.

        Params:
            tx = the funding transaction. Must be equal to the hash of the
                 funding transaction as set up in the initial `openChannel`
                 call - otherwise it's ignored.

    ***************************************************************************/

    private void onFundingTxExternalized (in Transaction tx)
    {
        this.funding_tx_signed = tx.clone();
        if (this.state == ChannelState.WaitingForFunding)
            this.state = ChannelState.Open;

        // todo: assert that this is really the actual balance
        // it shouldn't be technically possible that it mismatches
        Balance expected_balance = { refund_amount : this.conf.capacity };
        this.cur_balance = expected_balance;

        this.onChannelOpen(cast()this.conf);
    }

    /***************************************************************************

        Called when the closing transaction of this channel has been
        externalized in the blockchain.

        The state of this channel will change to `Closed`, which means it may
        safely be destroyed by the owning node.

        Params:
            tx = the closing transaction. Must be equal to the hash of the
                 closing transaction as set up in the `closeChannel`
                 call - otherwise it's ignored.

    ***************************************************************************/

    private void onCloseTxExternalized (in Transaction tx)
    {
        writefln("%s: Received close tx: %s", this.kp.V.prettify, tx.hashFull.prettify);
        writefln("%s: Tx is: %s", this.kp.V.prettify, tx);
        // todo: can notify Node that it can destroy this channel instance later
        this.state = ChannelState.Closed;
    }

    /***************************************************************************

        Called when the trigger / update transaction of this channel has been
        either detected in one of the nodes' transaction pools, or
        if it was externalized in the blockchain.

        This signals that the channel attemted to be unilaterally closed
        by some counter-party.

        The state of this channel will change to `PendingClose`, which will
        make it reject any new balance update requests.

        If the `tx` is not the latest update transaction the Channel will try
        to publish the latest update transaction. The Channel will then publish
        the latest matching settlement transaction.

        Params:
            tx = the trigger / update transaction.

    ***************************************************************************/

    public void onUpdateTxExternalized (in Transaction tx)
    {
        this.state = ChannelState.PendingClose;

        // last update was published, publish the settlement
        if (tx == this.channel_updates[$ - 1].update_tx)
        {
            // todo: the settlement is likely encumbered by a relative time
            // lock, need to determine the right time it should be published
            // and make sure a restart will still republish it.
            const settle_tx = this.channel_updates[$ - 1].settle_tx;
            writefln("%s: Publishing last settle tx %s: %s",
                this.kp.V.prettify, this.channel_updates.length, settle_tx.hashFull().prettify);
            this.txPublisher(cast()settle_tx);
        }
        else
        {
            // either the trigger or an outdated update tx was published.
            // publish the latest update first.
            const update_tx = this.channel_updates[$ - 1].update_tx;
            writefln("%s: Publishing latest update tx %s: %s",
                this.kp.V.prettify, this.channel_updates.length, update_tx.hashFull().prettify);
            this.txPublisher(cast()update_tx);
        }
    }

    /***************************************************************************

        Called when a closing transaction has been detected as externalized.
        This was a collaborative channel close.

        At this point the channel becomes closed and it is safe to destroy
        all of its associated data.

        Params:
            tx = the closing transaction.

    ***************************************************************************/

    private void onClosingTxExternalized (in Transaction tx)
    {
        // todo: assert this is the actual closing transaction
        this.state = ChannelState.Closed;
    }

    /***************************************************************************

        Called when a settlement transaction has been detected as externalized.
        This was a unilateral channel close.

        At this point the channel becomes closed and it is safe to destroy
        all of its associated data. If the counter-party was the initiator
        of the channel closure but did not attempt to collaborate on the close,
        or if the counter-party deliberately published an outdated settlement
        transaction, then the peer could be added to the local node's ban list.

        Note that it cannot be proven that a peer acted maliciously when
        publishing a stale update / settlement. Consider the following scenario:

        - Nodes A and B have settle & update transactions for seq 1.
        - They try to negotiate settle & update transactions for seq 2.
        - Node A receives settle & update for seq 2, but refuses to send back
          the update signature for seq 2 to Node B.
        - Node A stops collaborating for a long time, either deliberately or
          due to network issues.
        - Node B is forced to try to close the channel by publishing the trigger
          transaction and its latest update transaction with seq 1.
        - Node A comes back online, sees the trigger / update transactions
          published to the blockchain. It quickly publishes update with seq 2,
          and the associated settlement transaction.

        There was no loss of funds in the above case, but node B could appear
        to look like the bad actor to the external observers because it
        published a stale update transaction.

        In fact, neither node could necessarily be at fault. It's possible
        there was a network outage at Node A's side.

        At this time we're unaware of any algorithm that allows for an
        atomic swap of each others' secrets (signatures) to prevent having
        one party accept a signature but never returning its own signature back.

        Params:
            tx = the settlement transaction.

    ***************************************************************************/

    private void onSettleTxExternalized (in Transaction tx)
    {
        // todo: assert this is the actual settlement transaction
        this.state = ChannelState.Closed;
    }

    /***************************************************************************

        Called when the counter-party requests a settlement signature.
        If the sequence ID is unrecognized, it will return an error code.

        Params:
            seq_id = the sequence ID.

        Returns:
            the settlement signature,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!Signature onRequestSettleSig (in uint seq_id)
    {
        if (seq_id < this.channel_updates.length)
            return Result!Signature(this.channel_updates[seq_id].our_settle_sig);

        if (seq_id != this.update_signer.getSeqID())
            return Result!Signature(ErrorCode.InvalidSequenceID);

        return this.update_signer.getSettleSig();
    }

    /***************************************************************************

        Called when the counter-party requests an update signature.
        If the sequence ID is unrecognized, it will return an error code.

        Params:
            seq_id = the sequence ID.

        Returns:
            the update signature,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!Signature onRequestUpdateSig (in uint seq_id)
    {
        if (seq_id < this.channel_updates.length)
            return Result!Signature(this.channel_updates[seq_id].our_update_sig);

        if (seq_id != this.update_signer.getSeqID())
            return Result!Signature(ErrorCode.InvalidSequenceID);

        return this.update_signer.getUpdateSig();
    }

    /***************************************************************************

        Propose a new update of this channel with the counter-party.

        This folds any outgoing HTLCs for which we've either learned a secret
        for, or for which the HTLCs height locks have expired.

        Params:
            secrets = any newly discovered secrets
            height = the latest known block height

    ***************************************************************************/

    public void proposeNewUpdate (in Hash[] secrets, in Height height)
    {
        // todo: replace with a better retry mechanism
        Result!bool is_collecting;
        while (1)
        {
            is_collecting = this.peer.isCollectingSignatures(this.conf.chan_id);
            if (is_collecting.error || is_collecting.value)
            {
                writefln("%s: proposeNewUpdate: %s is still collecting signatures. Trying again soon..",
                    this.kp.V.prettify, this.peer_pk.prettify);
                this.taskman.wait(100.msecs);
                continue;
            }

            break;
        }

        uint new_seq_id = this.cur_seq_id + 1;

        PrivateNonce priv_nonce = genPrivateNonce();
        PublicNonce pub_nonce = priv_nonce.getPublicNonce();

        // todo: replace with a better retry mechanism
        Result!PublicNonce result;
        while (1)
        {
            // todo: there may be a double call here if the first request timed-out
            // and the client sends this request again.
            result = this.peer.proposeUpdate(this.conf.chan_id, new_seq_id,
                secrets, pub_nonce, height);

            // there may have been a new payment just before the update proposal
            if (this.cur_seq_id >= new_seq_id)
                new_seq_id = this.cur_seq_id + 1;

            if (result.error)
            {
                writefln("%s: ERROR PROPOSING UPDATE (trying again): %s", this.kp.V.prettify, result);
                this.taskman.wait(100.msecs);
                continue;
            }

            break;
        }

        this.cur_seq_id = new_seq_id;
        const peer_nonce = result.value;
        auto new_balance = this.foldHTLCs(this.cur_balance, secrets, height);
        const new_outputs = this.buildBalanceOutputs(new_balance);

        this.taskman.setTimer(0.seconds,
        {
            auto update_pair = this.update_signer.collectSignatures(
                this.cur_seq_id,
                new_outputs, priv_nonce, peer_nonce,
                this.channel_updates[0].update_tx);  // spend from trigger tx

            writefln("%s: Got new pair from %s! Balanced updated!",
                this.kp.V.prettify, this.peer_pk.prettify);
            this.channel_updates ~= update_pair;
            this.cur_balance = new_balance;
        });
    }

    /***************************************************************************

        Called by a counter-party when it wants to fold HTLCs by revealing
        secrets or when forced to spend HTLCs for which the time locks have
        expired.

        Params:
            seq_id = the new sequence ID
            secrets = any new secrets
            peer_nonce = the public nonce the counter-party will use
            height = the latest known height for the counter-party. If we don't
                agree with this height we will reject the update request.

        Returns:
            our nonce to use in the signing process, or an error code

    ***************************************************************************/

    public Result!PublicNonce onProposedUpdate (in uint seq_id,
        in Hash[] secrets, in PublicNonce peer_nonce, in Height height)
    {
        writefln("%s: onProposedUpdate from %s (%s, %s, %s)",
            this.kp.V.prettify, this.peer_pk.prettify,
            seq_id, secrets.map!(s => s.prettify), height);

        if (!this.isOpen())
            return Result!PublicNonce(ErrorCode.ChannelNotOpen,
                "This channel is not open");

        if (this.isCollectingSignatures())
            return Result!PublicNonce(ErrorCode.SigningInProcess,
                "This channel is still collecting signatures for a "
                ~ "previous sequence ID");

        // we force new sequences to be exactly the next in sequence to avoid
        // running out of sequence IDs
        if (seq_id != this.cur_seq_id + 1)
            return Result!PublicNonce(ErrorCode.InvalidSequenceID,
                "Proposed sequence ID must be +1 of the previous sequence ID");

        this.cur_seq_id = seq_id;
        PrivateNonce priv_nonce = genPrivateNonce();
        PublicNonce pub_nonce = priv_nonce.getPublicNonce();

        auto new_balance = this.foldHTLCs(this.cur_balance, secrets, height);
        writefln("%s: Before folding: %s. After folding: %s", this.kp.V.prettify,
            this.cur_balance, new_balance);
        const new_outputs = this.buildBalanceOutputs(new_balance);

        this.taskman.setTimer(0.seconds,
        {
            auto update_pair = this.update_signer.collectSignatures(
                this.cur_seq_id,
                new_outputs, priv_nonce, peer_nonce,
                this.channel_updates[0].update_tx);  // spend from trigger tx

            writefln("%s: Got new pair from %s! Balance updated! %s",
                this.kp.V.prettify, this.peer_pk.prettify, new_balance);
            this.channel_updates ~= update_pair;
            this.cur_balance = new_balance;

            writefln("%s: Update complete! Secrets used: %s",
                this.kp.V.prettify, secrets);
            foreach (secret; secrets)
                this.payment_hashes.remove(secret.hashFull());
            this.onUpdateComplete(secrets);
        });

        return Result!PublicNonce(pub_nonce);
    }

    /***************************************************************************

        Route a payment through the channel. This could be for our own payment,
        or forwarded from another node.

        Params:
            payment_hash = the invoice payment hash
            amount = the invoice amount
            lock_height = the lock height for the outgoing HTLC
            packet = the packet which contains the encrypted payload for the
                counter-party.

        Returns:
            our nonce to use in the signing process, or an error code

    ***************************************************************************/

    public void routeNewPayment (in Hash payment_hash, in Amount amount,
        in Height lock_height, in OnionPacket packet, in Height height)
    {
        // todo: need to check if the counter-party is still collecting
        // signatures, as they will otherwise reject this new request.
        // currently handled by retries
        Result!bool is_collecting;
        while (1)
        {
            is_collecting = this.peer.isCollectingSignatures(this.conf.chan_id);
            if (is_collecting.error || is_collecting.value)
            {
                writefln("%s: routeNewPayment: %s is still collecting signatures. Trying again soon..",
                    this.kp.V.prettify, this.peer_pk.prettify);
                this.taskman.wait(100.msecs);
                continue;
            }

            break;
        }

        const uint new_seq_id = this.cur_seq_id + 1;

        PrivateNonce priv_nonce = genPrivateNonce();
        PublicNonce pub_nonce = priv_nonce.getPublicNonce();

        // todo: work on retries
        auto result = this.peer.proposePayment(this.conf.chan_id, new_seq_id,
            payment_hash, amount, lock_height, packet, pub_nonce, height);
        if (result.error)
        {
            writefln("%s: Error proposing payment: %s", this.kp.V.prettify, result);
            return;
        }

        this.cur_seq_id = new_seq_id;
        const peer_nonce = result.value;
        auto new_balance = this.buildUpdatedBalance(this.cur_balance,
            amount, payment_hash, lock_height, height);
        const new_outputs = this.buildBalanceOutputs(new_balance);

        auto update_pair = this.update_signer.collectSignatures(this.
            cur_seq_id,
            new_outputs, priv_nonce, peer_nonce,
            this.channel_updates[0].update_tx);  // spend from trigger tx

        writefln("%s: Got new pair from %s! Balanced updated!",
            this.kp.V.prettify, this.peer_pk.prettify);
        this.channel_updates ~= update_pair;
        this.cur_balance = new_balance;

        this.payment_hashes.put(payment_hash);
    }

    /***************************************************************************

        Called by a counter-party node when it wants to propose a new payment.

        Params:
            seq_id = the new sequence ID
            payment_hash = the invoice payment hash
            amount = the amount the counter-party wants to forward
            lock_height = the lock height for the outgoing HTLC
            payload = the decrypted payload
            peer_nonce = the public nonce the counter-party will use for signing
            height = the current known block height

        Returns:
            the public nonce this node will use, or an error

    ***************************************************************************/

    public Result!PublicNonce onProposedPayment (in uint seq_id,
        in Hash payment_hash, in Amount amount, in Height lock_height,
        in Payload payload, in PublicNonce peer_nonce, in Height height )
    {
        writefln("%s: onProposedPayment from %s (%s, %s, %s, %s, %s)",
            this.kp.V.prettify, this.peer_pk.prettify,
            this.conf.chan_id, seq_id, payment_hash.prettify, amount,
            lock_height);

        if (!this.isOpen())
            return Result!PublicNonce(ErrorCode.ChannelNotOpen,
                "This channel is not open");

        if (this.isCollectingSignatures())
            return Result!PublicNonce(ErrorCode.SigningInProcess,
                "This channel is still collecting signatures for a "
                ~ "previous sequence ID");

        // Forwarding HTLC. Check balance first.
        // todo: check the owner balance first
        // todo: need to find the next channel ID (if forwarding packet),
        // and check our balance.
        const cur_amount = this.getOwnerBalance();
        if (cur_amount < amount)
            return Result!PublicNonce(ErrorCode.ExceedsMaximumPayment,
                format("Insufficient funds to route this payment. "
                    ~ "Amount requested: %s. Available: %s. Balance: %s",
                    amount, cur_amount, this.cur_balance));

        // todo
        version (none)
        if (amount > this.conf.max_payment_amount)
            return Result!PublicNonce(ErrorCode.ExceedsMaximumPayment,
                "Exceeds maximum payment the node is comfortable routing");

        // we force new sequences to be exactly the next in sequence to avoid
        // running out of sequence IDs
        if (seq_id != this.cur_seq_id + 1)
            return Result!PublicNonce(ErrorCode.InvalidSequenceID,
                "Proposed sequence ID must be +1 of the previous sequence ID");

        this.cur_seq_id = seq_id;
        PrivateNonce priv_nonce = genPrivateNonce();
        PublicNonce pub_nonce = priv_nonce.getPublicNonce();

        auto new_balance = this.buildUpdatedBalance(this.cur_balance,
            amount, payment_hash, lock_height, height);
        const new_outputs = this.buildBalanceOutputs(new_balance);

        this.taskman.setTimer(0.seconds,
        {
            auto update_pair = this.update_signer.collectSignatures(
                this.cur_seq_id,
                new_outputs, priv_nonce, peer_nonce,
                this.channel_updates[0].update_tx);  // spend from trigger tx

            writefln("%s: Got new pair from %s! Balance updated! %s",
                this.kp.V.prettify, this.peer_pk.prettify, new_balance);
            this.channel_updates ~= update_pair;
            this.cur_balance = new_balance;

            // prepare for secrets
            this.payment_hashes.put(payment_hash);

            // route to the next node
            if (payload.next_chan_id != Hash.init)
            {
                writefln("%s: Routing to next channel: %s", this.kp.V.prettify,
                    payload.next_chan_id.prettify);
                this.paymentRouter(payload.next_chan_id, payment_hash,
                    payload.forward_amount, payload.outgoing_lock_height,
                    payload.next_packet);
            }

            // propose an update afterwards
            this.onPaymentComplete(this.conf.chan_id, payment_hash);
        });

        return Result!PublicNonce(pub_nonce);
    }

    /***************************************************************************

        Fold HTLCs for which we've learned the secrets for or which have
        their lock time expired.

        TODO: can we merge this and buildUpdatedBalance() ?

        Params:
            old_balance = the current balance
            secrets = any new secrets we've discovered
            height = the current known block height

        Returns:
            the new balance to use during the next signing process

    ***************************************************************************/

    public Balance foldHTLCs (in Balance old_balance, in Hash[] secrets,
        in Height height)
    {
        Balance new_balance;
        new_balance.refund_amount = old_balance.refund_amount;
        new_balance.payment_amount = old_balance.payment_amount;

        // assocArray doesn't work with const..
        version (none)
            Hash[Hash] payment_hashes = secrets
                .map!(s => tuple(s.hashFull, s))
                .assocArray;

        Hash[Hash] payment_hashes;
        foreach (secret; secrets)
            payment_hashes[secret.hashFull()] = secret;

        foreach (payment_hash, htlc; old_balance.outgoing_htlcs)
        {
            // fold expired HTLCs
            if (htlc.lock_height < height)
            {
                writefln("%s: Fold: Folded time-expired HTLC: %s", this.kp.V.prettify, payment_hash);
                if (!new_balance.refund_amount.add(htlc.amount))
                    assert(0);
            }
            else if (payment_hash in payment_hashes)  // fold secret HTLC
            {
                writefln("%s: Fold: Folded secret-revealed HTLC: %s", this.kp.V.prettify, payment_hash);
                if (!new_balance.payment_amount.add(htlc.amount))
                    assert(0);
            }
            else
            {
                writefln("%s: Fold: DID NOT FOLD HTLC: %s", this.kp.V.prettify, payment_hash);
                new_balance.outgoing_htlcs[payment_hash] = htlc;
            }
        }

        return new_balance;
    }

    /***************************************************************************

        Add a new HTLC to the balance and fold any HTLCs for which the
        timeout has expired.

        Params:
            old_balance = the current balance
            amount = the invoice amount
            payment_hash = the invoice payment hash
            lock_height = the lock height for the outgoing HTLC
            height = the current known block height

        Returns:
            the new balance to use during the next signing process

    ***************************************************************************/

    public Balance buildUpdatedBalance (in Balance old_balance,
        in Amount amount, in Hash payment_hash, in Height lock_height,
        in Height height)
    {
        Balance new_balance;
        new_balance.refund_amount = old_balance.refund_amount;
        new_balance.payment_amount = old_balance.payment_amount;

        // deep-dup
        foreach (hash, htlc; old_balance.outgoing_htlcs)
        {
            // fold expired HTLCs
            if (htlc.lock_height < height)
            {
                writefln("%s: Fold: Folded HTLC: %s", this.kp.V.prettify, payment_hash);
                if (!new_balance.refund_amount.add(htlc.amount))
                    assert(0);
            }
            else
            {
                writefln("%s: Fold: DID NOT FOLD HTLC: %s", this.kp.V.prettify, payment_hash);
                new_balance.outgoing_htlcs[payment_hash] = htlc;
            }
        }

        // add new HTLC
        if (!new_balance.refund_amount.sub(amount))
            assert(0);
        new_balance.outgoing_htlcs[payment_hash] = HTLC(lock_height, amount);

        return new_balance;
    }

    /***************************************************************************

        Called when a new block has been externalized.

        Checks if the block contains funding / trigger / update / settlement
        transactions which belong to this channel, and calls one of the
        handler routines based on the detected transaction type.

        Params:
            block = an externalized block

    ***************************************************************************/

    public void onBlockExternalized (in Block block)
    {
        foreach (tx; block.txs)
        {
            if (tx.hashFull() == this.conf.funding_tx_hash)
            {
                writefln("%s: Funding tx externalized(%s)",
                    this.kp.V.prettify, tx.hashFull().prettify);
                this.onFundingTxExternalized(tx);
            }
            else
            if (this.isClosingTx(tx))
            {
                writefln("%s: Close tx externalized(%s)",
                    this.kp.V.prettify, tx.hashFull().prettify);
                this.onCloseTxExternalized(tx);
            }
            else
            if (this.isUpdateTx(tx))
            {
                writefln("%s: Update tx externalized(%s)",
                    this.kp.V.prettify, tx.hashFull().prettify);
                this.onUpdateTxExternalized(tx);
            }
            else
            if (this.isSettleTx(tx))
            {
                writefln("%s: Settle tx externalized(%s)",
                    this.kp.V.prettify, tx.hashFull().prettify);
                this.onSettleTxExternalized(tx);
            }
        }
    }

    /***************************************************************************

        Checks if this is a closing transaction belonging to this channel.

        Params:
            tx = the transaction to check.

        Returns:
            true if this is the matching closing transaction.

    ***************************************************************************/

    private bool isClosingTx (in Transaction tx)
    {
        return tx == this.pending_close.tx;
    }

    /***************************************************************************

        Checks if this is a trigger or update transaction belonging to
        this channel.

        Params:
            tx = the transaction to check.

        Returns:
            true if this is one of the trigger / update transactions.

    ***************************************************************************/

    private bool isUpdateTx (in Transaction tx)
    {
        if (tx.inputs.length != 1)
            return false;

        // todo: this is also the close tx, check its utxo first
        if (tx.inputs[0].utxo == this.conf.funding_utxo)
            return true;

        // todo: could there be a timing issue here if our `channel_updates`
        // are not updated fast enough? chances are very slim, need to verify.
        // todo: optimize by caching trigger tx utxo
        return this.channel_updates.length > 0
            && tx.inputs[0].utxo == this.trigger_utxo;
    }

    /***************************************************************************

        Checks if this is one of the settlement transactions belonging to
        this channel.

        Params:
            tx = the transaction to check.

        Returns:
            true if this is one of the matching settlement transactions.

    ***************************************************************************/

    private bool isSettleTx (in Transaction tx)
    {
        // todo: need to implement so the channel can be closed
        return false;
    }

    /***************************************************************************

        Begin a unilateral closing of the channel.

        The channel will attempt to co-operatively close by offering the
        counter-party to sign a closing transaction which spends directly
        from the funding transaction where the closing transaction is not
        encumbered by any sequence locks.

        This closing transaction will need to be externalized before the
        channel may be considered closed.

        If the counter-party is not collaborative or is non-responsive,
        the node will wait until `cooperative_close_timeout` time has passed
        since the last failed co-operative close request. If this timeout is
        reached the node will forcefully publish the trigger transaction.

        Once the trigger transaction is externalized the node will publish
        the latest update transaction if any, and subsequently will publish the
        settlement transaction. The settlement transaction may only be published
        after `settle_time` blocks were externalized after the trigger/update
        transaction's UTXO was included in the blockchain - this leaves enough
        time for the counter-party to react and publish a newer update &
        settlement transactions in case the closing party tries to cheat by
        publishing a stale update & settlement pair of transactions.

        Params:
            seq_id = the sequence ID.

        Returns:
            the update signature,
            or an error code with an optional error message.

    ***************************************************************************/

    public void beginUnilateralClose ()
    {
        // todo: should only be called once
        assert(this.state == ChannelState.Open);
        this.state = ChannelState.PendingClose;

        // publish the trigger transaction
        // note that the settlement will be published automatically after the
        // node detects the trigger tx published to the blockchain and after
        // its relative lock time expires.
        const trigger_tx = this.channel_updates[0].update_tx;
        writefln("%s: Publishing trigger tx: %s", this.kp.V.prettify,
            trigger_tx.hashFull().prettify);
        this.txPublisher(cast()trigger_tx);
    }

    /***************************************************************************

        Begin a collaborative close of the channel.

        The node will send the counter-party a `closeChannel` request,
        with the sequence ID of the last known state.

        The counter-party should return its signature for the closing
        transaction.

    ***************************************************************************/

    public void beginCollaborativeClose ()
    {
        // todo: should only be called once
        //assert(this.state == ChannelState.Open);
        // todo: can already be PendingClose if it was requested by another peer
        this.state = ChannelState.PendingClose;

        const Fee = Amount(100);  // todo: coordinate based on return value
        Pair priv_nonce = Pair.random();

        this.taskman.setTimer(0.seconds,
        {
            auto close_res = this.peer.closeChannel(this.conf.chan_id,
                this.cur_seq_id, priv_nonce.V, Fee);

            if (close_res.error)
            {
                // todo: retry with bigger fee if smaller fee was rejected
                // todo: retry?
                // todo: try unilateral close after the configured timeout?
                writefln("%s: Closing tx signature request rejected: %s",
                    this.kp.V.prettify, close_res);
                assert(0);
            }

            this.collectCloseSignatures(priv_nonce, close_res.value);
        });
    }

    /***************************************************************************

        Generate the Outputs for the refund / payment and any HTLCs in the
        balance.

        Params:
            balance = the balance to convert

        Returns:
            an Output array, to be used in the settle / close transactions

    ***************************************************************************/

    private Output[] buildBalanceOutputs (in Balance balance)
    {
        Output[] outputs;

        if (balance.refund_amount != Amount(0))
            outputs ~= Output(balance.refund_amount,
                genKeyLock(this.conf.funder_pk));

        if (balance.payment_amount != Amount(0))
            outputs ~= Output(balance.payment_amount,
                genKeyLock(this.conf.peer_pk));

        assert(outputs.length > 0);

        foreach (hash, htlc; balance.outgoing_htlcs)
        {
            assert(htlc.amount > Amount(0));
            Lock lock = createLockHTLC(hash, htlc.lock_height,
                this.conf.funder_pk, this.conf.peer_pk);

            Output output = Output(htlc.amount, lock);
            outputs ~= output;
        }

        return outputs;
    }

    /***************************************************************************

        Start collecting close transaction signatures.

        The node will send the counter-party a `requestCloseSig` request,
        with the sequence ID of the last known state.

        The counter-party should return its signature for the closing
        transaction.

        Once the closing multisig is validated, it will be published to
        the blockchain in order to close the channel.

        Params:
            priv_nonce = the private nonce of this node
            peer_nonce = the public nonce of the peer

    ***************************************************************************/

    private void collectCloseSignatures (Pair priv_nonce, Point peer_nonce)
    {
        // todo: index is hardcoded
        const utxo = UTXO.getHash(hashFull(this.funding_tx_signed), 0);
        const outputs = this.buildBalanceOutputs(this.cur_balance);
        this.pending_close.tx = createClosingTx(utxo, outputs);

        const nonce_pair_pk = priv_nonce.V + peer_nonce;
        this.pending_close.our_sig = sign(this.kp.v, this.conf.pair_pk,
            nonce_pair_pk, priv_nonce.v, this.pending_close.tx);

        Result!Signature sig_res;

        while (1)
        {
            sig_res = this.peer.requestCloseSig(this.conf.chan_id,
                this.cur_seq_id);
            if (sig_res.error)
            {
                // todo: retry?
                writefln("%s: Closing signature request rejected: %s",
                    sig_res);
                continue;
            }

            break;
        }

        if (auto error = this.isInvalidCloseMultiSig(this.pending_close,
            sig_res.value, priv_nonce, peer_nonce))
        {
            // todo: inform? ban?
            writefln("%s: Error during validation: %s. For closing signature: %s",
                this.kp.V.prettify, error, sig_res.value);
            assert(0);
        }

        this.pending_close.peer_sig = sig_res.value;
        this.pending_close.validated = true;

        // todo: schedule this
        writefln("%s: Publishing close tx: %s",
            this.kp.V.prettify, this.pending_close.tx.hashFull.prettify);
        this.txPublisher(this.pending_close.tx);
    }

    /***************************************************************************

        Attempt to collaboratively close the channel.

        The channel will attempt to co-operatively close by offering the
        counter-party to sign a closing transaction which spends directly
        from the funding transaction where the closing transaction is not
        encumbered by any sequence locks.

        This closing transaction will need to be externalized before the
        channel may be considered closed.

        If the counter-party is not collaborative or is non-responsive,
        the node will wait until `cooperative_close_timeout` time has passed
        since the last failed co-operative close request. If this timeout is
        reached the node will forcefully publish the trigger transaction.

        Once the trigger transaction is externalized the node will publish
        the latest update transaction if any, and subsequently will publish the
        settlement transaction. The settlement transaction may only be published
        after `settle_time` blocks were externalized after the trigger/update
        transaction's UTXO was included in the blockchain - this leaves enough
        time for the counter-party to react and publish a newer update &
        settlement transactions in case the closing party tries to cheat by
        publishing a stale update & settlement pair of transactions.

        Params:
            seq_id = the sequence ID.

        Returns:
            the update signature,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!Point requestCloseChannel (in uint seq_id,
        in Point peer_nonce, in Amount fee)
    {
        if (this.state != ChannelState.Open)
            return Result!Point(ErrorCode.ChannelNotOpen,
                format("Channel state is not open: %s", this.state));

        if (seq_id != this.cur_seq_id)
            return Result!Point(ErrorCode.InvalidSequenceID,
                format("Sequence Point %s does not match our latest ID %s.",
                    seq_id, this.cur_seq_id));

        // todo: check fee
        // todo: need to calculate *our* balance here and see if we can
        // cover this fee.

        this.state = ChannelState.PendingClose;
        Pair priv_nonce = Pair.random();
        Point pub_nonce = priv_nonce.V;

        // todo: there may be a double call here if the first request timed-out
        // and the client sends this request again. We should avoid calling
        // this again.
        this.taskman.setTimer(0.seconds,
        {
            this.collectCloseSignatures(priv_nonce, peer_nonce);
        });

        return Result!Point(pub_nonce);
    }

    /***************************************************************************

        Requests the signature for the closing transaction from this node.

        There must have been a previous `closeChannel` request, otherwise
        the node will return an error.

        Params:
            seq_id = the sequence ID

        Returns:
            the closing transaction signature,
            or an error if something went wrong

    ***************************************************************************/

    public Result!Signature requestCloseSig (in uint seq_id)
    {
        if (this.state != ChannelState.PendingClose &&
            this.state != ChannelState.Closed)
            return Result!Signature(ErrorCode.ChannelNotClosing,
                "Cannot request closing signature before issuing "
                ~ "closeChannel() request");

        if (seq_id != this.cur_seq_id)
            return Result!Signature(ErrorCode.InvalidSequenceID,
                "Wrong sequence ID");

        // todo: handle this edge-case (can occur due to timing issues)
        if (this.pending_close.our_sig == Signature.init)
            return Result!Signature(ErrorCode.SigningInProcess,
                "Close signature not created yet, please try again later");

        return Result!Signature(this.pending_close.our_sig);
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

    private string isInvalidCloseMultiSig (ref PendingClose close,
        in Signature peer_sig, in Pair priv_nonce, in Point peer_nonce)
    {
        const nonce_pair_pk = priv_nonce.V + peer_nonce;
        const close_multi_sig = Sig(nonce_pair_pk,
              Sig.fromBlob(close.our_sig).s
            + Sig.fromBlob(peer_sig).s).toBlob();

        Transaction close_tx
            = close.tx.serializeFull().deserializeFull!Transaction;

        close_tx.inputs[0].unlock = genKeyUnlock(close_multi_sig);

        // note: must always use the execution engine to validate and never
        // try to validate the signatures manually.
        if (auto error = this.engine.execute(
            this.funding_tx_signed.outputs[0].lock, close_tx.inputs[0].unlock,
            close_tx, close_tx.inputs[0]))
            return error;

        // todo: must always validate the tx itself with the validation
        // routine instead of using the engine alone.

        close.tx = close_tx;
        return null;
    }

    // forcefully publish an update transaction with the given index.
    // for use with tests
    version (unittest)
    public Transaction getPublishUpdateIndex (uint index)
    {
        assert(this.channel_updates.length > index + 1);
        const update_tx = this.channel_updates[index].update_tx;
        writefln("%s: Publishing update tx index %s: %s",
            this.kp.V.prettify, index, update_tx.hashFull().prettify);
        this.txPublisher(cast()update_tx);
        return cast()update_tx;
    }

    version (unittest)
    public Transaction getLastSettleTx ()
    {
        return this.channel_updates[$ - 1].settle_tx;
    }

    version (unittest)
    public Transaction getClosingTx ()
    {
        return this.pending_close.tx;
    }
}
