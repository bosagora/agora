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
import agora.common.crypto.ECC;
import agora.common.crypto.Schnorr;
import agora.common.Hash;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Transaction;
import agora.flash.API;
import agora.flash.Channel;
import agora.flash.Config;
import agora.flash.ErrorCode;
import agora.flash.Invoice;
import agora.flash.OnionPacket;
import agora.flash.Scripts;
import agora.flash.Types;
import agora.script.Engine;

import vibe.web.rest;

import core.stdc.time;
import core.time;

import std.format;
import std.stdio;

/// Ditto
public abstract class FlashNode : FlashAPI
{
    /// Schnorr key-pair belonging to this node
    protected const Pair kp;

    /// Hash of the genesis block
    protected const Hash genesis_hash;

    /// random agora node
    protected FullNodeAPI agora_node;

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

    /// All known connected peers (used for gossiping)
    protected FlashAPI[Point] known_peers;

    /// The last read block height.
    protected Height last_block_height;

    /// secret hash => secret (preimage)
    /// Only the Payee initially knows about the secret,
    /// but is then revealed back towards the payer through
    /// any intermediaries.
    protected Hash[Hash] secrets;

    /***************************************************************************

        Get an instance of an Agora client.

        Params:
            address = The address (IPv4, IPv6, hostname) of the Agora node.
            genesis_hash = the hash of the genesis block to use
            taskman = the task manager ot use
            agora_address = IP address of an Agora node to monitor the
                blockchain and publish new on-chain transactions to it.

        Returns:
            the Agora FullNode client

    ***************************************************************************/

    public this (const Pair kp, Hash genesis_hash, TaskManager taskman,
        string agora_address)
    {
        this.genesis_hash = genesis_hash;
        const TestStackMaxTotalSize = 16_384;
        const TestStackMaxItemSize = 512;
        this.engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
        this.kp = kp;
        this.taskman = taskman;
        Duration timeout;
        this.agora_node = this.getAgoraClient(agora_address, timeout);
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

        Get an instance of a Flash client.

        Params:
            address = The address (IPv4, IPv6, hostname) of the Flash node.
            timeout = the timeout duration to use for requests.

        Returns:
            the Flash client

    ***************************************************************************/

    protected FlashAPI getFlashClient (in Point peer_pk, Duration timeout)
    {
        if (auto peer = peer_pk in this.known_peers)
            return *peer;

        import vibe.http.client;
        import std.conv : to;

        auto settings = new RestInterfaceSettings;
        // todo: this is obviously wrong, need proper connection handling later
        settings.baseURL = URL(peer_pk.to!string);
        settings.httpClientSettings = new HTTPClientSettings;
        settings.httpClientSettings.connectTimeout = timeout;
        settings.httpClientSettings.readTimeout = timeout;

        auto peer = new RestInterfaceClient!FlashAPI(settings);
        this.known_peers[peer_pk] = peer;
        peer.gossipChannelsOpen(this.known_channels.values);

        return peer;
    }

    /***************************************************************************

        Start monitoring the blockchain for any new externalized blocks.

    ***************************************************************************/

    public void startMonitoring ()
    {
        // todo: 200 msecs is ok only in tests
        // todo: should additionally register as pushBlock() listener
        this.taskman.setTimer(200.msecs, &this.monitorBlockchain, Periodic.Yes);
    }

    /// See `FlashAPI.openChannel`
    public override Result!PublicNonce openChannel (in ChannelConfig chan_conf,
        in PublicNonce peer_nonce)
    {
        // todo: verify `chan_conf.funding_utxo`
        writefln("%s: openChannel()", this.kp.V.prettify);

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
            peer, this.engine, this.taskman, &this.agora_node.putTransaction,
            &this.paymentRouter, &this.onChannelOpen, &this.onPaymentComplete,
            &this.onUpdateComplete);

        this.channels[chan_conf.chan_id] = channel;

        // todo: simplify
        if (chan_conf.chan_id in this.channels_by_key)
            this.channels_by_key[chan_conf.chan_id] = [channel];
        else
            this.channels_by_key[chan_conf.chan_id] ~= channel;

        PublicNonce pub_nonce = priv_nonce.getPublicNonce();
        return Result!PublicNonce(pub_nonce);
    }

    /// See `FlashAPI.closeChannel`
    public override Result!Point closeChannel (in Hash chan_id,
        in uint seq_id, in Point peer_nonce, in Amount fee )
    {
        if (auto channel = chan_id in this.channels)
            return channel.requestCloseChannel(seq_id, peer_nonce, fee);

        return Result!Point(ErrorCode.InvalidChannelID,
            "Channel ID not found");
    }

    ///
    protected void onChannelOpen (ChannelConfig conf)
    {
        writefln("%s: onChannelOpen() with channel %s",
            this.kp.V.prettify, conf.chan_id);

        this.known_channels[conf.chan_id] = conf;

        // todo: should not gossip this to counterparty of the just opened channel
        foreach (peer; this.known_peers.byValue())
            peer.gossipChannelsOpen([conf]);
    }

    /// See `FlashAPI.gossipChannelsOpen`
    public override void gossipChannelsOpen ( ChannelConfig[] chan_configs )
    {
        writefln("%s: gossipChannelsOpen() with %s channels",
            this.kp.V.prettify, chan_configs.length);

        ChannelConfig[] to_gossip;
        foreach (conf; chan_configs)
        {
            if (conf.chan_id in this.known_channels)
                continue;

            writefln("%s: gossipChannelsOpen(): Discovered: %s",
                this.kp.V.prettify, conf.chan_id.prettify);

            // todo: need to verify the blockchain actually contains the
            // funding transaction, otherwise this becomes a point of DDoS.
            this.known_channels[conf.chan_id] = conf;

            to_gossip ~= conf;  // gossip only new channels
        }

        if (!to_gossip.length)
            return;

        // also gossip new channels to peers
        foreach (peer; this.known_peers.byValue())
            peer.gossipChannelsOpen(to_gossip);
    }

    /// See `FlashAPI.requestCloseSig`
    public override Result!Signature requestCloseSig (in Hash chan_id,
        in uint seq_id)
    {
        if (auto channel = chan_id in this.channels)
            return channel.requestCloseSig(seq_id);

        return Result!Signature(ErrorCode.InvalidChannelID,
            "Channel ID not found");
    }

    /// See `FlashAPI.getChannelState`
    public override Result!ChannelState getChannelState (in Hash chan_id)
    {
        if (auto channel = chan_id in this.channels)
            return Result!ChannelState(channel.getState());

        return Result!ChannelState(ErrorCode.InvalidChannelID,
            "Channel ID not found");
    }

    /// See `FlashAPI.requestSettleSig`
    public override Result!Signature requestSettleSig (in Hash chan_id,
        in uint seq_id)
    {
        if (auto channel = chan_id in this.channels)
            return channel.onRequestSettleSig(seq_id);

        return Result!Signature(ErrorCode.InvalidChannelID,
            "Channel ID not found");
    }

    /// See `FlashAPI.requestUpdateSig`
    public override Result!Signature requestUpdateSig (in Hash chan_id,
        in uint seq_id)
    {
        if (auto channel = chan_id in this.channels)
            return channel.onRequestUpdateSig(seq_id);

        return Result!Signature(ErrorCode.InvalidChannelID,
            "Channel ID not found");
    }

    /// See `FlashAPI.proposePayment`
    public override Result!PublicNonce proposePayment (in Hash chan_id,
        in uint seq_id, in Hash payment_hash, in Amount amount,
        in Height lock_height, in OnionPacket packet, in PublicNonce peer_nonce,
        in Height height)
    {
        auto channel = chan_id in this.channels;
        if (channel is null)
            return Result!PublicNonce(ErrorCode.InvalidChannelID,
                "Channel ID not found");

        Payload payload;
        if (!decryptPayload(packet.encrypted_payload, this.kp.v,
            packet.ephemeral_pk, payload))
        {
            writefln("%s --- ERROR: CANNOT DECRYPT PAYLOAD", this.kp.V.prettify);
            return Result!PublicNonce(ErrorCode.CantDecrypt);
        }

        if (payload.next_chan_id != Hash.init
            && payload.next_chan_id !in this.channels)
            return Result!PublicNonce(ErrorCode.InvalidChannelID,
                "Cannot accept this forwarded payment as it routes to an "
                ~ "unrecognized channel ID");

        return channel.onProposedPayment(seq_id, payment_hash, amount,
            lock_height, payload, peer_nonce, height);
    }

    /// See `FlashAPI.proposeUpdate`
    public override Result!PublicNonce proposeUpdate (in Hash chan_id,
        in uint seq_id, in Hash[] secrets, in PublicNonce peer_nonce,
        in Height block_height)
    {
        auto channel = chan_id in this.channels;
        if (channel is null)
            return Result!PublicNonce(ErrorCode.InvalidChannelID,
                "Channel ID not found");

        if (block_height != this.last_block_height)
            return Result!PublicNonce(ErrorCode.MismatchingBlockHeight,
                "Mismatching block height!");

        return channel.onProposedUpdate(seq_id, secrets, peer_nonce, block_height);
    }

    /// See `FlashAPI.isCollectingSignatures`
    public override Result!bool isCollectingSignatures (in Hash chan_id)
    {
        auto channel = chan_id in this.channels;
        if (channel is null)
            return Result!bool(ErrorCode.InvalidChannelID,
                "Channel ID not found");

        return Result!bool(channel.isCollectingSignatures());
    }

    /***************************************************************************

        Called by a channel once a payment has been completed.

        If the there are any known secrets, we can propose an update to the
        channel state by revealing the secrets to the counter-parties.

        Params:
            chan_id = the channel ID for which the payment was completed
            payment_hash = the payment hash which was used

    ***************************************************************************/

    protected void onPaymentComplete (Hash chan_id, Hash payment_hash)
    {
        // our own secret (we are the payee)
        if (auto secret = payment_hash in this.secrets)
        {
            auto channel = chan_id in this.channels;
            if (channel is null)
            {
                // todo: assert?
                writefln("Error: Channel not found: %s", chan_id);
                return;
            }

            channel.proposeNewUpdate([*secret], this.last_block_height);
        }
    }

    /***************************************************************************

        Called by a channel once an update has been completed.

        For any channels which use the same payment hash, the node will
        try to update the channel by settling the HTLCs.

        Params:
            secrets = list of secrets revealed during an update

    ***************************************************************************/

    protected void onUpdateComplete (in Hash[] secrets)
    {
        foreach (chan_id, channel; this.channels)
        {
            writefln("Calling learnSecrets for %s", chan_id);
            channel.learnSecrets(secrets, this.last_block_height);
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

    ***************************************************************************/

    protected void paymentRouter (in Hash chan_id, in Hash payment_hash,
        in Amount amount, in Height lock_height, in OnionPacket packet)
    {
        if (auto channel = chan_id in this.channels)
            return channel.routeNewPayment(payment_hash, amount, lock_height,
                packet, this.last_block_height);

        // todo: what to do in this case?
        // todo: should probably check this before accepting the
        // initial payment
        writefln("Could not find this channel ID: %s", chan_id);
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
}
