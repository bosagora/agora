/*******************************************************************************

    Contains the Flash abstract node definition.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.Node;

import agora.api.FullNode : FullNodeAPI = API;
import agora.common.Amount;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXO;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Schnorr;
import agora.flash.API;
import agora.flash.Channel;
import agora.flash.Config;
import agora.flash.ControlAPI;
import agora.flash.ErrorCode;
import agora.flash.Invoice;
import agora.flash.Network;
import agora.flash.OnionPacket;
import agora.flash.Route;
import agora.flash.Scripts;
import agora.flash.Types;
import agora.script.Engine;
import agora.utils.Log;

import vibe.web.rest;

import core.stdc.time;
import core.time;

import std.algorithm;
import std.conv;
import std.format;
import std.range;
import std.stdio;

mixin AddLogger!();

/// A thin Flash node which itself is not a FullNode / Validator but instead
/// interacts with another FullNode / Validator for queries to the blockchain.
public abstract class ThinFlashNode : FlashNode
{
    /// random agora node (for sending tx's)
    protected FullNodeAPI agora_node;

    /***************************************************************************

        Constructor

        Params:
            kp = The key-pair of this node
            genesis_hash = the hash of the genesis block to use
            taskman = the task manager ot use
            agora_address = IP address of an Agora node to monitor the
                blockchain and publish new on-chain transactions to it.

    ***************************************************************************/

    public this (const Pair kp, Hash genesis_hash, TaskManager taskman,
        string agora_address)
    {
        Duration timeout;  // infinite timeout (todo: fixup)
        this.agora_node = this.getAgoraClient(agora_address, timeout);
        super(kp, genesis_hash, taskman);
    }

    /***************************************************************************

        Start monitoring the blockchain for any new externalized blocks.

    ***************************************************************************/

    public void start ()
    {
        // todo: 200 msecs is ok only in tests
        // todo: should additionally register as pushBlock() listener
        this.taskman.setTimer(200.msecs, &this.monitorBlockchain, Periodic.Yes);
    }

    /***************************************************************************

        Monitors the blockchain for any new externalized blocks.

        If a funding / closing / trigger / update / settlement transaction
        belong to a channel is detected, it will trigger that channel's
        handler for this event.

        This enables changing the channel's state from open to closed.

        TODO: replace by having FullNode inherit from FlashNode and getting
        everything block-related for free.

        TODO: Must check HTLC timeouts in any of the channels, and then
        propose an update via proposeUpdate().

    ***************************************************************************/

    private void monitorBlockchain ()
    {
        while (1)
        {
            auto latest_height = this.agora_node.getBlockHeight();
            if (this.last_block_height < latest_height)
            {
                auto next_block = this.agora_node.getBlocksFrom(
                    this.last_block_height + 1, 1)[0];

                foreach (channel; this.channels)
                    channel.onBlockExternalized(next_block);

                this.last_block_height++;
            }

            this.taskman.wait(0.msecs);  // yield
        }
    }

    /***************************************************************************

        Get an instance of an Agora client.

        Params:
            address = The address (IPv4, IPv6, hostname) of the Agora node.
            timeout = the timeout duration to use for requests.

        Returns:
            the Agora FullNode client

    ***************************************************************************/

    protected FullNodeAPI getAgoraClient (Address address, Duration timeout)
    {
        import vibe.http.client;

        auto settings = new RestInterfaceSettings;
        settings.baseURL = URL(address);
        settings.httpClientSettings = new HTTPClientSettings;
        settings.httpClientSettings.connectTimeout = timeout;
        settings.httpClientSettings.readTimeout = timeout;

        return new RestInterfaceClient!FullNodeAPI(settings);
    }

    /***************************************************************************

        Send the transaction via the connected agora node.

        Params:
            tx = the transaction to send

    ***************************************************************************/

    protected override void putTransaction (Transaction tx)
    {
        this.agora_node.putTransaction(tx);
    }
}

/// A FullNode / Validator should embed this class if they enabled Flash
public class AgoraFlashNode : FlashNode
{
    /// random agora node (for sending tx's)
    protected FullNodeAPI agora_node;

    /// get a Flash client for the given public key
    protected FlashAPI delegate (in Point peer_pk, Duration timeout)
        flashClientGetter;

    /***************************************************************************

        Constructor

        Params:
            kp = The key-pair of this node
            genesis_hash = the hash of the genesis block to use
            taskman = the task manager ot use
            agora_address = IP address of an Agora node to monitor the
                blockchain and publish new on-chain transactions to it.

    ***************************************************************************/

    public this (const Pair kp, Hash genesis_hash, TaskManager taskman,
        FullNodeAPI agora_node,
        FlashAPI delegate (in Point, Duration) flashClientGetter)
    {
        this.agora_node = agora_node;
        this.flashClientGetter = flashClientGetter;
        super(kp, genesis_hash, taskman);
    }

    /// No-op, FullNode will notify us of externalized blocks
    public void start ()
    {
    }

    /// Called by a FullNode once a block has been externalized
    public void onExternalizedBlock (const ref Block block) @safe
    {
        this.last_block_height = block.header.height;

        foreach (channel; this.channels)
            channel.onBlockExternalized(block);
    }

    /***************************************************************************

        Send the transaction via the connected agora node.

        Params:
            tx = the transaction to send

    ***************************************************************************/

    protected override void putTransaction (Transaction tx)
    {
        this.agora_node.putTransaction(tx);
    }

    /***************************************************************************

        Get an instance of a Flash client for the given public key.

        TODO: What if we don't have an IP mapping?

        Params:
            peer_pk = the public key of the Flash node.
            timeout = the timeout duration to use for requests.

        Returns:
            the Flash client

    ***************************************************************************/

    protected override FlashAPI getFlashClient (in Point peer_pk,
        Duration timeout) @trusted
    {
        if (auto peer = peer_pk in this.known_peers)
            return *peer;

        auto peer = this.flashClientGetter(peer_pk, timeout);
        this.known_peers[peer_pk] = peer;
        peer.gossipChannelsOpen(this.known_channels.values);

        return peer;
    }
}

/// Ditto
public abstract class FlashNode : ControlFlashAPI
{
    /// Schnorr key-pair belonging to this node
    protected const Pair kp;

    /// Hash of the genesis block
    protected const Hash genesis_hash;

    /// Execution engine
    protected Engine engine;

    /// for scheduling
    protected TaskManager taskman;

    /// Channels which are pending and not accepted yet.
    /// Once the channel handshake is complete and only after the funding
    /// transaction is externalized, the Channel channel gets promoted
    /// to a Channel with a unique ID derived from the hash of the funding tx.
    protected Channel[Hash] channels;
    protected Channel[][Hash] channels_by_key;

    /// These are the known channels of which we may not necessary be a
    /// counterparty of. With this information we can derive payment paths.
    protected ChannelConfig[Hash] known_channels;

    /// Most recent update received for this channel
    protected ChannelUpdate[PaymentDirection][Hash] channel_updates;

    /// All known connected peers (used for gossiping)
    protected FlashAPI[Point] known_peers;

    /// The last read block height.
    protected Height last_block_height;

    /// secret hash => secret (preimage)
    /// Only the Payee initially knows about the secret,
    /// but is then revealed back towards the payer through
    /// any intermediaries.
    protected Hash[Hash] secrets;

    /// Shared secrets used to encrypt the OnionPacket
    protected Point[][Hash] shared_secrets;

    /// Path that is currently being tried for a payment
    protected Hop[][Hash] payment_path;

    /// Errors that are received for payments
    protected OnionError[][Hash] payment_errors;

    /// Flash network topology
    protected Network network;

    /// hash of secret => Invoice
    private Invoice[Hash] invoices;

    /***************************************************************************

        Constructor

        Params:
            kp = The key-pair of this node
            genesis_hash = the hash of the genesis block to use
            taskman = the task manager ot use

        Returns:
            the Agora FullNode client

    ***************************************************************************/

    public this (const Pair kp, Hash genesis_hash, TaskManager taskman)
    {
        this.genesis_hash = genesis_hash;
        const TestStackMaxTotalSize = 16_384;
        const TestStackMaxItemSize = 512;
        this.engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
        this.kp = kp;
        this.taskman = taskman;
        this.network = new Network((Hash chan_id) {
            if (auto chan = chan_id in this.channels)
                return *chan;
            return null;
        });
    }

    /***************************************************************************

        Get an instance of a Flash client for the given public key.

        Params:
            peer_pk = the public key of the Flash node.
            timeout = the timeout duration to use for requests.

        Returns:
            the Flash client

    ***************************************************************************/

    protected abstract FlashAPI getFlashClient (in Point peer_pk,
        Duration timeout) @trusted;

    /// See `FlashAPI.openChannel`
    public override Result!PublicNonce openChannel (
        /*in*/ ChannelConfig chan_conf, /*in*/ PublicNonce peer_nonce) @trusted
    {
        // todo: verify `chan_conf.funding_utxo`
        log.info("{}: openChannel()", this.kp.V.flashPrettify);

        if (chan_conf.chan_id in this.channels)
            return Result!PublicNonce(ErrorCode.DuplicateChannelID,
                "There is already an open channel with this ID");

        // todo: move to initialization stage!
        auto peer = this.getFlashClient(chan_conf.funder_pk, Duration.init);

        if (chan_conf.gen_hash != this.genesis_hash)
            return Result!PublicNonce(ErrorCode.InvalidGenesisHash,
                "Unrecognized blockchain genesis hash");

        const min_funding = Amount(1000);
        if (chan_conf.capacity < min_funding)
            return Result!PublicNonce(ErrorCode.FundingTooLow,
                format("Funding amount is too low. Want at least %s", min_funding));

        // todo: re-enable
        version (none)
        {
            const min_settle_time = 5;
            const max_settle_time = 10;
            if (chan_conf.settle_time < min_settle_time ||
                chan_conf.settle_time > max_settle_time)
                return OpenResult("Settle time is not within acceptable limits");
        }

        PrivateNonce priv_nonce = genPrivateNonce();
        auto channel = new Channel(chan_conf, this.kp, priv_nonce, peer_nonce,
            peer, this.engine, this.taskman, &this.putTransaction,
            &this.paymentRouter, &this.onChannelOpen, &this.onPaymentComplete,
            &this.onUpdateComplete);

        this.channels[chan_conf.chan_id] = channel;
        this.network.addChannel(chan_conf);

        // todo: simplify
        if (chan_conf.chan_id in this.channels_by_key)
            this.channels_by_key[chan_conf.chan_id] = [channel];
        else
            this.channels_by_key[chan_conf.chan_id] ~= channel;

        PublicNonce pub_nonce = priv_nonce.getPublicNonce();
        return Result!PublicNonce(pub_nonce);
    }

    /// Overriden by ThinFlashNode or FullNode
    protected abstract void putTransaction (Transaction tx);

    /// See `FlashAPI.closeChannel`
    public override Result!Point closeChannel (/* in */ Hash chan_id,
        /* in */ uint seq_id, /* in */ Point peer_nonce, /* in */ Amount fee )
        @trusted
    {
        if (auto channel = chan_id in this.channels)
            return channel.requestCloseChannel(seq_id, peer_nonce, fee);

        return Result!Point(ErrorCode.InvalidChannelID,
            "Channel ID not found");
    }

    ///
    protected void onChannelOpen (ChannelConfig conf)
    {
        this.taskman.setTimer(0.seconds,
        {
            log.info("{}: onChannelOpen() with channel {}",
                this.kp.V.flashPrettify, conf.chan_id);

            this.known_channels[conf.chan_id] = conf;
            this.network.addChannel(conf);

            const dir = this.kp.V == conf.funder_pk ?
                PaymentDirection.TowardsPeer : PaymentDirection.TowardsOwner;
            // Set the initial fees
            // todo: this should be configurable
            auto update = ChannelUpdate(conf.chan_id, dir,
                Amount(1), Amount(1));
            update.sig = sign(this.kp, update);
            this.channel_updates[conf.chan_id][dir] = update;
            // todo: should not gossip this to counterparty of the just opened channel
            foreach (peer; this.known_peers.byValue())
            {
                peer.gossipChannelsOpen([conf]);
                peer.gossipChannelUpdates([this.channel_updates[conf.chan_id][dir]]);
            }
        });
    }

    /// See `FlashAPI.gossipChannelsOpen`
    public override void gossipChannelsOpen ( ChannelConfig[] chan_configs )
    {
        log.info("{}: gossipChannelsOpen() with {} channels",
            this.kp.V.flashPrettify, chan_configs.length);

        ChannelConfig[] to_gossip;
        foreach (conf; chan_configs)
        {
            if (conf.chan_id in this.known_channels)
                continue;

            log.info("{}: gossipChannelsOpen(): Discovered: {}",
                this.kp.V.flashPrettify, conf.chan_id.flashPrettify);

            // todo: need to verify the blockchain actually contains the
            // funding transaction, otherwise this becomes a point of DDoS.
            this.known_channels[conf.chan_id] = conf;
            this.network.addChannel(conf);

            to_gossip ~= conf;  // gossip only new channels
        }

        if (!to_gossip.length)
            return;

        // also gossip new channels to peers
        foreach (peer; this.known_peers.byValue())
            peer.gossipChannelsOpen(to_gossip);
    }

    /// See `FlashAPI.gossipChannelUpdates`
    public void gossipChannelUpdates (ChannelUpdate[] chan_updates)
    {
        log.info("{}: gossipChannelUpdates() with {} channels",
            this.kp.V.flashPrettify, chan_updates.length);

        ChannelUpdate[] to_gossip;
        foreach (update; chan_updates)
        {
            if (auto conf = update.chan_id in this.known_channels)
            {
                auto pk = update.direction == PaymentDirection.TowardsPeer ?
                                                conf.funder_pk : conf.peer_pk;
                if (auto chan_update = update.chan_id in this.channel_updates)
                    if (auto dir_update = update.direction in *chan_update)
                        if (*dir_update == update)
                            continue;
                if (!verify(pk, update.sig, update))
                    continue;
                this.channel_updates[update.chan_id][update.direction] = update;
                to_gossip ~= update;
            }
        }

        if (!to_gossip.length)
            return;

        foreach (peer; this.known_peers.byValue())
            peer.gossipChannelUpdates(to_gossip);
    }

    /// See `FlashAPI.requestCloseSig`
    public override Result!Signature requestCloseSig (/* in */ Hash chan_id,
        /* in */ uint seq_id) @trusted
    {
        if (auto channel = chan_id in this.channels)
            return channel.requestCloseSig(seq_id);

        return Result!Signature(ErrorCode.InvalidChannelID,
            "Channel ID not found");
    }

    /// See `FlashAPI.getChannelState`
    public override Result!ChannelState getChannelState (/* in */ Hash chan_id)
        @trusted
    {
        if (auto channel = chan_id in this.channels)
            return Result!ChannelState(channel.getState());

        return Result!ChannelState(ErrorCode.InvalidChannelID,
            "Channel ID not found");
    }

    /// See `FlashAPI.requestSettleSig`
    public override Result!Signature requestSettleSig (/* in */ Hash chan_id,
        /* in */ uint seq_id) @trusted
    {
        if (auto channel = chan_id in this.channels)
            return channel.onRequestSettleSig(seq_id);

        return Result!Signature(ErrorCode.InvalidChannelID,
            "Channel ID not found");
    }

    /// See `FlashAPI.requestUpdateSig`
    public override Result!Signature requestUpdateSig (/* in */ Hash chan_id,
        /* in */ uint seq_id) @trusted
    {
        if (auto channel = chan_id in this.channels)
            return channel.onRequestUpdateSig(seq_id);

        return Result!Signature(ErrorCode.InvalidChannelID,
            "Channel ID not found");
    }

    /// See `FlashAPI.confirmChannelUpdate`
    public override void confirmChannelUpdate (/* in */ Hash chan_id,
        /* in */ uint seq_id) @trusted
    {
        if (auto channel = chan_id in this.channels)
            return channel.onConfirmedChannelUpdate(seq_id);

        //return;  // todo: return error on invalid channel ID
    }

    /// See `FlashAPI.proposePayment`
    public override Result!PublicNonce proposePayment (/* in */ Hash chan_id,
        /* in */ uint seq_id, /* in */ Hash payment_hash,
        /* in */ Amount amount, /* in */ Height lock_height,
        /* in */ OnionPacket packet, /* in */ PublicNonce peer_nonce,
        /* in */ Height height) @trusted
    {
        auto channel = chan_id in this.channels;
        if (channel is null)
            return Result!PublicNonce(ErrorCode.InvalidChannelID,
                "Channel ID not found");

        Payload payload;
        Point shared_secret;
        if (!decryptPayload(packet.encrypted_payloads[0], this.kp.v,
            packet.ephemeral_pk, payload, shared_secret))
        {
            log.info("{} --- ERROR: CANNOT DECRYPT PAYLOAD", this.kp.V.flashPrettify);
            return Result!PublicNonce(ErrorCode.CantDecrypt);
        }

        if (payload.next_chan_id != Hash.init
            && payload.next_chan_id !in this.channels)
            return Result!PublicNonce(ErrorCode.InvalidChannelID,
                "Cannot accept this forwarded payment as it routes to an "
                ~ "unrecognized channel ID");

        return channel.onProposedPayment(seq_id, payment_hash, amount,
            lock_height, packet, payload, peer_nonce, height, shared_secret);
    }

    /// See `FlashAPI.proposeUpdate`
    public override Result!PublicNonce proposeUpdate (/* in */ Hash chan_id,
        /* in */ uint seq_id, /* in */ Hash[] secrets, /* in */ Hash[] rev_htlcs,
        /* in */ PublicNonce peer_nonce, /* in */ Height block_height) @trusted
    {
        auto channel = chan_id in this.channels;
        if (channel is null)
            return Result!PublicNonce(ErrorCode.InvalidChannelID,
                "Channel ID not found");

        if (block_height != this.last_block_height)
            return Result!PublicNonce(ErrorCode.MismatchingBlockHeight,
                format("Mismatching block height! Our: %s Their %s",
                    this.last_block_height, block_height));

        return channel.onProposedUpdate(seq_id, secrets, rev_htlcs, peer_nonce,
            block_height);
    }

    /// See `FlashAPI.reportPaymentError`
    public override void reportPaymentError (/* in */ Hash chan_id,
        /* in */ OnionError err)
    {
        import std.algorithm.searching : canFind;

        if (auto path = err.payment_hash in this.payment_path)
        {
            auto shared_secrets = this.shared_secrets[err.payment_hash];
            assert(shared_secrets.length == path.length);

            auto chans = (*path).map!(hop => hop.chan_id);
            OnionError deobfuscated = err;
            foreach (secret; shared_secrets)
            {
                if (chans.canFind(deobfuscated.chan_id))
                    break;
                deobfuscated = deobfuscated.obfuscate(secret);
            }

            if (chans.canFind(deobfuscated.chan_id))
            {
                log.info(this.kp.V.flashPrettify, " Got error: ", deobfuscated);
                this.payment_errors[deobfuscated.payment_hash] ~= deobfuscated;
            }
        }
        else
            foreach (id, channel; this.channels)
                if (id != chan_id)
                    channel.forwardPaymentError(err);
    }

    /***************************************************************************

        Called by a channel once a payment has been completed.

        If the there are any known secrets, we can propose an update to the
        channel state by revealing the secrets to the counter-parties.

        Params:
            chan_id = the channel ID for which the payment was completed
            payment_hash = the payment hash which was used

    ***************************************************************************/

    protected void onPaymentComplete (Hash chan_id, Hash payment_hash,
        ErrorCode error = ErrorCode.None)
    {
        auto channel = chan_id in this.channels;
        if (channel is null)
        {
            // todo: assert?
            log.info("Error: Channel not found: {}", chan_id);
            return;
        }

        // our own secret (we are the payee)
        if (auto secret = payment_hash in this.secrets)
        {
            assert(!error); // Payee should never fail to receive
            channel.learnSecrets([*secret], [], this.last_block_height);
        }
        else if (error)
        {
            foreach (id, chan; this.channels)
                chan.learnSecrets([], [payment_hash], this.last_block_height);
            this.reportPaymentError(chan_id, OnionError(Hash.init,
                payment_hash, chan_id, error));
            if (auto invoice = payment_hash in this.invoices)
                this.payInvoice(*invoice); // Retry
        }
    }

    /***************************************************************************

        Called by a channel once an update has been completed.

        For any channels which use the same payment hash, the node will
        try to update the channel by settling the HTLCs.

        Params:
            secrets = list of secrets revealed during an update
            rev_htlcs = list of htlcs dropped during an update

    ***************************************************************************/

    protected void onUpdateComplete (in Hash[] secrets,
        in Hash[] rev_htlcs)
    {
        foreach (payment_hash; secrets.map!(secret => secret.hashFull()))
        {
            this.secrets.remove(payment_hash);
            this.shared_secrets.remove(payment_hash);
            this.payment_path.remove(payment_hash);
            this.payment_errors.remove(payment_hash);
            this.invoices.remove(payment_hash);
        }

        foreach (payment_hash; rev_htlcs)
            if (auto invoice = payment_hash in this.invoices)
                this.payInvoice(*invoice); // Retry

        foreach (chan_id, channel; this.channels)
        {
            log.info("{}: Calling learnSecrets for {}", this.kp.V.flashPrettify,
                chan_id);
            channel.learnSecrets(secrets, rev_htlcs, this.last_block_height);
        }
    }

    /***************************************************************************

        Routes an onion-encrypted payment to the given channel ID.

        Params:
            chan_id = the channel ID to route the payment to
            payment_hash = the payment hash to use
            amount = the amount to use
            lock_height = the lock the HTLC will use
            packet = the onion-encrypted packet for the channel counter-party

        Returns:
            Error code

    ***************************************************************************/

    protected void paymentRouter (in Hash chan_id,
        in Hash payment_hash, in Amount amount,
        in Height lock_height, in OnionPacket packet)
    {
        if (auto channel = chan_id in this.channels)
            return channel.queueNewPayment(payment_hash, amount, lock_height,
                packet, this.last_block_height);

        log.info("{} Could not find this channel ID: {}", this.kp.V.flashPrettify,
            chan_id);
        this.onPaymentComplete(chan_id, payment_hash,
            ErrorCode.InvalidChannelID);
    }

    ///
    public override void beginCollaborativeClose (/* in */ Hash chan_id)
    {
        auto channel = chan_id in this.channels;
        assert(channel !is null);
        channel.beginCollaborativeClose();
    }

    ///
    public override Hash openNewChannel (/* in */ Hash funding_utxo,
        /* in */ Amount capacity, /* in */ uint settle_time,
        /* in */ Point peer_pk)
    {
        log.info("{}: openNewChannel({}, {}, {})", this.kp.V.flashPrettify,
            capacity, settle_time, peer_pk.flashPrettify);

        // todo: move to initialization stage!
        auto peer = this.getFlashClient(peer_pk, Duration.init);
        const pair_pk = this.kp.V + peer_pk;

        // create funding, don't sign it yet as we'll share it first
        auto funding_tx = createFundingTx(funding_utxo, capacity,
            pair_pk);

        const funding_tx_hash = hashFull(funding_tx);
        const Hash chan_id = funding_tx_hash;
        const num_peers = 2;

        const ChannelConfig chan_conf =
        {
            gen_hash        : this.genesis_hash,
            funder_pk       : this.kp.V,
            peer_pk         : peer_pk,
            pair_pk         : this.kp.V + peer_pk,
            num_peers       : num_peers,
            update_pair_pk  : getUpdatePk(pair_pk, funding_tx_hash, num_peers),
            funding_tx      : funding_tx,
            funding_tx_hash : funding_tx_hash,
            funding_utxo    : UTXO.getHash(funding_tx.hashFull(), 0),
            capacity        : capacity,
            settle_time     : settle_time,
        };

        PrivateNonce priv_nonce = genPrivateNonce();
        PublicNonce pub_nonce = priv_nonce.getPublicNonce();

        auto result = peer.openChannel(cast(ChannelConfig)chan_conf, pub_nonce);
        assert(result.error == ErrorCode.None, result.to!string);

        auto channel = new Channel(chan_conf, this.kp, priv_nonce, result.value,
            peer, this.engine, this.taskman, &this.putTransaction,
            &this.paymentRouter, &this.onChannelOpen, &this.onPaymentComplete,
            &this.onUpdateComplete);
        this.channels[chan_id] = channel;

        return chan_id;
    }

    ///
    public override void waitChannelOpen (/* in */ Hash chan_id)
    {
        auto channel = chan_id in this.channels;
        assert(channel !is null);

        const state = channel.getState();
        if (state >= ChannelState.PendingClose)
        {
            log.info("{}: Error: waitChannelOpen({}) called on channel state {}",
                this.kp.V.flashPrettify, chan_id.flashPrettify, state);
            return;
        }

        while (!channel.isOpen())
            this.taskman.wait(100.msecs);
    }

    ///
    public override Invoice createNewInvoice (/* in */ Amount amount,
        /* in */ time_t expiry, /* in */ string description = null)
    {
        log.info("{}: createNewInvoice({}, {}, {})", this.kp.V.flashPrettify,
            amount, expiry, description);

        auto pair = createInvoice(this.kp.V, amount, expiry, description);
        this.invoices[pair.invoice.payment_hash] = pair.invoice;
        this.secrets[pair.invoice.payment_hash] = pair.secret;

        return pair.invoice;
    }

    /// Finds a payment path for the invoice and attempts to pay it
    public override void payInvoice (/* in */ Invoice invoice)
    {
        if (!this.isValidInvoice(invoice))
            assert(0);  // todo: should just reject it when we write test for it

        // todo: should not be hardcoded.
        // todo: isn't the payee supposed to set this?
        // the lock height for the end node. The first hop will have the biggest
        // lock height, gradually reducing with each hop until destination node.
        Height end_lock_height = Height(this.last_block_height + 100);

        Set!Hash ignore_chans;
        if (auto error = invoice.payment_hash in this.payment_errors)
            ignore_chans = Set!Hash.from((*error).map!(err => err.chan_id));

        // find a route
        // todo: not implemented properly yet as capacity, individual balances, and
        // fees are not taken into account yet. Only up to two channels assumed here.
        auto path = this.network.getPaymentPath(this.kp.V, invoice.destination,
            invoice.amount, ignore_chans);
        Amount total_amount;
        Height use_lock_height;
        Point[] cur_shared_secrets;
        auto packet = createOnionPacket(invoice.payment_hash, end_lock_height,
            invoice.amount, path, total_amount, use_lock_height, cur_shared_secrets);
        this.shared_secrets[invoice.payment_hash] = cur_shared_secrets.reverse;
        this.payment_path[invoice.payment_hash] = path;
        this.invoices[invoice.payment_hash] = invoice;

        this.paymentRouter(path.front.chan_id, invoice.payment_hash,
            total_amount, use_lock_height, packet);
    }

    ///
    private bool isValidInvoice (/* in */ Invoice invoice)
    {
        // paying to ourself doesn't make sense
        if (invoice.destination == this.kp.V)
            return false;

        return true;
    }
}
