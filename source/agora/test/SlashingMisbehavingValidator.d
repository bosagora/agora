/*******************************************************************************

    Contains tests for re-routing part of the frozen UTXO of a slashed
    validater to `CommonsBudget` address.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.SlashingMisbehavingValidator;

version (unittest):

import agora.common.Config;
import agora.common.ManagedDatabase;
import agora.consensus.data.Block;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.state.UTXOSet;
import agora.crypto.Schnorr;
import agora.crypto.Key;
import agora.utils.Test;
import agora.test.Base;

import std.exception;
import std.path : buildPath;

import core.atomic;
import core.stdc.stdint;
import core.thread;

import geod24.Registry;

/// Situation: A misbehaving validator does not reveal its preimages right after
///     it's enrolled.
/// Expectation: The information about the validator is stored in a block.
///     The validator is un-enrolled and a part of its fund is refunded to the
///     validators with the 10K of the fund going to the `CommonsBudget` address.
unittest
{
    static class BadAPIManager : TestAPIManager
    {
        public static shared bool reveal_preimage = false;

        ///
        mixin ForwardCtor!();

        ///
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 5)
                this.addNewNode!NoPreImageVN(conf, &reveal_preimage, file, line);
            else
                super.createNewNode(conf, file, line);
        }
    }

    TestConf conf = {
        recurring_enrollment : false,
    };
    auto network = makeTestNetwork!BadAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.nodes;
    auto spendable = network.blocks[$ - 1].spendable().array;
    auto bad_address = nodes[5].getPublicKey().key;

    // discarded UTXOs (just to trigger block creation)
    auto txs = spendable[0 .. 8].map!(txb => txb.sign()).array;

    auto utxos = nodes[0].getUTXOs(bad_address);
    auto original_stake = utxos[0].utxo.output.value;
    // block 1
    txs.each!(tx => nodes[0].putTransaction(tx));
    // Node index is 5 for bad node so we do not expect pre-image from it
    network.expectHeightAndPreImg(iota(0, 5), Height(1), network.blocks[0].header);

    assert(utxos.length == 1);
    auto block1 = nodes[0].getBlocksFrom(1, 1)[0];
    assert(block1.header.missing_validators.length == 1);
    auto cnt = nodes[0].countActive(block1.header.height + 1);
    assert(cnt == 5, format!"Invalid validator count, current: %s"(cnt));

    // check if the frozen UTXO is refunded to the owner and
    // the penalty is re-routed to the `CommonsBudget`
    auto refund = nodes[0].getUTXOs(bad_address);
    assert(refund.length == 1);
    auto penalty = nodes[0].getUTXOs(WK.Keys.CommonsBudget.address);
    assert(penalty.length == 1);
    auto total = refund[0].utxo.output.value;
    total.mustAdd(penalty[0].utxo.output.value);
    // Check that the two amounts add up to the original stake
    // TODO: Check for 40k, not just the total.
    assert(total == original_stake);

    // check the leftover UTXO is melting and the penalty UTXO is unfrozen
    assert(refund[0].utxo.unlock_height == 2017);
    assert(penalty[0].utxo.unlock_height == 2);
}

/// Situation: All the validators do not reveal their pre-images for
///     some time in the middle of creating the block of height 2 and
///     then start revealing their pre-images.
/// Expectation: The block of height 2 is created in the end after
///     some failures.
unittest
{
    TestConf conf = {
        recurring_enrollment : false,
    };
    auto network = makeTestNetwork!(LazyAPIManager!NoPreImageVN)(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;
    auto txs = network.blocks[$ - 1].spendable().map!(txb => txb.sign()).array;

    // block 1 must not be created because all the validators do not
    // reveal any pre-images after their enrollments.
    txs.each!(tx => nodes[0].putTransaction(tx));
    Thread.sleep(2.seconds); // Give time before checking still height 0
    network.expectHeight(Height(0));

    // all the validators start revealing pre-images
    atomicStore(network.reveal_preimage, true);

    // block 1 was created with no slashed validator
    network.expectHeightAndPreImg(Height(1), network.blocks[0].header);
    auto block1 = nodes[0].getBlocksFrom(1, 1)[0];
    assert(block1.header.missing_validators.length == 0);
}
