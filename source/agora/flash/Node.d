/*******************************************************************************

    Contains the Flash abstract node definition.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.Node;

import agora.api.FullNode : FullNodeAPI = API;
import agora.common.Amount;
import agora.common.ManagedDatabase;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXO;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr;
import agora.flash.api.FlashAPI;
import agora.flash.Channel;
import agora.flash.Config;
import agora.flash.api.FlashControlAPI;
import agora.flash.api.FlashListenerAPI;
import agora.flash.ErrorCode;
import agora.flash.Invoice;
import agora.flash.Network;
import agora.flash.OnionPacket;
import agora.flash.Route;
import agora.flash.Scripts;
import agora.flash.Types;
import agora.script.Engine;
import agora.serialization.Serializer;
import agora.utils.Log;

import vibe.web.rest;

import core.stdc.time;
import core.time;

import std.algorithm;
import std.container : DList;
import std.conv;
import std.format;
import std.range;
import std.stdio;
import std.traits;
import std.typecons;

/// Gossip type
private enum GossipType
{
    Open,
    Update,
}

/// Outgoing gossip event
private struct GossipEvent
{
    /// Union flag
    GossipType type;

    union
    {
        ChannelConfig open;
        ChannelUpdate update;
    }

    this (ChannelConfig open) @trusted nothrow
    {
        this.type = GossipType.Open;
        this.open = open;
    }

    this (ChannelUpdate update) @trusted nothrow
    {
        this.type = GossipType.Update;
        this.update = update;
    }
}

/// Ditto
public abstract class FlashNode : FlashControlAPI
{
    /// Logger instance
    protected Logger log;

    /// Flash config which remains static after boot but may change after restart
    protected FlashConfig conf;

    /// Hash of the genesis block
    protected const Hash genesis_hash;

    /// All the node metadata
    mixin NodeMetadata!() meta;

    /// Serialization buffer
    private ubyte[] serialize_buffer;

    /// Execution engine
    protected Engine engine;

    /// for scheduling
    protected ITaskManager taskman;

    /// List of outgoing gossip events
    private DList!GossipEvent gossip_queue;

    /// Timer used for gossiping
    private ITimer gossip_timer;

    /// Timer used for opening new channels
    private ITimer open_chan_timer;

    /// Flash network topology
    protected Network network;

    /// List of channels which are pending to be opened
    protected DList!ChannelConfig pending_channels;

    /// All channels which we are the participants of (open / pending / closed)
    protected Channel[Hash] channels;

    /// All known connected peers (used for gossiping)
    protected FlashAPI[Point] known_peers;

    /// Any listener
    protected FlashListenerAPI listener;

    /// Metadata database
    private ManagedDatabase db;

    /***************************************************************************

        Constructor

        Params:
            conf = the configuration of this node
            db_path = path to the database (or in-memory if set to ":memory:")
            genesis_hash = the hash of the genesis block to use
            engine = the execution engine to use
            taskman = the task manager ot use

        Returns:
            the Agora FullNode client

    ***************************************************************************/

    public this (FlashConfig conf, string db_path, Hash genesis_hash,
        Engine engine, ITaskManager taskman)
    {
        this.conf = conf;
        this.genesis_hash = genesis_hash;
        this.engine = engine;
        this.log = Logger(this.conf.key_pair.address.flashPrettify());
        this.taskman = taskman;
        this.db = this.getManagedDatabase(db_path);
        this.load();

        this.channels = Channel.loadChannels(this.conf, this.db,
            &this.getFlashClient, engine, taskman,
            &this.putTransaction, &this.paymentRouter,
            &this.onChannelNotify,
            &this.onPaymentComplete, &this.onUpdateComplete);

        this.network = new Network((Hash chan_id, Point from) {
            if (auto updates = chan_id in this.channel_updates)
            {
                auto config = this.known_channels[chan_id];
                auto dir = from == config.funder_pk ? PaymentDirection.TowardsPeer :
                    PaymentDirection.TowardsOwner;
                if (auto dir_update = dir in *updates)
                    return *dir_update;
            }
            return ChannelUpdate.init;
        });

        foreach (_, chan; this.channels)
            this.network.addChannel(chan.conf);
    }

    /***************************************************************************

        Start the gossiping timer and connect to the listener

    ***************************************************************************/

    public override void start ()
    {
        if (this.conf.listener_address.length != 0)
            this.listener = this.getFlashListenerClient(
                this.conf.listener_address, this.conf.timeout);
        else  // avoid null checks & segfaults
            this.listener = new BlackHole!FlashListenerAPI();

        this.gossip_timer = this.taskman.setTimer(100.msecs,
            &this.gossipTask, Periodic.Yes);
        this.open_chan_timer = this.taskman.setTimer(100.msecs,
            &this.channelOpenTask, Periodic.Yes);
    }

    /***************************************************************************

        Store all the node's and each channels' metadata to the DB,
        and shut down the gossiping timer.

    ***************************************************************************/

    public void shutdown () @safe
    {
        this.gossip_timer.stop();
        this.open_chan_timer.stop();

        try this.dump();
        catch (Exception exc)
        {
            () @trusted {
                printf("Error happened while dumping this node's state: %.*s\n",
                       cast(int) exc.msg.length, exc.msg.ptr);

                scope (failure) assert(0);
                writeln("========================================");
                writeln("Full stack trace: ", exc);
            }();
        }

        foreach (pair; this.channels.byKeyValue)
        {
            try pair.value.dump();
            catch (Exception exc)
            {
                scope (failure) assert(0);
                () @trusted {
                    writefln("Error happened while dumping a channel's (%s) state: %s",
                             pair.key, exc);
                }();
            }
        }
    }

    /***************************************************************************

        Gossiping fiber routine.

    ***************************************************************************/

    private void gossipTask ()
    {
        while (!this.gossip_queue.empty)
        {
            auto event = this.gossip_queue.front;
            this.gossip_queue.removeFront();
            this.handleGossip(event);
            this.taskman.wait(1.msecs);  // yield
        }
    }

    /***************************************************************************

        Fiber routine dedicated to opening channels.

    ***************************************************************************/

    private void channelOpenTask ()
    {
        while (!this.pending_channels.empty)
        {
            auto chan_conf = this.pending_channels.front;
            scope (exit) this.pending_channels.removeFront();
            this.handleOpenNewChannel(chan_conf);
            this.taskman.wait(1.msecs);  // yield
        }
    }

    /// Handle an outgoing gossip event
    private void handleGossip (GossipEvent event)
    {
        final switch (event.type) with (GossipType)
        {
        case Open:
            foreach (pair; this.known_peers.byKeyValue)
            {
                static ChannelConfig[1] open_buffer;
                open_buffer[0] = event.open;
                pair.value.gossipChannelsOpen(open_buffer[]);
            }
            break;

        case Update:
            foreach (pair; this.known_peers.byKeyValue)
            {
                static ChannelUpdate[1] update_buffer;
                update_buffer[0] = event.update;
                pair.value.gossipChannelUpdates(update_buffer[]);
            }
            break;
        }
    }

    /***************************************************************************

        Change the fees for the given channel ID.

        Params:
            chan_id = the channel ID to change the fees for
            fixed_fee = the new fixed fee
            proportional_fee = the new proportional fee

    ***************************************************************************/

    public override void changeFees (Hash chan_id, Amount fixed_fee,
        Amount proportional_fee)
    {
        this.gossipChannelUpdates(
            [this.channels[chan_id].updateFees(fixed_fee, proportional_fee)]);
    }

    /***************************************************************************

        Overridable in tests to test restart behavior.

        Params:
            db_path = path to the database

        Returns:
            a ManagedDatabase instance for the given path

    ***************************************************************************/

    protected ManagedDatabase getManagedDatabase (string db_path)
    {
        return new ManagedDatabase(db_path);
    }

    /***************************************************************************

        Serialize and dump the node metadata to the database.

    ***************************************************************************/

    private void dump () @trusted
    {
        this.serialize_buffer.length = 0;
        () @trusted { assumeSafeAppend(this.serialize_buffer); }();
        scope SerializeDg dg = (in ubyte[] data) @safe
        {
            this.serialize_buffer ~= data;
        };

        foreach (name; __traits(allMembers, this.meta))
        {
            auto field = __traits(getMember, this.meta, name);
            static if (isAssociativeArray!(typeof(field)))
                serializePart(serializeMap(field), dg);
            else
                serializePart(field, dg);
        }

        this.db.execute("REPLACE INTO flash_metadata (meta, data) VALUES (1, ?)",
            this.serialize_buffer);
    }

    /***************************************************************************

        Load any node metadata from the database.

    ***************************************************************************/

    private void load () @trusted
    {
        db.execute("CREATE TABLE IF NOT EXISTS flash_metadata " ~
            "(meta BLOB NOT NULL PRIMARY KEY, data BLOB NOT NULL)");

        auto results = this.db.execute(
            "SELECT data FROM flash_metadata WHERE meta = 1");
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
            else
                *field = deserializeFull!Type(dg);
        }
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

    /***************************************************************************

        Get an instance of a FlashListenerAPI client for the given address.

        Params:
            peer_pk = the public key of the Flash node.
            timeout = the timeout duration to use for requests.

        Returns:
            the FlashListenerAPI client

    ***************************************************************************/

    protected abstract FlashListenerAPI getFlashListenerClient (string address,
        Duration timeout) @trusted;

    /// See `FlashAPI.openChannel`
    public override Result!PublicNonce openChannel (
        /*in*/ ChannelConfig chan_conf, /*in*/ PublicNonce peer_nonce) @trusted
    {
        // todo: verify `chan_conf.funding_utxo`
        log.info("openChannel()");

        if (chan_conf.chan_id in this.channels)
            return Result!PublicNonce(ErrorCode.DuplicateChannelID,
                "There is already an open channel with this ID");

        auto peer = this.getFlashClient(chan_conf.funder_pk, this.conf.timeout);
        if (peer is null)
            return Result!PublicNonce(ErrorCode.AddressNotFound,
                format("Cannot find address of flash node in registry for the key %s",
                    chan_conf.funder_pk));

        if (chan_conf.gen_hash != this.genesis_hash)
            return Result!PublicNonce(ErrorCode.InvalidGenesisHash,
                "Unrecognized blockchain genesis hash");

        if (chan_conf.capacity < this.conf.min_funding ||
            chan_conf.capacity > this.conf.max_funding)
            return Result!PublicNonce(ErrorCode.RejectedFundingAmount,
                format("Funding amount rejected. Want between %s and %s",
                    this.conf.min_funding, this.conf.max_funding));

        if (chan_conf.settle_time < this.conf.min_settle_time ||
            chan_conf.settle_time > this.conf.max_settle_time)
            return Result!PublicNonce(ErrorCode.RejectedSettleTime, format(
                "Settle time rejecteds. Want between %s and %s",
                this.conf.min_settle_time, this.conf.max_settle_time));

        if (auto error = this.listener.onRequestedChannelOpen(chan_conf))
            return Result!PublicNonce(ErrorCode.UserRejectedChannel, error);

        PrivateNonce priv_nonce = genPrivateNonce();
        auto channel = new Channel(this.conf, chan_conf, this.conf.key_pair,
            priv_nonce, peer_nonce, peer, this.engine, this.taskman,
            &this.putTransaction, &this.paymentRouter, &this.onChannelNotify,
            &this.onPaymentComplete, &this.onUpdateComplete, this.db);

        this.channels[chan_conf.chan_id] = channel;
        this.network.addChannel(chan_conf);
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

    protected void onChannelNotify (Hash chan_id, ChannelState state,
        ErrorCode error)
    {
        // gossip to the network
        if (state == ChannelState.Open)
            this.onChannelOpen(this.channels[chan_id].conf);

        this.listener.onChannelNotify(chan_id, state, error);
    }

    ///
    private void onChannelOpen (ChannelConfig conf)
    {
        log.info("onChannelOpen() with channel {}", conf.chan_id);

        this.known_channels[conf.chan_id] = conf;
        this.network.addChannel(conf);

        const dir = this.conf.key_pair.address.data == conf.funder_pk ?
            PaymentDirection.TowardsPeer : PaymentDirection.TowardsOwner;
        // Set the initial fees
        // todo: this should be configurable
        auto update = this.channels[conf.chan_id].getChannelUpdate();
        this.channel_updates[conf.chan_id][dir] = update;

        // todo: should not gossip this to counterparty of the just opened channel
        this.gossip_queue.insertBack(GossipEvent(conf));
        this.gossip_queue.insertBack(GossipEvent(update));

        this.dump();
    }

    /// See `FlashAPI.gossipChannelsOpen`
    public override void gossipChannelsOpen ( ChannelConfig[] chan_configs )
    {
        log.info("gossipChannelsOpen() with {} channels", chan_configs.length);

        ChannelConfig[] to_gossip;
        foreach (conf; chan_configs)
        {
            if (conf.chan_id in this.known_channels)
                continue;

            log.info("gossipChannelsOpen(): Discovered: {}",
                     conf.chan_id.flashPrettify);

            // todo: need to verify the blockchain actually contains the
            // funding transaction, otherwise this becomes a point of DDoS.
            this.known_channels[conf.chan_id] = conf;
            this.network.addChannel(conf);

            to_gossip ~= conf;  // gossip only new channels
        }

        // also gossip new channels to peers later
        to_gossip.each!(chan =>
            this.gossip_queue.insertBack(GossipEvent(chan)));
    }

    /// See `FlashAPI.gossipChannelUpdates`
    public void gossipChannelUpdates (ChannelUpdate[] chan_updates)
    {
        log.info("gossipChannelUpdates() with {} channels", chan_updates.length);

        ChannelUpdate[] to_gossip;
        foreach (update; chan_updates)
        {
            if (auto conf = update.chan_id in this.known_channels)
            {
                auto pk = update.direction == PaymentDirection.TowardsPeer ?
                                                conf.funder_pk : conf.peer_pk;
                if (auto chan_update = update.chan_id in this.channel_updates)
                    if (auto dir_update = update.direction in *chan_update)
                    {
                        if (*dir_update == update // same fees as before
                            || update.update_idx <= dir_update.update_idx)  // must be newer (replay attacks)
                            continue;
                    }

                if (!verify(pk, update.sig, update))
                    continue;
                this.channel_updates[update.chan_id][update.direction] = update;
                to_gossip ~= update;
                this.dump();
            }
        }

        // also gossip new updates to peers later
        to_gossip.each!(update =>
            this.gossip_queue.insertBack(GossipEvent(update)));
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
    public override Result!bool confirmChannelUpdate (/* in */ Hash chan_id,
        /* in */ uint seq_id) @trusted
    {
        if (auto channel = chan_id in this.channels)
            return channel.onConfirmedChannelUpdate(seq_id);

        return Result!bool(ErrorCode.InvalidChannelID,
            "Channel ID not found");
    }

    /// See `FlashAPI.proposePayment`
    public override Result!PublicNonce proposePayment (/* in */ Hash chan_id,
        /* in */ uint seq_id, /* in */ Hash payment_hash,
        /* in */ Amount amount, /* in */ Height lock_height,
        /* in */ OnionPacket packet, /* in */ PublicNonce peer_nonce,
        /* in */ Height height) @trusted
    {
        if (packet.version_byte != OnionVersion)
            return Result!PublicNonce(ErrorCode.VersionMismatch,
                "Protocol version mismatch");

        auto channel = chan_id in this.channels;
        if (channel is null)
            return Result!PublicNonce(ErrorCode.InvalidChannelID,
                "Channel ID not found");

        if (!packet.ephemeral_pk.isValid())
            return Result!PublicNonce(ErrorCode.InvalidOnionPacket,
                "Ephemeral public key in the onion packet is invalid");

        Payload payload;
        Point shared_secret;
        if (!decryptPayload(packet.encrypted_payloads[0], this.conf.key_pair.secret,
            packet.ephemeral_pk, payload, shared_secret))
            return Result!PublicNonce(ErrorCode.InvalidOnionPacket,
                "Cannot decrypt onion packet payload");

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
        /* in */ PublicNonce peer_nonce, /* in */ Height height) @trusted
    {
        auto channel = chan_id in this.channels;
        if (channel is null)
            return Result!PublicNonce(ErrorCode.InvalidChannelID,
                "Channel ID not found");

        if (height != this.last_height)
            return Result!PublicNonce(ErrorCode.MismatchingBlockHeight,
                format("Mismatching block height! Our: %s Their %s",
                    this.last_height, height));

        return channel.onProposedUpdate(seq_id, secrets, rev_htlcs, peer_nonce,
            height);
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
            size_t failing_hop_idx = shared_secrets.length - 1;
            foreach (idx, secret; shared_secrets)
            {
                if (chans.canFind(deobfuscated.chan_id))
                {
                    failing_hop_idx = idx;
                    break;
                }
                deobfuscated = deobfuscated.obfuscate(secret);
            }
            if (!chans.canFind(deobfuscated.chan_id))
                return;

            // Get the PublicKey of the node we think is failing
            const failing_node_pk = (*path)[failing_hop_idx].pub_key;
            const failing_chan = this.known_channels[deobfuscated.chan_id];
            // Check the failing node is a peer of the failing channel
            if (failing_chan.funder_pk != failing_node_pk &&
                failing_chan.peer_pk != failing_node_pk)
                return;

            log.info(this.conf.key_pair.address.flashPrettify, " Got error: ",
                deobfuscated);
            this.payment_errors[deobfuscated.payment_hash] ~= deobfuscated;
            this.dump();
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

        // we only report failures here. success is only reported after
        // a successfull update
        if (error != ErrorCode.None)
        {
            if (auto invoice = payment_hash in this.invoices)
                this.listener.onPaymentFailure(*invoice, error);
        }

        // our own secret (we are the payee)
        if (auto secret = payment_hash in this.secrets)
        {
            assert(!error); // Payee should never fail to receive
            channel.learnSecrets([*secret], [], this.last_height);
        }
        else if (error)
        {
            foreach (id, chan; this.channels)
                chan.learnSecrets([], [payment_hash], this.last_height);
            this.reportPaymentError(chan_id, OnionError(payment_hash,
                chan_id, error));
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

            // get the invoice if it exists and not just the pointer (GC safety)
            Invoice inv;
            auto invoice = this.invoices.get(payment_hash, Invoice.init);
            this.invoices.remove(payment_hash);

            if (invoice != Invoice.init)
                this.listener.onPaymentSuccess(invoice);
        }

        foreach (payment_hash; rev_htlcs)
        {
            if (auto invoice = payment_hash in this.invoices)
            {
                ErrorCode error;
                if (auto errors = payment_hash in this.payment_errors)
                    error = (*errors)[$ - 1].err;  // pick latest known reason
                else
                    error = ErrorCode.Unknown;

                this.listener.onPaymentFailure(*invoice, error);
            }
        }

        foreach (chan_id, channel; this.channels)
        {
            log.info("Calling learnSecrets for {}", chan_id);
            channel.learnSecrets(secrets, rev_htlcs, this.last_height);
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
                packet, this.last_height);

        log.info("{} Could not find this channel ID: {}",
            this.conf.key_pair.address.flashPrettify, chan_id);
        this.onPaymentComplete(chan_id, payment_hash,
            ErrorCode.InvalidChannelID);
    }

    ///
    public override Result!bool beginCollaborativeClose (/* in */ Hash chan_id)
    {
        if (auto channel = chan_id in this.channels)
            return channel.beginCollaborativeClose();

        return Result!bool(ErrorCode.InvalidChannelID, "Channel ID not found");
    }

    ///
    public override Result!bool beginUnilateralClose (/* in */ Hash chan_id)
    {
        if (auto channel = chan_id in this.channels)
            return channel.beginUnilateralClose();

        return Result!bool(ErrorCode.InvalidChannelID, "Channel ID not found");
    }

    ///
    public override Result!Hash openNewChannel (/* in */ Hash funding_utxo,
        /* in */ Amount capacity, /* in */ uint settle_time,
        /* in */ Point peer_pk)
    {
        log.info("openNewChannel({}, {}, {})",
                 capacity, settle_time, peer_pk.flashPrettify);

        const pair_pk = this.conf.key_pair.address + peer_pk;

        // create funding, don't sign it yet as we'll share it first
        auto funding_tx = createFundingTx(funding_utxo, capacity,
            pair_pk);

        const funding_tx_hash = hashFull(funding_tx);
        const Hash chan_id = funding_tx_hash;

        auto all_funding_utxos = this.pending_channels[].chain(
                channels.byValue.map!(chan => chan.conf))
            .map!(conf => conf.funding_tx_hash);

        // this channel is already being set up (or duplicate funding UTXO used)
        if (all_funding_utxos.canFind(funding_tx_hash))
        {
            return Result!Hash(ErrorCode.DuplicateChannelID,
                "Cannot open another channel with the same UTXO as a "
                ~ "pending / existing channel");
        }

        const num_peers = 2;
        ChannelConfig chan_conf =
        {
            gen_hash        : this.genesis_hash,
            funder_pk       : this.conf.key_pair.address,
            peer_pk         : peer_pk,
            pair_pk         : this.conf.key_pair.address + peer_pk,
            num_peers       : num_peers,
            update_pair_pk  : getUpdatePk(pair_pk, funding_tx_hash, num_peers),
            funding_tx      : funding_tx,
            funding_tx_hash : funding_tx_hash,
            funding_utxo    : UTXO.getHash(funding_tx.hashFull(), 0),
            capacity        : capacity,
            settle_time     : settle_time,
        };
        this.pending_channels.insertBack(chan_conf);

        return Result!Hash(chan_id);
    }

    /// Handle opening new channels
    private void handleOpenNewChannel (ChannelConfig chan_conf)
    {
        auto peer = this.getFlashClient(chan_conf.peer_pk, this.conf.timeout);
        if (peer is null)
        {
            this.listener.onChannelNotify(chan_conf.chan_id,
                ChannelState.Rejected, ErrorCode.AddressNotFound);
            return;
        }

        PrivateNonce priv_nonce = genPrivateNonce();
        PublicNonce pub_nonce = priv_nonce.getPublicNonce();

        auto result = peer.openChannel(chan_conf, pub_nonce);
        if (result.error != ErrorCode.None)
        {
            this.listener.onChannelNotify(chan_conf.chan_id,
                ChannelState.Rejected, result.error);
            return;
        }

        auto channel = new Channel(this.conf, chan_conf, this.conf.key_pair,
            priv_nonce, result.value, peer, this.engine, this.taskman,
            &this.putTransaction, &this.paymentRouter, &this.onChannelNotify,
            &this.onPaymentComplete, &this.onUpdateComplete, this.db);
        this.channels[chan_conf.chan_id] = channel;
        this.listener.onChannelNotify(chan_conf.chan_id,
            ChannelState.SettingUp, ErrorCode.None);
    }

    ///
    public void waitChannelOpen (/* in */ Hash chan_id)
    {
        auto channel = chan_id in this.channels;
        assert(channel !is null);

        const state = channel.getState();
        if (state >= ChannelState.StartedCollaborativeClose)
        {
            log.info("Error: waitChannelOpen({}) called on channel state {}",
                chan_id.flashPrettify, state);
            return;
        }

        while (!channel.isOpen())
            this.taskman.wait(100.msecs);
    }

    ///
    public override Invoice createNewInvoice (/* in */ Amount amount,
        /* in */ time_t expiry, /* in */ string description = null)
    {
        log.info("createNewInvoice({}, {}, {})",
            amount, expiry, description);

        auto pair = createInvoice(this.conf.key_pair.address, amount, expiry, description);
        this.invoices[pair.invoice.payment_hash] = pair.invoice;
        this.secrets[pair.invoice.payment_hash] = pair.secret;
        this.dump();

        return pair.invoice;
    }

    /// Finds a payment path for the invoice and attempts to pay it
    public override void payInvoice (/* in */ Invoice invoice)
    {
        if (!this.isValidInvoice(invoice))
            assert(0);  // todo: should just reject it when we write test for it

        Set!Hash ignore_chans;
        if (auto error = invoice.payment_hash in this.payment_errors)
            ignore_chans = Set!Hash.from((*error).map!(err => err.chan_id));

        auto path = this.network.getPaymentPath(this.conf.key_pair.address,
            invoice.destination, invoice.amount, ignore_chans);
        if (path.length < 1 || path.length > MaxPathLength)
        {
            this.listener.onPaymentFailure(invoice, ErrorCode.PathNotFound);
            return;
        }

        Amount total_amount;
        Height use_lock_height;
        Point[] cur_shared_secrets;
        auto packet = createOnionPacket(invoice.payment_hash, invoice.amount,
            path, total_amount, use_lock_height, cur_shared_secrets);
        this.shared_secrets[invoice.payment_hash] = cur_shared_secrets.reverse;
        this.payment_path[invoice.payment_hash] = path;
        this.invoices[invoice.payment_hash] = invoice;

        // If suggested lock height is not enough, use settle_time + htlc_delta
        auto first_conf = this.known_channels[path.front.chan_id];
        auto first_update = this.channels[path.front.chan_id].getChannelUpdate();
        use_lock_height = max(use_lock_height,
            Height(first_conf.settle_time + first_update.htlc_delta));

        use_lock_height = Height(use_lock_height + this.last_height);

        this.paymentRouter(path.front.chan_id, invoice.payment_hash,
            total_amount, use_lock_height, packet);
        this.dump();
    }

    ///
    private bool isValidInvoice (/* in */ Invoice invoice)
    {
        // paying to ourself doesn't make sense
        if (invoice.destination == this.conf.key_pair.address)
            return false;

        return true;
    }
}

/// All the node metadata which we keep in the DB for storage
private mixin template NodeMetadata ()
{
    /// These are the known channels of which we may not necessary be a
    /// counterparty of. With this information we can derive payment paths.
    protected ChannelConfig[Hash] known_channels;

    /// Most recent update received for this channel
    protected ChannelUpdate[PaymentDirection][Hash] channel_updates;

    /// The last read block height.
    protected Height last_height;

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

    /// hash of secret => Invoice
    private Invoice[Hash] invoices;
}

/// A thin Flash node which itself is not a FullNode / Validator but instead
/// interacts with another FullNode / Validator for queries to the blockchain.
public abstract class ThinFlashNode : FlashNode
{
    /// random agora node (for sending tx's)
    protected FullNodeAPI agora_node;

    /// monitor timer
    protected ITimer monitor_timer;

    /***************************************************************************

        Constructor

        Params:
            conf = Flash configuration
            db_path = path to the database (or in-memory if set to ":memory:")
            genesis_hash = the hash of the genesis block to use
            engine = the execution engine to use
            taskman = the task manager ot use
            agora_address = IP address of an Agora node to monitor the
                blockchain and publish new on-chain transactions to it.

    ***************************************************************************/

    public this (FlashConfig conf, string db_path, Hash genesis_hash,
        Engine engine, ITaskManager taskman, string agora_address)
    {
        this.agora_node = this.getAgoraClient(agora_address, conf.timeout);
        super(conf, db_path, genesis_hash, engine, taskman);
    }

    /***************************************************************************

        Start monitoring the blockchain for any new externalized blocks.

    ***************************************************************************/

    public override void start ()
    {
        // todo: 20 msecs is ok only in tests
        // todo: should additionally register as pushBlock() listener
        this.monitor_timer = this.taskman.setTimer(20.msecs,
            &this.monitorBlockchain, Periodic.Yes);
        super.start();
    }

    /***************************************************************************

        Shut down any timers and store latest data to the database

    ***************************************************************************/

    public override void shutdown ()
    {
        super.shutdown();
        if (this.monitor_timer !is null)
            this.monitor_timer.stop();
    }

    /***************************************************************************

        Monitors the blockchain for any new externalized blocks.

        If a funding / closing / trigger / update / settlement transaction
        belong to a channel is detected, it will trigger that channel's
        handler for this event.

        This enables changing the channel's state from open to closed.

    ***************************************************************************/

    private void monitorBlockchain ()
    {
        try
        {
            auto latest_height = this.agora_node.getBlockHeight();
            if (this.last_height < latest_height)
            {
                auto next_block = this.agora_node.getBlocksFrom(
                    this.last_height + 1, 1)[0];

                foreach (channel; this.channels)
                    channel.onBlockExternalized(next_block);

                this.last_height++;
                this.dump();
            }
        }
        catch (Exception ex)
        {
            // connection might be dropped
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
    /// Callback for sending transactions to the network
    protected void delegate (Transaction tx) putTransactionDg;

    /// get a Flash client for the given public key
    protected FlashAPI delegate (in Point peer_pk, Duration timeout)
        flashClientGetter;

    /// get a Flash listener client for the given address
    protected FlashListenerAPI delegate (in string address, Duration timeout)
        flashListenerGetter;

    /***************************************************************************

        Constructor

        Params:
            conf = Flash configuration
            db_path = path to the database (or in-memory if set to ":memory:")
            genesis_hash = the hash of the genesis block to use
            engine = the execution engine to use
            taskman = the task manager ot use
            putTransactionDg = callback for sending transactions to the network
            flashListenerGetter = getter for the Flash listener client

    ***************************************************************************/

    public this (FlashConfig conf, string db_path, Hash genesis_hash,
        Engine engine, ITaskManager taskman,
        void delegate (Transaction tx) putTransactionDg,
        FlashAPI delegate (in Point, Duration) flashClientGetter,
        FlashListenerAPI delegate (in string address, Duration timeout)
            flashListenerGetter)
    {
        this.putTransactionDg = putTransactionDg;
        this.flashClientGetter = flashClientGetter;
        this.flashListenerGetter = flashListenerGetter;
        super(conf, db_path, genesis_hash, engine, taskman);
    }

    /// Called by a FullNode once a block has been externalized
    public void onExternalizedBlock (const ref Block block) @safe
    {
        this.last_height = block.header.height;

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
        this.putTransactionDg(tx);
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
        if (this.known_channels.length > 0)
            peer.gossipChannelsOpen(this.known_channels.values);

        return peer;
    }

    /***************************************************************************

        Get an instance of a FlashListenerAPI client for the given address.

        Params:
            address = the IP to use
            timeout = the timeout duration to use for requests

        Returns:
            the FlashListenerAPI client

    ***************************************************************************/

    protected override FlashListenerAPI getFlashListenerClient (string address,
        Duration timeout) @trusted
    {
        return this.flashListenerGetter(address, timeout);
    }
}
