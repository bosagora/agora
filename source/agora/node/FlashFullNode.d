/*******************************************************************************

    Implementation of the FlashFullNode

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.FlashFullNode;

import agora.api.FullNode;
import agora.api.handler.Block;
import agora.api.handler.PreImage;
import agora.api.handler.Transaction;
import agora.consensus.data.Block;
import agora.common.Amount;
import agora.common.BanManager;
import agora.common.Config;
import agora.common.Metadata;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.Fee;
import agora.consensus.state.UTXOSet;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr;
import agora.flash.API;
import agora.flash.Config;
import agora.flash.ErrorCode;
import agora.flash.Invoice;
import agora.flash.Node;
import agora.flash.OnionPacket;
import agora.flash.Types;
import agora.network.Clock;
import agora.network.Client;
import agora.network.Manager;
import agora.node.BlockStorage;
import agora.node.FullNode;
import agora.node.Ledger;
import agora.node.TransactionPool;
import agora.script.Engine;
import agora.serialization.Serializer;
import agora.stats.App;
import agora.stats.EndpointReq;
import agora.stats.Server;
import agora.stats.Utils;
import agora.utils.Log;
import agora.utils.PrettyPrinter;
import agora.utils.Utility;

import scpd.types.Utils;

import vibe.data.json;
import vibe.web.rest;

import std.algorithm;
import std.conv : to;
import std.exception;
import std.file;
import std.path : buildPath;
import std.range;

import core.time;

/// Common routines implemented by both FlashFullNode / FlashValidator.
/// Cannot use multiple inheritance in D.
public mixin template FlashNodeCommon ()
{
    private ExtendedFlashAPI getFlashClient (in Point peer_pk, Duration timeout)
    {
        // todo: need to retry later
        // todo: need a key => IP mapping (maybe through the NameRegistryAPI?)
        auto pk = PublicKey(peer_pk[]);
        log.info("getFlashClient searching peer: {}", pk);
        auto ip = this.network.getAddress(pk);
        enforce(ip !is null, "Could not find mapping of key => IP");

        import vibe.http.client;

        auto settings = new RestInterfaceSettings;
        // todo: this is obviously wrong, need proper connection handling later
        settings.baseURL = URL(ip);
        settings.httpClientSettings = new HTTPClientSettings;
        settings.httpClientSettings.connectTimeout = timeout;
        settings.httpClientSettings.readTimeout = timeout;

        return new RestInterfaceClient!ExtendedFlashAPI(settings);
    }

    /***************************************************************************

        Called when a block was externalized.

        Calls pushBlock(), but additionally the Validator overrides this
        and implements quorum shuffling.

        Params:
            block = the new block
            validators_changed = whether the validator set has changed

    ***************************************************************************/

    protected override void onAcceptedBlock (in Block block,
        bool validators_changed) @safe
    {
        super.onAcceptedBlock(block, validators_changed);
        this.flash.onExternalizedBlock(block);
    }

    ///
    public override Result!PublicNonce openChannel (
        /* in */ ChannelConfig chan_conf,
        /* in */ PublicNonce peer_nonce) @trusted
    {
        return this.flash.openChannel(chan_conf, peer_nonce);
    }

    ///
    public override Result!Point closeChannel (/* in */ Hash chan_id,
        /* in */ uint seq_id, /* in */ Point peer_nonce, /* in */ Amount fee)
        @trusted
    {
        return this.flash.closeChannel(chan_id, seq_id, peer_nonce, fee);
    }

    ///
    public override void gossipChannelsOpen (ChannelConfig[] chan_configs)
        @trusted
    {
        this.flash.gossipChannelsOpen(chan_configs);
    }

    ///
    public override void gossipChannelUpdates (ChannelUpdate[] chan_updates)
        @trusted
    {
        this.flash.gossipChannelUpdates(chan_updates);
    }

    ///
    public override Result!ChannelState getChannelState (/* in */ Hash chan_id)
        @trusted
    {
        return this.flash.getChannelState(chan_id);
    }

    ///
    public override Result!PublicNonce proposePayment (/* in */ Hash chan_id,
        /* in */ uint seq_id, /* in */ Hash payment_hash,
        /* in */ Amount amount, /* in */ Height lock_height,
        /* in */ OnionPacket packet, /* in */ PublicNonce peer_nonce,
        /* in */ Height height) @trusted
    {
        return this.flash.proposePayment(chan_id, seq_id, payment_hash,
            amount, lock_height, packet, peer_nonce, height);
    }

    ///
    public override Result!PublicNonce proposeUpdate (/* in */ Hash chan_id,
        /* in */ uint seq_id, /* in */ Hash[] secrets,
        /* in */ Hash[] rev_htlcs, /* in */ PublicNonce peer_nonce,
        /* in */ Height block_height) @trusted
    {
        return this.flash.proposeUpdate(chan_id, seq_id, secrets, rev_htlcs,
            peer_nonce, block_height);
    }

    ///
    public override Result!Signature requestSettleSig (/* in */ Hash chan_id,
        /* in */ uint seq_id) @trusted
    {
        return this.flash.requestSettleSig(chan_id, seq_id);
    }

    ///
    public override Result!Signature requestUpdateSig (/* in */ Hash chan_id,
        /* in */ uint seq_id) @trusted
    {
        return this.flash.requestUpdateSig(chan_id, seq_id);
    }

    ///
    public override void confirmChannelUpdate (/* in */ Hash chan_id,
        /* in */ uint seq_id) @trusted
    {
        this.flash.confirmChannelUpdate(chan_id, seq_id);
    }

    ///
    public override Result!Signature requestCloseSig (/* in */ Hash chan_id,
        /* in */ uint seq_id) @trusted
    {
        return this.flash.requestCloseSig(chan_id, seq_id);
    }

    ///
    public override void reportPaymentError (/* in */ Hash chan_id,
        /* in */ OnionError err) @trusted
    {
        this.flash.reportPaymentError(chan_id, err);
    }
}

///
public class FlashFullNode : FullNode, FlashFullNodeAPI
{
    /// Logger instance
    private Logger log;

    /// Flash node
    protected AgoraFlashNode flash;

    /***************************************************************************

        Constructor

        Params:
            config = Config instance

    ***************************************************************************/

    public this (const Config config)
    {
        super(config);
        assert(this.config.flash.enabled);
        assert(!this.config.validator.enabled);
        const flash_path = buildPath(this.config.node.data_dir, "flash.dat");
        this.flash = new AgoraFlashNode(this.config.flash,
            flash_path, hashFull(this.params.Genesis), this.engine,
            this.taskman, this, &this.getFlashClient);
    }

    public override void start ()
    {
        super.start();

        if (this.config.flash.testing)
        {
            // we know we're a full node, and the key we use is in
            // `this.config.flash.key_pair`
            log.info("This flash node is in testing mode!");
        }
    }

    public override void shutdown ()
    {
        this.flash.shutdown();
    }

    public override void receiveInvoice (Invoice invoice)
    {
        // todo: no-op
    }

    mixin FlashNodeCommon!();
}
