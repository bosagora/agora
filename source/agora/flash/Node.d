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
import agora.serialization.Serializer;
import agora.utils.Log;

import vibe.web.rest;

import core.stdc.time;
import core.time;

import std.algorithm;
import std.conv;
import std.format;
import std.range;
import std.stdio;
import std.traits;

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
        Duration timeout;  // infinite timeout (todo: fixup)
        this.agora_node = this.getAgoraClient(agora_address, timeout);
        super(conf, db_path, genesis_hash, engine, taskman);
    }

    /***************************************************************************

        Start monitoring the blockchain for any new externalized blocks.

    ***************************************************************************/

    public void start ()
    {
        // todo: 200 msecs is ok only in tests
        // todo: should additionally register as pushBlock() listener
        this.monitor_timer = this.taskman.setTimer(200.msecs,
            &this.monitorBlockchain, Periodic.Yes);
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

        TODO: replace by having FullNode inherit from FlashNode and getting
        everything block-related for free.

        TODO: Must check HTLC timeouts in any of the channels, and then
        propose an update via proposeUpdate().

    ***************************************************************************/

    private void monitorBlockchain ()
    {
        while (1)
        {
            try
            {
                auto latest_height = this.agora_node.getBlockHeight();
                if (this.last_block_height < latest_height)
                {
                    auto next_block = this.agora_node.getBlocksFrom(
                        this.last_block_height + 1, 1)[0];

                    foreach (channel; this.channels)
                        channel.onBlockExternalized(next_block);

                    this.last_block_height++;
                    this.dump();
                }
            }
            catch (Exception ex)
            {
                // connection might be dropped
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
            conf = Flash configuration
            db_path = path to the database (or in-memory if set to ":memory:")
            genesis_hash = the hash of the genesis block to use
            engine = the execution engine to use
            taskman = the task manager ot use
            agora_address = IP address of an Agora node to monitor the
                blockchain and publish new on-chain transactions to it.

    ***************************************************************************/

    public this (FlashConfig conf, string db_path, Hash genesis_hash,
        Engine engine, ITaskManager taskman, FullNodeAPI agora_node,
        FlashAPI delegate (in Point, Duration) flashClientGetter)
    {
        this.agora_node = agora_node;
        this.flashClientGetter = flashClientGetter;
        super(conf, db_path, genesis_hash, engine, taskman);
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

    /// Flash network topology
    protected Network network;

    /// All channels which we are the participants of (open / pending / closed)
    protected Channel[Hash] channels;

    /// All known connected peers (used for gossiping)
    protected FlashAPI[Point] known_peers;

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

        this.channels = Channel.loadChannels(this.db,
            &this.getFlashClient,engine, taskman,
            &this.putTransaction, &this.paymentRouter,
            &this.onChannelOpen,
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

        Store all the node's and each channels' metadata to the DB

    ***************************************************************************/

    public void shutdown ()
    {
        this.dump();
        foreach (chan; channels.byValue)
            chan.dump();
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

    /// See `FlashAPI.openChannel`
    public override Result!PublicNonce openChannel (
        /*in*/ ChannelConfig chan_conf, /*in*/ PublicNonce peer_nonce) @trusted
    {
        // todo: verify `chan_conf.funding_utxo`
        log.info("openChannel()");

        if (chan_conf.chan_id in this.channels)
            return Result!PublicNonce(ErrorCode.DuplicateChannelID,
                "There is already an open channel with this ID");

        // todo: move to initialization stage!
        auto peer = this.getFlashClient(chan_conf.funder_pk, Duration.init);

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

        PrivateNonce priv_nonce = genPrivateNonce();
        auto channel = new Channel(chan_conf, this.conf.key_pair, priv_nonce,
            peer_nonce, peer, this.engine, this.taskman, &this.putTransaction,
            &this.paymentRouter, &this.onChannelOpen, &this.onPaymentComplete,
            &this.onUpdateComplete, this.db);

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

    ///
    protected void onChannelOpen (ChannelConfig conf)
    {
        this.taskman.setTimer(0.seconds,
        {
            log.info("onChannelOpen() with channel {}", conf.chan_id);

            this.known_channels[conf.chan_id] = conf;
            this.network.addChannel(conf);

            const dir = this.conf.key_pair.address.data == conf.funder_pk ?
                PaymentDirection.TowardsPeer : PaymentDirection.TowardsOwner;
            // Set the initial fees
            // todo: this should be configurable
            auto update = ChannelUpdate(conf.chan_id, dir,
                Amount(1), Amount(1));
            update.sig = this.conf.key_pair.sign(update);
            this.channel_updates[conf.chan_id][dir] = update;
            // todo: should not gossip this to counterparty of the just opened channel
            foreach (peer; this.known_peers.byValue())
            {
                peer.gossipChannelsOpen([conf]);
                peer.gossipChannelUpdates([this.channel_updates[conf.chan_id][dir]]);
            }

            this.dump();
        });
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

        if (!to_gossip.length)
            return;

        // also gossip new channels to peers
        foreach (peer; this.known_peers.byValue())
            peer.gossipChannelsOpen(to_gossip);
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
                        if (*dir_update == update)
                            continue;
                if (!verify(pk, update.sig, update))
                    continue;
                this.channel_updates[update.chan_id][update.direction] = update;
                to_gossip ~= update;
                this.dump();
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
                log.info(this.conf.key_pair.address.flashPrettify, " Got error: ",
                    deobfuscated);
                this.payment_errors[deobfuscated.payment_hash] ~= deobfuscated;
                this.dump();
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
            log.info("Calling learnSecrets for {}", chan_id);
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

        log.info("{} Could not find this channel ID: {}",
            this.conf.key_pair.address.flashPrettify, chan_id);
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
    public override Result!Hash openNewChannel (/* in */ Hash funding_utxo,
        /* in */ Amount capacity, /* in */ uint settle_time,
        /* in */ Point peer_pk)
    {
        log.info("openNewChannel({}, {}, {})",
                 capacity, settle_time, peer_pk.flashPrettify);

        // todo: move to initialization stage!
        auto peer = this.getFlashClient(peer_pk, Duration.init);
        const pair_pk = this.conf.key_pair.address + peer_pk;

        // create funding, don't sign it yet as we'll share it first
        auto funding_tx = createFundingTx(funding_utxo, capacity,
            pair_pk);

        const funding_tx_hash = hashFull(funding_tx);
        const Hash chan_id = funding_tx_hash;
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

        PrivateNonce priv_nonce = genPrivateNonce();
        PublicNonce pub_nonce = priv_nonce.getPublicNonce();

        auto result = peer.openChannel(chan_conf, pub_nonce);
        if (result.error != ErrorCode.None)
            return Result!Hash(result.error, result.message);

        auto channel = new Channel(chan_conf, this.conf.key_pair, priv_nonce,
            result.value, peer, this.engine, this.taskman, &this.putTransaction,
            &this.paymentRouter, &this.onChannelOpen, &this.onPaymentComplete,
            &this.onUpdateComplete, this.db);
        this.channels[chan_id] = channel;

        return Result!Hash(chan_id);
    }

    ///
    public override void waitChannelOpen (/* in */ Hash chan_id)
    {
        auto channel = chan_id in this.channels;
        assert(channel !is null);

        const state = channel.getState();
        if (state >= ChannelState.PendingClose)
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
        auto path = this.network.getPaymentPath(this.conf.key_pair.address,
            invoice.destination, invoice.amount, ignore_chans);
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

    /// hash of secret => Invoice
    private Invoice[Hash] invoices;
}
