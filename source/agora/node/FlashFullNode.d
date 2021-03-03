/*******************************************************************************

    Implementation of the FlashFullNode

    Copyright:
        Copyright (c) 2019 - 2021 BOS Platform Foundation Korea
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
import agora.common.crypto.Key;
import agora.common.Serializer;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.Fee;
import agora.consensus.state.UTXODB;
import agora.consensus.EnrollmentManager;
import agora.consensus.Fee;
import agora.crypto.ECC;
import agora.crypto.Hash;
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

mixin AddLogger!();

///
public class FlashFullNode : FullNode, FlashFullNodeAPI
{
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

        immutable kp = Pair(this.config.flash.key_pair.secret,
            this.config.flash.key_pair.secret.toPoint);
        this.flash = new AgoraFlashNode(kp, hashFull(this.params.Genesis),
            this.taskman, this, &this.getFlashClient);
    }

    private ExtendedFlashAPI getFlashClient (in Point peer_pk, Duration timeout)
    {
        // todo: need to retry later
        // todo: need a key => IP mapping (maybe through the NameRegistryAPI?)
        import std.stdio;
        auto pk = PublicKey(peer_pk[]);
        writefln("getFlashClient searching peer: %s", pk);
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

    public override void start ()
    {
        super.start();

        if (this.config.flash.testing)
        {
            // we know we're a full node, and the key we use is in
            // `this.config.flash.key_pair`
            import std.stdio;
            writeln("This flash node is in testing mode!");
        }
    }

    public override void receiveInvoice (Invoice invoice)
    {
        // todo: no-op
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
