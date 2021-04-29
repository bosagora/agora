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
import agora.flash.api.FlashAPI;
import agora.flash.api.FlashListenerAPI;
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
import agora.registry.API;
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
    import agora.utils.InetUtils;
    import core.stdc.time;

    /// Flash node
    protected AgoraFlashNode flash;

    /// Periodic name registry timer
    protected ITimer periodic_timer;

    /// Registry client
    private NameRegistryAPI registry_client;

    // start the periodic name registry routine
    private void startNameRegistry ()
    {
        this.onRegisterName();  // avoid delay
        this.periodic_timer = this.taskman.setTimer(2.minutes,
            &this.onRegisterName, Periodic.Yes);
    }

    /// register network addresses into the name registry
    private void onRegisterName ()
    {
        if (this.registry_client is null)  // try to get the client
            this.registry_client = this.network.getNameRegistryClient(
                this.config.flash.registry_address, 10.seconds);

        if (this.registry_client is null)
            return;  // failed, try again later

        const(Address)[] addresses = this.config.flash.addresses_to_register;
        if (!addresses.length)
            addresses = InetUtils.getPublicIPs();

        foreach (pair; this.flash.getManagedKeys())
        {
            RegistryPayload payload =
            {
                data:
                {
                    public_key : pair.key,
                    addresses : addresses,
                    seq : time(null)
                }
            };

            const key_pair = KeyPair.fromSeed(pair.value);
            payload.signPayload(key_pair);

            try
            {
                this.registry_client.putValidator(payload);
            }
            catch (Exception ex)
            {
                log.info("Couldn't register our address: {}. Trying again later..",
                    ex);
            }
        }
    }

    private ExtendedFlashAPI getFlashClient (in Point peer_pk, Duration timeout)
    {
        // todo: need to retry later
        // todo: need a key => IP mapping (maybe through the NameRegistryAPI?)
        auto pk = PublicKey(peer_pk[]);
        log.info("getFlashClient searching peer: {}", pk);

        auto payload = this.registry_client.getValidator(pk);
        if (payload == RegistryPayload.init)
        {
            log.warn("Could not find mapping in registry for key {}", peer_pk);
            return null;
        }

        if (!payload.verifySignature(pk))
        {
            log.warn("RegistryPayload signature is incorrect for {}", peer_pk);
            return null;
        }

        if (payload.data.addresses.length == 0)
            return null;

        string ip = payload.data.addresses[0];

        import vibe.http.client;

        auto settings = new RestInterfaceSettings;
        // todo: this is obviously wrong, need proper connection handling later
        settings.baseURL = URL(ip);
        settings.httpClientSettings = new HTTPClientSettings;
        settings.httpClientSettings.connectTimeout = timeout;
        settings.httpClientSettings.readTimeout = timeout;

        return new RestInterfaceClient!ExtendedFlashAPI(settings);
    }

    private FlashListenerAPI getFlashListenerClient (in string address,
        Duration timeout)
    {
        import vibe.http.client;

        auto settings = new RestInterfaceSettings;
        // todo: this is obviously wrong, need proper connection handling later
        settings.baseURL = URL(address);
        settings.httpClientSettings = new HTTPClientSettings;
        settings.httpClientSettings.connectTimeout = timeout;
        settings.httpClientSettings.readTimeout = timeout;

        return new RestInterfaceClient!FlashListenerAPI(settings);
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
        PublicKey peer_pk, /* in */ ChannelConfig chan_conf,
        /* in */ PublicNonce peer_nonce) @trusted
    {
        return this.flash.openChannel(peer_pk, chan_conf, peer_nonce);
    }

    ///
    public override Result!Point closeChannel (PublicKey sender_pk,
        PublicKey peer_pk, /* in */ Hash chan_id, /* in */ uint seq_id,
        /* in */ Point peer_nonce, /* in */ Amount fee) @trusted
    {
        return this.flash.closeChannel(sender_pk, peer_pk, chan_id, seq_id,
            peer_nonce, fee);
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
    public override Result!PublicNonce proposePayment (PublicKey sender_pk,
        PublicKey peer_pk,
        /* in */ Hash chan_id,
        /* in */ uint seq_id, /* in */ Hash payment_hash,
        /* in */ Amount amount, /* in */ Height lock_height,
        /* in */ OnionPacket packet, /* in */ PublicNonce peer_nonce,
        /* in */ Height height) @trusted
    {
        return this.flash.proposePayment(sender_pk, peer_pk, chan_id, seq_id,
            payment_hash, amount, lock_height, packet, peer_nonce, height);
    }

    ///
    public override Result!PublicNonce proposeUpdate (PublicKey sender_pk,
        PublicKey peer_pk, /* in */ Hash chan_id,
        /* in */ uint seq_id, /* in */ Hash[] secrets,
        /* in */ Hash[] rev_htlcs, /* in */ PublicNonce peer_nonce,
        /* in */ Height height) @trusted
    {
        return this.flash.proposeUpdate(sender_pk, peer_pk, chan_id, seq_id, secrets, rev_htlcs,
            peer_nonce, height);
    }

    ///
    public override Result!Signature requestSettleSig (PublicKey sender_pk,
        PublicKey peer_pk, /* in */ Hash chan_id, /* in */ uint seq_id) @trusted
    {
        return this.flash.requestSettleSig(sender_pk, peer_pk, chan_id, seq_id);
    }

    ///
    public override Result!Signature requestUpdateSig (PublicKey sender_pk,
        PublicKey peer_pk, /* in */ Hash chan_id, /* in */ uint seq_id) @trusted
    {
        return this.flash.requestUpdateSig(sender_pk, peer_pk, chan_id, seq_id);
    }

    ///
    public override Result!bool confirmChannelUpdate (PublicKey sender_pk,
        PublicKey peer_pk, /* in */ Hash chan_id, /* in */ uint seq_id) @trusted
    {
        return this.flash.confirmChannelUpdate(sender_pk, peer_pk, chan_id,
            seq_id);
    }

    ///
    public override Result!Signature requestCloseSig (PublicKey sender_pk,
        PublicKey peer_pk, /* in */ Hash chan_id, /* in */ uint seq_id) @trusted
    {
        return this.flash.requestCloseSig(sender_pk, peer_pk, chan_id, seq_id);
    }

    ///
    public override void reportPaymentError (
        PublicKey peer_pk, /* in */ Hash chan_id, /* in */ OnionError err) @trusted
    {
        this.flash.reportPaymentError(peer_pk, chan_id, err);
    }
}

///
public class FlashFullNode : FullNode, FlashFullNodeAPI
{
    /// Logger instance
    private Logger log;

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
            this.taskman, &this.putTransaction, &this.getFlashClient,
            &this.getFlashListenerClient);
    }

    public override void start ()
    {
        super.start();
        this.startNameRegistry();
    }

    public override void shutdown () @safe
    {
        this.flash.shutdown();
        this.periodic_timer.stop();
    }

    public override void receiveInvoice (Invoice invoice)
    {
        // todo: no-op
    }

    mixin FlashNodeCommon!();
}
