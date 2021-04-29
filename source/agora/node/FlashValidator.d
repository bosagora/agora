/*******************************************************************************

    Implementation of the FlashValidator API.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.FlashValidator;

import agora.api.Validator;
import agora.common.Amount;
import agora.common.Config;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Params;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.ValidatorBlockSig;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.protocol.Nominator;
import agora.consensus.Quorum;
import agora.consensus.protocol.Data;
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
import agora.network.Manager;
import agora.node.admin.AdminInterface;
import agora.node.BlockStorage;
import agora.node.FlashFullNode;
import agora.node.FullNode;
import agora.node.Ledger;
import agora.node.Validator;
import agora.registry.API;
import agora.utils.Log;
import agora.utils.PrettyPrinter;
import agora.utils.Test;

import scpd.types.Stellar_SCP;

import vibe.data.json;
import vibe.web.rest;

import std.algorithm : each, map;
import std.exception;
import std.path : buildPath;
import std.range;

import core.stdc.stdlib : abort;
import core.stdc.time;
import core.time;

///
public class FlashValidator : Validator, FlashValidatorAPI
{
    const alice = WK.Keys.NODE2;
    const bob   = WK.Keys.NODE3;

    /***************************************************************************

        Constructor

        Params:
            config = Config instance

    ***************************************************************************/

    public this (const Config config)
    {
        super(config);
        assert(this.config.flash.enabled);
        assert(this.config.validator.enabled);
        const flash_path = buildPath(this.config.node.data_dir, "flash.dat");
        this.flash = new AgoraFlashNode(this.config.flash,
            flash_path, hashFull(this.params.Genesis), this.engine,
            this.taskman, &this.putTransaction, &this.getFlashClient,
            &this.getFlashListenerClient);
    }

    public override void start ()
    {
        super.start();
    }

    public override void shutdown ()
    {
        this.flash.shutdown();
    }

    public override void receiveInvoice (Invoice invoice)
    {
    }

    mixin FlashNodeCommon!();
}
